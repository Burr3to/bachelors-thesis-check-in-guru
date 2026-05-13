using CheckIn.Api.Bl.Facades;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace CheckIn.Api.Bl.Installers;

/// <summary>
/// Handles the registration of Business Logic (BL) layer services and facades into the dependency injection container.
/// </summary>
public static class ApiBlInstaller
{
    /// <summary>
    /// Registers facades and business services required for the API.
    /// </summary>
    public static void Install(IServiceCollection serviceCollection)
    {
        // Explicitly register the UserFacade
        serviceCollection.AddScoped<IUserFacade, UserFacade>();

        // Automatically scan the assembly and register all classes that implement the generic IFacade interface
        serviceCollection.Scan(selector =>
            selector.FromAssemblyOf<UserFacade>()
                .AddClasses(classes => classes.AssignableTo(typeof(IFacade<,,,,,>)))
                .AsSelfWithInterfaces()
                .WithScopedLifetime());

        // Register the email communication service
        serviceCollection.AddScoped<IEmailService, EmailService>();
    }
}