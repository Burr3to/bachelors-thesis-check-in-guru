using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Dal;

public class CheckInDbContext(DbContextOptions<CheckInDbContext> options) : DbContext(options)
{
	public DbSet<CheckInEventEntity> CheckInEvent { get; set; }
	public DbSet<CheckInResponseEntity> CheckInResponse { get; set; }
	public DbSet<UserEntity> User { get; set; }
}