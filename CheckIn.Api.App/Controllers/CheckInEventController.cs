using System.Linq.Expressions;
using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
// [Authorize] // DOČASNE ZAKOMENTOVANÉ PRE JEDNODUCHÉ TESTOVANIE
public class CheckInEventController(ICheckInEventFacade facade)
	: ControllerBase<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel>(facade)
{
	// Toto je ID testovacieho používateľa, ktoré sa bude používať kým nezapneme Google Login.
	private readonly Guid TestOwnerId = Guid.Parse("00000000-0000-0000-0000-000000000001");

	// IMPLEMENTÁCIA ABSTRAKTNÝCH METÓD
	protected override Expression<Func<CheckInEventEntity, bool>> CreateFilter(string? strFilterAtrib, string? strFilter)
	{
		// V testovacom režime filtrujeme podľa napevno určeného ID.
		// Neskôr nahradíme TestOwnerId za dynamicky získané ID z tokenu.
		Expression<Func<CheckInEventEntity, bool>> filter = l => l.OwnerId == TestOwnerId;

		// ... Logika triedenia zostáva rovnaká ...
		// Pridáš tu dodatočné filtre (napr. vyhľadávanie podľa Title)

		return filter;
	}

	protected override Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> CreateOrderBy(string? strSortBy, bool sortDesc)
	{
		// Triedenie zostáva rovnaké (napr. podľa dátumu vytvorenia)
		Func<IQueryable<CheckInEventEntity>, IOrderedQueryable<CheckInEventEntity>> orderBy = l => l.OrderByDescending(s => s.CreatedAt);

		if (strSortBy == nameof(CheckInEventEntity.Title))
		{
			orderBy = sortDesc
				? l => l.OrderByDescending(s => s.Title)
				: l => l.OrderBy(s => s.Title);
		}

		return orderBy;
	}

	// PREPÍSANIE POST PRE NASTAVENIE VLASTNÍKA
	[HttpPost]
	public override async Task<ActionResult<CheckInEventDetailModel>> Post([FromBody] CheckInEventDetailModel model)
	{
		// Nastavenie ID vlastníka na testovacie ID.
		model.OwnerId = TestOwnerId;

		return await base.Post(model);
	}

	// POZNÁMKA: Akonáhle zapneš autentifikáciu, musíš odstrániť TestOwnerId a vrátiť sa k logike získavania ID z tokenu.
}