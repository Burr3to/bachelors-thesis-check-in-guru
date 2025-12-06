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
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class SubtaskInstanceFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
	: FacadeBase<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
			SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
		(dbContext, mapper, userContext), ISubtaskInstanceFacade
{
	protected override Expression<Func<SubtaskInstanceEntity, bool>> CreateFilter(SubtaskInstanceQuery query)
	{
		Expression<Func<SubtaskInstanceEntity, bool>> filter = entity => true;
		// Ak SubtaskTemplateQuery obsahuje ParentTaskId:
		// if (query.ParentTaskId.HasValue) 
		//     filter = filter.And(e => e.ParentTaskId == query.ParentTaskId.Value);

		return filter;
	}

	protected override Func<IQueryable<SubtaskInstanceEntity>, IOrderedQueryable<SubtaskInstanceEntity>> CreateOrderBy(
		SubtaskInstanceQuery query)
	{
		return q => q.OrderBy(e => e.Id);
	}

	public async Task<Result<bool>> CompleteAsync(Guid instanceId)
	{
		var instance = await dbContext.Set<SubtaskInstanceEntity>()
			.Include(i => i.TemplateSubtask) // Načítame šablónu
			.ThenInclude(t => t.ParentTask) // A Task (aby sme zistili RequiresAuth)
			.FirstOrDefaultAsync(i => i.Id == instanceId);

		if (instance == null)
			return Result.NotFound($"Subtask instance with ID {instanceId} not found.");

		var task = instance.TemplateSubtask?.ParentTask;
		if (task == null)
			return Result.Failure(ErrorType.InternalError, "Parent Task structure missing.");

		var currentUserId = OptionalUserId;

		if (task.RequiresAuthenticationToComplete && currentUserId == null)
		{
			return Result.Unauthorized("Authentication is required to complete this task.");
		}

		// Kontrola, či je to splnenie pre PRIRADENÉHO užívateľa (Typ 2)
		if (instance.AssignedToUserId.HasValue)
		{
			if (currentUserId == null || instance.AssignedToUserId.Value != currentUserId.Value)
			{
				return Result.Forbidden("You are not authorized to complete this specific subtask instance.");
			}
		}

		// Ak už je splnené, vrátime úspech
		if (instance.IsCompleted)
			return Result.Success();

		// 4. Spracovanie splnenia
		if (!instance.IsCompleted)
		{
			instance.IsCompleted = true;
			instance.CompletedByUserId = currentUserId;
			instance.CompletedAt = DateTime.UtcNow;

			await dbContext.SaveChangesAsync();
		}

		try
		{
			await dbContext.SaveChangesAsync();
			return Result.Success();
		}
		catch (Exception ex)
		{
			return Result.Failure(ErrorType.InternalError, $"Failed to complete subtask: {ex.Message}");
		}
	}
}