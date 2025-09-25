using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class CheckInEventEntity : IEntity
{
	public Guid Id { get; set; }
	public required string Title { get; set; }
	public required string Hash { get; set; }
	public string? Notes { get; set; }
	public DateTime CreatedAt { get; set; }

	// Cudzí kľúč
	public Guid OwnerId { get; set; }

	// Navigačné vlastnosti pre EF Core
	public UserEntity Owner { get; set; } = default!;
	public ICollection<CheckInResponseEntity> Responses { get; set; } = new List<CheckInResponseEntity>();
}