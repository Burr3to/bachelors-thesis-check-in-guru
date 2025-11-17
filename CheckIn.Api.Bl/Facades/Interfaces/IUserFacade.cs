using System.Linq.Expressions;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface IUserFacade
{
	Task<UserDetailModel> SaveAsync(Guid identityUserId, string googleId, string email, string name);

	Task<UserEntity> GetOrCreateUserAsync(string googleId, string email, string name);

	Task<UserDetailModel?> GetByIdAsync(Guid id);

	Task<IEnumerable<UserListModel>> GetAsync(Expression<Func<UserEntity, bool>>? filter,
		Func<IQueryable<UserEntity>, IOrderedQueryable<UserEntity>>? orderBy,
		int pageNumber, int pageSize);
}