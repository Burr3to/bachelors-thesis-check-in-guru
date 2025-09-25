using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record CheckInEventDetailModel : CheckInEventListModel
{
	public string? Notes { get; init; }
	public ICollection<CheckInResponseListModel> Responses { get; init; } = new List<CheckInResponseListModel>();
}