using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public abstract class FacadeBase
	<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel>(
		CheckInDbContext dbContext,
		IMapper mapper,
		IUserContext userContext)
	: IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel>
	where TEntity : class, IEntity
	where TDetailModel : class, IEntityModel
	where TUpdateModel : class, IEntityModel
	where TCreateModel : class
{
	protected readonly IUserContext UserContext = userContext;

	protected Guid CurrentUserId
	{
		get
		{
			var userId = UserContext.GetUserId();
			if (userId == null)
				throw new UnauthorizedAccessException("User is not authenticated or user ID is missing for required operation.");

			return userId.Value;
		}
	}

	protected Guid? OptionalUserId => UserContext.GetUserId();

	public async Task<IQueryable<TListModel>> GetAsync(
		Expression<Func<TEntity, bool>>? filter = null,
		Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>>? orderBy = null,
		int pageNumber = 1,
		int pageSize = 10)
	{
		IQueryable<TEntity> query = dbContext.Set<TEntity>();

		if (filter != null)
			query = query.Where(filter);

		if (orderBy != null)
			query = orderBy(query);
		else
			query = query.OrderBy(l => l.Id);

		query = query
			.Skip((pageNumber - 1) * pageSize)
			.Take(pageSize);

		IQueryable<TListModel> queryResult = mapper.ProjectTo<TListModel>(query, mapper.ConfigurationProvider);

		return queryResult;
	}

	public async Task<TDetailModel?> GetByIdAsync(Guid id)
	{
		return await dbContext.Set<TEntity>()
			.Where(e => e.Id == id)
			.ProjectTo<TDetailModel>(mapper.ConfigurationProvider)
			.FirstOrDefaultAsync();
	}

	public async Task<int> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null)
	{
		IQueryable<TEntity> query = dbContext.Set<TEntity>();
		if (filter != null)
			query = query.Where(filter);
		return await query.CountAsync();
	}


	public async Task<TDetailModel> SaveCreateModelAsync(TCreateModel model)
	{
		var entity = mapper.Map<TEntity>(model);

		if (entity.Id == Guid.Empty)
		{
			entity.Id = Guid.NewGuid();
		}

		await dbContext.Set<TEntity>().AddAsync(entity);
		await dbContext.SaveChangesAsync();

		var detailModel = await GetByIdAsync(entity.Id);

		if (detailModel == null)
			throw new InvalidOperationException($"Failed to retrieve entity with ID {entity.Id} " +
			                                    $"immediately after creation.");

		return detailModel;
	}


	public async Task<TDetailModel> SaveUpdateModelAsync(TUpdateModel model)
	{
		var id = model.Id;

		var entityToUpdate = await dbContext.Set<TEntity>().FindAsync(id);

		if (entityToUpdate == null)
			throw new KeyNotFoundException($"Entity with ID {id} not found for update.");

		mapper.Map(model, entityToUpdate);

		await dbContext.SaveChangesAsync();

		var detailModel = await GetByIdAsync(entityToUpdate.Id);

		if (detailModel == null)
			throw new InvalidOperationException(
				$"Failed to retrieve entity with ID {entityToUpdate.Id} immediately after update.");

		return detailModel;
	}


	public async Task<bool> DeleteAsync(Guid entityId)
	{
		TEntity? entityToDelete = dbContext.Set<TEntity>().Local.FirstOrDefault(e => e.Id == entityId);

		if (entityToDelete == null)
		{
			entityToDelete = Activator.CreateInstance<TEntity>();
			entityToDelete.Id = entityId;
			dbContext.Set<TEntity>().Attach(entityToDelete);
		}

		dbContext.Set<TEntity>().Remove(entityToDelete);

		try
		{
			var affectedRows = await dbContext.SaveChangesAsync();
			return affectedRows > 0;
		}
		catch (DbUpdateConcurrencyException)
		{
			return false;
		}
	}
}