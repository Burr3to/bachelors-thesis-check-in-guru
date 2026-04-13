using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update; // Tu máš modely (List, Detail, Create, Update, Query)
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IInvitationFacade :
    IFacade<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>
{
    List<string> ParseEmails(string rawText);

    void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName, string taskTitle
        , string taskDescription, Guid authorId);
}