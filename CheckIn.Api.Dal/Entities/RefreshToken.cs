using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal.Entities;

public class RefreshToken
{
    public int Id { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiryDate { get; set; }
    public string UserId { get; set; }

    // Navigačná vlastnosť
    public IdentityUser User { get; set; } = null!;
}