using System.Text;
using System.Text.RegularExpressions;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;

namespace CheckIn.Api.Bl.Services;

public class EmailService(IConfiguration configuration) : IEmailService
{
    private async Task<SmtpClient> GetConnectedSmtpClientAsync()
    {
        var from = configuration["EmailSettings:Email"];
        var password = configuration["EmailSettings:Password"];
        var host = configuration["EmailSettings:Host"];
        var port = int.Parse(configuration["EmailSettings:Port"] ?? "587");

        var smtp = new SmtpClient();
        await smtp.ConnectAsync(host, port, SecureSocketOptions.StartTls);
        await smtp.AuthenticateAsync(from, password);
        return smtp;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string htmlMessage)
    {
        var from = configuration["EmailSettings:Email"];
        var email = new MimeMessage();
        email.From.Add(new MailboxAddress("CheckIn System", from));
        email.To.Add(MailboxAddress.Parse(toEmail));
        email.Subject = subject;
        email.Body = new BodyBuilder { HtmlBody = htmlMessage }.ToMessageBody();

        using var smtp = await GetConnectedSmtpClientAsync();
        await smtp.SendAsync(email);
        await smtp.DisconnectAsync(true);
    }

    public async Task SendBulkEmailsAsync(List<string> emails, string taskHash, string authorName, string taskTitle)
    {
        var from = configuration["EmailSettings:Email"];

        var templatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "Invitation.html");

        if (!File.Exists(templatePath))
            throw new FileNotFoundException($"Šablóna nenájdená: {templatePath}");

        var template = await File.ReadAllTextAsync(templatePath, Encoding.UTF8);

        using var smtp = await GetConnectedSmtpClientAsync();

        foreach (var toEmail in emails)
        {
            var email = new MimeMessage();
            email.From.Add(new MailboxAddress("CheckIn System", from));
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = $"Pozvánka na Check-in od {authorName}";

            // Vytvorenie linku na tvoj web
            var baseUrl = configuration["ClientUrl"];
            var inviteLink = $"{baseUrl}{taskHash}";

            var bodyBuilder = new BodyBuilder
            {
                HtmlBody = template
                    .Replace("{AuthorName}", authorName)
                    .Replace("{TaskTitle}", taskTitle)
                    .Replace("{Link}", inviteLink)
            };
            email.Body = bodyBuilder.ToMessageBody();

            try
            {
                await smtp.SendAsync(email);
                // 3. Delay medzi mailami (0.5 sekundy)
                await Task.Delay(500);
            }
            catch (Exception ex)
            {
                // Ak jeden zlyhá, zapíš do logu a pokračuj ďalším
                Console.WriteLine($"Chyba pri posielaní mailu na {toEmail}: {ex.Message}");
            }
        }

        await smtp.DisconnectAsync(true);
    }

    public List<string> ParseEmails(string rawText)
    {
        if (string.IsNullOrWhiteSpace(rawText)) return new List<string>();

        var regex = new Regex(@"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}", RegexOptions.Compiled);

        return regex.Matches(rawText)
            .Select(m => m.Value.ToLower().Trim())
            .Distinct()
            .ToList();
    }
}