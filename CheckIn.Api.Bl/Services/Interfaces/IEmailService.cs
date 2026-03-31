namespace CheckIn.Api.Bl.Services.Interfaces;

public interface IEmailService
{
    Task SendEmailAsync(string toEmail, string subject, string htmlMessage);
    Task SendBulkEmailsAsync(List<string> emails, string taskHash, string authorName, string taskTitle);
    List<string> ParseEmails(string rawText);
}