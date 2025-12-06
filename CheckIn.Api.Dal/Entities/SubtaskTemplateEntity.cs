using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class SubtaskTemplateEntity : IEntity
{
	public Guid Id { get; set; }


	[MaxLength(255)] public required string Title { get; set; }
	[MaxLength(255)] public string? Description { get; set; }

	// FK na Parent Task
	public Guid ParentTaskId { get; set; }
	public TaskEntity? ParentTask { get; set; }

	// Kolekcia inštancií splnenia
	public ICollection<SubtaskInstanceEntity> Instances { get; set; } = new List<SubtaskInstanceEntity>();
}