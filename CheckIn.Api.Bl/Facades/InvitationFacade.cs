using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Enums;
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
        string taskTitle, string taskDescription, Guid authorId, Guid taskId, bool isReminder = false)
    {
        _ = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<CheckInDbContext>();
            var mailer = scope.ServiceProvider.GetRequiredService<IEmailService>();
            var taskHub = scope.ServiceProvider.GetRequiredService<IHubContext<TaskHub>>();

            try
            {
                await mailer.SendBulkEmailsAsync(emails, taskHash, authorName, taskTitle, taskDescription, isReminder);

                // UPDATE DB: Označíme pozvánky za odoslané
                var invitations = await db.Invitations
                    .Where(i => i.TaskId == taskId && emails.Contains(i.Email))
                    .ToListAsync();

                foreach (var inv in invitations)
                {
                    inv.IsSent = true;
                    inv.SentAt = DateTime.UtcNow;
                }

                await SyncAlreadyCompletedInvitationsAsync(db, taskId, emails);

                await db.SaveChangesAsync();

                // Notifikujeme autora cez SignalR, nech si refreshne UI
                var userGroupName = $"User_{authorId.ToString().ToLower()}";
                await taskHub.Clients.Group(userGroupName).SendAsync("ReceiveNotification", "EMAILS_SENT");
                await taskHub.Clients.Group(taskId.ToString().ToLower()).SendAsync("TaskInvitationsChanged");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EMAIL BACKGROUND ERROR]: Nastala chyba pri odosielaní emailov: {ex.Message}");
                var userGroupName = $"User_{authorId.ToString().ToLower()}";
                await taskHub.Clients.Group(userGroupName).SendAsync("ReceiveNotification", "EMAILS_FAILED");
            }
        });
    }

    private async Task SyncAlreadyCompletedInvitationsAsync(CheckInDbContext db, Guid taskId, List<string> emails)
    {
        // 0. Zistíme režim úlohy (Shared vs Individual)
        var task = await db.Tasks
            .Select(t => new { t.Id, t.SubtaskMode })
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return;

        foreach (var email in emails)
        {
            var normalizedEmail = email.ToLower().Trim();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == normalizedEmail);
            Guid? userId = user?.Id;

            // Základný query pre inštancie patriace k tomuto tasku
            var instancesQuery = db.SubtaskInstances
                .Where(i => i.TemplateSubtask.ParentTaskId == taskId);

            if (task.SubtaskMode == SubtaskMode.Shared)
            {
                // --- REŽIM: SHARED ---
                // Tu chceme označiť pozvánku za vybavenú IBA ak existuje záznam, 
                // ktorý je jasne podpísaný týmto konkrétnym človekom.
                // Ak je AssignedToUserId null, znamená to, že to môže splniť ktokoľvek, 
                // ale my tu hľadáme dôkaz, že to splnil PRÁVE tento email.
                var specificallyDoneByMe = await instancesQuery.AnyAsync(i =>
                    ((userId != null && i.AssignedToUserId == userId) ||
                     (i.RespondentName != null && i.RespondentName.ToLower() == normalizedEmail))
                    && i.IsCompleted);

                if (specificallyDoneByMe)
                {
                    var invitation = await db.Invitations
                        .FirstOrDefaultAsync(i => i.TaskId == taskId && i.Email.ToLower() == normalizedEmail);

                    if (invitation != null)
                    {
                        invitation.IsAccepted = true;
                        invitation.IsCompleted = true;
                    }
                }
            }
            else
            {
                var hasPendingWork = await instancesQuery.AnyAsync(i =>
                    ((userId != null && i.AssignedToUserId == userId) ||
                     (i.RespondentName != null && i.RespondentName.ToLower() == normalizedEmail))
                    && !i.IsCompleted);

                var hasAnyCompleted = await instancesQuery.AnyAsync(i =>
                    ((userId != null && i.AssignedToUserId == userId) ||
                     (i.RespondentName != null && i.RespondentName.ToLower() == normalizedEmail))
                    && i.IsCompleted);

                if (!hasPendingWork && hasAnyCompleted)
                {
                    var invitation = await db.Invitations
                        .FirstOrDefaultAsync(i => i.TaskId == taskId && i.Email.ToLower() == normalizedEmail);

                    if (invitation != null)
                    {
                        invitation.IsAccepted = true;
                        invitation.IsCompleted = true;
                    }
                }
            }
        }
    }


    public async Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId, List<string>? specificEmails = null)
    {
        var task = await GetTaskWithValidation(taskId);
        if (task == null) return Result<bool>.NotFound();

        IQueryable<InvitationEntity> query = dbContext.Invitations.Where(i => i.TaskId == taskId);

        if (specificEmails != null && specificEmails.Any())
            query = query.Where(i => specificEmails.Contains(i.Email));
        else
            query = query.Where(i => !i.IsSent); // Len noví

        var listToSend = await query.ToListAsync();
        if (!listToSend.Any()) return Result<bool>.Success(true);

        return await ExecuteEmailSending(task, listToSend, isReminder: false);
    }

    public async Task<Result<bool>> SendRemindersForTaskAsync(Guid taskId)
    {
        var task = await GetTaskWithValidation(taskId);
        if (task == null) return Result<bool>.NotFound();

        // 1. Získame všetkých, čo ešte nemajú hotovo
        var pendingInvitations = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && i.IsSent && !i.IsCompleted)
            .ToListAsync();

        if (!pendingInvitations.Any())
        {
            Console.WriteLine($"[REMINDER] Žiadne neukončené pozvánky pre task {taskId}");
            return Result<bool>.Success(true);
        }

        // 2. Synchronizácia (pre istotu)
        var emails = pendingInvitations.Select(x => x.Email).ToList();
        await SyncAlreadyCompletedInvitationsAsync(dbContext, taskId, emails);
        await dbContext.SaveChangesAsync();

        // 3. Finálny výber - ak chceš poslať pripomienku aj tým, čo ešte mail nedostali, 
        // vymaž podmienku && i.IsSent
        var finalRemindList = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && !i.IsCompleted)
            .ToListAsync();

        if (!finalRemindList.Any())
        {
            Console.WriteLine($"[REMINDER] Po synchronizácii už nikto nepotrebuje pripomienku.");
            return Result<bool>.Success(true);
        }

        Console.WriteLine($"[REMINDER] Odosielam {finalRemindList.Count} pripomienok pre task {taskId}");
        return await ExecuteEmailSending(task, finalRemindList, isReminder: true);
    }

    private async Task<TaskEntity?> GetTaskWithValidation(Guid taskId)
    {
        var task = await dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == taskId);
        if (task != null && task.CreatedById == CurrentUserId) return task;
        return null;
    }

    public async Task<List<string>> ParseEmailsAsync(string rawText)
    {
        var allParsedEmails = emailService.ParseEmails(rawText).Distinct().ToList();
        var validEmails = new List<string>();
        var invalidEmails = new List<string>();

        foreach (var email in allParsedEmails)
        {
            if (!await emailService.IsEmailDomainValidAsync(email))
            {
                invalidEmails.Add(email);
                continue;
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

    public async Task<bool> ValidateDomainAsync(string domain)
    {
        return await emailService.IsDomainValidAsync(domain);
    }


    private async Task<Result<bool>> ExecuteEmailSending(TaskEntity task, List<InvitationEntity> invitations,
        bool isReminder)
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
            task.Id,
            isReminder // Predáme flag
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