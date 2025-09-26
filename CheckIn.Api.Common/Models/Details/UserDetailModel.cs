using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public class UserDetailModel : UserListModel
{
	public ICollection<CheckInEventDetailModel> CreatedCheckIns { get; set; } = new List<CheckInEventDetailModel>();
}