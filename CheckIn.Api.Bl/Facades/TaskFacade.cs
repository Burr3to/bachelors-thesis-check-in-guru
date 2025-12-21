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
using TaskStatus = CheckIn.Api.Common.Enums.TaskStatus;

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
			filter = filter.And(entity => entity.Status == query.Status.Value);

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
			entity.Status = TaskStatus.Todo;

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
					// Typ 2: Vytvoríme N inštancií pre každého pozvaného
					/*
					foreach (var userId in assignedUsers)
					{
						subtaskTemplate.Instances.Add(new SubtaskInstanceEntity
						{
							AssignedToUserId = userId,
							IsCompleted = false
						});
					}
					*/
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

	public async Task<Result<List<SubtaskCombinedListModel>>> GetSubTasksForTask(Guid taskId)
	{
		var currentUserId = CurrentUserId; // Vyhodí Unauthorized, ak nie je prihlásený

		// 1. Zabezpečenie prístupu: Načítať inštancie, ktoré patria danému tasku.
		// POZOR: Musíme načítať Task, aby sme vedeli, či je shared alebo individual.

		// Načítame všetky šablóny a ich inštancie pre daný Task
		var task = await dbContext.Set<TaskEntity>()
			.Include(t => t.Subtasks)
			.ThenInclude(st => st.Instances)
			// ODSTRÁNILI SME: .ThenInclude(i => i.TemplateSubtask) 
			// Táto navigácia je redundantná a spôsobovala chybu.
			.Where(t => t.Id == taskId && t.CreatedById == currentUserId)
			.FirstOrDefaultAsync();

		if (task == null)
		{
			return Result<List<SubtaskCombinedListModel>>.NotFound($"Task with ID {taskId} was not found or access denied.");
		}

		// 2. Filtrácia Inštancií na základe Režimu (Biznis Logika)

		// Zoznam SubtaskInstance entít, ktoré má user vidieť:
		IEnumerable<SubtaskInstanceEntity> instancesToShow;

		if (task.SubtaskMode == SubtaskMode.Shared)
		{
			// Všetky inštancie (bude len 1 inštancia na šablónu s AssignedToUserId=null)
			instancesToShow = task.Subtasks.SelectMany(s => s.Instances);
		}
		else // Individual
		{
			// Len inštancie priradené aktuálnemu používateľovi
			instancesToShow = task.Subtasks.SelectMany(s => s.Instances)
				.Where(i => i.AssignedToUserId == currentUserId);
		}

		// 3. Projekcia na DTO
		// Musíme konvertovať instancesToShow (Entity) na ListModel (DTO)

		// POZOR: Musíte použiť LINQ in memory (.ToList() pred mapovaním) 
		// alebo zložitý dotaz v EF Core, aby sa dáta spojili.

		// Pre jednoduchosť a výkon (ak už dáta máme):
		var subtasksList = instancesToShow
			.AsQueryable()
			.ProjectTo<SubtaskCombinedListModel>(mapper.ConfigurationProvider) // Používame nový model
			.ToList();

		return Result<List<SubtaskCombinedListModel>>.Success(subtasksList);
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

		IEnumerable<SubtaskInstanceEntity> instancesToShow;

		// 2. Filtrácia inštancií
		if (task.SubtaskMode == SubtaskMode.Individual && !currentUserId.HasValue)
		{
			// Individuálny režim a ANONYMNÝ používateľ: Vrátime len Task Detail, ale bez Subtaskov.
			var publicModel = mapper.Map<TaskPublicDetailModel>(task);
			publicModel = publicModel with { Subtasks = new List<SubtaskCombinedListModel>() };

			return Result<TaskPublicDetailModel>.Success(publicModel);
		}
		else if (task.SubtaskMode == SubtaskMode.Individual && currentUserId.HasValue)
		{
			// Individuálny režim a PRIHLÁSENÝ používateľ: Filtrujeme podľa ID
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
}