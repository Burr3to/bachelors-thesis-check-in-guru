namespace CheckIn.Api.Bl.Services.Interfaces;

public interface IUserContext
{
    Guid? GetUserId();
    string? GetName();
    string? GetEmail();
}