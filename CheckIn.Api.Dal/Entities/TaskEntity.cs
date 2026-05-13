using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// The primary entity representing a Check-in task or checklist.
/// </summary>
public class TaskEntity : IEntity
{
    public Guid Id { get; set; }
    [MaxLength(255)] public required string Title { get; set; }

    /// <summary>
    /// Unique hash used for public URLs and sharing.
    /// </summary>
    [MaxLength(512)]
    public required string Hash { get; set; }

    /// <summary>
    /// Optional domain restriction (e.g., "vutbr.cz") to limit access to specific organizations.
    /// </summary>
    [MaxLength(100)]
    public string? AllowedDomain { get; set; }

    /// <summary>
    /// Rich text description stored as a Delta JSON string (Quill editor format).
    /// </summary>
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime LastModifiedAt { get; set; }
    public DateTime DeadLine { get; set; }
    public TaskState State { get; set; }

    /// <summary>
    /// Logic mode: Shared (collaborative) or Individual (personal copies).
    /// </summary>
    public SubtaskMode SubtaskMode { get; set; }

    /// <summary>
    /// List of blueprint subtasks defined for this task.
    /// </summary>
    public ICollection<SubtaskTemplateEntity> Subtasks { get; set; } = new List<SubtaskTemplateEntity>();

    /// <summary>
    /// Security flag: if true, participants must log in to check off items.
    /// </summary>
    public bool RequiresAuthenticationToComplete { get; set; } = true;

    /// <summary>
    /// List of users invited to this task.
    /// </summary>
    public ICollection<InvitationEntity> Invitations { get; set; } = new List<InvitationEntity>();

    /// <summary>
    /// Foreign key to the task author.
    /// </summary>
    public Guid CreatedById { get; set; }

    public UserEntity CreatedBy { get; set; } = null!;
}