using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using Microsoft.EntityFrameworkCore;
using CheckIn.Api.Common.Results;

namespace CheckIn.Api.Bl.Facades;

/// <summary>
/// Base implementation of a Business Logic facade providing common database operations.
/// </summary>
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
    /// <summary>
    /// Creates a basic filtering expression for the entity query.
    /// </summary>
    protected virtual Expression<Func<TEntity, bool>> CreateFilter(TQueryModel query)
    {
        return entity => true;
    }

    /// <summary>
    /// Defines the ordering logic for the query results.
    /// </summary>
    protected abstract Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> CreateOrderBy(TQueryModel query);

    /// <summary>
    /// Allows injecting additional contextual data (e.g., owner ID) into the entity before saving.
    /// </summary>
    protected virtual void AddContextualData(TEntity entity, TCreateModel? createModel, TUpdateModel? updateModel)
    {
    }

    protected readonly IUserContext UserContext = userContext;

    /// <summary>
    /// Retrieves the user ID if the user is authenticated.
    /// </summary>
    protected Guid? OptionalUserId => UserContext.GetUserId();

    /// <summary>
    /// Retrieves the user ID or throws an exception if the user is not authenticated.
    /// </summary>
    protected Guid CurrentUserId
    {
        get
        {
            var userId = OptionalUserId;
            if (userId == null)
                throw new UnauthorizedAccessException(
                    "User is not authenticated or user ID is missing for required operation.");

            return userId.Value;
        }
    }

    /// <summary>
    /// Fetches a paginated, filtered, and ordered list of models.
    /// </summary>
    public async Task<Result<QueryResult<TListModel>>> GetListAsync(TQueryModel query)
    {
        IQueryable<TEntity> queryable = dbContext.Set<TEntity>();

        try
        {
            // Apply custom filter
            var filter = CreateFilter(query);
            queryable = queryable.Where(filter);

            // Count total items before applying pagination
            var totalCount = await queryable.CountAsync();

            // Apply sorting
            var orderBy = CreateOrderBy(query);
            queryable = orderBy(queryable);

            // Apply pagination (Skip/Take)
            queryable = queryable
                .Skip((query.PageNumber - 1) * query.PageSize)
                .Take(query.PageSize);

            // Map directly to List Model and execute query
            var listModels = await mapper
                .ProjectTo<TListModel>(queryable, mapper.ConfigurationProvider)
                .ToListAsync();

            var result = new QueryResult<TListModel>
            {
                Items = listModels,
                TotalCount = totalCount,
                PageNumber = query.PageNumber,
                PageSize = query.PageSize
            };

            return Result<QueryResult<TListModel>>.Success(result);
        }
        catch (Exception ex)
        {
            return Result<QueryResult<TListModel>>.Failure(ErrorType.InternalError,
                $"Error during list retrieval: {ex.Message}");
        }
    }

    /// <summary>
    /// Finds a single entity and returns its detailed model view.
    /// </summary>
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

    /// <summary>
    /// Counts how many entities exist based on an optional filter.
    /// </summary>
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

    /// <summary>
    /// Maps a create model to a new entity and saves it to the database.
    /// </summary>
    public virtual async Task<Result<TDetailModel>> SaveCreateModelAsync(TCreateModel model)
    {
        var entity = mapper.Map<TEntity>(model);

        // Add logic-specific data (e.g., CreatorId)
        AddContextualData(entity, model, default);

        // Ensure a new ID is assigned if not provided
        if (entity.Id == Guid.Empty)
            entity.Id = Guid.NewGuid();

        await dbContext.Set<TEntity>().AddAsync(entity);
        await dbContext.SaveChangesAsync();

        // Return the detail model of the newly created entity
        var detailModelResult = await GetByIdAsync(entity.Id);

        if (!detailModelResult.IsSuccess)
            return Result<TDetailModel>.Failure(ErrorType.InternalError,
                "Successfully created entity, but failed to retrieve details.");

        return detailModelResult;
    }

    /// <summary>
    /// Updates an existing entity with data from the update model.
    /// </summary>
    public virtual async Task<Result<TDetailModel>> SaveUpdateModelAsync(TUpdateModel model)
    {
        var id = model.Id;
        var entityToUpdate = await dbContext.Set<TEntity>().FindAsync(id);

        if (entityToUpdate == null)
            return Result<TDetailModel>.NotFound($"Entity with ID {id} not found for update.");

        // Map updated properties onto the existing tracked entity
        mapper.Map(model, entityToUpdate);

        await dbContext.SaveChangesAsync();

        // Refresh data and return details
        var detailModel = await GetByIdAsync(entityToUpdate.Id);

        if (detailModel.IsSuccess)
            return Result<TDetailModel>.Success(detailModel.Value!);

        return Result<TDetailModel>.Failure(ErrorType.InternalError, "Failed to retrieve detail after saving.");
    }

    /// <summary>
    /// Deletes an entity from the database.
    /// </summary>
    public async Task<Result<bool>> DeleteAsync(Guid entityId)
    {
        // Create a stub entity to avoid unnecessary SELECT before DELETE
        TEntity entityToDelete = Activator.CreateInstance<TEntity>();
        entityToDelete.Id = entityId;

        // Attach and mark for removal
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
                return Result.NotFound($"Entity with ID {entityId} was not found for deletion.");
            }
        }
        catch (DbUpdateConcurrencyException ex)
        {
            return Result.Failure(ErrorType.Conflict, $"Conflict during deletion: {ex.Message}");
        }
        catch (Exception ex)
        {
            return Result.Failure(ErrorType.InternalError, $"Unexpected error: {ex.Message}");
        }
    }
}