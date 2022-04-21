namespace Harvest.models
{
    public  interface IBulkWitDataResult
    {
        int count { get; set; }
        IList<WitData> value { get; set; }
    }
}
