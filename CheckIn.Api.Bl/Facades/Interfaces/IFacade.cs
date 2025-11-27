using System.Linq.Expressions;
using CheckIn.Api.Common.Results;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>
{
	public Task<IQueryable<TListModel>> GetAsync(
		Expression<Func<TEntity, bool>>? filter = null,
		Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>>? orderBy = null,
		int pageNumber = 1,
		int pageSize = 10);

	public Task<IQueryable<TListModel>> GetListAsync(TQueryModel query);

	public Task<Result<TDetailModel>> GetByIdAsync(Guid id);
	public Task<Result<TDetailModel>> SaveCreateModelAsync(TCreateModel model);
	public Task<Result<TDetailModel>> SaveUpdateModelAsync(TUpdateModel model);
	public Task<Result<bool>> DeleteAsync(Guid entityId);
	public Task<Result<int>> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null);
}