namespace CheckIn.Api.Common.Models.Interfaces;

public interface IPageableQuery
{
    int PageNumber { get; set; }
    int PageSize { get; set; }
}