using System.Linq.Expressions;
using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Utils.Expressions;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public class CheckInEventApiController(ICheckInEventFacade facade)
	: ApiControllerBase<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel, CheckInEventCreateModel,
			CheckInEventUpdateModel, ListQuery>
		(facade)
{
	// Pomocná metóda na získanie OwnerId z kontextu používateľa
	private Guid GetCurrentOwnerId()
	{
		var ownerIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(ownerIdString, out var ownerId))
			throw new UnauthorizedAccessException("Owner ID claim is missing or invalid.");
		return ownerId;
	}

	// IMPLEMENTÁCIA ABSTRAKTNÝCH METÓD
	protected override Expression<Func<CheckInEventEntity, bool>> CreateFilter(ListQuery query)
	{
		// 1. Získanie ID prihláseného používateľa
		var currentOwnerId = GetCurrentOwnerId();

		// 2. Základný a povinný filter (Row Level Security)
		Expression<Func<CheckInEventEntity, bool>> filter = l => l.OwnerId == currentOwnerId;

		// 3. Voliteľný filter: Ak klient poslal parameter NameContains
		if (!string.IsNullOrEmpty(query.NameContains))
		{
			filter = filter.And(l => l.Title.Contains(query.NameContains));
		}

		// 4. Voliteľný filter pre Status, ak by bol v ListQuery definovaný 
		// if (!string.IsNullOrEmpty(query.Status))
		// {
		//     filter = filter.And(l => l.Status == query.Status);
		// }

		// 5. Voliteľný filter pre Dátum, ak by bol v ListQuery definovaný 
		// if (query.CreatedAfter.HasValue)
		// {
		//     filter = filter.And(l => l.CreatedAt >= query.CreatedAfter.Value);
		// }

		return filter;
	}

	protected override Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> CreateOrderBy(
		ListQuery query)
	{
		Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> orderBy = l =>
			l.OrderByDescending(s => s.CreatedAt);

		// 2. Podmienené triedenie (prepisuje defaultné)
		if (query.SortBy == nameof(CheckInEventEntity.Title))
		{
			orderBy = query.SortDesc
				? l => l.OrderByDescending(s => s.Title)
				: l => l.OrderBy(s => s.Title);
		}

		return orderBy;
	}

	[HttpPost]
	public override async Task<ActionResult<CheckInEventDetailModel>> Post([FromBody] CheckInEventCreateModel model)
	{
		var ownerId = GetCurrentOwnerId();

		var result = await facade.SaveCreateModelAsync(model, ownerId);

		return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
	}

	[HttpGet("{id}")]
	[ProducesResponseType(typeof(CheckInEventDetailModel), StatusCodes.Status200OK)]
	[ProducesResponseType(StatusCodes.Status401Unauthorized)]
	[ProducesResponseType(StatusCodes.Status404NotFound)]
	public override async Task<ActionResult<CheckInEventDetailModel>> GetById(Guid id)
	{
		var currentOwnerId = GetCurrentOwnerId();
		var eventDetail = await facade.GetByIdAsync(id);

		if (eventDetail == null)
		{
			return NotFound("CheckInEvent not found.");
		}

		// Ak event nepatrí prihlásenému používateľovi
		if (eventDetail.OwnerId != currentOwnerId)
		{
			return NotFound("CheckInEvent not found..");
		}

		return Ok(eventDetail);
	}
}