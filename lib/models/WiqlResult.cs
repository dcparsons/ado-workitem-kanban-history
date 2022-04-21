
namespace Harvest.models
{
    public class WiqlResult : IWiqlResult
    {
        public string queryType { get; set; }
        public string queryResultType { get; set; }
        public IList<WiqlWitResult> workItems { get; set; } = new List<WiqlWitResult>();
    }
}
