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
			.ForMember(dest => dest.ParentTaskId, opt => opt.Ignore());

		CreateMap<SubtaskTemplateEntity, SubtaskCombinedListModel>()
			.ForMember(d => d.Id, opt => opt.MapFrom(s => s.Id))
			.ForMember(d => d.IsCompleted, opt => opt.MapFrom(_ => false))
			.ForMember(d => d.RespondentName, opt => opt.Ignore());
	}
}