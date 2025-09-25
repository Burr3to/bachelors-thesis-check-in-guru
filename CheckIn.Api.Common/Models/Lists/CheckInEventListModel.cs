using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public record CheckInEventListModel : IEntityModel
{
    public Guid Id { get; init; }
    public required string Title { get; init; }
    public required string Hash { get; init; }
    public DateTime CreatedAt { get; init; }
    public Guid OwnerId { get; init; }
}