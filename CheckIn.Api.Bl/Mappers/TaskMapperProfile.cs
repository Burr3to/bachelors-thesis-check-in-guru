using AutoMapper;
using CheckIn.Api.Common.Enums;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;

namespace CheckIn.Api.Bl.Mappers;

/// <summary>
/// AutoMapper profile for TaskEntity transformations.
/// Handles state calculation, date normalization, and security filtering for different model types.
/// </summary>
public class TaskMapperProfile : Profile
{
    public TaskMapperProfile()
    {
        // Logic to determine the current logical state of a task.
        // If the task is not completed and the deadline has passed, it is considered "Missed".
        Func<TaskEntity, TaskState> calculateState = src =>
            (src.State != TaskState.Completed && src.DeadLine < DateTime.UtcNow)
                ? TaskState.Missed
                : src.State;

        // Map Entity to Detail Model (used in full-page management views)
        CreateMap<TaskEntity, TaskDetailModel>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)))
            .ForMember(dest => dest.Invitations, opt => opt.MapFrom(src =>
                src.Invitations.OrderBy(i => i.Email))) // Ensure consistent alphabetical order
            // Enforce UTC kind for proper frontend JSON serialization
            .ForMember(dest => dest.DeadLine,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.DeadLine, DateTimeKind.Utc)))
            .ForMember(dest => dest.CreatedAt,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.CreatedAt, DateTimeKind.Utc)))
            .ForMember(dest => dest.LastModifiedAt,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.LastModifiedAt, DateTimeKind.Utc)));

        CreateMap<TaskDetailModel, TaskEntity>();

        // Map Entity to List Model (used for dashboard tables)
        CreateMap<TaskEntity, TaskListModel>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)))
            .ForMember(dest => dest.DeadLine,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.DeadLine, DateTimeKind.Utc)))
            .ForMember(dest => dest.CreatedAt,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.CreatedAt, DateTimeKind.Utc)))
            .ForMember(dest => dest.LastModifiedAt,
                opt => opt.MapFrom(src => DateTime.SpecifyKind(src.LastModifiedAt, DateTimeKind.Utc)));

        CreateMap<TaskListModel, TaskEntity>();

        // Map Create Model to Entity (Initialization logic)
        CreateMap<TaskCreateModel, TaskEntity>()
            .ForMember(dest => dest.Hash, opt => opt.MapFrom(src => Guid.NewGuid().ToString("N")))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => Guid.NewGuid()))
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => TaskState.InProgress))
            .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
            .ForMember(dest => dest.LastModifiedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
            .ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
            .ForMember(dest => dest.Subtasks, opt => opt.MapFrom(src => src.Subtasks));

        // Map Entity to Public Detail Model (Filtered for non-authors or anonymous users)
        CreateMap<TaskEntity, TaskPublicDetailModel>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => calculateState(src)))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Notes, opt => opt.MapFrom(src => src.Notes))
            .ForMember(dest => dest.DeadLine, opt => opt.MapFrom(src => src.DeadLine))
            .ForMember(dest => dest.SubtaskMode, opt => opt.MapFrom(src => src.SubtaskMode))
            .ForMember(dest => dest.RequiresAuthenticationToComplete,
                opt => opt.MapFrom(src => src.RequiresAuthenticationToComplete))
            .ForMember(dest => dest.AllowedDomain, opt => opt.MapFrom(src => src.AllowedDomain))
            .ForMember(dest => dest.Subtasks,
                opt => opt.Ignore()); // Subtasks are handled manually in Facade based on mode

        // Map Update Model to Entity (Protection against unauthorized field changes)
        CreateMap<TaskUpdateModel, TaskEntity>()
            // Prevent overwriting system-managed or immutable fields
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