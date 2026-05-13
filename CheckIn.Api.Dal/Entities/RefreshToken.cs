using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// Represents a refresh token used for JWT rotation and persistent authentication sessions.
/// </summary>
public class RefreshToken
{
    public int Id { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiryDate { get; set; }
    public string UserId { get; set; }

    /// <summary>
    /// Navigation property to the associated Identity user.
    /// </summary>
    public IdentityUser User { get; set; } = null!;
}