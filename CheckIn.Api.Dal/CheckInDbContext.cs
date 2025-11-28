using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal;

public class CheckInDbContext(DbContextOptions<CheckInDbContext> options)
	: IdentityDbContext<IdentityUser, IdentityRole, string>(options)
{
	public DbSet<TaskEntity> Tasks { get; set; }
	public DbSet<TaskResponseEntity> TaskResponses { get; set; }
	public new DbSet<UserEntity> Users { get; set; }
	public DbSet<RefreshToken> RefreshTokens { get; set; }
}