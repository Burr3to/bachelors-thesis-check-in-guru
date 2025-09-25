using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Bl.Mappers;

public class CheckInResponseMapperProfile : Profile
{
	public CheckInResponseMapperProfile()
	{
		CreateMap<CheckInResponseEntity, CheckInResponseDetailModel>();
		CreateMap<CheckInResponseDetailModel, CheckInResponseEntity>();

		CreateMap<CheckInResponseEntity, CheckInResponseListModel>();
		CreateMap<CheckInResponseListModel, CheckInResponseEntity>();
	}
}