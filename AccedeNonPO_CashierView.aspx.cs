using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeNonPOEditPage;

namespace DX_WebTemplate
{
    public partial class AccedeNonPO_CashierView : System.Web.UI.Page
    {
        private ITPORTALDataContext _DataContext = new ITPORTALDataContext(
            ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        // Simple cache keys
        private const string CacheKey_Statuses = "ACCEDE_CachedStatuses";
        private const string CacheKey_DocTypes = "ACCEDE_CachedDocTypes";

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!AnfloSession.Current.ValidCookieUser())
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                if (IsPostBack) return;

                var encryptedID = Request.QueryString["secureToken"];
                if (string.IsNullOrEmpty(encryptedID))
                {
                    Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                    return;
                }

                string decrypted = SafeDecrypt(encryptedID);
                if (!int.TryParse(decrypted, out int actID))
                {
                    Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                    return;
                }

                InitializePage(actID);
            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        // OPTIMIZATION: Safe decrypt wrapper
        private string SafeDecrypt(string encrypted)
        {
            try
            {
                return Decrypt(encrypted);
            }
            catch
            {
                return "";
            }
        }

        private void InitializePage(int actID)
        {
            // Fix for CS1931: The range variable 'inv' conflicts with a previous declaration of 'inv'.
            // The issue occurs because the variable name 'inv' is already used in the same scope.
            // To resolve this, we rename the conflicting variable to a unique name.

            var wfAndInv = (from w in _DataContext.ITP_T_WorkflowActivities
                            join invoice in _DataContext.ACCEDE_T_InvoiceMains on w.Document_Id equals invoice.ID
                            where w.WFA_Id == actID
                            select new
                            {
                                Workflow = w,
                                Invoice = invoice
                            }).FirstOrDefault();

            if (wfAndInv == null)
            {
                Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                return;
            }

            var wf = wfAndInv.Workflow;
            var inv = wfAndInv.Invoice;

            // Cache + load needed Status names
            var neededStatusNames = new[] { "Pending at Cashier", "Pending at Audit", "Complete" };
            var statuses = GetCachedStatuses()
                .Where(s => neededStatusNames.Contains(s.STS_Name))
                .ToDictionary(s => s.STS_Name, s => s);

            // Cache + load document types (RFP + InvoiceNPO)
            var docTypes = GetCachedDocTypes()
                .Where(d => d.App_Id == 1032 &&
                            (d.DCT_Name == "ACDE InvoiceNPO" || d.DCT_Name == "ACDE RFP"))
                .ToDictionary(d => d.DCT_Name, d => d);

            ITP_S_DocumentType invDocType;
            docTypes.TryGetValue("ACDE InvoiceNPO", out invDocType);

            // Set all SqlDataSource parameters (only once)
            string invIdStr = inv.ID.ToString();
            string docTypeIdStr = (invDocType != null ? invDocType.DCT_Id.ToString() : null);

            sqlMain.SelectParameters["ID"].DefaultValue = invIdStr;
            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = wf.Document_Id.ToString();
            SqlDocs.SelectParameters["DocType_Id"].DefaultValue = docTypeIdStr;
            SqlCA.SelectParameters["Exp_ID"].DefaultValue = invIdStr;
            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = invIdStr;
            SqlExpDetails.SelectParameters["InvMain_ID"].DefaultValue = invIdStr;
            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = invIdStr;
            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = (inv.WF_Id ?? 0).ToString();
            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = (inv.FAPWF_Id ?? 0).ToString();

            // UI: Layout caption
            var layoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
            if (layoutGroup != null)
            {
                layoutGroup.Caption = "Invoice Document - " + (inv.DocNo ?? "") + " (View)";
            }

            // Vendor handling (OPTIMIZATION: avoid loading all vendors)
            string vendorCodeClean = (inv.VendorName ?? "").Replace("\r", "").Replace("\n", "").Trim();
            //var payee = TryGetVendorByCode(vendorCodeClean);
            // If needed later: assign UI field (kept commented because original was commented)
            // txt_Vendor.Text = payee?.VendorName ?? "";

            // Expense total via DB SUM
            decimal totalExp = _DataContext.ACCEDE_T_InvoiceLineDetails
                .Where(x => x.InvMain_ID == inv.ID)
                .Select(x => (decimal?)x.NetAmount).Sum() ?? 0m;
            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";

            txt_InvoiceNo.Text = inv.InvoiceNo ?? "";

            // Disburse button visibility
            LayoutItem btnDisburse = FormExpApprovalView.FindItemOrGroupByName("disburseBtn") as LayoutItem;
            if (btnDisburse != null &&
                statuses.ContainsKey("Pending at Cashier") &&
                inv.Status == statuses["Pending at Cashier"].STS_Id)
            {
                btnDisburse.ClientVisible = true;
            }

            // RFP main retrieval
            var rfpMain = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x =>
                x.Exp_ID == inv.ID &&
                x.Status != 4 &&
                x.IsExpenseReim != true &&
                x.IsExpenseCA != true &&
                x.isTravel != true);

            if (rfpMain == null)
            {
                var reimItem = FormExpApprovalView.FindItemOrGroupByName("reimItem") as LayoutItem;
                if (reimItem != null) reimItem.ClientVisible = true;
            }
            else
            {
                var reimLayout = FormExpApprovalView.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                if (reimLayout != null)
                {
                    reimLayout.ClientVisible = true;
                    link_rfp.Value = rfpMain.RFP_DocNum;
                }
                txt_SAPDoc.Text = rfpMain.SAPDocNo ?? "";
            }
        }

        // OPTIMIZATION: vendor lookup specialization (fallback to existing bulk call)
        private dynamic TryGetVendorByCode(string vendorCode)
        {
            if (string.IsNullOrEmpty(vendorCode)) return null;

            // If a specialized method exists, prefer it:
            // return SAPVendor.GetVendorByCode(vendorCode);

            // Fallback: still reduces memory by filtering before GroupBy if implementation supports predicate
            var allVendors = SAPVendor.GetVendorData(vendorCode); // Suggest modifying this to accept filter
            var result = allVendors
                .Where(v => v.VENDCODE == vendorCode)
                .GroupBy(v => new { v.VENDCODE, v.VENDNAME })
                .Select(g => g.First())
                .FirstOrDefault();
            return result;
        }

        private IEnumerable<ITP_S_Status> GetCachedStatuses()
        {
            var cache = HttpRuntime.Cache[CacheKey_Statuses] as List<ITP_S_Status>;
            if (cache == null)
            {
                cache = _DataContext.ITP_S_Status.ToList();
                HttpRuntime.Cache.Insert(CacheKey_Statuses, cache, null, DateTime.Now.AddMinutes(10), TimeSpan.Zero);
            }
            return cache;
        }

        private IEnumerable<ITP_S_DocumentType> GetCachedDocTypes()
        {
            var cache = HttpRuntime.Cache[CacheKey_DocTypes] as List<ITP_S_DocumentType>;
            if (cache == null)
            {
                cache = _DataContext.ITP_S_DocumentTypes.ToList();
                HttpRuntime.Cache.Insert(CacheKey_DocTypes, cache, null, DateTime.Now.AddMinutes(30), TimeSpan.Zero);
            }
            return cache;
        }

        private string Decrypt(string encryptedText)
        {
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        [WebMethod]
        public static string DisburseAJAX(string secureToken, string signatureData, string signee)
        {
            // OPTIMIZATION: Do not instantiate Page; use a lightweight handler pattern
            var ctx = new ITPORTALDataContext(
                ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
            return DisburseInternal(ctx, secureToken, signatureData, signee);
        }

        private static string DisburseInternal(ITPORTALDataContext dc, string secureToken, string signatureData, string signee)
        {
            try
            {
                if (string.IsNullOrEmpty(secureToken)) return "Secure token is empty.";

                int actID = Convert.ToInt32(System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(secureToken)));

                var wfDetails = dc.ITP_T_WorkflowActivities.FirstOrDefault(x => x.WFA_Id == actID);
                if (wfDetails == null) return "Workflow not found.";

                var rfp_main = dc.ACCEDE_T_RFPMains.FirstOrDefault(x =>
                    x.Exp_ID == wfDetails.Document_Id &&
                    x.Status != 4 &&
                    x.IsExpenseReim != true &&
                    x.IsExpenseCA != true &&
                    x.isTravel != true);

                var inv_main = dc.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == wfDetails.Document_Id);
                if (inv_main == null || rfp_main == null) return "Related document missing.";

                var release_cash_status = dc.ITP_S_Status.FirstOrDefault(x => x.STS_Description == "Disbursed");
                var completed_status = dc.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Complete");
                var rfp_app_docType = dc.ITP_S_DocumentTypes.FirstOrDefault(x => x.DCT_Name == "ACDE RFP" && x.App_Id == 1032);

                var reimActDetails = (rfp_app_docType != null)
                    ? dc.ITP_T_WorkflowActivities.FirstOrDefault(x =>
                        x.AppDocTypeId == rfp_app_docType.DCT_Id &&
                        x.AppId == 1032 &&
                        x.Document_Id == rfp_main.ID &&
                        x.Status == wfDetails.Status)
                    : null;

                if (release_cash_status == null || completed_status == null)
                    return "Status configuration missing.";

                // Update workflow
                wfDetails.DateAction = DateTime.Now;
                wfDetails.Remarks = (HttpContext.Current != null && HttpContext.Current.Session != null
                    ? (HttpContext.Current.Session["AuthUser"] + ": ;")
                    : ";");
                if (HttpContext.Current != null && HttpContext.Current.Session != null)
                    wfDetails.ActedBy_User_Id = Convert.ToString(HttpContext.Current.Session["userID"]);
                wfDetails.Status = release_cash_status.STS_Id;

                if (reimActDetails != null)
                {
                    reimActDetails.Status = release_cash_status.STS_Id;
                    reimActDetails.DateAction = DateTime.Now;
                    if (HttpContext.Current != null && HttpContext.Current.Session != null)
                        reimActDetails.ActedBy_User_Id = Convert.ToString(HttpContext.Current.Session["userID"]);
                }

                inv_main.Status = completed_status.STS_Id;
                rfp_main.Status = release_cash_status.STS_Id;

                byte[] signatureBytes = Base64ToBytes(signatureData);
                var existRFPSignature = dc.ACCEDE_T_RFPSignatures.FirstOrDefault(x => x.RFPMain_Id == rfp_main.ID);
                if(existRFPSignature != null)
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

                    dc.ACCEDE_T_RFPSignatures.InsertOnSubmit(sig);
                }

                if (HttpContext.Current != null && HttpContext.Current.Session != null)
                    HttpContext.Current.Session["passRFPID"] = rfp_main.ID.ToString();
                
                dc.SubmitChanges();
                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public string Disburse(string secureToken, string signatureData, string signee)
        {
            // Preserve original instance method for backward compatibility
            return DisburseInternal(_DataContext, secureToken, signatureData, signee);
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (string.IsNullOrEmpty(encryptedID)) return;

            string decrypted = SafeDecrypt(encryptedID);
            int actID;
            if (!int.TryParse(decrypted, out actID)) return;

            var actDetails = _DataContext.ITP_T_WorkflowActivities.FirstOrDefault(x => x.WFA_Id == actID);
            if (actDetails == null) return;

            var rfp_main = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x =>
                x.Exp_ID == actDetails.Document_Id &&
                x.Status != 4 &&
                x.IsExpenseReim != true &&
                x.IsExpenseCA != true &&
                x.isTravel != true);

            if (rfp_main == null) return;

            Session["passRFPID"] = rfp_main.ID.ToString();
            Response.Redirect("~/RFPPrintPage.aspx");
        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (string.IsNullOrEmpty(encryptedID)) return;

            string decrypted = SafeDecrypt(encryptedID);
            int actID;
            if (!int.TryParse(decrypted, out actID)) return;

            var actDetails = _DataContext.ITP_T_WorkflowActivities.FirstOrDefault(x => x.WFA_Id == actID);
            if (actDetails == null) return;

            var invMain = _DataContext.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == actDetails.Document_Id);
            if (invMain == null) return;

            var invDocType = _DataContext.ITP_S_DocumentTypes
                .FirstOrDefault(x => x.DCT_Name == "ACDE InvoiceNPO" && x.App_Id == 1032);

            foreach (var uploadedFile in UploadController.UploadedFiles) // Renamed 'file' to 'uploadedFile'
            {
                string fileSizeStr;
                long len = uploadedFile.ContentLength; // Changed type from int to long to match ContentLength property
                if (len > 999999)
                    fileSizeStr = (len / 1000000) + " MB";
                else if (len > 999)
                    fileSizeStr = (len / 1000) + " KB";
                else
                    fileSizeStr = len + " Bytes";

                var docs = new ITP_T_FileAttachment
                {
                    FileAttachment = uploadedFile.FileBytes,
                    FileName = uploadedFile.FileName,
                    Doc_ID = Convert.ToInt32(Session["NonPOExpenseId"]),
                    App_ID = 1032,
                    DocType_Id = invDocType != null ? invDocType.DCT_Id : 0,
                    User_ID = Convert.ToString(Session["userID"]),
                    FileExtension = uploadedFile.FileName.Contains(".") ? uploadedFile.FileName.Split('.').Last() : "",
                    Description = uploadedFile.FileName.Contains(".") ? uploadedFile.FileName.Substring(0, uploadedFile.FileName.LastIndexOf('.')) : uploadedFile.FileName,
                    FileSize = fileSizeStr,
                    Doc_No = Convert.ToString(Session["DocNo"]),
                    Company_ID = Convert.ToInt32(invMain.InvChargedTo_CompanyId),
                    DateUploaded = DateTime.Now
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }

            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
            DocumentGrid.DataBind();
        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = e.Parameters;
            SqlExpMap.DataBind();
            ExpAllocGrid.DataBind();
        }

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpDetailAttach.SelectParameters["ExpDetail_Id"].DefaultValue = e.Parameters;
            SqlExpDetailAttach.DataBind();
            DocuGrid1.DataBind();
        }

        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            var ctx = new ITPORTALDataContext(
                ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
            return DisplayExpDetailsInternal(ctx, expDetailID);
        }

        private static InvDetailsNonPO DisplayExpDetailsInternal(ITPORTALDataContext dc, int invDetailID)
        {
            var invDetails = dc.ACCEDE_T_InvoiceLineDetails.FirstOrDefault(x => x.ID == invDetailID);
            if (invDetails == null) return new InvDetailsNonPO();

            var particularsName = dc.ACCEDE_S_Particulars
                .Where(x => x.ID == invDetails.Particulars)
                .Select(x => x.P_Name)
                .FirstOrDefault();

            decimal allocated = dc.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(x => x.InvoiceReportDetail_ID == invDetailID)
                .Select(x => (decimal?)x.NetAmount).Sum() ?? 0m;

            decimal remaining = (invDetails.TotalAmount ?? 0m) - allocated;

            var dto = new InvDetailsNonPO
            {
                dateAdded = invDetails.DateAdded.HasValue ? invDetails.DateAdded.Value.ToString("MM/dd/yyyy hh:mm:ss") : "",
                particulars = particularsName ?? "",
                acctCharge = Convert.ToInt32(invDetails.AcctToCharged),
                InvoiceOR = invDetails.InvoiceNo ?? "",
                grossAmnt = invDetails.TotalAmount ?? 0m,
                netAmnt = invDetails.NetAmount ?? 0m,
                expMainId = invDetails.InvMain_ID ?? 0,
                preparerId = invDetails.Preparer_ID ?? "",
                LineDesc = invDetails.LineDescription ?? "",
                Qty = invDetails.Qty ?? 0m,
                UnitPrice = invDetails.UnitPrice ?? 0m,
                uom = invDetails.UOM ?? "",
                ewt = invDetails.EWT ?? 0m,
                vat = invDetails.VAT ?? 0m,
                ewtperc = invDetails.EWTPerc ?? 0m,
                netvat = invDetails.NOVAT ?? 0m,
                isVatCompute = invDetails.isVatComputed ?? false,
                totalAllocAmnt = remaining
            };

            if (HttpContext.Current != null && HttpContext.Current.Session != null)
                HttpContext.Current.Session["InvDetailsID"] = invDetailID.ToString();

            return dto;
        }

        public InvDetailsNonPO DisplayExpDetails(int invDetailID)
        {
            return DisplayExpDetailsInternal(_DataContext, invDetailID);
        }
        // Add the following helper method to resolve the CS0103 error for 'Base64ToBytes'.


        public static byte[] Base64ToBytes(string base64String)
        {
            // Remove the data URL prefix if present
            if (base64String.Contains(","))
            {
                base64String = base64String.Substring(base64String.IndexOf(",") + 1);
            }

            return Convert.FromBase64String(base64String);
        }
    }
}