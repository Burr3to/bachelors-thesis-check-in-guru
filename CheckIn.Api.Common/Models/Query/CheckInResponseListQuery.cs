namespace CheckIn.Api.Common.Models.Query;

public class CheckInResponseListQuery : ListQuery
{

    public Guid? CheckInEventId { get; set; }
}