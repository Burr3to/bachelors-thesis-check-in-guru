namespace CheckIn.Api.Common.Models.Create;

public record SubtaskInstanceCreateModel
{
	public required Guid TemplateSubtaskId { get; init; }

	// Ak sa manuálne vytvára Individuálna kópia:
	public Guid? AssignedToUserId { get; init; }
}