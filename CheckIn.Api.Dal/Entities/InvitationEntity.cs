using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// Represents a participant invitation for a specific task.
/// Tracks email dispatch, user engagement, and overall completion status.
/// </summary>
public class InvitationEntity : IEntity
{
    public Guid Id { get; set; }

    /// <summary>
    /// The email address of the invited user.
    /// </summary>
    public string Email { get; set; } = null!;

    /// <summary>
    /// Foreign key to the parent Task.
    /// </summary>
    public Guid TaskId { get; set; }

    public TaskEntity? Task { get; set; }

    /// <summary>
    /// Indicates if the invitation email has been successfully dispatched.
    /// </summary>
    public bool IsSent { get; set; }

    /// <summary>
    /// Indicates if the user has interacted with the task (e.g., opened the link).
    /// </summary>
    public bool IsAccepted { get; set; }

    /// <summary>
    /// Indicates if the user has completed their assigned portion of the task.
    /// In Individual mode, this means all their instances are done.
    /// In Shared mode, this means they have completed at least one instance.
    /// </summary>
    public bool IsCompleted { get; set; }

    /// <summary>
    /// Timestamp of when the invitation email was sent.
    /// </summary>
    public DateTime? SentAt { get; set; }
}