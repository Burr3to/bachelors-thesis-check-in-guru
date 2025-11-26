using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

public record ListQuery : IPageableQuery
{
	// Paginácia
	public int PageNumber { get; set; } = 1;
	public int PageSize { get; set; } = 10;

	// Triedenie
	public string? SortBy { get; init; }
	public bool SortDesc { get; init; } = false;

	// Filtre 
	public string? NameContains { get; init; }
	public string? Status { get; init; }
	public DateTime? CreatedAfter { get; init; }
}