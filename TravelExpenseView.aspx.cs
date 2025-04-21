using DevExpress.Web;
using DevExpress.Web.Data;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class TravelExpenseView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        DataSet ds = null;
        DataSet dsDoc = null;

        void ApplyStylesToGrid(dynamic grid, string colorCode)
        {
            var color = ColorTranslator.FromHtml(colorCode);
            grid.StylesPager.CurrentPageNumber.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.DropDownButtonStyle.HoverStyle.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.ItemStyle.SelectedStyle.BackColor = color;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    string colorCode = "#06838";
                    ApplyStylesToGrid(CAGrid, colorCode);
                    ApplyStylesToGrid(ExpenseGrid, colorCode);
                    ApplyStylesToGrid(DocumentGrid, colorCode);
                    ApplyStylesToGrid(WFSequenceGrid, colorCode);
                    ApplyStylesToGrid(FAPWFGrid, colorCode);
                    ApplyStylesToGrid(TraDocuGrid, colorCode);
                    ApplyStylesToGrid(ASPxGridView22, colorCode);

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();
                    var status = "";
                    Session["statusid"] = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").Select(x => x.STS_Id).FirstOrDefault();
                    Session["appdoctype"] = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault();

                    if (mainExp != null)
                    {
                        Session["isForeignTravel"] = mainExp.ForeignDomestic == "Foreign" ? 1 : 0;
                        Session["ford"] = mainExp.ForeignDomestic;
                        Session["currency"] = mainExp.ForeignDomestic == "Domestic" ? '₱' : mainExp.ForeignDomestic == "Foreign" ? '$' : ' ';
                        status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault();

                        ExpenseEditForm.Items[0].Caption = status != null ? "Travel Expense Document No.: " + mainExp.Doc_No + " (" + status + ")" : "Travel Expense Document No.: " + mainExp.Doc_No;

                        var chargedComp = Convert.ToString(_DataContext.CompanyMasters.Where(x => x.WASSId == mainExp.ChargedToComp).Select(x => x.CompanyShortName).FirstOrDefault());
                        var chargedDept = Convert.ToString(_DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == mainExp.ChargedToDept).Select(x => x.DepCode).FirstOrDefault());

                        if (!string.IsNullOrEmpty(chargedComp) && !string.IsNullOrEmpty(chargedDept))
                            chargedCB.Text = chargedComp + " - " + chargedDept;
                        else if (!string.IsNullOrEmpty(chargedComp) && string.IsNullOrEmpty(chargedDept))
                            chargedCB.Text = chargedComp;
                        else if (string.IsNullOrEmpty(chargedComp) && !string.IsNullOrEmpty(chargedDept))
                            chargedCB.Text = chargedDept;

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

                    if (status != null)
                    {
                        if (status == "Saved" || status.Contains("Returned"))
                        {
                            editButton.Visible = true;
                            printButton.Visible = false;
                        }
                        else if (status == "Approved" || status.Contains("Approved"))
                        {
                            printButton.Visible = true;
                            printItem.VisibleIndex = 1;
                            editItem.VisibleIndex = 0;
                            editButton.Visible = false;
                        }
                        else
                        {
                            printButton.Visible = false;
                            editButton.Visible = false;
                        }
                    }
                    else
                    {
                        editButton.Visible = true;
                        printButton.Visible = false;
                    }
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
                var remItem = ExpenseEditForm.FindItemOrGroupByName("remItem") as LayoutItem;

                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.isTravel == true && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reimDetails.ClientVisible = true;
                    reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                }

                var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                var userId = Convert.ToString(Session["userID"]);

                var totalca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true)
                    .Sum(x => (decimal?)x.Amount) ?? 0;

                var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Where(x => x.TravelExpenseMain_ID == travelExpId)
                    .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                var countCA = _DataContext.ACCEDE_T_RFPMains
                    .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true);

                var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Count(x => x.TravelExpenseMain_ID == travelExpId);

                var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                if (totalexp > totalca)
                {
                    remItem.ClientVisible = false;
                    due_lbl.Caption = "Due To Employee";
                    if (reim != null)
                        reimDetails.ClientVisible = true;
                    else
                        reimDetails.ClientVisible = false;
                }
                else if (totalca > totalexp)
                {
                    due_lbl.Caption = "Due To Company";
                    reimDetails.ClientVisible = false;
                    remItem.ClientVisible = true;
                }
                else
                {
                    due_lbl.Caption = "Due To Company";
                    reimDetails.ClientVisible = false;
                    remItem.ClientVisible = false;
                }

                departmentCB.Value = expType;
                lbl_caTotal.Text = Convert.ToString(Session["currency"]) + totalca.ToString("N2");
                lbl_expenseTotal.Text = Convert.ToString(Session["currency"]) + totalexp.ToString("N2");
                lbl_dueTotal.Text = totalexp > totalca ? "(" + Convert.ToString(Session["currency"]) + "" + (totalexp - totalca).ToString("N2") + ")" : Convert.ToString(Session["currency"]) + (totalca - totalexp).ToString("N2");

                var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                if (mainExp != null)
                {
                    Session["mainwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.Company_Id && x.IsRA == true && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault());
                    SqlWF.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();

                    if (Convert.ToString(Session["ford"]) == "Foreign")
                    {
                        Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.ChargedToComp && x.Description.Contains("Travel Foreign FAP>Manager>VP>CFO/PRES") && (x.IsRA == false || x.IsRA == null)).Select(x => x.WF_Id).FirstOrDefault());
                    }
                    else
                    {
                        Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.ChargedToComp && x.Description.Contains("Travel Domestic FAP>Manager>VP") && (x.IsRA == false || x.IsRA == null)).Select(x => x.WF_Id).FirstOrDefault());
                    }

                    SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                }

                //SqlWF.SelectParameters["UserId"].DefaultValue = mainExp.Employee_Id.ToString();
                //SqlWF.SelectParameters["CompanyId"].DefaultValue = mainExp.Company_Id.ToString();
                //SqlWF.DataBind();

                //Session["mainwfid"] = Convert.ToString(_DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == mainExp.Employee_Id.ToString() && x.CompanyId == mainExp.Company_Id).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                //SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                //SqlWorkflowSequence.DataBind();

                //Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                //SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                //SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                //SqlFAPWF2.DataBind();
                //SqlFAPWF.DataBind();
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();

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
        public static object RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            TravelExpenseView exp = new TravelExpenseView();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public object RedirectToRFPDetails(string rfpDoc)
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
            TravelExpenseView exp = new TravelExpenseView();
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
                    CreateDataTable("TravelExpenseDetailMap_ID", "ReimTranspo_Type1", "ReimTranspo_Amount1", "ReimTranspo_Type2", "ReimTranspo_Amount2", "ReimTranspo_Type3", "ReimTranspo_Amount3", "FixedAllow_ForP", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount", "OtherBus_Type", "OtherBus_Specify", "OtherBus_Amount")
                    //CreateDataTable("ReimTranspo_ID", "ReimTranspo_Type", "ReimTranspo_Amount"),
                    //CreateDataTable("FixedAllow_ID", "FixedAllow_ForP", "FixedAllow_Amount"),
                    //CreateDataTable("MiscTravelExp_ID", "MiscTravelExp_Type", "MiscTravelExp_Amount", "MiscTravelExp_Specify"),
                    //CreateDataTable("OtherBusinessExp_ID", "OtherBusinessExp_Type", "OtherBusinessExp_Amount", "OtherBusinessExp_Specify"),
                    //CreateDataTable("Entertainment_ID", "Entertainment_Explain", "Entertainment_Amount"),
                    //CreateDataTable("BusinessMeal_ID", "BusinessMeal_Explain", "BusinessMeal_Amount")
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
            TraDocuGrid.DataSource = dsDoc.Tables[0];
            TraDocuGrid.DataBind();

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
                ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlExpDetailsMap));

                //ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlRTMap));
                //ds.Tables[1].Merge(GetDataTableFromSqlDataSource(SqlFAMap));
                //ds.Tables[2].Merge(GetDataTableFromSqlDataSource(SqlMTMap));
                //ds.Tables[3].Merge(GetDataTableFromSqlDataSource(SqlOBMap));
                //ds.Tables[4].Merge(GetDataTableFromSqlDataSource(SqlEMap));
                //ds.Tables[5].Merge(GetDataTableFromSqlDataSource(SqlBMMap));

                //dsDoc.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlDocs2));
            }

            // Bind the tables to the grids
            ASPxGridView22.DataSource = ds.Tables[0];
            ASPxGridView22.DataBind();

            TraDocuGrid.DataSource = SqlDocs2;
            TraDocuGrid.DataBind();

            //reimTranGrid.DataSource = ds.Tables[0];
            //fixedAllowGrid.DataSource = ds.Tables[1];
            //miscTravelGrid.DataSource = ds.Tables[2];
            //otherBusGrid.DataSource = ds.Tables[3];
            //entertainmentGrid.DataSource = ds.Tables[4];
            //busMealsGrid.DataSource = ds.Tables[5];
            //TraDocuGrid.DataSource = dsDoc.Tables[0];

            //// Data bind to refresh the grids
            //reimTranGrid.DataBind();
            //fixedAllowGrid.DataBind();
            //miscTravelGrid.DataBind();
            //otherBusGrid.DataBind();
            //entertainmentGrid.DataBind();
            //busMealsGrid.DataBind();
            //TraDocuGrid.DataBind();

            //reimTranGrid.JSProperties["cpSummary"] = reimTranGrid.GetTotalSummaryValue(reimTranGrid.TotalSummary["ReimTranspo_Amount"]);
            //fixedAllowGrid.JSProperties["cpSummary"] = fixedAllowGrid.GetTotalSummaryValue(fixedAllowGrid.TotalSummary["FixedAllow_Amount"]);
            //miscTravelGrid.JSProperties["cpSummary"] = miscTravelGrid.GetTotalSummaryValue(miscTravelGrid.TotalSummary["MiscTravelExp_Amount"]);
            //otherBusGrid.JSProperties["cpSummary"] = otherBusGrid.GetTotalSummaryValue(otherBusGrid.TotalSummary["OtherBusinessExp_Amount"]);
            //entertainmentGrid.JSProperties["cpSummary"] = entertainmentGrid.GetTotalSummaryValue(entertainmentGrid.TotalSummary["Entertainment_Amount"]);
            //busMealsGrid.JSProperties["cpSummary"] = busMealsGrid.GetTotalSummaryValue(busMealsGrid.TotalSummary["BusinessMeal_Amount"]);
        }

        protected void ExpenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Fixed Allowances")
            {
                var amount = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.FixedAllow_Amount));

                if (amount.ToString() == "0.00" || string.IsNullOrEmpty(amount.ToString()))
                    e.DisplayText = "0.00";
                else
                {
                    e.DisplayText = amount.ToString("N");
                }
            }

            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            {
                var travelExpenseDetailId = Convert.ToInt32(e.Value);
                var total = _DataContext.ACCEDE_T_TravelExpenseDetailsMaps
                    .Where(or => or.TravelExpenseDetail_ID == travelExpenseDetailId)
                    .Sum(or =>
                        (or.ReimTranspo_Amount1 ?? 0) +
                        (or.ReimTranspo_Amount2 ?? 0) +
                        (or.ReimTranspo_Amount3 ?? 0) +
                        (or.MiscTravel_Amount ?? 0) +
                        (or.Entertainment_Amount ?? 0) +
                        (or.BusMeals_Amount ?? 0) +
                        (or.OtherBus_Amount ?? 0)
                    );

                e.DisplayText = total == 0 ? "0.00" : total.ToString("N");
            }

            //if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            //{
            //    var amount1 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.ReimTranspo_Amount1) ?? 0);
            //    var amount2 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.ReimTranspo_Amount2) ?? 0);
            //    var amount3 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.ReimTranspo_Amount3) ?? 0);
            //    var amount4 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.FixedAllow_Amount) ?? 0);
            //    var amount5 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.MiscTravel_Amount) ?? 0);
            //    var amount6 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.Entertainment_Amount) ?? 0);
            //    var amount7 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.BusMeals_Amount) ?? 0);
            //    var amount8 = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.OtherBus_Amount) ?? 0);

            //    var total = Convert.ToDecimal(amount1 + amount2 + amount3 + amount4 + amount5 + amount6 + amount7 + amount8);

            //    if (total.ToString() == "0.00" || string.IsNullOrEmpty(total.ToString()))
            //        e.DisplayText = "0.00";
            //    else
            //    {
            //        e.DisplayText = total.ToString("N");
            //    }
            //}
        }

        protected void ASPxGridView22_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "ReimTranspo_Amount1" || e.Column.FieldName == "ReimTranspo_Amount2" || e.Column.FieldName == "ReimTranspo_Amount3" || e.Column.FieldName == "FixedAllow_Amount" || e.Column.FieldName == "MiscTravel_Amount" || e.Column.FieldName == "Entertainment_Amount" || e.Column.FieldName == "BusMeals_Amount" || e.Column.FieldName == "OtherBus_Amount")
            {
                if (Convert.ToString(e.Value) == "0" || Convert.ToString(e.Value) == "0.00")
                    e.DisplayText = string.Empty;
            }
        }
    }
}