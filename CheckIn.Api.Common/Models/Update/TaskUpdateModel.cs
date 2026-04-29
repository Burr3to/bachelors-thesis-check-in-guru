using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record TaskUpdateModel : IEntityModel
{
    public Guid Id { get; init; }
    public required string Title { get; init; }
    public string? Notes { get; init; }
    public string? AllowedDomain { get; set; }
    public DateTime DeadLine { get; init; }

    public List<string> InvitedEmails { get; init; } = new();
    public List<SubtaskTemplateCreateModel> Subtasks { get; init; } = new();
}