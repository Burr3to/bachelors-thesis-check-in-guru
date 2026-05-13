using CheckIn.Api.Common.Models.Lists;

namespace CheckIn.Api.Common.Results;

/// <summary>
/// A generic result wrapper used across the Business Logic and API layers 
/// to encapsulate both successful data and detailed error information.
/// </summary>
/// <typeparam name="T">Type of the returned value.</typeparam>
public record Result<T>
{
    public T? Value { get; init; }
    public bool IsSuccess { get; init; }
    public string ErrorMessage { get; init; } = string.Empty;
    public ErrorType ErrorType { get; init; }

    // Internal constructor for successful operations
    private Result(T value)
    {
        Value = value;
        IsSuccess = true;
        ErrorMessage = string.Empty;
        ErrorType = ErrorType.None;
    }

    // Internal constructor for failed operations
    private Result(ErrorType errorType, string errorMessage)
    {
        Value = default;
        IsSuccess = false;
        ErrorType = errorType;
        ErrorMessage = errorMessage;
    }

    public static Result<T> Success(T value) => new(value);

    public static Result<T> Failure(ErrorType errorType, string errorMessage = "")
        => new(errorType, errorMessage);

    public static Result<T> NotFound(string errorMessage = "The requested source was not found.")
        => new(ErrorType.NotFound, errorMessage);

    public static Result<T> Forbidden(string errorMessage = "You are not authorized for this action.")
        => new(ErrorType.Forbidden, errorMessage);

    public static Result<T> ValidationFailure(string errorMessage)
        => new(ErrorType.Validation, errorMessage);

    public static Result<T> Unauthorized(string errorMessage = "Authentication is required for this action.")
        => new(ErrorType.Unauthorized, errorMessage);
}

/// <summary>
/// Non-generic helper class for creating simple boolean results.
/// </summary>
public class Result
{
    public static Result<bool> Success() => Result<bool>.Success(true);

    public static Result<bool> Failure(ErrorType errorType, string errorMessage = "")
        => Result<bool>.Failure(errorType, errorMessage);

    public static Result<bool> NotFound(string errorMessage = "The requested source was not found.")
        => Result<bool>.Failure(ErrorType.NotFound, errorMessage);

    public static Result<bool> Forbidden(string errorMessage = "You do not have permission for this action.")
        => Result<bool>.Failure(ErrorType.Forbidden, errorMessage);

    public static Result<bool> Unauthorized(string errorMessage = "Authentication is required. Access is prohibited.")
        => Result<bool>.Failure(ErrorType.Unauthorized, errorMessage);
}