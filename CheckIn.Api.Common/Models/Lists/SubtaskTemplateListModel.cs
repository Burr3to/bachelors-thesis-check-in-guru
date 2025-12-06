using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record SubtaskTemplateListModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string Title { get; init; }
	public string? Description { get; init; }
	public Guid ParentTaskId { get; init; }
}