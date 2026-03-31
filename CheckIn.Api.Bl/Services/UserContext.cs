using System.Security.Claims;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.AspNetCore.Http;

namespace CheckIn.Api.Bl.Services;

public class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContext(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

    public bool IsAuthenticated() => User?.Identity?.IsAuthenticated ?? false;

    public Guid? GetUserId()
    {
        var userIdClaim = User?.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim, out var userId) ? userId : null;
    }

    public string? GetName()
    {
        return User?.FindFirstValue(ClaimTypes.Name)
               ?? User?.FindFirstValue("name")
               ?? User?.FindFirstValue(ClaimTypes.GivenName);
    }

    public string? GetEmail()
    {
        return User?.FindFirstValue(ClaimTypes.Email);
    }
}