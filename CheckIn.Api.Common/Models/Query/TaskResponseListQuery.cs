namespace CheckIn.Api.Common.Models.Query;

public record TaskResponseListQuery : ListQuery
{
	public Guid? TaskId { get; init; }
	public string? CommentContains { get; init; }
}