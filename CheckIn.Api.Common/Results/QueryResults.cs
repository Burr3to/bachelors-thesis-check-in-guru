namespace CheckIn.Api.Common.Results;

public record QueryResult<T>
{
	public required IEnumerable<T> Items { get; init; }
	public required int TotalCount { get; init; }
	public required int PageNumber { get; init; }
	public required int PageSize { get; init; }
}