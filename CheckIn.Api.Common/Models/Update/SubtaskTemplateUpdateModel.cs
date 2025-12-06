using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record SubtaskTemplateUpdateModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string Title { get; init; }
	public string? Description { get; init; }
}