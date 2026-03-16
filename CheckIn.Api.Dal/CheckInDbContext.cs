using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace CheckIn.Api.Dal;

public class CheckInDbContext(DbContextOptions<CheckInDbContext> options)
    : IdentityDbContext<IdentityUser, IdentityRole, string>(options)
{
    public DbSet<TaskEntity> Tasks { get; set; }
    public DbSet<SubtaskTemplateEntity> Subtasks { get; set; }
    public DbSet<SubtaskInstanceEntity> SubtaskInstances { get; set; }
    public new DbSet<UserEntity> Users { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // VŽDY volajte základnú metódu pre konfiguráciu Identity tabuliek
        base.OnModelCreating(modelBuilder);

        // 1. TaskEntity a CreatedById
        modelBuilder.Entity<TaskEntity>()
            .HasOne(t => t.CreatedBy) // Relácia k vašej entite používateľa
            .WithMany()
            .HasForeignKey(t => t.CreatedById)
            .IsRequired(true)
            .OnDelete(DeleteBehavior.Restrict); // Zabrániť kaskádovému mazaniu taskov pri mazaní používateľa

        // 2. TaskEntity a SubtaskTemplateEntity (1:N)
        modelBuilder.Entity<SubtaskTemplateEntity>()
            .HasOne(st => st.ParentTask)
            .WithMany(t => t.Subtasks)
            .HasForeignKey(st => st.ParentTaskId)
            .OnDelete(DeleteBehavior.Cascade); // Ak sa zmaže Task, zmažú sa aj všetky šablóny subtaskov

        // Delta JSON string for rich text flutter_quill
        modelBuilder.Entity<TaskEntity>()
            .Property(b => b.Notes)
            .HasColumnType("jsonb");

        // 3. SubtaskTemplateEntity a SubtaskInstanceEntity (1:N)
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne(si => si.TemplateSubtask)
            .WithMany(st => st.Instances)
            .HasForeignKey(si => si.TemplateSubtaskId)
            .OnDelete(DeleteBehavior.Cascade); // Ak sa zmaže šablóna, zmažú sa aj všetky inštancie splnenia

        // 4. SubtaskInstanceEntity a UserEntity (CompletedByUserId, AssignedToUserId)

        // Kto inštanciu splnil (CompletedByUserId)
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne<UserEntity>()
            .WithMany()
            .HasForeignKey(si => si.CompletedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Komu bola inštancia priradená (AssignedToUserId)
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasOne<UserEntity>()
            .WithMany()
            .HasForeignKey(si => si.AssignedToUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // --- INDEXY PRE RÝCHLE ŠTATISTIKY ---

        // 1. Index na SubtaskTemplateEntity (vyhľadávanie šablón podľa Tasku)
        modelBuilder.Entity<SubtaskTemplateEntity>()
            .HasIndex(st => st.ParentTaskId)
            .HasDatabaseName("IX_SubtaskTemplates_ParentTaskId");

        // 2. Index na SubtaskInstanceEntity (vyhľadávanie inštancií podľa šablóny)
        // Toto je kľúčové pre tvoj "Individual mode" výpočet
        modelBuilder.Entity<SubtaskInstanceEntity>()
            .HasIndex(si => si.TemplateSubtaskId)
            .HasDatabaseName("IX_SubtaskInstances_TemplateSubtaskId");
    }
}