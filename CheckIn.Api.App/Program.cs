using System.Text;
using CheckIn.Api.Bl.Installers;
using CheckIn.Api.Dal.Installers;
using CheckIn.Api.Bl.Mappers;
using CheckIn.Api.Dal;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key not configured.");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "https://localhost:7084";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "https://localhost:7084";

builder.Services.AddAuthentication(options =>
	{
		options.DefaultScheme = Microsoft.AspNetCore.Identity.IdentityConstants.ApplicationScheme;
		options.DefaultChallengeScheme = Microsoft.AspNetCore.Authentication.Google.GoogleDefaults.AuthenticationScheme;
	})
	.AddGoogle(googleOptions =>
	{
		googleOptions.ClientId = builder.Configuration["Authentication:Google:ClientId"];
		googleOptions.ClientSecret = builder.Configuration["Authentication:Google:ClientSecret"];
		googleOptions.CallbackPath = "/signin-google";
	})
	.AddJwtBearer(jwtOptions =>
	{
		// Toto je kľúčová konfigurácia pre validáciu prichádzajúcich JWT tokenov
		jwtOptions.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuer = true, // Overiť vydavateľa tokenu
			ValidateAudience = true, // Overiť príjemcu tokenu
			ValidateLifetime = true, // Overiť platnosť tokenu (expiráciu)
			ValidateIssuerSigningKey = true, // Overiť podpisový kľúč tokenu
			ValidIssuer = jwtIssuer, // Použijte hodnotu z User Secrets
			ValidAudience = jwtAudience, // Použijte hodnotu z User Secrets
			IssuerSigningKey =
				new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)) // Použijte podpisový kľúč z User Secrets
		};
	});
builder.Services.AddIdentity<IdentityUser, IdentityRole>(options => { options.SignIn.RequireConfirmedAccount = false; })
	.AddEntityFrameworkStores<CheckInDbContext>()
	.AddDefaultTokenProviders();

builder.Services.AddAutoMapper(
	cfg => cfg.LicenseKey = builder.Configuration.GetSection("Licenses")["Automapper"],
	typeof(CheckInEventMapperProfile));

builder.Services.AddSwaggerGen(options =>
{
	options.SwaggerDoc("v1", new OpenApiInfo { Title = "CheckIn API", Version = "v1" });

	options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
	{
		Name = "Authorization",
		Type = SecuritySchemeType.Http,
		Scheme = "bearer",
		BearerFormat = "JWT",
		In = ParameterLocation.Header,
		Description = "Zadajte JWT Bearer token pre autorizáciu."
	});

	// Priradenie bezpečnostnej požiadavky k celej dokumentácii
	// To znamená, že všetky endpointy budú vyžadovať túto schému (alebo explicitné AllowAnonymous)
	options.AddSecurityRequirement(new OpenApiSecurityRequirement
	{
		{
			new OpenApiSecurityScheme
			{
				Reference = new OpenApiReference
				{
					Type = ReferenceType.SecurityScheme,
					Id = "Bearer"
				}
			},
			new string[] { }
		}
	});
});

// --- Registrácia Fasád/BL služieb 
ApiBlInstaller.Install(builder.Services);

// CORS - Dôležité pre Flutter
builder.Services.AddCors(options =>
{
	options.AddDefaultPolicy(o =>
		o.AllowAnyOrigin()
			.AllowAnyHeader()
			.AllowAnyMethod());
});

// Dependency Injection - Registruj DAL a BL služby
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

ApiDalInstaller.Install(builder.Services, connectionString);

// Add services to the container.

builder.Services.AddSwaggerGen();
builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	// --- Dodatočný kód ---
	app.UseSwagger();
	app.UseSwaggerUI(options =>
	{
		options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
		options.RoutePrefix = string.Empty; // URL bude priamo na hlavnej stránke
	});
	// --- Koniec dodatočného kódu ---

	app.MapOpenApi();
}

app.UseCors();

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();