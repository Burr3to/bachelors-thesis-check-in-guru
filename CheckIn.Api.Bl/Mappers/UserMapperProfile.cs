using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Bl.Mappers;

/// <summary>
/// AutoMapper profile configuration for User entities and their data transfer objects.
/// </summary>
public class UserMapperProfile : Profile
{
    public UserMapperProfile()
    {
        // Bidirectional mapping for User details.
        CreateMap<UserEntity, UserDetailModel>();
        CreateMap<UserDetailModel, UserEntity>();

        // Bidirectional mapping for User list views.
        CreateMap<UserEntity, UserListModel>();
        CreateMap<UserListModel, UserEntity>();
    }
}