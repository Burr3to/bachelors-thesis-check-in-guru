using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Action;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(AuthenticationSchemes = "Bearer")]
public class SubtaskInstanceController(ISubtaskInstanceFacade facade)
    : ApiControllerBase<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
            SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
        (facade)
{
    [HttpPost("bulk-complete")] // Nový hromadný endpoint
    [AllowAnonymous]
    public async Task<ActionResult<int>> BulkComplete([FromBody] BulkSubtaskCompleteModel model)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await ((ISubtaskInstanceFacade)Facade).BulkCompleteAsync(model);

        if (result.IsSuccess)
            return Ok(new { CompletedCount = result.Value });

        // Vráti 401, 403, 500 atď.
        return HandleResultFailure(result);
    }
}