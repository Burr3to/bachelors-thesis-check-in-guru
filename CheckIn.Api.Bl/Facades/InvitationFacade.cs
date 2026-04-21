using AutoMapper;
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
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace CheckIn.Api.Bl.Facades;

public class InvitationFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IEmailService emailService,
    IHubContext<TaskHub> hubContext,
    IServiceScopeFactory scopeFactory
) : FacadeBase<InvitationEntity, InvitationListModel, InvitationDetailModel,
        InvitationCreateModel, InvitationUpdateModel, InvitationQueryModel>(dbContext, mapper, userContext),
    IInvitationFacade
{
    public List<string> ParseEmails(string rawText)
    {
        return emailService.ParseEmails(rawText);
    }

    public void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName,
        string taskTitle, string taskDescription, Guid authorId, Guid taskId)
    {
        _ = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<CheckInDbContext>();
            var mailer = scope.ServiceProvider.GetRequiredService<IEmailService>();
            var hub = scope.ServiceProvider.GetRequiredService<IHubContext<NotificationHub>>();
            var taskHub = scope.ServiceProvider.GetRequiredService<IHubContext<TaskHub>>();

            try
            {
                await mailer.SendBulkEmailsAsync(emails, taskHash, authorName, taskTitle, taskDescription);

                // UPDATE DB: Označíme pozvánky za odoslané
                var invitations = await db.Invitations
                    .Where(i => i.TaskId == taskId && emails.Contains(i.Email))
                    .ToListAsync();

                foreach (var inv in invitations)
                {
                    inv.IsSent = true;
                    inv.SentAt = DateTime.UtcNow;
                }

                await db.SaveChangesAsync();

                // Notifikujeme autora cez SignalR, nech si refreshne UI
                await hub.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_SENT");
                await taskHub.Clients.Group(taskId.ToString()).SendAsync("TaskInvitationsChanged");
            }
            catch (Exception)
            {
                await hub.Clients.User(authorId.ToString()).SendAsync("ReceiveNotification", "EMAILS_FAILED");
            }
        });
    }


    public async Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId, List<string>? specificEmails = null)
    {
        var task = await dbContext.Tasks
            .Include(t => t.Invitations)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return Result<bool>.NotFound();
        if (task.CreatedById != CurrentUserId) return Result<bool>.Forbidden();

        // Filtrujeme pozvánky na spracovanie
        IQueryable<InvitationEntity> query = dbContext.Invitations.Where(i => i.TaskId == taskId);

        if (specificEmails != null && specificEmails.Any())
        {
            // A. Posielame len konkrétnym (napr. manuálne preposlanie)
            query = query.Where(i => specificEmails.Contains(i.Email));
        }
        else
        {
            // B. Predvolené správanie (Tlačidlo "Send to All New"): Posielame len tým, čo ešte nedostali nič
            query = query.Where(i => !i.IsSent);
        }

        var listToSend = await query.ToListAsync();
        if (!listToSend.Any()) return Result<bool>.Success(true);

        return await ExecuteEmailSending(task, listToSend);
    }

    public async Task<Result<bool>> SendRemindersForTaskAsync(Guid taskId)
    {
        var task = await dbContext.Tasks
            .Include(t => t.Invitations)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return Result<bool>.NotFound();
        if (task.CreatedById != CurrentUserId) return Result<bool>.Forbidden();

        // C. Pripomienky: Posielame len tým, čo ešte NEAKCEPTOVALI (nehľadiac na to, či už mail dostali)
        var listToSend = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && !i.IsAccepted)
            .ToListAsync();

        if (!listToSend.Any()) return Result<bool>.Success(true);

        return await ExecuteEmailSending(task, listToSend);
    }

    public async Task<List<string>> ParseEmailsAsync(string rawText)
    {
        var allParsedEmails = emailService.ParseEmails(rawText).Distinct().ToList();

        var validEmails = new List<string>();
        var invalidEmails = new List<string>();

        foreach (var email in allParsedEmails)
        {
            // 1. DÔLEŽITÉ: Ak doména nie je validná, pridáme do invalid a POKRAČUJEME (continue)
            if (!await emailService.IsDomainValidAsync(email))
            {
                invalidEmails.Add(email);
                continue; // Tento mail sa nesmie dostať do validEmails!
            }

            validEmails.Add(email);
        }

        if (invalidEmails.Any())
        {
            var userId = CurrentUserId.ToString().ToLower();
            var groupName = $"User_{userId}";

            // Posielame cez TaskHub
            await hubContext.Clients.Group(groupName)
                .SendAsync("InvalidEmailsFound", invalidEmails);

            Console.WriteLine(
                $"[SIGNALR] Odoslané InvalidEmailsFound do {groupName}: {string.Join(", ", invalidEmails)}");
        }

        return validEmails; // Tu už budú len tie skutočne dobré
    }


    private async Task<Result<bool>> ExecuteEmailSending(TaskEntity task, List<InvitationEntity> invitations)
    {
        var emails = invitations.Select(i => i.Email).ToList();
        var author = await dbContext.Users.FindAsync(CurrentUserId);
        var authorName = author?.Name ?? "Váš kolega";

        StartEmailSendingBackground(
            emails,
            task.Hash,
            authorName,
            task.Title,
            task.Notes,
            task.CreatedById,
            task.Id
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