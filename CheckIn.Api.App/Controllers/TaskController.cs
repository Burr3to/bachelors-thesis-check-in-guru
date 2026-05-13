using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services;
using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Common.Statistics;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

/// <summary>
/// Controller for managing task entities, including their lifecycle, invitations, and related subtasks.
/// </summary>
[Route("api/[controller]")]
[ApiController]
[Authorize(AuthenticationSchemes = "Bearer")]
public class TaskController(ITaskFacade taskFacade)
    : ApiControllerBase<TaskEntity, TaskListModel, TaskDetailModel, TaskCreateModel, TaskUpdateModel, TaskListQuery>
        (taskFacade)
{
    /// <summary>
    /// Retrieves a paginated and filtered list of tasks.
    /// </summary>
    /// <param name="query">Filtering and pagination parameters.</param>
    /// <returns>A result containing the list of tasks.</returns>
    [HttpGet]
    public override async Task<ActionResult<QueryResult<TaskListModel>>> GetList([FromQuery] TaskListQuery query)
    {
        var result = await taskFacade.GetListAsync(query);

        if (!result.IsSuccess)
        {
            return HandleResultFailure(result);
        }

        return Ok(result.Value);
    }

    /// <summary>
    /// Creates a new task and returns its detailed view.
    /// </summary>
    /// <param name="model">Task creation data.</param>
    [HttpPost]
    public override async Task<ActionResult<TaskDetailModel>> Post([FromBody] TaskCreateModel model)
    {
        var result = await taskFacade.SaveCreateModelAsync(model);

        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Updates an existing task.
    /// </summary>
    /// <param name="id">Task identifier.</param>
    /// <param name="model">Updated task data.</param>
    [HttpPut("{id}")]
    public override async Task<IActionResult> Put(Guid id, [FromBody] TaskUpdateModel model)
    {
        // Validate that the ID in the route matches the ID in the body
        if (id != model.Id)
            return BadRequest("ID mismatch.");

        var result = await taskFacade.SaveUpdateModelAsync(model);

        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Retrieves all subtask instances (execution rows) associated with a specific task.
    /// </summary>
    /// <param name="taskId">The ID of the parent task.</param>
    [HttpGet("{taskId}/instances")]
    public async Task<ActionResult<List<SubtaskCombinedListModel>>> GetInstances([FromRoute] Guid taskId)
    {
        var result = await taskFacade.GetTaskInstancesAsync(taskId);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Removes multiple invitations from a task based on provided emails.
    /// </summary>
    /// <param name="id">Task identifier.</param>
    /// <param name="emails">List of emails to be removed.</param>
    [HttpDelete("{id}/invitations")]
    public async Task<ActionResult<Result<bool>>> RemoveInvitations(Guid id, [FromBody] List<string> emails)
    {
        var result = await taskFacade.RemoveInvitationsAsync(id, emails);

        if (result.IsSuccess)
            return Ok(result);

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Retrieves the subtask templates (blueprints) defined for a specific task.
    /// </summary>
    /// <param name="taskId">The ID of the parent task.</param>
    [HttpGet("{taskId}/templates")]
    public async Task<ActionResult<List<SubtaskCombinedListModel>>> GetTemplates([FromRoute] Guid taskId)
    {
        var result = await taskFacade.GetTaskTemplatesAsync(taskId);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Calculates summary statistics for a given set of tasks.
    /// </summary>
    /// <param name="taskIds">List of task IDs to include in statistics.</param>
    [HttpPost("summary-stats")]
    public async Task<ActionResult<List<TaskSummaryStats>>> GetTaskSummaryStats([FromBody] List<Guid> taskIds)
    {
        var result = await taskFacade.GetSummaryStats(taskIds);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }


    /// <summary>
    /// Retrieves public details of a task using a unique access hash.
    /// Handles authentication and domain restriction logic.
    /// </summary>
    /// <param name="hash">The unique public access hash.</param>
    [HttpGet("public/{hash}")]
    [AllowAnonymous]
    public async Task<ActionResult<TaskPublicDetailModel>> GetPublicSubtasksByHash([FromRoute] string hash)
    {
        var result = await ((ITaskFacade)Facade).GetTaskPublicDetailByHashAsync(hash);

        if (result.IsSuccess)
            return Ok(result.Value);

        // Special handling for public access:
        // We return 200 OK even for restricted access so the frontend can display specific 
        // messages (e.g., login required or domain forbidden) instead of a generic error.

        // Case: User is not authenticated
        if (result.ErrorType == ErrorType.Unauthorized)
            return Ok(new TaskPublicDetailModel
            {
                RequiresAuthenticationToComplete = true,
                Title = "null"
            });

        // Case: User email domain is not allowed for this task
        if (result.ErrorType == ErrorType.Forbidden)
            return Ok(new TaskPublicDetailModel
            {
                IsForbidden = true,
                ForbiddenMessage = result.ErrorMessage,
                Title = "null"
            });

        return HandleResultFailure(result);
    }
}