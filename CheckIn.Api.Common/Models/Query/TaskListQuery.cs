using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Models.Query;

public record TaskListQuery : ListQuery
{
    public TaskState? Status { get; init; }
    public SubtaskMode? Mode { get; init; }
    public bool? RequiresAuth { get; init; }

    public string? RespondentEmail { get; init; }
    public DateTime? DeadLineBefore { get; init; }
    public DateTime? DeadLineAfter { get; init; }
}