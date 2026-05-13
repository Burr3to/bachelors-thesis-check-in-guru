using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

/// <summary>
/// Query parameters for filtering and paginating subtask execution instances.
/// </summary>
public record SubtaskInstanceQuery : IPageableQuery
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;

    // Filter: Instances derived from a specific blueprint template
    public Guid? TemplateSubtaskId { get; init; }

    // Filter: Instances assigned to a specific user (useful for "My Subtasks" views)
    public Guid? AssignedToUserId { get; init; }

    // Filter: Filter by completion state
    public bool? IsCompleted { get; init; }
}