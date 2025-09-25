using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class UserEntity : IEntity
{
	public Guid Id { get; set; }

	public required string GoogleId { get; set; }
	public required string Email { get; set; }
	public required string Name { get; set; }

	public ICollection<CheckInEventEntity> CreatedCheckIns { get; set; } = new List<CheckInEventEntity>();
}