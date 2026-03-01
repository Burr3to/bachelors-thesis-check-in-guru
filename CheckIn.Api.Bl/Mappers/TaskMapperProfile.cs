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

		CreateMap<TaskCreateModel, TaskEntity>()
			.ForMember(dest => dest.Hash, opt => opt.MapFrom(src => Guid.NewGuid().ToString("N")))
			.ForMember(dest => dest.Id, opt => opt.MapFrom(src => Guid.NewGuid()))
			.ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
			.ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
			.ForMember(dest => dest.Subtasks, opt => opt.MapFrom(src => src.Subtasks));

		CreateMap<TaskEntity, TaskPublicDetailModel>()
			// Priame mapovanie polí:
			.ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
			.ForMember(dest => dest.Notes, opt => opt.MapFrom(src => src.Notes))
			.ForMember(dest => dest.DeadLine, opt => opt.MapFrom(src => src.DeadLine))
			.ForMember(dest => dest.State, opt => opt.MapFrom(src => src.State))
			.ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
			.ForMember(dest => dest.RequiresAuthenticationToComplete,
				opt => opt.MapFrom(src => src.RequiresAuthenticationToComplete))

			// POZOR: Subtasks v public modeli musia byť naplnené ručne vo Fasáde
			// Alebo to mapovanie ignorujeme, ak to robíme manuálne.
			.ForMember(dest => dest.Subtasks, opt => opt.Ignore());

		CreateMap<TaskUpdateModel, TaskEntity>();
	}
}