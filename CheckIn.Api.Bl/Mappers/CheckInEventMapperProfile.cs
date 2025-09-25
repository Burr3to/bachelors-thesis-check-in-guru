using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Bl.Mappers;

public class CheckInEventMapperProfile : Profile
{
	public CheckInEventMapperProfile()
	{
		CreateMap<CheckInEventEntity, CheckInEventDetailModel>();
		CreateMap<CheckInEventDetailModel, CheckInEventEntity>();

		CreateMap<CheckInEventEntity, CheckInEventListModel>();
		CreateMap<CheckInEventListModel, CheckInEventEntity>();
	}
}