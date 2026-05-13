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

/// <summary>
/// Handles the logic for creating, sending, and synchronizing task invitations.
/// </summary>
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
    /// <summary>
    /// Extracts email addresses from a raw text input using the email service.
    /// </summary>
    public List<string> ParseEmails(string rawText)
    {
        return emailService.ParseEmails(rawText);
    }

    /// <summary>
    /// Runs a fire-and-forget task to send bulk emails and update invitation statuses in the database.
    /// </summary>
    public void StartEmailSendingBackground(List<string> emails, string taskHash, string authorName,
        string taskTitle, string taskDescription, Guid authorId, Guid taskId, bool isReminder = false)
    {
        _ = Task.Run(async () =>
        {
            // Create a new scope for background database operations
            using var scope = scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<CheckInDbContext>();
            var mailer = scope.ServiceProvider.GetRequiredService<IEmailService>();
            var taskHub = scope.ServiceProvider.GetRequiredService<IHubContext<TaskHub>>();

            try
            {
                // Dispatch the emails via the mail service
                await mailer.SendBulkEmailsAsync(emails, taskHash, authorName, taskTitle, taskDescription, isReminder);

                // Mark invitations as sent in the database
                var invitations = await db.Invitations
                    .Where(i => i.TaskId == taskId && emails.Contains(i.Email))
                    .ToListAsync();

                foreach (var inv in invitations)
                {
                    inv.IsSent = true;
                    inv.SentAt = DateTime.UtcNow;
                }

                // Synchronize statuses in case the user has already performed actions
                await SyncAlreadyCompletedInvitationsAsync(db, taskId, emails);
                await db.SaveChangesAsync();

                // Notify the UI via SignalR that invitations have been updated
                var userGroupName = $"User_{authorId.ToString().ToLower()}";
                await taskHub.Clients.Group(userGroupName).SendAsync("ReceiveNotification", "EMAILS_SENT");
                await taskHub.Clients.Group(taskId.ToString().ToLower()).SendAsync("TaskInvitationsChanged");
            }
            catch (Exception)
            {
                // Handle background failures by notifying the author
                var userGroupName = $"User_{authorId.ToString().ToLower()}";
                await taskHub.Clients.Group(userGroupName).SendAsync("ReceiveNotification", "EMAILS_FAILED");
            }
        });
    }

    /// <summary>
    /// Recalculates if invitations should be marked as "Accepted" or "Completed" 
    /// based on existing subtask progress and the task's logic mode.
    /// </summary>
    private async Task SyncAlreadyCompletedInvitationsAsync(CheckInDbContext db, Guid taskId, List<string> emails)
    {
        var task = await db.Tasks
            .Select(t => new { t.Id, t.SubtaskMode })
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return;

        foreach (var email in emails)
        {
            var normalizedEmail = email.ToLower().Trim();
            var invitation = await db.Invitations
                .FirstOrDefaultAsync(i => i.TaskId == taskId && i.Email.ToLower() == normalizedEmail);

            if (invitation == null) continue;

            if (task.SubtaskMode == SubtaskMode.Shared)
            {
                // Logic for Shared Mode:
                // An invitation is completed if the user has contributed to at least one subtask.
                var userHasContributed = await db.SubtaskInstances
                    .AnyAsync(si => si.TemplateSubtask.ParentTaskId == taskId
                                    && si.IsCompleted
                                    && si.CompletedByUserId != null
                                    && db.Users.Any(u =>
                                        u.Id == si.CompletedByUserId && u.Email.ToLower() == normalizedEmail));

                invitation.IsCompleted = userHasContributed;
                if (userHasContributed) invitation.IsAccepted = true;
            }
            else
            {
                // Logic for Individual Mode:
                // An invitation is completed only if ALL subtasks assigned to this email are finished.
                var userInstances = db.SubtaskInstances
                    .Where(si => si.TemplateSubtask.ParentTaskId == taskId
                                 && si.AssignedToEmail.ToLower() == normalizedEmail);

                var hasPendingWork = await userInstances.AnyAsync(si => !si.IsCompleted);
                var hasAnyCompleted = await userInstances.AnyAsync(si => si.IsCompleted);

                invitation.IsCompleted = !hasPendingWork && hasAnyCompleted;
                if (hasAnyCompleted) invitation.IsAccepted = true;
            }
        }
    }

    /// <summary>
    /// Prepares a list of emails to receive a task invitation and starts the sending process.
    /// </summary>
    public async Task<Result<bool>> SendInvitationsForTaskAsync(Guid taskId, List<string>? specificEmails = null)
    {
        var task = await GetTaskWithValidation(taskId);
        if (task == null) return Result<bool>.NotFound();

        IQueryable<InvitationEntity> query = dbContext.Invitations.Where(i => i.TaskId == taskId);

        // Filter by specific emails if provided, otherwise send to all unsent
        if (specificEmails != null && specificEmails.Any())
            query = query.Where(i => specificEmails.Contains(i.Email));
        else
            query = query.Where(i => !i.IsSent);

        var listToSend = await query.ToListAsync();
        if (!listToSend.Any()) return Result<bool>.Success(true);

        return await ExecuteEmailSending(task, listToSend, isReminder: false);
    }

    /// <summary>
    /// Identifies users who haven't completed their tasks and triggers a reminder email.
    /// </summary>
    public async Task<Result<bool>> SendRemindersForTaskAsync(Guid taskId)
    {
        var task = await GetTaskWithValidation(taskId);
        if (task == null) return Result<bool>.NotFound();

        // Find invitations that were sent but are not yet completed
        var pendingInvitations = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && i.IsSent && !i.IsCompleted)
            .ToListAsync();

        if (!pendingInvitations.Any()) return Result<bool>.Success(true);

        // Sync statuses one last time before sending reminders
        var emails = pendingInvitations.Select(x => x.Email).ToList();
        await SyncAlreadyCompletedInvitationsAsync(dbContext, taskId, emails);
        await dbContext.SaveChangesAsync();

        // Final list of recipients who still have work to do
        var finalRemindList = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && !i.IsCompleted)
            .ToListAsync();

        if (!finalRemindList.Any()) return Result<bool>.Success(true);

        return await ExecuteEmailSending(task, finalRemindList, isReminder: true);
    }

    /// <summary>
    /// Validates task existence and checks if the current user is the author.
    /// </summary>
    private async Task<TaskEntity?> GetTaskWithValidation(Guid taskId)
    {
        var task = await dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == taskId);
        if (task != null && task.CreatedById == CurrentUserId) return task;
        return null;
    }

    /// <summary>
    /// Parses emails and validates their domains. Notifies the frontend via SignalR if invalid domains are found.
    /// </summary>
    public async Task<List<string>> ParseEmailsAsync(string rawText)
    {
        var allParsedEmails = emailService.ParseEmails(rawText).Distinct().ToList();
        var validEmails = new List<string>();
        var invalidEmails = new List<string>();

        // Domain validation loop
        foreach (var email in allParsedEmails)
        {
            if (!await emailService.IsEmailDomainValidAsync(email))
            {
                invalidEmails.Add(email);
                continue;
            }

            validEmails.Add(email);
        }

        // Notify user about rejected emails
        if (invalidEmails.Any())
        {
            var userId = CurrentUserId.ToString().ToLower();
            var groupName = $"User_{userId}";
            await hubContext.Clients.Group(groupName).SendAsync("InvalidEmailsFound", invalidEmails);
        }

        return validEmails;
    }

    /// <summary>
    /// Checks if a given domain is valid for task invitations.
    /// </summary>
    public async Task<bool> ValidateDomainAsync(string domain)
    {
        return await emailService.IsDomainValidAsync(domain);
    }

    /// <summary>
    /// Gathers metadata and initiates the background email dispatch.
    /// </summary>
    private async Task<Result<bool>> ExecuteEmailSending(TaskEntity task, List<InvitationEntity> invitations,
        bool isReminder)
    {
        var emails = invitations.Select(i => i.Email).ToList();
        var author = await dbContext.Users.FindAsync(CurrentUserId);
        var authorName = author?.Name ?? "A colleague";

        StartEmailSendingBackground(
            emails,
            task.Hash,
            authorName,
            task.Title,
            task.Notes,
            task.CreatedById,
            task.Id,
            isReminder
        );

        return Result<bool>.Success(true);
    }

    /// <summary>
    /// Configures the default sorting for invitation queries.
    /// </summary>
    protected override Func<IQueryable<InvitationEntity>, IOrderedQueryable<InvitationEntity>> CreateOrderBy(
        InvitationQueryModel query)
    {
        return q => q.OrderByDescending(i => i.SentAt);
    }

    /// <summary>
    /// Adds task-specific filtering to invitation queries.
    /// </summary>
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