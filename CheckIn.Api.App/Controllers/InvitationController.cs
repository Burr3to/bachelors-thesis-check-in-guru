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
    public ActionResult<List<string>> Parse([FromBody] string rawText)
    {
        var result = _invitationFacade.ParseEmails(rawText);
        return Ok(result);
    }

    [HttpPost("send-pending/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendPendingInvitations(Guid taskId)
    {
        Console.WriteLine($"---> REQUEST RECEIVED: SendPendingInvitations pre TaskId: {taskId}");
        Console.WriteLine($"---> USER AUTHENTICATED: {User.Identity?.IsAuthenticated}");

        // Vypíšeme všetky claims, ktoré prišli v tokene
        foreach (var claim in User.Claims)
        {
            Console.WriteLine($"---> CLAIM: {claim.Type} = {claim.Value}");
        }


        var result = await _invitationFacade.SendInvitationsForTaskAsync(taskId);

        return result.ErrorType switch
        {
            ErrorType.None => Ok(result),
            ErrorType.NotFound => NotFound(result),
            ErrorType.Forbidden => Forbid(),
            ErrorType.Unauthorized => Unauthorized(result),
            _ => BadRequest(result)
        };
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