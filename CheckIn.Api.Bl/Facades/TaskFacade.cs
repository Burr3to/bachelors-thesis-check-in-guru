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
        // Základný filter, ktorý všetko vráti
        Expression<Func<TaskEntity, bool>> filter = entity => true;

        if (!string.IsNullOrEmpty(query.NameContains))
            filter = filter.And(entity => entity.Title.ToLower().Contains(query.NameContains.ToLower()));

        if (query.Status.HasValue)
            filter = filter.And(entity => entity.State == query.Status.Value);

        if (query.DeadLineBefore.HasValue)
            filter = filter.And(entity => entity.DeadLine <= query.DeadLineBefore.Value);

        if (query.DeadLineAfter.HasValue)
            filter = filter.And(entity => entity.DeadLine >= query.DeadLineAfter.Value);

        if (query.CreatedAfter.HasValue)
            filter = filter.And(entity => entity.CreatedAt >= query.CreatedAfter.Value);

        Guid currentUserId = CurrentUserId;
        filter = filter.And(entity => entity.CreatedById == currentUserId);

        return filter;
    }

    protected override Func<IQueryable<TaskEntity>, IOrderedQueryable<TaskEntity>> CreateOrderBy(TaskListQuery query)
    {
        // Ak používateľ nezadal kritérium triedenia, použijeme default Id
        if (string.IsNullOrWhiteSpace(query.SortBy))
        {
            return q => q.OrderBy(e => e.Id);
        }

        return query.SortBy.ToLower() switch
        {
            "title" => query.SortDesc
                ? q => q.OrderByDescending(e => e.Title)
                : q => q.OrderBy(e => e.Title),

            "deadline" => query.SortDesc
                ? q => q.OrderByDescending(e => e.DeadLine)
                : q => q.OrderBy(e => e.DeadLine),

            "createdat" => query.SortDesc
                ? q => q.OrderByDescending(e => e.CreatedAt)
                : q => q.OrderBy(e => e.CreatedAt),

            _ => q => q.OrderBy(e => e.Id)
        };
    }

    protected override void AddContextualData(TaskEntity entity, TaskCreateModel? createModel,
        TaskUpdateModel? updateModel)
    {
        if (createModel is not null)
        {
            entity.CreatedById = CurrentUserId;
            entity.State = TaskState.Todo;

            // Toto tu nechaj - ak používateľ nepridal žiadne subúlohy, 
            // vytvoríme aspoň jednu "hlavnú", aby sa mal kam podpísať.
            if (entity.Subtasks is null || !entity.Subtasks.Any())
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
        {
            entity.LastModifiedAt = DateTime.UtcNow;
        }
    }

    public override async Task<Result<TaskDetailModel>> SaveCreateModelAsync(TaskCreateModel model)
    {
        var task = mapper.Map<TaskEntity>(model);
        AddContextualData(task, model, default);
        if (task.Id == Guid.Empty) task.Id = Guid.NewGuid();

        // 1. Pozvánky (Invitations) - Pridávame priamo do Tasku
        foreach (var email in model.InvitedEmails)
        {
            task.Invitations.Add(new InvitationEntity
            {
                Id = Guid.NewGuid(),
                Email = email,
                SentAt = DateTime.UtcNow,
                TaskId = task.Id
            });
        }

        //  Shared mode
        if (task.SubtaskMode == SubtaskMode.Shared)
        {
            var sharedGroupId = Guid.NewGuid();
            foreach (var subtaskTemplate in task.Subtasks)
            {
                // Pridávame inštanciu do kolekcie v šablóne
                subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
                {
                    Id = Guid.NewGuid(),
                    ResponseGroupId = sharedGroupId,
                    IsCompleted = false
                    // AssignedToEmail NULL
                });
            }
        }
        else // Individual Mode
        {
            foreach (var email in model.InvitedEmails)
            {
                var userGroupId = Guid.NewGuid();
                foreach (var subtaskTemplate in task.Subtasks)
                {
                    // Pre každého pozvaného vytvoríme inštanciu v každej šablóne
                    subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
                    {
                        Id = Guid.NewGuid(),
                        ResponseGroupId = userGroupId,
                        AssignedToEmail = email,
                        IsCompleted = false
                    });
                }
            }
        }

        await dbContext.Tasks.AddAsync(task);
        await dbContext.SaveChangesAsync();

        // Spustenie mailov na pozadí...
        var author = await dbContext.Users.FindAsync(CurrentUserId);
        var authorName = author?.Name ?? "Váš kolega";
        invitationFacade.StartEmailSendingBackground(model.InvitedEmails, task.Hash, authorName, task.Title,
            task.Notes, task.CreatedById);

        return await GetByIdAsync(task.Id);
    }

    public override async Task<Result<TaskDetailModel>> SaveUpdateModelAsync(TaskUpdateModel model)
    {
        var task = await dbContext.Tasks.FindAsync(model.Id);

        if (task is null)
            return Result<TaskDetailModel>.NotFound($"Task with ID {model.Id} not found for update.");

        mapper.Map(model, task);

        AddContextualData(task, null, model);

        try
        {
            await dbContext.SaveChangesAsync();
        }
        catch (Exception e)
        {
            return Result<TaskDetailModel>.Failure(ErrorType.InternalError, $"Failed to update task: {{e.Message}}");
        }

        var updatedTask = await GetByIdAsync(task.Id);

        return updatedTask;
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
            .Where(i => i.TemplateSubtask.ParentTaskId == taskId &&
                        i.TemplateSubtask.ParentTask.CreatedById == CurrentUserId)
            .ToListAsync();

        var result = mapper.Map<List<SubtaskCombinedListModel>>(instances);

        return Result<List<SubtaskCombinedListModel>>.Success(result);
    }


    public async Task<Result<TaskPublicDetailModel>> GetTaskPublicDetailByHashAsync(string hash)
    {
        // Kľúčové: Používame OptionalUserId, pretože anonymný prístup je povolený.
        var currentUserId = OptionalUserId;

        // 1. Načítanie Tasku podľa Hashu a jeho Subtaskov/Inštancií
        var task = await dbContext.Set<TaskEntity>()
            .Include(t => t.Subtasks)
            .ThenInclude(st => st.Instances)
            .Include(t => t.Invitations)
            .Where(t => t.Hash == hash) // FILTER JE PODĽA HASHU
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

        if (task.Invitations.Any())
        {
            if (task.CreatedById == currentUserId)
            {
                // Autor má prístup vždy
            }
            else
            {
                var userEmail = UserContext.GetEmail();
                var isInvited = task.Invitations.Any(i => i.Email == userEmail);

                if (!isInvited)
                {
                    return Result<TaskPublicDetailModel>.Failure(ErrorType.Forbidden,
                        "Bohužiaľ, váš email nie je na zozname pozvaných pre túto úlohu.");
                }
            }
        }

        IEnumerable<SubtaskInstanceEntity> instancesToShow;

        // 2. Filtrácia inštancií
        if (task.SubtaskMode == SubtaskMode.Individual && !currentUserId.HasValue)
        {
            // Individuálny režim a ANONYMNÝ používateľ:
            // Nemá žiadne inštancie, tak mu vrátime "prázdne" inštancie vytvorené zo šablón.
            var subtasks = task.Subtasks.Select(st => new SubtaskCombinedListModel
            {
                // Tu je dôležitý trik: Keďže inštancia neexistuje, 
                // môžeme poslať ID šablóny, aby frontend vedel, k čomu sa podpisuje.
                Id = st.Id,
                Title = st.Title,
                Description = st.Description,
                IsCompleted = false,
                IsGeneratedFromTask = st.IsGeneratedFromTask,
                // Pridáme flag, aby frontend vedel, že toto je len "šablóna" na vyplnenie
                // (voliteľné, ak to potrebuješ rozlíšiť)
            }).ToList();

            var publicModel = mapper.Map<TaskPublicDetailModel>(task);
            return Result<TaskPublicDetailModel>.Success(publicModel with { Subtasks = subtasks });
        }
        else if (task.SubtaskMode == SubtaskMode.Individual && currentUserId.HasValue)
        {
            // Individuálny režim a PRIHLÁSENÝ používateľ: Filtrujeme podľa ID
            await EnsureIndividualInstancesExist(task, currentUserId.Value, UserContext.GetEmail());

            instancesToShow = await dbContext.Set<SubtaskInstanceEntity>()
                .Include(i => i.TemplateSubtask) // Tu môžeme includnuť šablónu, lebo ideme smerom "hore"
                .Where(i => i.TemplateSubtask.ParentTaskId == task.Id && i.AssignedToUserId == currentUserId.Value)
                .ToListAsync();
        }
        else // Shared Mode
        {
            // Zdieľaný režim: Všetci vidia všetky inštancie
            instancesToShow = task.Subtasks.SelectMany(s => s.Instances);
        }

        // 3. Projekcia Subtaskov
        var subtasksList = instancesToShow
            .AsQueryable()
            .ProjectTo<SubtaskCombinedListModel>(mapper.ConfigurationProvider)
            .ToList();

        // 4. Mapovanie a návrat
        var publicModelBase = mapper.Map<TaskPublicDetailModel>(task);
        var finalModel = publicModelBase with { Subtasks = subtasksList };

        return Result<TaskPublicDetailModel>.Success(finalModel);
    }

    public async Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId, string userEmail)
    {
        // 1. Skontrolujeme, či už existujú inštancie priradené priamo tomuto UserId
        var hasUserIdInstances = task.Subtasks.SelectMany(st => st.Instances)
            .Any(i => i.AssignedToUserId == userId);

        if (hasUserIdInstances) return;

        // 2. Skontrolujeme, či existujú inštancie priradené tomuto EMAILU (pozvánky)
        var emailInstances = await dbContext.Set<SubtaskInstanceEntity>()
            .Where(i => i.TemplateSubtask.ParentTaskId == task.Id && i.AssignedToEmail == userEmail)
            .ToListAsync();

        if (emailInstances.Any())
        {
            // Ak existujú, "adoptujeme" ich – priradíme im UserId
            foreach (var instance in emailInstances)
            {
                instance.AssignedToUserId = userId;
            }

            await dbContext.SaveChangesAsync();
            return;
        }

        // 3. Ak nie je ani jedno (náhodný prihlásený človek, čo nebol pozvaný), 
        // vytvoríme mu nové (tvoja pôvodná logika)
        var userResponseGroupId = Guid.NewGuid();
        foreach (var subtaskTemplate in task.Subtasks)
        {
            subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
            {
                ResponseGroupId = userResponseGroupId,
                AssignedToUserId = userId,
                IsCompleted = false
            });
        }

        await dbContext.SaveChangesAsync();
    }

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
                i.ResponseGroupId
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
                        CompletedCount = g.Count(x => x.IsCompleted)
                    }).ToList();

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalRespondents = userGroups.Count,
                    CompletedFull = userGroups.Count(u => u.CompletedCount == u.TotalCount && u.TotalCount > 0),
                    InProgress = userGroups.Count(u => u.CompletedCount > 0 && u.CompletedCount < u.TotalCount),
                    NotStarted = userGroups.Count(u => u.CompletedCount == 0),
                    GlobalProgress = userGroups.Count == 0
                        ? 0
                        : (double)userGroups
                            .Count(u => u.CompletedCount == u.TotalCount) / userGroups.Count * 100
                });
            }
            else // Shared Mode
            {
                int total = taskInstances.Count;
                int completed = taskInstances.Count(i => i.IsCompleted);

                results.Add(new TaskSummaryStats()
                {
                    TaskId = taskId,
                    Mode = mode,
                    TotalSubtasks = total,
                    CompletedSubtasks = completed,
                    GlobalProgress = total == 0 ? 0 : (double)completed / total * 100
                });
            }
        }

        return Result<List<TaskSummaryStats>>.Success(results);
        ;
    }
}