namespace CheckIn.Api.Common.Models.Query;

using TaskStatus = CheckIn.Api.Common.Enums.TaskStatus;

public record TaskListQuery : ListQuery
{
	public TaskStatus? Status { get; init; }

	// Filtrovanie podľa dátumu (Deadline)
	public DateTime? DeadLineBefore { get; init; }
	public DateTime? DeadLineAfter { get; init; }
}