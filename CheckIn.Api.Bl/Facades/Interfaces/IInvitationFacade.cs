using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Interface for managing task invitations, email parsing, and background notification processes.
/// </summary>
public interface IInvitationFacade :
    IFacade<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>
{
    /// <summary>
    /// Synchronously parses a raw string for valid email addresses.
    /// </summary>
    List<string> ParseEmails(string rawText);

    /// <summary>
    /// Initiates a background process to send emails to invited users.
    /// </summary>
    void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName, string taskTitle
        , string taskDescription, Guid authorId, Guid taskId, bool isReminder = false);

    /// <summary>
    /// Identifies new invitations or specific emails and triggers the sending process.
    /// </summary>
    Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId, List<string>? specificEmails = null);

    /// <summary>
    /// Identifies pending (uncompleted) invitations and sends a reminder email.
    /// </summary>
    Task<Result<bool>> SendRemindersForTaskAsync(Guid taskId);

    /// <summary>
    /// Asynchronously parses emails and performs domain validation, notifying the user of any invalid entries.
    /// </summary>
    Task<List<string>> ParseEmailsAsync(string rawText);

    /// <summary>
    /// Validates if a specific domain is allowed by the system configuration.
    /// </summary>
    Task<bool> ValidateDomainAsync(string domain);
}