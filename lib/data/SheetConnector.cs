using Google.Apis.Auth.OAuth2;
using Google.Apis.Services;
using Google.Apis.Sheets.v4;
using Google.Apis.Sheets.v4.Data;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;


namespace Harvest.data
{
    internal class SheetConnector
    {
        private readonly IConfiguration _config;
        private string[] _sheetScopes = { SheetsService.Scope.Spreadsheets };

        private SheetsService _sheetService;
        private SheetsService SheetService
        {
            get
            {
                if( _sheetService != default(SheetsService)) return _sheetService;
                ConnectSheetService();
                return _sheetService;
            }
        }

        internal SheetConnector(IConfiguration config)
        {
            _config = config;
        }

        public string UpdateSheet(List<IList<object>> data)
        {
            var nextRowNumber = SheetService.Spreadsheets.Values.Get(_config["SHEET_ID"], "Sheet1!A1:B")?.Execute().Values.Count;
            nextRowNumber += 1;

            var range = String.Format("Sheet1!A{0}:D", nextRowNumber);

            var dataValueRange = new ValueRange();
            dataValueRange.Range = range;
            dataValueRange.Values = data;

            var req = SheetService.Spreadsheets.Values.Append(dataValueRange, _config["SHEET_ID"], range);
            req.ValueInputOption = SpreadsheetsResource.ValuesResource.AppendRequest.ValueInputOptionEnum.USERENTERED;

            var resp = req.Execute();

            return JsonConvert.SerializeObject(resp);
        }

        private void ConnectSheetService()
        {
            GoogleCredential credential;

            using (var stream = new FileStream(Path.Combine(Environment.CurrentDirectory, "configs/credentials.json"),FileMode.Open, FileAccess.Read))
            {
                credential = GoogleCredential.FromStream(stream).CreateScoped(_sheetScopes);
            }

            _sheetService = new SheetsService(new BaseClientService.Initializer()
            {
                HttpClientInitializer = credential,
                ApplicationName = _config["GCP_PROJECT_NAME"]
            });

        }

    }
}
