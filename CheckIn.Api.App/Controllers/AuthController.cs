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
        /// Verifies Firebase ID Token, synchronizes the user locally, and issues a custom JWT.
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
                // Verify the token authenticity via Firebase Admin SDK
                decodedToken = await firebaseAuth.VerifyIdTokenAsync(request.IdToken);
            }
            catch (FirebaseAuthException e)
            {
                return Unauthorized($"Invalid Firebase token: {e.Message}");
            }

            // Extract user data from the verified token claims
            var email = decodedToken.Claims.ContainsKey("email")
                ? decodedToken.Claims["email"].ToString()
                : null;

            var name = decodedToken.Claims.ContainsKey("name")
                ? decodedToken.Claims["name"].ToString()
                : "Unknown User";

            var firebaseUid = decodedToken.Uid;

            if (string.IsNullOrEmpty(email))
            {
                return BadRequest("Email not provided by Firebase.");
            }

            // Sync with local ASP.NET Identity system
            IdentityUser user = await userManager.FindByEmailAsync(email);

            if (user == null)
            {
                // Create local user if they don't exist yet
                user = new IdentityUser { UserName = email, Email = email, EmailConfirmed = true };
                var createResult = await userManager.CreateAsync(user);

                if (!createResult.Succeeded)
                {
                    var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
                    return StatusCode(500, $"User creation failed: {errors}");
                }
            }

            // Update user profile in local database
            await userFacade.SaveAsync(Guid.Parse(user.Id), firebaseUid, user.Email, name);

            // Generate short-lived Access Token and long-lived Refresh Token
            var accessToken = GenerateJwtToken(user, TimeSpan.FromMinutes(20));
            var refreshToken = await GenerateAndSaveRefreshToken(user.Id, TimeSpan.FromDays(30));

            // Store Refresh Token in a secure HttpOnly cookie
            AttachRefreshTokenToCookie(refreshToken.Token);

            return Ok(new
            {
                token = accessToken,
                userId = user.Id,
                email = user.Email
            });
        }

        /// <summary>
        /// Rotates the Refresh Token and issues a new Access Token.
        /// </summary>
        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<IActionResult> RefreshToken()
        {
            // Extract the refresh token from secure cookies
            var refreshToken = Request.Cookies["refresh_token"];

            if (string.IsNullOrEmpty(refreshToken))
            {
                return Unauthorized("Refresh token missing.");
            }

            // Validate the token against the database
            var tokenRecord = await dbContext.RefreshTokens
                .Include(t => t.User)
                .SingleOrDefaultAsync(t => t.Token == refreshToken);

            if (tokenRecord == null || tokenRecord.ExpiryDate < DateTime.UtcNow)
            {
                return Unauthorized("Invalid or expired refresh token.");
            }

            // Issue new tokens (Token Rotation pattern for enhanced security)
            var newAccessToken = GenerateJwtToken(tokenRecord.User, TimeSpan.FromMinutes(15));
            var newRefreshToken = await GenerateAndSaveRefreshToken(tokenRecord.UserId, TimeSpan.FromDays(30));

            AttachRefreshTokenToCookie(newRefreshToken.Token);

            return Ok(new
            {
                token = newAccessToken,
                userId = tokenRecord.UserId,
                email = tokenRecord.User.Email
            });
        }

        /// <summary>
        /// Creates a new refresh token and purges old ones for the user.
        /// </summary>
        private async Task<RefreshToken> GenerateAndSaveRefreshToken(string userId, TimeSpan lifespan)
        {
            var token = Guid.NewGuid().ToString("N");
            var expiryDate = DateTime.UtcNow.Add(lifespan);

            // Best practice: remove existing tokens to prevent bloat and enforce single-session/rotation
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
                // Silently handle concurrent token updates
            }

            return refreshToken;
        }

        /// <summary>
        /// Configures and attaches a secure HttpOnly cookie for the refresh token.
        /// </summary>
        private void AttachRefreshTokenToCookie(string token)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true, // Prevents XSS access
                Secure = true, // Requires HTTPS
                Expires = DateTime.UtcNow.AddDays(30),
                SameSite = SameSiteMode.None, // Required for cross-site requests (e.g., Flutter Web)
                Path = "/"
            };

            Response.Cookies.Append("refresh_token", token, cookieOptions);
        }

        /// <summary>
        /// Generates a signed JWT for the authenticated user.
        /// </summary>
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