using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Action;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class SubtaskInstanceFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IHubContext<TaskHub> hubContext)
    : FacadeBase<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
            SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
        (dbContext, mapper, userContext), ISubtaskInstanceFacade
{
    protected override Expression<Func<SubtaskInstanceEntity, bool>> CreateFilter(SubtaskInstanceQuery query)
    {
        Expression<Func<SubtaskInstanceEntity, bool>> filter = entity => true;
        // Ak SubtaskTemplateQuery obsahuje ParentTaskId:
        // if (query.ParentTaskId.HasValue) 
        //     filter = filter.And(e => e.ParentTaskId == query.ParentTaskId.Value);

        return filter;
    }

    protected override Func<IQueryable<SubtaskInstanceEntity>, IOrderedQueryable<SubtaskInstanceEntity>> CreateOrderBy(
        SubtaskInstanceQuery query)
    {
        return q => q.OrderBy(e => e.TemplateSubtask.CreatedAt).ThenBy(e => e.TemplateSubtaskId);
    }


    public async Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model)
    {
        var currentUserId = OptionalUserId;
        var currentUserEmail = userContext.GetEmail();
        Guid? taskId = null;

        // Ak je zoznam prázdny, vrátime BadRequest (alebo 0)
        if (model.InstanceIds == null || !model.InstanceIds.Any())
        {
            return Result<int>.ValidationFailure("List of Subtask Instance IDs cannot be empty.");
        }

        // 1. Načítanie všetkých inštancií, ktoré majú byť zmenené
        var existingInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Include(i => i.TemplateSubtask) // Potrebujeme Task pre RequiresAuthentication
            .ThenInclude(st => st.ParentTask)
            .Where(i => model.InstanceIds.Contains(i.Id))
            .ToListAsync();


        Console.WriteLine($"[BULK] Začínam spracovanie pre {model.InstanceIds?.Count} inštancií");
        if (existingInstances.Any())
            taskId = existingInstances.First().TemplateSubtask?.ParentTaskId;


        int completedCount = 0;

        // 2. Iterácia a overovanie každého Subtasku
        foreach (var instance in existingInstances)
        {
            if (instance.IsCompleted) continue;

            var task = instance.TemplateSubtask?.ParentTask;
            if (task == null) continue; // Chyba integrity, ignorujeme

            // Kontrola autentifikácie
            if (task.RequiresAuthenticationToComplete && currentUserId == null)
                return Result<int>.Unauthorized("Authentication is required for this task.");

            // Kontrola priradenia (ak je inštancia niekomu priradená, iný ju nemôže splniť)
            if (instance.AssignedToUserId.HasValue && instance.AssignedToUserId.Value != currentUserId)
                return Result<int>.Unauthorized("Unauthorized access to subtask instance.");

            // 3. Aktualizácia stavu
            instance.IsCompleted = true;
            instance.CompletedByUserId = currentUserId;
            instance.CompletedAt = DateTime.UtcNow;
            instance.RespondentName = model.RespondentName;
            if (!string.IsNullOrEmpty(currentUserEmail))
            {
                instance.AssignedToEmail = currentUserEmail;
            }

            completedCount++;
        }

        // --- 2. KROK: Spracovanie nových inštancií z ID šablón (pre anonymný Individual) ---
        var processedInstanceIds = existingInstances.Select(i => i.Id).ToList();
        var remainingIds = model.InstanceIds.Except(processedInstanceIds).ToList();

        if (remainingIds.Any())
        {
            // 1. Zistíme, ku ktorému Tasku patria tieto šablóny
            var firstTemplate = await dbContext.Set<SubtaskTemplateEntity>()
                .FirstOrDefaultAsync(t => t.Id == remainingIds.First());

            if (firstTemplate != null)
            {
                var parentTaskId = firstTemplate.ParentTaskId;

                // !!! KĽÚČOVÁ ZMENA: Načítame VŠETKY šablóny tohto tasku !!!
                var allTemplatesOfTask = await dbContext.Set<SubtaskTemplateEntity>()
                    .Where(t => t.ParentTaskId == parentTaskId)
                    .ToListAsync();

                var anonymousResponseGroupId = Guid.NewGuid();

                foreach (var template in allTemplatesOfTask)
                {
                    // Vytvoríme inštanciu pre KAŽDÚ šablónu tasku
                    bool isActuallyCompletedInThisRequest = remainingIds.Contains(template.Id);

                    var newInstance = new SubtaskInstanceEntity
                    {
                        TemplateSubtaskId = template.Id,
                        ResponseGroupId = anonymousResponseGroupId,
                        IsCompleted = isActuallyCompletedInThisRequest,
                        RespondentName = model.RespondentName,
                        CompletedAt = isActuallyCompletedInThisRequest ? DateTime.UtcNow : null,
                        CompletedByUserId = currentUserId,

                        AssignedToEmail = isActuallyCompletedInThisRequest && !string.IsNullOrEmpty(currentUserEmail)
                            ? currentUserEmail
                            : null
                    };

                    await dbContext.Set<SubtaskInstanceEntity>().AddAsync(newInstance);

                    if (isActuallyCompletedInThisRequest)
                    {
                        completedCount++;
                    }
                }

                taskId = parentTaskId; // Nastavíme taskId pre SignalR
            }
        }


        if (taskId.HasValue)
        {
            // 1. KROK: Uložíme splnené inštancie (aby ich kontrolné funkcie videli v DB)
            await dbContext.SaveChangesAsync();

            // 2. KROK: Spustíme kontrolné mechanizmy
            await CheckAndSetTaskCompletionAsync(taskId.Value); // Zmení Task.State na Completed (ak treba)
            await UpdateInvitationStatusAsync(taskId.Value); // Zmení Invitation.IsCompleted na true (ak treba)

            // 3. KROK: Uložíme zmeny, ktoré spravili kontrolné mechanizmy
            await dbContext.SaveChangesAsync();

            // --- SIGNALR NOTIFIKÁCIE ---
            var taskAuthorId = await dbContext.Set<TaskEntity>()
                .Where(t => t.Id == taskId.Value)
                .Select(t => t.CreatedById)
                .FirstOrDefaultAsync();

            var roomName = taskId.Value.ToString().ToLower().Trim();

            // A. Notifikácia pre DETAIL úlohy (obnoví checklist a čipy pozvánok)
            await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");
            await hubContext.Clients.Group(roomName).SendAsync("TaskUpdated"); // Ak meníme stav tasku na Completed

            // B. Notifikácia pre DASHBOARD autora (obnoví riadok v zozname úloh)
            if (taskAuthorId != Guid.Empty)
            {
                var userGroupName = $"User_{taskAuthorId.ToString().ToLower()}";
                await hubContext.Clients.Group(userGroupName).SendAsync("AuthorTaskUpdated", taskId.Value.ToString());
            }

            Console.WriteLine($"[BULK & SIGNALR] Všetko spracované pre TaskId: {taskId}");
        }
        else
        {
            // Toto sa stane len ak niekto pošle prázdny zoznam ID
            await dbContext.SaveChangesAsync();
        }

        return Result<int>.Success(completedCount);
    }

    private async Task UpdateInvitationStatusAsync(Guid taskId)
    {
        var currentUserId = OptionalUserId;
        var userEmail = userContext.GetEmail();

        if (string.IsNullOrEmpty(userEmail)) return;

        var normalizedEmail = userEmail.ToLower().Trim();

        var invitation = await dbContext.Set<InvitationEntity>()
            .FirstOrDefaultAsync(i => i.TaskId == taskId && i.Email.ToLower() == normalizedEmail);

        if (invitation == null || invitation.IsCompleted) return;

        var taskMode = await dbContext.Set<TaskEntity>()
            .Where(t => t.Id == taskId)
            .Select(t => t.SubtaskMode)
            .FirstOrDefaultAsync();

        bool hasPendingWork;

        if (taskMode == SubtaskMode.Individual)
        {
            if (currentUserId.HasValue)
            {
                // Registrovaný používateľ: kontrolujeme len tie, čo sú priradené jemu
                hasPendingWork = await dbContext.Set<SubtaskInstanceEntity>()
                    .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId &&
                                   i.AssignedToUserId == currentUserId.Value &&
                                   !i.IsCompleted);
            }
            else
            {
                // ANONYMNÝ používateľ v Individual móde: 
                // Tu je to zložitejšie. Ak je to "Main Task Only", tak po SaveChanges 
                // a pri správnom priradení ResponseGroupId by sme mali hľadať 
                // podľa mena respondenta alebo v rámci tejto session.

                // NAJJEDNODUCHŠIA LOGIKA pre "Main Task Only": 
                // Ak sme v tejto funkcii a práve sme niečo úspešne uložili, 
                // a v zozname inštancií pre tento task a toto MENO už nie je nič voľné.
                hasPendingWork = await dbContext.Set<SubtaskInstanceEntity>()
                    .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId &&
                                   i.RespondentName ==
                                   invitation.Email && // Použijeme email ako identifikátor v inštancii
                                   !i.IsCompleted);
            }
        }
        else
        {
            // Shared Mode: tu nás zaujíma celkový stav úloh v tasku
            hasPendingWork = await dbContext.Set<SubtaskInstanceEntity>()
                .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId && !i.IsCompleted);
        }

        if (!hasPendingWork)
        {
            invitation.IsCompleted = true;

            await hubContext.Clients.Group(taskId.ToString().ToLower()).SendAsync("TaskInvitationsChanged");
        }
    }


    private async Task CheckAndSetTaskCompletionAsync(Guid taskId)
    {
        var task = await dbContext.Set<TaskEntity>()
            .Include(t => t.Invitations)
            .Include(t => t.Subtasks)
            .ThenInclude(st => st.Instances)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null || task.State == TaskState.Completed) return;

        bool isAllDone = false;
        var now = DateTime.UtcNow;

        if (task.SubtaskMode == SubtaskMode.Shared)
        {
            // SHARED: Ostáva rovnaké (každý subtask splnený aspoň raz)
            isAllDone = task.Subtasks.All(st => st.Instances.Any(i => i.IsCompleted));
        }
        else // INDIVIDUAL
        {
            int invitedCount = task.Invitations.Count;

            if (invitedCount == 0)
            {
                // NOVÁ LOGIKA: Verejný individuálny task
                // Ak je aktuálny čas po deadline, tento posledný respondent task "uzamkol"
                isAllDone = now > task.DeadLine;
            }
            else
            {
                // Pozvaní respondenti: Task je hotový, ak všetci pozvaní odovzdali
                var completedGroupsCount = task.Subtasks
                    .SelectMany(st => st.Instances)
                    .GroupBy(i => i.ResponseGroupId)
                    .Count(g => g.Count() == task.Subtasks.Count && g.All(i => i.IsCompleted));

                isAllDone = completedGroupsCount >= invitedCount;

                // BONUS: Ak chceš, aby sa aj pri pozvaných ľuďoch task zavrel po deadline, 
                // keď niekto odpovie neskoro, pridaj:
                if (!isAllDone && now > task.DeadLine)
                {
                    isAllDone = true;
                }
            }
        }

        if (isAllDone)
        {
            task.State = TaskState.Completed;
            task.LastModifiedAt = now;

            // SignalR notifikácia
            var userGroupName = $"User_{task.CreatedById.ToString().ToLower()}";
            await hubContext.Clients.Group(userGroupName).SendAsync("AuthorTaskUpdated", task.Id.ToString());
        }
    }
}