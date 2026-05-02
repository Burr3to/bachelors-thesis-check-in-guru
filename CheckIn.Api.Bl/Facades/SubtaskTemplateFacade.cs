using System.Linq.Expressions;
using AutoMapper;
using CheckIn.Api.Bl.Facades.Interfaces;
using CheckIn.Api.Bl.Hubs;
using CheckIn.Api.Bl.Services.Interfaces;
using CheckIn.Api.Common.Models.Create;
using CheckIn.Api.Common.Models.Details;
using CheckIn.Api.Common.Models.Lists;
using CheckIn.Api.Common.Models.Query;
using CheckIn.Api.Common.Models.Update;
using CheckIn.Api.Common.Results;
using CheckIn.Api.Dal;
using CheckIn.Api.Dal.Entities;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace CheckIn.Api.Bl.Facades;

public class SubtaskTemplateFacade(
    CheckInDbContext dbContext,
    IMapper mapper,
    IUserContext userContext,
    IHubContext<TaskHub> hubContext)
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
        return q => q.OrderBy(e => e.CreatedAt).ThenBy(e => e.Id);
    }

    // 1. CREATE - Pridanie novej podúlohy
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveCreateModelAsync(
        SubtaskTemplateCreateModel model)
    {
        // Najprv overíme, či má používateľ právo meniť tento task
        var parentTask = await dbContext.Tasks.FindAsync(model.ParentTaskId);
        if (parentTask == null)
            return Result<SubtaskTemplateDetailModel>.NotFound("Parent Task not found.");
        if (parentTask.CreatedById != CurrentUserId)
            return Result<SubtaskTemplateDetailModel>.Forbidden();

        // A. Vytvoríme samotnú šablónu (cez bázu)
        var result = await base.SaveCreateModelAsync(model);
        if (!result.IsSuccess) return result;

        var newTemplateId = result.Value!.Id;

        // B. SYNC: Nájdeme všetky existujúce ResponseGroups, ktoré už k tomuto tasku existujú
        // (To sú unikátne sety podúloh pre jednotlivých ľudí v Independent móde, 
        // alebo jeden spoločný set v Collaborative móde)
        var existingResponseGroups = await dbContext.SubtaskInstances
            .Where(i => i.TemplateSubtask.ParentTaskId == model.ParentTaskId)
            .Select(i => i.ResponseGroupId)
            .Distinct()
            .ToListAsync();

        if (existingResponseGroups.Any())
        {
            foreach (var groupId in existingResponseGroups)
            {
                var newInstance = new SubtaskInstanceEntity
                {
                    Id = Guid.NewGuid(),
                    TemplateSubtaskId = newTemplateId,
                    ResponseGroupId = groupId,
                    IsCompleted = false
                };
                await dbContext.SubtaskInstances.AddAsync(newInstance);
            }

            await dbContext.SaveChangesAsync();
        }

        // C. Notifikácia cez SignalR - povieme všetkým, že sa zmenila štruktúra aj inštancie
        await NotifyChanges(model.ParentTaskId);

        return result;
    }

    // 3. Override Update - pridáme SignalR notifikáciu
    public override async Task<Result<SubtaskTemplateDetailModel>> SaveUpdateModelAsync(
        SubtaskTemplateUpdateModel model)
    {
        var result = await base.SaveUpdateModelAsync(model);
        if (result.IsSuccess)
        {
            // Musíme zistiť ParentTaskId, aby sme vedeli kam poslať signál
            var template = await dbContext.Subtasks.FindAsync(model.Id);
            if (template != null) await NotifyChanges(template.ParentTaskId);
        }

        return result;
    }

    // 4. Override Delete - odstránime inštancie a notifikujeme
    public new async Task<Result<bool>> DeleteAsync(Guid entityId)
    {
        var template = await dbContext.Subtasks
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == entityId);
        if (template == null) return Result<bool>.NotFound();

        var parentTaskId = template.ParentTaskId;

        // EF Core by mal mať nastavené Cascade Delete na SubtaskInstances, 
        // ale ak nie, musíme ich zmazať ručne tu.

        var result = await base.DeleteAsync(entityId);
        if (result.IsSuccess)
        {
            await NotifyChanges(parentTaskId);
        }

        return result;
    }

    private async Task NotifyChanges(Guid taskId)
    {
        var roomName = taskId.ToString().ToLower().Trim();
        // Informujeme respondentov, aby si refreshli checklist
        await hubContext.Clients.Group(roomName).SendAsync("TaskInstancesChanged");
        // Informujeme autora (teba), aby si videl nové riadky v progress liste
        await hubContext.Clients.Group(roomName).SendAsync("TaskTemplatesChanged");
    }
}