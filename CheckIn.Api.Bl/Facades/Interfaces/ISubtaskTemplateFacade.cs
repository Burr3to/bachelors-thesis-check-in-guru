using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Interface for managing subtask templates (blueprints).
/// Handles the definition of subtasks that are later instantiated for users.
/// </summary>
public interface ISubtaskTemplateFacade :
    IFacade<SubtaskTemplateEntity, SubtaskTemplateListModel, SubtaskTemplateDetailModel,
        SubtaskTemplateCreateModel, SubtaskTemplateUpdateModel, SubtaskTemplateQuery>
{
}