using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Interfaces;


namespace CheckIn.Api.Common.Models.Lists;

public record TaskListModel : IEntityModel
{
    public Guid Id { get; init; }
    public required string Title { get; init; }
    public string? Notes { get; init; }

    public required string Hash { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime LastModifiedAt { get; init; }
    public DateTime DeadLine { get; init; }
    public TaskState State { get; init; }
    public Guid CreatedById { get; init; }
    public SubtaskMode SubtaskMode { get; init; }
    public bool RequiresAuthenticationToComplete { get; init; } = true;
}