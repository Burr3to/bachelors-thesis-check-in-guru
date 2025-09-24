using Microsoft.EntityFrameworkCore;


namespace CheckIn.Api.Dal;

public class CheckInDbContext(DbContextOptions<CheckInDbContext> options) : DbContext(options)
{
	//    public DbSet<Entity> name { get; set; }
}