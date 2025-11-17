using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class CheckInResponseFacade(CheckInDbContext dbContext, IMapper mapper)
	: FacadeBase<CheckInResponseEntity, CheckInResponseListModel, CheckInResponseDetailModel, CheckInResponseCreateModel,
			CheckInResponseUpdateModel>
		(dbContext, mapper), ICheckInResponseFacade
{
	public async Task<CheckInResponseDetailModel?> SaveResponseByHashAsync(string eventHash,
		CheckInResponseDetailModel responseModel)
	{
		// Krok 1: Nájsť CheckInEvent na základe Hashu (Musíme zabezpečiť, že udalosť existuje)
		var checkInEvent = await dbContext.CheckInEvents
			.FirstOrDefaultAsync(e => e.Hash == eventHash);

		if (checkInEvent == null)
		{
			// Ak udalosť s daným Hashom neexistuje, vrátime null
			return null;
		}

		// Krok 2: Namapovať DTO na Entitu
		// Vytvoríme novú entitu z DTO.
		var newResponseEntity = mapper.Map<CheckInResponseEntity>(responseModel);

		// Krok 3: Nastaviť Cudzí kľúč (CheckInId) na základe nájdeného ID udalosti
		newResponseEntity.CheckInId = checkInEvent.Id;

		// Krok 4: Uložiť do databázy
		dbContext.CheckInResponses.Add(newResponseEntity);
		await dbContext.SaveChangesAsync();

		// Krok 5: Vrátiť namapovaný výsledok
		return mapper.Map<CheckInResponseDetailModel>(newResponseEntity);
	}
}