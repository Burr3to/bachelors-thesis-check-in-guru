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
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
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
        string taskDescription,
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
                await scopedEmailService.SendBulkEmailsAsync(emails, taskHash, authorName, taskTitle, taskDescription);

                await hubContext.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_SENT");
            }
            catch (Exception)
            {
                await hubContext.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_FAILED");
            }
        });
    }


    public async Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId)
    {
        Console.WriteLine($"---> FACADE START: TaskId={taskId}");

        try
        {
            var currentUserId = CurrentUserId;
            Console.WriteLine($"---> CURRENT USER ID: {currentUserId}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"---> ERROR GETTING USER ID: {ex.Message}");
        }

        var task = await dbContext.Tasks
            .Include(t => t.Invitations)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            Console.WriteLine("---> TASK NOT FOUND IN DB");
            return Result<bool>.NotFound("Úloha nebola nájdená.");
        }

        Console.WriteLine($"---> TASK OWNER ID: {task.CreatedById}");

        if (task.CreatedById != CurrentUserId)
            return Result<bool>.Forbidden("Nemáte oprávnenie odosielať pozvánky pre túto úlohu.");

        var emails = task.Invitations.Select(i => i.Email).ToList();

        if (!emails.Any())
            return Result<bool>.ValidationFailure("Zoznam pozvánok je prázdny.");

        // 4. Získanie mena autora pre email
        var author = await dbContext.Users.FindAsync(CurrentUserId);
        var authorName = author?.Name ?? "Váš kolega";

        // 5. Spustenie existujúcej background úlohy
        StartEmailSendingBackground(
            emails,
            task.Hash,
            authorName,
            task.Title,
            task.Notes,
            task.CreatedById
        );

        return Result<bool>.Success(true);
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