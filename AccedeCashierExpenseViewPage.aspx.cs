using DevExpress.Data.Filtering.Helpers;
using DevExpress.Web;
using System;
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
    public partial class AccedeCashierExpenseViewPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        decimal dueComp = new decimal(0.00);
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    string encryptedID = Request.QueryString["secureToken"];
                    if (!string.IsNullOrEmpty(encryptedID))
                    {
                        int actID = Convert.ToInt32(Decrypt(encryptedID));
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

                        var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                        var expID = wfDetails.Document_Id;
                        var expDetails = _DataContext.ACCEDE_T_ExpenseMains
                            .Where(x => x.ID == Convert.ToInt32(expID))
                            .FirstOrDefault();

                        var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                        sqlMain.SelectParameters["ID"].DefaultValue = expDetails.ID.ToString();
                        SqlDocs.SelectParameters["Doc_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlCA.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlReim.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = expDetails.ID.ToString();
                        SqlCADetails.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                        SqlExpDocs.SelectParameters["Doc_ID"].DefaultValue = expID.ToString();
                        SqlExpDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";


                        var exp = _DataContext.ACCEDE_T_ExpenseMains
                            .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                            .FirstOrDefault();

                        SqlIO.SelectParameters["CompanyId"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();

                        SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                        SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                        SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";

                        var status_id = exp.Status.ToString();
                        var user_id = exp.UserId.ToString();

                        var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                        var btnAR = FormExpApprovalView.FindItemOrGroupByName("SaveAR") as LayoutItem;
                        var btnDisburse = FormExpApprovalView.FindItemOrGroupByName("CashSave") as LayoutItem;
                        var upload = FormExpApprovalView.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
                        upload.Visible = true;

                        if (myLayoutGroup != null)
                        {
                            myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";

                        }

                        var RFPCA = _DataContext.ACCEDE_T_RFPMains
                            .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                            .Where(x => x.IsExpenseCA == true)
                            .Where(x => x.isTravel != true);

                        decimal totalCA = 0;
                        foreach (var item in RFPCA)
                        {
                            totalCA += Convert.ToDecimal(item.Amount);
                        }
                        caTotal.Text = totalCA.ToString("#,##0.00") + "  PHP ";

                        var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                            .Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));

                        decimal totalExp = 0;
                        foreach (var item in ExpDetails)
                        {
                            totalExp += Convert.ToDecimal(item.NetAmount);
                        }
                        expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";
                        dueComp = totalCA - totalExp;

                        if (dueComp < 0)
                        {
                            var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            dueField.Caption = "Net Due to Employee";

                            var reimRFP = _DataContext.ACCEDE_T_RFPMains
                                        .Where(x => x.IsExpenseReim == true)
                                        .Where(x => x.Status != 4)
                                        .Where(x => x.Exp_ID == Convert.ToInt32(exp.ID))
                                        .Where(x => x.isTravel != true)
                                        .FirstOrDefault();

                            if (reimRFP == null)
                            {
                                var reim = FormExpApprovalView.FindItemOrGroupByName("reimItem") as LayoutItem;
                                if (reim != null)
                                {
                                    reim.ClientVisible = true;
                                    
                                    //ReimburseGrid.Visible = false;
                                }

                            }
                            else
                            {
                                var reim = FormExpApprovalView.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                                if (reim != null)
                                {
                                    reim.ClientVisible = true;
                                    link_rfp.Value = reimRFP.RFP_DocNum;
                                    edit_SAPDocNo.Value = reimRFP.SAPDocNo;
                                    btnDisburse.ClientVisible = true;
                                }

                                var SAPdoc = FormExpApprovalView.FindItemOrGroupByName("SAPDoc") as LayoutItem;
                                SAPdoc.ClientVisible = true;
                            }

                        }
                        else
                        {
                            var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            dueField.Caption = "Net Due to Company";

                            if (dueComp > 0)
                            {
                                var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                                AR_Reference.ClientVisible = true;

                                btnAR.ClientVisible = true;
                                btnDisburse.ClientVisible = false;
                            }
                        }

                        dueTotal.Text = FormatDecimal(dueComp) + "  PHP ";

                        //if (status_id == "3" || status_id == "13" || status_id == "15" || status_id == "18" || status_id == "19" && user_id == Session["userID"].ToString())
                        //{
                        //    btnEdit.ClientVisible = true;
                        //}

                        //if (status_id == "7")
                        //{
                        //    var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                        //    print.ClientVisible = true;
                        //}
                    }


                }
                else
                {
                    Response.Redirect("~/Logon.aspx");
                }
            }
            catch (Exception ex)
            {
                //Session["MyRequestPath"] = Request.Url.AbsoluteUri;
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void FormExpApprovalView_Init(object sender, EventArgs e)
        {
            try
            {
                string encryptedID = Request.QueryString["secureToken"];
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == Convert.ToInt32(actID))
                        .FirstOrDefault();

                    var exp_id = Convert.ToInt32(actDetails.Document_Id);
                    var exp_details = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == exp_id).FirstOrDefault();

                    if (!IsPostBack || (Session["DataSetDoc"] == null))
                    {
                        dsDoc = new DataSet();
                        DataTable masterTable = new DataTable();
                        masterTable.Columns.Add("ID", typeof(int));
                        masterTable.Columns.Add("Orig_ID", typeof(int));
                        masterTable.Columns.Add("FileName", typeof(string));
                        masterTable.Columns.Add("FileByte", typeof(byte[]));
                        masterTable.Columns.Add("FileExt", typeof(string));
                        masterTable.Columns.Add("FileSize", typeof(string));
                        masterTable.Columns.Add("FileDesc", typeof(string));
                        masterTable.Columns.Add("isExist", typeof(bool));
                        masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                        dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                        Session["DataSetDoc"] = dsDoc;

                    }
                    else
                        dsDoc = (DataSet)Session["DataSetDoc"];

                    var docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").FirstOrDefault();
                    var ExpDocs = _DataContext.ITP_T_FileAttachments.Where(x => x.Doc_ID == exp_details.ID).Where(x => x.DocType_Id == docType.DCT_Id).ToList();

                    if (!IsPostBack || (Session["DataSetDoc"] == null))
                    {
                        foreach (var expDoc in ExpDocs)
                        {
                            // Add a new row to the data table with the uploaded file data
                            DataRow row = dsDoc.Tables[0].NewRow();
                            row["ID"] = GetNewId();
                            row["Orig_ID"] = expDoc.ID;
                            row["FileName"] = expDoc.FileName;
                            row["FileByte"] = expDoc.FileAttachment.ToArray();
                            row["FileExt"] = expDoc.FileExtension;
                            row["FileSize"] = expDoc.FileSize;
                            row["FileDesc"] = expDoc.Description;
                            row["isExist"] = true;
                            dsDoc.Tables[0].Rows.Add(row);

                        }
                    }

                    DocuGrid.DataSource = dsDoc.Tables[0];
                    DocuGrid.DataBind();
                }

            }
            catch (Exception ex)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        public static string FormatDecimal(decimal value)
        {
            if (value < 0)
            {
                return $"({Math.Abs(value).ToString("#,##0.00")})";
            }
            return value.ToString("#,##0.00");
        }

        [WebMethod]
        public static string SaveCashierChangesAJAX(string SAPDoc, int stats, string secureToken)
        {
            AccedeCashierExpenseViewPage rfp = new AccedeCashierExpenseViewPage();

            return rfp.SaveCashierChanges(SAPDoc, stats, secureToken);
        }

        public string SaveCashierChanges(string SAPDoc, int stats, string secureToken)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));
                    var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var app_docType_rfp = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var app_docType_exp = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                        .FirstOrDefault();

                    var completed_status = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Complete")
                        .FirstOrDefault();

                    var rfp_main_reim = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                        .Where(x => x.IsExpenseReim == true).Where(x => x.Status != 4)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_main.ID)
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    var release_cash_status = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Description == "Disbursed")
                        .FirstOrDefault();

                    var cashierWF = _DataContext.ITP_S_WorkflowHeaders
                        .Where(x => x.Name == "ACDE CASHIER")
                        .Where(x => x.Company_Id == Convert.ToInt32(exp_main.ExpChargedTo_CompanyId))
                        .FirstOrDefault();

                    var cashierWFDetail = _DataContext.ITP_S_WorkflowDetails
                        .Where(x => x.WF_Id == Convert.ToInt32(cashierWF.WF_Id))
                        .FirstOrDefault();

                    var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles
                        .Where(x => x.OrgRoleId == Convert.ToInt32(cashierWFDetail.OrgRole_Id))
                        .Where(x => x.UserId == Session["userID"].ToString())
                        .FirstOrDefault();

                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                            .Where(x => x.DCT_Name == "ACDE RFP")
                            .Where(x => x.App_Id == 1032)
                            .FirstOrDefault();

                    var exp_app_doctype = _DataContext.ITP_S_DocumentTypes
                            .Where(x => x.DCT_Name == "ACDE Expense")
                            .Where(x => x.App_Id == 1032)
                            .FirstOrDefault();

                    var payMethod = "";
                    var tranType = "";
                    var stat = "";

                    if (rfp_main_reim != null)
                    {
                        Session["passRFPID"] = rfp_main_reim.ID.ToString();
                        stat = "success with reim";
                        payMethod = _DataContext.ACCEDE_S_PayMethods
                            .Where(x => x.ID == rfp_main_reim.PayMethod)
                            .FirstOrDefault().PMethod_name;

                        tranType = _DataContext.ACCEDE_S_RFPTranTypes
                            .Where(x => x.ID == rfp_main_reim.TranType)
                            .FirstOrDefault().RFPTranType_Name;
                    }
                    else
                    {
                        Session["passRFPID"] = "";
                        stat = "success";
                        payMethod = _DataContext.ACCEDE_S_PayMethods
                            .Where(x => x.ID == rfp_main_ca.PayMethod)
                            .FirstOrDefault().PMethod_name;

                        tranType = _DataContext.ACCEDE_S_RFPTranTypes
                            .Where(x => x.ID == rfp_main_ca.TranType)
                            .FirstOrDefault().RFPTranType_Name;

                    }

                    if (stats == 1)
                    {
                        if (rfp_main_reim != null)
                        {
                            var rfpDocType = _DataContext.ITP_S_DocumentTypes
                            .Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment")
                            .Select(x => x.DCT_Id)
                            .FirstOrDefault();

                            rfp_main_reim.SAPDocNo = SAPDoc;
                            if (release_cash_status != null && cashierWF != null && cashierWFDetail != null && orgRole != null)
                            {
                                var wfDetail_reim = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.Document_Id == rfp_main_reim.ID)
                                .Where(x => x.Status == wfDetails.Status)
                                .Where(x => x.AppDocTypeId == rfpDocType)
                                .FirstOrDefault();

                                if (wfDetail_reim != null)
                                {
                                    //UPDATE ACTIVITY REIM
                                    wfDetail_reim.Status = release_cash_status.STS_Id;
                                    wfDetail_reim.DateAction = DateTime.Now;
                                    wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ":";
                                    wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                                }

                                rfp_main_reim.Status = release_cash_status.STS_Id;
                            }
                            else
                            {
                                //error in setup
                                return "There is an error in setup. Please contact admin regarding this issue.";
                            }
                        }

                        //UPDATE WF ACTIVITY EXPENSE
                        wfDetails.Status = release_cash_status.STS_Id;
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                        _DataContext.SubmitChanges();

                        exp_main.Status = completed_status.STS_Id;
                    }


                    _DataContext.SubmitChanges();

                    return stat;
                }
                else
                {
                    return "Secure Token is null.";
                }

            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        [WebMethod]
        public static string ReleaseARReferenceAJAX(string ARReference)
        {
            AccedeCashierExpenseViewPage exp = new AccedeCashierExpenseViewPage();
            return exp.ReleaseARReference(ARReference);

        }

        public string ReleaseARReference(string ARReference)
        {
            var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                    .FirstOrDefault();

            var rfp_main_reim = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                    .Where(x => x.IsExpenseReim == true).Where(x => x.Status != 4)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

            var app_docType_exp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

            var app_docType_rfp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

            var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == exp_main.ID)
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

            //Insert Attachments
            DataSet dsFile = (DataSet)Session["DataSetDoc"];
            DataTable dataTable = dsFile.Tables[0];

            if (dataTable.Rows.Count > 0)
            {
                string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                using (SqlConnection connection = new SqlConnection(connectionString1))
                using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                {
                    // Define the parameters for the SQL query
                    command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                    command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                    command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                    command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                    command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                    command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                    command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                    command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);
                    command.Parameters.Add("@docType", SqlDbType.Int, 10);

                    // Open the connection to the database
                    connection.Open();

                    // Loop through the rows in the DataTable and insert them into the database
                    foreach (DataRow row in dataTable.Rows)
                    {
                        if (Convert.ToBoolean(row["isExist"]) == false)
                        {
                            command.Parameters["@filename"].Value = row["FileName"];
                            command.Parameters["@file_byte"].Value = row["FileByte"];
                            command.Parameters["@desc"].Value = row["FileDesc"];
                            command.Parameters["@date_upload"].Value = DateTime.Now;
                            command.Parameters["@app_id"].Value = 1032;
                            command.Parameters["@comp_id"].Value = exp_main.ExpChargedTo_CompanyId;
                            command.Parameters["@doc_id"].Value = exp_main.ID;
                            command.Parameters["@doc_no"].Value = exp_main.DocNo;
                            command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                            command.Parameters["@fileExt"].Value = row["FileExt"];
                            command.Parameters["@filesize"].Value = row["FileSize"];
                            command.Parameters["@docType"].Value = app_docType_exp != null ? app_docType_exp.DCT_Id : 0;
                            command.ExecuteNonQuery();
                        }

                    }

                    // Close the connection to the database
                    connection.Close();


                }
            }

            var payMethod = "";
            var tranType = "";

            if (rfp_main_reim != null)
            {
                payMethod = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfp_main_reim.PayMethod)
                    .FirstOrDefault().PMethod_name;

                tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfp_main_reim.TranType)
                    .FirstOrDefault().RFPTranType_Name;

                rfp_main_reim.Status = 1;
            }
            else
            {
                payMethod = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfp_main_ca.PayMethod)
                    .FirstOrDefault().PMethod_name;

                tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfp_main_ca.TranType)
                    .FirstOrDefault().RFPTranType_Name;

            }

            //transition to finance wf
            var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders
                .Where(x => x.WF_Id == exp_main.FAPWF_Id)
                .FirstOrDefault();

            if (finance_wf_data != null)
            {
                var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails
                    .Where(x => x.WF_Id == finance_wf_data.WF_Id)
                    .Where(x => x.Sequence == 1)
                    .FirstOrDefault();

                var org_id = fin_wfDetail_data.OrgRole_Id;
                var date2day = DateTime.Now;
                //DELEGATE CHECK
                foreach (var del in _DataContext.ITP_S_TaskDelegations.Where(x => x.OrgRole_ID_Orig == fin_wfDetail_data.OrgRole_Id).Where(x => x.DateFrom <= date2day).Where(x => x.DateTo >= date2day).Where(x => x.isActive == true))
                {
                    if (del != null)
                    {
                        org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                    }

                }

                if (rfp_main_reim != null)
                {
                    //Insert new activity to RFP Reimburse
                    ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                    {
                        new_activity.Status = 1;
                        new_activity.AppId = 1032;
                        new_activity.CompanyId = rfp_main_reim.Company_ID;
                        new_activity.Document_Id = rfp_main_reim.ID;
                        new_activity.WF_Id = fin_wfDetail_data.WF_Id;
                        new_activity.DateAssigned = DateTime.Now;
                        new_activity.DateCreated = DateTime.Now;
                        new_activity.IsActive = true;
                        new_activity.OrgRole_Id = org_id;
                        new_activity.WFD_Id = fin_wfDetail_data.WFD_Id;
                        new_activity.AppDocTypeId = app_docType_rfp.DCT_Id;
                    }
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                }

                //Insert new activity to Expense
                ITP_T_WorkflowActivity new_activity_exp = new ITP_T_WorkflowActivity();
                {
                    new_activity_exp.Status = 1;
                    new_activity_exp.AppId = 1032;
                    new_activity_exp.CompanyId = exp_main.CompanyId;
                    new_activity_exp.Document_Id = exp_main.ID;
                    new_activity_exp.WF_Id = fin_wfDetail_data.WF_Id;
                    new_activity_exp.DateAssigned = DateTime.Now;
                    new_activity_exp.DateCreated = DateTime.Now;
                    new_activity_exp.IsActive = true;
                    new_activity_exp.OrgRole_Id = org_id;
                    new_activity_exp.WFD_Id = fin_wfDetail_data.WFD_Id;
                    new_activity_exp.AppDocTypeId = app_docType_exp.DCT_Id;
                }
                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity_exp);

                ///////---START EMAIL PROCESS-----////////
                foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                {
                    var nexApprover_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == user.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    exp.SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, "", "Pending", payMethod.ToString(), tranType.ToString(), "");

                }

                exp_main.AR_Reference_No = ARReference;
                exp_main.Status = 1;
                _DataContext.SubmitChanges();
            }
            else
            {
                return "Workflow data does not exist.";
            }

            //End of Finance WF transition

            return "success";
            
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            Session["cID"] = Session["ExpenseId"];
            Response.Redirect("~/AccedeExpenseReportPrinting.aspx");
        }

        //PDF/IMAGE VIEWER
        [WebMethod]
        public static object AJAXGetDocument(string fileId, string appId)
        {
            DocumentViewer doc = new DocumentViewer();

            return doc.GetDocument(fileId, appId);
        }

        public object GetDocument(string fileId, string appId)
        {
            byte[] bytes;
            string fileName, contentType;
            string constr = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT FileName, FileAttachment, FileExtension FROM ITP_T_FileAttachment WHERE ID = @fileId AND App_ID = @appId";
                    cmd.Parameters.AddWithValue("@fileId", Convert.ToInt32(fileId));
                    cmd.Parameters.AddWithValue("@appId", Convert.ToInt32(appId));
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        sdr.Read();
                        bytes = (byte[])sdr["FileAttachment"];
                        contentType = sdr["FileExtension"].ToString();
                        fileName = sdr["FileName"].ToString();
                    }
                    con.Close();
                }
            }

            if (contentType == "png" || contentType == "jpg" || contentType == "jpeg" || contentType == "gif" || contentType == "JPEG" || contentType == "JPG" || contentType == "PNG" || contentType == "GIF")
            {
                string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            else
                return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }

        protected void CAWFActivityGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAWFActivity.SelectParameters["Document_Id"].DefaultValue = e.Parameters.ToString();
            SqlCAWFActivity.DataBind();

            CAWFActivityGrid.DataBind();
        }

        protected void CADocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAFileAttach.SelectParameters["Doc_ID"].DefaultValue = e.Parameters.ToString();
            SqlCAFileAttach.DataBind();

            CADocuGrid.DataBind();
        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
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
                row["FileDesc"] = file.FileName.Split('.').First();
                row["isExist"] = false;
                ImgDS.Tables[0].Rows.Add(row);
            }
            _DataContext.SubmitChanges();
            SqlExpDocs.DataBind();
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

        DataSet dsDoc = null;

        protected void DocuGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnRemove") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "isExist");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (Convert.ToBoolean(statusValue) != true))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }

            if (e.VisibleIndex >= 0 && e.ButtonID == "btnDownload") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "isExist");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (Convert.ToBoolean(statusValue) != false))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void DocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[1];

            if (buttonId == "btnRemove")
            {
                int i = DocuGrid.FindVisibleIndexByKeyValue(rowKey);

                // Access the dataset from the session
                DataSet dsDoc = (DataSet)Session["DataSetDoc"];

                // Ensure that the rowKey exists in the table before trying to remove it
                DataRow rowToRemove = dsDoc.Tables[0].Rows.Find(rowKey);
                if (rowToRemove != null)
                {
                    dsDoc.Tables[0].Rows.Remove(rowToRemove);
                }

                // Optionally rebind the grid after removing the row
                DocuGrid.DataBind();
            }
        }
    }
}