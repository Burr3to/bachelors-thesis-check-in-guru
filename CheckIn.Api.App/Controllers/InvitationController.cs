using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InvitationController(IInvitationFacade facade)
    : ApiControllerBase<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>(facade)
{
    private readonly IInvitationFacade _invitationFacade = facade;

    [HttpPost("parse")]
    public ActionResult<List<string>> Parse([FromBody] string rawText)
    {
        var result = _invitationFacade.ParseEmails(rawText);
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