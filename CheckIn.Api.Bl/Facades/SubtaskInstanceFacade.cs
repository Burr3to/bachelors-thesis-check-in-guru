using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
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
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class SubtaskInstanceFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
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


    public async Task<Result<bool>> CompleteAsync(Guid instanceId)
    {
        var instance = await dbContext.Set<SubtaskInstanceEntity>()
            .Include(i => i.TemplateSubtask) // Načítame šablónu
            .ThenInclude(t => t.ParentTask) // A Task (aby sme zistili RequiresAuth)
            .FirstOrDefaultAsync(i => i.Id == instanceId);

        if (instance == null)
            return Result.NotFound($"Subtask instance with ID {instanceId} not found.");

        var task = instance.TemplateSubtask?.ParentTask;
        if (task == null)
            return Result.Failure(ErrorType.InternalError, "Parent Task structure missing.");

        var currentUserId = OptionalUserId;

        if (task.RequiresAuthenticationToComplete && currentUserId == null)
        {
            return Result.Unauthorized("Authentication is required to complete this task.");
        }

        // Kontrola, či je to splnenie pre PRIRADENÉHO užívateľa (Typ 2)
        if (instance.AssignedToUserId.HasValue)
        {
            if (currentUserId == null || instance.AssignedToUserId.Value != currentUserId.Value)
            {
                return Result.Forbidden("You are not authorized to complete this specific subtask instance.");
            }
        }

        // Ak už je splnené, vrátime úspech
        if (instance.IsCompleted)
            return Result.Success();

        // 4. Spracovanie splnenia
        if (!instance.IsCompleted)
        {
            instance.IsCompleted = true;
            instance.CompletedByUserId = currentUserId;
            instance.CompletedAt = DateTime.UtcNow;

            await dbContext.SaveChangesAsync();
        }

        try
        {
            await dbContext.SaveChangesAsync();
            return Result.Success();
        }
        catch (Exception ex)
        {
            return Result.Failure(ErrorType.InternalError, $"Failed to complete subtask: {ex.Message}");
        }
    }

    public async Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model)
    {
        var currentUserId = OptionalUserId;

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


        // 4. Uloženie VŠETKÝCH zmien v jednej transakcii
        await dbContext.SaveChangesAsync();

        return Result<int>.Success(completedCount);
    }
}