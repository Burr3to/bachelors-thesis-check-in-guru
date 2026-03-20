using System.ComponentModel.DataAnnotations;
using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

public class SubtaskInstanceEntity : IEntity
{
    public Guid Id { get; set; }

    public Guid ResponseGroupId { get; set; }
    [MaxLength(255)] public string? RespondentName { get; set; }
    [MaxLength(255)] public string? Comment { get; set; }

    // FK na Subtask Šablónu
    public Guid TemplateSubtaskId { get; set; }
    public SubtaskTemplateEntity? TemplateSubtask { get; set; }

    // Kľúčové pre Individual/Shared režim: Kto má túto inštanciu splniť?
    // NULL, ak ide o zdieľanú inštanciu pre celú skupinu.
    public Guid? AssignedToUserId { get; set; }

    public bool IsCompleted { get; set; } = false;

    // Kto to skutočne splnil (pre audit/zdielany rezim)
    public Guid? CompletedByUserId { get; set; }
    public DateTime? CompletedAt { get; set; }
}