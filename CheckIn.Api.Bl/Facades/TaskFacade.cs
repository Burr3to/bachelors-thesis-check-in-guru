using System.Linq.Expressions;
using AutoMapper;
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
}