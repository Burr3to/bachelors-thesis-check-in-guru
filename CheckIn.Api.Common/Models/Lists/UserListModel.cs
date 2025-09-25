using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record UserListModel : IEntityModel
{
	public Guid Id { get; init; }
	public required string Email { get; init; }
	public required string Name { get; init; }
}