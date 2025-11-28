using System.Linq.Expressions;
using CheckIn.Api.Common.Results;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>
{
	Task<Result<QueryResult<TListModel>>> GetListAsync(TQueryModel query);
	public Task<Result<TDetailModel>> GetByIdAsync(Guid id);
	public Task<Result<TDetailModel>> SaveCreateModelAsync(TCreateModel model);
	public Task<Result<TDetailModel>> SaveUpdateModelAsync(TUpdateModel model);
	public Task<Result<bool>> DeleteAsync(Guid entityId);
	public Task<Result<int>> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null);
}