using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace CheckIn.Api.Dal;

public class CheckInDbContextFactory : IDesignTimeDbContextFactory<CheckInDbContext>
{
	public CheckInDbContext CreateDbContext(string[] args)
	{
		var basePath = Path.Combine(Directory.GetCurrentDirectory(), "../CheckIn.Api.App");

		if (!Directory.Exists(basePath))
		{
			// Fallback, ak spúšťaš z iného miesta
			basePath = Directory.GetCurrentDirectory();
		}

		// 1. Manuálne vytvorenie konfigurácie pre Design Time
		IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(basePath)
			.AddJsonFile("appsettings.json", optional: true)
			.AddJsonFile("appsettings.Development.json", optional: true)
			.Build();

		var connectionString = configuration.GetConnectionString("DefaultConnection");
		if (string.IsNullOrEmpty(connectionString))
		{
			throw new InvalidOperationException(
				"Connection string 'DefaultConnection' not found.");
		}

		var optionsBuilder = new DbContextOptionsBuilder<CheckInDbContext>();
		optionsBuilder.UseNpgsql(connectionString);

		return new CheckInDbContext(optionsBuilder.Options);
	}
}