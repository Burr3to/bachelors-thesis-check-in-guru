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
/// Facade handling subtask definitions (templates) and their propagation to active instances.
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
    protected override Expression<Func<SubtaskTemplateEntity, bool>> CreateFilter(SubtaskTemplateQuery query)
    {
        return entity => true;
    }

    protected override Func<IQueryable<SubtaskTemplateEntity>, IOrderedQueryable<SubtaskTemplateEntity>> CreateOrderBy(
        SubtaskTemplateQuery query)
    {
        return q => q.OrderBy(e => e.CreatedAt).ThenBy(e => e.Id);
    }

    /// <summary>
    /// Creates a new subtask template and automatically propagates it as a new execution 
    /// instance to all existing response groups for the parent task.
    /// </summary>
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveCreateModelAsync(
        SubtaskTemplateCreateModel model)
    {
        var parentTask = await dbContext.Tasks.FindAsync(model.ParentTaskId);
        if (parentTask == null)
            return Result<SubtaskTemplateDetailModel>.NotFound("Parent Task not found.");

        if (parentTask.CreatedById != CurrentUserId)
            return Result<SubtaskTemplateDetailModel>.Forbidden();

        // Create the base template entity
        var result = await base.SaveCreateModelAsync(model);
        if (!result.IsSuccess) return result;

        var newTemplateId = result.Value!.Id;

        // Propagate changes: Find all existing participants (response groups) for this task 
        // to ensure everyone gets this new subtask added to their checklist.
        var existingGroupsInfo = await dbContext.SubtaskInstances
            .Where(i => i.TemplateSubtask.ParentTaskId == model.ParentTaskId)
            .GroupBy(i => i.ResponseGroupId)
            .Select(g => new
            {
                GroupId = g.Key,
                AssignedToUserId = g.Select(x => x.AssignedToUserId).FirstOrDefault(x => x != null),
                AssignedToEmail = g.Select(x => x.AssignedToEmail).FirstOrDefault(x => x != null),
                RespondentName = g.Select(x => x.RespondentName).FirstOrDefault(x => x != null)
            })
            .ToListAsync();

        if (existingGroupsInfo.Any())
        {
            foreach (var groupInfo in existingGroupsInfo)
            {
                var newInstance = new SubtaskInstanceEntity
                {
                    Id = Guid.NewGuid(),
                    TemplateSubtaskId = newTemplateId,
                    ResponseGroupId = groupInfo.GroupId,
                    IsCompleted = false,
                    // Directly assign the new instance to the group owner
                    AssignedToUserId = groupInfo.AssignedToUserId,
                    AssignedToEmail = groupInfo.AssignedToEmail,
                    RespondentName = groupInfo.RespondentName
                };
                await dbContext.SubtaskInstances.AddAsync(newInstance);
            }

            await dbContext.SaveChangesAsync();
        }

        // Notify active task rooms about the checklist structural change
        await NotifyChanges(model.ParentTaskId);

        return result;
    }

    /// <summary>
    /// Updates an existing template and notifies clients.
    /// </summary>
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveUpdateModelAsync(
        SubtaskTemplateUpdateModel model)
    {
        var result = await base.SaveUpdateModelAsync(model);

        if (result.IsSuccess)
        {
            var template = await dbContext.Subtasks.FindAsync(model.Id);
            if (template != null)
                await NotifyChanges(template.ParentTaskId);
        }

        return result;
    }

    /// <summary>
    /// Deletes a template and its associated instances across all response groups.
    /// </summary>
    public new async Task<Result<bool>> DeleteAsync(Guid entityId)
    {
        var template = await dbContext.Subtasks
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == entityId);

        if (template == null)
            return Result<bool>.NotFound();

        var parentTaskId = template.ParentTaskId;

        var result = await base.DeleteAsync(entityId);

        if (result.IsSuccess)
        {
            await NotifyChanges(parentTaskId);
        }

        return result;
    }

    /// <summary>
    /// Broadcasts Real-time updates via SignalR.
    /// </summary>
    private async Task NotifyChanges(Guid taskId)
    {
        var roomName = taskId.ToString().ToLower().Trim();

        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");
        await hubContext.Clients.Group(roomName).SendAsync("TaskTemplatesChanged");
    }
}