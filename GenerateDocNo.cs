using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls.WebParts;
using System.Data;

namespace DX_WebTemplate
{
    public class GenerateDocNo
    {
        string conString = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;

        public string GetLatest_DocNum(int docTypID, int companyID, int appID)
        {
            ITPORTALDataContext dbContxt = new ITPORTALDataContext(conString);

            var latestDocNum = "";

            try
            {
                var queryDoc = from doc in dbContxt.ITP_S_DocumentNumbers 
                               where doc.DocType_ID == docTypID  && 
                                     doc.Company_ID == companyID && 
                                     doc.App_ID == appID
                               select doc;

                foreach ( var docInfo in queryDoc )
                {
                    latestDocNum = docInfo.NextNum;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);  
                latestDocNum = "";
            }

            return latestDocNum;
        }

        /// <summary>
        /// Run Stored Procedure that generates document number based on data configured at table ITP_S_DocumentNumber
        /// </summary>
        /// <param name="par_doctypeID">Document Type ID (ITP_S_DocumentType)</param>
        /// <param name="par_companyID">Company ID (CompanyMaster.WASSId)</param>
        /// <param name="par_appID">Application ID (ITP_S_SecurityApp)</param>
        public void RunStoredProc_GenerateDocNum(int par_doctypeID, int par_companyID, int par_appID)
        {
            SqlConnection conn = null;
            SqlDataReader rdr = null;

            string sp_name = "sp_upd_DocNxtNum";
            string parName1 = "@p_DocTypID";
            string parName2 = "@p_CompanyID";
            string parName3 = "@p_AppID";

            try
            {
                // create and open a connection object
                conn = new
                    SqlConnection(conString);
                conn.Open();

                // 1. create a command object identifying
                // the stored procedure
                SqlCommand cmd = new SqlCommand(
                    sp_name, conn);

                // 2. set the command object so it knows
                // to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. add parameter to command, which
                // will be passed to the stored procedure
                cmd.Parameters.Add(
                    new SqlParameter(parName1, par_doctypeID));
                cmd.Parameters.Add(
                    new SqlParameter(parName2, par_companyID));
                cmd.Parameters.Add(
                    new SqlParameter(parName3, par_appID));

                // execute the command
                rdr = cmd.ExecuteReader();
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
                if (rdr != null)
                {
                    rdr.Close();
                }
            }

        }
    }
}