namespace CheckIn.Api.Common.Models.Query;

public record TaskResponseListQuery : ListQuery
{
	public Guid? CheckInEventId { get; init; }
}