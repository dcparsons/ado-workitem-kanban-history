using Harvest.models;

namespace Harvest.services
{
    public interface IADOService
    {
        IWiqlResult GetAllWorkItems();
        IWitData GetWorkItemInformation(IWiqlWitResult wit);
        IList<IWitData> GetWorkItemInformation(IEnumerable<IWiqlWitResult> workItems);
        IWiqlResult GetAllWorkItems(DateTime sinceDate);
    }
}
