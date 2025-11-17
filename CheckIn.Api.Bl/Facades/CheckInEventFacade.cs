using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;

namespace CheckIn.Api.Bl.Facades;

public class CheckInEventFacade(CheckInDbContext dbContext, IMapper mapper)
	: FacadeBase<CheckInEventEntity, CheckInEventListModel, CheckInEventDetailModel, CheckInEventCreateModel,
			CheckInEventUpdateModel>
		(dbContext, mapper), ICheckInEventFacade
{
	public async Task<CheckInEventDetailModel> SaveCreateModelAsync(CheckInEventCreateModel model, Guid ownerId)
	{
		// 1. Mapovanie: TCreateModel -> TEntity
		var entity = mapper.Map<CheckInEventEntity>(model);

		// 2. Priradenie SYSTÉMOVÝCH a NEVSTUPNÝCH HODNÔT (ktoré klient neposiela)
		entity.Id = Guid.NewGuid();
		entity.OwnerId = ownerId;
		entity.CreatedAt = DateTime.UtcNow;
		entity.Hash = Guid.NewGuid().ToString("N")[..8];

		// 3. Uloženie do databázy
		await dbContext.CheckInEvents.AddAsync(entity);
		await dbContext.SaveChangesAsync();

		// 4. Mapovanie späť: TEntity -> TDetailModel (pre návrat s ID, Hash, CreatedAt)
		var detailModel = mapper.Map<CheckInEventDetailModel>(entity);
		return detailModel;
	}
}