using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class CheckInResponseEntity : IEntity
{
	public Guid Id { get; set; }
	public required string RespondentName { get; set; }
	public required string Comment { get; set; }
	public DateTime SubmittedAt { get; set; }

	// Cudzí kľúč
	public Guid CheckInId { get; set; }

	// Navigačná vlastnosť pre EF Core
	public CheckInEventEntity CheckInEvent { get; set; } = default!;
}