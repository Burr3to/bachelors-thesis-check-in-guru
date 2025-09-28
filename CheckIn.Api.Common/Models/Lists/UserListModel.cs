using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public class UserListModel : IEntityModel
{
	public Guid Id { get; set; }
	public required string GoogleId { get; set; }
	public required string Email { get; set; }
	public required string Name { get; set; }
}