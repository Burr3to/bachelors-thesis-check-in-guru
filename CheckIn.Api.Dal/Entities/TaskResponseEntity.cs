using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class TaskResponseEntity : IEntity
{
	public Guid Id { get; set; }
	[MaxLength(255)] public required string RespondentName { get; set; }
	[MaxLength(255)] public required string Comment { get; set; }
	public DateTime SubmittedAt { get; set; }

	public Guid TaskId { get; set; }

	public TaskEntity Task { get; set; } = default!;
}