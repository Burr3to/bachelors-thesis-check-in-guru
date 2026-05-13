using AutoMapper;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Mappers;

/// <summary>
/// AutoMapper profile configuration for SubtaskTemplate entities and their respective DTOs.
/// </summary>
public class SubtaskTemplateMapperProfile : Profile
{
    public SubtaskTemplateMapperProfile()
    {
        // -----------------------------------------------------------
        // ENTITY -> DTO (READ OPERATIONS)
        // -----------------------------------------------------------

        // Map entity to a basic list representation.
        CreateMap<SubtaskTemplateEntity, SubtaskTemplateListModel>();

        // Map entity to a detailed view.
        CreateMap<SubtaskTemplateEntity, SubtaskTemplateDetailModel>();


        // -----------------------------------------------------------
        // DTO -> ENTITY (WRITE OPERATIONS)
        // -----------------------------------------------------------

        // Map creation model to entity, generating a new unique identifier.
        CreateMap<SubtaskTemplateCreateModel, SubtaskTemplateEntity>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(_ => Guid.NewGuid()));

        // Map update model to entity. 
        // Ensures relational integrity by ignoring immutable fields like ParentTaskId and CreatedAt.
        CreateMap<SubtaskTemplateUpdateModel, SubtaskTemplateEntity>()
            .ForMember(dest => dest.ParentTaskId, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());

        // Map template entity to a combined list model.
        // Used when displaying templates as "potential" subtasks before they are instantiated.
        CreateMap<SubtaskTemplateEntity, SubtaskCombinedListModel>()
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Description))
            .ForMember(dest => dest.Deadline, opt => opt.MapFrom(src => src.ParentTask.DeadLine))
            .ForMember(dest => dest.IsGeneratedFromTask, opt => opt.MapFrom(src => src.IsGeneratedFromTask))
            .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => src.CreatedAt));
    }
}