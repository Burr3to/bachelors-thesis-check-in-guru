using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

/// <summary>
/// Facade implementation for handling user entity operations and synchronization with Google/Identity information.
/// </summary>
public class UserFacade(CheckInDbContext dbContext, IMapper mapper) : IUserFacade
{
    /// <summary>
    /// Synchronizes external identity data with the local database. 
    /// If the user exists, updates their profile; otherwise, creates a new record.
    /// </summary>
    public async Task<UserDetailModel> SaveAsync(Guid identityUserId, string googleId, string email, string name)
    {
        var user = await dbContext.Users
            .FirstOrDefaultAsync(u => u.Id == identityUserId);

        if (user == null)
        {
            // Create a new user using the ID provided by the Identity system
            user = new UserEntity { Id = identityUserId, GoogleId = googleId, Email = email, Name = name };
            dbContext.Users.Add(user);
        }
        else
        {
            // Update existing user details if they changed in the Google account
            user.Name = name;
            user.GoogleId = googleId;
            user.Email = email;
            dbContext.Entry(user).State = EntityState.Modified;
        }

        await dbContext.SaveChangesAsync();
        return mapper.Map<UserDetailModel>(user);
    }

    /// <summary>
    /// Ensures a user record exists based on a Google ID.
    /// </summary>
    public async Task<UserEntity> GetOrCreateUserAsync(string googleId, string email, string name)
    {
        // Try to find the existing user by Google identifier
        var user = await dbContext.Users
            .FirstOrDefaultAsync(u => u.GoogleId == googleId);

        if (user != null)
        {
            return user;
        }

        // Create a new user entity if not found
        user = new UserEntity
        {
            Id = Guid.NewGuid(),
            GoogleId = googleId,
            Email = email,
            Name = name,
        };

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync();

        return user;
    }

    /// <summary>
    /// Fetches a user record by primary key without tracking changes.
    /// </summary>
    public async Task<UserDetailModel?> GetByIdAsync(Guid id)
    {
        var user = await dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == id);

        return user == null ? null : mapper.Map<UserDetailModel>(user);
    }

    /// <summary>
    /// Placeholder for listing users with custom filters and pagination.
    /// </summary>
    public Task<IEnumerable<UserListModel>> GetAsync(Expression<Func<UserEntity, bool>>? filter,
        Func<IQueryable<UserEntity>, IOrderedQueryable<UserEntity>>? orderBy, int pageNumber, int pageSize)
    {
        throw new NotImplementedException();
    }
}