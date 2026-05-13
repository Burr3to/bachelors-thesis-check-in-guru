namespace CheckIn.Api.Common.Models.Create;

public record SubtaskInstanceCreateModel
{
    public required Guid TemplateSubtaskId { get; init; }
    public Guid? AssignedToUserId { get; init; }
}