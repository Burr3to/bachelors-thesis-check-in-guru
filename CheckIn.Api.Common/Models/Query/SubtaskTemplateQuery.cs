using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

public record SubtaskTemplateQuery : IPageableQuery
{
	public int PageNumber { get; set; } = 1;
	public int PageSize { get; set; } = 10;

	// Kľúčový filter: Chcem šablóny pre daný Task
	public Guid? ParentTaskId { get; init; }

	// Ostatné filtre (Title, SortBy atď.)
}