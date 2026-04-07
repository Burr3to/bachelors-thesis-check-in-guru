using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Models.Details;

public record TaskDetailModel : TaskListModel
{
    public List<SubtaskTemplateListModel> Subtasks { get; init; } = new();
    public List<InvitationListModel> Invitations { get; init; } = new();
}