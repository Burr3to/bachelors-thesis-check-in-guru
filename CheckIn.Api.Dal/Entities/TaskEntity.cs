using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

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

	public Guid CreadtedById { get; set; }

	public UserEntity CreatedBy { get; set; } = default!;
	public ICollection<TaskResponseEntity> Responses { get; set; } = new List<TaskResponseEntity>();
}