using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace CheckIn.Api.App.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class AuthController : ControllerBase
	{
		private readonly SignInManager<IdentityUser> _signInManager;
		private readonly UserManager<IdentityUser> _userManager;
		private readonly IUserFacade _userFacade;
		private readonly IConfiguration _configuration;

		public AuthController(
			SignInManager<IdentityUser> signInManager,
			UserManager<IdentityUser> userManager,
			IUserFacade userFacade,
			IConfiguration configuration)
		{
			_signInManager = signInManager;
			_userManager = userManager;
			_userFacade = userFacade;
			_configuration = configuration;
		}

		/// <summary>
		/// Krok 1: Iniciuje Google OAuth prihlasovací tok.
		/// Flutter klient zavolá tento endpoint na spustenie prihlásenia cez Google.
		/// </summary>
		[HttpGet("google-login")]
		[AllowAnonymous]
		public IActionResult GoogleLogin()
		{
			// Pripravíme URL pre callback, na ktorú nás Google vráti.
			var redirectUrl = Url.Action(nameof(GoogleCallback), "Auth", new { }, Request.Scheme);
			var properties =
				_signInManager.ConfigureExternalAuthenticationProperties(GoogleDefaults.AuthenticationScheme,
					redirectUrl);

			// Vrátime "Challenge", čo spôsobí presmerovanie na prihlasovaciu stránku Google.
			return Challenge(properties, GoogleDefaults.AuthenticationScheme);
		}

		/// <summary>
		/// Krok 2: Callback endpoint, na ktorý Google presmeruje po úspešnej autentifikácii.
		/// Backend tu spracuje Google autentifikáciu a vydá JWT token.
		/// </summary>
		[HttpGet("callback")]
		[AllowAnonymous]
		public async Task<IActionResult> GoogleCallback()
		{
			var frontendBaseUrl = _configuration["Frontend:BaseUrl"] ?? "http://localhost:5000";

			var info = await _signInManager.GetExternalLoginInfoAsync();
			if (info == null)
			{
				return Redirect($"{frontendBaseUrl}/login-error?message=External login info not available.");
			}

			IdentityUser user;
			// Pokúsime sa prihlásiť používateľa s externým poskytovateľom
			var signInResult = await _signInManager.ExternalLoginSignInAsync(info.LoginProvider, info.ProviderKey,
				isPersistent: false, bypassTwoFactor: true);

			if (signInResult.Succeeded)
			{
				// Používateľ už existuje v našej DB Identity a je prepojený s Google účtom. Načítame ho.
				user = await _userManager.FindByLoginAsync(info.LoginProvider, info.ProviderKey);
			}
			else // Používateľ neexistuje v Identity, alebo nie je prepojený s externým loginom.
			{
				var email = info.Principal.FindFirstValue(ClaimTypes.Email);
				if (string.IsNullOrEmpty(email))
				{
					return Redirect($"{frontendBaseUrl}/login-error?message=Email not found from Google.");
				}

				user = await _userManager.FindByEmailAsync(email);
				if (user == null)
				{
					// Používateľ s týmto emailom neexistuje v Identity, vytvoríme nového IdentityUser.
					user = new IdentityUser { UserName = email, Email = email, EmailConfirmed = true };
					var createResult = await _userManager.CreateAsync(user);
					if (!createResult.Succeeded)
					{
						var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
						return Redirect($"{frontendBaseUrl}/login-error?message=User creation failed: {errors}");
					}
				}

				// Prepojíme existujúceho alebo novovytvoreného IdentityUser s jeho Google účtom.
				// Toto sa uloží do tabuľky AspNetUserLogins.
				var addLoginResult = await _userManager.AddLoginAsync(user, info);
				if (!addLoginResult.Succeeded)
				{
					var errors = string.Join(", ", addLoginResult.Errors.Select(e => e.Description));
					return Redirect($"{frontendBaseUrl}/login-error?message=Failed to add external login: {errors}");
				}
			}

			// *** TÁTO ČASŤ JE KĽÚČOVÁ PRE VYTVORENIE/AKTUALIZÁCIU VÁŠHO CUSTOM UserEntity ***
			// Bez ohľadu na to, či bol používateľ práve vytvorený alebo už existoval,
			// zabezpečíme, aby mal záznam aj vo vašej vlastnej tabuľke 'Users' cez fasádu.
			var userDetailModel = new UserDetailModel
			{
				Id = Guid.Parse(user.Id), // IdentityUser.Id je string, ale pre naše entitity ho parsujeme na Guid
				Name = info.Principal.FindFirstValue(ClaimTypes.Name) ?? "Nezname meno",
				Email = user.Email,
				GoogleId = info.ProviderKey // Jedinečný identifikátor používateľa od Google
			};

			// Metóda SaveAsync vo vašej fasáde teraz správne zistí, či ide o pridanie alebo aktualizáciu.
			await _userFacade.SaveAsync(userDetailModel);

			// Prihlásime používateľa do ASP.NET Core Identity (ak ešte nie je)
			// Toto vytvorí session cookie, ktorá je pre náš JWT tok technicky voliteľná,
			// ale môže byť užitočná pre interné ASP.NET Identity mechanizmy.
			await _signInManager.SignInAsync(user, isPersistent: false);

			// Generovanie JWT tokenu
			var token = GenerateJwtToken(user);

			// Presmerovanie späť na Flutter aplikáciu s JWT tokenom
			return Redirect($"{frontendBaseUrl}/login-success?token={token}");
		}

		private string GenerateJwtToken(IdentityUser user)
		{
			var claims = new List<Claim>
			{
				new Claim(JwtRegisteredClaimNames.Sub, user.Id),
				new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()), // JWT ID
				new Claim(ClaimTypes.NameIdentifier, user.Id),
				new Claim(ClaimTypes.Email, user.Email)
			};

			// V budúcnosti tu môžete pridať roly
			// var roles = await _userManager.GetRolesAsync(user);
			// claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

			var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
			var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

			var token = new JwtSecurityToken(
				issuer: _configuration["Jwt:Issuer"],
				audience: _configuration["Jwt:Audience"],
				claims: claims,
				expires: DateTime.Now.AddDays(7),
				signingCredentials: creds
			);

			return new JwtSecurityTokenHandler().WriteToken(token);
		}
	}
}