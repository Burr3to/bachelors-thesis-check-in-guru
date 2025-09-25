using AutoMapper;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Bl.Mappers;

public class UserMapperProfile : Profile
{
		public UserMapperProfile()
	{
		CreateMap<UserEntity, UserDetailModel>();
		CreateMap<UserDetailModel, UserEntity>();

		CreateMap<UserEntity, UserListModel>();
		CreateMap<UserListModel, UserEntity>();
	}
}