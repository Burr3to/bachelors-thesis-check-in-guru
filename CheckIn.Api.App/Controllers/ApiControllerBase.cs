using System.Linq.Expressions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace CheckIn.Api.App.Controllers;

public abstract class ApiControllerBase<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>(
	IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel> facade)
	: ControllerBase
	where TDetailModel : class, IEntityModel
	where TCreateModel : class
	where TUpdateModel : IEntityModel
	where TQueryModel : IPageableQuery, new()
{
	// Uložíme fasádu ako chránenú pre prípad, že konkrétny kontrolér potrebuje špecifické volania
	protected readonly IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel> Facade = facade;


	[HttpGet]
	public virtual async Task<ActionResult<IEnumerable<TListModel>>> GetList([FromQuery] TQueryModel query)
	{
		var resultQueryable = await Facade.GetListAsync(query);

		return Ok(resultQueryable.ToList());
	}


	[HttpGet("{id}")]
	public async Task<ActionResult<TaskDetailModel>> GetById(Guid id)
	{
		var result = await Facade.GetByIdAsync(id);

		if (result.IsSuccess)
		{
			return Ok(result.Value);
		}

		return result.ErrorType switch
		{
			ErrorType.NotFound => NotFound(result.ErrorMessage), // 404
			ErrorType.Forbidden => Forbid(),
			_ => StatusCode(StatusCodes.Status500InternalServerError, result.ErrorMessage)
		};
	}


	[HttpPut("{id}")]
	public async Task<IActionResult> Put(Guid id, [FromBody] TUpdateModel model)
	{
		if (id != model.Id)
		{
			return BadRequest("ID mismatch: Route ID must match Model ID.");
		}

		var result = await Facade.SaveUpdateModelAsync(model);

		if (result.IsSuccess)
			return NoContent();

		return result.ErrorType switch
		{
			ErrorType.NotFound => NotFound(result.ErrorMessage), // 404
			ErrorType.Forbidden => Forbid(), // 403
			ErrorType.Validation => BadRequest(result.ErrorMessage),
			ErrorType.Conflict => Conflict(result.ErrorMessage),
			_ => StatusCode(StatusCodes.Status500InternalServerError,
				new { Error = "Internal error during update.", Details = result.ErrorMessage })
		};
	}


	[HttpPost]
	public async Task<ActionResult<TaskDetailModel>> Post([FromBody] TCreateModel model)
	{
		var result = await Facade.SaveCreateModelAsync(model);

		if (result.IsSuccess)
		{
			return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
		}

		return result.ErrorType switch
		{
			ErrorType.Validation => BadRequest(result.ErrorMessage),
			ErrorType.Unauthorized => Unauthorized(result.ErrorMessage),
			ErrorType.Conflict => Conflict(result.ErrorMessage), // 409
			_ => StatusCode(StatusCodes.Status500InternalServerError, result.ErrorMessage)
		};
	}


	[HttpDelete("{id}")]
	public async Task<IActionResult> Delete(Guid id)
	{
		var result = await Facade.DeleteAsync(id);

		if (result.IsSuccess)
		{
			return NoContent();
		}

		// Spracovanie chyby
		return result.ErrorType switch
		{
			ErrorType.NotFound => NotFound(result.ErrorMessage), // 404
			ErrorType.Forbidden => Forbid(), // 403
			ErrorType.Conflict => Conflict(result.ErrorMessage), // 409
			_ => StatusCode(StatusCodes.Status500InternalServerError,
				new { Error = "Internal error during deletion.", Details = result.ErrorMessage })
		};
	}
}