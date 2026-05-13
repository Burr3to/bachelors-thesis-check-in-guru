using System.ComponentModel.DataAnnotations;

namespace CheckIn.Api.Common.Models.Action;

public record BulkSubtaskCompleteModel
{
    public required List<Guid> InstanceIds { get; init; }

    [Required] [MaxLength(255)] public required string RespondentName { get; init; }
}