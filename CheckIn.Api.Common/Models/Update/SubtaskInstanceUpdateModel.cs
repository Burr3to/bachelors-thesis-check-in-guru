using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record SubtaskInstanceUpdateModel : IEntityModel
{
	public Guid Id { get; init; }
	public bool IsCompleted { get; init; } // Ak by sa stav menil cez PUT namiesto Complete endpointu
	public Guid? AssignedToUserId { get; init; }
}