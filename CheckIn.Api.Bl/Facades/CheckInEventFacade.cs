using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades;

public class CheckInEventFacade(CheckInDbContext dbContext, IMapper mapper)
	: FacadeBase<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel>
		(dbContext, mapper), ICheckInEventFacade
{
}