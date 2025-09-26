using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Lists;

public class CheckInResponseListModel : IEntityModel
{
	public Guid Id { get; set; }
	public required string RespondentName { get; set; }
	public required string Comment { get; set; }
	public DateTime SubmittedAt { get; set; }
}