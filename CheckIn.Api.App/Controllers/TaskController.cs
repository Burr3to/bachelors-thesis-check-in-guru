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

[Route("api/[controller]")]
[ApiController]
[Authorize(AuthenticationSchemes = "Bearer")]
public class TaskController(ITaskFacade taskFacade)
    : ApiControllerBase<TaskEntity, TaskListModel, TaskDetailModel, TaskCreateModel, TaskUpdateModel, TaskListQuery>
        (taskFacade)
{
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

    [HttpPut("{id}")]
    public override async Task<IActionResult> Put(Guid id, [FromBody] TaskUpdateModel model)
    {
        if (id != model.Id)
            return BadRequest("ID mismatch.");

        var result = await taskFacade.SaveUpdateModelAsync(model);

        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
        }

        return HandleResultFailure(result);
    }

    [HttpGet("{taskId}/instances")]
    public async Task<ActionResult<List<SubtaskCombinedListModel>>> GetInstances([FromRoute] Guid taskId)
    {
        var result = await taskFacade.GetTaskInstancesAsync(taskId);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }

    [HttpGet("{taskId}/templates")]
    public async Task<ActionResult<List<SubtaskCombinedListModel>>> GetTemplates([FromRoute] Guid taskId)
    {
        var result = await taskFacade.GetTaskTemplatesAsync(taskId);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }

    [HttpPost("summary-stats")]
    public async Task<ActionResult<List<TaskSummaryStats>>> GetTaskSummaryStats([FromBody] List<Guid> taskIds)
    {
        var result = await taskFacade.GetSummaryStats(taskIds);

        if (result.IsSuccess)
            return Ok(result.Value);

        return HandleResultFailure(result);
    }


    [HttpGet("public/{hash}")]
    [AllowAnonymous]
    public async Task<ActionResult<TaskPublicDetailModel>> GetPublicSubtasksByHash([FromRoute] string hash)
    {
        // Používame taskFacade (alebo _taskFacade, ak ste si ho definovali)
        var result = await ((ITaskFacade)Facade).GetTaskPublicDetailByHashAsync(hash);

        if (result.IsSuccess)
            return Ok(result.Value);

        if (result.ErrorType == ErrorType.Unauthorized)
            return Ok(new TaskDetailModel
                { RequiresAuthenticationToComplete = true, Title = "", Hash = "", SubtaskMode = SubtaskMode.Shared });

        // Spracovanie chyby (404, 401, 500...)
        return HandleResultFailure(result);
    }
}