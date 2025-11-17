using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public abstract class FacadeBase
	<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel>(CheckInDbContext dbContext, IMapper mapper)
	: IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel>
	where TEntity : class, IEntity
	where TDetailModel : class, IEntityModel
	where TUpdateModel : class, IEntityModel
	where TCreateModel : class
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
	public async Task<IQueryable<TListModel>> GetAsync(Expression<Func<TEntity, bool>>? filter = null,
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

	public async Task<TDetailModel> SaveCreateModelAsync(TCreateModel model)
	{
		// 1. Mapovanie: TCreateModel -> TEntity
		var entity = mapper.Map<TEntity>(model);

		// 2. Kontrola a pridanie (ID sa automaticky priradí v DB/EF Core,
		// ale v entite ho môžeme nastaviť na Guid.NewGuid())

		dbContext.Set<TEntity>().Add(entity);
		await dbContext.SaveChangesAsync();

		// 3. Mapovanie späť: TEntity -> TDetailModel (aby sme dostali priradené ID, CreatedAt atď.)
		var detailModel = mapper.Map<TDetailModel>(entity);
		return detailModel;
	}

	public async Task<TDetailModel> SaveUpdateModelAsync(TUpdateModel model)
	{
		// 1. Získanie ID z TUpdateModel
		var idProperty = model.GetType().GetProperty("Id");
		var idValue = (Guid)(idProperty?.GetValue(model) ??
		                     throw new InvalidOperationException("Update Model must have an Id property."));

		// 2. Načítanie existujúcej entity (bez sledovania - AsNoTracking, ak je to potrebné)
		var existingEntity = await dbContext.Set<TEntity>().AsNoTracking().FirstOrDefaultAsync(e => e.Id == idValue);

		if (existingEntity == null)
		{
			throw new InvalidOperationException($"Entity with ID {idValue} not found for update.");
		}

		// 3. Mapovanie z TUpdateModel na existujúcu TEntity
		// Mapujeme len tie polia, ktoré sú v TUpdateModel.
		mapper.Map(model, existingEntity);

		// 4. Pripojenie a označenie ako Modifikované
		dbContext.Set<TEntity>().Attach(existingEntity);
		dbContext.Entry(existingEntity).State = EntityState.Modified;

		await dbContext.SaveChangesAsync();

		// 5. Mapovanie späť: TEntity -> TDetailModel (pre návrat)
		var detailModel = mapper.Map<TDetailModel>(existingEntity);
		return detailModel;
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