namespace CheckIn.Api.Common.Models.Interfaces;

/// <summary>
/// Interface defining standard pagination parameters for list-based API queries.
/// </summary>
public interface IPageableQuery
{
    /// <summary>
    /// The index of the requested page (typically starting from 1).
    /// </summary>
    int PageNumber { get; set; }

    /// <summary>
    /// The maximum number of items to return in a single page.
    /// </summary>
    int PageSize { get; set; }
}