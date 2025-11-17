namespace CheckIn.Api.Common.Models.Create;

public class CheckInResponseCreateModel
{
	public required string RespondentName { get; set; }
	public required string Comment { get; set; }
	public Guid CheckInId { get; set; } // TODO rename to TaskId
}