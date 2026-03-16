using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class AddIndexesForPerformance : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameIndex(
                name: "IX_Subtasks_ParentTaskId",
                table: "Subtasks",
                newName: "IX_SubtaskTemplates_ParentTaskId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameIndex(
                name: "IX_SubtaskTemplates_ParentTaskId",
                table: "Subtasks",
                newName: "IX_Subtasks_ParentTaskId");
        }
    }
}
