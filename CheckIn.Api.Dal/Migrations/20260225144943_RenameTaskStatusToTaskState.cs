using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class RenameTaskStatusToTaskState : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
		  migrationBuilder.RenameColumn(
		        name: "Status",
		        table: "Tasks",
		        newName: "State");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
    migrationBuilder.RenameColumn(
        name: "State",
        table: "Tasks",
        newName: "Status");
        }
    }
}
