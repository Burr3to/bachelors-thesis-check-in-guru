using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record SubtaskCombinedListModel : IEntityModel
{
    public Guid Id { get; init; }
    public bool IsCompleted { get; init; }
    public Guid ResponseGroupId { get; set; }
    [MaxLength(255)] public string? RespondentName { get; init; }
    [MaxLength(255)] public string? Comment { get; init; }
    public Guid? AssignedToUserId { get; init; }

    [MaxLength(255)] public string? AssignedToEmail { get; set; }
    public Guid? CompletedByUserId { get; init; }
    public DateTime? CompletedAt { get; init; }
    public bool IsGeneratedFromTask { get; set; }
    public DateTime CreatedAt { get; init; }
    public DateTime Deadline { get; init; }

    public required string Title { get; init; }
    public string? Description { get; init; }
    public Guid TemplateSubtaskId { get; init; }
}