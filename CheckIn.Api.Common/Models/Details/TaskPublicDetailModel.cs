using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Models.Lists;
using TaskStatus = System.Threading.Tasks.TaskStatus;

namespace CheckIn.Api.Common.Models.Details;

public record TaskPublicDetailModel : IEntityModel
{
    public Guid Id { get; init; }
    public string Hash { get; set; } = null!;
    public required string Title { get; init; }
    public string? Notes { get; init; }
    public DateTime DeadLine { get; init; }
    public TaskState State { get; init; }
    public SubtaskMode SubtaskMode { get; init; }
    public bool RequiresAuthenticationToComplete { get; init; }
    public string? AllowedDomain { get; init; }
    public List<SubtaskCombinedListModel> Subtasks { get; init; } = new();
    public bool IsForbidden { get; set; }
    public string? ForbiddenMessage { get; set; }
}