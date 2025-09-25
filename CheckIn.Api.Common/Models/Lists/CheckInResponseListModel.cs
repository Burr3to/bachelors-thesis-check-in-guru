using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record CheckInResponseListModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string RespondentName { get; init; }
	public required string Comment { get; init; }
	public DateTime SubmittedAt { get; init; }
}