using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record TaskResponseDetailModel : TaskResponseListModel
{
	public Guid CheckInId { get; init; }
	public TaskDetailModel Task { get; init; } = default!;
}