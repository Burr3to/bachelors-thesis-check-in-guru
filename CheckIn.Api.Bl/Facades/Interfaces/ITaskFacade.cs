using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Common.Statistics;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Facade for managing core Task entities and related operations.
/// Extends the generic facade with task-specific business logic.
/// </summary>
public interface ITaskFacade : IFacade<TaskEntity, TaskListModel, TaskDetailModel,
    TaskCreateModel, TaskUpdateModel, TaskListQuery>
{
    /// <summary>
    /// Retrieves the subtask templates (the "blueprint" of subtasks) for a given task.
    /// </summary>
    Task<Result<List<SubtaskCombinedListModel>>> GetTaskTemplatesAsync(Guid taskId);

    /// <summary>
    /// Retrieves the subtask instances (the actual executable subtasks) for a given task.
    /// </summary>
    Task<Result<List<SubtaskCombinedListModel>>> GetTaskInstancesAsync(Guid taskId);

    /// <summary>
    /// Fetches the public-facing details of a task using a secure hash, intended for anonymous users.
    /// </summary>
    Task<Result<TaskPublicDetailModel>> GetTaskPublicDetailByHashAsync(string hash);

    /// <summary>
    /// Removes specified users from a task's invitation list by their email addresses.
    /// </summary>
    Task<Result<bool>> RemoveInvitationsAsync(Guid taskId, List<string> emails);

    /// <summary>
    /// For "Individual" mode tasks, this method generates a personal set of subtask instances for a user if they don't already have one.
    /// </summary>
    Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId, string userEmail);

    /// <summary>
    /// Gathers and returns summary statistics (e.g., completion rates) for a list of specified tasks.
    /// </summary>
    Task<Result<List<TaskSummaryStats>>> GetSummaryStats(List<Guid> taskIds);
}