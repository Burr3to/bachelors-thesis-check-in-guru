namespace CheckIn.Api.Common.Models.Interfaces;

/// <summary>
/// Base interface for Data Transfer Objects (DTOs) that represent an entity with a unique identifier.
/// Ensures consistent ID handling across detail and update models.
/// </summary>
public interface IEntityModel
{
    /// <summary>
    /// The unique identifier of the entity.
    /// </summary>
    public Guid Id { get; init; }
}