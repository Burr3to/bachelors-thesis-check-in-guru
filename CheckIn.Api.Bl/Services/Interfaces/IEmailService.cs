namespace CheckIn.Api.Bl.Services.Interfaces;

/// <summary>
/// Service for handling email extraction, domain validation, and dispatching.
/// </summary>
public interface IEmailService
{
    /// <summary>
    /// Sends a single HTML email.
    /// </summary>
    Task SendEmailAsync(string toEmail, string subject, string htmlMessage);

    /// <summary>
    /// Sends batch emails for invitations or reminders using predefined HTML templates.
    /// </summary>
    Task SendBulkEmailsAsync(List<string> emails, string taskHash, string authorName, string taskTitle,
        string? taskDescription, bool isReminder = false);

    /// <summary>
    /// Parses raw text to find and extract all valid email addresses.
    /// </summary>
    List<string> ParseEmails(string rawText);

    /// <summary>
    /// Checks if the provided domain has valid MX records.
    /// </summary>
    Task<bool> IsDomainValidAsync(string domain);

    /// <summary>
    /// Extracts the domain from an email address and validates its MX records.
    /// </summary>
    Task<bool> IsEmailDomainValidAsync(string email);
}