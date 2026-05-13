using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Models.Query;

/// <summary>
/// Extended query model specifically for filtering Task entities.
/// </summary>
public record TaskListQuery : ListQuery
{
    public TaskState? Status { get; init; }
    public SubtaskMode? Mode { get; init; }
    public bool? RequiresAuth { get; init; }

    // Search for tasks where a specific email is a participant
    public string? RespondentEmail { get; init; }

    // Filtering by deadline ranges
    public DateTime? DeadLineBefore { get; init; }
    public DateTime? DeadLineAfter { get; init; }
}