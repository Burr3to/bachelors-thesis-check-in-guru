using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal;

/// <summary>
/// Main database context for the CheckIn system, integrating ASP.NET Identity 
/// and custom business entities.
/// </summary>
public class CheckInDbContext(DbContextOptions<CheckInDbContext> options)
    : IdentityDbContext<IdentityUser, IdentityRole, string>(options)
{
    public DbSet<TaskEntity> Tasks { get; set; }
    public DbSet<SubtaskTemplateEntity> Subtasks { get; set; }
    public DbSet<SubtaskInstanceEntity> SubtaskInstances { get; set; }
    public new DbSet<UserEntity> Users { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<InvitationEntity> Invitations { get; set; }

    /// <summary>
    /// Configures entity relationships, column types, and database indexes.
    /// </summary>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Required for configuring ASP.NET Identity tables
        base.OnModelCreating(modelBuilder);

        // Configuration for TaskEntity and its Author (CreatedBy)
        modelBuilder.Entity<TaskEntity>()
            .HasOne(t => t.CreatedBy)
            .WithMany()
            .HasForeignKey(t => t.CreatedById)
            .IsRequired(true)
            .OnDelete(DeleteBehavior.Restrict); // Prevent task deletion from cascading back to users

        // Relationship between Task and its Subtask Blueprints
        modelBuilder.Entity<SubtaskTemplateEntity>()
            .HasOne(st => st.ParentTask)
            .WithMany(t => t.Subtasks)
            .HasForeignKey(st => st.ParentTaskId)
            .OnDelete(DeleteBehavior.Cascade);

        // Store Quill editor rich text as native PostgreSQL JSONB for efficient querying
        modelBuilder.Entity<TaskEntity>()
            .Property(b => b.Notes)
            .HasColumnType("jsonb");

        // Relationship between Subtask Blueprint and its Execution Instances
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne(si => si.TemplateSubtask)
            .WithMany(st => st.Instances)
            .HasForeignKey(si => si.TemplateSubtaskId)
            .OnDelete(DeleteBehavior.Cascade);

        // Relationship for the user who completed the subtask instance
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne<UserEntity>()
            .WithMany()
            .HasForeignKey(si => si.CompletedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Relationship for the user assigned to a specific instance (Individual mode)
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne<UserEntity>()
            .WithMany()
            .HasForeignKey(si => si.AssignedToUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Relationship between Task and Invitations
        modelBuilder.Entity<InvitationEntity>()
            .HasOne(i => i.Task)
            .WithMany(t => t.Invitations)
            .HasForeignKey(i => i.TaskId)
            .OnDelete(DeleteBehavior.Cascade);

        // --- PERFORMANCE INDEXES ---

        // Index for searching templates by parent task
        modelBuilder.Entity<SubtaskTemplateEntity>()
            .HasIndex(st => st.ParentTaskId)
            .HasDatabaseName("IX_SubtaskTemplates_ParentTaskId");

        // Index for searching execution instances by their template
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasIndex(si => si.TemplateSubtaskId)
            .HasDatabaseName("IX_SubtaskInstances_TemplateSubtaskId");
    }
}