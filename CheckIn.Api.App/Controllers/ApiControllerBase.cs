using System.Linq.Expressions;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Interfaces;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace CheckIn.Api.App.Controllers;

/// <summary>
/// Generic base controller providing standard CRUD operations.
/// </summary>
public abstract class ApiControllerBase<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel>(
    IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel> facade)
    : ControllerBase
    where TDetailModel : class, IEntityModel
    where TCreateModel : class
    where TUpdateModel : IEntityModel
    where TQueryModel : IPageableQuery, new()
{
    protected readonly IFacade<TEntity, TListModel, TDetailModel, TCreateModel, TUpdateModel, TQueryModel> Facade =
        facade;

    /// <summary>
    /// Retrieves a paginated and filtered list of entities.
    /// </summary>
    [HttpGet]
    public virtual async Task<ActionResult<QueryResult<TListModel>>> GetList([FromQuery] TQueryModel query)
    {
        var result = await Facade.GetListAsync(query);

        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Retrieves a specific entity detail by its unique identifier.
    /// </summary>
    [HttpGet("{id}")]
    public virtual async Task<ActionResult<TDetailModel>> GetById(Guid id)
    {
        var result = await Facade.GetByIdAsync(id);

        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Updates an existing entity.
    /// </summary>
    [HttpPut("{id}")]
    public virtual async Task<IActionResult> Put(Guid id, [FromBody] TUpdateModel model)
    {
        // Ensure the ID in the route matches the ID in the payload
        if (id != model.Id)
        {
            return BadRequest("ID mismatch: Route ID must match Model ID.");
        }

        var result = await Facade.SaveUpdateModelAsync(model);

        if (result.IsSuccess)
            return NoContent();

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Creates a new entity.
    /// </summary>
    [HttpPost]
    public virtual async Task<ActionResult<TDetailModel>> Post([FromBody] TCreateModel model)
    {
        var result = await Facade.SaveCreateModelAsync(model);

        if (result.IsSuccess)
        {
            // Return 201 Created with the location of the new resource
            return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Deletes an entity by its identifier.
    /// </summary>
    [HttpDelete("{id}")]
    public virtual async Task<IActionResult> Delete(Guid id)
    {
        var result = await Facade.DeleteAsync(id);

        if (result.IsSuccess)
        {
            return NoContent();
        }

        return HandleResultFailure(result);
    }

    /// <summary>
    /// Maps internal result errors to standard HTTP responses.
    /// </summary>
    protected ActionResult HandleResultFailure<T>(Result<T> result)
    {
        if (result.IsSuccess)
        {
            throw new InvalidOperationException("Cannot handle failure on a successful result.");
        }

        return result.ErrorType switch
        {
            ErrorType.NotFound => NotFound(result.ErrorMessage),
            ErrorType.Forbidden => StatusCode(StatusCodes.Status403Forbidden, new { message = result.ErrorMessage }),
            ErrorType.Unauthorized => Unauthorized(result.ErrorMessage),
            ErrorType.Validation => BadRequest(result.ErrorMessage),
            ErrorType.Conflict => Conflict(result.ErrorMessage),
            _ => StatusCode(StatusCodes.Status500InternalServerError,
                new { Error = "Internal Server Error", Details = result.ErrorMessage })
        };
    }
}