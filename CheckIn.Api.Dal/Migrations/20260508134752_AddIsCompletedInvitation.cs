using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class AddIsCompletedInvitation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsCompleted",
                table: "Invitations",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsCompleted",
                table: "Invitations");
        }
    }
}
