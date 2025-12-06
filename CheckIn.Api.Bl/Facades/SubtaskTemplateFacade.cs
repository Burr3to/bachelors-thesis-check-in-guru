using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades;

public class SubtaskTemplateFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
	: FacadeBase<SubtaskTemplateEntity, SubtaskTemplateListModel, SubtaskTemplateDetailModel,
			SubtaskTemplateCreateModel, SubtaskTemplateUpdateModel, SubtaskTemplateQuery>
		(dbContext, mapper, userContext), ISubtaskTemplateFacade
{
	private ISubtaskTemplateFacade _subtaskTemplateFacadeImplementation;
	// Pretože Subtasky sú často len listované podľa ParentTaskId,
	// musíte zabezpečiť, že base.CreateFilter vie spracovať ParentTaskId

	protected override Expression<Func<SubtaskTemplateEntity, bool>> CreateFilter(SubtaskTemplateQuery query)
	{
		Expression<Func<SubtaskTemplateEntity, bool>> filter = entity => true;
		// Ak SubtaskTemplateQuery obsahuje ParentTaskId:
		// if (query.ParentTaskId.HasValue) 
		//     filter = filter.And(e => e.ParentTaskId == query.ParentTaskId.Value);

		return filter;
	}

	protected override Func<IQueryable<SubtaskTemplateEntity>, IOrderedQueryable<SubtaskTemplateEntity>> CreateOrderBy(
		SubtaskTemplateQuery query)
	{
		return q => q.OrderBy(e => e.Id);
	}
}