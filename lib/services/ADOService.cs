using Harvest.models;
using Microsoft.Extensions.Configuration;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace Harvest.services
{
    public class ADOService : IADOService
    {
        private readonly IConfiguration _config;
        private string _creds = string.Empty;
        private string Credentials
        {
            get
            {
                if (!string.IsNullOrEmpty(_creds)) return _creds;
                _creds = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(string.Format("{0}:{1}", "", _config["PAT"])));
                return _creds;
            }
        }

        internal ADOService(IConfiguration config)
        {
            _config = config;
        }

        /// <summary>
        /// Returns an unbounded list of all Work Items of type: User Story and Bug for the entire project. 
        /// </summary>
        /// <returns></returns>
        public IWiqlResult GetAllWorkItems()
        {
            var wiqlUrl = String.Concat(_config["DEVOPS_URL"], _config["DEVOPS_ORG_NAME"], "/", _config["DEVOPS_PROJECT_NAME"], "/", _config["DEVOPS_TEAM_NAME"], "/", _config["WIQL_API_PATH"]);

            var httpBody = new StringContent("{\"query\":\"" + _config["GETALLWORKITEMS"] + "\"}", Encoding.UTF8, "application/json");
            return PostApiData<WiqlResult>(wiqlUrl, httpBody);
        }

        /// <summary>
        /// Get all work items from ADO that have been modified or created since the provided date. 
        /// </summary>
        /// <param name="sinceDate">The date used to filter the query</param>
        /// <returns></returns>
        public IWiqlResult GetAllWorkItems(DateTime sinceDate)
        {
            var wiqlUrl = String.Concat(_config["DEVOPS_URL"], _config["DEVOPS_ORG_NAME"], "/", _config["DEVOPS_PROJECT_NAME"], "/", _config["DEVOPS_TEAM_NAME"], "/", _config["WIQL_API_PATH"]);

            var httpBody = new StringContent("{\"query\":\"" + string.Format(_config["GETWORKITEMSSINCELASTRUN"], sinceDate.ToShortDateString()) + "\"}", Encoding.UTF8, "application/json");
            return PostApiData<WiqlResult>(wiqlUrl, httpBody);
         }

        /// <summary>
        /// Returns information about a single WIT.  This method is good for when there are very few Work Items.
        /// </summary>
        /// <param name="wit">The WorkItem to get information about</param>
        /// <returns></returns>
        public IWitData GetWorkItemInformation(IWiqlWitResult wit)
        {
            var witUrl = String.Concat(_config["DEVOPS_URL"], _config["DEVOPS_ORG_NAME"], "/", _config["DEVOPS_PROJECT_NAME"], "/", String.Format(_config["WIT_API_PATH"], wit.id));

            return GetApiData<WitData>(witUrl);
        }

        /// <summary>
        /// Gets information about WITs in bulk.  This is the preferred way to pull data because it is
        /// much quicker than pulling the data for each individual WIT sequentially. 
        /// </summary>
        /// <param name="workItems">The list of WorkItems to get information about</param>
        /// <returns></returns>
        public IList<IWitData> GetWorkItemInformation(IEnumerable<IWiqlWitResult> workItems)
        {
            var itemCount = workItems.Count();
            var skip = 0;
            string ids = string.Empty;
            string witUrl = string.Empty;

            var maxCount = Convert.ToInt32(_config["MAX_BULK_ADO_COUNT"]);


            IList<IWitData> result = new List<IWitData>();

            while (itemCount > 0)
            {
                if(itemCount > maxCount)
                {
                    ids = string.Join(",", workItems.Skip(skip).Take(maxCount).Select(x => x.id));
                    skip += maxCount;
                    itemCount -= maxCount;
                }
                else
                {
                    ids = string.Join(",", workItems.Skip(skip).Take(itemCount).Select(x => x.id));
                    itemCount = 0;
                }

                witUrl = String.Concat(_config["DEVOPS_URL"], _config["DEVOPS_ORG_NAME"], "/", _config["DEVOPS_PROJECT_NAME"], "/", String.Format(_config["WIT_API_PATH_BULK"], ids));
                var respData = GetApiData<BulkWitDataResult>(witUrl);

                result = result.Concat(respData.value).ToList();
            }

            return result;
        }

        private T GetApiData<T>(string apiUrl)
        {
            using (var client = new HttpClient())
            {
                var req = new HttpRequestMessage(HttpMethod.Get, apiUrl);
                req.Headers.Authorization = new AuthenticationHeaderValue("Basic", Credentials);

                var resp = client.Send(req);

                //resp.EnsureSuccessStatusCode();

                var content = resp.Content.ReadAsStringAsync().Result;

                return JsonSerializer.Deserialize<T>(content);
            }
        }

        private T PostApiData<T>(string apiUrl, HttpContent? postBody = null)
        {
            using (var client = new HttpClient())
            {
                var req = new HttpRequestMessage(HttpMethod.Post, apiUrl);
                var credentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(string.Format("{0}:{1}", "", _config["PAT"])));
                req.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);

                req.Content = postBody;
                var resp = client.Send(req);

                //resp.EnsureSuccessStatusCode();

                var content = resp.Content.ReadAsStringAsync().Result;

                return JsonSerializer.Deserialize<T>(content);
            }
        }
    }
}
