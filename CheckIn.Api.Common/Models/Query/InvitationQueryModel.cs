using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

/// <summary>
/// Query parameters for filtering and paginating task invitations.
/// </summary>
public record InvitationQueryModel : IPageableQuery
{
    /// <summary>
    /// The page number to retrieve. Defaults to 1.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// The number of items to retrieve per page. Defaults to 10.
    /// </summary>
    public int PageSize { get; set; } = 10;

    /// <summary>
    /// Optional identifier to filter invitations by a specific task.
    /// </summary>
    public Guid? TaskId { get; set; }
}