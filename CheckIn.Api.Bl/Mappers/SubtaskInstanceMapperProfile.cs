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
			.ForMember(dest => dest.TemplateSubtaskId, opt => opt.Ignore()); // Nemalo by sa meniť, na akú šablónu odkazuje

		// POZNÁMKA: V metóde CompleteAsync v SubtaskInstanceFacade by ste nikdy
		// nemali mapovať z Update modelu. Stav by sa mal meniť priamo v BL logike
		// (nastavenie CompletedAt, CompletedByUserId a IsCompleted = true)
		// A Update model by sa primárne používal len na zmenu napr. AssignedToUserId.
	}
}