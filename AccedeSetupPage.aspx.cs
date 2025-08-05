using DevExpress.Web;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeSetupPage : System.Web.UI.Page
    {
        string ITPORTALcon = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void gridMain_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {

        }

        [WebMethod]
        public static string SaveIOAJAX(string io_num, string io_desc, string io_comp, string isActive)
        {
            AccedeSetupPage page = new AccedeSetupPage();
            return page.SaveIO(io_num, io_desc, io_comp, isActive);
        }

        public string SaveIO(string io_num, string io_desc, string io_comp, string isActive)
        {
            try
            {
                var existing_io = _DataContext.ACCEDE_S_IOs.Where(x => x.IO_Num == io_num).FirstOrDefault();
                var compSapCode = _DataContext.CompanyMasters.Where(x => x.WASSId == Convert.ToInt32(io_comp)).FirstOrDefault();
                if (existing_io != null)
                {
                    existing_io.IO_Description = io_desc;
                    existing_io.CompanyId = Convert.ToInt32(io_comp);
                    existing_io.isActive = Convert.ToBoolean(isActive);
                    existing_io.CompanySAPCode = compSapCode.SAP_Id.ToString();
                }
                else
                {
                    ACCEDE_S_IO io = new ACCEDE_S_IO();
                    {
                        io.IO_Num = io_num;
                        io.IO_Description = io_desc;
                        io.CompanyId = Convert.ToInt32(io_comp);
                        io.CompanySAPCode = compSapCode.SAP_Id.ToString();
                        io.isActive = Convert.ToBoolean(isActive);
                    }

                    _DataContext.ACCEDE_S_IOs.InsertOnSubmit(io);
                }

                _DataContext.SubmitChanges();

                return "success";
            }
            catch (Exception ex)
            {

                return ex.Message;
            }
            
        }

        protected void UploadControllerIO_FileUploadComplete(object sender, DevExpress.Web.FileUploadCompleteEventArgs e)
        {
            string filePath = Server.MapPath("~/Temp/" + e.UploadedFile.FileName);
            e.UploadedFile.SaveAs(filePath);

            // Process and return message
            e.CallbackData = ProcessAndInsertData(filePath);

            File.Delete(filePath); // Delete the uploaded file if needed
        }

        private string ProcessAndInsertData(string filePath)
        {
            try
            {
                ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

                using (var package = new ExcelPackage(new FileInfo(filePath)))
                {
                    var worksheet = package.Workbook.Worksheets[0];
                    var rowCount = worksheet.Dimension.End.Row;

                    using (var connection = new SqlConnection(ITPORTALcon))
                    {
                        connection.Open();

                        for (int row = 2; row <= rowCount; row++)
                        {
                            string ioNum = worksheet.Cells[row, 1].Text?.Trim();           // Column A
                            string ioDescription = worksheet.Cells[row, 9].Text?.Trim();   // Column I
                            string companySAPCode = worksheet.Cells[row, 11].Text?.Trim(); // Column K
                            string statusFlag = worksheet.Cells[row, 27].Text?.Trim();     // Column AA

                            if (string.IsNullOrWhiteSpace(ioNum))
                                continue; // Skip blank rows

                            bool isActive = statusFlag != "X";

                            // Get CompanyId
                            int? companyId = GetCompanyIdBySAPCode(connection, companySAPCode);
                            if (companyId == null)
                            {
                                Console.WriteLine($"Skipping row {row}: Company SAP code not found: {companySAPCode}");
                                continue;
                            }

                            // Check if IO_Num exists
                            bool exists = CheckIfIONumExists(connection, ioNum);

                            if (exists)
                            {
                                // Update existing row
                                using (var cmd = new SqlCommand(@"
                        UPDATE ACCEDE_S_IO 
                        SET IO_Description = @IO_Description, 
                            isActive = @isActive, 
                            CompanyId = @CompanyId, 
                            CompanySAPCode = @CompanySAPCode
                        WHERE IO_Num = @IO_Num", connection))
                                {
                                    cmd.Parameters.AddWithValue("@IO_Num", ioNum);
                                    cmd.Parameters.AddWithValue("@IO_Description", ioDescription);
                                    cmd.Parameters.AddWithValue("@isActive", isActive);
                                    cmd.Parameters.AddWithValue("@CompanyId", companyId);
                                    cmd.Parameters.AddWithValue("@CompanySAPCode", companySAPCode);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                // Insert new row
                                using (var cmd = new SqlCommand(@"
                        INSERT INTO ACCEDE_S_IO (IO_Num, IO_Description, isActive, CompanyId, CompanySAPCode)
                        VALUES (@IO_Num, @IO_Description, @isActive, @CompanyId, @CompanySAPCode)", connection))
                                {
                                    cmd.Parameters.AddWithValue("@IO_Num", ioNum);
                                    cmd.Parameters.AddWithValue("@IO_Description", ioDescription);
                                    cmd.Parameters.AddWithValue("@isActive", isActive);
                                    cmd.Parameters.AddWithValue("@CompanyId", companyId);
                                    cmd.Parameters.AddWithValue("@CompanySAPCode", companySAPCode);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                }

                return "IO import completed successfully!";
            }
            catch (Exception ex)
            {

                return $"An error occurred during import: {ex.Message}";
            }
            
        }


        private int? GetCompanyIdBySAPCode(SqlConnection connection, string sapCode)
        {
            using (var cmd = new SqlCommand("SELECT WASSId FROM CompanyMaster WHERE SAP_Id = @SAP_Id", connection))
            {
                cmd.Parameters.AddWithValue("@SAP_Id", sapCode);
                var result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value)
                    return null;

                return Convert.ToInt32(result);
            }
        }

        private bool CheckIfIONumExists(SqlConnection connection, string ioNum)
        {
            using (var cmd = new SqlCommand("SELECT 1 FROM ACCEDE_S_IO WHERE IO_Num = @IO_Num", connection))
            {
                cmd.Parameters.AddWithValue("@IO_Num", ioNum);
                var result = cmd.ExecuteScalar();
                return result != null;
            }
        }


    }
}