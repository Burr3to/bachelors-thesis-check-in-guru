using Microsoft.AspNetCore.SignalR;

namespace CheckIn.Api.Bl.Hubs;

public class TaskHub : Hub
{
    // Táto metóda umožní Flutteru povedať: "Sledujem úlohu č. 5"
    public async Task JoinTaskRoom(string taskId)
    {
        // Očistíme ID: trim odstráni medzery, ToLower zabezpečí malé písmená
        var roomName = taskId.Trim().ToLower();
        await Groups.AddToGroupAsync(Context.ConnectionId, roomName);

        Console.WriteLine($"[SIGNALR] Autor vstúpil do ROOM: '{roomName}'");
    }

    // Flutter môže povedať: "Už nesledujem úlohu č. 5"
    public async Task LeaveTaskRoom(string taskId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, taskId);
    }

    public async Task JoinUserRoom(string userId)
    {
        var groupName = $"User_{userId.ToLower()}";
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
        Console.WriteLine($"[SIGNALR] Autor vstúpil do svojej USER ROOM: '{groupName}'");
    }
}