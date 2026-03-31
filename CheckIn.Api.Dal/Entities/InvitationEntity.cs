using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class InvitationEntity : IEntity
{
    public Guid Id { get; set; }
    public string Email { get; set; } = null!;
    public Guid TaskId { get; set; }
    public TaskEntity? Task { get; set; }

    public bool IsAccepted { get; set; } = false;
    public DateTime SentAt { get; set; }
}