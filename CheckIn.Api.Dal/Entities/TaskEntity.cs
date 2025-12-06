using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using CheckIn.Api.Common.Enums;
using TaskStatus = CheckIn.Api.Common.Enums.TaskStatus;

namespace CheckIn.Api.Dal.Entities;

public class TaskEntity : IEntity
{
	public Guid Id { get; set; }
	[MaxLength(255)] public required string Title { get; set; }
	[MaxLength(512)] public required string Hash { get; set; }
	[MaxLength(1024)] public string? Notes { get; set; }
	public DateTime CreatedAt { get; set; }
	public DateTime DeadLine { get; set; }
	public TaskStatus Status { get; set; }

	public SubtaskMode SubtaskMode { get; set; }
	public ICollection<SubtaskTemplateEntity> Subtasks { get; set; } = new List<SubtaskTemplateEntity>();
	public bool RequiresAuthenticationToComplete { get; set; } = true;

	// public ICollection<UserTaskAssignment> Assignments { get; set; } = new List<UserTaskAssignment>();

	public Guid CreatedById { get; set; }
	public UserEntity CreatedBy { get; set; } = null!;
}