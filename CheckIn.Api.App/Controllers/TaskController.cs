using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
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

	[HttpGet("{taskId}/subtasks")]
	public async Task<ActionResult<List<SubtaskCombinedListModel>>> GetSubtasksByTask([FromRoute] Guid taskId)
	{
		// Využitie Facade, ktorá je definovaná v Base Controleri
		var result = await taskFacade.GetSubTasksForTask(taskId);

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
		{
			// Ok(result.Value) vráti 200 OK s telom TaskPublicDetailModel
			return Ok(result.Value);
		}

		// Spracovanie chyby (404, 401, 500...)
		return HandleResultFailure(result);
	}
}