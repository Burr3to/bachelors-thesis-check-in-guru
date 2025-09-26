using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public class CheckInEventDetailModel : CheckInEventListModel
{
	public string? Notes { get; set; }
	public ICollection<CheckInResponseListModel> Responses { get; set; } = new List<CheckInResponseListModel>();
}