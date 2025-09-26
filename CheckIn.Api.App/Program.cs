using CheckIn.Api.Bl.Installers;
using CheckIn.Api.Dal.Installers;
using CheckIn.Api.Bl.Mappers;
using CheckIn.Api.Dal;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using AutoMapper;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddAutoMapper(
	cfg => cfg.LicenseKey = builder.Configuration.GetSection("Licenses")["Automapper"],
	typeof(CheckInEventMapperProfile));

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
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
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

app.UseAuthorization();

app.MapControllers();

app.Run();