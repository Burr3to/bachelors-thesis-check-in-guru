namespace CheckIn.Api.Common.Results;

/// <summary>
/// A standardized wrapper for paginated data responses.
/// </summary>
/// <typeparam name="T">The type of items in the list.</typeparam>
public record QueryResult<T>
{
    /// <summary>
    /// The collection of items for the current page.
    /// </summary>
    public required IEnumerable<T> Items { get; init; }

    /// <summary>
    /// The total count of items matching the filter (ignoring pagination).
    /// </summary>
    public required int TotalCount { get; init; }

    /// <summary>
    /// The current page index.
    /// </summary>
    public required int PageNumber { get; init; }

    /// <summary>
    /// The number of items per page.
    /// </summary>
    public required int PageSize { get; init; }
}