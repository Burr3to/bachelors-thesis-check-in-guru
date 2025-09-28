using System.Linq.Expressions;
using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public class CheckInEventController(ICheckInEventFacade facade)
	: ControllerBase<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel>(facade)
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
	protected override Expression<Func<CheckInEventEntity, bool>> CreateFilter(string? strFilterAtrib,
		string? strFilter)
	{
		var currentOwnerID = GetCurrentOwnerId();
		Expression<Func<CheckInEventEntity, bool>> filter = l => l.OwnerId == currentOwnerID;

		return filter;
	}

	protected override Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> CreateOrderBy(
		string? strSortBy, bool sortDesc)
	{
		// Triedenie zostáva rovnaké (napr. podľa dátumu vytvorenia)
		Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> orderBy = l =>
			l.OrderByDescending(s => s.CreatedAt);

		if (strSortBy == nameof(CheckInEventEntity.Title))
		{
			orderBy = sortDesc
				? l => l.OrderByDescending(s => s.Title)
				: l => l.OrderBy(s => s.Title);
		}

		return orderBy;
	}

	[HttpPost]
	public override async Task<ActionResult<CheckInEventDetailModel>> Post([FromBody] CheckInEventDetailModel model)
	{
		// Nastavenie ID vlastníka na testovacie ID.
		model.OwnerId = GetCurrentOwnerId();

		return await base.Post(model);
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