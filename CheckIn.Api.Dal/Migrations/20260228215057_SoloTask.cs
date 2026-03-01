using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class SoloTask : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsGeneratedFromTask",
                table: "Subtasks",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsGeneratedFromTask",
                table: "Subtasks");
        }
    }
}
