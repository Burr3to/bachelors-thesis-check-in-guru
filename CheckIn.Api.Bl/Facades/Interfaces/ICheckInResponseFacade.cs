using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ICheckInResponseFacade : IFacade<CheckInResponseEntity, CheckInResponseListModel,
	CheckInResponseDetailModel, CheckInResponseCreateModel, CheckInResponseUpdateModel>
{
	Task<CheckInResponseDetailModel?> SaveResponseByHashAsync(string eventHash,
		CheckInResponseDetailModel responseModel);
}