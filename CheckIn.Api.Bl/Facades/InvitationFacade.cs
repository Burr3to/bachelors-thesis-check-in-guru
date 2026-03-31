using AutoMapper;
using CheckIn.Api.Bl.Facades;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;

public class InvitationFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IEmailService emailService,
    IServiceScopeFactory scopeFactory
) : FacadeBase<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>(dbContext, mapper, userContext),
    IInvitationFacade
{
    public List<string> ParseEmails(string rawText)
    {
        return emailService.ParseEmails(rawText);
    }

    public void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName, string taskTitle,
        Guid authorId)
    {
        _ = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var scopedEmailService = scope.ServiceProvider.GetRequiredService<IEmailService>();
            // Musíš použiť IHubContext<NotificationHub>
            var hubContext = scope.ServiceProvider.GetRequiredService<IHubContext<NotificationHub>>();

            try
            {
                // Táto metóda musí byť v IEmailService
                await scopedEmailService.SendBulkEmailsAsync(emails, taskHash, authorName, taskTitle);

                await hubContext.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_SENT");
            }
            catch (Exception)
            {
                await hubContext.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_FAILED");
            }
        });
    }

    protected override Func<IQueryable<InvitationEntity>, IOrderedQueryable<InvitationEntity>> CreateOrderBy(
        InvitationQueryModel query)
    {
        return q => q.OrderByDescending(i => i.SentAt);
    }

    // Pridáme filter, aby sme vedeli zobraziť pozvánky pre konkrétny Task
    protected override System.Linq.Expressions.Expression<Func<InvitationEntity, bool>> CreateFilter(
        InvitationQueryModel query)
    {
        if (query.TaskId.HasValue)
        {
            return e => e.TaskId == query.TaskId.Value;
        }

        return base.CreateFilter(query);
    }
}