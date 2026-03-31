using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public record InvitationUpdateModel : IEntityModel
{
    public Guid Id { get; init; }
    public bool IsAccepted { get; init; }
}