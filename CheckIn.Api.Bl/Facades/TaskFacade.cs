using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
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
using CheckIn.Api.Common.Statistics;
using CheckIn.Api.Common.Utils.Expressions;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

/// <summary>
/// Facade handling complex task logic, including invitations, subtask instance generation, 
/// and statistical aggregation.
/// </summary>
public class TaskFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IInvitationFacade invitationFacade,
    IHubContext<TaskHub> hubContext)
    : FacadeBase<TaskEntity, TaskListModel, TaskDetailModel, TaskCreateModel,
            TaskUpdateModel, TaskListQuery>
        (dbContext, mapper, userContext), ITaskFacade
{
    /// <summary>
    /// Builds a filter expression based on the provided query parameters for searching tasks.
    /// </summary>
    protected override Expression<Func<TaskEntity, bool>> CreateFilter(TaskListQuery query)
    {
        Expression<Func<TaskEntity, bool>> filter = entity => true;

        // Filter by title using case-insensitive ILike
        if (!string.IsNullOrEmpty(query.NameContains))
            filter = filter.And(entity => EF.Functions.ILike(entity.Title, $"%{query.NameContains}%"));

        // Filter by calculated task state (InProgress, Completed, Missed)
        if (query.Status.HasValue)
        {
            filter = query.Status.Value switch
            {
                TaskState.InProgress => filter.And(e =>
                    e.State == TaskState.InProgress && e.DeadLine >= DateTime.UtcNow),
                TaskState.Completed => filter.And(e => e.State == TaskState.Completed),
                TaskState.Missed => filter.And(e => e.State != TaskState.Completed && e.DeadLine < DateTime.UtcNow),
                _ => filter.And(e => e.State == query.Status.Value)
            };
        }

        // Search for tasks associated with a specific participant email
        if (!string.IsNullOrEmpty(query.RespondentEmail))
        {
            var email = query.RespondentEmail.Trim().ToLower();
            filter = filter.And(entity =>
                entity.Invitations.Any(i => i.Email.ToLower().Contains(email)) ||
                entity.Subtasks.Any(st => st.Instances.Any(inst =>
                    (inst.AssignedToEmail != null && inst.AssignedToEmail.ToLower().Contains(email)) ||
                    (inst.RespondentName != null && inst.RespondentName.ToLower().Contains(email))
                ))
            );
        }

        // Filtering by various date ranges and task modes
        if (query.DeadLineBefore.HasValue)
            filter = filter.And(entity => entity.DeadLine <= query.DeadLineBefore.Value);

        if (query.DeadLineAfter.HasValue)
            filter = filter.And(entity => entity.DeadLine >= query.DeadLineAfter.Value);

        if (query.CreatedAfter.HasValue)
            filter = filter.And(entity => entity.CreatedAt >= query.CreatedAfter.Value);

        if (query.Mode.HasValue)
            filter = filter.And(entity => entity.SubtaskMode == query.Mode.Value);

        if (query.RequiresAuth.HasValue)
            filter = filter.And(entity => entity.RequiresAuthenticationToComplete == query.RequiresAuth.Value);

        // Security: only show tasks created by the current user
        Guid currentUserId = CurrentUserId;
        filter = filter.And(entity => entity.CreatedById == currentUserId);

        return filter;
    }

    /// <summary>
    /// Configures the ordering for the task list query.
    /// </summary>
    protected override Func<IQueryable<TaskEntity>, IOrderedQueryable<TaskEntity>> CreateOrderBy(TaskListQuery query)
    {
        if (string.IsNullOrWhiteSpace(query.SortBy))
            return q => q.OrderBy(e => e.Id);

        return query.SortBy.ToLower() switch
        {
            "title" => query.SortDesc ? q => q.OrderByDescending(e => e.Title) : q => q.OrderBy(e => e.Title),
            "deadline" => query.SortDesc ? q => q.OrderByDescending(e => e.DeadLine) : q => q.OrderBy(e => e.DeadLine),
            "createdat" => query.SortDesc
                ? q => q.OrderByDescending(e => e.CreatedAt)
                : q => q.OrderBy(e => e.CreatedAt),
            "lastmodifiedat" => query.SortDesc
                ? q => q.OrderByDescending(e => e.LastModifiedAt)
                : q => q.OrderBy(e => e.LastModifiedAt),
            _ => q => q.OrderBy(e => e.Id)
        };
    }

    /// <summary>
    /// Injects owner ID and ensures at least one subtask exists for every task.
    /// </summary>
    protected override void AddContextualData(TaskEntity entity, TaskCreateModel? createModel,
        TaskUpdateModel? updateModel)
    {
        if (createModel is not null)
        {
            entity.CreatedById = CurrentUserId;

            // If no subtasks provided, create a default template from the task title
            if (entity.Subtasks is null || entity.Subtasks.Count == 0)
            {
                entity.Subtasks.Add(new SubtaskTemplateEntity
                {
                    Title = entity.Title,
                    Description = entity.Notes,
                    IsGeneratedFromTask = true
                });
            }
        }

        if (updateModel is not null)
            entity.LastModifiedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Handles task creation, initializes shared instances, and processes initial invitations.
    /// </summary>
    public override async Task<Result<TaskDetailModel>> SaveCreateModelAsync(TaskCreateModel model)
    {
        var task = mapper.Map<TaskEntity>(model);
        AddContextualData(task, model, default);
        if (task.Id == Guid.Empty) task.Id = Guid.NewGuid();

        // In Shared mode, we create one global instance per template immediately
        if (task.SubtaskMode == SubtaskMode.Shared)
        {
            CreateInstancesForTemplates(task.Subtasks, Guid.NewGuid(), null, null, addToContext: false);
        }

        await ProcessNewInvitations(task, model.InvitedEmails, isNewTask: true);

        await dbContext.Tasks.AddAsync(task);
        await dbContext.SaveChangesAsync();

        // Handle background email dispatching if requested
        if (model.SendInvitesImmediately && model.InvitedEmails.Count != 0)
        {
            var author = await dbContext.Users.FindAsync(CurrentUserId);
            var authorName = author?.Name ?? "Your colleague";

            invitationFacade.StartEmailSendingBackground(
                model.InvitedEmails, task.Hash, authorName, task.Title, task.Notes, task.CreatedById, task.Id
            );
        }

        return await GetByIdAsync(task.Id);
    }

    /// <summary>
    /// Updates an existing task and refreshes UI components via SignalR.
    /// </summary>
    public override async Task<Result<TaskDetailModel>> SaveUpdateModelAsync(TaskUpdateModel model)
    {
        var task = await dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == model.Id);

        if (task is null)
            return Result<TaskDetailModel>.NotFound($"Task with ID {model.Id} not found.");

        mapper.Map(model, task);

        // Reset state if deadline was moved to the future
        if (task.State == TaskState.Completed && model.DeadLine > DateTime.UtcNow)
            task.State = TaskState.InProgress;

        if (model.State.HasValue)
            task.State = model.State.Value;

        task.LastModifiedAt = DateTime.UtcNow;

        await ProcessNewInvitations(task, model.InvitedEmails, isNewTask: false);

        await dbContext.SaveChangesAsync();

        // Broadcast changes to active detail rooms
        var roomName = task.Id.ToString().ToLower();
        await hubContext.Clients.Group(roomName).SendAsync("TaskInvitationsChanged");
        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");

        return await GetByIdAsync(task.Id);
    }

    /// <summary>
    /// Helper to create subtask execution rows from blueprint templates.
    /// </summary>
    private void CreateInstancesForTemplates(
        IEnumerable<SubtaskTemplateEntity> templates, Guid responseGroupId, string? email, Guid? userId,
        bool addToContext)
    {
        foreach (var template in templates)
        {
            var instance = new SubtaskInstanceEntity
            {
                Id = Guid.NewGuid(),
                ResponseGroupId = responseGroupId,
                AssignedToEmail = email,
                AssignedToUserId = userId,
                IsCompleted = false,
                TemplateSubtaskId = template.Id
            };

            if (addToContext) dbContext.SubtaskInstances.Add(instance);
            else template.Instances.Add(instance);
        }
    }

    /// <summary>
    /// Synchronizes a user's instances, creating missing ones or adopting anonymous ones after registration.
    /// </summary>
    private void SyncUserInstances(
        IEnumerable<SubtaskTemplateEntity> templates,
        List<SubtaskInstanceEntity> existingUserInstances,
        string? email, Guid? userId, bool addToContext)
    {
        if (!existingUserInstances.Any())
        {
            // Generate full set for new participant
            CreateInstancesForTemplates(templates, Guid.NewGuid(), email, userId, addToContext);
        }
        else
        {
            // Add instances for templates added after the participant joined
            var existingTemplateIds = existingUserInstances.Select(i => i.TemplateSubtaskId).ToHashSet();
            var missingTemplates = templates.Where(t => !existingTemplateIds.Contains(t.Id)).ToList();

            if (missingTemplates.Any())
            {
                var existingGroupId = existingUserInstances.First().ResponseGroupId;
                CreateInstancesForTemplates(missingTemplates, existingGroupId, email, userId, addToContext);
            }

            // Link anonymous responses to the user profile if they just logged in
            if (userId != null && userId != Guid.Empty)
            {
                foreach (var inst in existingUserInstances.Where(i => i.AssignedToUserId == null))
                {
                    inst.AssignedToUserId = userId;
                }
            }
        }
    }

    /// <summary>
    /// Generates Invitation entities and corresponding Individual mode instances for new emails.
    /// </summary>
    private async Task ProcessNewInvitations(TaskEntity task, List<string> emailsToInvite, bool isNewTask)
    {
        var existingEmails = isNewTask
            ? new List<string>()
            : await dbContext.Invitations
                .Where(i => i.TaskId == task.Id)
                .Select(i => i.Email.ToLower().Trim())
                .ToListAsync();

        var newEmails = emailsToInvite
            .Select(e => e.ToLower().Trim())
            .Except(existingEmails)
            .Distinct()
            .ToList();

        if (!newEmails.Any()) return;

        var templates = isNewTask
            ? task.Subtasks.ToList()
            : await dbContext.Subtasks.Where(s => s.ParentTaskId == task.Id).ToListAsync();

        var templatesCount = templates.Count;

        var newEmailsUsers = await dbContext.Users
            .Where(u => newEmails.Contains(u.Email.ToLower()))
            .ToListAsync();

        // Optimized batch loading to avoid N+1 query issues
        var allTaskInstances = isNewTask
            ? new List<SubtaskInstanceEntity>()
            : await dbContext.SubtaskInstances
                .Where(i => i.TemplateSubtask.ParentTaskId == task.Id)
                .ToListAsync();

        foreach (var email in newEmails)
        {
            var user = newEmailsUsers.FirstOrDefault(u => u.Email.ToLower() == email);

            var existingUserInstances = allTaskInstances
                .Where(i => (i.AssignedToEmail != null && i.AssignedToEmail.ToLower() == email) ||
                            (user != null && i.AssignedToUserId == user.Id))
                .ToList();

            bool hasAnyCompleted = existingUserInstances.Any(i => i.IsCompleted);
            bool isFullyCompleted =
                hasAnyCompleted && existingUserInstances.Count(i => i.IsCompleted) >= templatesCount;

            dbContext.Invitations.Add(new InvitationEntity
            {
                Id = Guid.NewGuid(),
                Email = email,
                IsSent = false,
                SentAt = null,
                TaskId = task.Id,
                IsAccepted = hasAnyCompleted,
                IsCompleted = isFullyCompleted
            });

            if (task.SubtaskMode == SubtaskMode.Individual)
            {
                SyncUserInstances(templates, existingUserInstances, email, user?.Id, addToContext: !isNewTask);
            }
        }
    }

    /// <summary>
    /// Removes users from task and cleans up their specific instances or resets shared progress.
    /// </summary>
    public async Task<Result<bool>> RemoveInvitationsAsync(Guid taskId, List<string> emails)
    {
        var normalizedEmails = emails.Select(e => e.ToLower().Trim()).ToList();

        var task = await dbContext.Tasks
            .Select(t => new { t.Id, t.SubtaskMode })
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return Result<bool>.NotFound();

        var invitationsToRemove = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && normalizedEmails.Contains(i.Email.ToLower()))
            .ToListAsync();

        if (!invitationsToRemove.Any())
            return Result<bool>.Success(true);

        var userIds = await dbContext.Users
            .Where(u => normalizedEmails.Contains(u.Email.ToLower()))
            .Select(u => u.Id)
            .ToListAsync();

        try
        {
            if (task.SubtaskMode == SubtaskMode.Individual)
            {
                // In Individual mode, we purge all instances tied to these users
                var instancesToRemove = await dbContext.SubtaskInstances
                    .Where(si => si.TemplateSubtask.ParentTaskId == taskId &&
                                 (
                                     (si.AssignedToEmail != null &&
                                      normalizedEmails.Contains(si.AssignedToEmail.ToLower())) ||
                                     (si.AssignedToUserId != null && userIds.Contains(si.AssignedToUserId.Value))
                                 ))
                    .ToListAsync();

                if (instancesToRemove.Any())
                {
                    dbContext.SubtaskInstances.RemoveRange(instancesToRemove);
                }
            }
            else
            {
                // In Shared mode, we reset progress for subtasks completed by these users
                var instancesToReset = await dbContext.SubtaskInstances
                    .Where(si => si.TemplateSubtask.ParentTaskId == taskId &&
                                 si.CompletedByUserId != null &&
                                 userIds.Contains(si.CompletedByUserId.Value))
                    .ToListAsync();

                foreach (var si in instancesToReset)
                {
                    si.IsCompleted = false;
                    si.CompletedByUserId = null;
                    si.CompletedAt = null;
                    si.RespondentName = null;
                    si.Comment = null;
                }
            }

            dbContext.Invitations.RemoveRange(invitationsToRemove);
            await dbContext.SaveChangesAsync();

            // Notify UI about invitation and task content changes
            var taskRoom = taskId.ToString().ToLower();
            await hubContext.Clients.Group(taskRoom).SendAsync("TaskInvitationsChanged");
            await hubContext.Clients.Group(taskRoom).SendAsync("TaskInstancesChanged");

            return Result<bool>.Success(true);
        }
        catch (Exception)
        {
            return Result<bool>.Failure(ErrorType.InternalError, "Failed to remove users from task.");
        }
    }

    /// <summary>
    /// Retrieves task blueprints for management.
    /// </summary>
    public async Task<Result<List<SubtaskCombinedListModel>>> GetTaskTemplatesAsync(Guid taskId)
    {
        var task = await dbContext.Tasks
            .Include(t => t.Subtasks)
            .FirstOrDefaultAsync(t => t.Id == taskId && t.CreatedById == CurrentUserId);

        if (task == null) return Result<List<SubtaskCombinedListModel>>.NotFound();

        var result = mapper.Map<List<SubtaskCombinedListModel>>(task.Subtasks);
        return Result<List<SubtaskCombinedListModel>>.Success(result);
    }

    /// <summary>
    /// Retrieves execution instances of subtasks for a specific task.
    /// </summary>
    public async Task<Result<List<SubtaskCombinedListModel>>> GetTaskInstancesAsync(Guid taskId)
    {
        var instances = await dbContext.SubtaskInstances
            .Include(i => i.TemplateSubtask)
            .ThenInclude(st => st.ParentTask)
            .Where(i => i.TemplateSubtask.ParentTaskId == taskId &&
                        i.TemplateSubtask.ParentTask.CreatedById == CurrentUserId)
            .ToListAsync();

        var result = mapper.Map<List<SubtaskCombinedListModel>>(instances);
        return Result<List<SubtaskCombinedListModel>>.Success(result);
    }

    /// <summary>
    /// Core logic for viewing a task publically. Handles domain validation, 
    /// invitation acceptance, and participant-specific instance retrieval.
    /// </summary>
    public async Task<Result<TaskPublicDetailModel>> GetTaskPublicDetailByHashAsync(string hash)
    {
        var currentUserId = OptionalUserId;

        var task = await dbContext.Set<TaskEntity>()
            .Include(t => t.Subtasks)
            .ThenInclude(st => st.Instances)
            .Include(t => t.Invitations)
            .Where(t => t.Hash == hash)
            .FirstOrDefaultAsync();

        if (task == null)
            return Result<TaskPublicDetailModel>.NotFound($"Task with hash '{hash}' was not found.");

        if (task.RequiresAuthenticationToComplete && currentUserId == null)
        {
            return Result<TaskPublicDetailModel>.Failure(ErrorType.Unauthorized,
                "Authentication is required to view the details of this task.");
        }

        // Domain validation for corporate/academic restricted tasks
        if (!string.IsNullOrEmpty(task.AllowedDomain))
        {
            var userEmail = UserContext.GetEmail()?.ToLower().Trim();

            if (string.IsNullOrEmpty(userEmail))
            {
                return Result<TaskPublicDetailModel>.Failure(ErrorType.Unauthorized,
                    "You must be logged in with a school/company email to access this task.");
            }

            var requiredDomain = task.AllowedDomain.ToLower().Trim();
            if (!requiredDomain.StartsWith("@")) requiredDomain = "@" + requiredDomain;

            if (!userEmail.EndsWith(requiredDomain))
            {
                return Result<TaskPublicDetailModel>.Forbidden(
                    $"This task is reserved for members of {task.AllowedDomain}. " +
                    $"You are currently logged in as {userEmail}.");
            }
        }

        // Auto-accept invitation upon first open
        if (task.Invitations.Count != 0 && task.CreatedById != currentUserId)
        {
            var email = UserContext.GetEmail();
            if (!string.IsNullOrEmpty(email))
            {
                var userEmail = email.ToLower().Trim();
                var invitation = task.Invitations.FirstOrDefault(i => i.Email.ToLower().Trim() == userEmail);

                if (invitation != null && !invitation.IsAccepted)
                {
                    invitation.IsAccepted = true;
                    await dbContext.SaveChangesAsync();
                    await hubContext.Clients.Group(task.Id.ToString()).SendAsync("TaskUpdated");
                }
            }
        }

        IEnumerable<SubtaskInstanceEntity> instancesToShow;

        // Individual Mode for Anonymous participants (Show empty templates)
        if (task.SubtaskMode == SubtaskMode.Individual && !currentUserId.HasValue)
        {
            var subtasks = task.Subtasks.Select(st => new SubtaskCombinedListModel
            {
                Id = st.Id,
                Title = st.Title,
                Description = st.Description,
                IsCompleted = false,
                IsGeneratedFromTask = st.IsGeneratedFromTask,
                Deadline = task.DeadLine
            }).ToList();

            var publicModel = mapper.Map<TaskPublicDetailModel>(task);
            return Result<TaskPublicDetailModel>.Success(publicModel with { Subtasks = subtasks });
        }
        // Individual Mode for Authenticated users
        else if (task.SubtaskMode == SubtaskMode.Individual && currentUserId.HasValue)
        {
            await EnsureIndividualInstancesExist(task, currentUserId.Value, UserContext.GetEmail());

            instancesToShow = await dbContext.Set<SubtaskInstanceEntity>()
                .Include(i => i.TemplateSubtask)
                .Where(i => i.TemplateSubtask.ParentTaskId == task.Id && i.AssignedToUserId == currentUserId.Value)
                .ToListAsync();
        }
        // Shared Mode
        else
        {
            instancesToShow = task.Subtasks.SelectMany(s => s.Instances);
        }

        var subtasksList = instancesToShow
            .AsQueryable()
            .ProjectTo<SubtaskCombinedListModel>(mapper.ConfigurationProvider)
            .ToList();

        var publicModelBase = mapper.Map<TaskPublicDetailModel>(task);
        var finalModel = publicModelBase with { Subtasks = subtasksList };

        return Result<TaskPublicDetailModel>.Success(finalModel);
    }

    /// <summary>
    /// Ensures participant-specific subtask instances exist for the user.
    /// </summary>
    public async Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId, string? userEmail)
    {
        var existingUserInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Where(i => i.TemplateSubtask.ParentTaskId == task.Id &&
                        (i.AssignedToUserId == userId || (userEmail != null && i.AssignedToEmail == userEmail)))
            .ToListAsync();

        SyncUserInstances(task.Subtasks, existingUserInstances, userEmail, userId, addToContext: true);

        await dbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Aggregates progress data for a list of tasks for the author's dashboard.
    /// </summary>
    public async Task<Result<List<TaskSummaryStats>>> GetSummaryStats(List<Guid> taskIds)
    {
        var allInstances = await dbContext.SubtaskInstances
            .Where(i => taskIds.Contains(i.TemplateSubtask.ParentTaskId))
            .Select(i => new
            {
                TaskId = i.TemplateSubtask.ParentTaskId,
                i.TemplateSubtask.ParentTask.SubtaskMode,
                i.AssignedToUserId,
                i.IsCompleted,
                i.ResponseGroupId,
                i.CompletedAt,
                Deadline = i.TemplateSubtask.ParentTask.DeadLine
            })
            .ToListAsync();

        var taskModes = await dbContext.Tasks
            .Where(t => taskIds.Contains(t.Id))
            .Select(t => new { t.Id, t.SubtaskMode })
            .ToDictionaryAsync(t => t.Id, t => t.SubtaskMode);

        var results = new List<TaskSummaryStats>();

        foreach (var taskId in taskIds)
        {
            var mode = taskModes.ContainsKey(taskId) ? taskModes[taskId] : SubtaskMode.Shared;
            var taskInstances = allInstances.Where(i => i.TaskId == taskId).ToList();

            if (mode == SubtaskMode.Individual)
            {
                var userGroups = taskInstances
                    .GroupBy(i => i.ResponseGroupId)
                    .Select(g => new
                    {
                        TotalCount = g.Count(),
                        CompletedCount = g.Count(x => x.IsCompleted),
                        // Late: Everything done, but at least one after deadline
                        IsFinishedLate = g.All(x => x.IsCompleted) && g.Any(x => x.CompletedAt > x.Deadline),
                        // OnTime: Everything done and submitted before deadline
                        IsFinishedOnTime = g.All(x => x.IsCompleted) && g.All(x => x.CompletedAt <= x.Deadline)
                    }).ToList();

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalRespondents = userGroups.Count,

                    CompletedOnTime = userGroups.Count(u => u.IsFinishedOnTime), // Green
                    IssuesCount = userGroups.Count(u => u.IsFinishedLate), // Red
                    InProgress =
                        userGroups.Count(u => u.CompletedCount > 0 && u.CompletedCount < u.TotalCount), // Orange
                    NotStarted = userGroups.Count(u => u.CompletedCount == 0), // Gray

                    GlobalProgress = userGroups.Count == 0
                        ? 0
                        : (double)userGroups.Count(u => u.CompletedCount == u.TotalCount) / userGroups.Count * 100
                });
            }
            else // Shared Mode
            {
                int total = taskInstances.Count;
                int completedOnTime = taskInstances.Count(i => i.IsCompleted && i.CompletedAt <= i.Deadline);
                int completedLate = taskInstances.Count(i => i.IsCompleted && i.CompletedAt > i.Deadline);
                int notCompleted = total - completedOnTime - completedLate;

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalSubtasks = total,
                    CompletedSubtasks = completedOnTime + completedLate,

                    CompletedOnTime = completedOnTime, // Green
                    IssuesCount = completedLate, // Red
                    NotStarted = notCompleted // Gray
                });
            }
        }

        return Result<List<TaskSummaryStats>>.Success(results);
    }
}