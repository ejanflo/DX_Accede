using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TravelExpenseAddDetails : System.Web.UI.Page
    {
        DataSet ds = null;
        DataSet dsDoc = null;

        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            ASPxGridView22.DataSource = ds.Tables[0];
            ASPxGridView22.DataBind();

            TraDocuGrid.DataSource = dsDoc.Tables[0];
            TraDocuGrid.DataBind();
        }

        protected void ASPxPopupControl1_Init(object sender, EventArgs e)
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("TravelExpenseDetailMap_ID", "LocParticulars", "ReimTranspo_Type1", "ReimTranspo_Amount1", "ReimTranspo_Type2", "ReimTranspo_Amount2", "ReimTranspo_Type3", "ReimTranspo_Amount3", "FixedAllow_ForP", "FixedAllow_Remarks", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount", "OtherBus_Type", "OtherBus_Specify", "OtherBus_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
                ds = (DataSet)Session["DataSet"];


            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileAttachment", typeof(byte[]));
                masterTable.Columns.Add("FileExtension", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("Description", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;
            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
        }

        private DataTable CreateDataTable(string idColumnName, params string[] columnNames)
        {
            var table = new DataTable();
            table.Columns.Add(idColumnName, typeof(int));
            foreach (var columnName in columnNames)
            {
                Type columnType = columnName.Contains("Amount") ? typeof(decimal) : typeof(string);
                table.Columns.Add(columnName, columnType);
            }
            table.PrimaryKey = new[] { table.Columns[idColumnName] };
            return table;
        }

        protected void TraUploadController_FilesUploadComplete(object sender, DevExpress.Web.FileUploadCompleteEventArgs e)
        {
            DataSet ImgDS = (DataSet)Session["DataSetDoc"];
            foreach (var file in TraUploadController.UploadedFiles)
            {
                var filesize = 0.00;
                var filesizeStr = "";
                if (Convert.ToInt32(file.ContentLength) > 999999)
                {
                    filesize = Convert.ToInt32(file.ContentLength) / 1000000;
                    filesizeStr = filesize.ToString() + " MB";
                }
                else if (Convert.ToInt32(file.ContentLength) > 999)
                {
                    filesize = Convert.ToInt32(file.ContentLength) / 1000;
                    filesizeStr = filesize.ToString() + " KB";
                }
                else
                {
                    filesize = Convert.ToInt32(file.ContentLength);
                    filesizeStr = filesize.ToString() + " Bytes";
                }

                // Add a new row to the data table with the uploaded file data
                DataRow row = ImgDS.Tables[0].NewRow();
                row["ID"] = GetNewDocId();
                row["FileName"] = file.FileName;
                row["FileAttachment"] = file.FileBytes;
                row["FileExtension"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["Description"] = "";
                ImgDS.Tables[0].Rows.Add(row);
            }

            // Bind the data set to the grid view
            Session["UploadedFilesTable"] = ImgDS.Tables[0];
            TraDocuGrid.DataSource = ImgDS.Tables[0];
            TraDocuGrid.DataBind();
        }

        private int GetNewDocId()
        {
            dsDoc = (DataSet)Session["DataSetDoc"];
            DataTable table = dsDoc.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["ID"]);
            }
            return max + 1;
        }

        [WebMethod]
        public static string AddTravelExpenseDetailsAJAX(DateTime travelDate, string totalExp)
        {
            TravelExpenseAddDetails exp = new TravelExpenseAddDetails();
            return exp.AddTravelExpenseDetails(travelDate, totalExp);
        }

        public string AddTravelExpenseDetails(DateTime travelDate, string totalExp)
        {
            try
            {
                int travelExpMainId = Convert.ToInt32(Session["TravelExp_Id"]);
                decimal totalExpenses = Convert.ToDecimal(totalExp);
                var trav = new ACCEDE_T_TravelExpenseDetail
                {
                    TravelExpenseDetail_Date = travelDate,
                    TravelExpenseMain_ID = travelExpMainId,
                    Total_Expenses = totalExpenses
                };

                context.ACCEDE_T_TravelExpenseDetails.InsertOnSubmit(trav);
                context.SubmitChanges(); // Get the ID after saving

                int travExpDetailId = trav.TravelExpenseDetail_ID;

                InsertAttachments(travExpDetailId);

                var dataSet = Session["DataSet"] as DataSet;
                if (dataSet == null || dataSet.Tables.Count == 0)
                    return "TravelExpenseAdd.aspx";

                InsertMappedData<ACCEDE_T_TravelExpenseDetailsMap>(dataSet.Tables[0], (map, row) =>
                {
                    map.LocParticulars = row["LocParticulars"]?.ToString() ?? string.Empty;
                    map.ReimTranspo_Type1 = row["ReimTranspo_Type1"]?.ToString() ?? string.Empty;
                    map.ReimTranspo_Amount1 = row["ReimTranspo_Amount1"] == DBNull.Value ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount1"]);
                    map.ReimTranspo_Type2 = row["ReimTranspo_Type2"]?.ToString() ?? string.Empty;
                    map.ReimTranspo_Amount2 = row["ReimTranspo_Amount2"] == DBNull.Value ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount2"]);
                    map.ReimTranspo_Type3 = row["ReimTranspo_Type3"]?.ToString() ?? string.Empty;
                    map.ReimTranspo_Amount3 = row["ReimTranspo_Amount3"] == DBNull.Value ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount3"]);
                    map.FixedAllow_ForP = row["FixedAllow_ForP"]?.ToString() ?? string.Empty;
                    map.FixedAllow_Amount = row["FixedAllow_Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["FixedAllow_Amount"]);
                    map.FixedAllow_Remarks = row["FixedAllow_Remarks"]?.ToString() ?? string.Empty;
                    map.MiscTravel_Type = row["MiscTravel_Type"]?.ToString() ?? string.Empty;
                    map.MiscTravel_Specify = row["MiscTravel_Specify"]?.ToString() ?? string.Empty;
                    map.MiscTravel_Amount = row["MiscTravel_Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["MiscTravel_Amount"]);
                    map.Entertainment_Explain = row["Entertainment_Explain"]?.ToString() ?? string.Empty;
                    map.Entertainment_Amount = row["Entertainment_Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["Entertainment_Amount"]);
                    map.BusMeals_Explain = row["BusMeals_Explain"]?.ToString() ?? string.Empty;
                    map.BusMeals_Amount = row["BusMeals_Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["BusMeals_Amount"]);
                    map.OtherBus_Type = row["OtherBus_Type"]?.ToString() ?? string.Empty;
                    map.OtherBus_Specify = row["OtherBus_Specify"]?.ToString() ?? string.Empty;
                    map.OtherBus_Amount = row["OtherBus_Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["OtherBus_Amount"]);
                    map.TravelExpenseDetail_ID = travExpDetailId;
                });

                context.SubmitChanges();

                return "TravelExpenseAdd.aspx";
            }
            catch (Exception)
            {
                throw; // Consider logging the error
            }

            // Local method for reusability
            void InsertMappedData<T>(DataTable table, Action<T, DataRow> mapAction) where T : class, new()
            {
                foreach (DataRow row in table.Rows)
                {
                    // Check if row is not empty
                    bool isEmptyRow = table.Columns
                        .Cast<DataColumn>()
                        .All(c => row[c] == DBNull.Value || string.IsNullOrWhiteSpace(row[c]?.ToString()) || decimal.TryParse(row[c]?.ToString(), out var val) && val == 0);

                    if (isEmptyRow)
                        continue;

                    T entity = new T();
                    mapAction(entity, row);
                    context.GetTable<T>().InsertOnSubmit(entity);
                }
            }
        }


        public void InsertAttachments(int id)
        {
            try
            {
                var uploadedFilesTable = Session["UploadedFilesTable"] as DataTable;
                if (uploadedFilesTable == null || uploadedFilesTable.Rows.Count == 0)
                    return;

                string connectionString = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                int travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                string docNo = Session["DocNo"]?.ToString() ?? string.Empty;
                string userId = Session["userID"]?.ToString() ?? "0";

                // Fetch once outside loop
                int? companyId = context.ACCEDE_T_TravelExpenseMains
                    .Where(x => x.ID == travelExpId)
                    .Select(x => x.Company_Id)
                    .FirstOrDefault();

                int? docTypeId = context.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense Travel")
                    .Select(x => x.DCT_Id)
                    .FirstOrDefault();

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    string query = @"INSERT INTO ITP_T_FileAttachment(FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) OUTPUT INSERTED.ID VALUES(@FileAttachment, @FileName, @Description, @DateUploaded, @App_ID, @Company_ID, @Doc_ID, @Doc_No, @User_ID, @FileExtension, @FileSize, @DocType_Id)";

                    foreach (DataRow row in uploadedFilesTable.Rows)
                    {
                        using (SqlCommand command = new SqlCommand(query, connection))
                        {
                            command.Parameters.AddWithValue("@FileAttachment", row["FileAttachment"]);
                            command.Parameters.AddWithValue("@FileName", row["FileName"].ToString());
                            command.Parameters.AddWithValue("@Description", row["Description"].ToString());
                            command.Parameters.AddWithValue("@DateUploaded", DateTime.Now);
                            command.Parameters.AddWithValue("@App_ID", 1032);
                            command.Parameters.AddWithValue("@Company_ID", companyId != null ? (object)companyId : DBNull.Value);
                            command.Parameters.AddWithValue("@Doc_ID", id);
                            command.Parameters.AddWithValue("@Doc_No", docNo);
                            command.Parameters.AddWithValue("@User_ID", userId);
                            command.Parameters.AddWithValue("@FileExtension", row["FileExtension"].ToString());
                            command.Parameters.AddWithValue("@FileSize", row["FileSize"].ToString());
                            command.Parameters.AddWithValue("@DocType_Id", docTypeId != null ? (object)docTypeId : DBNull.Value);

                            int insertedId = (int)command.ExecuteScalar();

                            var attachmentLink = new ACCEDE_T_TravelExpenseDetailsFileAttach
                            {
                                FileAttachment_ID = insertedId,
                                ExpenseDetails_ID = id
                            };

                            context.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(attachmentLink);
                        }
                    }

                    context.SubmitChanges();
                }
            }
            catch (Exception)
            {
                throw; // Consider logging here
            }
        }

        protected void ASPxFormLayout7_Init(object sender, EventArgs e)
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("TravelExpenseDetailMap_ID", "LocParticulars", "ReimTranspo_Type1", "ReimTranspo_Amount1", "ReimTranspo_Type2", "ReimTranspo_Amount2", "ReimTranspo_Type3", "ReimTranspo_Amount3", "FixedAllow_ForP", "FixedAllow_Remarks", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount", "OtherBus_Type", "OtherBus_Specify", "OtherBus_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
                ds = (DataSet)Session["DataSet"];


            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileAttachment", typeof(byte[]));
                masterTable.Columns.Add("FileExtension", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("Description", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;
            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
        }

        protected void ASPxGridView22_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
        }

        protected void popupSubmitBtn_Click(object sender, EventArgs e)
        {
            ASPxGridView22.UpdateEdit();
        }
    }
}