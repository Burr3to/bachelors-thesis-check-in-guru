using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

/// <summary>
/// Controller managing user profile information.
/// </summary>
[Route("api/[controller]")]
[ApiController]
public class UserController : ControllerBase
{
    private readonly IUserFacade _userFacade;

    public UserController(IUserFacade userFacade)
    {
        _userFacade = userFacade;
    }

    /// <summary>
    /// Retrieves the profile details of the currently authenticated user based on their JWT token.
    /// </summary>
    [HttpGet("profile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ProducesResponseType(typeof(UserDetailModel), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetUserProfile()
    {
        // Extract the user ID from the NameIdentifier claim within the JWT Token
        var ownerIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(ownerIdString, out var userId))
        {
            return Unauthorized("Invalid or missing User ID claim.");
        }

        // Fetch user data from the database via facade
        var userDetail = await _userFacade.GetByIdAsync(userId);

        if (userDetail == null)
        {
            return NotFound("User profile not found in database.");
        }

        return Ok(userDetail);
    }
}