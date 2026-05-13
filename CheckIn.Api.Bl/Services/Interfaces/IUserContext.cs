namespace CheckIn.Api.Bl.Services.Interfaces;

/// <summary>
/// Provides an abstraction for accessing information about the currently authenticated user.
/// </summary>
public interface IUserContext
{
    /// <summary>
    /// Retrieves the unique identifier (GUID) of the current user.
    /// </summary>
    /// <returns>The user's ID if authenticated; otherwise, null.</returns>
    Guid? GetUserId();

    /// <summary>
    /// Retrieves the display name of the current user.
    /// </summary>
    /// <returns>The user's name if available; otherwise, null.</returns>
    string? GetName();

    /// <summary>
    /// Retrieves the email address of the current user.
    /// </summary>
    /// <returns>The user's email if available; otherwise, null.</returns>
    string? GetEmail();
}