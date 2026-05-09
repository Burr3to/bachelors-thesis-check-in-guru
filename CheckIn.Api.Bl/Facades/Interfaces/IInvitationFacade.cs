using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results; // Tu máš modely (List, Detail, Create, Update, Query)
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IInvitationFacade :
    IFacade<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>
{
    List<string> ParseEmails(string rawText);

    void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName, string taskTitle
        , string taskDescription, Guid authorId, Guid taskId, bool isReminder = false);

    Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId, List<string>? specificEmails = null);
    Task<Result<bool>> SendRemindersForTaskAsync(Guid taskId);
    Task<List<string>> ParseEmailsAsync(string rawText);
    Task<bool> ValidateDomainAsync(string domain);
}