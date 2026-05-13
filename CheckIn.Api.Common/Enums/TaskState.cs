namespace CheckIn.Api.Common.Enums;

/// <summary>
/// Represents the lifecycle stage or status of a task.
/// </summary>
public enum TaskState
{
    /// <summary>
    /// Task has been created but no action has been taken yet.
    /// </summary>
    Todo = 0,

    /// <summary>
    /// Task is currently active and within its deadline.
    /// </summary>
    InProgress = 1,

    /// <summary>
    /// Task has been successfully finished.
    /// </summary>
    Completed = 2,

    /// <summary>
    /// The deadline has passed without the task being completed.
    /// </summary>
    Missed = 3
}