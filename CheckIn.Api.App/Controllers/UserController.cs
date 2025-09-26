using System.Security.Claims;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UserController : ControllerBase
{
    private readonly IUserFacade _userFacade;
    // Potrebujeme Fasádu, ktorá sa stará o užívateľov (nájde/vytvorí užívateľa)
    public UserController(IUserFacade userFacade) 
    {
        _userFacade = userFacade;
    }

    // -----------------------------------------------------------------------
    // 1. ZÍSKANIE PROFILU (Dashboard)
    // -----------------------------------------------------------------------
    
    // GET: api/User/profile
    [HttpGet("profile")]
    [Authorize] // Kľúčové: iba pre prihláseného užívateľa!
    [ProducesResponseType(typeof(UserDetailModel), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetUserProfile()
    {
        // 1. Získanie ID užívateľa z JWT Tokenu
        var ownerIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(ownerIdString, out var userId))
        {
            // Toto by sa nemalo stať, ak je [Authorize] úspešné
            return Unauthorized("User ID claim is missing.");
        }
        
        // 2. Volanie Fasády pre získanie detailu
        var userDetail = await _userFacade.GetByIdAsync(userId);
        
        if (userDetail == null)
        {
            return NotFound("User profile not found in database.");
        }
        
        return Ok(userDetail);
    }

    // -----------------------------------------------------------------------
    // 2. GOOGLE LOGIN (Špeciálny Endpoint)
    // -----------------------------------------------------------------------
    
    // POST: api/User/login-google
    // Táto metóda by v budúcnosti spracovala token od Google (alebo nejaký kód)
    // a vymenila ho za náš JWT token.
    [HttpPost("login-google")]
    [AllowAnonymous] // Tento endpoint musí byť otvorený!
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GoogleLogin([FromBody] string googleToken)
    {
        // POZNÁMKA: Implementácia OAuth 2.0 je rozsiahla. 
        // Pre MVP to stačí ako placeholder:
        
        // 1. Zavolaj Fasádu, aby overila token u Google (nie je implementované)
        // 2. Fasáda vytvorí alebo nájde UserEntity v DB
        // 3. Fasáda vygeneruje a vráti JWT token pre Flutter
        
        // Zatiaľ len vrátime placeholder
        var placeholderJwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...."; 
        
        return Ok(new { token = placeholderJwtToken });
    }
    
    // -----------------------------------------------------------------------
    // 3. REGISTRÁCIA (Nepotrebné pre Google Login, je integrovaná v Login)
    // -----------------------------------------------------------------------
}
