using System.Linq.Expressions;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IFacade<TEntity, TListModel, TDetailModel>
{
	public Task<IQueryable<TListModel>> GetAsync(
		Expression<Func<TEntity, bool>>? filter = null,
		Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>>? orderBy = null,
		int pageNumber = 1,
		int pageSize = 10);

	public Task<TDetailModel?> GetByIdAsync(Guid id);
	public Task<TDetailModel> SaveAsync(TDetailModel model);
	public Task<bool> DeleteAsync(Guid entityId);
	public Task<int> GetCountAsync(Expression<Func<TEntity, bool>>? filter = null);
}