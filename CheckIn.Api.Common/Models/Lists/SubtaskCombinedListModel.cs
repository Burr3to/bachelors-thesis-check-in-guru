using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record SubtaskCombinedListModel : IEntityModel
{
	// Dáta zo SubtaskInstanceEntity
	public Guid Id { get; init; } // Toto je ID inštancie! (pre kliknutie Complete)
	public bool IsCompleted { get; init; }
	[MaxLength(255)] public string? RespondentName { get; init; }
	[MaxLength(255)] public string? Comment { get; init; }
	public Guid? AssignedToUserId { get; init; }
	public Guid? CompletedByUserId { get; init; }
	public DateTime? CompletedAt { get; init; }

	// Dáta zo SubtaskTemplateEntity
	public required string Title { get; init; }
	public string? Description { get; init; }
	public Guid TemplateSubtaskId { get; init; } // ID šablóny, ak by sme ju potrebovali
}