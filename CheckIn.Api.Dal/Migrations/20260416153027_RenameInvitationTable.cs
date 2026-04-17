using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckIn.Api.Dal.Migrations
{
    /// <inheritdoc />
    public partial class RenameInvitationTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_InvitationEntity_Tasks_TaskId",
                table: "InvitationEntity");

            migrationBuilder.DropPrimaryKey(
                name: "PK_InvitationEntity",
                table: "InvitationEntity");

            migrationBuilder.RenameTable(
                name: "InvitationEntity",
                newName: "Invitations");

            migrationBuilder.RenameIndex(
                name: "IX_InvitationEntity_TaskId",
                table: "Invitations",
                newName: "IX_Invitations_TaskId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Invitations",
                table: "Invitations",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Invitations_Tasks_TaskId",
                table: "Invitations",
                column: "TaskId",
                principalTable: "Tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Invitations_Tasks_TaskId",
                table: "Invitations");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Invitations",
                table: "Invitations");

            migrationBuilder.RenameTable(
                name: "Invitations",
                newName: "InvitationEntity");

            migrationBuilder.RenameIndex(
                name: "IX_Invitations_TaskId",
                table: "InvitationEntity",
                newName: "IX_InvitationEntity_TaskId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_InvitationEntity",
                table: "InvitationEntity",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_InvitationEntity_Tasks_TaskId",
                table: "InvitationEntity",
                column: "TaskId",
                principalTable: "Tasks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
