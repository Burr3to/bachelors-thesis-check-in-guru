namespace CheckIn.Api.Common.Models.Create;

public class CheckInEventCreateModel
{
	public required string Title { get; set; }
	public string? Notes { get; set; }
	public DateTime DeadLine { get; set; }
}