using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public abstract class FacadeBase
	<TEntity, TListModel, TDetailModel>(CheckInDbContext dbContext, IMapper mapper)
	: IFacade<TEntity, TListModel, TDetailModel>
	where TEntity : class, IEntity
	where TDetailModel : class, IEntityModel
{
	/// <summary>
	/// Return all filtered and ordered detailModel entities with 
	/// </summary>
	/// <param name="filter"></param>   p => p.Price > 100
	/// <param name="orderBy"></param>  query => query.OrderBy(p => p.Name)
	/// <param name="pageSize"></param>
	/// <param name="pageNumber"></param>
	/// navigation attributes of required entity
	/// <returns></returns>
	public async Task<IQueryable<TListModel>> GetAsync(
		Expression<Func<TEntity, bool>>? filter = null,
		Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>>? orderBy = null,
		int pageNumber = 1,
		int pageSize = 10)
	{
		// Access to DbSet
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

		IQueryable<TListModel> queryResult = mapper.ProjectTo<TListModel>(query);

		return queryResult;
	}

	public async Task<TDetailModel?> GetByIdAsync(Guid id)
	{
		IQueryable<TEntity> query = dbContext.Set<TEntity>();
		var projectedQuery = mapper.ProjectTo<TDetailModel>(query);
		return await projectedQuery.FirstOrDefaultAsync(e => e.Id == id);
	}

	/// <summary>
	/// Direct access to db only with one query
	/// </summary>
	/// <param name="model"></param>
	/// <returns></returns>
	public async Task<TDetailModel> SaveAsync(TDetailModel model)
	{
		var entity = mapper.Map<TEntity>(model);

		var idProperty = entity.GetType().GetProperty("Id");

		var idValue = (Guid)(idProperty?.GetValue(entity) ?? throw new InvalidOperationException());

		if (idValue == Guid.Empty)
		{
			dbContext.Set<TEntity>().Add(entity);
		}
		else
		{
			dbContext.Set<TEntity>().Update(entity);
		}

		await dbContext.SaveChangesAsync();

		mapper.Map(entity, model);

		return model;
	}

	public async Task<bool> DeleteAsync(Guid entityId)
	{
		TEntity? entity = await dbContext.Set<TEntity>().FindAsync(entityId);
		if (entity != null)
		{
			dbContext.Remove(entity);
			await dbContext.SaveChangesAsync();
		}
		else
			return false;

		return true;
	}

	public async Task<int> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null)
	{
		IQueryable<TEntity> query = dbContext.Set<TEntity>();
		if (filter != null)
			query = query.Where(filter);
		return await query.CountAsync();
	}
}