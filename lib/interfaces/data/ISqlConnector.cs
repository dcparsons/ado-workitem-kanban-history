using Harvest.models;

namespace Harvest.data
{
    public interface ISqlConnector
    {
        void RunLoadWitWorkflow(IList<IWitData> witData);
        void AddWits(IList<IWitData> witData);
        void UpdateLastRunTime();
        DateTime? GetLastRuntime();
    }
}
