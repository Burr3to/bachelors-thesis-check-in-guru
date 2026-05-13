using System.ComponentModel.DataAnnotations;

namespace CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

/// <summary>
/// Base interface for all database entities, ensuring a consistent primary key.
/// </summary>
public interface IEntity
{
    /// <summary>
    /// Unique identifier for the entity.
    /// </summary>
    [Key]
    public Guid Id { get; set; }
}