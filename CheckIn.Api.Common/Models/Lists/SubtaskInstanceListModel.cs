using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record SubtaskInstanceListModel : IEntityModel
{
    public Guid Id { get; init; }
    public Guid TemplateSubtaskId { get; init; }
    public Guid? AssignedToUserId { get; init; }
    public string? AssignedToEmail { get; set; }
    public Guid ResponseGroupId { get; init; }
    public bool IsCompleted { get; init; }
    public Guid? CompletedByUserId { get; init; }
    public DateTime? CompletedAt { get; init; }
}