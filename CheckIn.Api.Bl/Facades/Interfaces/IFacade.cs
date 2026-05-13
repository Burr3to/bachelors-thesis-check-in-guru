using System.Linq.Expressions;
using CheckIn.Api.Common.Results;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Generic interface for Business Logic facades, defining standard CRUD and query operations.
/// </summary>
public interface IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>
{
    /// <summary>
    /// Retrieves a paginated list of models based on the provided query parameters.
    /// </summary>
    Task<Result<QueryResult<TListModel>>> GetListAsync(TQueryModel query);

    /// <summary>
    /// Retrieves a detailed model of a specific entity by its unique identifier.
    /// </summary>
    public Task<Result<TDetailModel>> GetByIdAsync(Guid id);

    /// <summary>
    /// Creates a new entity from the provided creation model.
    /// </summary>
    public Task<Result<TDetailModel>> SaveCreateModelAsync(TCreateModel model);

    /// <summary>
    /// Updates an existing entity using the data from the update model.
    /// </summary>
    public Task<Result<TDetailModel>> SaveUpdateModelAsync(TUpdateModel model);

    /// <summary>
    /// Deletes an entity from the database by its unique identifier.
    /// </summary>
    public Task<Result<bool>> DeleteAsync(Guid entityId);

    /// <summary>
    /// Gets the total count of entities that match the optional filter.
    /// </summary>
    public Task<Result<int>> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null);
}