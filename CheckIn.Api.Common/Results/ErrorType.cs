namespace CheckIn.Api.Common.Results;

public enum ErrorType
{
	None = 0,

	// 400
	Validation = 1,
	BadRequest = 2,

	// 404
	NotFound = 3,

	// 403
	Forbidden = 4,

	// 401
	Unauthorized = 5,

	// 500
	InternalError = 6,

	// 409
	Conflict = 7
}