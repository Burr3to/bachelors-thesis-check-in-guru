using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Common.Utils.Expressions;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class TaskFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
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

	protected override void AddContextualData(TaskEntity entity, TaskCreateModel? createModel, TaskUpdateModel? updateModel)
	{
		if (createModel is not null)
		{
			entity.CreatedById = CurrentUserId;
			entity.State = TaskState.Todo;

			if (entity.Subtasks is null || !entity.Subtasks.Any())
			{
				entity.Subtasks.Add(new SubtaskTemplateEntity
				{
					Title = entity.Title,
					Description = entity.Notes,
					IsGeneratedFromTask = true
				});
			}

			// var assignedUsers = taskCreateModel.AssignedUserIds;

			foreach (var subtaskTemplate in entity.Subtasks)
			{
				if (entity.SubtaskMode == SubtaskMode.Shared)
				{
					// Typ 1: Vytvoríme 1 zdieľanú inštanciu
					subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
					{
						// TemplateSubtaskId bude nastavené automaticky EF Core, 
						// lebo používame navigačnú property subtaskTemplate.Instances.Add()
						AssignedToUserId = null,
						IsCompleted = false,
					});
				}
				else if (entity.SubtaskMode == SubtaskMode.Individual)
				{
				}
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

		try
		{
			await dbContext.Tasks.AddAsync(task);
			await dbContext.SaveChangesAsync();
		}
		catch (Exception ex)
		{
			return Result<TaskDetailModel>.Failure(ErrorType.InternalError, $"Failed to save task: {{ex.Message}}");
		}

		var createdTask = await GetByIdAsync(task.Id);

		return createdTask;
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

	// V TaskFacade.cs
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
			.Where(i => i.TemplateSubtask.ParentTaskId == taskId && i.TemplateSubtask.ParentTask.CreatedById == CurrentUserId)
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
			await EnsureIndividualInstancesExist(task, currentUserId.Value);

			task = await dbContext.Set<TaskEntity>()
				.Include(t => t.Subtasks).ThenInclude(st => st.Instances).ThenInclude(i => i.TemplateSubtask)
				.Where(t => t.Id == task.Id) // Použijeme existujúce ID Tasku
				.FirstOrDefaultAsync();

			// Ak sa Task nenašiel, vrátime chybu
			if (task == null) return Result<TaskPublicDetailModel>.Failure(ErrorType.InternalError, "Task lost after save.");
			// ****************

			instancesToShow = task.Subtasks.SelectMany(s => s.Instances)
				.Where(i => i.AssignedToUserId == currentUserId.Value);
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

	public async Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId)
	{
		// 1. Zistíme, či už má užívateľ nejaké inštancie
		bool instancesExist = task.Subtasks
			.SelectMany(st => st.Instances)
			.Any(i => i.AssignedToUserId == userId);

		if (instancesExist)
			return;

		// 2. Ak neexistujú, vytvoríme N inštancií
		foreach (var subtaskTemplate in task.Subtasks)
		{
			subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
			{
				AssignedToUserId = userId,
				IsCompleted = false
			});
		}

		await dbContext.SaveChangesAsync();
	}
}