using System.Linq.Expressions;
using AutoMapper;
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

/// <summary>
/// Implementation of subtask instance management logic.
/// Handles the lifecycle of subtask execution in both Individual and Shared modes.
/// </summary>
public class SubtaskInstanceFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IHubContext<TaskHub> hubContext)
    : FacadeBase<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
            SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
        (dbContext, mapper, userContext), ISubtaskInstanceFacade
{
    /// <summary>
    /// Placeholder for entity filtering.
    /// </summary>
    protected override Expression<Func<SubtaskInstanceEntity, bool>> CreateFilter(SubtaskInstanceQuery query)
    {
        return entity => true;
    }

    /// <summary>
    /// Orders instances by the creation date of their respective templates.
    /// </summary>
    protected override Func<IQueryable<SubtaskInstanceEntity>, IOrderedQueryable<SubtaskInstanceEntity>> CreateOrderBy(
        SubtaskInstanceQuery query)
    {
        return q => q.OrderBy(e => e.TemplateSubtask.CreatedAt).ThenBy(e => e.TemplateSubtaskId);
    }

    /// <summary>
    /// Completes subtasks in bulk. Handles existing instances and generates new ones 
    /// for Individual mode if only template IDs are provided.
    /// </summary>
    /// <param name="model">The bulk completion model containing instance/template IDs.</param>
    /// <returns>A result containing the number of successfully completed subtasks.</returns>
    public async Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model)
    {
        if (model.InstanceIds == null || !model.InstanceIds.Any())
            return Result<int>.ValidationFailure("List of Subtask IDs cannot be empty.");

        var currentUserId = OptionalUserId;
        var currentUserEmail = userContext.GetEmail();
        int completedCount = 0;
        Guid? taskId = null;

        // 1. Process instances that already exist in the database
        var existingInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Include(i => i.TemplateSubtask).ThenInclude(st => st.ParentTask)
            .Where(i => model.InstanceIds.Contains(i.Id))
            .ToListAsync();

        var existingResult = ProcessExistingInstances(existingInstances, model, currentUserId, currentUserEmail);
        if (!existingResult.IsSuccess) return existingResult;

        completedCount += existingResult.Value;
        if (existingInstances.Any()) taskId = existingInstances.First().TemplateSubtask.ParentTaskId;

        // 2. Process template IDs (create new instances for Individual mode)
        var processedInstanceIds = existingInstances.Select(i => i.Id).ToList();
        var templateIdsForCreation = model.InstanceIds.Except(processedInstanceIds).ToList();

        if (templateIdsForCreation.Any())
        {
            var creationResult =
                await CreateInstancesFromTemplates(templateIdsForCreation, model, currentUserId, currentUserEmail);
            completedCount += creationResult.count;
            taskId ??= creationResult.taskId;
        }

        // 3. Finalize and Notify
        if (taskId.HasValue)
        {
            await dbContext.SaveChangesAsync();
            await FinalizeTaskAndInvitationStatusAsync(taskId.Value);
            await SendBulkCompleteNotificationsAsync(taskId.Value);
            await dbContext.SaveChangesAsync();
        }
        else
        {
            await dbContext.SaveChangesAsync();
        }

        return Result<int>.Success(completedCount);
    }

    /// <summary>
    /// Updates properties of existing subtask instances in the database.
    /// </summary>
    private Result<int> ProcessExistingInstances(
        List<SubtaskInstanceEntity> instances,
        BulkSubtaskCompleteModel model,
        Guid? currentUserId,
        string? currentUserEmail)
    {
        int count = 0;
        foreach (var instance in instances)
        {
            if (instance.IsCompleted) continue;

            var task = instance.TemplateSubtask?.ParentTask;
            if (task == null) continue;

            if (task.RequiresAuthenticationToComplete && currentUserId == null)
                return Result<int>.Unauthorized("Authentication is required for this task.");

            if (instance.AssignedToUserId.HasValue && instance.AssignedToUserId.Value != currentUserId)
                return Result<int>.Unauthorized("Unauthorized access to subtask instance.");

            instance.IsCompleted = true;
            instance.CompletedByUserId = currentUserId;
            instance.CompletedAt = DateTime.UtcNow;
            instance.RespondentName = model.RespondentName;

            if (!string.IsNullOrEmpty(currentUserEmail)) instance.AssignedToEmail = currentUserEmail;
            count++;
        }

        return Result<int>.Success(count);
    }

    /// <summary>
    /// Generates a new ResponseGroup and set of instances when an Individual task is first interacted with.
    /// </summary>
    private async Task<(Guid? taskId, int count)> CreateInstancesFromTemplates(
        List<Guid> templateIds,
        BulkSubtaskCompleteModel model,
        Guid? currentUserId,
        string? currentUserEmail)
    {
        var firstTemplate = await dbContext.Set<SubtaskTemplateEntity>()
            .FirstOrDefaultAsync(t => t.Id == templateIds.First());

        if (firstTemplate == null) return (null, 0);

        var parentTaskId = firstTemplate.ParentTaskId;
        var allTemplatesOfTask = await dbContext.Set<SubtaskTemplateEntity>()
            .Where(t => t.ParentTaskId == parentTaskId).ToListAsync();

        var anonymousResponseGroupId = Guid.NewGuid();
        int count = 0;

        foreach (var template in allTemplatesOfTask)
        {
            bool isActuallyCompleted = templateIds.Contains(template.Id);
            var newInstance = new SubtaskInstanceEntity
            {
                TemplateSubtaskId = template.Id,
                ResponseGroupId = anonymousResponseGroupId,
                IsCompleted = isActuallyCompleted,
                RespondentName = model.RespondentName,
                CompletedAt = isActuallyCompleted ? DateTime.UtcNow : null,
                CompletedByUserId = currentUserId,
                AssignedToEmail = isActuallyCompleted && !string.IsNullOrEmpty(currentUserEmail)
                    ? currentUserEmail
                    : null
            };

            await dbContext.Set<SubtaskInstanceEntity>().AddAsync(newInstance);
            if (isActuallyCompleted) count++;
        }

        return (parentTaskId, count);
    }

    /// <summary>
    /// Orchestrates the status updates for both the parent Task and the user's Invitation.
    /// </summary>
    private async Task FinalizeTaskAndInvitationStatusAsync(Guid taskId)
    {
        // 1. Evaluate Task-wide completion
        await CheckAndSetTaskCompletionAsync(taskId);

        // 2. Synchronize user's personal invitation status (The Green Chip)
        var userEmail = userContext.GetEmail();
        if (string.IsNullOrEmpty(userEmail)) return;

        var normalizedEmail = userEmail.ToLower().Trim();
        var invitation = await dbContext.Set<InvitationEntity>()
            .FirstOrDefaultAsync(i => i.TaskId == taskId && i.Email.ToLower() == normalizedEmail);

        if (invitation == null) return;

        var taskMode = await dbContext.Set<TaskEntity>()
            .Where(t => t.Id == taskId).Select(t => t.SubtaskMode).FirstOrDefaultAsync();

        if (taskMode == SubtaskMode.Shared)
        {
            // SHARED MODE logic: If user contributed at least once, chip turns green.
            var hasAnyContributed = await dbContext.Set<SubtaskInstanceEntity>()
                .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId &&
                               i.IsCompleted &&
                               (i.RespondentName == userEmail || i.CompletedByUserId == OptionalUserId));

            invitation.IsCompleted = hasAnyContributed;
        }
        else
        {
            // INDIVIDUAL MODE logic: All instances assigned to this user must be completed.
            var hasPendingWork = await dbContext.Set<SubtaskInstanceEntity>()
                .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId &&
                               (i.AssignedToEmail == userEmail || i.RespondentName == userEmail) &&
                               !i.IsCompleted);

            invitation.IsCompleted = !hasPendingWork;
        }

        if (invitation.IsCompleted)
        {
            invitation.IsAccepted = true;
            await hubContext.Clients.Group(taskId.ToString().ToLower()).SendAsync("TaskInvitationsChanged");
        }
    }

    /// <summary>
    /// Evaluates if the entire task should be marked as Completed.
    /// </summary>
    private async Task CheckAndSetTaskCompletionAsync(Guid taskId)
    {
        var task = await dbContext.Set<TaskEntity>()
            .Include(t => t.Invitations)
            .Include(t => t.Subtasks).ThenInclude(st => st.Instances)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null || task.State == TaskState.Completed) return;

        bool isAllDone = false;
        var now = DateTime.UtcNow;

        if (task.SubtaskMode == SubtaskMode.Shared)
        {
            isAllDone = task.Subtasks.All(st => st.Instances.Any(i => i.IsCompleted));
        }
        else
        {
            int invitedCount = task.Invitations.Count;
            if (invitedCount == 0)
            {
                isAllDone = now > task.DeadLine;
            }
            else
            {
                var completedGroupsCount = task.Subtasks
                    .SelectMany(st => st.Instances)
                    .GroupBy(i => i.ResponseGroupId)
                    .Count(g => g.Count() == task.Subtasks.Count && g.All(i => i.IsCompleted));

                isAllDone = completedGroupsCount >= invitedCount || now > task.DeadLine;
            }
        }

        if (isAllDone)
        {
            task.State = TaskState.Completed;
            task.LastModifiedAt = now;
        }
    }

    /// <summary>
    /// Sends SignalR notifications to the task room and the author's dashboard.
    /// </summary>
    private async Task SendBulkCompleteNotificationsAsync(Guid taskId)
    {
        var roomName = taskId.ToString().ToLower().Trim();
        var taskAuthorId = await dbContext.Set<TaskEntity>()
            .Where(t => t.Id == taskId).Select(t => t.CreatedById).FirstOrDefaultAsync();

        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");
        await hubContext.Clients.Group(roomName).SendAsync("TaskUpdated");

        if (taskAuthorId != Guid.Empty)
        {
            var userGroupName = $"User_{taskAuthorId.ToString().ToLower()}";
            await hubContext.Clients.Group(userGroupName).SendAsync("AuthorTaskUpdated", taskId.ToString());
        }
    }
}