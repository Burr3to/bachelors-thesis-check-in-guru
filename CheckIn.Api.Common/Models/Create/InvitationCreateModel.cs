namespace CheckIn.Api.Common.Models.Create;

public class InvitationCreateModel
{
    public required string Email { get; set; }
    public Guid TaskId { get; set; }
}