using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Common.Statistics;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ITaskFacade : IFacade<TaskEntity, TaskListModel, TaskDetailModel,
    TaskCreateModel, TaskUpdateModel, TaskListQuery>
{
    Task<Result<List<SubtaskCombinedListModel>>> GetTaskTemplatesAsync(Guid taskId);
    Task<Result<List<SubtaskCombinedListModel>>> GetTaskInstancesAsync(Guid taskId);
    Task<Result<TaskPublicDetailModel>> GetTaskPublicDetailByHashAsync(string hash);
    Task EnsureIndividualInstancesExist(TaskEntity task, Guid userId, string userEmail);
    Task<Result<List<TaskSummaryStats>>> GetSummaryStats(List<Guid> taskIds);
}