using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record CheckInResponseDetailModel : CheckInResponseListModel
{
	public Guid CheckInId { get; init; }
	public CheckInEventDetailModel CheckInEvent { get; init; } = default!;
	
}