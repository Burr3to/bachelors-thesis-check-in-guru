using CheckIn.Api.Bl.Facades.Interfaces;
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
	// Custom endpoint pre splnenie Subtasku (namiesto generického PUT)
	[HttpPost("complete/{id}")]
	public async Task<IActionResult> Complete([FromRoute] Guid id)
	{
		var result = await facade.CompleteAsync(id);

		if (result.IsSuccess)
			return NoContent(); // 204 No Content

		// Použitie helpera na spracovanie chyby
		return HandleResultFailure(result);
	}

	// Ostatné CRUD metódy (GetList, GetById, Put, Delete) sú zdedené
}