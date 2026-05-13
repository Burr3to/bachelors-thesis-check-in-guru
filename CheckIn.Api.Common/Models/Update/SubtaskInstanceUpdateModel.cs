using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record SubtaskInstanceUpdateModel : IEntityModel
{
    public Guid Id { get; init; }
    public bool IsCompleted { get; init; }
    public Guid? AssignedToUserId { get; init; }
}