namespace CheckIn.Api.Common.Results;

public record Result<T>
{
	public T? Value { get; init; }
	public bool IsSuccess { get; init; }
	public string ErrorMessage { get; init; } = string.Empty;
	public ErrorType ErrorType { get; init; }

	private Result(T value)
	{
		Value = value;
		IsSuccess = true;
		ErrorMessage = string.Empty;
		ErrorType = ErrorType.None;
	}

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

	public static Result<T> NotFound(string errorMessage = "Source wasnt found")
		=> new(ErrorType.NotFound, errorMessage);

	public static Result<T> Forbidden(string errorMessage = "You are not authorized for this action.")
		=> new(ErrorType.Forbidden, errorMessage);

	public static Result<T> ValidationFailure(string errorMessage)
		=> new(ErrorType.Validation, errorMessage);
}

public class Result
{
	public static Result<bool> Success() => Result<bool>.Success(true);

	public static Result<bool> Failure(ErrorType errorType, string errorMessage = "")
		=> Result<bool>.Failure(errorType, errorMessage);

	public static Result<bool> NotFound(string errorMessage = "Source wasnt found")
		=> Result<bool>.Failure(ErrorType.NotFound, errorMessage);

	public static Result<bool> Forbidden(string errorMessage = "You dont have permission for this action")
		=> Result<bool>.Failure(ErrorType.Forbidden, errorMessage);

	public static Result<bool> Unauthorized(string errorMessage = "You are not logged in, action is prohibited")
		=> Result<bool>.Failure(ErrorType.Unauthorized, errorMessage);
}