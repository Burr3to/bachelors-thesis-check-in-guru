//using CheckIn.Api.App.Installers;
//using CheckIn.Api.Dal.Installers;
//using CheckIn.Api.Bl.Mappers;

using AutoMapper;
using CheckIn.Api.Dal;
using Microsoft.EntityFrameworkCore;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

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

builder.Services.AddDbContext<CheckInDbContext>(options => { options.UseNpgsql(connectionString); });


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