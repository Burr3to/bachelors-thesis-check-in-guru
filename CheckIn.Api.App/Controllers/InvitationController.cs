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

    [HttpGet("validate-domain")]
    public async Task<ActionResult<bool>> ValidateDomain([FromQuery] string domain)
    {
        var isValid = await _invitationFacade.ValidateDomainAsync(domain);
        return Ok(isValid);
    }

    [HttpPost("remind-unfinished/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendReminders(Guid taskId)
    {
        var result = await _invitationFacade.SendRemindersForTaskAsync(taskId);
        return Ok(result);
    }
}