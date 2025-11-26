using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record TaskResponseUpdateModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string RespondentName { get; init; }
	public required string Comment { get; init; }
}