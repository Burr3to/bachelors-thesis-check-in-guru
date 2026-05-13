using System;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
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
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

var builder = WebApplication.CreateBuilder(args);

// --- Configuration Retrieval ---
var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key not configured.");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "https://localhost:7084";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "https://localhost:7084";

var firebaseConfigJson = builder.Configuration["FirebaseAdmin:ServiceAccountJson"];

if (string.IsNullOrEmpty(firebaseConfigJson))
{
    throw new InvalidOperationException(
        "Firebase service account key (FirebaseAdmin:ServiceAccountJson) not found in configuration. Check secrets.json or environment variables.");
}

// --- External Services Initialization ---

// Initialize Firebase Admin SDK using service account credentials
FirebaseApp.Create(new AppOptions()
{
    Credential = GoogleCredential.FromJson(firebaseConfigJson)
});

builder.Services.AddSingleton(FirebaseAuth.DefaultInstance);

// --- Authentication Configuration ---
builder.Services.AddAuthentication(options =>
    {
        // Set JWT Bearer as the default scheme for all authentication actions
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultForbidScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, jwtOptions =>
    {
        // Define validation parameters for incoming JWT tokens
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
                // SignalR sends the access token via a query string parameter named 'access_token'
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
                // Suppress default redirect and return a custom 401 JSON response
                context.HandleResponse();
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = "application/json";

                var result = System.Text.Json.JsonSerializer.Serialize(new
                {
                    error = "Unauthorized",
                    message = "Authorization failed. Token is invalid or missing."
                });

                return context.Response.WriteAsync(result);
            },
            OnForbidden = context =>
            {
                // Return a custom 403 JSON response for insufficient permissions
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                context.Response.ContentType = "application/json";
                return context.Response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(new
                {
                    error = "Forbidden",
                    message = "You do not have sufficient permissions to access this resource."
                }));
            }
        };
    });

// --- Identity & Core Services ---
builder.Services.AddIdentity<IdentityUser, IdentityRole>(options => { options.SignIn.RequireConfirmedAccount = false; })
    .AddEntityFrameworkStores<CheckInDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddAutoMapper(
    cfg => cfg.LicenseKey = builder.Configuration.GetSection("Licenses")["Automapper"],
    typeof(TaskMapperProfile));

// --- Swagger Configuration ---
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "CheckIn API", Version = "v1" });

    // Enable JWT Authorize button in Swagger UI
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter JWT Bearer token for authorization."
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

// Registration of Business Logic Facades and Services
ApiBlInstaller.Install(builder.Services);

// --- CORS Configuration ---
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
            .AllowCredentials(); // Required for SignalR and Cookies
    });
});

// Database Connection String
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

// Registration of Data Access Layer
ApiDalInstaller.Install(builder.Services, connectionString);

builder.Services.AddControllers()
    .AddNewtonsoftJson();
builder.Services.AddOpenApi();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();

// --- Migration Support ---
if (args.Contains("migrate"))
{
    var host = builder.Build();

    // Run database migrations and exit the application
    MigrateDatabase(host);
    return;
}

var app = builder.Build();

// --- HTTP Request Pipeline ---
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

// SignalR Hub Mappings (Support for both direct and prefixed paths)
app.MapHub<TaskHub>("/hubs/tasks");
app.MapHub<TaskHub>("/api/hubs/tasks");

app.Run();

/// <summary>
/// Scoped helper method to apply pending EF Core migrations to the database.
/// </summary>
void MigrateDatabase(IHost host)
{
    using (var scope = host.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        try
        {
            var dbContext = services.GetRequiredService<CheckInDbContext>();
            dbContext.Database.Migrate();
        }
        catch (Exception ex)
        {
            var logger = services.GetRequiredService<ILogger<Program>>();
            logger.LogError(ex, "An error occurred while migrating the database.");
        }
    }
}