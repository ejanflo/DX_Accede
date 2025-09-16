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
using static DevExpress.XtraEditors.Mask.MaskSettings;

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

                        var pending_SAPDoc_status = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Description == "Pending SAP Doc No.")
                            .FirstOrDefault();

                        var disbursed_status = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Description == "Disbursed")
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
                        var btnSave = FormExpApprovalView.FindItemOrGroupByName("BtnSaveDetails") as LayoutItem;
                        var upload = FormExpApprovalView.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
                        var print = FormExpApprovalView.FindItemOrGroupByName("printRFP") as LayoutItem;
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
                                    if(wfDetails.Status.ToString() == pending_SAPDoc_status.STS_Id.ToString())
                                    {
                                        btnDisburse.ClientVisible = false;
                                        btnSave.ClientVisible = true;
                                    }
                                    else
                                    {
                                        if(wfDetails.Status.ToString() == disbursed_status.STS_Id.ToString())
                                        {
                                            btnDisburse.ClientVisible = false;
                                            print.ClientVisible = true;
                                        }
                                        else
                                        {
                                            btnDisburse.ClientVisible = true;
                                            btnSave.ClientVisible = false;
                                        }
                                            
                                    }
                                    edit_SAPDocNo.Value = reimRFP.SAPDocNo;
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

        [WebMethod]
        public static void PrintRFPAJAX(string rfpDoc)
        {
            AccedeCashierExpenseViewPage page = new AccedeCashierExpenseViewPage();
            page.PrintRFP(rfpDoc);

            return;

        }

        public void PrintRFP(string rfpDoc)
        {
            var doc = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.RFP_DocNum == rfpDoc);
            Session["passRFPID"] = doc.ID;
        }

        protected void FormExpApprovalView_Init(object sender, EventArgs e)
        {
            //try
            //{
            //    string encryptedID = Request.QueryString["secureToken"];
            //    if (!string.IsNullOrEmpty(encryptedID))
            //    {
            //        int actID = Convert.ToInt32(Decrypt(encryptedID));

            //        var actDetails = _DataContext.ITP_T_WorkflowActivities
            //            .Where(x => x.WFA_Id == Convert.ToInt32(actID))
            //            .FirstOrDefault();

            //        var exp_id = Convert.ToInt32(actDetails.Document_Id);
            //        var exp_details = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == exp_id).FirstOrDefault();

            //        if (!IsPostBack || (Session["DataSetDoc"] == null))
            //        {
            //            dsDoc = new DataSet();
            //            DataTable masterTable = new DataTable();
            //            masterTable.Columns.Add("ID", typeof(int));
            //            masterTable.Columns.Add("Orig_ID", typeof(int));
            //            masterTable.Columns.Add("FileName", typeof(string));
            //            masterTable.Columns.Add("FileByte", typeof(byte[]));
            //            masterTable.Columns.Add("FileExt", typeof(string));
            //            masterTable.Columns.Add("FileSize", typeof(string));
            //            masterTable.Columns.Add("FileDesc", typeof(string));
            //            masterTable.Columns.Add("User_ID", typeof(string));
            //            masterTable.Columns.Add("isExist", typeof(bool));
            //            masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

            //            dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
            //            Session["DataSetDoc"] = dsDoc;

            //        }
            //        else
            //            dsDoc = (DataSet)Session["DataSetDoc"];

            //        var docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").FirstOrDefault();
            //        var ExpDocs = _DataContext.ITP_T_FileAttachments.Where(x => x.Doc_ID == exp_details.ID).Where(x => x.DocType_Id == docType.DCT_Id).ToList();

            //        if (!IsPostBack || (Session["DataSetDoc"] == null))
            //        {
            //            foreach (var expDoc in ExpDocs)
            //            {
            //                // Add a new row to the data table with the uploaded file data
            //                DataRow row = dsDoc.Tables[0].NewRow();
            //                row["ID"] = GetNewId();
            //                row["Orig_ID"] = expDoc.ID;
            //                row["FileName"] = expDoc.FileName;
            //                row["FileByte"] = expDoc.FileAttachment.ToArray();
            //                row["FileExt"] = expDoc.FileExtension;
            //                row["FileSize"] = expDoc.FileSize;
            //                row["FileDesc"] = expDoc.Description;
            //                row["User_ID"] = expDoc.User_ID;
            //                row["isExist"] = true;
            //                dsDoc.Tables[0].Rows.Add(row);

            //            }
            //        }

            //        DocuGrid.DataSource = dsDoc.Tables[0];
            //        DocuGrid.DataBind();
            //    }

            //}
            //catch (Exception ex)
            //{
            //    Response.Redirect("~/Logon.aspx");
            //}
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
        public static string SaveCashierChangesAJAX(string SAPDoc, int stats, string secureToken, string signee, string signatureData)
        {
            AccedeCashierExpenseViewPage rfp = new AccedeCashierExpenseViewPage();

            return rfp.SaveCashierChanges(SAPDoc, stats, secureToken, signee, signatureData);
        }

        public string SaveCashierChanges(string SAPDoc, int stats, string secureToken, string signee, string signatureData)
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

                    var pending_SAPDoc_status = _DataContext.ITP_S_Status
                        .Where(x=>x.STS_Description == "Pending SAP Doc No.")
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
                            rfp_main_reim.SAPDocNo = SAPDoc;
                            if (release_cash_status != null && cashierWF != null && cashierWFDetail != null && orgRole != null)
                            {
                                var wfDetail_reim = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.Document_Id == rfp_main_reim.ID)
                                .Where(x => x.Status == wfDetails.Status)
                                .Where(x => x.AppDocTypeId == rfp_app_docType.DCT_Id)
                                .FirstOrDefault();

                                if (wfDetail_reim != null)
                                {
                                    //UPDATE ACTIVITY REIM
                                    if (SAPDoc != "" && SAPDoc != null)
                                    {
                                        wfDetail_reim.Status = release_cash_status.STS_Id;
                                    }
                                    else
                                    {
                                        wfDetail_reim.Status = pending_SAPDoc_status.STS_Id;
                                    }
                                    
                                    wfDetail_reim.DateAction = DateTime.Now;
                                    wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ":";
                                    wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                                }

                                rfp_main_reim.Status = release_cash_status.STS_Id;

                                byte[] signatureBytes = Base64ToBytes(signatureData);
                                var existRFPSignature = _DataContext.ACCEDE_T_RFPSignatures.FirstOrDefault(x => x.RFPMain_Id == rfp_main_reim.ID);
                                if (existRFPSignature != null)
                                {
                                    existRFPSignature.RFPMain_Id = rfp_main_reim.ID;
                                    existRFPSignature.Signature = signatureBytes;
                                    existRFPSignature.Signee_Fullname = signee;
                                    existRFPSignature.Status_Id = release_cash_status.STS_Id;
                                    existRFPSignature.DateReceived = DateTime.Now;
                                }
                                else
                                {
                                    ACCEDE_T_RFPSignature sig = new ACCEDE_T_RFPSignature
                                    {
                                        RFPMain_Id = rfp_main_reim.ID,
                                        Signature = signatureBytes,
                                        Signee_Fullname = signee,
                                        Status_Id = release_cash_status.STS_Id,
                                        DateReceived = DateTime.Now
                                    };

                                    _DataContext.ACCEDE_T_RFPSignatures.InsertOnSubmit(sig);
                                }

                            }
                            else
                            {
                                //error in setup
                                return "There is an error in setup. Please contact admin regarding this issue.";
                            }
                        }

                        //UPDATE WF ACTIVITY EXPENSE
                        if (SAPDoc != "" && SAPDoc != null)
                        {
                            wfDetails.Status = release_cash_status.STS_Id;
                        }
                        else
                        {
                            wfDetails.Status = pending_SAPDoc_status.STS_Id;
                        }
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                        _DataContext.SubmitChanges();

                        exp_main.Status = completed_status.STS_Id;
                    }

                    if (wfDetails.Status == pending_SAPDoc_status.STS_Id && stats == 0 && SAPDoc != "" && SAPDoc != null)
                    {
                        //UPDATE WF ACTIVITY EXPENSE
                        wfDetails.Status = release_cash_status.STS_Id;
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                        if (rfp_main_reim != null)
                        {
                            
                            rfp_main_reim.SAPDocNo = SAPDoc;
                            if (release_cash_status != null && cashierWF != null && cashierWFDetail != null && orgRole != null)
                            {
                                var wfDetail_reim = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.Document_Id == rfp_main_reim.ID)
                                .Where(x => x.Status == wfDetails.Status)
                                .Where(x => x.AppDocTypeId == rfp_app_docType.DCT_Id)
                                .FirstOrDefault();

                                if (wfDetail_reim != null)
                                {
                                    //UPDATE ACTIVITY REIM
                                    
                                    wfDetail_reim.Status = release_cash_status.STS_Id;
                                    wfDetail_reim.DateAction = DateTime.Now;
                                    wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ":";
                                    wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                                }

                            }
                            else
                            {
                                //error in setup
                                return "There is an error in setup. Please contact admin regarding this issue.";
                            }
                        }

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

        public static byte[] Base64ToBytes(string base64String)
        {
            // Remove the data URL prefix if present
            if (base64String.Contains(","))
            {
                base64String = base64String.Substring(base64String.IndexOf(",") + 1);
            }

            return Convert.FromBase64String(base64String);
        }

        [WebMethod]
        public static string ReleaseARReferenceAJAX(string ARReference, string secureToken)
        {
            AccedeCashierExpenseViewPage exp = new AccedeCashierExpenseViewPage();
            return exp.ReleaseARReference(ARReference, secureToken);

        }

        public string ReleaseARReference(string ARReference, string secureToken)
        {
            string encryptedID = secureToken;
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int actID = Convert.ToInt32(Decrypt(encryptedID));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id))
                    .FirstOrDefault();

                var rfp_main_reim = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id))
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
                //DataSet dsFile = (DataSet)Session["DataSetDoc"];
                //DataTable dataTable = dsFile.Tables[0];

                //if (dataTable.Rows.Count > 0)
                //{
                //    string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                //    string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                //    using (SqlConnection connection = new SqlConnection(connectionString1))
                //    using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                //    {
                //        // Define the parameters for the SQL query
                //        command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                //        command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                //        command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                //        command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                //        command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                //        command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                //        command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                //        command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                //        command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                //        command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                //        command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);
                //        command.Parameters.Add("@docType", SqlDbType.Int, 10);

                //        // Open the connection to the database
                //        connection.Open();

                //        // Loop through the rows in the DataTable and insert them into the database
                //        foreach (DataRow row in dataTable.Rows)
                //        {
                //            if (Convert.ToBoolean(row["isExist"]) == false)
                //            {
                //                command.Parameters["@filename"].Value = row["FileName"];
                //                command.Parameters["@file_byte"].Value = row["FileByte"];
                //                command.Parameters["@desc"].Value = row["FileDesc"];
                //                command.Parameters["@date_upload"].Value = DateTime.Now;
                //                command.Parameters["@app_id"].Value = 1032;
                //                command.Parameters["@comp_id"].Value = exp_main.ExpChargedTo_CompanyId;
                //                command.Parameters["@doc_id"].Value = exp_main.ID;
                //                command.Parameters["@doc_no"].Value = exp_main.DocNo;
                //                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                //                command.Parameters["@fileExt"].Value = row["FileExt"];
                //                command.Parameters["@filesize"].Value = row["FileSize"];
                //                command.Parameters["@docType"].Value = app_docType_exp != null ? app_docType_exp.DCT_Id : 0;
                //                command.ExecuteNonQuery();
                //            }

                //        }

                //        // Close the connection to the database
                //        connection.Close();


                //    }
                //}

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

                    var wfDetail_reim = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.Document_Id == rfp_main_reim.ID)
                                .Where(x => x.Status == wfDetails.Status)
                                .Where(x => x.AppDocTypeId == app_docType_rfp.DCT_Id)
                                .FirstOrDefault();

                    if (wfDetail_reim != null)
                    {
                        //UPDATE ACTIVITY REIM

                        wfDetail_reim.Status = 7;
                        wfDetail_reim.DateAction = DateTime.Now;
                        wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ":";
                        wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                    }
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

                    var sender_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == Session["UserID"].ToString())
                            .FirstOrDefault();

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    ///////---START EMAIL PROCESS-----////////
                    foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                    {
                        var nexApprover_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == user.UserId)
                            .FirstOrDefault();


                        exp.SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, "", "Pending", payMethod.ToString(), tranType.ToString(), "");

                    }

                    var creator_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == exp_main.UserId)
                            .FirstOrDefault();

                    AR_SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, "", "Approve", payMethod.ToString(), tranType.ToString(), ARReference);

                    //Update Exp WFActivity
                    wfDetails.Status = 7;
                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ":";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();

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

            return "Secure token is null.";
        }

        public bool AR_SendEmailTo(int doc_id, string receiver_id, int Comp_id, string sender_fullname, string sender_email, string doc_no, string date_created, string document_purpose, string remarks, string status, string payMethod, string tranType, string AR)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == doc_id)
                    .FirstOrDefault();

                var requestor_detail = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == exp_main.ExpenseName)
                    .FirstOrDefault();

                var user_email = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == receiver_id)
                    .FirstOrDefault();

                var comp_name = _DataContext.CompanyMasters
                    .Where(x => x.WASSId == Comp_id)
                    .FirstOrDefault();

                //Start--   Get Text info
                var queryText =
                        from texts in _DataContext.ITP_S_Texts
                        where texts.Type == "Email" && texts.Name == status
                        select texts;

                var emailMessage = "";
                var emailSubMessage = "";
                var emailColor = "";
                var emailSubTitle = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = "The Cashier has received your returned payment. Your Expense Report has now been forwarded to the Finance Approvers for review.";

                    emailColor = text.Color.ToString();
                    emailMessage = "please be informed that the Cashier has successfully released your AR Number.";
                    emailSubTitle = text.Text3.ToString();
                }
                //End--     Get Text info

                string appName = "ACCEDE Expense Report";
                string recipientName = user_email.FName;
                string senderName = sender_fullname;
                string emailSender = sender_email;
                string emailSite = "https://apps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": " + "Released AR No.";
                string requestorName = requestor_detail.FullName;


                ANFLO anflo = new ANFLO();

                //Body Details Sample
                string emailDetails = "";

                emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
                emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>";
                emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>";
                emailDetails += "<tr><td>Requestor</td><td><strong>" + requestorName + "</strong></td></tr>";
                //emailDetails += "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>";
                emailDetails += "<tr><td>Transaction Type</td><td><strong>" + tranType + "</strong></td></tr>";
                emailDetails += "<tr><td>Status</td><td><strong>" + "Pending" + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Purpose</td><td><strong>" + document_purpose + "</strong></td></tr>";
                emailDetails += "<tr><td>AR No.</td><td><strong>" + AR + "</strong></td></tr>";
                emailDetails += "</table>";
                emailDetails += "<br>";

                emailDetails += "</table>";
                //End of Body Details Sample

                //}
                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, remarks, emailSite, emailColor);

                if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }
            catch (Exception e)
            {
                return false;
            }
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
            string encryptedID = Request.QueryString["secureToken"];
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int actID = Convert.ToInt32(Decrypt(encryptedID));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();

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

                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                    {
                        docs.FileAttachment = file.FileBytes;
                        docs.FileName = file.FileName;
                        docs.Doc_ID = exp_main.ID;
                        docs.App_ID = 1032;
                        docs.DocType_Id = 1016;
                        docs.User_ID = Session["userID"].ToString();
                        docs.FileExtension = file.FileName.Split('.').Last();
                        docs.Description = file.FileName.Split('.').First();
                        docs.FileSize = filesizeStr;
                        docs.Doc_No = exp_main.DocNo.ToString();
                        docs.Company_ID = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId);
                        docs.DateUploaded = DateTime.Now;
                        docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                    }

                    _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                }

                _DataContext.SubmitChanges();
                SqlExpDocs.DataBind();
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

        DataSet dsDoc = null;

        protected void DocuGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnRemove") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "User_ID");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && statusValue.ToString() == Session["userID"].ToString())
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
                int rowIndex = DocuGrid.FindVisibleIndexByKeyValue(rowKey);

                // Get the actual ID value from the grid using the row index
                object idValue = DocuGrid.GetRowValues(rowIndex, "ID");
                if (idValue != null)
                {
                    int id = Convert.ToInt32(idValue);
                    var file = _DataContext.ITP_T_FileAttachments.FirstOrDefault(x => x.ID == id);
                    if (file != null)
                    {
                        _DataContext.ITP_T_FileAttachments.DeleteOnSubmit(file);
                        _DataContext.SubmitChanges();
                    }
                }

                DocuGrid.DataBind();
            }
        }

        protected void DocuGrid_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "User_ID")
            {
                if (e.CellValue != null)
                {
                    var emp = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == e.CellValue.ToString()).FirstOrDefault();

                    e.Cell.Text = emp.FullName;
                }
            }
        }

        [WebMethod]
        public static string CheckSAPVAlidAJAX(string SAPDoc, string secureToken)
        {
            AccedeCashierExpenseViewPage page = new AccedeCashierExpenseViewPage();
            return page.CheckSAPVAlid(SAPDoc, secureToken);
        }

        public string CheckSAPVAlid(string SAPDoc, string secureToken)
        {
            if (!string.IsNullOrEmpty(secureToken))
            {
                int actID = Convert.ToInt32(Decrypt(secureToken));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                var reimRFP = _DataContext.ACCEDE_T_RFPMains
                                        .Where(x => x.IsExpenseReim == true)
                                        .Where(x => x.Status != 4)
                                        .Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id))
                                        .Where(x => x.isTravel != true)
                                        .FirstOrDefault();

                var rfpCheck = _DataContext.ACCEDE_T_RFPMains.Where(x => x.SAPDocNo == SAPDoc).FirstOrDefault();

                if (rfpCheck != null && SAPDoc != reimRFP.SAPDocNo)
                {
                    return "error";
                }
                else
                {
                    return "clear";
                }
            }
            else
            {
                return "Secure token is null.";
            }

        }
    }
}