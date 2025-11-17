using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

public class ListQuery: IPageableQuery 
{
    // Paginácia
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;

    // Triedenie
    public string? SortBy { get; set; }
    public bool SortDesc { get; set; } = false;

    // Filtre 
    public string? NameContains { get; set; }
    public string? Status { get; set; }
    public DateTime? CreatedAfter { get; set; }

}