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
// POZNÁMKA: [Authorize] je DOČASNE odstránené, aby sa povolilo testovanie
public class CheckInResponseController(ICheckInResponseFacade responseFacade) 
    : ControllerBase<CheckInResponseEntity, CheckInResponseListModel, CheckInResponseDetailModel>(responseFacade)
{
    private readonly ICheckInResponseFacade _responseFacade = responseFacade;
    
    // -----------------------------------------------------------------------
    // IMPLEMENTÁCIA ABSTRAKTNÝCH METÓD Z ControllerBase
    // -----------------------------------------------------------------------
    
    // Filtrovanie: V testovacom režime nefiltrujeme podľa vlastníka, ale iba podľa potreby
    protected override Expression<Func<CheckInResponseEntity, bool>> CreateFilter(string? strFilterAtrib, string? strFilter)
    {
        // POZNÁMKA: Tu by inak bola logika na získanie OwnerId z tokenu a filtrovanie.
        
        // V testovacom režime vrátime filter, ktorý vždy vráti TRUE (všetky odpovede)
        // Keď zapneš autorizáciu, musíš tu pridať filter podľa OwnerId (ako v CheckInEventController).
        return l => true; 
    }

    protected override Func<IQueryable<CheckInResponseEntity>, IOrderedQueryable<CheckInResponseEntity>> CreateOrderBy(string? strSortBy, bool sortDesc)
    {
        // Triedenie odpovedí podľa času odoslania
        Func<IQueryable<CheckInResponseEntity>, IOrderedQueryable<CheckInResponseEntity>> orderBy = l => l.OrderByDescending(s => s.SubmittedAt);
        
        return orderBy;
    }
    
    // -----------------------------------------------------------------------
    // VEREJNÝ ENDPOINT (PRE NEPRIHLÁSENÝCH RESPONDENTOV)
    // -----------------------------------------------------------------------

    // POST: api/CheckInResponse/submit/{eventHash}
    [HttpPost("submit/{eventHash}")]
    [AllowAnonymous] // Tento endpoint musí zostať vždy otvorený!
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SubmitResponse(string eventHash, [FromBody] CheckInResponseDetailModel responseModel)
    {
        // 1. Nastavenie ID udalosti a časovej známky
        responseModel.Id = Guid.Empty; // Vynulujeme ID
        responseModel.SubmittedAt = DateTime.UtcNow; 
        
        // 2. Volanie Fasády s Hashom
        var result = await _responseFacade.SaveResponseByHashAsync(eventHash, responseModel);

        if (result == null)
        {
            return NotFound("Check-in event not found or hash is invalid.");
        }
        
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
    
    // -----------------------------------------------------------------------
    // PREPÍSANIE BASE METÓD PRE ZABEZPEČENIE (DOČASNE MIMO TESTOVACEJ FÁZY)
    // -----------------------------------------------------------------------
    
    // Aby boli metódy GetList, GetById, Put a Delete dostupné, stačí, že sú verejné
    // a neobsahujú [Authorize].
    // Keď zapneš autorizáciu, automaticky sa zdedené metódy GetList, GetById, atď. 
    // stanú zabezpečenými, lebo nemajú [AllowAnonymous].
    
    // POZNÁMKA: Pre jednoduchosť testovania v Swaggeri NEPREPISUJ zdedené metódy, 
    // nechaj to na ControllerBase. Počas testovania uvidíš všetky odpovede.
}
