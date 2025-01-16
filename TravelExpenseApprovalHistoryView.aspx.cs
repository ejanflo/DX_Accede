using DevExpress.Web;
using DevExpress.Web.Data;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class TravelExpenseApprovalHistoryView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        DataSet ds = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();
                    var status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault();

                    if (mainExp != null)
                    {
                        ExpenseEditForm.Items[0].Caption = "Travel Expense Document No.: " + mainExp.Doc_No + " (" + status + ")";

                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());
                        Session["DocNo"] = mainExp.Doc_No.ToString();
                    }

                    CAGrid.DataBind();
                    ExpenseGrid.DataBind();

                    InitializeExpCA(mainExp);

                    var forAccounting = ExpenseEditForm.FindItemOrGroupByName("forAccounting") as LayoutGroup; 
                    var printItem = ExpenseEditForm.FindItemOrGroupByName("printItem") as LayoutItem;
                    var editItem = ExpenseEditForm.FindItemOrGroupByName("editItem") as LayoutItem;

                    //if (status.Contains("Pending at Finance"))
                    //    forAccounting.ClientVisible = true;
                    //else
                    //    forAccounting.ClientVisible = false;
                }
                else
                    Response.Redirect("~/Logon.aspx");
            }
            catch (Exception ex)
            {
                //Response.Redirect("~/Logon.aspx");
                Debug.WriteLine(ex.Message);
            }
        }

        private void InitializeExpCA(ACCEDE_T_TravelExpenseMain mainExp)
        {
            try
            {
                var due_lbl = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutItem;

                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reimDetails.ClientVisible = true;
                    reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                }

                var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                var userId = Convert.ToString(Session["userID"]);

                var totalca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId)
                    .Sum(x => (decimal?)x.Amount) ?? 0;

                var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Where(x => x.TravelExpenseMain_ID == travelExpId)
                    .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                var countCA = _DataContext.ACCEDE_T_RFPMains
                    .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId);

                var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Count(x => x.TravelExpenseMain_ID == travelExpId);

                var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                if (totalexp > totalca)
                {
                    due_lbl.Caption = "Due To Employee";
                }
                else
                {
                    due_lbl.Caption = "Due To Company";
                }

                drpdown_expenseType.Value = expType;
                lbl_caTotal.Text = totalca.ToString();
                lbl_expenseTotal.Text = totalexp.ToString();
                lbl_dueTotal.Text = totalexp > totalca ? $"({(totalexp - totalca):N2})" : (totalca - totalexp).ToString("N2");

                var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                SqlWF.SelectParameters["UserId"].DefaultValue = mainExp.Employee_Id.ToString();
                SqlWF.SelectParameters["CompanyId"].DefaultValue = mainExp.Company_Id.ToString();
                SqlWF.DataBind();

                Session["mainwfid"] = Convert.ToString(_DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == mainExp.Employee_Id.ToString() && x.CompanyId == mainExp.Company_Id).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                SqlWorkflowSequence.DataBind();

                Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF2.DataBind();
                SqlFAPWF.DataBind();
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void UploadController_FilesUploadComplete(object sender, DevExpress.Web.FilesUploadCompleteEventArgs e)
        {
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(companyCB.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
        }


        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            TravelExpenseReview exp = new TravelExpenseReview();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public bool RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.RFP_DocNum == rfpDoc).FirstOrDefault();
                if (rfp != null)
                {
                    Session["passRFPID"] = rfp.ID;
                }
                return true;
            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static ExpDetails DisplayExpDetailsAJAX(int expDetailID)
        {
            TravelExpenseApprovalHistoryView exp = new TravelExpenseApprovalHistoryView();
            return exp.DisplayExpDetails(expDetailID);
        }

        public ExpDetails DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == expDetailID).FirstOrDefault();
            ExpDetails exp_det_class = new ExpDetails();

            if (exp_details != null)
            {
                exp_det_class.travelDate = Convert.ToDateTime(exp_details.TravelExpenseDetail_Date).ToString("MM/dd/yyyy hh:mm:ss");
                if (exp_details.LocParticulars != null)
                {
                    exp_det_class.locParticulars = exp_details.LocParticulars;
                }
                if (exp_details.Total_Expenses != null)
                {
                    exp_det_class.totalExp = exp_details.Total_Expenses.ToString();
                }

                Session["ExpDetailsID"] = expDetailID.ToString();
            }

            return exp_det_class;
        }

        public class ExpDetails
        {
            public string travelDate { get; set; }
            public string locParticulars { get; set; }
            public string totalExp { get; set; }
        }

        protected void ExpenseEditForm_Init(object sender, EventArgs e)
        {
            InitializeDataSet();
        }

        private void InitializeDataSet()
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("ReimTranspo_ID", "ReimTranspo_Type", "ReimTranspo_Amount"),
                    CreateDataTable("FixedAllow_ID", "FixedAllow_ForP", "FixedAllow_Amount"),
                    CreateDataTable("MiscTravelExp_ID", "MiscTravelExp_Type", "MiscTravelExp_Amount", "MiscTravelExp_Specify"),
                    CreateDataTable("OtherBusinessExp_ID", "OtherBusinessExp_Type", "OtherBusinessExp_Amount", "OtherBusinessExp_Specify"),
                    CreateDataTable("Entertainment_ID", "Entertainment_Explain", "Entertainment_Amount"),
                    CreateDataTable("BusinessMeal_ID", "BusinessMeal_Explain", "BusinessMeal_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
            {
                ds = (DataSet)Session["DataSet"];
            }
        }

        protected void forAccountingGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["TravelExpenseMain_ID"] = Convert.ToInt32(Session["TravelExp_Id"]);
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

        private int GetNewId(int tableIndex, string idColumn)
        {
            var table = ds.Tables[tableIndex];
            return table.Rows.Count == 0 ? 0 : table.AsEnumerable().Max(row => row.Field<int>(idColumn)) + 1;
        }

        private DataTable GetDataTableFromSqlDataSource(SqlDataSource sqlDataSource)
        {
            DataView dataView = (DataView)sqlDataSource.Select(DataSourceSelectArguments.Empty);
            return dataView.ToTable();
        }

        protected void addExpCallback_Callback(object sender, CallbackEventArgsBase e)
        {
            // Clear the DataSet tables for the "add" action
            ds = (DataSet)Session["DataSet"];
            foreach (DataTable table in ds.Tables)
            {
                table.Clear();
            }
            if (e.Parameter == "add")
            {
                Session["expAction"] = "add";
            }
            else if (e.Parameter == "edit")
            {
                Session["expAction"] = "edit";

                // Load data from SqlDataSources into DataTables and merge
                ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlRTMap));
                ds.Tables[1].Merge(GetDataTableFromSqlDataSource(SqlFAMap));
                ds.Tables[2].Merge(GetDataTableFromSqlDataSource(SqlMTMap));
                ds.Tables[3].Merge(GetDataTableFromSqlDataSource(SqlOBMap));
                ds.Tables[4].Merge(GetDataTableFromSqlDataSource(SqlEMap));
                ds.Tables[5].Merge(GetDataTableFromSqlDataSource(SqlBMMap));
            }

            // Bind the tables to the grids
            reimTranGrid.DataSource = ds.Tables[0];
            fixedAllowGrid.DataSource = ds.Tables[1];
            miscTravelGrid.DataSource = ds.Tables[2];
            otherBusGrid.DataSource = ds.Tables[3];
            entertainmentGrid.DataSource = ds.Tables[4];
            busMealsGrid.DataSource = ds.Tables[5];

            // Data bind to refresh the grids
            reimTranGrid.DataBind();
            fixedAllowGrid.DataBind();
            miscTravelGrid.DataBind();
            otherBusGrid.DataBind();
            entertainmentGrid.DataBind();
            busMealsGrid.DataBind();

            reimTranGrid.JSProperties["cpSummary"] = reimTranGrid.GetTotalSummaryValue(reimTranGrid.TotalSummary["ReimTranspo_Amount"]);
            fixedAllowGrid.JSProperties["cpSummary"] = fixedAllowGrid.GetTotalSummaryValue(fixedAllowGrid.TotalSummary["FixedAllow_Amount"]);
            miscTravelGrid.JSProperties["cpSummary"] = miscTravelGrid.GetTotalSummaryValue(miscTravelGrid.TotalSummary["MiscTravelExp_Amount"]);
            otherBusGrid.JSProperties["cpSummary"] = otherBusGrid.GetTotalSummaryValue(otherBusGrid.TotalSummary["OtherBusinessExp_Amount"]);
            entertainmentGrid.JSProperties["cpSummary"] = entertainmentGrid.GetTotalSummaryValue(entertainmentGrid.TotalSummary["Entertainment_Amount"]);
            busMealsGrid.JSProperties["cpSummary"] = busMealsGrid.GetTotalSummaryValue(busMealsGrid.TotalSummary["BusinessMeal_Amount"]);
        }

        protected void ExpenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Fixed Allowances")
            {
                var amount = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpFixedAllowMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.FixedAllow_Amount));

                if (amount.ToString() == "0.00" || string.IsNullOrEmpty(amount.ToString()))
                    e.DisplayText = "0.00";
                else
                {
                    e.DisplayText = amount.ToString("N");
                }
            }

            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            {
                var amount1 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpMiscTravelMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.MiscTravelExp_Amount));
                var amount2 = _DataContext.ACCEDE_T_TraExpReimTranspoMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.ReimTranspo_Amount) ?? 0;
                var amount3 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpOtherBusMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.OtherBusinessExp_Amount));
                var amount4 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpEntertainmentMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.Entertainment_Amount));
                var amount5 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpBusinessMealMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.BusinessMeal_Amount));

                var total = Convert.ToDecimal(amount1 + amount2 + amount3 + amount4 + amount5);

                if (total.ToString() == "0.00" || string.IsNullOrEmpty(total.ToString()))
                    e.DisplayText = "0.00";
                else
                {
                    e.DisplayText = total.ToString("N");
                }
            }
        }
    }
}