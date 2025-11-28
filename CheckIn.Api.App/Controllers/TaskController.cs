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
}