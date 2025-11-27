using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ITaskResponseFacade : IFacade<TaskResponseEntity, TaskResponseListModel,
	TaskResponseDetailModel, TaskResponseCreateModel, TaskResponseUpdateModel, TaskResponseListQuery>
{
	Task<TaskResponseDetailModel?> SaveResponseByHashAsync(string eventHash,
		TaskResponseDetailModel responseModel);
}