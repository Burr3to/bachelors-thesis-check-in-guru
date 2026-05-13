using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace CheckIn.Api.Dal.Installers;

/// <summary>
/// Handles the registration of Data Access Layer (DAL) services into the dependency injection container.
/// </summary>
public class ApiDalInstaller
{
    /// <summary>
    /// Configures and adds the database context to the application services.
    /// </summary>
    /// <param name="services">The service collection to register into.</param>
    /// <param name="connectionString">The PostgreSQL connection string.</param>
    public static void Install(IServiceCollection services, string connectionString)
    {
        // Configure EF Core to use PostgreSQL with the provided connection string
        services.AddDbContext<CheckInDbContext>(options => { options.UseNpgsql(connectionString); });
    }
}