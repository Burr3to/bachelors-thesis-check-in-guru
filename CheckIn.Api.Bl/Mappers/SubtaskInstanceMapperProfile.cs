using AutoMapper;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Mappers;

public class SubtaskInstanceMapperProfile : Profile
{
    public SubtaskInstanceMapperProfile()
    {
        // ===============================================
        // ENTITY -> DTO (READ)
        // ===============================================

        // Mapovanie na List model
        CreateMap<SubtaskInstanceEntity, SubtaskInstanceListModel>();

        // Mapovanie na Detail model
        CreateMap<SubtaskInstanceEntity, SubtaskInstanceDetailModel>();


        // ===============================================
        // DTO -> ENTITY (WRITE)
        // ===============================================

        // Mapovanie z Create modelu (Primárne sa používa len pre manuálne POST, inak Fasáda)
        CreateMap<SubtaskInstanceCreateModel, SubtaskInstanceEntity>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(_ => Guid.NewGuid()))
            // Nastavenie defaultného stavu pri vytváraní
            .ForMember(dest => dest.IsCompleted, opt => opt.MapFrom(_ => false))
            .ForMember(dest => dest.CompletedAt, opt => opt.Ignore())
            .ForMember(dest => dest.CompletedByUserId, opt => opt.Ignore());

        // Mapovanie z Update modelu
        // Update model by mohol obsahovať zmenu stavu alebo priradenia
        CreateMap<SubtaskInstanceUpdateModel, SubtaskInstanceEntity>()
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.Ignore()); // Nemalo by sa meniť, na akú šablónu odkazuje

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
            // Mapovanie zo šablóny
            .ForMember(dest => dest.Title,
                opt => opt.MapFrom(src => src.TemplateSubtask!.Title))
            .ForMember(dest => dest.Description,
                opt => opt.MapFrom(src => src.TemplateSubtask!.Description))
            .ForMember(dest => dest.TemplateSubtaskId,
                opt => opt.MapFrom(src => src.TemplateSubtaskId))
            .ForMember(dest => dest.IsGeneratedFromTask,
                opt => opt.MapFrom(src => src.TemplateSubtask!.IsGeneratedFromTask));

        // POZNÁMKA: V metóde CompleteAsync v SubtaskInstanceFacade by ste nikdy
        // nemali mapovať z Update modelu. Stav by sa mal meniť priamo v BL logike
        // (nastavenie CompletedAt, CompletedByUserId a IsCompleted = true)
        // A Update model by sa primárne používal len na zmenu napr. AssignedToUserId.
    }
}