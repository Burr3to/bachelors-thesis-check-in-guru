using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Statistics;

public class TaskSummaryStats
{
    public Guid TaskId { get; set; }
    public SubtaskMode Mode { get; set; }
    public double GlobalProgress { get; set; }

    // Individual Mode
    public int TotalRespondents { get; set; }
    public int CompletedFull { get; set; }
    public int InProgress { get; set; }
    public int NotStarted { get; set; }

    // Shared Mode
    public int TotalSubtasks { get; set; }
    public int CompletedSubtasks { get; set; }
}