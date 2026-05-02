using AutoMapper;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Mappers;

public class SubtaskTemplateMapperProfile : Profile
{
    public SubtaskTemplateMapperProfile()
    {
        // ===============================================
        // ENTITY -> DTO (READ)
        // ===============================================

        // Mapovanie na List model
        CreateMap<SubtaskTemplateEntity, SubtaskTemplateListModel>();

        // Mapovanie na Detail model
        CreateMap<SubtaskTemplateEntity, SubtaskTemplateDetailModel>();


        // ===============================================
        // DTO -> ENTITY (WRITE)
        // ===============================================

        // Mapovanie z Create modelu (Nastavujeme ID automaticky)
        CreateMap<SubtaskTemplateCreateModel, SubtaskTemplateEntity>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(_ => Guid.NewGuid()));

        // Mapovanie z Update modelu
        // EF Core sleduje zmeny, ID sa zachová.
        CreateMap<SubtaskTemplateUpdateModel, SubtaskTemplateEntity>()
            // Ignorujeme ParentTaskId, aby sme ho nechtiac nezmenili
            .ForMember(dest => dest.ParentTaskId, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());

        CreateMap<SubtaskTemplateEntity, SubtaskCombinedListModel>()
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.MapFrom(src => src.Id)) // ID šablóny ide do TemplateSubtaskId
            .ForMember(dest => dest.Id, opt => opt.Ignore()) // Inštancia zatiaľ neexistuje (ak mapujeme čistú šablónu)
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Description))
            .ForMember(dest => dest.Deadline, opt => opt.MapFrom(src => src.ParentTask.DeadLine))
            .ForMember(dest => dest.IsGeneratedFromTask, opt => opt.MapFrom(src => src.IsGeneratedFromTask))
            .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => src.CreatedAt));
    }
}