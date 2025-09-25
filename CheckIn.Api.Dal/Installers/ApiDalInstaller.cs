using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace CheckIn.Api.Dal.Installers;

public class ApiDalInstaller
{
	public static void Install(IServiceCollection services, string connectionString)
	{
		services.AddDbContext<CheckInDbContext>(options => { options.UseNpgsql(connectionString); });
	}
}