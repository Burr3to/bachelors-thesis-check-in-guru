using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// Represents the actual execution or "check" of a subtask.
/// Depending on the mode, this can be private to a user or shared among everyone.
/// </summary>
public class SubtaskInstanceEntity : IEntity
{
    public Guid Id { get; set; }

    /// <summary>
    /// Groups multiple instances together for a single participant's response set.
    /// </summary>
    public Guid ResponseGroupId { get; set; }

    [MaxLength(255)] public string? RespondentName { get; set; }
    [MaxLength(255)] public string? Comment { get; set; }

    /// <summary>
    /// Foreign key to the blueprint (template) this instance is based on.
    /// </summary>
    public Guid TemplateSubtaskId { get; set; }

    public SubtaskTemplateEntity? TemplateSubtask { get; set; }

    /// <summary>
    /// Identifier of the user assigned to this instance (used in Individual mode).
    /// Is null if the instance is shared or anonymous.
    /// </summary>
    public Guid? AssignedToUserId { get; set; }

    [MaxLength(255)] public string? AssignedToEmail { get; set; }

    public bool IsCompleted { get; set; } = false;

    /// <summary>
    /// Tracks which specific user performed the completion action.
    /// </summary>
    public Guid? CompletedByUserId { get; set; }

    public DateTime? CompletedAt { get; set; }
}