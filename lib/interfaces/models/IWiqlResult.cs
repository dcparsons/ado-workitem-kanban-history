namespace Harvest.models
{
    public interface IWiqlResult
    {
        public string queryType { get; set; }
        public string queryResultType { get; set; }
        public IList<WiqlWitResult> workItems { get; set; }
    }
}
