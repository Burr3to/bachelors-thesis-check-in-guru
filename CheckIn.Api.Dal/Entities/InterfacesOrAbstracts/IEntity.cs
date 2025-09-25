using System.ComponentModel.DataAnnotations;

namespace CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

public interface IEntity
{
	[Key] public Guid Id { get; set; }
}