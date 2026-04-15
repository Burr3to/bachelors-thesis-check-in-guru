using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Models.Create;

public record TaskCreateModel
{
    public required string Title { get; init; }
    public string? Notes { get; init; }
    public DateTime DeadLine { get; init; }


    public required SubtaskMode SubtaskMode { get; init; }
    public List<SubtaskTemplateCreateModel> Subtasks { get; init; } = new();
    public bool RequiresAuthenticationToComplete { get; init; } = true;
    public bool SendInvitesImmediately { get; init; } = false;

    public List<string> InvitedEmails { get; set; } = new();
}