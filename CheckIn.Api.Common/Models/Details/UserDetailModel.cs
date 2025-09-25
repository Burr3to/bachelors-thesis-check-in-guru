using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record UserDetailModel : UserListModel
{
	public ICollection<CheckInEventDetailModel> CreatedCheckIns { get; init; } = new List<CheckInEventDetailModel>();
}