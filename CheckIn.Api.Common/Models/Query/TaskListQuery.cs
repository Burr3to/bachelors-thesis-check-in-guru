using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Models.Query;

public record TaskListQuery : ListQuery
{
    public TaskState? Status { get; init; }
    public SubtaskMode? Mode { get; init; }
    public bool? RequiresAuth { get; init; }
    public bool? OnlyOverdue { get; init; }
    public bool? OnlyActive { get; init; }
    public DateTime? DeadLineBefore { get; init; }
    public DateTime? DeadLineAfter { get; init; }
}