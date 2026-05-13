using CheckIn.Api.Common.Models.Action;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

/// <summary>
/// Facade for managing subtask execution instances.
/// </summary>
public interface ISubtaskInstanceFacade :
    IFacade<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
        SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
{
    /// <summary>
    /// Processes completion for multiple subtask instances at once.
    /// Supports both existing instances and creating new ones for anonymous users.
    /// </summary>
    Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model);
}