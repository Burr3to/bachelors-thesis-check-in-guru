using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using CheckIn.Api.Bl.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;
using DnsClient;

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

    public async Task SendBulkEmailsAsync(List<string> emails, string taskHash, string authorName, string taskTitle,
        string? taskDescription)
    {
        var from = configuration["EmailSettings:Email"];

        var templatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "Invitation.html");

        if (!File.Exists(templatePath))
            throw new FileNotFoundException($"Šablóna nenájdená: {templatePath}");

        var template = await File.ReadAllTextAsync(templatePath, Encoding.UTF8);

        using var smtp = await GetConnectedSmtpClientAsync();

        var plainDescription = StripQuillDeltaToPlainText(taskDescription ?? "");
        var htmlDescription = plainDescription.Replace("\r\n", "<br>").Replace("\n", "<br>");

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
                    .Replace("{TaskDescription}", string.IsNullOrWhiteSpace(htmlDescription)
                        ? ""
                        : $"<p style='color: #666;'>{htmlDescription}</p>")
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

    public async Task<bool> IsDomainValidAsync(string email)
    {
        try
        {
            var host = email.Split('@').Last();
            var lookup = new LookupClient();
            var result = await lookup.QueryAsync(host, QueryType.MX);

            // Musí existovať aspoň jeden MX záznam a nesmie tam byť DNS chyba
            return !result.HasError && result.Answers.MxRecords().Any();
        }
        catch
        {
            return false;
        }
    }

    public string StripQuillDeltaToPlainText(string deltaJson)
    {
        if (string.IsNullOrWhiteSpace(deltaJson)) return string.Empty;

        // Ak to nie je JSON (nezačína [ alebo {), vráť to ako čistý text
        if (!deltaJson.Trim().StartsWith("[") && !deltaJson.Trim().StartsWith("{"))
            return deltaJson;

        try
        {
            using var doc = JsonDocument.Parse(deltaJson);
            JsonElement opsElement;

            // Prípad 1: Dáta sú priamo pole [ {"insert":...}, ... ] -> toto je tvoj prípad
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                opsElement = doc.RootElement;
            }
            // Prípad 2: Dáta sú objekt { "ops": [ ... ] }
            else if (doc.RootElement.ValueKind == JsonValueKind.Object &&
                     doc.RootElement.TryGetProperty("ops", out var opsProp))
            {
                opsElement = opsProp;
            }
            else
            {
                return deltaJson; // Neznámy formát, vráť surové
            }

            var textBuilder = new StringBuilder();
            foreach (var op in opsElement.EnumerateArray())
            {
                if (op.TryGetProperty("insert", out var insertProp))
                {
                    // Quill v 'insert' môže mať string (text) alebo objekt (obrázok/video)
                    if (insertProp.ValueKind == JsonValueKind.String)
                    {
                        textBuilder.Append(insertProp.GetString());
                    }
                }
            }

            return textBuilder.ToString().Trim();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Chyba pri parsovaní Quill Delta: {ex.Message}");
            return deltaJson;
        }
    }
}