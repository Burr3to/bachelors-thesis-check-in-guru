namespace CheckIn.Api.Common.Models.Query;

public record TaskListQuery : ListQuery
{
	public TaskStatus? Status { get; init; }

	// Filtrovanie podľa dátumu (Deadline)
	public DateTime? DeadLineBefore { get; init; }
	public DateTime? DeadLineAfter { get; init; }
}