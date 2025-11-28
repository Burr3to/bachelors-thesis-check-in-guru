using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using CheckIn.Api.Common.Enums;
using TaskStatus = CheckIn.Api.Common.Enums.TaskStatus;

namespace CheckIn.Api.Dal.Entities;

public class TaskEntity : IEntity
{
	public Guid Id { get; set; }
	public required string Title { get; set; }
	public required string Hash { get; set; }
	public string? Notes { get; set; }
	public DateTime CreatedAt { get; set; }
	public DateTime DeadLine { get; set; }
	public TaskStatus Status { get; set; }

	public Guid CreatedById { get; set; }

	public UserEntity CreatedBy { get; set; } = null!;
	public ICollection<TaskResponseEntity> Responses { get; set; } = new List<TaskResponseEntity>();
}