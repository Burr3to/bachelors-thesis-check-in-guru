using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

/// <summary>
/// Base record for paginated and sortable list queries.
/// </summary>
public record ListQuery : IPageableQuery
{
    // Pagination parameters
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;

    // Sorting parameters
    public string? SortBy { get; init; }
    public bool SortDesc { get; init; } = false;

    // General filter parameters
    public string? NameContains { get; init; }
    public DateTime? CreatedAfter { get; init; }
}