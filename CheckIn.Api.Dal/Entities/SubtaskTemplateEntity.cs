using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class SubtaskTemplateEntity : IEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;

    [MaxLength(255)] public required string Title { get; set; }
    public string? Description { get; set; }
    public bool IsGeneratedFromTask { get; set; }

    // FK na Parent Task
    public Guid ParentTaskId { get; set; }
    public TaskEntity? ParentTask { get; set; }

    // Kolekcia inštancií splnenia
    public ICollection<SubtaskInstanceEntity> Instances { get; set; } = new List<SubtaskInstanceEntity>();
}