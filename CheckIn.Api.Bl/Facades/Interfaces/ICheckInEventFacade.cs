using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ICheckInEventFacade : IFacade<TaskEntity, TaskListModel, TaskDetailModel,
	TaskCreateModel, TaskUpdateModel>
{
	Task<TaskDetailModel> SaveCreateModelAsync(TaskCreateModel model, Guid ownerId);
}