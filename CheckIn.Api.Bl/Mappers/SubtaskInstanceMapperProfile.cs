using AutoMapper;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Mappers;

/// <summary>
/// AutoMapper profile for SubtaskInstanceEntity transformations.
/// </summary>
public class SubtaskInstanceMapperProfile : Profile
{
    /// <summary>
    /// Configures mapping rules for subtask execution instances.
    /// </summary>
    public SubtaskInstanceMapperProfile()
    {
        // ===============================================
        // ENTITY -> DTO (READ)
        // ===============================================

        // Mapping to List model
        CreateMap<SubtaskInstanceEntity, SubtaskInstanceListModel>();

        // Mapping to Detail model
        CreateMap<SubtaskInstanceEntity, SubtaskInstanceDetailModel>();


        // ===============================================
        // DTO -> ENTITY (WRITE)
        // ===============================================

        // Mapping from Create model (primarily used for manual POST, otherwise handled by Facade)
        CreateMap<SubtaskInstanceCreateModel, SubtaskInstanceEntity>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(_ => Guid.NewGuid()))
            // Setting default state upon creation
            .ForMember(dest => dest.IsCompleted, opt => opt.MapFrom(_ => false))
            .ForMember(dest => dest.CompletedAt, opt => opt.Ignore())
            .ForMember(dest => dest.CompletedByUserId, opt => opt.Ignore());

        // Mapping from Update model
        // Update model may contain status or assignment changes
        CreateMap<SubtaskInstanceUpdateModel, SubtaskInstanceEntity>()
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.Ignore()); // The reference to the template should remain immutable

        // Combined model mapping for UI checklist views
        CreateMap<SubtaskInstanceEntity, SubtaskCombinedListModel>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.IsCompleted, opt => opt.MapFrom(src => src.IsCompleted))
            .ForMember(dest => dest.RespondentName, opt => opt.MapFrom(src => src.RespondentName))
            .ForMember(dest => dest.Comment, opt => opt.MapFrom(src => src.Comment))
            .ForMember(dest => dest.ResponseGroupId, opt => opt.MapFrom(src => src.ResponseGroupId))
            .ForMember(dest => dest.AssignedToUserId, opt => opt.MapFrom(src => src.AssignedToUserId))
            .ForMember(dest => dest.CompletedByUserId, opt => opt.MapFrom(src => src.CompletedByUserId))
            .ForMember(dest => dest.CompletedAt, opt => opt.MapFrom(src => src.CompletedAt))
            .ForMember(dest => dest.Deadline, opt => opt.MapFrom(src => src.TemplateSubtask.ParentTask.DeadLine))
            .ForMember(dest => dest.AssignedToEmail, opt => opt.MapFrom(src => src.AssignedToEmail))

            // Mapping metadata from the associated template
            .ForMember(dest => dest.Title,
                opt => opt.MapFrom(src => src.TemplateSubtask!.Title))
            .ForMember(dest => dest.Description,
                opt => opt.MapFrom(src => src.TemplateSubtask!.Description))
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.MapFrom(src => src.TemplateSubtaskId))
            .ForMember(dest => dest.IsGeneratedFromTask,
                opt => opt.MapFrom(src => src.TemplateSubtask!.IsGeneratedFromTask));
    }
}