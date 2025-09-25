using DevExpress.DocumentServices.ServiceModel.DataContracts;
using DevExpress.Web;
using DevExpress.Web.Internal.XmlProcessor;
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
using static DevExpress.Utils.Drawing.Helpers.NativeMethods;

namespace DX_WebTemplate
{
    public partial class RFPViewPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Basic auth/session guard
                if (!AnfloSession.Current.ValidCookieUser())
                {
                    RedirectToLogin();
                    return;
                }

                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                // Required session values
                string empCode = GetSessionString("userID");
                if (string.IsNullOrEmpty(empCode))
                {
                    RedirectToLogin();
                    return;
                }

                int? rfpId = GetSessionInt("passRFPID");
                if (rfpId == null)
                {
                    RedirectToLogin();
                    return;
                }

                // Pull main RFP record once
                var rfp = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.ID == rfpId.Value);
                if (rfp == null)
                {
                    RedirectToLogin();
                    return;
                }

                // Cache frequently used lookups in a single pass
                // (Descriptions/Names used later)
                var neededStatusDescriptions = new[] { "Disbursed", "Pending SAP Doc No." };
                var neededStatusNames = new[] { "Pending at Cashier" };

                var statusList = _DataContext.ITP_S_Status
                    .Where(s => neededStatusDescriptions.Contains(s.STS_Description) || neededStatusNames.Contains(s.STS_Name))
                    .ToList();

                var disbursedStatus = statusList.FirstOrDefault(s => s.STS_Description == "Disbursed");
                var pendingSapDocStatus = statusList.FirstOrDefault(s => s.STS_Description == "Pending SAP Doc No.");
                var cashierPendingStatus = statusList.FirstOrDefault(s => s.STS_Name == "Pending at Cashier");

                // Transaction type (Cash Advance) id (nullable)
                int? cashAdvanceTranTypeId = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.RFPTranType_Name == "Cash Advance")
                    .Select(x => (int?)x.ID)
                    .FirstOrDefault();

                // Document type (ACDE RFP)
                var appDocType = _DataContext.ITP_S_DocumentTypes
                    .FirstOrDefault(x => x.DCT_Name == "ACDE RFP" && x.App_Id == 1032);

                // Set expense link / related label + visibility
                SetExpenseLink(rfp);

                // Payee resolution
                SetPayee(rfp, empCode);

                // Layout + buttons
                ConfigureLayout(rfp, empCode, cashAdvanceTranTypeId);

                // Cashier / workflow related controls
                ConfigureCashierSection(rfp, empCode, pendingSapDocStatus, cashierPendingStatus, disbursedStatus, appDocType);

                // Always (safe, idempotent) setup of SqlDataSource parameters
                SqlMain.SelectParameters["ID"].DefaultValue = rfp.ID.ToString();
                if (rfp.WF_Id != null)
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp.WF_Id.ToString();
                if (rfp.FAPWF_Id != null)
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp.FAPWF_Id.ToString();
                SqlActivity.SelectParameters["Document_Id"].DefaultValue = rfp.ID.ToString();
                SqlRFPDocs.SelectParameters["Doc_ID"].DefaultValue = rfp.ID.ToString();
                SqlRFPDocs.SelectParameters["DocType_Id"].DefaultValue = appDocType != null ? appDocType.DCT_Id.ToString() : "";
                if (rfp.ChargedTo_CompanyId != null)
                    SqlIO.SelectParameters["CompanyId"].DefaultValue = rfp.ChargedTo_CompanyId.ToString();

                // Creator-specific upload visibility (matches original logic)
                if (rfp.Status == 1 && rfp.User_ID != empCode)
                {
                    var btnSaveUser = formRFP.FindItemOrGroupByName("BtnSaveDetailsUser") as LayoutItem;
                    var upload = formRFP.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
                    if (btnSaveUser != null)
                    {
                        btnSaveUser.ClientVisible = true;
                        if (upload != null) upload.ClientVisible = true;
                    }
                }
            }
            catch
            {
                RedirectToLogin();
            }
        }

        #region Helper Methods (New)

        private string GetSessionString(string key)
        {
            return Session[key] == null ? string.Empty : Session[key].ToString();
        }

        private int? GetSessionInt(string key)
        {
            if (Session[key] == null) return null;
            if (int.TryParse(Session[key].ToString(), out int v)) return v;
            return null;
        }

        private void RedirectToLogin()
        {
            Response.Redirect("~/Logon.aspx");
        }

        private void SetExpenseLink(ACCEDE_T_RFPMain rfp)
        {
            if (rfp == null) return;

            // Travel
            if (rfp.isTravel == true)
            {
                var travel = _DataContext.ACCEDE_T_TravelExpenseMains.FirstOrDefault(x => x.ID == rfp.Exp_ID);
                if (travel != null)
                    lbl_expLink.Text = travel.Doc_No;
                else
                    ExpBtn.Visible = false;
                return;
            }

            // Invoice (TranType == 3)
            if (rfp.TranType == 3)
            {
                var invoice = _DataContext.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == Convert.ToInt32(rfp.Exp_ID));
                if (invoice != null)
                    lbl_expLink.Text = invoice.DocNo;
                else
                    ExpBtn.Visible = false;
                return;
            }

            // Regular expense
            var exp = _DataContext.ACCEDE_T_ExpenseMains.FirstOrDefault(x => x.ID == rfp.Exp_ID);
            if (exp != null)
                lbl_expLink.Text = exp.DocNo;
            else
                ExpBtn.Visible = false;
        }

        private void SetPayee(ACCEDE_T_RFPMain rfp, string currentUser)
        {
            if (rfp == null) return;

            if (rfp.TranType == 3)
            {
                // Original code fetched all vendors then filtered; keep behavior
                string cleaned = (rfp.Payee ?? "").Replace("\r", "").Replace("\n", "");
                var vendors = SAPConnector.GetVendorData("")
                    .GroupBy(x => new { x.VENDCODE, x.VENDNAME })
                    .Select(g => g.First())
                    .ToList();

                var payeeVendor = vendors.FirstOrDefault(x => x.VENDCODE == cleaned);
                if (payeeVendor != null)
                    txt_Payee.Text = payeeVendor.VENDNAME;
                return;
            }

            var user = _DataContext.ITP_S_UserMasters.FirstOrDefault(x => x.EmpCode == rfp.Payee);
            if (user != null)
                txt_Payee.Text = user.FullName;
        }

        private void ConfigureLayout(ACCEDE_T_RFPMain rfp, string empCode, int? cashAdvanceTranTypeId)
        {
            var groupTitle = formRFP.FindItemOrGroupByName("PageTitle") as LayoutGroup;
            if (groupTitle != null)
                groupTitle.Caption = "Request For Payment (View) - " + rfp.RFP_DocNum;

            var btnEdit = formRFP.FindItemOrGroupByName("btnEditRFP") as LayoutItem;
            var btnSubmit = formRFP.FindItemOrGroupByName("btnSubmit") as LayoutItem;
            var btnRecall = formRFP.FindItemOrGroupByName("recallBtn") as LayoutItem;
            var pld = formRFP.FindItemOrGroupByName("PLD") as LayoutItem;
            var wbs = formRFP.FindItemOrGroupByName("WBS") as LayoutItem; // (Unused currently but kept for parity)
            var cType = formRFP.FindItemOrGroupByName("ClassType") as LayoutItem;
            var tType = formRFP.FindItemOrGroupByName("TravType") as LayoutItem;
            var expDoc = formRFP.FindItemOrGroupByName("ExpDoc") as LayoutItem;

            if (rfp.Exp_ID != null && expDoc != null)
                expDoc.ClientVisible = true;

            if (rfp.isTravel == true)
            {
                rdButton_Trav.Checked = true;
                rdButton_NonTrav.Checked = false;
                if (cType != null) cType.ClientVisible = false;
            }
            else
            {
                rdButton_Trav.Checked = false;
                rdButton_NonTrav.Checked = true;
                if (tType != null) tType.ClientVisible = false;
                if (rfp.TranType == 3 && expDoc != null)
                    expDoc.Caption = "Link to Invoice Details";
            }

            // Edit / Submit visibility (matches original combined conditions)
            if ((rfp.Status == 3 || rfp.Status == 13 || rfp.Status == 15) &&
                rfp.User_ID == empCode &&
                rfp.IsExpenseReim != true &&
                rfp.IsExpenseCA == true)
            {
                if (btnEdit != null) btnEdit.Visible = true;
                if (btnSubmit != null) btnSubmit.Visible = true;
            }

            // PL Date (Cash Advance)
            if (rfp.TranType == cashAdvanceTranTypeId && pld != null)
            {
                pld.ClientVisible = true;
                if (rfp.PLDate != null)
                {
                    DateTime date = Convert.ToDateTime(rfp.PLDate);
                    PLD_lbl.Text = date.ToString("MMMM dd, yyyy");
                }
            }

            // Travel type label
            txtbox_TravType.Value = (rfp.isForeignTravel == true) ? "Foreign" : "Domestic";

            // Recall
            if (rfp.Status == 1 && rfp.User_ID == empCode && rfp.TranType == cashAdvanceTranTypeId && btnRecall != null)
                btnRecall.ClientVisible = true;

            // Restrict editing for non-owner/non-payee
            if (rfp.User_ID != empCode && rfp.Payee != empCode)
            {
                BtnSaveDetailsUser.Visible = false;
                ExpBtn.Visible = false;
            }

            amount_lbl.Text = rfp.Currency + " " + Convert.ToDecimal(rfp.Amount).ToString("#,##0.00");
        }

        private void ConfigureCashierSection(
            ACCEDE_T_RFPMain rfp,
            string empCode,
            ITP_S_Status pendingSapDocStatus,
            ITP_S_Status cashierPendingStatus,
            ITP_S_Status disbursedStatus,
            ITP_S_DocumentType appDocType)
        {
            var edit_SAPDoc = formRFP.FindItemOrGroupByName("edit_SAPDoc") as LayoutItem;
            var lbl_SAPDoc = formRFP.FindItemOrGroupByName("lbl_SAPDoc") as LayoutItem;
            var edit_IO = formRFP.FindItemOrGroupByName("IO_edit") as LayoutItem;
            var lbl_IO = formRFP.FindItemOrGroupByName("IO_lbl") as LayoutItem;
            var upload = formRFP.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
            var btnCash = formRFP.FindItemOrGroupByName("btnCash") as LayoutItem;
            var btnPrint = formRFP.FindItemOrGroupByName("btnPrintRFP") as LayoutItem;
            var btnSave = formRFP.FindItemOrGroupByName("BtnSaveDetails") as LayoutItem;

            // Approver verification (Cashier)
            var cashierVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                .FirstOrDefault(x => x.UserId == empCode && x.Role_Name == "Accede Cashier");

            // Pending SAP workflow activity (load once)
            ITP_T_WorkflowActivity pendingSAPDocAct = null;
            if (pendingSapDocStatus != null && appDocType != null)
            {
                pendingSAPDocAct = _DataContext.ITP_T_WorkflowActivities
                    .FirstOrDefault(x =>
                        x.Document_Id == rfp.ID &&
                        x.AppId == 1032 &&
                        x.AppDocTypeId == appDocType.DCT_Id &&
                        x.Status == pendingSapDocStatus.STS_Id);
            }

            bool showCashierControls =
                cashierVerify != null &&
                ((cashierPendingStatus != null && rfp.Status == cashierPendingStatus.STS_Id) ||
                  pendingSAPDocAct != null);

            if (showCashierControls)
            {
                if (edit_SAPDoc != null) edit_SAPDoc.ClientVisible = true;
                if (lbl_SAPDoc != null) lbl_SAPDoc.ClientVisible = false;
                if (edit_IO != null) edit_IO.ClientVisible = true;
                if (lbl_IO != null) lbl_IO.ClientVisible = false;
                if (upload != null) upload.ClientVisible = true;
                if (btnCash != null) btnCash.ClientVisible = pendingSAPDocAct == null; // hide when pending SAP doc
                if (btnSave != null) btnSave.ClientVisible = true;
            }

            if (disbursedStatus != null && rfp.Status == disbursedStatus.STS_Id)
            {
                if (btnPrint != null) btnPrint.ClientVisible = true;
                if (btnCash != null) btnCash.ClientVisible = false;
            }
        }

        #endregion

        DataSet dsDoc = null;
        protected void formRFP_Init(object sender, EventArgs e)
        {
            // (unchanged – original commented logic kept)
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

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Session["EditRFPID"] = Convert.ToInt32(Session["passRFPID"]);
            Response.Redirect("RFPEditPage.aspx");
        }

        [WebMethod]
        public static int UpdateRFPMainAjax(int status)
        {
            try
            {
                RFPViewPage rfp = new RFPViewPage();
                return rfp.UpdateRFPMain(status);
            }
            catch
            {
                return 0;
            }
        }

        public int UpdateRFPMain(int status)
        {
            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

            if (status == 1)
            {
                RFPCreationPage rfpCreatePage = new RFPCreationPage();
                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                               where app.WF_Id == Convert.ToInt32(rfp_main.WF_Id)
                               where app.Sequence == 1
                               select app;

                bool ins_wf = rfpCreatePage.InsertWorkflowAct(rfp_main.ID);
                if (!ins_wf) return 0;
            }

            rfp_main.Status = status;
            _DataContext.SubmitChanges();
            return rfp_main.ID;
        }

        private string Encrypt(string plainText)
        {
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText));
        }

        [WebMethod]
        public static object redirectExpAJAX()
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.redirectExp();
        }

        public object redirectExp()
        {
            var result = new { status = "error", link = "RFPViewPage.aspx" };
            try
            {
                if (Session["passRFPID"] == null) throw new Exception("Session 'passRFPID' is null.");
                int rfpId = Convert.ToInt32(Session["passRFPID"]);
                var rfpDetails = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.ID == rfpId);
                if (rfpDetails == null) throw new Exception("RFP details not found.");

                Session["ExpenseId"] = rfpDetails.Exp_ID;
                Session["TravelExp_Id"] = rfpDetails.Exp_ID;
                string encryptedID = Encrypt(rfpDetails.Exp_ID.ToString());
                string redirectUrl = $"AccedeInvoiceNonPOViewPage.aspx?secureToken={encryptedID}";

                if (rfpDetails.isTravel == true)
                    result = new { status = "success", link = "TravelExpenseView.aspx" };
                else if (rfpDetails.TranType == 3)
                    result = new { status = "success", link = redirectUrl };
                else
                    result = new { status = "success", link = "AccedeExpenseViewPage.aspx" };
            }
            catch { }
            return result;
        }

        [WebMethod]
        public static string SaveCashierChangesAJAX(string SAPDoc, int stats, string signatureData, string signee)
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.SaveCashierChanges(SAPDoc, stats, signatureData, signee);
        }

        public string SaveCashierChanges(string SAPDoc, int stats, string signatureData, string signee)
        {
            try
            {
                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();
                var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();
                var release_cash_status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disbursed").FirstOrDefault();
                var cashierWF = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Name == "ACDE CASHIER").Where(x => x.Company_Id == Convert.ToInt32(rfp_main.Company_ID)).FirstOrDefault();
                var cashierWFDetail = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == Convert.ToInt32(cashierWF.WF_Id)).FirstOrDefault();
                var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == Convert.ToInt32(cashierWFDetail.OrgRole_Id)).Where(x => x.UserId == Session["userID"].ToString()).FirstOrDefault();
                var pending_SAPDoc_status = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Description == "Pending SAP Doc No.")
                            .FirstOrDefault();

                rfp_main.SAPDocNo = SAPDoc;
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(Session["wfa"])).FirstOrDefault();
                var pre_wfDetStatus = wfDetails.Status.ToString();

                if (stats == 1)
                {
                    if (!string.IsNullOrEmpty(SAPDoc))
                        wfDetails.Status = release_cash_status.STS_Id;
                    else
                        wfDetails.Status = pending_SAPDoc_status.STS_Id;

                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();
                    rfp_main.Status = release_cash_status.STS_Id;

                    byte[] signatureBytes = Base64ToBytes(signatureData);
                    var existRFPSignature = _DataContext.ACCEDE_T_RFPSignatures.FirstOrDefault(x => x.RFPMain_Id == rfp_main.ID);
                    if (existRFPSignature != null)
                    {
                        existRFPSignature.RFPMain_Id = rfp_main.ID;
                        existRFPSignature.Signature = signatureBytes;
                        existRFPSignature.Signee_Fullname = signee;
                        existRFPSignature.Status_Id = release_cash_status.STS_Id;
                        existRFPSignature.DateReceived = DateTime.Now;
                    }
                    else
                    {
                        ACCEDE_T_RFPSignature sig = new ACCEDE_T_RFPSignature
                        {
                            RFPMain_Id = rfp_main.ID,
                            Signature = signatureBytes,
                            Signee_Fullname = signee,
                            Status_Id = release_cash_status.STS_Id,
                            DateReceived = DateTime.Now
                        };

                        _DataContext.ACCEDE_T_RFPSignatures.InsertOnSubmit(sig);
                    }
                }

                if (pre_wfDetStatus == pending_SAPDoc_status.STS_Id.ToString())
                {
                    if (!string.IsNullOrEmpty(SAPDoc))
                        wfDetails.Status = release_cash_status.STS_Id;
                    else
                        wfDetails.Status = pending_SAPDoc_status.STS_Id;

                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();
                }

                _DataContext.SubmitChanges();
                return "success";
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

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

            foreach (var file in UploadController.UploadedFiles)
            {
                double filesize = 0.00;
                string filesizeStr;
                if (file.ContentLength > 999999)
                {
                    filesize = file.ContentLength / 1000000d;
                    filesizeStr = filesize + " MB";
                }
                else if (file.ContentLength > 999)
                {
                    filesize = file.ContentLength / 1000d;
                    filesizeStr = filesize + " KB";
                }
                else
                {
                    filesize = file.ContentLength;
                    filesizeStr = filesize + " Bytes";
                }

                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP" && x.App_Id == 1032)
                    .FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment
                {
                    FileAttachment = file.FileBytes,
                    FileName = file.FileName,
                    Doc_ID = rfp_main.ID,
                    App_ID = 1032,
                    DocType_Id = app_docType != null ? app_docType.DCT_Id : 0,
                    User_ID = Session["userID"].ToString(),
                    FileExtension = file.FileName.Split('.').Last(),
                    Description = file.FileName.Split('.').First(),
                    FileSize = filesizeStr,
                    Doc_No = rfp_main.RFP_DocNum.ToString(),
                    Company_ID = Convert.ToInt32(rfp_main.ChargedTo_CompanyId),
                    DateUploaded = DateTime.Now
                };

                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }

            _DataContext.SubmitChanges();
            SqlRFPDocs.DataBind();
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/RFPPrintPage.aspx");
        }

        protected void DocuGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnRemove")
            {
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "User_ID");
                e.Visible = (statusValue != null && statusValue.ToString() == Session["userID"].ToString())
                    ? DevExpress.Utils.DefaultBoolean.True
                    : DevExpress.Utils.DefaultBoolean.False;
            }

            if (e.VisibleIndex >= 0 && e.ButtonID == "btnDownload")
            {
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "isExist");
                e.Visible = (statusValue != null && Convert.ToBoolean(statusValue))
                    ? DevExpress.Utils.DefaultBoolean.True
                    : DevExpress.Utils.DefaultBoolean.False;
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

        [WebMethod]
        public static string SaveCreatorChangesAJAX()
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.SaveCreatorChanges();
        }

        public string SaveCreatorChanges()
        {
            try
            {
                var rfp_details = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();
                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" && x.App_Id == 1032).FirstOrDefault();

                DataSet dsFile = (DataSet)Session["DataSetDoc"];
                if (dsFile == null) return "success";
                DataTable dataTable = dsFile.Tables[0];

                if (dataTable.Rows.Count > 0)
                {
                    string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                    string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                    using (SqlConnection connection = new SqlConnection(connectionString1))
                    using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                    {
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

                        connection.Open();
                        foreach (DataRow row in dataTable.Rows)
                        {
                            if (Convert.ToBoolean(row["isExist"]) == false)
                            {
                                command.Parameters["@filename"].Value = row["FileName"];
                                command.Parameters["@file_byte"].Value = row["FileByte"];
                                command.Parameters["@desc"].Value = row["FileDesc"];
                                command.Parameters["@date_upload"].Value = DateTime.Now;
                                command.Parameters["@app_id"].Value = 1032;
                                command.Parameters["@comp_id"].Value = rfp_details.Company_ID;
                                command.Parameters["@doc_id"].Value = rfp_details.ID;
                                command.Parameters["@doc_no"].Value = rfp_details.RFP_DocNum;
                                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                                command.Parameters["@fileExt"].Value = row["FileExt"];
                                command.Parameters["@filesize"].Value = row["FileSize"];
                                command.Parameters["@docType"].Value = app_docType != null ? app_docType.DCT_Id : 0;
                                command.ExecuteNonQuery();
                            }
                        }
                        connection.Close();
                    }
                }
                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

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

            if (new[] { "png", "jpg", "jpeg", "gif", "JPEG", "JPG", "PNG", "GIF" }.Contains(contentType))
            {
                string base64String = Convert.ToBase64String(bytes);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }

        [WebMethod]
        public static string RecallRFPMainAJAX(string remarks)
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.RecallRFPMain(remarks);
        }

        public string RecallRFPMain(string remarks)
        {
            try
            {
                string remarksInput = remarks.Trim();
                var doc_id = Convert.ToInt32(Session["passRFPID"]);
                int approver_org_id = 0;
                var rfpDoctype = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").FirstOrDefault();

                if (!string.IsNullOrEmpty(remarksInput))
                {
                    foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.Document_Id == doc_id && x.AppDocTypeId == rfpDoctype.DCT_Id && x.AppId == 1032 && x.Status == 1))
                    {
                        rs.Status = 15;
                        rs.DateAction = DateTime.Now;
                        rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                        approver_org_id = Convert.ToInt32(rs.OrgRole_Id);
                    }

                    int comp_id = 0;
                    string doc_no = "";
                    string date_created = "";
                    string document_purpose = "";
                    string creator_email = "";
                    string creator_fullname = "";
                    string approver_id = "";
                    string payMethod = "";
                    string tranType = "";

                    foreach (var item in _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == doc_id))
                    {
                        item.Status = 15;
                        comp_id = Convert.ToInt32(item.Company_ID);
                        doc_no = item.RFP_DocNum;
                        date_created = item.DateCreated.ToString();
                        document_purpose = item.Purpose;
                        approver_id = _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == approver_org_id).FirstOrDefault().UserId;
                        creator_fullname = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.User_ID).FirstOrDefault().FullName;
                        creator_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.User_ID).FirstOrDefault().Email;

                        if (item.PayMethod != null)
                            payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == item.PayMethod).FirstOrDefault()?.PMethod_name;

                        if (item.TranType != null)
                            tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == item.TranType).FirstOrDefault()?.RFPTranType_Name;
                    }
                    _DataContext.SubmitChanges();

                    foreach (var item in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == approver_org_id))
                    {
                        SendEmailToApprover(approver_id, comp_id, creator_fullname, creator_email, doc_no, date_created, document_purpose, payMethod, tranType, remarks, "Recalled");
                    }
                }

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public bool SendEmailToApprover(string approver_id, int Comp_id, string creator_fullname, string creator_email, string doc_no, string date_created, string document_purpose, string payMethod, string tranType, string remarks, string status)
        {
            try
            {
                var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == approver_id).FirstOrDefault();
                var comp_name = _DataContext.CompanyMasters.Where(x => x.WASSId == Comp_id).FirstOrDefault();

                var queryText = from texts in _DataContext.ITP_S_Texts
                                where texts.Type == "Email" && texts.Name == status
                                select texts;

                string emailMessage = "";
                string emailSubMessage = "";
                string emailColor = "";
                string emailSubjectText3 = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = text.Text2;
                    emailColor = text.Color;
                    emailMessage = text.Text1;
                    if (text.Text3 != null) emailSubjectText3 = text.Text3;
                }

                string appName = "Request For Payment (RFP)";
                string recipientName = user_email.FName;
                string senderName = creator_fullname;
                string emailSender = creator_email;
                string emailSite = "https://apps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": " + emailSubjectText3;

                ANFLO anflo = new ANFLO();

                string emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' style='border-collapse:separate;background:#fff;border-radius:3px;width:100%;'>" +
                                      "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>" +
                                      "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>" +
                                      "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>" +
                                      "<tr><td>Requestor</td><td><strong>" + senderName + "</strong></td></tr>" +
                                      "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>" +
                                      "<tr><td>Transaction Type</td><td><strong>" + tranType + "</strong></td></tr>" +
                                      "<tr><td>Status</td><td><strong>Pending</strong></td></tr>" +
                                      "<tr><td>Document Purpose</td><td><strong>" + document_purpose + "</strong></td></tr>" +
                                      "</table><br>";

                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, remarks, emailSite, emailColor);
                return anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo);
            }
            catch
            {
                return false;
            }
        }

        protected void DocuGrid_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "User_ID" && e.CellValue != null)
            {
                var emp = _DataContext.ITP_S_UserMasters.FirstOrDefault(x => x.EmpCode == e.CellValue.ToString());
                if (emp != null)
                    e.Cell.Text = emp.FullName;
            }
        }

        [WebMethod]
        public static string CheckSAPVAlidAJAX(string SAPDoc)
        {
            RFPViewPage page = new RFPViewPage();
            return page.CheckSAPVAlid(SAPDoc);
        }

        public string CheckSAPVAlid(string SAPDoc)
        {
            var rfpMain = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.ID == Convert.ToInt32(Session["passRFPID"]));
            var rfpCheck = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.SAPDocNo == SAPDoc);

            if (rfpCheck != null && SAPDoc != rfpMain.SAPDocNo)
                return "error";
            return "clear";
        }
    }
}