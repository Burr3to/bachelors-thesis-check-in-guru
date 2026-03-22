using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.App.Hubs;
using CheckIn.Api.Bl.Facades.Interfaces;
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
        return q => q.OrderBy(e => e.Id);
    }


    public async Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model)
    {
        var currentUserId = OptionalUserId;
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
            //instance.Comment = model.CommonComment;

            completedCount++;
        }

        // --- 2. KROK: Spracovanie nových inštancií z ID šablón (pre anonymný Individual) ---
        // Zistíme, ktoré ID z modelu neboli nájdené medzi existujúcimi inštanciami
        var processedInstanceIds = existingInstances.Select(i => i.Id).ToList();
        var remainingIds = model.InstanceIds.Except(processedInstanceIds).ToList();

        if (remainingIds.Any())
        {
            var templates = await dbContext.Set<SubtaskTemplateEntity>()
                .Include(t => t.ParentTask)
                .Where(t => remainingIds.Contains(t.Id))
                .ToListAsync();


            // !!! TOTO TU CHÝBALO !!!
            if (taskId == null && templates.Any())
                taskId = templates.First().ParentTaskId;

            var anonymousResponseGroupId = Guid.NewGuid();

            foreach (var template in templates)
            {
                var task = template.ParentTask;
                if (task == null) continue;

                // Logika: Ak je to Individual a anonym, vytvoríme novú inštanciu "on-the-fly"
                if (task.SubtaskMode == SubtaskMode.Individual)
                {
                    if (task.RequiresAuthenticationToComplete && currentUserId == null)
                        return Result<int>.Unauthorized("Authentication is required to complete this task.");

                    var newInstance = new SubtaskInstanceEntity
                    {
                        TemplateSubtaskId = template.Id,
                        ResponseGroupId = anonymousResponseGroupId,
                        IsCompleted = true,
                        RespondentName = model.RespondentName,
                        CompletedAt = DateTime.UtcNow,
                        CompletedByUserId = OptionalUserId, // Guid? (null pre anonymov)
                        //AssignedToUserId = currentUserId   // Guid? (null pre anonymov)
                    };

                    await dbContext.Set<SubtaskInstanceEntity>().AddAsync(newInstance);
                    completedCount++;
                }
                else
                {
                    // Ak je to Shared mód, ale inštancia nebola nájdená v 1. kroku, 
                    // niečo je zle (inštancia mala byť vytvorená pri Tasku).
                    // Môžeš to buď ignorovať, alebo vrátiť chybu.
                }
            }
        }


        await dbContext.SaveChangesAsync();
        Console.WriteLine($"[BULK] Zmeny uložené do DB. TaskId: {taskId}");

        //SignalR
        if (taskId.HasValue)
        {
            var roomName = taskId.Value.ToString().ToLower().Trim();
            Console.WriteLine($"[SIGNALR] Odosielam signál do ROOM: '{roomName}'");

            await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");

            await hubContext.Clients.Group(taskId.Value.ToString()).SendAsync("TaskStatsChanged");
        }
        else
        {
            Console.WriteLine("[SIGNALR] VAROVANIE: Signál neodoslaný, taskId je NULL!");
        }


        return Result<int>.Success(completedCount);
    }
}