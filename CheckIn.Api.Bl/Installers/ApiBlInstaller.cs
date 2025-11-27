using CheckIn.Api.Bl.Facades;
using CheckIn.Api.Bl.Facades.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace CheckIn.Api.Bl.Installers;

public static class ApiBlInstaller
{
	public static void Install(IServiceCollection serviceCollection)
	{
		serviceCollection.AddScoped<IUserFacade, UserFacade>();

		serviceCollection.Scan(selector =>
			selector.FromAssemblyOf<UserFacade>()
				.AddClasses(classes => classes.AssignableTo(typeof(IFacade<,,,,,>)))
				.AsSelfWithInterfaces()
				.WithScopedLifetime());
	}
}