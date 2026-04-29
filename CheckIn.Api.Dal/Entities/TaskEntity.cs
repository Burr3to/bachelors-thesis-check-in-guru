using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;
using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Dal.Entities;

public class TaskEntity : IEntity
{
    public Guid Id { get; set; }
    [MaxLength(255)] public required string Title { get; set; }

    [MaxLength(512)] public required string Hash { get; set; }

    [MaxLength(100)] public string? AllowedDomain { get; set; }

    //Delta Json string
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastModifiedAt { get; set; }
    public DateTime DeadLine { get; set; }
    public TaskState State { get; set; }

    public SubtaskMode SubtaskMode { get; set; }
    public ICollection<SubtaskTemplateEntity> Subtasks { get; set; } = new List<SubtaskTemplateEntity>();
    public bool RequiresAuthenticationToComplete { get; set; } = true;

    public ICollection<InvitationEntity> Invitations { get; set; } = new List<InvitationEntity>();

    public Guid CreatedById { get; set; }
    public UserEntity CreatedBy { get; set; } = null!;
}