using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Auth;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using FirebaseAdmin.Auth;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.App.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController(
        SignInManager<IdentityUser> signInManager,
        UserManager<IdentityUser> userManager,
        CheckInDbContext dbContext,
        IUserFacade userFacade,
        IConfiguration configuration,
        FirebaseAuth firebaseAuth)
        : ControllerBase
    {
        /// <summary>
        /// Prijme Firebase ID Token od Flutter klienta, overí ho a vydá vlastný JWT.
        /// </summary>
        [HttpPost("verify-firebase-token")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyFirebaseToken([FromBody] FirebaseTokenRequest request)
        {
            if (string.IsNullOrEmpty(request.IdToken))
            {
                return BadRequest("Firebase ID Token is required.");
            }

            FirebaseToken decodedToken;
            try
            {
                // Kľúčová linka: Overenie tokenu, využíva injektovaný _firebaseAuth
                decodedToken = await firebaseAuth.VerifyIdTokenAsync(request.IdToken);
            }
            catch (FirebaseAuthException e)
            {
                // Neplatný token (vypršaný, zmenený, zlá signatúra)
                return Unauthorized($"Invalid Firebase token: {e.Message}");
            }

            // Extrahovanie dát z Firebase tokenu
            var email = decodedToken.Claims.ContainsKey("email")
                ? decodedToken.Claims["email"].ToString()
                : null;

            var name = decodedToken.Claims.ContainsKey("name")
                ? decodedToken.Claims["name"].ToString()
                : "Nezname meno";

            var firebaseUid = decodedToken.Uid;

            if (string.IsNullOrEmpty(email))
            {
                return BadRequest("Email not provided by Firebase.");
            }

            // --- Spracovanie lokálnej Identity (ASP.NET Identity / PostgreSQL) ---
            IdentityUser user = await userManager.FindByEmailAsync(email);

            if (user == null)
            {
                // Používateľ neexistuje, vytvoríme ho
                user = new IdentityUser { UserName = email, Email = email, EmailConfirmed = true };
                var createResult = await userManager.CreateAsync(user);

                if (!createResult.Succeeded)
                {
                    var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
                    return StatusCode(500, $"User creation failed: {errors}");
                }
            }

            await userFacade.SaveAsync(Guid.Parse(user.Id), firebaseUid, user.Email, name);

            // 1. Vygeneruj NOVÝ Access Token (teraz s krátkou expiráciou, napr. 15 minút)
            var accessToken = GenerateJwtToken(user, TimeSpan.FromMinutes(20));

            // 2. Vygeneruj a ulož Refresh Token (dlhá expiráciu, napr. 30 dní)
            var refreshToken = await GenerateAndSaveRefreshToken(user.Id, TimeSpan.FromDays(30));

            // 3. Pridaj Refresh Token do HttpOnly Cookie
            AttachRefreshTokenToCookie(refreshToken.Token);

            // 4. Vráť Access Token v tele odpovede
            return Ok(new
            {
                token = accessToken, // Krátkožijúci JWT
                userId = user.Id,
                email = user.Email
            });
        }

        [HttpPost("refresh")]
        [AllowAnonymous] // Tento endpoint musí byť neautorizovaný, pretože používa Refresh Token, nie JWT.
        public async Task<IActionResult> RefreshToken()
        {
            // 1. Získa Refresh Token z Cookie
            var refreshToken = Request.Cookies["refresh_token"];

            if (string.IsNullOrEmpty(refreshToken))
            {
                return Unauthorized("Refresh token missing.");
            }

            // 2. Nájdeme ho v databáze
            var tokenRecord = await dbContext.RefreshTokens
                .Include(t => t.User)
                .SingleOrDefaultAsync(t => t.Token == refreshToken);

            if (tokenRecord == null || tokenRecord.ExpiryDate < DateTime.UtcNow)
            {
                // Token neexistuje alebo vypršal
                return Unauthorized("Invalid or expired refresh token.");
            }

            // 3. Vydáme nový Access Token (15m)
            var newAccessToken = GenerateJwtToken(tokenRecord.User, TimeSpan.FromMinutes(15));

            // 4. Vydáme NOVÝ Refresh Token a starý zneplatníme (tzv. Rotating Refresh Tokens)
            // Týmto zvyšujeme bezpečnosť - ak by bol token ukradnutý, platí iba raz.
            var newRefreshToken = await GenerateAndSaveRefreshToken(tokenRecord.UserId, TimeSpan.FromDays(30));

            // 5. Nahradíme Cookie novým tokenom
            AttachRefreshTokenToCookie(newRefreshToken.Token);

            // 6. Vrátime nový Access Token
            return Ok(new
            {
                token = newAccessToken,
                userId = tokenRecord.UserId,
                email = tokenRecord.User.Email
            });
        }

        private async Task<RefreshToken> GenerateAndSaveRefreshToken(string userId, TimeSpan lifespan)
        {
            var token = Guid.NewGuid().ToString("N");
            var expiryDate = DateTime.UtcNow.Add(lifespan);


            // Odstránenie starých tokenov (best practice)
            var existingTokens = dbContext.RefreshTokens.Where(t => t.UserId == userId);
            if (await existingTokens.AnyAsync())
            {
                dbContext.RefreshTokens.RemoveRange(existingTokens);
            }

            var refreshToken = new RefreshToken
            {
                Token = token,
                ExpiryDate = expiryDate,
                UserId = userId
            };

            await dbContext.RefreshTokens.AddAsync(refreshToken);
            try
            {
                await dbContext.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                // Ak sa dva requesty "pobili", nevadí, jeden z nich vyhrá
            }

            return refreshToken;
        }

        private void AttachRefreshTokenToCookie(string token)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true, // KĽÚČOVÉ: Neprístupné cez JavaScript (chráni proti XSS)
                Secure = true, // KĽÚČOVÉ: Len cez HTTPS (chráni prenos)
                Expires = DateTime.UtcNow.AddDays(30), // Expirácia zhodná s tokenom
                SameSite = SameSiteMode.None, // Chráni proti CSRF
                Path = "/" // Zabezpečí, že cookie sa pošle na všetky API endpointy
            };

            // POZOR: Flutter Web musí bežať na rovnakej doméne (alebo subdoméne) ako tvoj backend, 
            // inak prehliadač cookie nepripojí kvôli SameSite politike.
            Response.Cookies.Append("refresh_token", token, cookieOptions);
        }

        private string GenerateJwtToken(IdentityUser user, TimeSpan lifespan)
        {
            var expirationTime = DateTime.UtcNow.Add(lifespan);

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: configuration["Jwt:Issuer"],
                audience: configuration["Jwt:Audience"],
                claims: claims,
                expires: expirationTime,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}