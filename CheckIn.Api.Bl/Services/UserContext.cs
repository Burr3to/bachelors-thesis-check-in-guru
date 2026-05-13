using System.Security.Claims;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.AspNetCore.Http;

namespace CheckIn.Api.Bl.Services;

/// <summary>
/// Implementation of UserContext that extracts user information from the HTTP request's ClaimsPrincipal.
/// </summary>
public class UserContext(IHttpContextAccessor httpContextAccessor) : IUserContext
{
    /// <summary>
    /// Accesses the ClaimsPrincipal from the current HTTP context.
    /// </summary>
    private ClaimsPrincipal? User => httpContextAccessor.HttpContext?.User;

    /// <summary>
    /// Checks if the current user is authenticated.
    /// </summary>
    public bool IsAuthenticated() => User?.Identity?.IsAuthenticated ?? false;

    /// <summary>
    /// Extracts the User ID from the NameIdentifier claim.
    /// </summary>
    public Guid? GetUserId()
    {
        var userIdClaim = User?.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim, out var userId) ? userId : null;
    }

    /// <summary>
    /// Extracts the user's name from available claims. 
    /// Checks Name, custom "name", and GivenName claim types.
    /// </summary>
    public string? GetName()
    {
        return User?.FindFirstValue(ClaimTypes.Name)
               ?? User?.FindFirstValue("name")
               ?? User?.FindFirstValue(ClaimTypes.GivenName);
    }

    /// <summary>
    /// Extracts the email address from the Email claim.
    /// </summary>
    public string? GetEmail()
    {
        return User?.FindFirstValue(ClaimTypes.Email);
    }
}