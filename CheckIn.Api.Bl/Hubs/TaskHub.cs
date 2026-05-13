using Microsoft.AspNetCore.SignalR;

namespace CheckIn.Api.Bl.Hubs;

/// <summary>
/// SignalR Hub for handling real-time communication between the server and clients.
/// Manages task-specific and user-specific notification groups.
/// </summary>
public class TaskHub : Hub
{
    /// <summary>
    /// Adds a client connection to a specific task group to receive real-time updates for that task.
    /// </summary>
    public async Task JoinTaskRoom(string taskId)
    {
        // Normalize the room name by trimming whitespace and converting to lowercase
        var roomName = taskId.Trim().ToLower();
        await Groups.AddToGroupAsync(Context.ConnectionId, roomName);
    }

    /// <summary>
    /// Removes a client connection from a specific task group.
    /// </summary>
    public async Task LeaveTaskRoom(string taskId)
    {
        var roomName = taskId.Trim().ToLower();
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomName);
    }

    /// <summary>
    /// Adds a client to a private user-specific room, used for dashboard-wide notifications (e.g., author updates).
    /// </summary>
    public async Task JoinUserRoom(string userId)
    {
        // Construct a unique group name for the specific user
        var groupName = $"User_{userId.ToLower()}";
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
    }
}