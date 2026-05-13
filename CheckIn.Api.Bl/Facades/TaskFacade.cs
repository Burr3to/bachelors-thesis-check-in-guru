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
    protected override Expression<Func<TaskEntity, bool>> CreateFilter(TaskListQuery query)
    {
        Expression<Func<TaskEntity, bool>> filter = entity => true;

        if (!string.IsNullOrEmpty(query.NameContains))
            filter = filter.And(entity => EF.Functions.ILike(entity.Title, $"%{query.NameContains}%"));

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

        Guid currentUserId = CurrentUserId;
        filter = filter.And(entity => entity.CreatedById == currentUserId);

        return filter;
    }

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

    protected override void AddContextualData(TaskEntity entity, TaskCreateModel? createModel,
        TaskUpdateModel? updateModel)
    {
        if (createModel is not null)
        {
            entity.CreatedById = CurrentUserId;

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

    public override async Task<Result<TaskDetailModel>> SaveCreateModelAsync(TaskCreateModel model)
    {
        var task = mapper.Map<TaskEntity>(model);
        AddContextualData(task, model, default);
        if (task.Id == Guid.Empty) task.Id = Guid.NewGuid();

        if (task.SubtaskMode == SubtaskMode.Shared)
        {
            CreateInstancesForTemplates(task.Subtasks, Guid.NewGuid(), null, null, addToContext: false);
        }

        await ProcessNewInvitations(task, model.InvitedEmails, isNewTask: true);

        await dbContext.Tasks.AddAsync(task);
        await dbContext.SaveChangesAsync();

        if (model.SendInvitesImmediately && model.InvitedEmails.Count != 0)
        {
            var author = await dbContext.Users.FindAsync(CurrentUserId);
            var authorName = author?.Name ?? "Váš kolega";

            invitationFacade.StartEmailSendingBackground(
                model.InvitedEmails, task.Hash, authorName, task.Title, task.Notes, task.CreatedById, task.Id
            );
        }

        return await GetByIdAsync(task.Id);
    }

    public override async Task<Result<TaskDetailModel>> SaveUpdateModelAsync(TaskUpdateModel model)
    {
        var task = await dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == model.Id);

        if (task is null)
            return Result<TaskDetailModel>.NotFound($"Task with ID {model.Id} not found.");

        mapper.Map(model, task);

        if (task.State == TaskState.Completed && model.DeadLine > DateTime.UtcNow)
            task.State = TaskState.InProgress;

        if (model.State.HasValue)
            task.State = model.State.Value;

        task.LastModifiedAt = DateTime.UtcNow;

        await ProcessNewInvitations(task, model.InvitedEmails, isNewTask: false);

        await dbContext.SaveChangesAsync();

        var roomName = task.Id.ToString().ToLower();
        await hubContext.Clients.Group(roomName).SendAsync("TaskInvitationsChanged");
        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");

        return await GetByIdAsync(task.Id);
    }


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

    private void SyncUserInstances(
        IEnumerable<SubtaskTemplateEntity> templates,
        List<SubtaskInstanceEntity> existingUserInstances,
        string? email, Guid? userId, bool addToContext)
    {
        if (!existingUserInstances.Any())
        {
            CreateInstancesForTemplates(templates, Guid.NewGuid(), email, userId, addToContext);
        }
        else
        {
            var existingTemplateIds = existingUserInstances.Select(i => i.TemplateSubtaskId).ToHashSet();
            var missingTemplates = templates.Where(t => !existingTemplateIds.Contains(t.Id)).ToList();

            if (missingTemplates.Any())
            {
                var existingGroupId = existingUserInstances.First().ResponseGroupId;
                CreateInstancesForTemplates(missingTemplates, existingGroupId, email, userId, addToContext);
            }

            // Adopt anonymous instances if user has registered
            if (userId != null && userId != Guid.Empty)
            {
                foreach (var inst in existingUserInstances.Where(i => i.AssignedToUserId == null))
                {
                    inst.AssignedToUserId = userId;
                }
            }
        }
    }

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

        // Optimized batch loading - Fetch ALL relevant instances at once instead of N+1
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

    public async Task<Result<bool>> RemoveInvitationsAsync(Guid taskId, List<string> emails)
    {
        var normalizedEmails = emails.Select(e => e.ToLower().Trim()).ToList();

        // 1. Zistíme režim úlohy
        var task = await dbContext.Tasks
            .Select(t => new { t.Id, t.SubtaskMode })
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null) return Result<bool>.NotFound();

        // 2. Nájdeme pozvánky na odstránenie
        var invitationsToRemove = await dbContext.Invitations
            .Where(i => i.TaskId == taskId && normalizedEmails.Contains(i.Email.ToLower()))
            .ToListAsync();

        if (!invitationsToRemove.Any())
            return Result<bool>.Success(true);

        // 3. Získame ID používateľov (potrebné pre oba módy na identifikáciu cez UserId)
        var userIds = await dbContext.Users
            .Where(u => normalizedEmails.Contains(u.Email.ToLower()))
            .Select(u => u.Id)
            .ToListAsync();

        try
        {
            if (task.SubtaskMode == SubtaskMode.Individual)
            {
                // --- INDIVIDUAL MODE (VRÁTENÁ A POSILNENÁ LOGIKA) ---
                // Mažeme VŠETKY inštancie pridelené daným emailom/userom.
                // Či sú splnené (3) alebo nesplnené (5), musia zmiznúť všetky, 
                // pretože v Individual móde má každý svoju vlastnú sadu.
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
                // --- SHARED MODE (BEZPEČNÝ RESET) ---
                // Tu inštancie nemažeme (sú spoločné), len hľadáme tie, ktoré tito ľudia reálne klikli.
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

            // Odstránime samotné pozvánky
            dbContext.Invitations.RemoveRange(invitationsToRemove);

            await dbContext.SaveChangesAsync();

            // SignalR notifikácie
            var taskRoom = taskId.ToString().ToLower();
            await hubContext.Clients.Group(taskRoom).SendAsync("TaskInvitationsChanged");
            await hubContext.Clients.Group(taskRoom).SendAsync("TaskInstancesChanged");

            return Result<bool>.Success(true);
        }
        catch (Exception e)
        {
            Console.WriteLine($"REMOVE ERROR: {e.Message}");
            return Result<bool>.Failure(ErrorType.InternalError, "Nepodarilo sa odstrániť používateľov.");
        }
    }

    public async Task<Result<List<SubtaskCombinedListModel>>> GetTaskTemplatesAsync(Guid taskId)
    {
        var task = await dbContext.Tasks
            .Include(t => t.Subtasks)
            .FirstOrDefaultAsync(t => t.Id == taskId && t.CreatedById == CurrentUserId);

        if (task == null) return Result<List<SubtaskCombinedListModel>>.NotFound();

        var result = mapper.Map<List<SubtaskCombinedListModel>>(task.Subtasks);

        return Result<List<SubtaskCombinedListModel>>.Success(result);
    }

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
        {
            return Result<TaskPublicDetailModel>.NotFound($"Task with hash '{hash}' was not found.");
        }

        if (task.RequiresAuthenticationToComplete && currentUserId == null)
        {
            return Result<TaskPublicDetailModel>.Failure(ErrorType.Unauthorized,
                "Authentication is required to view the details of this task.");
        }

        // --- PRIDANÁ LOGIKA PRE KONTROLU DOMÉNY ---
        if (!string.IsNullOrEmpty(task.AllowedDomain))
        {
            var userEmail = UserContext.GetEmail()?.ToLower().Trim();

            // Ak je nastavená doména, ale nemáme email (používateľ nie je prihlásený)
            if (string.IsNullOrEmpty(userEmail))
            {
                return Result<TaskPublicDetailModel>.Failure(ErrorType.Unauthorized,
                    "Na prístup k tejto úlohe sa musíte prihlásiť školským/firemným emailom.");
            }

            // Normalizujeme doménu z DB (aby sme zvládli "vutbr.cz" aj "@vutbr.cz")
            var requiredDomain = task.AllowedDomain.ToLower().Trim();
            if (!requiredDomain.StartsWith("@")) requiredDomain = "@" + requiredDomain;

            // Kontrola, či email končí požadovanou doménou
            if (!userEmail.EndsWith(requiredDomain))
            {
                return Result<TaskPublicDetailModel>.Forbidden(
                    $"Tento check-in je vyhradený pre organizáciu {task.AllowedDomain}. " +
                    $"Momentálne ste prihlásený ako {userEmail}. " +
                    "Prosím, odhláste sa a použite svoj oficiálny školský alebo firemný účet.");
            }
        }

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
        else if (task.SubtaskMode == SubtaskMode.Individual && currentUserId.HasValue)
        {
            await EnsureIndividualInstancesExist(task, currentUserId.Value, UserContext.GetEmail());

            instancesToShow = await dbContext.Set<SubtaskInstanceEntity>()
                .Include(i => i.TemplateSubtask)
                .Where(i => i.TemplateSubtask.ParentTaskId == task.Id && i.AssignedToUserId == currentUserId.Value)
                .ToListAsync();
        }
        else // Shared Mode
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

    public async Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId, string? userEmail)
    {
        // Now extremely simplified by reusing our helper
        var existingUserInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Where(i => i.TemplateSubtask.ParentTaskId == task.Id &&
                        (i.AssignedToUserId == userId || (userEmail != null && i.AssignedToEmail == userEmail)))
            .ToListAsync();

        SyncUserInstances(task.Subtasks, existingUserInstances, userEmail, userId, addToContext: true);

        await dbContext.SaveChangesAsync();
    }

    public async Task<Result<List<TaskSummaryStats>>> GetSummaryStats(List<Guid> taskIds)
    {
        // Vytiahneme aj CompletedAt a DeadLine!
        var allInstances = await dbContext.SubtaskInstances
            .Where(i => taskIds.Contains(i.TemplateSubtask.ParentTaskId))
            .Select(i => new
            {
                TaskId = i.TemplateSubtask.ParentTaskId,
                i.TemplateSubtask.ParentTask.SubtaskMode,
                i.AssignedToUserId,
                i.IsCompleted,
                i.ResponseGroupId,
                i.CompletedAt, // PRIDANÉ
                Deadline = i.TemplateSubtask.ParentTask.DeadLine // PRIDANÉ (Ak je deadline inde, uprav cestu)
            })
            .ToListAsync();

        var taskModes = await dbContext.Tasks
            .Where(t => taskIds.Contains(t.Id))
            .Select(t => new { t.Id, t.SubtaskMode })
            .ToDictionaryAsync(t => t.Id, t => t.SubtaskMode);

        var now = DateTime.UtcNow;
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
                        // Osoba je "Late", ak má všetko hotové, ale aspoň jeden subtask bol po deadline
                        IsFinishedLate = g.All(x => x.IsCompleted) && g.Any(x => x.CompletedAt > x.Deadline),
                        // Osoba je "OnTime", ak má všetko hotové a všetko bolo včas
                        IsFinishedOnTime = g.All(x => x.IsCompleted) && g.All(x => x.CompletedAt <= x.Deadline)
                    }).ToList();

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalRespondents = userGroups.Count,

                    CompletedOnTime = userGroups.Count(u => u.IsFinishedOnTime), // Zelená
                    IssuesCount = userGroups.Count(u => u.IsFinishedLate), // Červená
                    InProgress =
                        userGroups.Count(u => u.CompletedCount > 0 && u.CompletedCount < u.TotalCount), // Oranžová
                    NotStarted = userGroups.Count(u => u.CompletedCount == 0), // Sivá

                    GlobalProgress = userGroups.Count == 0
                        ? 0
                        : (double)userGroups.Count(u => u.CompletedCount == u.TotalCount) / userGroups.Count * 100
                });
            }
            else // Shared Mode
            {
                int total = taskInstances.Count;
                // Zelená: Dokončené a včas
                int completedOnTime = taskInstances.Count(i => i.IsCompleted && i.CompletedAt <= i.Deadline);
                // Červená: Dokončené, ale po deadline (Late)
                int completedLate = taskInstances.Count(i => i.IsCompleted && i.CompletedAt > i.Deadline);
                // Sivá: Všetko ostatné, čo nie je hotové (bez ohľadu na to, či už mešká alebo nie)
                int notCompleted = total - completedOnTime - completedLate;

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalSubtasks = total,
                    CompletedSubtasks = completedOnTime + completedLate, // Pre label X/Y (celkovo hotové)

                    // Farby pre Progress Bar:
                    CompletedOnTime = completedOnTime, // Zelená
                    IssuesCount = completedLate, // Červená (iba tie, čo sú hotové neskoro)
                    NotStarted = notCompleted // Sivá (všetko nehotové)
                });
            }
        }

        return Result<List<TaskSummaryStats>>.Success(results);
    }
}