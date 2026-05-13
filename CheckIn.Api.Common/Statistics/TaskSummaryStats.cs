using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Statistics;

/// <summary>
/// Data structure representing aggregated statistics for a task, 
/// used for rendering progress bars and dashboard overviews.
/// </summary>
public class TaskSummaryStats
{
    public Guid TaskId { get; set; }
    public SubtaskMode Mode { get; set; }
    public double GlobalProgress { get; set; }

    // --- Visualization Fields (Progress Bar Colors) ---

    /// <summary>
    /// Number of entities (participants in Individual mode / subtasks in Shared mode) 
    /// that are completely finished ON TIME. 
    /// This value populates the GREEN section of the progress bar.
    /// </summary>
    public int CompletedOnTime { get; set; }

    /// <summary>
    /// Number of entities (participants in Individual mode / subtasks in Shared mode) 
    /// that have an issue (completed late or currently overdue). 
    /// This value populates the RED section of the progress bar.
    /// </summary>
    public int IssuesCount { get; set; }

    // --- Individual Mode Specifics ---

    public int TotalRespondents { get; set; }

    /// <summary>
    /// Total number of users who have finished (regardless of being on time or late).
    /// </summary>
    public int CompletedFull { get; set; }

    /// <summary>
    /// Number of participants who have started but not yet completed, and are not yet late.
    /// This value populates the ORANGE section of the progress bar.
    /// </summary>
    public int InProgress { get; set; }

    /// <summary>
    /// Number of participants who haven't started yet and are not yet late.
    /// This value populates the GRAY section of the progress bar.
    /// </summary>
    public int NotStarted { get; set; }

    // --- Shared Mode Specifics ---

    public int TotalSubtasks { get; set; }

    /// <summary>
    /// Total number of completed subtasks, used primarily for the X/Y text label.
    /// </summary>
    public int CompletedSubtasks { get; set; }
}