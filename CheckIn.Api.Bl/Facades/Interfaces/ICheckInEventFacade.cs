using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ICheckInEventFacade : IFacade<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel>
{
}