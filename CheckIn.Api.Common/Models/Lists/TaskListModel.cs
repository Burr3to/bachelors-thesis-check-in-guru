using CheckIn.Api.Common.Models.Interfaces;
using TaskStatus = CheckIn.Api.Common.Enums.TaskStatus;


namespace CheckIn.Api.Common.Models.Lists;

public record TaskListModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string Title { get; init; }
	public required string Hash { get; init; }
	public DateTime CreatedAt { get; init; }
	public DateTime DeadLine { get; init; }
	public TaskStatus Status { get; init; }
	public Guid CreatedById { get; init; }
}