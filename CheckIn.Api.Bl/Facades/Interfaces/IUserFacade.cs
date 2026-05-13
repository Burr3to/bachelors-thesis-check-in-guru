using System.Linq.Expressions;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Interface for managing user-related data, synchronization with external identity providers, and profile retrieval.
/// </summary>
public interface IUserFacade
{
    /// <summary>
    /// Saves or updates user profile data linked to an Identity provider ID.
    /// </summary>
    Task<UserDetailModel> SaveAsync(Guid identityUserId, string googleId, string email, string name);

    /// <summary>
    /// Retrieves a user by their unique Google ID or creates a new database record if they do not exist.
    /// </summary>
    Task<UserEntity> GetOrCreateUserAsync(string googleId, string email, string name);

    /// <summary>
    /// Retrieves a specific user profile by their unique identifier.
    /// </summary>
    Task<UserDetailModel?> GetByIdAsync(Guid id);

    /// <summary>
    /// Retrieves a paginated and filtered list of users.
    /// </summary>
    Task<IEnumerable<UserListModel>> GetAsync(Expression<Func<UserEntity, bool>>? filter,
        Func<IQueryable<UserEntity>, IOrderedQueryable<UserEntity>>? orderBy,
        int pageNumber, int pageSize);
}