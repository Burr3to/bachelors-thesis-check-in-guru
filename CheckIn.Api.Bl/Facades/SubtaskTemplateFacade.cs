using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
using CheckIn.Api.Bl.Services.Interfaces;
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
/// Facade handling the lifecycle of subtask templates, including automatic 
/// synchronization with subtask instances and real-time updates via SignalR.
/// </summary>
public class SubtaskTemplateFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IHubContext<TaskHub> hubContext)
    : FacadeBase<SubtaskTemplateEntity, SubtaskTemplateListModel, SubtaskTemplateDetailModel,
            SubtaskTemplateCreateModel, SubtaskTemplateUpdateModel, SubtaskTemplateQuery>
        (dbContext, mapper, userContext), ISubtaskTemplateFacade
{
    /// <summary>
    /// Configures filtering for subtask templates.
    /// </summary>
    protected override Expression<Func<SubtaskTemplateEntity, bool>> CreateFilter(SubtaskTemplateQuery query)
    {
        Expression<Func<SubtaskTemplateEntity, bool>> filter = entity => true;

        // Add specific filtering logic here if needed (e.g., by ParentTaskId)

        return filter;
    }

    /// <summary>
    /// Defines the default ordering for subtask templates (chronological).
    /// </summary>
    protected override Func<IQueryable<SubtaskTemplateEntity>, IOrderedQueryable<SubtaskTemplateEntity>> CreateOrderBy(
        SubtaskTemplateQuery query)
    {
        return q => q.OrderBy(e => e.CreatedAt).ThenBy(e => e.Id);
    }

    /// <summary>
    /// Creates a new subtask template and automatically generates instances 
    /// for all existing participants or groups assigned to the parent task.
    /// </summary>
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveCreateModelAsync(
        SubtaskTemplateCreateModel model)
    {
        // Permission check: Verify the parent task exists and belongs to the current user
        var parentTask = await dbContext.Tasks.FindAsync(model.ParentTaskId);
        if (parentTask == null)
            return Result<SubtaskTemplateDetailModel>.NotFound("Parent Task not found.");

        if (parentTask.CreatedById != CurrentUserId)
            return Result<SubtaskTemplateDetailModel>.Forbidden();

        // Create the blueprint template
        var result = await base.SaveCreateModelAsync(model);
        if (!result.IsSuccess) return result;

        var newTemplateId = result.Value!.Id;

        // Synchronization logic: 
        // Find all existing response groups for this task (unique sets for users/shared mode)
        var existingResponseGroups = await dbContext.SubtaskInstances
            .Where(i => i.TemplateSubtask.ParentTaskId == model.ParentTaskId)
            .Select(i => i.ResponseGroupId)
            .Distinct()
            .ToListAsync();

        // Create an executable instance of this new template for every existing group
        if (existingResponseGroups.Any())
        {
            foreach (var groupId in existingResponseGroups)
            {
                var newInstance = new SubtaskInstanceEntity
                {
                    Id = Guid.NewGuid(),
                    TemplateSubtaskId = newTemplateId,
                    ResponseGroupId = groupId,
                    IsCompleted = false
                };
                await dbContext.SubtaskInstances.AddAsync(newInstance);
            }

            await dbContext.SaveChangesAsync();
        }

        // Notify all connected clients about the structure change
        await NotifyChanges(model.ParentTaskId);

        return result;
    }

    /// <summary>
    /// Updates an existing subtask template and notifies relevant clients via SignalR.
    /// </summary>
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveUpdateModelAsync(
        SubtaskTemplateUpdateModel model)
    {
        var result = await base.SaveUpdateModelAsync(model);

        if (result.IsSuccess)
        {
            // Retrieve parent ID to identify the SignalR room
            var template = await dbContext.Subtasks.FindAsync(model.Id);
            if (template != null)
                await NotifyChanges(template.ParentTaskId);
        }

        return result;
    }

    /// <summary>
    /// Deletes a subtask template and triggers a UI refresh for all participants.
    /// </summary>
    public new async Task<Result<bool>> DeleteAsync(Guid entityId)
    {
        var template = await dbContext.Subtasks
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == entityId);

        if (template == null)
            return Result<bool>.NotFound();

        var parentTaskId = template.ParentTaskId;

        // Note: Related SubtaskInstances should be handled via Cascade Delete in the database
        var result = await base.DeleteAsync(entityId);

        if (result.IsSuccess)
        {
            await NotifyChanges(parentTaskId);
        }

        return result;
    }

    /// <summary>
    /// Helper method to send SignalR notifications to both the author and the respondents.
    /// </summary>
    /// <param name="taskId">The ID of the task room to notify.</param>
    private async Task NotifyChanges(Guid taskId)
    {
        var roomName = taskId.ToString().ToLower().Trim();

        // Notify respondents to refresh their checklists
        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");

        // Notify the author to update the progress management view
        await hubContext.Clients.Group(roomName).SendAsync("TaskTemplatesChanged");
    }
}