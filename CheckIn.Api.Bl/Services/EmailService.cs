using System.Text.RegularExpressions;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;

namespace CheckIn.Api.Bl.Services;

public class EmailService(IConfiguration configuration) : IEmailService
{
    public async Task SendEmailAsync(string toEmail, string subject, string htmlMessage)
    {
        var email = new MimeMessage();
        var from = configuration["EmailSettings:Email"];
        var password = configuration["EmailSettings:Password"];
        var host = configuration["EmailSettings:Host"];
        var port = int.Parse(configuration["EmailSettings:Port"] ?? "587");

        email.From.Add(new MailboxAddress("CheckIn System", from));
        email.To.Add(MailboxAddress.Parse(toEmail));
        email.Subject = subject;

        var builder = new BodyBuilder { HtmlBody = htmlMessage };
        email.Body = builder.ToMessageBody();

        using var smtp = new SmtpClient();
        // Pripojenie k Gmailu s použitím STARTTLS
        await smtp.ConnectAsync(host, port, SecureSocketOptions.StartTls);
        await smtp.AuthenticateAsync(from, password);
        await smtp.SendAsync(email);
        await smtp.DisconnectAsync(true);
    }

    public List<string> ParseEmails(string rawText)
    {
        if (string.IsNullOrWhiteSpace(rawText)) return new List<string>();

        // Regex na vyhľadanie mailov
        var regex = new Regex(@"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}", RegexOptions.Compiled);

        return regex.Matches(rawText)
            .Select(m => m.Value.ToLower().Trim()) // Všetko na malé písmená
            .Distinct() // Odstráni duplicity
            .ToList();
    }
}