using System.Linq.Expressions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Models.Query;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

public abstract class ApiControllerBase<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>(
	IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel> facade)
	: ControllerBase
	where TDetailModel : IEntityModel
	where TCreateModel : class
	where TUpdateModel : IEntityModel
	where TQueryModel : IPageableQuery, new()
{
	// Abstraktné metódy, ktoré MUSÍ implementovať každá konkrétna Controller trieda
	protected abstract Expression<Func<TEntity, bool>> CreateFilter(TQueryModel query);
	protected abstract Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> CreateOrderBy(TQueryModel query);

	// GET: api/ControllerName
	// Implementuje Paging a Filtering pre zoznam
	[HttpGet]
	public virtual async Task<ActionResult<IEnumerable<TListModel>>> GetList(
		[FromQuery] TQueryModel query)
	{
		var filter = CreateFilter(query);
		var orderBy = CreateOrderBy(query);

		var result = await facade.GetAsync(
			filter,
			orderBy,
			query.PageNumber,
			query.PageSize);

		return Ok(result.ToList());
	}

	// GET: api/ControllerName/5
	[HttpGet("{id}")]
	public virtual async Task<ActionResult<TDetailModel>> GetById(Guid id)
	{
		var entity = await facade.GetByIdAsync(id);
		if (entity == null)
		{
			return NotFound();
		}

		return Ok(entity);
	}

	// PUT: api/ControllerName/5
	[HttpPut("{id}")]
	public virtual async Task<IActionResult> Put(Guid id, [FromBody] TUpdateModel model)
	{
		if (id != model.Id)
		{
			return BadRequest("ID mismatch.");
		}

		await facade.SaveUpdateModelAsync(model);

		return NoContent(); // Vrátenie 204 No Content (Úspešne, ale bez tela)
	}

	// POST: api/ControllerName (Vytvorenie)
	[HttpPost]
	public virtual async Task<ActionResult<TDetailModel>> Post([FromBody] TCreateModel model)
	{
		var result = await facade.SaveCreateModelAsync(model);

		return CreatedAtAction(nameof(GetById), new { id = result.Id }, result); // Vrátenie 201 Created
	}

	// DELETE: api/ControllerName/5
	[HttpDelete("{id}")]
	public virtual async Task<IActionResult> Delete(Guid id)
	{
		var result = await facade.DeleteAsync(id);
		if (result)
		{
			return NoContent();
		}

		return NotFound();
	}
}