namespace Harvest.models
{
    internal class BulkWitDataResult : IBulkWitDataResult
    {
        public int count { get; set; }
        public IList<WitData> value { get; set; }
    }
}
