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
public class SubtaskTemplateController(ISubtaskTemplateFacade facade)
    : ApiControllerBase<SubtaskTemplateEntity, SubtaskTemplateListModel, SubtaskTemplateDetailModel,
            SubtaskTemplateCreateModel, SubtaskTemplateUpdateModel, SubtaskTemplateQuery>
        (facade)
{
    // Všetok CRUD je zdedený z ApiControllerBase
}