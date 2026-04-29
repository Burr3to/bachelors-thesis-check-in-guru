using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class AddAllowedDomains : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("UPDATE \"Tasks\" SET \"SubtaskMode\" = \"SubtaskMode\" - 1");
            
            migrationBuilder.AddColumn<string>(
                name: "AllowedDomain",
                table: "Tasks",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AllowedDomain",
                table: "Tasks");
        }
    }
}
