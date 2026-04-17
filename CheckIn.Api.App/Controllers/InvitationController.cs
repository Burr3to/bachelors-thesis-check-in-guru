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

[Authorize(AuthenticationSchemes = "Bearer")]
[ApiController]
[Route("api/[controller]")]
public class InvitationController(IInvitationFacade facade)
    : ApiControllerBase<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>(facade)
{
    private readonly IInvitationFacade _invitationFacade = facade;

    [HttpPost("parse")]
    public async Task<ActionResult<List<string>>> Parse([FromBody] string rawText)
    {
        // Nezabudni pridať 'await' a volať novú metódu
        var result = await _invitationFacade.ParseEmailsAsync(rawText);
        return Ok(result);
    }

    [HttpPost("send/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendInvitations(Guid taskId, [FromBody] List<string>? emails = null)
    {
        // Ak 'emails' je null, facade pošle len tým, čo majú IsSent = false
        // Ak 'emails' obsahuje zoznam, prepošle to konkrétnym ľuďom (napr. vybraným čipom)
        var result = await _invitationFacade.SendInvitationsForTaskAsync(taskId, emails);
        return Ok(result);
    }

    [HttpPost("remind-pending/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendReminders(Guid taskId)
    {
        // Toto je pre scenár: Poslať všetkým, čo ešte neakceptovali (IsAccepted = false)
        // Implementácia vo Facade by bola podobná, len filter by bol na IsAccepted
        var result = await _invitationFacade.SendRemindersForTaskAsync(taskId);
        return Ok(result);
    }

    [HttpPost("test-send")]
    public async Task<IActionResult> TestSend([FromBody] string targetEmail)
    {
        try
        {
            // Voláme priamo emailovú službu
            _invitationFacade.StartEmailSendingBackground(
                new List<string> { targetEmail },
                "testovaci-hash-123",
                "Jakub (Test)",
                "Cervene paradajky",
                "Toto je testovací email s popisom úlohy. Neodpovedaj naň.",
                Guid.Empty,
                Guid.Empty
            );
            return Ok("Pokus o odoslanie bol spustený. Skontroluj konzolu a svoj mail.");
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }
}