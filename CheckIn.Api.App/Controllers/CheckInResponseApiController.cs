using System.Linq.Expressions;
using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Utils.Expressions;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
// 1. Pridaný štvrtý generický parameter: CheckInResponseListQuery
public class CheckInResponseApiController(ICheckInResponseFacade responseFacade)
	: ApiControllerBase<CheckInResponseEntity, CheckInResponseListModel, CheckInResponseDetailModel,
		CheckInResponseCreateModel, CheckInResponseUpdateModel, CheckInResponseListQuery>(responseFacade)
{
	private readonly ICheckInResponseFacade _responseFacade = responseFacade;

	protected override Expression<Func<CheckInResponseEntity, bool>> CreateFilter(CheckInResponseListQuery query)
	{
		// V testovacom režime začíname s TRUE filtrom. 
		// Ak by bol Controller pod [Authorize], pridali by sme filter pre OwnerId tu!
		Expression<Func<CheckInResponseEntity, bool>> filter = l => true;

		// Filter podľa ID eventu (najčastejšie použitie pre tento zoznam)
		if (query.CheckInEventId.HasValue && query.CheckInEventId.Value != Guid.Empty)
		{
			// Filtrujeme, aby sme videli len odpovede patriace k danému eventu
			filter = filter.And(l => l.CheckInEvent.Id == query.CheckInEventId.Value);
		}

		// Ak ste v ListQuery nechali filtre NameContains, Status atď., môžete ich tu pridať
		if (!string.IsNullOrEmpty(query.NameContains))
		{
			// Príklad: hľadanie v mene respondenta (ak to entita má)
			// filter = filter.And(l => l.RespondentName.Contains(query.NameContains)); 
		}

		return filter;
	}

	// Triedenie: Teraz prijíma Query Object
	protected override Func<IQueryable<CheckInResponseEntity>, IOrderedQueryable<CheckInResponseEntity>> CreateOrderBy(
		CheckInResponseListQuery query)
	{
		// Základné triedenie odpovedí podľa času odoslania (SubmittedAt)
		Func<IQueryable<CheckInResponseEntity>, IOrderedQueryable<CheckInResponseEntity>> orderBy = l =>
			l.OrderByDescending(s => s.SubmittedAt);

		// Ak klient poslal požiadavku na iné triedenie (použijeme query.SortBy)
		if (query.SortBy == "Id") // Príklad: triedenie podľa ID
		{
			orderBy = query.SortDesc
				? l => l.OrderByDescending(s => s.Id)
				: l => l.OrderBy(s => s.Id);
		}

		// Môžete pridať ďalšie stĺpce triedenia...

		return orderBy;
	}


}