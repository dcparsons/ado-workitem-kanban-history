using System.Data;
using Harvest.models;
using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Text.Json;

namespace Harvest.data
{
    public class SqlConnector : ISqlConnector
    {
        private readonly IConfiguration _config;
        internal SqlConnector(IConfiguration config)
        {
            _config = config;
        }

        public void AddWits(IList<IWitData> witData)
        {
            using (var cnx = new SqlConnection(_config.GetConnectionString("ADOAnalysis")))
            {
                cnx.Open();
                var cmd = new SqlCommand(Queries.USP_ADDWORKITEM, cnx);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@witJson", JsonSerializer.Serialize(witData));

                cmd.ExecuteNonQuery();

            }
        }

        public void RunLoadWitWorkflow(IList<IWitData> witData)
        {
            using (var cnx = new SqlConnection(_config.GetConnectionString("ADOAnalysis")))
            {
                cnx.Open();
                var cmd = new SqlCommand(Queries.WORKFLOW_LOADWITDATA, cnx);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@witJson", JsonSerializer.Serialize(witData));

                cmd.ExecuteNonQuery();

            }
        }

        public DateTime? GetLastRuntime()
        {
            using (var cnx = new SqlConnection(_config.GetConnectionString("ADOAnalysis")))
            {
                cnx.Open();
                var cmd = new SqlCommand(Queries.USP_GETLASTRUNTIME, cnx);
                cmd.CommandType = CommandType.StoredProcedure;

                var dtm = cmd.ExecuteScalar();

                if(dtm != null) return (DateTime?)dtm;  
            }

            return null;
        }

        public void UpdateLastRunTime()
        {
            using (var cnx = new SqlConnection(_config.GetConnectionString("ADOAnalysis")))
            {
                cnx.Open();
                var cmd = new SqlCommand(Queries.USP_UPDATELASTRUNTIME, cnx);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.ExecuteNonQuery();

            }
        }
    }
}
