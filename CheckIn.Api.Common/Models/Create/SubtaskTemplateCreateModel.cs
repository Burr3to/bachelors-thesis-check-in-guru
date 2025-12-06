namespace CheckIn.Api.Common.Models.Create;

public record SubtaskTemplateCreateModel
{
	public required string Title { get; init; }
	public string? Description { get; init; }
	public Guid ParentTaskId { get; init; }
}