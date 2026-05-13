namespace CheckIn.Api.Common.Results;

/// <summary>
/// Specifies the type of error encountered during a request, 
/// typically mapped to standard HTTP status codes.
/// </summary>
public enum ErrorType
{
    None = 0,

    // Mapped to HTTP 400
    Validation = 1,
    BadRequest = 2,

    // Mapped to HTTP 404
    NotFound = 3,

    // Mapped to HTTP 403
    Forbidden = 4,

    // Mapped to HTTP 401
    Unauthorized = 5,

    // Mapped to HTTP 500
    InternalError = 6,

    // Mapped to HTTP 409
    Conflict = 7
}