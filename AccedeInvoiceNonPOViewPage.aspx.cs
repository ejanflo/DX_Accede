using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Linq;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeModels;
using static DX_WebTemplate.AccedeNonPOEditPage;

namespace DX_WebTemplate
{
    public partial class AccedeInvoiceNonPOViewPage : System.Web.UI.Page
    {
        private readonly ITPORTALDataContext _DataContext =
            new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        private const string DocTypeInvoiceNPO = "ACDE InvoiceNPO";
        private const string DocTypeRFP = "ACDE RFP";
        private const int AppIdAccede = 1032;

        // Vendor cache (left as in original – re‑enable if necessary)
        private static Dictionary<string, VendorSet> _vendorCache;
        private static readonly object _vendorLock = new object();

        // Lookup caching
        private static readonly object _cacheLock = new object();
        private static int? _invoiceDocTypeId;
        private static Dictionary<string, int> _statusNameToId; // name -> id
        private static DateTime _lastLookupRefresh = DateTime.MinValue;
        private const int LookupCacheMinutes = 10;
        private static readonly string[] _neededStatuses = { "Returned by Audit", "Returned by P2P", "Pending at Audit" };

        // Compiled queries
        private static readonly Func<ITPORTALDataContext, int, ACCEDE_T_InvoiceMain> CQ_GetInvoiceMain =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int id) =>
                ctx.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == id));

        private static readonly Func<ITPORTALDataContext, int, decimal?> CQ_GetInvoiceLineNetSum =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int invId) =>
                ctx.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == invId)
                    .Select(x => (decimal?)x.NetAmount)
                    .Sum());

        private static readonly Func<ITPORTALDataContext, int, ACCEDE_T_RFPMain> CQ_GetRelatedRFP =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int invId) =>
                ctx.ACCEDE_T_RFPMains.FirstOrDefault(x =>
                    (x.IsExpenseReim ?? false) == false &&
                    (x.IsExpenseCA ?? false) == false &&
                    (x.isTravel ?? false) == false &&
                    x.Status != 4 &&
                    x.Exp_ID == invId));

        protected void Page_Load(object sender, EventArgs e)
        {
            var sw = Stopwatch.StartNew();
            try
            {
                // Authentication / session pre-checks
                if (!AnfloSession.Current.ValidCookieUser())
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }
                AnfloSession.Current.CreateSession(HttpContext.Current.User?.ToString() ?? string.Empty);

                if (IsPostBack) return;

                string encryptedID = Request.QueryString["secureToken"];
                if (string.IsNullOrWhiteSpace(encryptedID))
                {
                    Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                    return;
                }

                var userIdSession = Session["userID"];
                if (userIdSession == null)
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }
                string empCode = userIdSession.ToString();

                if (!TryDecryptToInt(encryptedID, out int invID))
                {
                    Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                    return;
                }

                // Main invoice
                var inv = CQ_GetInvoiceMain(_DataContext, invID);
                if (inv == null)
                {
                    Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                    return;
                }

                // Ensure cached lookups (document type + statuses)
                EnsureLookups(_DataContext);

                // Configure data source parameters (only once)
                string invIdStr = inv.ID.ToString();
                sqlMain.SelectParameters["ID"].DefaultValue = invIdStr;
                SqlDocs.SelectParameters["Doc_ID"].DefaultValue = invIdStr;
                if (_invoiceDocTypeId.HasValue)
                    SqlDocs.SelectParameters["DocType_Id"].DefaultValue = _invoiceDocTypeId.Value.ToString();

                SqlCA.SelectParameters["Exp_ID"].DefaultValue = invIdStr;
                SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = invIdStr;
                SqlExpDetails.SelectParameters["InvMain_ID"].DefaultValue = invIdStr;
                SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = invIdStr;
                if (inv.WF_Id.HasValue)
                    SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = inv.WF_Id.Value.ToString();
                if (inv.FAPWF_Id.HasValue)
                    SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = inv.FAPWF_Id.Value.ToString();

                string statusIdStr = inv.Status?.ToString() ?? string.Empty;
                string invoiceUserId = inv.UserId;

                // Layout controls
                var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                var btnRecall = FormExpApprovalView.FindItemOrGroupByName("recallBtn") as LayoutItem;
                var btnEdit = FormExpApprovalView.FindItemOrGroupByName("edit_btn") as LayoutItem;

                if (myLayoutGroup != null)
                    myLayoutGroup.Caption = $"Invoice Document - {inv.DocNo} (View)";

                // Vendor name (optional cache) – left disabled as in original
                txt_TranType.Text = "Payment To Vendor";

                // Aggregate net (single DB call via compiled query)
                decimal totalExp = CQ_GetInvoiceLineNetSum(_DataContext, inv.ID) ?? 0m;
                expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";

                // Status logic
                _statusNameToId.TryGetValue("Returned by Audit", out int returnAuditId);
                _statusNameToId.TryGetValue("Returned by P2P", out int returnP2PId);
                _statusNameToId.TryGetValue("Pending at Audit", out int pendingAuditId);

                bool statusMatches(string wanted) =>
                    _statusNameToId.TryGetValue(wanted, out int id) && statusIdStr == id.ToString();

                bool canEdit =
                    statusIdStr == "3" ||
                    statusIdStr == "13" ||
                    statusIdStr == "15" ||
                    statusMatches("Returned by Audit") ||
                    (statusMatches("Returned by P2P") && invoiceUserId == empCode);

                if (canEdit && btnEdit != null)
                    btnEdit.ClientVisible = true;

                if (statusMatches("Pending at Audit"))
                {
                    var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                    if (print != null) print.ClientVisible = true;
                }

                if (statusIdStr == "1" && invoiceUserId == empCode && btnRecall != null)
                    btnRecall.ClientVisible = true;

                // Related RFP lookup (compiled)
                var relatedRfp = CQ_GetRelatedRFP(_DataContext, inv.ID);
                if (relatedRfp == null)
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
                        link_rfp.Value = relatedRfp.RFP_DocNum;
                    }
                    txt_SAPDoc.Text = relatedRfp.SAPDocNo ?? string.Empty;
                }
            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }
            finally
            {
                sw.Stop();
                // Optional: inspect in DebugView / Trace listener
                Debug.WriteLine($"[Perf] AccedeInvoiceNonPOViewPage.Page_Load elapsed: {sw.ElapsedMilliseconds} ms");
            }
        }

        private static void EnsureLookups(ITPORTALDataContext ctx)
        {
            if ((DateTime.UtcNow - _lastLookupRefresh).TotalMinutes < LookupCacheMinutes
                && _invoiceDocTypeId.HasValue
                && _statusNameToId != null)
                return;

            lock (_cacheLock)
            {
                if ((DateTime.UtcNow - _lastLookupRefresh).TotalMinutes < LookupCacheMinutes
                    && _invoiceDocTypeId.HasValue
                    && _statusNameToId != null)
                    return;

                // Document type id
                _invoiceDocTypeId = ctx.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == DocTypeInvoiceNPO && x.App_Id == AppIdAccede)
                    .Select(x => (int?)x.DCT_Id)
                    .FirstOrDefault();

                // Status ids (tolerant if some missing)
                _statusNameToId = ctx.ITP_S_Status
                    .Where(s => _neededStatuses.Contains(s.STS_Name))
                    .Select(s => new { s.STS_Name, s.STS_Id })
                    .ToDictionary(x => x.STS_Name, x => x.STS_Id);

                _lastLookupRefresh = DateTime.UtcNow;
            }
        }

        private bool TryDecryptToInt(string secureToken, out int value)
        {
            value = 0;
            try
            {
                var decoded = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(secureToken));
                return int.TryParse(decoded, out value);
            }
            catch { return false; }
        }

        private string Decrypt(string encryptedText)
        {
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        public static string FormatDecimal(decimal value)
        {
            return value < 0
                ? $"({Math.Abs(value):#,##0.00})"
                : value.ToString("#,##0.00");
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (string.IsNullOrEmpty(encryptedID)) return;
            if (!TryDecryptToInt(encryptedID, out int expID)) return;

            Session["cID"] = expID;
            Response.Redirect("~/AccedeExpenseReportPrinting.aspx");
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
            string fileName;
            string contentType;
            string constr = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            using (SqlCommand cmd = new SqlCommand("SELECT FileName, FileAttachment, FileExtension FROM ITP_T_FileAttachment WHERE ID = @fileId AND App_ID = @appId", con))
            {
                cmd.Parameters.AddWithValue("@fileId", Convert.ToInt32(fileId));
                cmd.Parameters.AddWithValue("@appId", Convert.ToInt32(appId));
                con.Open();
                using (var sdr = cmd.ExecuteReader())
                {
                    if (!sdr.Read())
                        return null;
                    bytes = (byte[])sdr["FileAttachment"];
                    contentType = sdr["FileExtension"].ToString();
                    fileName = sdr["FileName"].ToString();
                }
            }

            bool isImage = new[] { "png", "jpg", "jpeg", "gif" }
                .Any(ext => string.Equals(ext, contentType, StringComparison.OrdinalIgnoreCase));

            if (isImage)
            {
                string base64String = Convert.ToBase64String(bytes);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }

        [WebMethod]
        public static string RecallExpMainAJAX(string remarks, string secureToken)
        {
            AccedeInvoiceNonPOViewPage exp = new AccedeInvoiceNonPOViewPage();
            return exp.RecallExpMain(remarks, secureToken);
        }

        public string RecallExpMain(string remarks, string secureToken)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(secureToken))
                    return "Secure token is null. Please refresh page.";

                if (!TryDecryptToInt(secureToken, out int expID))
                    return "Invalid secure token.";

                string remarksInput = (remarks ?? "").Trim();
                if (string.IsNullOrEmpty(remarksInput))
                    return "Remarks required.";

                var expDocType = _DataContext.ITP_S_DocumentTypes.FirstOrDefault(x => x.DCT_Name == DocTypeInvoiceNPO);
                if (expDocType == null) return "Document type not found.";

                var wfActivities = _DataContext.ITP_T_WorkflowActivities
                    .Where(x => x.Document_Id == expID && x.AppDocTypeId == expDocType.DCT_Id && x.AppId == AppIdAccede && x.Status == 1)
                    .ToList();

                int approver_org_id = 0;
                foreach (var wf in wfActivities)
                {
                    wf.Status = 15;
                    wf.DateAction = DateTime.Now;
                    wf.Remarks = $"{Session["AuthUser"]}: {remarksInput}";
                    if (wf.OrgRole_Id.HasValue)
                        approver_org_id = wf.OrgRole_Id.Value;
                }

                var ptvRFP = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x =>
                    (x.IsExpenseReim ?? false) == false &&
                    (x.IsExpenseCA ?? false) == false &&
                    (x.isTravel ?? false) == false &&
                    x.Status != 4 &&
                    x.Exp_ID == expID);

                if (ptvRFP != null)
                {
                    ptvRFP.Status = 15;
                    var rfpDocType = _DataContext.ITP_S_DocumentTypes.FirstOrDefault(x => x.DCT_Name == DocTypeRFP);
                    if (rfpDocType != null)
                    {
                        var rfpActs = _DataContext.ITP_T_WorkflowActivities
                            .Where(x => x.Document_Id == ptvRFP.ID && x.AppDocTypeId == rfpDocType.DCT_Id && x.AppId == AppIdAccede && x.Status == 1)
                            .ToList();
                        foreach (var r in rfpActs)
                        {
                            r.Status = 15;
                            r.DateAction = DateTime.Now;
                            r.Remarks = $"{Session["AuthUser"]}: {remarksInput}";
                        }
                    }
                }

                var invoice = _DataContext.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == expID);
                if (invoice == null) return "Invoice not found.";
                invoice.Status = 15;

                var approverUser = approver_org_id != 0
                    ? _DataContext.ITP_S_SecurityUserOrgRoles.FirstOrDefault(x => x.OrgRoleId == approver_org_id)
                    : null;

                var creator = _DataContext.ITP_S_UserMasters.FirstOrDefault(x => x.EmpCode == invoice.UserId);
                var payMethodName = (invoice.PaymentType.HasValue && invoice.PaymentType != 0)
                    ? _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == invoice.PaymentType).Select(x => x.PMethod_name).FirstOrDefault()
                    : string.Empty;

                var tranTypeName = (invoice.InvoiceType_ID.HasValue && invoice.InvoiceType_ID != 0)
                    ? _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == invoice.InvoiceType_ID).Select(x => x.Description).FirstOrDefault()
                    : string.Empty;

                _DataContext.SubmitChanges();

                if (approverUser != null)
                {
                    var allRoleUsers = _DataContext.ITP_S_SecurityUserOrgRoles
                        .Where(x => x.OrgRoleId == approver_org_id)
                        .ToList();

                    foreach (var roleUser in allRoleUsers)
                    {
                        RFPViewPage expPage = new RFPViewPage();
                        expPage.SendEmailToApprover(
                            approverUser.UserId,
                            Convert.ToInt32(invoice.CompanyId),
                            creator?.FullName ?? "",
                            creator?.Email ?? "",
                            invoice.DocNo,
                            invoice.DateCreated.ToString(),
                            invoice.Purpose,
                            payMethodName,
                            tranTypeName,
                            remarksInput,
                            "Recalled");
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
        public static string RedirectToEditAJAX(string secureToken)
        {
            AccedeInvoiceNonPOViewPage page = new AccedeInvoiceNonPOViewPage();
            return page.RedirectToEdit(secureToken);
        }

        public string RedirectToEdit(string secureToken)
        {
            if (string.IsNullOrWhiteSpace(secureToken))
                return "Secure Token is null. Please refresh the page or login again.";

            if (!TryDecryptToInt(secureToken, out int expID))
                return "Invalid token.";

            Session["NonPOExpenseId"] = expID;
            return "success";
        }

        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeInvoiceNonPOViewPage exp = new AccedeInvoiceNonPOViewPage();
            return exp.DisplayExpDetails(expDetailID);
        }

        public InvDetailsNonPO DisplayExpDetails(int invDetailID)
        {
            var invDetails = _DataContext.ACCEDE_T_InvoiceLineDetails.FirstOrDefault(x => x.ID == invDetailID);
            if (invDetails == null) return new InvDetailsNonPO();

            var particularsName = _DataContext.ACCEDE_S_Particulars
                .Where(x => x.ID == invDetails.Particulars)
                .Select(x => x.P_Name)
                .FirstOrDefault();

            decimal allocated = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
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

            Session["InvDetailsID"] = invDetailID.ToString();
            return dto;
        }

        protected void CAWFActivityGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAWFActivity.SelectParameters["Document_Id"].DefaultValue = e.Parameters;
            SqlCAWFActivity.DataBind();
            CAWFActivityGrid.DataBind();
        }

        protected void CADocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAFileAttach.SelectParameters["Doc_ID"].DefaultValue = e.Parameters;
            SqlCAFileAttach.DataBind();
            CADocuGrid.DataBind();
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

        protected override void OnUnload(EventArgs e)
        {
            base.OnUnload(e);
            _DataContext.Dispose();
        }
    }
}