using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using Microsoft.EntityFrameworkCore;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Results;


namespace CheckIn.Api.Bl.Facades;

public abstract class FacadeBase
	<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>(
		CheckInDbContext dbContext,
		IMapper mapper,
		IUserContext userContext)
	: IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>
	where TEntity : class, IEntity
	where TDetailModel : class, IEntityModel
	where TUpdateModel : class, IEntityModel
	where TCreateModel : class
	where TQueryModel : IPageableQuery
{
	protected abstract Expression<Func<TEntity, bool>> CreateFilter(TQueryModel query);
	protected abstract Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> CreateOrderBy(TQueryModel query);

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


	public async Task<IQueryable<TListModel>> GetListAsync(TQueryModel query)
	{
		var filter = CreateFilter(query);
		var orderBy = CreateOrderBy(query);

		return await GetAsync(filter, orderBy, query.PageNumber, query.PageSize);
	}

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

	public async Task<Result<TDetailModel>> GetByIdAsync(Guid id)
	{
		var model = await dbContext.Set<TEntity>()
			.Where(e => e.Id == id)
			.ProjectTo<TDetailModel>(mapper.ConfigurationProvider)
			.FirstOrDefaultAsync();

		if (model == null)
			return Result<TDetailModel>.NotFound($"Entity with ID {id} wasnt found.");

		return Result<TDetailModel>.Success(model);
	}

	public async Task<Result<int>> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null)
	{
		try
		{
			IQueryable<TEntity> query = dbContext.Set<TEntity>();
			if (filter != null)
				query = query.Where(filter);

			var count = await query.CountAsync();
			return Result<int>.Success(count);
		}
		catch (Exception ex)
		{
			return Result<int>.Failure(ErrorType.InternalError, $"Error counting entities: {ex.Message}");
		}
	}


	public async Task<Result<TDetailModel>> SaveCreateModelAsync(TCreateModel model)
	{
		var entity = mapper.Map<TEntity>(model);

		if (entity.Id == Guid.Empty)
			entity.Id = Guid.NewGuid();

		await dbContext.Set<TEntity>().AddAsync(entity);
		await dbContext.SaveChangesAsync();

		var detailModelResult = await GetByIdAsync(entity.Id);

		if (!detailModelResult.IsSuccess)
			return Result<TDetailModel>.Failure(ErrorType.InternalError,
				"Successfully created entity, but failed to retrieve details.");

		return detailModelResult;
	}


	public async Task<Result<TDetailModel>> SaveUpdateModelAsync(TUpdateModel model)
	{
		var id = model.Id;

		var entityToUpdate = await dbContext.Set<TEntity>().FindAsync(id);

		if (entityToUpdate == null)
			return Result<TDetailModel>.NotFound($"Entity with ID {id} not found for update.");

		mapper.Map(model, entityToUpdate);

		await dbContext.SaveChangesAsync();

		var detailModel = await GetByIdAsync(entityToUpdate.Id);

		if (detailModel.IsSuccess)
			return Result<TDetailModel>.Success(detailModel.Value!);

		return Result<TDetailModel>.Failure(ErrorType.InternalError, "Failed to retrieve detail after saving.");
	}


	public async Task<Result<bool>> DeleteAsync(Guid entityId)
	{
		TEntity entityToDelete = Activator.CreateInstance<TEntity>();
		entityToDelete.Id = entityId;

		// 2. Pripojíme ju ku kontextu a označíme ako odstránenú
		// (Aj keď entita neexistovala, toto ju pripraví na mazací dotaz)
		dbContext.Set<TEntity>().Attach(entityToDelete);
		dbContext.Set<TEntity>().Remove(entityToDelete);

		try
		{
			var affectedRows = await dbContext.SaveChangesAsync();

			if (affectedRows > 0)
			{
				return Result.Success();
			}
			else
			{
				return Result.NotFound($"Entita s ID {entityId} nebola nájdená na mazanie.");
			}
		}
		catch (DbUpdateConcurrencyException ex)
		{
			return Result.Failure(ErrorType.Conflict, $"Konflikt pri mazaní: {ex.Message}");
		}
		catch (Exception ex)
		{
			return Result.Failure(ErrorType.InternalError, $"Neočakávaná chyba: {ex.Message}");
		}
	}
}