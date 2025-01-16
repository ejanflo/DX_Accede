using DevExpress.CodeParser;
using DevExpress.Web;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class ReportViewPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    //Start ------------------ Page Security
                    string empCode = Session["userID"].ToString();
                    int appID = 26; //22-ITPORTAL; 13-CAR; 26-RS; 1027-RFP; 1028-UAR

                    string url = Request.Url.AbsolutePath; // Get the current URL
                    string pageName = Path.GetFileNameWithoutExtension(url); // Get the filename without extension


                    //if (!AnfloSession.Current.hasPageAccess(empCode, appID, pageName))
                    //{
                    //    Session["appID"] = appID.ToString();
                    //    Session["pageName"] = pageName.ToString();

                    //    Response.Redirect("~/ErrorAccess.aspx");
                    //}
                    //End ------------------ Page Security

                    sqlMain.SelectParameters["ID"].DefaultValue = Session["passAccedeID"].ToString();
                    SqlExpense.SelectParameters["ACDE_Main_ID"].DefaultValue = Session["passAccedeID"].ToString();

                    var MainDetails = _DataContext.ACDE_T_Mains
                        .Where(x => x.ID == Convert.ToInt32(Session["passAccedeID"]))
                        .FirstOrDefault();

                    //txt_Itinerary.Text = MainDetails.ItineraryName.ToString();
                    //drpdwn_TripType.Value = MainDetails.TravelType_ID.ToString();
                    
                }
                else
                {
                    //Session["MyRequestPath"] = Request.Url.AbsoluteUri;
                    Response.Redirect("~/Logon.aspx");
                }
            }
            catch (Exception ex)
            {
                //Session["MyRequestPath"] = Request.Url.AbsoluteUri;
                Response.Redirect("~/Logon.aspx");
            }
        }

        DataSet dsDoc = null;
        protected void formAccede_Init(object sender, EventArgs e)
        {
            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileByte", typeof(byte[]));
                masterTable.Columns.Add("FileExt", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("FileDesc", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;

            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
                DocuGrid.DataSource = dsDoc.Tables[0];
                DocuGrid.DataBind();

            if (Session["passAccedeID"] != null)
            {
                var rs_id = Session["passAccedeID"].ToString();

                var accedeMain = _DataContext.vw_ACDE_MainTotalExpenses.Where(x => x.ID == Convert.ToInt32(rs_id)).FirstOrDefault();

                var myLayoutGroup = formAccede.FindItemOrGroupByName("PageTitle") as LayoutGroup;

                if (accedeMain != null)
                {
                    string formattedTotal = Convert.ToDecimal(accedeMain.Total).ToString("#,##0.00");
                    myLayoutGroup.Caption = accedeMain.ReportName.ToString() + " | PHP " + formattedTotal;
                }
                else
                {
                    myLayoutGroup.Caption = accedeMain.ReportName.ToString();
                }

            }
        }

        private int GetNewId()
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

        protected void ExpenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {

        }

        protected void ExpenseGrid_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
        {

        }

        protected void ExpenseGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {

        }

        protected void ExpenseGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
        }

        [WebMethod]
        public static string InsertExpenseServerSide(int expType, int expCat, string dateTransact, 
            string businessPurpose, string vendorName, string vendorTIN, 
            string vendorAdd, string cityPurch, string invoiceOR, string payType, 
            int recStatus, decimal amount, string currency, decimal WTAXamnt, 
            string WTAX_atc, string interOrder, string WBS, string asset, 
            string subAsset, decimal GST, decimal amntTaxExempt, string comment)
        {
           ReportViewPage reportViewPage = new ReportViewPage();
            return reportViewPage.InsertExpense(expType, expCat, dateTransact, 
                businessPurpose, vendorName, vendorTIN, vendorAdd, cityPurch, 
                invoiceOR, payType, recStatus, amount, currency, WTAXamnt, 
                WTAX_atc, interOrder, WBS, asset, subAsset, GST, amntTaxExempt, comment);
        }

        public string InsertExpense(int expType, int expCat, string dateTransact, 
            string businessPurpose, string vendorName, string vendorTIN, 
            string vendorAdd, string cityPurch, string invoiceOR, string payType, 
            int recStatus, decimal amount, string currency, decimal WTAXamnt, string WTAX_atc, 
            string interOrder, string WBS, string asset, string subAsset, decimal GST, 
            decimal amntTaxExempt, string comment)
        {
            if (Session["DataSetDoc"] != null)
            {
                try
                {

                    DateTime dateTransaction = Convert.ToDateTime(dateTransact);
                    ACDE_T_Expense expense = new ACDE_T_Expense();
                    {
                        expense.ACDE_Main_ID = Convert.ToInt32(Session["passAccedeID"]);
                        expense.ExpenseType_ID = expType;
                        expense.ExpenseCategory = expCat;
                        expense.TransactionDate = dateTransaction;
                        expense.BusinessPurpose = businessPurpose != "" ? businessPurpose : null;
                        expense.VendorName = vendorName != "" ? vendorName : null;
                        expense.VendorTIN = vendorTIN != "" ? vendorTIN : null;
                        expense.VendorAddress = vendorAdd != "" ? vendorAdd : null;
                        expense.CityOfPurchase = cityPurch;
                        expense.InvoiceORNum = invoiceOR != "" ? invoiceOR : null;
                        expense.PaymentType = payType;
                        expense.ReceiptStatus = recStatus;
                        expense.Requested_Amount = amount;
                        expense.Currency_ID = Convert.ToInt32(currency);
                        if (WTAXamnt != Convert.ToDecimal(0.00))
                        {
                            expense.WithholdingTaxAmnt = WTAXamnt;
                        }
                        expense.WithholdingTaxATC = WTAX_atc != "" ? WTAX_atc : null;
                        expense.InternalOrder = interOrder != "" ? interOrder : null;
                        expense.WBSElement = WBS != "" ? WBS : null;
                        expense.AssetNum = asset != "" ? asset : null;
                        expense.SubAssetNum = subAsset != "" ? subAsset : null;
                        expense.GSTAmnt = GST;
                        if (amntTaxExempt != Convert.ToDecimal(0.00))
                        {
                            expense.VATExempt = amntTaxExempt;
                        }
                        expense.Comment = comment;
                        expense.VendorDetails = cityPurch;

                    }

                    _DataContext.ACDE_T_Expenses.InsertOnSubmit(expense);
                    _DataContext.SubmitChanges();

                    var NewID = expense.ID;

                    //Insert Attachments
                    DataSet dsFile = (DataSet)Session["DataSetDoc"];
                    DataTable dataTable = dsFile.Tables[0];

                    if (dataTable.Rows.Count > 0)
                    {
                        string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                        string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Doc_ID, User_ID, FileExtension, FileSize) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @doc_id, @user_id, @fileExt, @filesize)";

                        using (SqlConnection connection = new SqlConnection(connectionString1))
                        using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                        {
                            // Define the parameters for the SQL query
                            command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                            command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                            command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                            command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                            command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                            command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                            command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                            command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                            command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);

                            // Open the connection to the database
                            connection.Open();

                            // Loop through the rows in the DataTable and insert them into the database
                            foreach (DataRow row in dataTable.Rows)
                            {
                                command.Parameters["@filename"].Value = row["FileName"];
                                command.Parameters["@file_byte"].Value = row["FileByte"];
                                command.Parameters["@desc"].Value = row["FileDesc"];
                                command.Parameters["@date_upload"].Value = DateTime.Now;
                                command.Parameters["@app_id"].Value = 1032;
                                command.Parameters["@doc_id"].Value = NewID;
                                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                                command.Parameters["@fileExt"].Value = row["FileExt"];
                                command.Parameters["@filesize"].Value = row["FileSize"];
                                command.ExecuteNonQuery();
                            }

                            // Close the connection to the database
                            connection.Close();


                        }
                    }



                }
                catch (Exception ex)
                {
                    return ex.Message;
                }
            }
            else
            {
                return "Receipt is required! Please upload a receipt and try again";
            }
            
            return "Valid";
        }

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            int i = DocuGrid.FindVisibleIndexByKeyValue(e.Keys[DocuGrid.KeyFieldName]);
            //Control c = DocuGrid.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            dsDoc = (DataSet)Session["DataSetDoc"];
            dsDoc.Tables[0].Rows.Remove(dsDoc.Tables[0].Rows.Find(e.Keys[DocuGrid.KeyFieldName]));
        }

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            dsDoc = (DataSet)Session["DataSetDoc"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsDoc.Tables[1] : dsDoc.Tables[0];
            DataRow row = dataTable.Rows.Find(e.Keys[0]);
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                row[enumerator.Key.ToString()] = enumerator.Value;
            gridView.CancelEdit();
            e.Cancel = true;
        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            // Create a new data table if it doesn't exist in the data set
            DataSet ImgDS = (DataSet)Session["DataSetDoc"];
            foreach (var file in UploadController.UploadedFiles)
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
                row["ID"] = GetNewId();
                row["FileName"] = file.FileName;
                row["FileByte"] = file.FileBytes;
                row["FileExt"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["FileDesc"] = "";
                ImgDS.Tables[0].Rows.Add(row);


            }

            // Bind the data set to the grid view
            DocuGrid.DataSource = ImgDS.Tables[0];

            DocuGrid.DataBind();
        }

        public Expense LookupExpenseData(int exp_id)
        {
            Expense exp = new Expense();
            var exp_data = _DataContext.ACDE_T_Expenses.Where(x => x.ID == exp_id).FirstOrDefault();
            {
                DateTime tranDate = Convert.ToDateTime(exp_data.TransactionDate);
                exp.PaymentType = exp_data.PaymentType;
                exp.ExpenseType_ID = Convert.ToInt32(exp_data.ExpenseType_ID);
                exp.vendorDetails = exp_data.VendorDetails;
                exp.TransactionDate = tranDate.ToString("MM/dd/yyyy");
                exp.Requested_Amount = Convert.ToDecimal(exp_data.Requested_Amount);
                exp.ExpenseCategory = Convert.ToInt32(exp_data.ExpenseCategory);
                exp.BusinessPurpose = exp_data.BusinessPurpose;
                exp.VendorName = exp_data.VendorName;
                exp.VendorTIN = exp_data.VendorTIN;
                exp.VendorAddress = exp_data.VendorAddress;
                exp.CityOfPurchase = exp_data.CityOfPurchase;
                exp.InvoiceORNum = exp_data.InvoiceORNum;
                exp.ReceiptStatus = Convert.ToInt32(exp_data.ReceiptStatus);
                exp.Currency_ID = Convert.ToInt32(exp_data.Currency_ID);
                exp.WithholdingTaxAmnt = Convert.ToDecimal(exp_data.WithholdingTaxAmnt);
                exp.WithholdingTaxATC = exp_data.WithholdingTaxATC;
                exp.WBSElement = exp_data.WBSElement;
                exp.InternalOrder = exp_data.InternalOrder;
                exp.AssetNum = exp_data.AssetNum;
                exp.SubAssetNum = exp_data.SubAssetNum;
                exp.TaxPostedAmnt = Convert.ToDecimal(exp_data.TaxPostedAmnt);
                exp.VATExempt = Convert.ToDecimal(exp_data.VATExempt);
                exp.Comment = exp_data.Comment;
                exp.GSTAmnt = Convert.ToDecimal(exp_data.GSTAmnt);
            }

            return exp;
            
        }

        [WebMethod]
        public static Expense VerifyExpenseType(string exp_id)
        {
            
            ReportViewPage reportViewPage = new ReportViewPage();
            return reportViewPage.LookupExpenseData(Convert.ToInt32(exp_id));
        }

        protected void drpdwn_ExpTypeEdit_Callback(object sender, CallbackEventArgsBase e)
        {
            
        }

        protected void DocumentGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpenseAttach.SelectParameters["Doc_ID"].DefaultValue = e.Parameters;
            SqlExpenseAttach.DataBind();

            Session["ExpenseID"] = e.Parameters;

            DocumentGrid.DataSourceID = null;
            DocumentGrid.DataSource = SqlExpenseAttach;
            DocumentGrid.DataBind();
        }

        protected void EditUploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            foreach (var file in EditUploadController.UploadedFiles)
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

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["ExpenseID"].ToString());
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.FileSize = filesizeStr;
                    docs.DateUploaded = DateTime.Now;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();

            SqlExpenseAttach.SelectParameters["Doc_ID"].DefaultValue = Session["ExpenseID"].ToString();
            SqlExpenseAttach.DataBind();

            DocumentGrid.DataBind();
        }
    }

    public class Expense
    {
        public int ID { get; set; }
        public string PaymentType { get; set; } 
        public int ExpenseType_ID { get; set; }
        public string vendorDetails { get; set; }
        public string TransactionDate { get; set; }
        public decimal Requested_Amount { get; set; }
        public int ExpenseCategory { get; set; }
        public string BusinessPurpose { get; set; }
        public string VendorName { get; set; }
        public string VendorTIN { get; set; }
        public string VendorAddress { get; set; }
        public string CityOfPurchase { get; set; }
        public string InvoiceORNum { get; set; }
        public int ReceiptStatus { get; set; }
        public int Currency_ID { get; set; }
        public decimal WithholdingTaxAmnt { get; set; }
        public string WithholdingTaxATC { get; set; }
        public string WBSElement { get; set; }
        public string InternalOrder { get; set; }
        public string AssetNum { get; set; }
        public string SubAssetNum { get; set; }
        public decimal TaxPostedAmnt { get; set; }
        public decimal VATExempt { get; set; }
        public string Comment { get; set; }
        public decimal GSTAmnt { get; set; }


    }

}