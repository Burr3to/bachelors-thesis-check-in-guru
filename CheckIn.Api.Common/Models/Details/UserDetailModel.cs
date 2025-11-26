using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record UserDetailModel : UserListModel
{
	public ICollection<TaskDetailModel> CreatedCheckIns { get; init; } = new List<TaskDetailModel>();
}