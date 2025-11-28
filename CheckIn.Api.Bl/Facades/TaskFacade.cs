using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
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
		if (createModel != null)
		{
			entity.CreatedById = CurrentUserId;
			entity.Status = TaskStatus.Todo;
		}
	}
}