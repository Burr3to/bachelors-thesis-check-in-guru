using CheckIn.Api.Dal.Entities.InterfacesOrAbstracts;

namespace CheckIn.Api.Dal.Entities;

/// <summary>
/// Represents a local user profile synchronized with an external identity provider.
/// </summary>
public class UserEntity : IEntity
{
    public Guid Id { get; set; }

    /// <summary>
    /// Identifier from the external provider (e.g., Firebase UID).
    /// </summary>
    public required string GoogleId { get; set; }

    public required string Email { get; set; }
    public required string Name { get; set; }

    /// <summary>
    /// Navigation property for all tasks created by this user.
    /// </summary>
    public ICollection<TaskEntity> CreatedCheckIns { get; set; } = new List<TaskEntity>();
}