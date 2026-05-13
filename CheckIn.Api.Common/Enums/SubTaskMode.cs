namespace CheckIn.Api.Common.Enums;

/// <summary>
/// Defines how subtask instances are distributed and handled among invited participants.
/// </summary>
public enum SubtaskMode
{
    /// <summary>
    /// Collaborative mode where all users work on a single shared set of subtask instances.
    /// </summary>
    Shared = 0,

    /// <summary>
    /// Private mode where each invited user receives their own independent set of subtask instances.
    /// </summary>
    Individual = 1
}