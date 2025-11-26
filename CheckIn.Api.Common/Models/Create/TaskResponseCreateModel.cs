namespace CheckIn.Api.Common.Models.Create;

public record TaskResponseCreateModel
{
	public required string RespondentName { get; init; }
	public required string Comment { get; init; }
	public Guid TaskId { get; init; }
}