using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;

namespace CheckIn.Api.Bl.Mappers;

public class TaskResponseMapperProfile : Profile
{
	public TaskResponseMapperProfile()
	{
		CreateMap<TaskResponseEntity, TaskResponseDetailModel>();
		CreateMap<TaskResponseDetailModel, TaskResponseEntity>();

		CreateMap<TaskResponseEntity, TaskResponseListModel>();
		CreateMap<TaskResponseListModel, TaskResponseEntity>();

		CreateMap<TaskCreateModel, TaskResponseEntity>();
		CreateMap<TaskUpdateModel, TaskResponseEntity>();
	}
}