using CheckIn.Api.Common.Models.Interfaces;

namespace CheckIn.Api.Common.Models.Update;

public class CheckInResponseUpdateModel : IEntityModel
{
	public Guid Id { get; set; }
	public required string RespondentName { get; set; }
	public required string Comment { get; set; }
}