using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using DevExpress.Web.ASPxHtmlEditor.Internal;
using DevExpress.Web.Bootstrap;
using DevExpress.Web.Internal.XmlProcessor;
using DevExpress.Xpo;
using DevExpress.XtraCharts;
using DevExpress.XtraReports.Design.ParameterEditor;
using DevExpress.XtraRichEdit.Fields;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Security.Cryptography;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportEdit1 : System.Web.UI.Page
    {
        string ITPORTALcon = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                    var EmpCode = Session["userID"].ToString();

                    var mainExp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                    sqlExpenseCA.SelectParameters["Exp_ID"].DefaultValue = mainExp.ID.ToString();
                    SqlRFPMainReim.SelectParameters["Exp_ID"].DefaultValue = mainExp.ID.ToString();
                    SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = mainExp.ID.ToString();
                    SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = mainExp.ID.ToString();
                    SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : null;

                    SqlCompany.SelectParameters["UserId"].DefaultValue = mainExp.ExpenseName.ToString();
                    SqlCostCenterAll.SelectParameters["CompanyId"].DefaultValue = mainExp.ExpChargedTo_CompanyId.ToString();
                    sqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = mainExp.ExpChargedTo_DeptId.ToString();

                    SqlDepartment.SelectParameters["UserId"].DefaultValue = mainExp.ExpenseName.ToString();
                    //sqlCostCenter.SelectParameters["CompanyId"].DefaultValue = mainExp.CompanyId.ToString();
                    SqlRFPMainReim.SelectParameters["Exp_ID"].DefaultValue = Session["ExpenseId"].ToString();
                    sqlDept.SelectParameters["CompanyId"].DefaultValue = mainExp.CompanyId.ToString();
                    sqlDept.SelectParameters["UserId"].DefaultValue = mainExp.ExpenseName.ToString();
                    SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = mainExp.ExpChargedTo_CompanyId.ToString();

                    SqlUser.SelectParameters["Company_ID"].DefaultValue = mainExp.ExpChargedTo_CompanyId.ToString();
                    SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = mainExp.ExpenseName.ToString();
                    SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                    SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();

                    SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = EmpCode;

                    // Get the existing data from SqlDataSource
                    DataView dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;

                    if (dv != null)
                    {
                        // Convert DataView to DataTable to modify it
                        DataTable dt = dv.ToTable();

                        // Add a new row manually
                        DataRow newRow = dt.NewRow();
                        newRow["DelegateFor_UserID"] = EmpCode;
                        newRow["FullName"] = Session["userFullName"].ToString();
                        dt.Rows.Add(newRow);

                        // Rebind the ComboBox with the updated list
                        exp_EmpId.DataSource = dt;
                        exp_EmpId.TextField = "FullName";   // Ensure text field is set correctly
                        exp_EmpId.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly
                        exp_EmpId.DataBind();
                    }


                    //if (exp_EmpId.Items.Count() > 0)
                    //{
                    //    exp_EmpId.Value = Session["userID"].ToString();
                    //    exp_EmpId.DataBind();
                    //}
                    //else
                    //{
                    //    exp_EmpId.DataSourceID = null;
                    //    exp_EmpId.DataSource = SqlUserSelf;
                    //    exp_EmpId.ValueField = "EmpCode";

                    //    exp_EmpId.DataBind();
                    //    exp_EmpId.SelectedIndex = 0;
                    //}

                    var pay_released = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").FirstOrDefault();
                    sqlRFPMainCA.SelectParameters["User_ID"].DefaultValue = mainExp.ExpenseName.ToString();
                    sqlRFPMainCA.SelectParameters["Status"].DefaultValue = pay_released.STS_Id.ToString();

                    var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == mainExp.ID).Where(x=>x.IsExpenseCA == true);
                    var totalCA = new decimal (0.00);
                    foreach(var item in rfpCA)
                    {
                        totalCA += Convert.ToDecimal(item.Amount);
                        
                    }
                    //if (totalCA >= 0)
                    //{
                    //    drpdown_expenseType.Text = "Liquidation";
                    //}
                    //else
                    //{
                    //    drpdown_expenseType.Text = "Reimbursement";
                    //}
                    lbl_caTotal.Text = totalCA.ToString("#,##0.00") + "  "+ mainExp.Exp_Currency;

                    var expDetail = _DataContext.ACCEDE_T_ExpenseDetails.Where(x=>x.ExpenseMain_ID == mainExp.ID);
                    var totalExp = new decimal (0.00);
                    foreach(var item in expDetail)
                    {
                        totalExp += Convert.ToDecimal(item.GrossAmount);
                    }
                    lbl_expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + mainExp.Exp_Currency;

                    var totalDue = new decimal(0.00);
                    totalDue = totalCA - totalExp;
                    var reimRFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.IsExpenseReim == true).Where(x=>x.Status != 4).Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]));

                    if (totalDue < 0)
                    {
                        lbl_dueTotal.Text = Math.Abs(totalDue).ToString("(#,##0.00)") + "  " + mainExp.Exp_Currency;
                        if (reimRFP.Count() == 0)
                        {
                            var reim = ExpenseEditForm.FindItemOrGroupByName("reimItem") as LayoutItem;
                            var pay_type = ExpenseEditForm.FindItemOrGroupByName("PayType") as LayoutItem;
                            if (reim != null)
                            {
                                reim.ClientVisible = true;
                                ReimburseGrid.Visible = false;
                                errImg.Visible = true;
                            }

                            if (pay_type != null)
                            {
                                pay_type.ClientVisible = true;
                                
                            }

                            if (mainExp.PaymentType != null && mainExp.PaymentType != 0)
                            {
                                drpdown_payType.Value = mainExp.PaymentType.ToString();
                            }
                            else
                            {
                                drpdown_payType.SelectedIndex = 0;
                            }
                        }
                        else
                        {
                            var reim = ExpenseEditForm.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                            if (reim != null)
                            {
                                reim.ClientVisible = true;
                                link_rfp.Value = reimRFP.First().RFP_DocNum;
                            }
                        }
                        var dueField = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Employee";
                    }
                    else
                    {
                        lbl_dueTotal.Text = totalDue.ToString("#,##0.00") + "  " + mainExp.Exp_Currency;
                        var dueField = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Company";

                        if(totalDue > 0)
                        {
                            var AR_Reference = ExpenseEditForm.FindItemOrGroupByName("ARNo") as LayoutItem;
                            AR_Reference.ClientVisible = true;
                        }

                        if (reimRFP.Count() != 0)
                        {
                            foreach (var reim in reimRFP)
                            {
                                var test = reim.ID;
                                reim.Status = 4;
                            }
                        }
                        _DataContext.SubmitChanges();
                    }
                    //// - - SET WORKFLOWS - - ////
                    //// - - Setting FAP workflow - - ////

                    if (!IsPostBack)
                    {
                        var classTypeId = mainExp.ExpenseClassification;
                        var classType = _DataContext.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(classTypeId)).FirstOrDefault();
                        var fapwf_id = 0;

                        if (classType != null && Convert.ToBoolean(classType.withFAPLogic) == true)
                        {
                            var fapwf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(mainExp.CompanyId))
                            .Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == true)
                            .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
                            .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
                            .Where(x => x.IsRA == null || x.IsRA == false)
                            .FirstOrDefault();

                            if (fapwf != null)
                            {
                                fapwf_id = fapwf.WF_Id;
                            }
                        }
                        else
                        {
                            var fapwf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(mainExp.CompanyId))
                            .Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                            .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
                            .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
                            .Where(x => x.IsRA == null || x.IsRA == false)
                            .FirstOrDefault();

                            if (fapwf != null)
                            {
                                fapwf_id = fapwf.WF_Id;
                            }

                        }

                        if (fapwf_id != 0)
                        {
                            drpdwn_FAPWF.SelectedIndex = 0;
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();

                            //FAPWFGrid.DataSourceID = null;
                            //FAPWFGrid.DataSource = SqlFAPWF;
                            //FAPWFGrid.DataBind();

                        }

                        //// - - Setting RA Workflow - - ////

                        var depcode = _DataContext.ITP_S_OrgDepartmentMasters
                            .Where(x => x.ID == Convert.ToInt32(mainExp.Dept_Id))
                            .FirstOrDefault();

                        // Fetch data using the stored procedure
                        DataTable rawf = GetWorkflowHeadersByExpenseAndDepartment(mainExp.ExpenseName.ToString(), Convert.ToInt32(mainExp.CompanyId), totalExp, depcode != null ? depcode.DepCode : "0", 1032);

                        if (rawf != null && rawf.Rows.Count > 0)
                        {
                            // Get the first row's WF_Id value
                            DataRow firstRow = rawf.Rows[0];
                            int wfId = Convert.ToInt32(firstRow["WF_Id"]);

                            // Set the dropdown to the first item (if applicable)
                            drpdown_WF.SelectedIndex = 0;

                            // Update the SQL data source parameters
                            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();
                            SqlWF.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();

                        }
                        else
                        {
                            // Handle the case when no data is returned
                            drpdown_WF.SelectedIndex = -1; // Optionally reset the dropdown
                            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = string.Empty;
                            SqlWF.SelectParameters["WF_Id"].DefaultValue = string.Empty;
                        }
                    }

                    

                    //// - - END SETTING WORKFLOW - - ////

                    Session["DocNo"] = mainExp.DocNo.ToString();
                    Session["ExpMain_ID"] = mainExp.ID;

                    var myLayoutGroup = ExpenseEditForm.FindItemOrGroupByName("EditFormName") as LayoutGroup;

                    if (mainExp != null)
                    {
                        myLayoutGroup.Caption = mainExp.DocNo + " (Edit)";
                    }

                    var payee = Session["userFullName"].ToString();
                    payee_reim.Text = payee;

                    //var expCat = _DataContext.ACDE_T_MasterCodes.Where(x=>x.ID == mainExp.ExpenseCat).FirstOrDefault();
                    //acctCharge_reim.Text = expCat.Description;

                    if (!IsPostBack || (Session["DataSetExpAlloc"] == null))
                    {
                        dsExpAlloc = new DataSet();
                        DataTable masterTable = new DataTable();
                        masterTable.Columns.Add("ID", typeof(int));
                        masterTable.Columns.Add("CostCenter", typeof(int));
                        masterTable.Columns.Add("NetAmount", typeof(decimal));
                        masterTable.Columns.Add("Remarks", typeof(string));
                        masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                        dsExpAlloc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                        Session["DataSetExpAlloc"] = dsExpAlloc;

                    }
                    else
                    {
                        dsExpAlloc = (DataSet)Session["DataSetExpAlloc"];
                        ExpAllocGrid.DataSource = dsExpAlloc.Tables[0];
                        ExpAllocGrid.DataBind();
                    }
                        

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
                    {
                        dsDoc = (DataSet)Session["DataSetDoc"];
                        DocuGrid.DataSource = dsDoc.Tables[0];
                        DocuGrid.DataBind();
                    }
                        
                }
                else
                    Response.Redirect("~/Logon.aspx");
            }
            catch (Exception ex)
            {
                if (!IsPostBack)
                {
                    Response.Redirect("~/Logon.aspx");
                }
                
            }
        }


        DataSet dsDoc = null;
        DataSet dsExpAlloc = null;
        private int GetNewId()
        {
            dsExpAlloc = (DataSet)Session["DataSetExpAlloc"];
            DataTable table = dsExpAlloc.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["ID"]);
            }
            return max + 1;
        }

        private int GetDocNewId()
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
                    docs.Doc_ID = Convert.ToInt32(Session["ExpenseId"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(exp_EmpId.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
            DocumentGrid.DataBind();
        }

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {

        }

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {

        }

        protected void WFSequenceGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF.Value != null ? drpdown_WF.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = e.Parameters != null ? e.Parameters.ToString() : "";
            SqlFAPWF.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWF;
            FAPWFGrid.DataBind();
        }

        protected void capopGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            capopGrid.DataBind();
        }

        [WebMethod]
        public static bool AddCA_AJAX(List<int> selectedValues)
        {
            try
            {
                AccedeExpenseReportEdit1 accede = new AccedeExpenseReportEdit1();
                bool result = accede.AddCA(selectedValues);
                return result;
            }
            catch (Exception ex)
            {
                // Log the error (ex.Message)
                return false;
            }
        }

        public bool AddCA(List<int> selectedIds)
        {
            try
            {
                var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                expMain.ExpenseType_ID = 1;

                foreach (var id in selectedIds)
                {
                    // INSERT TO ACCEDE_T_ExpenseCA
                    ACCEDE_T_ExpenseCA ca = new ACCEDE_T_ExpenseCA()
                    {
                        RFPMain_ID = id,
                        User_ID = Convert.ToInt32(Session["userID"]),
                        IsUploaded = false
                    };
                    _DataContext.ACCEDE_T_ExpenseCAs.InsertOnSubmit(ca);
                    _DataContext.SubmitChanges();

                    // UPDATE TO ACCEDE_T_RFPMain
                    var updateRFPMain = _DataContext.ACCEDE_T_RFPMains
                        .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && ex.ID == id);

                    foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                    {
                        ex.IsExpenseCA = true;
                        ex.Exp_ID = Convert.ToInt32(Session["ExpenseId"]);
                        ex.isTravel = false;

                        expMain.PaymentType = ex.PayMethod;
                    }
                    
                    _DataContext.SubmitChanges();
                }

                //caPopup.ShowOnPageLoad = false;
                //DocuGrid1.DataBind();
            }
            catch (Exception ex)
            {
                return false;
            }
            return true;
        }

        protected void CAGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            // Get the key value of the row being deleted
            var keyValue = e.Values["RFPMain_ID"];
            if (keyValue != null)
            {
                var updateRFP = _DataContext.ACCEDE_T_RFPMains
                     .Where(x => x.ID == Convert.ToInt32(keyValue));

                foreach (ACCEDE_T_RFPMain ex in updateRFP)
                {
                    //.IsExpenseCA = false;
                    ex.Exp_ID = null;
                }
                _DataContext.SubmitChanges();
            }
            else
            {
                Debug.WriteLine("Column value not found in e.Values[\"RFPMain_ID\"]");
            }

            //Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString();
            //CultureInfo cultureInfo = new CultureInfo("en-PH");
            //caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            // Prevent the automatic delete operation
            //e.Cancel = true;
        }

        [WebMethod]
        public static string AddExpDetailsAJAX(string dateAdd, string tin_no, string invoice_no, string cost_center,
            string gross_amount, string net_amount, string supp, string particu, string acctCharge, string vat_amnt, string ewt_amnt, string currency, string io, string wbs)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.AddExpDetails(dateAdd, tin_no, invoice_no, cost_center,
            gross_amount, net_amount, supp, particu, acctCharge, vat_amnt, ewt_amnt, currency, io, wbs);
        }

        public string AddExpDetails(string dateAdd, string tin_no, string invoice_no, string cost_center,
            string gross_amount, string net_amount, string supp, string particu, string acctCharge, string vat_amnt, string ewt_amnt, string currency, string io, string wbs)
        {
            try
            {
                
                decimal totalNetAmnt = new decimal(0.00);
                DataSet dsAlloc = (DataSet)Session["DataSetExpAlloc"];
                DataTable dataTableAlloc = dsAlloc.Tables[0];

                foreach (DataRow row in dataTableAlloc.Rows)
                {
                    ACCEDE_T_ExpenseDetailsMap map = new ACCEDE_T_ExpenseDetailsMap();
                    {
                        totalNetAmnt += Convert.ToDecimal(row["NetAmount"]);
                    }
                    

                }
                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if(totalNetAmnt < gross && dataTableAlloc.Rows.Count > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00")+" "+ currency + ". Please check the allocation amounts.";
                    return error;
                }else if(totalNetAmnt > gross && dataTableAlloc.Rows.Count > 0)
                {
                    string error = "Allocation Exceeded!";
                    return error;
                }
                else
                {
                    var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                    var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
                    //if (rfpCA.Count() > 0)
                    //{
                    //    expMain.ExpenseType_ID = 1;
                    //}
                    //else
                    //{
                    //    expMain.ExpenseType_ID = 2;
                    //}

                    ACCEDE_T_ExpenseDetail exp = new ACCEDE_T_ExpenseDetail();
                    {
                        exp.DateAdded = Convert.ToDateTime(dateAdd);
                        if (tin_no != "")
                        {
                            exp.TIN = tin_no;
                        }
                        if (invoice_no != "")
                        {
                            exp.InvoiceOR = invoice_no;
                        }
                        
                        exp.CostCenterIOWBS = cost_center;
                        exp.GrossAmount = Convert.ToDecimal(gross_amount);
                        exp.NetAmount = Convert.ToDecimal(net_amount);
                        if(supp != "")
                        {
                            exp.Supplier = supp;
                        }
                        
                        exp.Particulars = Convert.ToInt32(particu);
                        exp.AccountToCharged = acctCharge;
                        exp.VAT = Convert.ToDecimal(vat_amnt);
                        exp.EWT = Convert.ToDecimal(ewt_amnt);
                        exp.ExpenseMain_ID = Convert.ToInt32(Session["ExpenseId"]);
                        exp.Preparer_ID = Session["userID"].ToString();
                        exp.ExpDtl_Currency = currency;
                        if (io != "")
                        {
                            exp.ExpDtl_IO = io;
                        }

                        if (wbs != "")
                        {
                            exp.ExpDtl_WBS = wbs;
                        }
                    }
                    _DataContext.ACCEDE_T_ExpenseDetails.InsertOnSubmit(exp);
                    _DataContext.SubmitChanges();
                    var ExpDetail_ID = exp.ExpenseReportDetail_ID;

                    //Insert Expense Allocations
                    if (dataTableAlloc.Rows.Count > 0)
                    {
                        foreach (DataRow row in dataTableAlloc.Rows)
                        {
                            ACCEDE_T_ExpenseDetailsMap map = new ACCEDE_T_ExpenseDetailsMap();
                            {
                                map.CostCenterIOWBS = Convert.ToInt32(row["CostCenter"]);
                                map.NetAmount = Convert.ToDecimal(row["NetAmount"]);
                                map.ExpenseReportDetail_ID = ExpDetail_ID;
                                map.Preparer_ID = Session["userID"].ToString();
                                map.EDM_Remarks = row["Remarks"].ToString();
                            }

                            _DataContext.ACCEDE_T_ExpenseDetailsMaps.InsertOnSubmit(map);

                        }


                    }

                    _DataContext.SubmitChanges();

                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                    //Insert Invoice Attachments
                    DataSet dsFile = (DataSet)Session["DataSetDoc"];
                    DataTable dataTable = dsFile.Tables[0];

                    ITP_T_FileAttachment attach = new ITP_T_FileAttachment();
                    ACCEDE_T_ExpenseDetailFileAttach attachMap = new ACCEDE_T_ExpenseDetailFileAttach();

                    if (dataTable.Rows.Count > 0)
                    {
                        foreach (DataRow row in dataTable.Rows)
                        {
                            attach.FileName= row["FileName"].ToString();
                            attach.FileAttachment = (byte[])row["FileByte"];
                            attach.Description = row["FileDesc"].ToString();
                            attach.DateUploaded = DateTime.Now;
                            attach.App_ID = 1032;
                            attach.User_ID = Session["userID"] != null ? Session["userID"].ToString() : "0";
                            attach.FileExtension = row["FileExt"].ToString();
                            attach.FileSize = row["FileSize"].ToString();
                            attach.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;

                            _DataContext.ITP_T_FileAttachments.InsertOnSubmit(attach);
                            _DataContext.SubmitChanges();

                            attachMap.ExpDetail_Id = ExpDetail_ID;
                            attachMap.FileAttach_Id = attach.ID;

                            _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.InsertOnSubmit(attachMap);
                            _DataContext.SubmitChanges();
                        }

                    }
                    //Done inserting Invoice attachments

                    var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                    var expDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));

                    decimal totalReim = new decimal(0);
                    decimal totalCA = new decimal(0);
                    decimal totalExpense = new decimal(0);

                    foreach (var ca in rfpCA)
                    {
                        totalCA += Convert.ToDecimal(ca.Amount);
                    }

                    foreach (var expDtl in expDetails)
                    {
                        totalExpense += Convert.ToDecimal(expDtl.NetAmount);
                    }

                    totalReim = totalCA - totalExpense;
                    if (totalReim < 0)
                    {
                        if (rfpReim != null)
                        {
                            rfpReim.Amount = Math.Abs(totalReim);
                        }
                    }
                    else
                    {
                        if (rfpReim != null)
                        {
                            rfpReim.Status = 4;
                        }

                    }
                }

                
                _DataContext.SubmitChanges();
                return "success";
            }catch (Exception ex)
            {
                return ex.Message;
            }
        }

        protected void drpdwn_FAPWF_Callback(object sender, CallbackEventArgsBase e)
        {
            var mainExp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();

            var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == mainExp.ID).Where(x => x.IsExpenseCA == true);
            var totalCA = new decimal(0.00);
            foreach (var item in rfpCA)
            {
                totalCA += Convert.ToDecimal(item.Amount);

            }
            //if (totalCA >= 0)
            //{
            //    drpdown_expenseType.Text = "Liquidation";
            //}
            //else
            //{
            //    drpdown_expenseType.Text = "Reimbursement";
            //}

            var expDetail = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == mainExp.ID);
            var totalExp = new decimal(0.00);
            foreach (var item in expDetail)
            {
                totalExp += Convert.ToDecimal(item.GrossAmount);
            }

            var totalDue = new decimal(0.00);
            totalDue = totalCA - totalExp;

            //// - - Setting FAP workflow - - ////
            var classTypeId = drpdown_classification.Value != null ? drpdown_classification.Value : 0;
            var classType = _DataContext.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(classTypeId)).FirstOrDefault();
            var fapwf_id = 0;

            if (classType != null && Convert.ToBoolean(classType.withFAPLogic) == true)
            {
                var fapwf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(mainExp.CompanyId))
                .Where(x => x.App_Id == 1032)
                .Where(x => x.With_DivHead == true)
                .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
                .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
                .Where(x => x.IsRA == null || x.IsRA == false)
                .FirstOrDefault();

                if (fapwf != null)
                {
                    fapwf_id = fapwf.WF_Id;
                }
            }
            else
            {
                var fapwf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(mainExp.CompanyId))
                .Where(x => x.App_Id == 1032)
                .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
                .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
                .Where(x => x.IsRA == null || x.IsRA == false)
                .FirstOrDefault();

                if (fapwf != null)
                {
                    fapwf_id = fapwf.WF_Id;
                }

            }

            if (fapwf_id != 0)
            {
                
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();
                drpdwn_FAPWF.SelectedIndex = 0;
                drpdwn_FAPWF.DataBind();

                SqlFAPWF.DataBind();
                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();
            }
        }

        [WebMethod]
        public static bool RemoveFromExp_AJAX(int item_id, string btnCommand)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();

            return exp.RemoveFromExp(item_id, btnCommand);
        }

        public bool RemoveFromExp(int item_id, string btnCommand)
        {
            try
            {
                if(btnCommand == "btnRemoveCA")
                {
                    var CA_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x=>x.ID == item_id).FirstOrDefault();
                    CA_RFP.Exp_ID = null;
                    var rfpReim_upd = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                    if(rfpReim_upd != null)
                    {
                        rfpReim_upd.Amount = Convert.ToDecimal(rfpReim_upd.Amount) + Convert.ToDecimal(CA_RFP.Amount);
                    }
                }

                if (btnCommand == "btnRemoveExp")
                {
                    var exp_det = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseReportDetail_ID == item_id).FirstOrDefault();
                    var exp_det_map = _DataContext.ACCEDE_T_ExpenseDetailsMaps.Where(x => x.ExpenseReportDetail_ID == item_id);
                    _DataContext.ACCEDE_T_ExpenseDetails.DeleteOnSubmit(exp_det);
                    _DataContext.ACCEDE_T_ExpenseDetailsMaps.DeleteAllOnSubmit(exp_det_map);
                    _DataContext.SubmitChanges();

                    var Reim_RFP_exp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x=>x.IsExpenseReim == true).FirstOrDefault();

                    var updated_exp_det = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                    if(updated_exp_det == null)
                    {
                        if(Reim_RFP_exp != null)
                        {
                            var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Reim_RFP_exp.ID).FirstOrDefault();
                            //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                            Reim_RFP.Status = 4;
                        }
                    }
                    else
                    {
                        var rfp_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
                        var totalCA = new decimal(0.00);
                        foreach (var item in rfp_CA)
                        {
                            totalCA += Convert.ToDecimal(item.Amount);

                        }

                        var expDetail = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));
                        var totalExp = new decimal(0.00);
                        foreach (var item in expDetail)
                        {
                            totalExp += Convert.ToDecimal(item.GrossAmount);
                        }

                        decimal totalDue = new decimal(0);
                        totalDue = totalCA - totalExp;

                        if(totalDue >= 0)
                        {
                            if (Reim_RFP_exp != null)
                            {
                                var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Reim_RFP_exp.ID).FirstOrDefault();
                                //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                                Reim_RFP.Status = 4;
                            }
                            
                        }
                        if (Reim_RFP_exp != null)
                        {
                            Reim_RFP_exp.Amount = Math.Abs(totalCA - totalExp);
                        }
                    }
                }

                if (btnCommand == "btnRemoveReim")
                {
                    var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == item_id).FirstOrDefault();
                    //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                    Reim_RFP.Status = 4;
                }

                var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true).Where(x => x.Status == 7);
                if (rfpCA.Count() > 0)
                {
                    expMain.ExpenseType_ID = 1;
                }
                else
                {
                    expMain.ExpenseType_ID = 2;
                }

                _DataContext.SubmitChanges();

                return true;
            }catch (Exception ex)
            {
                return false;
            }
        }


        protected void costCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            sqlCostCenter.SelectParameters["CompanyId"].DefaultValue = exp_EmpId.Value.ToString();
            sqlCostCenter.DataBind();

        }

        protected void dept_reim_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlDepartment.SelectParameters["CompanyId"].DefaultValue = exp_EmpId.Value.ToString();
            SqlDepartment.DataBind();

            dept_reim.DataSourceID = null;
            dept_reim.DataSource = SqlDepartment;
            dept_reim.DataBind();
        }

        [WebMethod]
        public static string CostCenterUpdateField(string dept_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            var cc = rfp.GetCostCenter(dept_id);
            return cc;
        }

        [WebMethod]
        public static bool AddRFPReimburseAJAX(string comp_id, string payMethod, string purpose, string dept_id, string cCenter,
            string io, string payee, string acctCharge, string amount, string remarks, bool isTravelrfp, string wbs, string currency, string classification, string CTComp_id, string CTDept_id)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();

            return exp.AddRFPReimburse(comp_id, payMethod, purpose, dept_id, cCenter,
            io, payee, acctCharge, amount, remarks, isTravelrfp, wbs, currency, classification, CTComp_id, CTDept_id);
        }

        public bool AddRFPReimburse(string comp_id, string payMethod, string purpose, string dept_id, string cCenter,
            string io, string payee, string acctCharge, string amount, string remarks, bool isTravelrfp, string wbs, string currency, string classification, string CTComp_id, string CTDept_id)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(comp_id), 1032);
                var docNum = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(comp_id), 1032);

                var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x=>x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();

                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
                var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                var expDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));

                decimal totalReim = new decimal(0);
                decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                foreach (var ca in rfpCA)
                {
                    totalCA += Convert.ToDecimal(ca.Amount);
                }

                foreach (var exp in expDetails)
                {
                    totalExpense += Convert.ToDecimal(exp.NetAmount);
                }

                totalReim = totalCA - totalExpense;

                if(rfpReim == null)
                {
                    ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain();
                    {
                        rfp.Company_ID = Convert.ToInt32(comp_id);
                        rfp.PayMethod = Convert.ToInt32(payMethod);
                        rfp.Purpose = purpose;
                        rfp.Department_ID = Convert.ToInt32(dept_id);
                        rfp.SAPCostCenter = cCenter;
                        if (io != "")
                        {
                            rfp.IO_Num = io;
                        }
                        rfp.Payee = payee;
                        rfp.AcctCharged = Convert.ToInt32(acctCharge);
                        rfp.Amount = Convert.ToDecimal(Math.Abs(totalReim));
                        if (remarks != "")
                        {
                            rfp.Remarks = remarks;
                        }
                        rfp.Exp_ID = expMain.ID;
                        rfp.TranType = 2;
                        rfp.IsExpenseReim = true;
                        rfp.isTravel = false;//isTravelrfp;
                        rfp.DateCreated = DateTime.Now;
                        rfp.RFP_DocNum = docNum.ToString();
                        if (wbs != "")
                        {
                            rfp.WBS = wbs;
                        }
                        rfp.User_ID = Session["userID"].ToString();
                        rfp.Currency = currency;
                        rfp.Status = expMain.Status;
                        rfp.Classification_Type_Id = Convert.ToInt32(classification);
                        rfp.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        rfp.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);

                    }

                    _DataContext.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                }

                expMain.PaymentType = Convert.ToInt32(payMethod);
                
                _DataContext.SubmitChanges();

                return true;
            }catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static string UpdateExpenseAJAX(string dateFile, string repName, string comp_id, string expType, string expCat,
            string purpose, bool trav, string wf, string fapwf, string currency, string department, string payType, string btn, string classification, string costCenter, string CTCompany_id, string CTDept_id, string AR)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.UpdateExpense(dateFile, repName, comp_id, expType, expCat,purpose, trav, wf, fapwf, currency, department, payType, btn, classification, costCenter, CTCompany_id, CTDept_id, AR);
        }

        public string UpdateExpense(string dateFile, string repName, string comp_id, string expType, string expCat,
            string purpose, bool trav, string wf, string fapwf, string currency, string department, string payType, string btn, string classification, string costCenter, string CTCompany_id, string CTDept_id, string AR)
        {
            try
            {
                var exp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == exp.ID).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                var expCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x=>x.IsExpenseCA == true).FirstOrDefault();
                if (expType == "1")
                {
                    if(expCA == null && btn != "Save" && btn != "Save2")
                    {
                        return "require CA";
                    }
                }
                else
                {
                    if (expCA != null)
                    {
                        return "This transaction should be a Liquidation since you attached a Cash Advance.";
                    }
                }

                if(expCA == null && reim == null && btn != "Save" && btn != "Save2")
                {
                    return "This transaction cannot be submitted. Please check your Cash Advance, Expense Items, or Reimbursement.";
                }

                var tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x=>x.ExpenseType_ID == Convert.ToInt32(expType)).FirstOrDefault();
                
                exp.ReportDate = Convert.ToDateTime(dateFile);
                exp.ExpenseName = repName;
                exp.CompanyId = Convert.ToInt32(comp_id);
                exp.ExpenseType_ID = Convert.ToInt32(tranType.ExpenseType_ID);
                exp.ExpenseCat = Convert.ToInt32(expCat);
                exp.Purpose = purpose;
                exp.isTravel = trav;
                exp.WF_Id = Convert.ToInt32(wf);
                exp.FAPWF_Id = Convert.ToInt32(fapwf);
                //exp.remarks = remarks;
                exp.Exp_Currency = currency;
                exp.Dept_Id = Convert.ToInt32(department);
                exp.ExpenseClassification = Convert.ToInt32(classification);
                exp.CostCenter = costCenter;
                exp.ExpChargedTo_CompanyId = Convert.ToInt32(CTCompany_id);
                exp.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                exp.PaymentType = Convert.ToInt32(payType);
                if(payType != null)
                {
                    exp.PaymentType = Convert.ToInt32(payType);
                }

                if(AR != "")
                {
                    exp.AR_Reference_No = AR;
                }

                //Update reimbursement Workflows
                
                if (reim != null)
                {
                    reim.WF_Id = Convert.ToInt32(wf);
                    reim.FAPWF_Id = Convert.ToInt32(fapwf);
                    reim.Status = 13;
                    reim.Currency = currency;
                }

                if (btn == "Submit" || btn == "CreateSubmit")
                {
                    var returnAuditStats = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();
                    var returnP2PStats = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Returned by P2P").FirstOrDefault();

                    if( exp.Status == returnAuditStats.STS_Id)
                    {
                        var pendingAuditStats = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                        exp.Status = pendingAuditStats.STS_Id;
                        if (reim != null)
                        {
                            reim.Status = pendingAuditStats.STS_Id;
                        }
                        
                    }
                    else if(exp.Status == returnP2PStats.STS_Id)
                    {
                        var pendingP2PStats = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at P2P").FirstOrDefault();
                        exp.Status = pendingP2PStats.STS_Id;
                        if(reim != null)
                        {
                            reim.Status = pendingP2PStats.STS_Id;
                        }
                        
                    }
                    else
                    {
                        int wfID = Convert.ToInt32(wf);

                        // GET WORKFLOW DETAILS ID
                        var wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                        where wfd.WF_Id == wfID && wfd.Sequence == 1
                                        select wfd.WFD_Id;
                        int wfdID = wfDetails.FirstOrDefault();

                        // GET ORG ROLE ID
                        var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                      where or.WF_Id == wfID && or.Sequence == 1
                                      select or.OrgRole_Id;
                        int orID = (int)orgRole.FirstOrDefault();

                        //Add reim to workflow activity
                        if (reim != null)
                        {
                            //change reimbursement status to pending
                            reim.Status = 1;

                            ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                            {
                                Status = 1,
                                DateAssigned = DateTime.Now,
                                DateAction = null,
                                WF_Id = wfID,
                                WFD_Id = wfdID,
                                OrgRole_Id = orID,
                                Document_Id = Convert.ToInt32(reim.ID),
                                AppId = 1032,
                                CompanyId = Convert.ToInt32(comp_id),
                                AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                                IsActive = true,
                            };
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);

                        }

                        //change expense rep status to pending
                        exp.Status = 1;

                        //INSERT EXPENSE TO ITP_T_WorkflowActivity
                        DateTime currentDate = DateTime.Now;

                        ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                        {
                            Status = 1,
                            DateAssigned = currentDate,
                            DateAction = null,
                            WF_Id = wfID,
                            WFD_Id = wfdID,
                            OrgRole_Id = orID,
                            Document_Id = Convert.ToInt32(Session["ExpenseId"]),
                            AppId = 1032,
                            CompanyId = Convert.ToInt32(comp_id),
                            AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                            IsActive = true,
                        };
                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                        _DataContext.SubmitChanges();

                        //InsertAttachment(Convert.ToInt32(Session["ExpenseId"]));
                        SendEmail(Convert.ToInt32(wfa.Document_Id), orID, Convert.ToInt32(comp_id), 1);
                    }
                    
                }

                _DataContext.SubmitChanges();
                
                return "success";
            }catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static decimal CheckMinAmountAJAX(int comp_id, int payMethod)
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.CheckMinAmount(comp_id, payMethod);
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID)
        {
            DateTime currentDate = DateTime.Now;

            var status = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Description)
                .FirstOrDefault();

            ///////---START EMAIL PROCESS-----////////
            var user_userID = _DataContext.ITP_S_SecurityUserOrgRoles
                .Where(um => um.OrgRoleId == org_id)
                .Select(um => um.UserId)
                .FirstOrDefault();
            var user_email = _DataContext.ITP_S_UserMasters
                .Where(x => x.EmpCode == user_userID)
                .FirstOrDefault();
            var comp_name = _DataContext.CompanyMasters
                .Where(x => x.WASSId == comps_id)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == "Pending"
                            select texts;

            var emailMessage = "";
            var emailSubMessage = "";
            var emailColor = "";

            foreach (var text in queryText)
            {
                emailMessage = text.Text1.ToString();
                emailSubMessage = text.Text2.ToString();
                emailColor = text.Color.ToString();
            }
            //End--     Get Text info

            var requestor_fullname = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.Email)
                .FirstOrDefault();

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/AccedeApprovalPage.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + doc_id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_ExpenseDetails
                          where er.ExpenseMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Particulars</th><th>Supplier</th><th>Net Amount</th><th>Date Created</th></tr>";

            foreach (var item in queryER)
            {
                var exp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.Particulars + "</td>" +
                            "<td style='text-align: center;'>" + item.Supplier + "</td>" +
                            "<td style='text-align: center;'>" + item.NetAmount + "</td>" +
                            "<td style='text-align: center;'>" + item.DateAdded.Value.ToLongDateString() + "</td>" +
                            "</tr>";
            }
            emailDetails += "</table>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            };
        }

        protected void ExpAllocGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            decimal totalNetAmount = 0;

            ASPxGridView grid = (ASPxGridView)sender;

            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");
                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            totalNetAmount = Convert.ToDecimal(e.NewValues["NetAmount"]) + totalNetAmount;

            if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            {
                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;

                e.Cancel = true;
            }
            else
            {
                dsExpAlloc = (DataSet)Session["DataSetExpAlloc"];
                ASPxGridView gridView = (ASPxGridView)sender;
                DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsExpAlloc.Tables[1] : dsExpAlloc.Tables[0];
                DataRow row = dataTable.NewRow();
                e.NewValues["ID"] = GetNewId();

                IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
                enumerator.Reset();
                while (enumerator.MoveNext())
                    if (enumerator.Key.ToString() != "Count")
                        row[enumerator.Key.ToString()] = enumerator.Value;

                gridView.CancelEdit();
                e.Cancel = true;


                dataTable.Rows.Add(row);

                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
            }

        }

        protected void ExpAllocGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            // Get the index of the deleted row
            int deletedRowIndex = Convert.ToInt32(e.Keys[ExpAllocGrid.KeyFieldName].ToString());

            //Delete row
            e.Cancel = true;
            dsExpAlloc = (DataSet)Session["DataSetExpAlloc"];
            dsExpAlloc.Tables[0].Rows.Remove(dsExpAlloc.Tables[0].Rows.Find(e.Keys[ExpAllocGrid.KeyFieldName]));

        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            decimal totalNetAmount = 0;
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            //{
            //    ExpAllocGrid.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}

            ASPxGridView grid = (ASPxGridView)sender;
            grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;

        }

        //Display Expense detail data to modal
        [WebMethod]
        public static ExpDetails DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.DisplayExpDetails(expDetailID);
        }

        public ExpDetails DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_ExpenseDetails.Where(x=>x.ExpenseReportDetail_ID == expDetailID).FirstOrDefault();
            ExpDetails exp_det_class = new ExpDetails();

            if (exp_details != null)
            {
                exp_det_class.dateAdded = Convert.ToDateTime(exp_details.DateAdded).ToString("MM/dd/yyyy hh:mm:ss");
                if(exp_details.Supplier != null)
                {
                    exp_det_class.supplier = exp_details.Supplier;
                }
                if (exp_details.Particulars != null)
                {
                    exp_det_class.particulars = exp_details.Particulars.ToString();
                }
                if (exp_details.AccountToCharged != null)
                {
                    exp_det_class.acctCharge = exp_details.AccountToCharged;
                }
                if (exp_details.TIN != null)
                {
                    exp_det_class.tin = exp_details.TIN;
                }
                if (exp_details.InvoiceOR != null)
                {
                    exp_det_class.invoice = exp_details.InvoiceOR;
                }
                if (exp_details.CostCenterIOWBS != null)
                {
                    exp_det_class.costCenter = exp_details.CostCenterIOWBS;
                }
                if (exp_details.GrossAmount != null)
                {
                    exp_det_class.grossAmnt = Convert.ToDecimal(exp_details.GrossAmount);
                }
                if (exp_details.VAT != null)
                {
                    exp_det_class.vat = Convert.ToDecimal(exp_details.VAT);
                }
                if (exp_details.EWT != null)
                {
                    exp_det_class.ewt = Convert.ToDecimal(exp_details.EWT);
                }
                if (exp_details.NetAmount != null)
                {
                    exp_det_class.netAmnt = Convert.ToDecimal(exp_details.NetAmount);
                }
                if (exp_details.ExpenseMain_ID != null)
                {
                    exp_det_class.expMainId = Convert.ToInt32(exp_details.ExpenseMain_ID);
                }
                if (exp_details.Preparer_ID != null)
                {
                    exp_det_class.preparerId = exp_details.Preparer_ID;
                }
                if (exp_details.ExpDtl_IO != null)
                {
                    exp_det_class.io = exp_details.ExpDtl_IO;
                }

                Session["ExpDetailsID"] = expDetailID.ToString();

            }

            return exp_det_class;
        }


        protected void ExpAllocGrid_edit_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            var expAllocs = _DataContext.ACCEDE_T_ExpenseDetailsMaps.Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));
            decimal totalAmnt = new decimal(0.00);

            ASPxGridView grid =  (ASPxGridView)sender;

            foreach(var item in expAllocs)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }

            totalAmnt = totalAmnt + Convert.ToDecimal(e.NewValues["NetAmount"]);
            if(totalAmnt > Convert.ToDecimal(grossAmount_edit.Value))
            {
                grid.Styles.Footer.ForeColor = System.Drawing.Color.Red;

                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;

                e.Cancel = true;

            }
            else
            {
                e.NewValues["ExpenseReportDetail_ID"] = Convert.ToInt32(Session["ExpDetailsID"]);
                e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);

                grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;
            }
            
            
        }

        protected void ExpAllocGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            var expAllocs = _DataContext.ACCEDE_T_ExpenseDetailsMaps.Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));
            decimal totalAmnt = new decimal(0.00);

            ASPxGridView grid = (ASPxGridView)sender;

            foreach (var item in expAllocs)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }
            grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;
        }

        [WebMethod]
        public static string SaveExpDetailsAJAX(string dateAdd, string tin_no, string invoice_no, string cost_center,
            string gross_amount, string net_amount, string supp, string particu, string acctCharge, string vat_amnt, string ewt_amnt, string currency, string io, string wbs)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.SaveExpDetails(dateAdd, tin_no, invoice_no, cost_center, gross_amount, net_amount, supp, particu, acctCharge, vat_amnt, ewt_amnt, currency, io, wbs);
        }

        public string SaveExpDetails(string dateAdd, string tin_no, string invoice_no, string cost_center,
            string gross_amount, string net_amount, string supp, string particu, string acctCharge, string vat_amnt, string ewt_amnt, string currency, string io, string wbs)
        {
            try
            {
                decimal totalNetAmnt = new decimal(0.00);
                var expDtlMap = _DataContext.ACCEDE_T_ExpenseDetailsMaps.Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));

                foreach (var item in expDtlMap)
                {
                    totalNetAmnt += Convert.ToDecimal(item.NetAmount);
                }

                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if (totalNetAmnt < gross && expDtlMap.Count() > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + ". Please check the allocation amounts.";
                    return error;
                }
                else
                {
                    var expDetail = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"])).FirstOrDefault();
                    if (expDetail != null)
                    {
                        expDetail.DateAdded = Convert.ToDateTime(dateAdd);
                        expDetail.TIN = string.IsNullOrEmpty(tin_no) ? (string)null : tin_no;
                        expDetail.InvoiceOR = string.IsNullOrEmpty(invoice_no) ? (string)null : invoice_no;
                        expDetail.CostCenterIOWBS = cost_center;
                        expDetail.GrossAmount = Convert.ToDecimal(gross_amount);
                        expDetail.NetAmount = Convert.ToDecimal(net_amount);
                        expDetail.Supplier = string.IsNullOrEmpty(supp) ? (string)null : supp;
                        expDetail.Particulars = Convert.ToInt32(particu);
                        expDetail.AccountToCharged = acctCharge;
                        expDetail.VAT = Convert.ToDecimal(vat_amnt);
                        expDetail.EWT = Convert.ToDecimal(ewt_amnt);
                        expDetail.ExpDtl_Currency = currency;
                        expDetail.ExpDtl_IO = string.IsNullOrEmpty(io) ? (string)null : io;
                        expDetail.ExpDtl_WBS = string.IsNullOrEmpty(wbs) ? (string)null : wbs;
                    }
                }

                _DataContext.SubmitChanges();

                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
                var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                var expDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));
                
                decimal totalReim = new decimal(0);
                decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                foreach(var ca in rfpCA)
                {
                    totalCA += Convert.ToDecimal(ca.Amount);
                }

                foreach(var exp in expDetails)
                {
                    totalExpense += Convert.ToDecimal(exp.NetAmount);
                }

                totalReim = totalCA - totalExpense;
                if(totalReim < 0)
                {
                    if(rfpReim != null)
                    {
                        rfpReim.Amount = Math.Abs(totalReim);
                    }
                }
                else
                {
                    if (rfpReim != null)
                    {
                        rfpReim.Status = 4;
                    }

                }

                _DataContext.SubmitChanges();
                return "success";
            }catch (Exception ex)
            {
                return ex.Message;
            }
        }

        protected void ExpAllocGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            decimal totalNetAmount = 0;

            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount_edit.Value))
            //{
            //    ExpAllocGrid_edit.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}
            ASPxGridView grid = (ASPxGridView)sender;

            grid.JSProperties["cpComputeUnalloc_edit"] = totalNetAmount;
        }

        [WebMethod]
        public static bool UpdateCurrencyAJAX(string currency)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();

            return exp.UpdateCurrency(currency);
        }

        public bool UpdateCurrency(string currency)
        {
            try
            {
                var mainExp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                if(mainExp != null)
                {
                    mainExp.Exp_Currency = currency;

                    var expDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == mainExp.ID);

                    foreach(var expense in expDetails)
                    {
                        expense.ExpDtl_Currency = currency;

                    }

                    _DataContext.SubmitChanges();
                }

                return true;
            }catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public bool RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains.Where(x=>x.RFP_DocNum == rfpDoc).FirstOrDefault();
                if(rfp != null)
                {
                    Session["passRFPID"] = rfp.ID;
                }
                return true;
            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static bool CheckReimburseValidationAJAX(string t_amount)
        {
            AccedeExpenseReportEdit1 ex = new AccedeExpenseReportEdit1();
            return ex.CheckReimburseValidation(t_amount);
        }

        public bool CheckReimburseValidation(string t_amount)
        {
            try
            {
                var rfp_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
                var totalCA = new decimal(0.00);
                foreach (var item in rfp_CA)
                {
                    totalCA += Convert.ToDecimal(item.Amount);

                }

                var expDetail = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));
                var totalExp = new decimal(0.00);
                foreach (var item in expDetail)
                {
                    totalExp += Convert.ToDecimal(item.GrossAmount);
                }

                decimal totalDue = new decimal(0);
                totalDue = totalCA - totalExp;

                if(totalDue < 0 && Math.Abs(totalDue) > Convert.ToDecimal(t_amount))
                {
                    var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true);
                    if(rfpReim.Count() > 0)
                    {
                        return false;
                    }
                    else
                    {
                        return true;
                    }
                }

                return false;
            }catch (Exception ex) { return false; }
        }

        public class ExpDetails
        {
            public string dateAdded { get; set; }
            public string supplier { get; set; }
            public string particulars { get; set; }
            public string tin { get; set; }
            public string invoice { get; set; }
            public string acctCharge { get; set; }
            public string costCenter { get; set; }
            public decimal grossAmnt { get; set; }
            public decimal vat { get; set; }
            public decimal ewt { get; set; }
            public decimal netAmnt { get; set; }
            public int expMainId { get; set; }
            public string preparerId { get; set; }
            public string io { get; set; }
        }

        protected void exp_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = exp_EmpId.Value;

            sqlDept.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();

            exp_Department.DataSourceID = null;
            exp_Department.DataSource = sqlDept;
            exp_Department.DataBind();

            exp_Department.SelectedIndex = 0;
        }

        protected void UploadControllerExpD_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            // Create a new data table if it doesn't exist in the data set
            DataSet ImgDS = (DataSet)Session["DataSetDoc"];
            foreach (var file in UploadControllerExpD.UploadedFiles)
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
                row["ID"] = GetDocNewId();
                row["FileName"] = file.FileName;
                row["FileByte"] = file.FileBytes;
                row["FileExt"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["FileDesc"] = file.FileName.Split('.').First();
                ImgDS.Tables[0].Rows.Add(row);


            }

            // Bind the data set to the grid view
            DocuGrid.DataSource = ImgDS.Tables[0];

            DocuGrid.DataBind();
        }

        protected void DocuGrid_RowDeleting1(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            int i = DocuGrid.FindVisibleIndexByKeyValue(e.Keys[DocuGrid.KeyFieldName]);
            //Control c = DocuGrid.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            dsDoc = (DataSet)Session["DataSetDoc"];
            dsDoc.Tables[0].Rows.Remove(dsDoc.Tables[0].Rows.Find(e.Keys[DocuGrid.KeyFieldName]));
        }

        protected void DocuGrid_RowUpdating1(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
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

        protected void UploadControllerExpD_edit_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            foreach (var file in UploadControllerExpD_edit.UploadedFiles)
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
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                _DataContext.SubmitChanges();

                ACCEDE_T_ExpenseDetailFileAttach docsMap = new ACCEDE_T_ExpenseDetailFileAttach();
                {
                    docsMap.FileAttach_Id = docs.ID;
                    docsMap.ExpDetail_Id = Convert.ToInt32(Session["ExpDetailsID"]);
                }
                _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.InsertOnSubmit(docsMap);
                _DataContext.SubmitChanges();
            }
            
            SqlDocs.DataBind();

        }

        protected void DocuGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var expFile_Id = e.Keys["File_Id"].ToString();

            var expFile = _DataContext.ITP_T_FileAttachments.Where(x => x.ID == Convert.ToInt32(expFile_Id)).FirstOrDefault();

            if (expFile != null)
            {
                expFile.Description = e.NewValues["Description"].ToString();
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }

        protected void DocuGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var expFile_Id = e.Keys["File_Id"].ToString();

            var expFile = _DataContext.ITP_T_FileAttachments.Where(x => x.ID == Convert.ToInt32(expFile_Id)).FirstOrDefault();
            var expMap = _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.Where(x=>x.FileAttach_Id == Convert.ToInt32(expFile_Id)).FirstOrDefault();
            if (expFile != null)
            {
                _DataContext.ITP_T_FileAttachments.DeleteOnSubmit(expFile);
                _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.DeleteOnSubmit(expMap);
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }


        protected void DocuGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["ExpDetailsID"] = null;

            DocuGrid_edit.DataSourceID = null;
            DocuGrid_edit.DataSource = SqlExpDetailAttach;
            DocuGrid_edit.DataBind();
        }

        protected void exp_Company_Callback(object sender, CallbackEventArgsBase e)
        {

        }

        protected void drpdown_WF_Callback(object sender, CallbackEventArgsBase e)
        {
            var rfpCA = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                .Where(x => x.IsExpenseCA == true)
                .Where(x=>x.isTravel != true);

            var totalCA = new decimal(0.00);
            foreach (var item in rfpCA)
            {
                totalCA += Convert.ToDecimal(item.Amount);
            }

            var expDetail = _DataContext.ACCEDE_T_ExpenseDetails
                .Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));

            var totalExp = new decimal(0.00);

            foreach (var item in expDetail)
            {
                totalExp += Convert.ToDecimal(item.GrossAmount);
            }
            //lbl_expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + mainExp.Exp_Currency;

            var totalDue = new decimal(0.00);
            totalDue = totalCA - totalExp;
            var reimRFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.IsExpenseReim == true).Where(x => x.Status != 4).Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]));

            var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(exp_Department.Value)).FirstOrDefault();
            //var rawf = _DataContext.vw_ACCEDE_I_UserWFAccesses
            //    .Where(x => x.CompanyId == Convert.ToInt32(exp_Company.Value))
            //    .Where(x => x.UserId == exp_EmpId.ToString())
            //    .Where(x => x.App_Id == 1032)
            //    .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
            //    .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
            //    .Where(x => x.IsRA == true)
            //    .Where(x => x.DepCode == (depcode != null ? depcode.DepCode : "0"))
            //    .FirstOrDefault();

            // Fetch data using the stored procedure
            DataTable rawf = GetWorkflowHeadersByExpenseAndDepartment(exp_EmpId.ToString(), Convert.ToInt32(exp_EmpId.Value), totalExp, depcode != null ? depcode.DepCode : "0", 1032);

            if (rawf != null && rawf.Rows.Count > 0)
            {
                // Get the first row's WF_Id value
                DataRow firstRow = rawf.Rows[0];
                int wfId = Convert.ToInt32(firstRow["WF_Id"]);

                // Set the dropdown to the first item (if applicable)
                drpdown_WF.SelectedIndex = 0;

                // Update the SQL data source parameters
                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();
                SqlWF.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();
            }
            else
            {
                // Handle the case when no data is returned
                drpdown_WF.SelectedIndex = -1; // Optionally reset the dropdown
                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = string.Empty;
                SqlWF.SelectParameters["WF_Id"].DefaultValue = string.Empty;
            }
        }

        protected void exp_costCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            sqlCostCenter.SelectParameters["CompanyId"].DefaultValue = exp_EmpId.Value != null ? exp_EmpId.Value.ToString() : "";
            sqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = exp_Department.Value != null ? exp_Department.Value.ToString() : "";
            sqlCostCenter.DataBind();

            //exp_costCenter.DataSourceID = null;
            //exp_costCenter.DataSource = sqlCostCenter;
            //exp_costCenter.DataBindItems();

            //if (exp_costCenter.Items.Count == 1)
            //{
            //    exp_costCenter.SelectedIndex = 0;
            //}
        }

        private DataTable GetWorkflowHeadersByExpenseAndDepartment(string userId, int companyId, decimal totalExp, string depCode, int app_id)
        {
            DataTable dataTable = new DataTable();

            using (SqlConnection connection = new SqlConnection(ITPORTALcon))
            {
                using (SqlCommand command = new SqlCommand("sp_sel_ACCEDE_GetWorkflowHeadersByExpenseAndDepartment", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@CompanyId", companyId);
                    command.Parameters.AddWithValue("@totalExp", totalExp);
                    command.Parameters.AddWithValue("@DepCode", depCode);
                    command.Parameters.AddWithValue("@AppId", app_id);

                    // Open the connection
                    connection.Open();

                    // Execute the query and load the results into the DataTable
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        dataTable.Load(reader);
                    }
                }
            }

            return dataTable;
        }

        protected void exp_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            exp_CTDepartment.DataSourceID = null;
            exp_CTDepartment.DataSource = SqlCTDepartment;
            exp_CTDepartment.DataBind();
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var Dept_id = e.Parameter.ToString();

            sqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = Dept_id;
            sqlCostCenter.DataBind();

            drpdown_CostCenter.DataSourceID = null;
            drpdown_CostCenter.DataSource = sqlCostCenter;
            drpdown_CostCenter.DataBind();

            var count = drpdown_CostCenter.Items.Count;
            if (count == 1)
                drpdown_CostCenter.SelectedIndex = 0; drpdown_CostCenter.DataBind();
        }

        protected void exp_EmpId_Callback(object sender, CallbackEventArgsBase e)
        {
            //var comp_id = drpdown_Comp.Value != null ? Convert.ToInt32(drpdown_Comp.Value) : 0;
            var comp_id = e.Parameter.ToString();
            if (comp_id != "")
            {
                SqlUser.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
                SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();
            }
            // Get the existing data from SqlDataSource
            DataView dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;

            if (dv != null)
            {
                // Convert DataView to DataTable to modify it
                DataTable dt = dv.ToTable();

                // Add a new row manually
                DataRow newRow = dt.NewRow();
                newRow["DelegateFor_UserID"] = Session["userID"].ToString();
                newRow["FullName"] = Session["userFullName"].ToString();
                dt.Rows.Add(newRow);

                // Rebind the ComboBox with the updated list
                exp_EmpId.DataSource = dt;
                exp_EmpId.TextField = "FullName";   // Ensure text field is set correctly
                exp_EmpId.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly
                exp_EmpId.DataBind();
            }
        }
    }
}