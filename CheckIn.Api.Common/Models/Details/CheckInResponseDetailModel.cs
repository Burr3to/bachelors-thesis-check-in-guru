using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public class CheckInResponseDetailModel : CheckInResponseListModel
{
	public Guid CheckInId { get; set; }
	public CheckInEventDetailModel CheckInEvent { get; set; } = default!;
	
}