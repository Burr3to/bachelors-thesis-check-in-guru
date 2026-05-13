using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// Represents the definition or "blueprint" of a subtask within a task.
/// Actual completions are tracked via SubtaskInstanceEntity.
/// </summary>
public class SubtaskTemplateEntity : IEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;

    [MaxLength(255)] public required string Title { get; set; }
    public string? Description { get; set; }

    /// <summary>
    /// Flag indicating if this subtask was automatically created from the main task title.
    /// </summary>
    public bool IsGeneratedFromTask { get; set; }

    /// <summary>
    /// Foreign key to the parent Task.
    /// </summary>
    public Guid ParentTaskId { get; set; }

    public TaskEntity? ParentTask { get; set; }

    /// <summary>
    /// Collection of execution instances generated from this template.
    /// </summary>
    public ICollection<SubtaskInstanceEntity> Instances { get; set; } = new List<SubtaskInstanceEntity>();
}