using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class TaskResponseFacade(CheckInDbContext dbContext, IMapper mapper, IUserContext userContext)
	: FacadeBase<TaskResponseEntity, TaskResponseListModel,
		TaskResponseDetailModel, TaskResponseCreateModel,
		TaskResponseUpdateModel>(dbContext, mapper, userContext), ITaskResponseFacade
{
	public async Task<TaskResponseDetailModel?> SaveResponseByHashAsync(string eventHash,
		TaskResponseDetailModel responseModel)
	{
		// Krok 1: Nájsť Task na základe Hashu (Musíme zabezpečiť, že udalosť existuje)
		var checkInEvent = await dbContext.CheckInEvents
			.FirstOrDefaultAsync(e => e.Hash == eventHash);

		if (checkInEvent == null)
		{
			// Ak udalosť s daným Hashom neexistuje, vrátime null
			return null;
		}

		// Krok 2: Namapovať DTO na Entitu
		// Vytvoríme novú entitu z DTO.
		var newResponseEntity = mapper.Map<TaskResponseEntity>(responseModel);

		// Krok 3: Nastaviť Cudzí kľúč (CheckInId) na základe nájdeného ID udalosti
		newResponseEntity.CheckInId = checkInEvent.Id;

		// Krok 4: Uložiť do databázy
		dbContext.CheckInResponses.Add(newResponseEntity);
		await dbContext.SaveChangesAsync();

		// Krok 5: Vrátiť namapovaný výsledok
		return mapper.Map<TaskResponseDetailModel>(newResponseEntity);
	}
}