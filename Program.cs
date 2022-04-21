using Harvest.data;
using Harvest.models;
using Harvest.services;
using Microsoft.Extensions.Configuration;

namespace Harvest 
{
    internal class Program
    {
        private static IConfiguration _config;
        private static IADOService _adoService;
        private static ISqlConnector _sqlConnector;

        static void Main(string[] args)
        {
            _config = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
            _adoService = new ADOService(_config);
            _sqlConnector = new SqlConnector(_config);

            HarvestData();
        }

        private static void HarvestData()
        {
            IWiqlResult witQueryResult;
            var lastRunDate = _sqlConnector.GetLastRuntime();

            if (!lastRunDate.HasValue)
                witQueryResult = _adoService.GetAllWorkItems();
            else
                witQueryResult = _adoService.GetAllWorkItems(lastRunDate.Value);

            IList<IWitData> workItems = _adoService.GetWorkItemInformation(witQueryResult.workItems.Cast<IWiqlWitResult>());

            _sqlConnector.RunLoadWitWorkflow(workItems);
        }

    }
}