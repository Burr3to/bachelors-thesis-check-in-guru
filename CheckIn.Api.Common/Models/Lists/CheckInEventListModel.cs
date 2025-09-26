using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public class CheckInEventListModel : IEntityModel
{
    public Guid Id { get; set; }
    public required string Title { get; set; }
    public required string Hash { get; set; }
    public DateTime CreatedAt { get; set; }
    public Guid OwnerId { get; set; }
}