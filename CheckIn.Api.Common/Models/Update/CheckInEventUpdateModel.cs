using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public class CheckInEventUpdateModel : IEntityModel
{
	public Guid Id { get; set; }
	public required string Title { get; set; }
	public string? Notes { get; set; }
	public DateTime DeadLine { get; set; }
}