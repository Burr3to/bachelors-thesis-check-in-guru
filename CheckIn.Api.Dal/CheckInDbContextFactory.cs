/*
------------------------------------------------
This file was made by Gemini
------------------------------------------------
*/

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace CheckIn.Api.Dal;

/// <summary>
/// Factory used by EF Core Design-time tools (migrations) to instantiate the DbContext.
/// </summary>
public class CheckInDbContextFactory : IDesignTimeDbContextFactory<CheckInDbContext>
{
    /// <summary>
    /// Creates a new instance of the DbContext using settings from the App project.
    /// </summary>
    public CheckInDbContext CreateDbContext(string[] args)
    {
        var basePath = Path.Combine(Directory.GetCurrentDirectory(), "../CheckIn.Api.App");

        // Fallback if the factory is executed from within the project directory itself
        if (!Directory.Exists(basePath))
        {
            basePath = Directory.GetCurrentDirectory();
        }

        // Load configuration from the main API project to access the connection string
        IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(basePath)
            .AddJsonFile("appsettings.json", optional: true)
            .AddJsonFile("appsettings.Development.json", optional: true)
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection");
        if (string.IsNullOrEmpty(connectionString))
        {
            throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        var optionsBuilder = new DbContextOptionsBuilder<CheckInDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new CheckInDbContext(optionsBuilder.Options);
    }
}