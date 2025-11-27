using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Dal.Entities;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using Microsoft.AspNetCore.Mvc;

namespace CheckIn.Api.App.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TaskResponseApiController(ITaskResponseFacade responseFacade)
	: ApiControllerBase<
		TaskResponseEntity,
		TaskResponseListModel,
		TaskResponseDetailModel,
		TaskResponseCreateModel,
		TaskResponseUpdateModel,
		TaskResponseListQuery>(responseFacade)
{
}