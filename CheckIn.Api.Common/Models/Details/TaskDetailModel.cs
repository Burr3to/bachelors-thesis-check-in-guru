using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record TaskDetailModel : TaskListModel
{
	public string? Notes { get; init; }
	public ICollection<TaskResponseListModel> Responses { get; init; } = new List<TaskResponseListModel>();
}