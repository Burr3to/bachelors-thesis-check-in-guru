using System.Reflection;
using System.Text;
using CheckIn.Api.App.Hubs;
using CheckIn.Api.Bl.Installers;
using CheckIn.Api.Dal.Installers;
using CheckIn.Api.Bl.Mappers;
using CheckIn.Api.Bl.Services;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Auth;
using CheckIn.Api.Dal;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;

var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key not configured.");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "https://localhost:7084";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "https://localhost:7084";

var firebaseConfigJson = builder.Configuration["FirebaseAdmin:ServiceAccountJson"];

if (string.IsNullOrEmpty(firebaseConfigJson))
{
    // Ak sa to nenašlo, hádžeme výnimku.
    throw new InvalidOperationException(
        "Firebase service account key (FirebaseAdmin:ServiceAccountJson) not found in configuration. Check secrets.json or environment variables.");
}

// Inicializácia Firebase Admin SDK
FirebaseApp.Create(new AppOptions()
{
    // GoogleCredential.FromJson spracuje JSON string, ktorý si vytiahol
    Credential = GoogleCredential.FromJson(firebaseConfigJson)
});

// Zaregistruj Singleton
builder.Services.AddSingleton(FirebaseAuth.DefaultInstance);


builder.Services.AddAuthentication(options =>
    {
        // Nastavujeme JWT ako predvolenú schému pre autentifikáciu a Challenge
        options.DefaultAuthenticateScheme = "Bearer";
        options.DefaultChallengeScheme = "Bearer";
        options.DefaultForbidScheme = "Bearer";
        options.DefaultScheme = "Bearer";
    })
    // Odstránená Google OAuth schéma, pretože prechádzame na Firebase klientskú autentifikáciu.
    .AddJwtBearer("Bearer", jwtOptions =>
    {
        // Kľúčová konfigurácia pre validáciu prichádzajúcich JWT tokenov
        jwtOptions.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero
        };
        jwtOptions.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            },
            OnChallenge = context =>
            {
                // Vypneme predvolené správanie (presmerovanie)
                context.HandleResponse();

                // Vrátime 401 Unauthorized a JSON telo
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";

                var result = System.Text.Json.JsonSerializer.Serialize(new
                {
                    error = "Unauthorized",
                    message = "Autorizácia zlyhala. Token je neplatný alebo chýba."
                });

                return context.Response.WriteAsync(result);
            },
            OnForbidden = context =>
            {
                // Spracovanie 403 Forbidden
                context.Response.StatusCode = 403;
                context.Response.ContentType = "application/json";
                return context.Response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(new
                {
                    error = "Forbidden",
                    message = "Nemáte dostatočné oprávnenia pre tento prístup."
                }));
            }
        };
    });


builder.Services.AddIdentity<IdentityUser, IdentityRole>(options => { options.SignIn.RequireConfirmedAccount = false; })
    .AddEntityFrameworkStores<CheckInDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddAutoMapper(
    cfg => cfg.LicenseKey = builder.Configuration.GetSection("Licenses")["Automapper"],
    typeof(TaskMapperProfile));

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

builder.Services.AddSignalR();

// --- Registrácia Fasád/BL služieb 
ApiBlInstaller.Install(builder.Services);

var allowedOrigins = new[]
{
    "https://bp-checkin-473517.web.app",
    "http://checkin.fit.vutbr.cz",
    "https://checkin.fit.vutbr.cz",
    "https://localhost:7084",
    "http://localhost:5000"
};

builder.Services.AddCors(options =>
{
    options.AddPolicy("AppCorsPolicy", policy =>
    {
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});


// Dependency Injection - Registruj DAL a BL služby
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

ApiDalInstaller.Install(builder.Services, connectionString);

// Add services to the container.

builder.Services.AddSwaggerGen();
builder.Services.AddControllers()
    .AddNewtonsoftJson();
builder.Services.AddOpenApi();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();

if (args.Contains("migrate"))
{
    var host = builder.Build();

    // Spustí migráciu a ukončí aplikáciu
    MigrateDatabase(host);

    // Ak prebehne len migrácia, aplikácia sa skončí
    return;
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
        options.RoutePrefix = string.Empty;
    });

    app.MapOpenApi();
}

app.UseCors("AppCorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapHub<TaskHub>("/hubs/tasks");

app.Run();

// PRIDAJTE TÚTO METÓDU NA KONIEC Program.cs
void MigrateDatabase(IHost host)
{
    using (var scope = host.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        try
        {
            var dbContext = services.GetRequiredService<CheckInDbContext>();
            dbContext.Database.Migrate();
            Console.WriteLine("Database migration successful.");
        }
        catch (Exception ex)
        {
            var logger = services.GetRequiredService<ILogger<Program>>();
            logger.LogError(ex, "An error occurred while migrating the database.");
        }
    }
}