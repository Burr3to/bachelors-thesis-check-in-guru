using CheckIn.Api.Common.Enums;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Models.Lists;
using TaskStatus = System.Threading.Tasks.TaskStatus;

namespace CheckIn.Api.Common.Models.Details;

public record TaskPublicDetailModel : IEntityModel
{
	// POZOR: Id nie je Id TaskEntity, ale Guid, ktorý len slúži pre IEntityModel
	// Skutočný Hash je v URL a nepotrebujeme ho v tele.
	public Guid Id { get; init; }

	// Polia Tasku, ktoré sú bezpečné na expozíciu
	public required string Title { get; init; }
	public string? Notes { get; init; }
	public DateTime DeadLine { get; init; }
	public TaskState State { get; init; }

	// Kľúčové pre FE logiku
	public SubtaskMode SubtaskMode { get; init; }
	public bool RequiresAuthenticationToComplete { get; init; }

	public List<SubtaskCombinedListModel> Subtasks { get; init; } = new();
}