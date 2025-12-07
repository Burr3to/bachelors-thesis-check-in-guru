using CheckIn.Api.Common.Models.Action;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades.Interfaces;

public interface ISubtaskInstanceFacade :
	IFacade<SubtaskInstanceEntity, SubtaskInstanceListModel, SubtaskInstanceDetailModel,
		SubtaskInstanceCreateModel, SubtaskInstanceUpdateModel, SubtaskInstanceQuery>
{
	Task<Result<bool>> CompleteAsync(Guid instanceId);
	Task<Result<int>> BulkCompleteAsync(BulkSubtaskCompleteModel model);
}