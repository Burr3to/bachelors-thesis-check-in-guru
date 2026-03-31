using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record InvitationListModel : IEntityModel
{
    public Guid Id { get; init; }
    public string Email { get; init; } = null!;
    public Guid TaskId { get; init; }
    public string? TaskTitle { get; init; }
    public bool IsAccepted { get; init; }
    public DateTime SentAt { get; init; }
}