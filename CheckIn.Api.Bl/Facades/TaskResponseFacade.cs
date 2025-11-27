using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Utils.Expressions;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class TaskResponseFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
	: FacadeBase<TaskResponseEntity, TaskResponseListModel,
		TaskResponseDetailModel, TaskResponseCreateModel,
		TaskResponseUpdateModel, TaskResponseListQuery>(dbContext, mapper, userContext), ITaskResponseFacade
{
	protected override Expression<Func<TaskResponseEntity, bool>> CreateFilter(TaskResponseListQuery query)
	{
		Expression<Func<TaskResponseEntity, bool>> filter = entity => true;

		if (query.TaskId.HasValue)
			filter = filter.And(entity => entity.TaskId == query.TaskId.Value);

		if (!string.IsNullOrEmpty(query.NameContains))
			filter = filter.And(entity => entity.RespondentName.ToLower().Contains(query.NameContains.ToLower()));

		if (!string.IsNullOrEmpty(query.CommentContains))
			filter = filter.And(entity => entity.Comment.ToLower().Contains(query.CommentContains.ToLower()));

		if (query.CreatedAfter.HasValue)
			filter = filter.And(entity => entity.SubmittedAt >= query.CreatedAfter.Value);

		return filter;
	}

	protected override Func<IQueryable<TaskResponseEntity>, IOrderedQueryable<TaskResponseEntity>> CreateOrderBy(
		TaskResponseListQuery query)
	{
		if (string.IsNullOrWhiteSpace(query.SortBy))
			return q => q.OrderByDescending(e => e.SubmittedAt);

		return query.SortBy.ToLower() switch
		{
			"respondentname" => query.SortDesc
				? q => q.OrderByDescending(e => e.RespondentName)
				: q => q.OrderBy(e => e.RespondentName),

			"submittedat" => query.SortDesc
				? q => q.OrderByDescending(e => e.SubmittedAt)
				: q => q.OrderBy(e => e.SubmittedAt),

			_ => q => q.OrderBy(e => e.Id)
		};
	}

	public async Task<TaskResponseDetailModel?> SaveResponseByHashAsync(string eventHash,
		TaskResponseDetailModel responseModel)
	{
		// Krok 1: Nájsť Task na základe Hashu (Musíme zabezpečiť, že udalosť existuje)
		var checkInEvent = await dbContext.CheckInEvents
			.FirstOrDefaultAsync(e => e.Hash == eventHash);

		if (checkInEvent == null)
		{
			// Ak udalosť s daným Hashom neexistuje, vrátime null
			return null;
		}

		// Krok 2: Namapovať DTO na Entitu
		// Vytvoríme novú entitu z DTO.
		var newResponseEntity = mapper.Map<TaskResponseEntity>(responseModel);

		// Krok 3: Nastaviť Cudzí kľúč (TaskId) na základe nájdeného ID udalosti
		newResponseEntity.TaskId = checkInEvent.Id;

		// Krok 4: Uložiť do databázy
		dbContext.CheckInResponses.Add(newResponseEntity);
		await dbContext.SaveChangesAsync();

		// Krok 5: Vrátiť namapovaný výsledok
		return mapper.Map<TaskResponseDetailModel>(newResponseEntity);
	}
}