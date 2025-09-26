using System.Linq.Expressions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

public abstract class ControllerBase<TEntity, TListModel, TDetailModel>(IFacade<TEntity, TListModel, TDetailModel> facade)
	: ControllerBase where TDetailModel : IEntityModel
{
	// Abstraktné metódy, ktoré MUSÍ implementovať každá konkrétna Controller trieda
	protected abstract Expression<Func<TEntity, bool>> CreateFilter(string? strFilterAtrib, string? strFilter);
	protected abstract Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> CreateOrderBy(string? strSortBy, bool sortDesc);

	// GET: api/ControllerName
	// Implementuje Paging a Filtering pre zoznam
	[HttpGet]
	public virtual async Task<ActionResult<IEnumerable<TListModel>>> GetList(
		[FromQuery] string? strFilterAtrib,
		[FromQuery] string? strFilter,
		[FromQuery] string? strSortBy,
		[FromQuery] bool sortDesc = false,
		[FromQuery] int pageNumber = 1,
		[FromQuery] int pageSize = 10)
	{
		var filter = CreateFilter(strFilterAtrib, strFilter);
		var orderBy = CreateOrderBy(strSortBy, sortDesc);

		var result = await facade.GetAsync(filter, orderBy, pageNumber, pageSize);
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
	public virtual async Task<IActionResult> Put(Guid id, [FromBody] TDetailModel model)
	{
		if (id != model.Id)
		{
			return BadRequest("ID mismatch.");
		}

		await facade.SaveAsync(model);

		return NoContent(); // Vrátenie 204 No Content (Úspešne, ale bez tela)
	}

	// POST: api/ControllerName (Vytvorenie)
	[HttpPost]
	public virtual async Task<ActionResult<TDetailModel>> Post([FromBody] TDetailModel model)
	{
		// Vytvorenie nového ID na strane servera
		model.Id = Guid.Empty;
		var result = await facade.SaveAsync(model);

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