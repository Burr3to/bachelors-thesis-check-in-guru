using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class UserFacade(CheckInDbContext dbContext, IMapper mapper) : IUserFacade
{
	public async Task<UserDetailModel> SaveAsync(Guid identityUserId, string googleId, string email, string name)
	{
		var user = await dbContext.Users
			.FirstOrDefaultAsync(u => u.Id == identityUserId);

		if (user == null)
		{
			// Vytvorenie (použije ID z IdentityUser)
			user = new UserEntity { Id = identityUserId, GoogleId = googleId, Email = email, Name = name };
			dbContext.Users.Add(user);
		}
		else
		{
			// Aktualizácia  mena a Google ID (aksa zmenili na Google účte)
			user.Name = name;
			user.GoogleId = googleId;
			user.Email = email; // (hoci email by sa nemal meniť, ak je to kľúč)
			dbContext.Entry(user).State = EntityState.Modified;
		}

		await dbContext.SaveChangesAsync();
		return mapper.Map<UserDetailModel>(user);
	}
	
	public async Task<UserEntity> GetOrCreateUserAsync(string googleId, string email, string name)
	{
		// 1. Skúsime nájsť existujúceho používateľa podľa GoogleId
		var user = await dbContext.Users
			.FirstOrDefaultAsync(u => u.GoogleId == googleId);

		if (user != null)
		{
			return user;
		}

		// 2. Používateľ neexistuje, vytvoríme novú entitu
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

	public async Task<UserDetailModel?> GetByIdAsync(Guid id)
	{
		var user = await dbContext.Users
			.AsNoTracking()
			.FirstOrDefaultAsync(u => u.Id == id);

		return user == null ? null : mapper.Map<UserDetailModel>(user);
	}

	public Task<IEnumerable<UserListModel>> GetAsync(Expression<Func<UserEntity, bool>>? filter,
		Func<IQueryable<UserEntity>, IOrderedQueryable<UserEntity>>? orderBy, int pageNumber, int pageSize)
	{
		throw new NotImplementedException();
	}
}