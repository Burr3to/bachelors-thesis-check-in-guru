using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record TaskUpdateModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string Title { get; init; }
	public string? Notes { get; init; }
	public DateTime DeadLine { get; init; }
}