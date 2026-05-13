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
/// Facade for managing subtask execution instances, handling bulk completions and state synchronization.
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
    protected override Expression<Func<SubtaskInstanceEntity, bool>> CreateFilter(SubtaskInstanceQuery query)
    {
        return entity => true;
    }

    protected override Func<IQueryable<SubtaskInstanceEntity>, IOrderedQueryable<SubtaskInstanceEntity>> CreateOrderBy(
        SubtaskInstanceQuery query)
    {
        return q => q.OrderBy(e => e.TemplateSubtask.CreatedAt).ThenBy(e => e.TemplateSubtaskId);
    }

    /// <summary>
    /// Processes completion for a list of subtask IDs. Handles existing instances 
    /// and generates new ones if template IDs are provided (Individual mode).
    /// </summary>
    public async Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model)
    {
        if (model.InstanceIds == null || !model.InstanceIds.Any())
            return Result<int>.ValidationFailure("List of Subtask IDs cannot be empty.");

        var currentUserId = OptionalUserId;
        var currentUserEmail = userContext.GetEmail();
        int completedCount = 0;
        Guid? taskId = null;

        // Fetch instances that are already present in the database
        var existingInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Include(i => i.TemplateSubtask).ThenInclude(st => st.ParentTask)
            .Where(i => model.InstanceIds.Contains(i.Id))
            .ToListAsync();

        // Process standard updates for existing instances
        var existingResult = ProcessExistingInstances(existingInstances, model, currentUserId, currentUserEmail);
        if (!existingResult.IsSuccess) return existingResult;

        completedCount += existingResult.Value;
        if (existingInstances.Any()) taskId = existingInstances.First().TemplateSubtask.ParentTaskId;

        // Identify which IDs refer to templates that haven't been instantiated yet (Individual Mode)
        var processedInstanceIds = existingInstances.Select(i => i.Id).ToList();
        var templateIdsForCreation = model.InstanceIds.Except(processedInstanceIds).ToList();

        if (templateIdsForCreation.Any())
        {
            var creationResult =
                await CreateInstancesFromTemplates(templateIdsForCreation, model, currentUserId, currentUserEmail);
            completedCount += creationResult.count;
            taskId ??= creationResult.taskId;
        }

        if (taskId.HasValue)
        {
            await dbContext.SaveChangesAsync();
            // Recalculate and update the status of the parent Task and the user's Invitation chip
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
    /// Validates permissions and updates the completion state of existing instances.
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

            // Security checks
            if (task.RequiresAuthenticationToComplete && currentUserId == null)
                return Result<int>.Unauthorized("Authentication is required for this task.");

            if (instance.AssignedToUserId.HasValue && instance.AssignedToUserId.Value != currentUserId)
                return Result<int>.Unauthorized("Unauthorized access to subtask instance.");

            // Adopt "Ghost" instances (unassigned) if completed by a registered user
            if (instance.AssignedToUserId == null) instance.AssignedToUserId = currentUserId;
            if (!string.IsNullOrEmpty(currentUserEmail)) instance.AssignedToEmail = currentUserEmail;

            instance.IsCompleted = true;
            instance.CompletedByUserId = currentUserId;
            instance.CompletedAt = DateTime.UtcNow;
            instance.RespondentName = model.RespondentName;

            count++;
        }

        return Result<int>.Success(count);
    }

    /// <summary>
    /// For Individual mode: creates a personal set of subtask instances for a user 
    /// if they provided blueprint template IDs.
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

        // Check if the user already has a partial response group in this task to avoid duplicates
        Guid? existingGroupId = null;
        if (currentUserId.HasValue)
        {
            existingGroupId = await dbContext.Set<SubtaskInstanceEntity>()
                .Where(i => i.TemplateSubtask.ParentTaskId == parentTaskId && i.AssignedToUserId == currentUserId.Value)
                .Select(i => i.ResponseGroupId)
                .FirstOrDefaultAsync();
        }

        if (existingGroupId == null && !string.IsNullOrEmpty(currentUserEmail))
        {
            existingGroupId = await dbContext.Set<SubtaskInstanceEntity>()
                .Where(i => i.TemplateSubtask.ParentTaskId == parentTaskId && i.AssignedToEmail == currentUserEmail)
                .Select(i => i.ResponseGroupId)
                .FirstOrDefaultAsync();
        }

        var responseGroupId = existingGroupId ?? Guid.NewGuid();
        int count = 0;

        var allTemplatesOfTask = await dbContext.Set<SubtaskTemplateEntity>()
            .Where(t => t.ParentTaskId == parentTaskId).ToListAsync();

        // Fetch all existing instances in this group to fill gaps rather than recreating the whole set
        var existingInstancesInGroup = await dbContext.Set<SubtaskInstanceEntity>()
            .Where(i => i.ResponseGroupId == responseGroupId).ToListAsync();

        foreach (var template in allTemplatesOfTask)
        {
            bool isCompletingNow = templateIds.Contains(template.Id);
            var existingInstance = existingInstancesInGroup.FirstOrDefault(i => i.TemplateSubtaskId == template.Id);

            if (existingInstance != null)
            {
                // Update unassigned instance metadata
                if (existingInstance.AssignedToUserId == null && string.IsNullOrEmpty(existingInstance.AssignedToEmail))
                {
                    existingInstance.AssignedToUserId = currentUserId;
                    if (!string.IsNullOrEmpty(currentUserEmail)) existingInstance.AssignedToEmail = currentUserEmail;
                    existingInstance.RespondentName = model.RespondentName ?? existingInstance.RespondentName;
                }

                if (isCompletingNow && !existingInstance.IsCompleted)
                {
                    existingInstance.IsCompleted = true;
                    existingInstance.CompletedAt = DateTime.UtcNow;
                    existingInstance.CompletedByUserId = currentUserId;
                    count++;
                }
            }
            else
            {
                // Create a completely new instance if no entry exists for this template/group combination
                var newInstance = new SubtaskInstanceEntity
                {
                    TemplateSubtaskId = template.Id,
                    ResponseGroupId = responseGroupId,
                    IsCompleted = isCompletingNow,
                    RespondentName = model.RespondentName,
                    CompletedAt = isCompletingNow ? DateTime.UtcNow : null,
                    CompletedByUserId = currentUserId,
                    AssignedToUserId = currentUserId,
                    AssignedToEmail = !string.IsNullOrEmpty(currentUserEmail) ? currentUserEmail : null
                };

                await dbContext.Set<SubtaskInstanceEntity>().AddAsync(newInstance);
                if (isCompletingNow) count++;
            }
        }

        return (parentTaskId, count);
    }

    /// <summary>
    /// Synchronizes invitation and task statuses after changes to subtask instances.
    /// </summary>
    private async Task FinalizeTaskAndInvitationStatusAsync(Guid taskId)
    {
        await CheckAndSetTaskCompletionAsync(taskId);

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
            // In Shared mode, the user's status chip turns green if they contributed at least one subtask
            var hasAnyContributed = await dbContext.Set<SubtaskInstanceEntity>()
                .AnyAsync(i => i.TemplateSubtask.ParentTaskId == taskId &&
                               i.IsCompleted &&
                               (i.RespondentName == userEmail || i.CompletedByUserId == OptionalUserId));

            invitation.IsCompleted = hasAnyContributed;
        }
        else
        {
            // In Individual mode, the status chip turns green only when ALL their assigned work is done
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
    /// Determines if the overall parent Task state should move to 'Completed'.
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
    /// Dispatches SignalR notifications to refresh UI for the author and participants.
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