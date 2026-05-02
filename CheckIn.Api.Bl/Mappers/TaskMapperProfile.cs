using AutoMapper;
using CheckIn.Api.Common.Enums;
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
        Func<TaskEntity, TaskState> calculateState = src =>
            (src.State != TaskState.Completed && src.DeadLine < DateTime.UtcNow)
                ? TaskState.Missed
                : src.State;

        CreateMap<TaskEntity, TaskDetailModel>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)))
            .ForMember(dest => dest.Invitations, opt => opt.MapFrom(src =>
                src.Invitations.OrderBy(i => i.Email)));
        CreateMap<TaskDetailModel, TaskEntity>();

        CreateMap<TaskEntity, TaskListModel>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)));
        CreateMap<TaskListModel, TaskEntity>();

        CreateMap<TaskCreateModel, TaskEntity>()
            .ForMember(dest => dest.Hash, opt => opt.MapFrom(src => Guid.NewGuid().ToString("N")))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => Guid.NewGuid()))
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => TaskState.InProgress))
            .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
            .ForMember(dest => dest.LastModifiedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
            .ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
            .ForMember(dest => dest.Subtasks, opt => opt.MapFrom(src => src.Subtasks));

        CreateMap<TaskEntity, TaskPublicDetailModel>()
            // Priame mapovanie polí:
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Notes, opt => opt.MapFrom(src => src.Notes))
            .ForMember(dest => dest.DeadLine, opt => opt.MapFrom(src => src.DeadLine))
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => src.State))
            .ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
            .ForMember(dest => dest.RequiresAuthenticationToComplete,
                opt => opt.MapFrom(src => src.RequiresAuthenticationToComplete))
            .ForMember(dest => dest.AllowedDomain, opt => opt.MapFrom(src => src.AllowedDomain))
            .ForMember(dest => dest.Subtasks, opt => opt.Ignore());

        CreateMap<TaskUpdateModel, TaskEntity>()
            // Tieto polia sa NIKDY nesmú prepísať z updatovacieho modelu
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.Hash, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedById, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedBy, opt => opt.Ignore())
            .ForMember(dest => dest.Invitations, opt => opt.Ignore())
            .ForMember(dest => dest.Subtasks, opt => opt.Ignore())
            .ForMember(dest => dest.DeadLine, opt => opt.MapFrom(src => src.DeadLine.ToUniversalTime()));
    }
}