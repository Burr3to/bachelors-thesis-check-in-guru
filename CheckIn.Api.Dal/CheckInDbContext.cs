using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal;

public class CheckInDbContext(DbContextOptions<CheckInDbContext> options)
	: IdentityDbContext<IdentityUser, IdentityRole, string>(options)
{
	public DbSet<CheckInEventEntity> CheckInEvent { get; set; }
	public DbSet<CheckInResponseEntity> CheckInResponse { get; set; }
	public DbSet<UserEntity> User { get; set; }
}