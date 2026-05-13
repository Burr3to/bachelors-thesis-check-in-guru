using CheckIn.Api.Common.Enums;

namespace CheckIn.Api.Common.Statistics;

public class TaskSummaryStats
{
    public Guid TaskId { get; set; }
    public SubtaskMode Mode { get; set; }
    public double GlobalProgress { get; set; }

    // --- Nové polia pre detailnú vizualizáciu (Farby progress baru) ---

    /// <summary>
    /// Počet entít (osôb v Individual / subtaskov v Shared), ktoré sú kompletne dokončené VČAS.
    /// Táto hodnota napĺňa ZELENÚ časť progress baru.
    /// </summary>
    public int CompletedOnTime { get; set; }

    /// <summary>
    /// Počet entít (osôb v Individual / subtaskov v Shared), ktoré majú problém (neskoro splnené alebo aktuálne meškajú).
    /// Táto hodnota napĺňa ČERVENÚ časť progress baru.
    /// </summary>
    public int IssuesCount { get; set; }

    // --- Pôvodné polia (zostávajú pre spätnú kompatibilitu a textové labely) ---

    // Individual Mode
    public int TotalRespondents { get; set; }
    public int CompletedFull { get; set; } // Celkový počet ľudí, čo majú hotovo (bez ohľadu na včas/neskoro)
    public int InProgress { get; set; } // Začaté a nič nemešká (Oranžová časť)
    public int NotStarted { get; set; } // Nezačaté a nič nemešká (Sivá časť)

    // Shared Mode
    public int TotalSubtasks { get; set; }
    public int CompletedSubtasks { get; set; } // Čisto číselný údaj pre label X/Y
}