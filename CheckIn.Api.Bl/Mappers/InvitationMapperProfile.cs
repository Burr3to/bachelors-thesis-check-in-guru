using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;
using AutoMapper;

namespace CheckIn.Api.Bl.Mappers;

/// <summary>
/// AutoMapper profile for InvitationEntity transformations.
/// </summary>
public class InvitationMapperProfile : Profile
{
    /// <summary>
    /// Configures mapping rules for invitations.
    /// </summary>
    public InvitationMapperProfile()
    {
        CreateMap<InvitationEntity, InvitationListModel>();

        CreateMap<InvitationEntity, InvitationDetailModel>()
            .ForMember(dest => dest.TaskTitle,
                opt => opt.MapFrom(src => src.Task != null ? src.Task.Title : string.Empty));

        CreateMap<InvitationCreateModel, InvitationEntity>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.SentAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
            .ForMember(dest => dest.IsAccepted, opt => opt.MapFrom(_ => false));

        CreateMap<InvitationUpdateModel, InvitationEntity>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
    }
}