using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;

namespace CheckIn.Api.Bl.Mappers;

public class TaskMapperProfile : Profile
{
	public TaskMapperProfile()
	{
		CreateMap<TaskEntity, TaskDetailModel>();
		CreateMap<TaskDetailModel, TaskEntity>();

		CreateMap<TaskEntity, TaskListModel>();
		CreateMap<TaskListModel, TaskEntity>();

		CreateMap<TaskCreateModel, TaskEntity>();
		CreateMap<TaskUpdateModel, TaskEntity>();
	}
}