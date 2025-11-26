namespace CheckIn.Api.Common.Models.Create;

public record TaskCreateModel
{
	public required string Title { get; init; }
	public string? Notes { get; init; }
	public DateTime DeadLine { get; init; }
}