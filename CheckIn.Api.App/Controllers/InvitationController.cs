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

/// <summary>
/// Controller for managing task invitations and email communication.
/// </summary>
[Authorize(AuthenticationSchemes = "Bearer")]
[ApiController]
[Route("api/[controller]")]
public class InvitationController(IInvitationFacade facade)
    : ApiControllerBase<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>(facade)
{
    private readonly IInvitationFacade _invitationFacade = facade;

    /// <summary>
    /// Extracts email addresses from a raw string of text.
    /// </summary>
    [HttpPost("parse")]
    public async Task<ActionResult<List<string>>> Parse([FromBody] string rawText)
    {
        var result = await _invitationFacade.ParseEmailsAsync(rawText);
        return Ok(result);
    }

    /// <summary>
    /// Sends invitations for a specific task.
    /// If no emails are provided, it sends invitations to all pending invitees.
    /// </summary>
    [HttpPost("send/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendInvitations(Guid taskId, [FromBody] List<string>? emails = null)
    {
        // If emails list is null, the facade handles sending to those with IsSent = false.
        // If provided, it targets specific recipients.
        var result = await _invitationFacade.SendInvitationsForTaskAsync(taskId, emails);
        return Ok(result);
    }

    /// <summary>
    /// Validates if a specific domain is allowed within the system.
    /// </summary>
    [HttpGet("validate-domain")]
    public async Task<ActionResult<bool>> ValidateDomain([FromQuery] string domain)
    {
        var isValid = await _invitationFacade.ValidateDomainAsync(domain);
        return Ok(isValid);
    }

    /// <summary>
    /// Sends reminder emails to users who have not yet completed their subtasks.
    /// </summary>
    [HttpPost("remind-unfinished/{taskId}")]
    public async Task<ActionResult<Result<bool>>> SendReminders(Guid taskId)
    {
        var result = await _invitationFacade.SendRemindersForTaskAsync(taskId);
        return Ok(result);
    }
}