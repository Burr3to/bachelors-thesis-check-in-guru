using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Query;

// CheckIn.Api.Common.Models.Query.SubtaskInstanceQuery.cs
public record SubtaskInstanceQuery : IPageableQuery
{
	public int PageNumber { get; set; } = 1;
	public int PageSize { get; set; } = 10;

	// Filter: Inštancie pre konkrétnu šablónu
	public Guid? TemplateSubtaskId { get; init; }

	// Filter: Inštancie priradené k tomuto užívateľovi (pre zobrazenie "Moje subtasky")
	public Guid? AssignedToUserId { get; init; }

	// Filter: Stav splnenia
	public bool? IsCompleted { get; init; }
}