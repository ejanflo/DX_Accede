using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Runtime.Caching;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeModels;
using static DX_WebTemplate.SAPVendor;

namespace DX_WebTemplate
{
    public partial class AccedeInvoiceNonPODashboard : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        // ---------------- VENDOR CACHE (same pattern as AccedeNonPOEditPage) ----------------
        private static readonly ObjectCache _cache = MemoryCache.Default;
        private const string SapClientParam = "sap-client=300";
        private static readonly object _vendorRefreshLock = new object();
        private static readonly Dictionary<string, DateTime> _vendorLastRefreshUtc = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);
        private static readonly TimeSpan VendorListMaxAge = TimeSpan.FromMinutes(30);

        internal static class VendorDataSetCache
        {
            private static readonly object _sync = new object();
            private static readonly DataTable _table;

            static VendorDataSetCache()
            {
                _table = new DataTable("Vendors");
                _table.Columns.Add("VENDCODE", typeof(string));
                _table.Columns.Add("VENDNAME", typeof(string));
                _table.Columns.Add("VENDCOCODE", typeof(string));
                _table.Columns.Add("VENDTIN", typeof(string));
                _table.Columns.Add("VENDSTREET", typeof(string));
                _table.Columns.Add("VENDCITY", typeof(string));
                _table.Columns.Add("VENDPOSTAL", typeof(string));
                _table.PrimaryKey = new[] { _table.Columns["VENDCODE"] };
            }

            public static void AddOrUpdate(IEnumerable<VendorSet> vendors)
            {
                if (vendors == null) return;
                lock (_sync)
                {
                    foreach (var v in vendors)
                    {
                        if (v == null || string.IsNullOrWhiteSpace(v.VENDCODE)) continue;
                        var key = v.VENDCODE.Trim().ToUpperInvariant();
                        var row = _table.Rows.Find(key);
                        if (row == null)
                        {
                            row = _table.NewRow();
                            row["VENDCODE"] = key;
                            row["VENDNAME"] = v.VENDNAME;
                            row["VENDCOCODE"] = v.VENDCOCODE;
                            row["VENDTIN"] = v.VENDTIN;
                            row["VENDSTREET"] = v.VENDSTREET;
                            row["VENDCITY"] = v.VENDCITY;
                            row["VENDPOSTAL"] = v.VENDPOSTAL;
                            _table.Rows.Add(row);
                        }
                        else
                        {
                            row["VENDNAME"] = v.VENDNAME;
                            row["VENDCOCODE"] = v.VENDCOCODE;
                            row["VENDTIN"] = v.VENDTIN;
                            row["VENDSTREET"] = v.VENDSTREET;
                            row["VENDCITY"] = v.VENDCITY;
                            row["VENDPOSTAL"] = v.VENDPOSTAL;
                        }
                    }
                }
            }

            public static VendorSet Get(string vendorCode)
            {
                if (string.IsNullOrWhiteSpace(vendorCode)) return null;
                var key = vendorCode.Trim().ToUpperInvariant();
                lock (_sync)
                {
                    var row = _table.Rows.Find(key);
                    if (row == null) return null;
                    return new VendorSet
                    {
                        VENDCODE = (string)row["VENDCODE"],
                        VENDNAME = row["VENDNAME"] as string,
                        VENDCOCODE = row["VENDCOCODE"] as string,
                        VENDTIN = row["VENDTIN"] as string,
                        VENDSTREET = row["VENDSTREET"] as string,
                        VENDCITY = row["VENDCITY"] as string,
                        VENDPOSTAL = row["VENDPOSTAL"] as string
                    };
                }
            }
        }

        internal static class VendorLookupService
        {
            private static readonly ObjectCache _localCache = MemoryCache.Default;
            private static readonly TimeSpan AbsoluteLifetime = TimeSpan.FromMinutes(10);
            private static readonly TimeSpan SlidingLifetime = TimeSpan.FromMinutes(3);
            private static readonly object _lockRoot = new object();

            public static VendorSet GetVendor(string vendorCode)
            {
                if (string.IsNullOrWhiteSpace(vendorCode))
                    return null;

                // 1. DataSet
                var dsHit = VendorDataSetCache.Get(vendorCode);
                if (dsHit != null) return dsHit;

                var normalized = vendorCode.Trim().ToUpperInvariant();
                string cacheKey = "VENDOR_SINGLE_" + normalized;

                // 2. MemoryCache
                var cached = _localCache.Get(cacheKey) as VendorSet;
                if (cached != null) return cached;

                lock (_lockRoot)
                {
                    cached = _localCache.Get(cacheKey) as VendorSet;
                    if (cached != null) return cached;

                    VendorSet result = null;
                    try
                    {
                        string query = $"{SapClientParam}&$filter=VENDCODE eq '{normalized.Replace("'", "''")}'&$top=1";
                        result = SAPConnector.GetVendorData(query)
                                          .FirstOrDefault(v => string.Equals(v.VENDCODE?.Trim(), normalized, StringComparison.OrdinalIgnoreCase));
                        if (result != null)
                        {
                            VendorDataSetCache.AddOrUpdate(new[] { result });
                            _localCache.Set(
                                cacheKey,
                                result,
                                new CacheItemPolicy
                                {
                                    AbsoluteExpiration = DateTimeOffset.UtcNow.Add(AbsoluteLifetime),
                                    SlidingExpiration = SlidingLifetime
                                });
                        }
                    }
                    catch
                    {
                        return result;
                    }
                    return result;
                }
            }
        }

        private List<VendorSet> FetchVendorListFromSap(string compCode)
        {
            if (string.IsNullOrWhiteSpace(compCode))
                return new List<VendorSet>();

            string query = $"{SapClientParam}&$filter=VENDCOCODE eq '{compCode}'";
            var list = SAPConnector.GetVendorData(query)
                .GroupBy(v => v.VENDCODE?.Trim().ToUpperInvariant())
                .Select(g => g.First())
                .OrderBy(v => v.VENDNAME)
                .ToList();

            VendorDataSetCache.AddOrUpdate(list);
            return list;
        }

        private List<VendorSet> GetOrRefreshVendorList(string compCode, bool force = false)
        {
            if (string.IsNullOrWhiteSpace(compCode))
                return new List<VendorSet>();

            string memKey = "VENDOR_LIST_" + compCode;
            var now = DateTime.UtcNow;

            if (!force)
            {
                if (_cache.Get(memKey) is List<VendorSet> cached &&
                    _vendorLastRefreshUtc.TryGetValue(compCode, out var last) &&
                    (now - last) < VendorListMaxAge &&
                    cached.Count > 0)
                {
                    return cached;
                }
            }

            lock (_vendorRefreshLock)
            {
                if (!force)
                {
                    if (_cache.Get(memKey) is List<VendorSet> cached2 &&
                        _vendorLastRefreshUtc.TryGetValue(compCode, out var last2) &&
                        (now - last2) < VendorListMaxAge &&
                        cached2.Count > 0)
                    {
                        return cached2;
                    }
                }

                var fresh = FetchVendorListFromSap(compCode);
                _cache.Set(memKey, fresh, DateTimeOffset.UtcNow.AddMinutes(15));
                _vendorLastRefreshUtc[compCode] = now;
                return fresh;
            }
        }

        private DateTime? GetLastVendorRefresh(string compCode)
        {
            if (_vendorLastRefreshUtc.TryGetValue(compCode ?? "", out var dt))
                return dt;
            return null;
        }
        // ---------------- END VENDOR CACHE ----------------

        // ---------------- VENDOR CACHE (same pattern as AccedeNonPOEditPage) ----------------

        // continue the code here same as the Vendor cache but for EWT
        internal static class EwtDataSetCache
        {
            private static readonly object _sync = new object();
            private static readonly DataTable _table;
            static EwtDataSetCache()
            {
                _table = new DataTable("EWTs");
                _table.Columns.Add("EWTTYPE", typeof(string));
                _table.Columns.Add("EWTCODE", typeof(string));
                _table.Columns.Add("EWTRATE", typeof(decimal));
                _table.Columns.Add("EWTDESC", typeof(string));
                _table.PrimaryKey = new[] { _table.Columns["EWTTYPE"], _table.Columns["EWTCODE"] };
            }
            public static void AddOrUpdate(IEnumerable<EwtSet> ewts)
            {
                if (ewts == null) return;
                lock (_sync)
                {
                    foreach (var e in ewts)
                    {
                        if (e == null || string.IsNullOrWhiteSpace(e.EWTTYPE) || string.IsNullOrWhiteSpace(e.EWTCODE)) continue;
                        var typeKey = e.EWTTYPE.Trim().ToUpperInvariant();
                        var codeKey = e.EWTCODE.Trim().ToUpperInvariant();
                        var row = _table.Rows.Find(new object[] { typeKey, codeKey });
                        if (row == null)
                        {
                            row = _table.NewRow();
                            row["EWTTYPE"] = typeKey;
                            row["EWTCODE"] = codeKey;
                            row["EWTRATE"] = decimal.TryParse(e.EWTRATE, out var rate) ? rate : 0m;
                            row["EWTDESC"] = e.EWTDESC;
                            _table.Rows.Add(row);
                        }
                        else
                        {
                            row["EWTRATE"] = decimal.TryParse(e.EWTRATE, out var rate) ? rate : 0m;
                            row["EWTDESC"] = e.EWTDESC;
                        }
                    }
                }
            }
            public static EwtSet Get(string ewtType, string ewtCode)
            {
                if (string.IsNullOrWhiteSpace(ewtType) || string.IsNullOrWhiteSpace(ewtCode)) return null;
                var typeKey = ewtType.Trim().ToUpperInvariant();
                var codeKey = ewtCode.Trim().ToUpperInvariant();
                lock (_sync)
                {
                    var row = _table.Rows.Find(new object[] { typeKey, codeKey });
                    if (row == null) return null;
                    return new EwtSet
                    {
                        EWTTYPE = (string)row["EWTTYPE"],
                        EWTCODE = (string)row["EWTCODE"],
                        EWTRATE = row["EWTRATE"]?.ToString(),
                        EWTDESC = row["EWTDESC"] as string
                    };
                }
            }

        }



        // ---------------- END EWT CACHE ----------------

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
                var empCode = Session["userID"]?.ToString();
                if (string.IsNullOrEmpty(empCode))
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                SqlUserCompany.SelectParameters["UserId"].DefaultValue = empCode;
                SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = empCode;
                sqlExpense.SelectParameters["UserId"].DefaultValue = empCode;
            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        private string Encrypt(string plainText)
        {
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText));
        }

        protected void expenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var parts = e.Parameters?.Split('|');
            if (parts == null || parts.Length == 0) return;
            string docId = parts[0];
            string action = parts.Length > 1 ? parts[1] : "";

            Session["NonPOInvoiceId"] = docId;

            switch (action)
            {
                case "btnEdit":
                    ASPxWebControl.RedirectOnCallback("AccedeNonPOEditPage.aspx");
                    break;
                case "btnView":
                    ASPxWebControl.RedirectOnCallback($"AccedeInvoiceNonPOViewPage.aspx?secureToken={Encrypt(docId)}");
                    break;
                case "btnPrint":
                    Session["cID"] = docId;
                    ASPxWebControl.RedirectOnCallback("AccedeExpenseReportPrinting.aspx");
                    break;
            }
        }

        protected void expenseGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex < 0) return;

            var statusVal = expenseGrid.GetRowValues(e.VisibleIndex, "Status")?.ToString();
            if (string.IsNullOrEmpty(statusVal)) return;

            var returnedAudit = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Returned by Audit");
            var returnedP2P = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Returned by P2P");
            var pendingAudit = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Pending at Audit");

            if (e.ButtonID == "btnEdit")
            {
                e.Visible = (statusVal == "15" || statusVal == "13" || statusVal == "3"
                             || statusVal == returnedAudit?.STS_Id.ToString()
                             || statusVal == returnedP2P?.STS_Id.ToString())
                    ? DevExpress.Utils.DefaultBoolean.True
                    : DevExpress.Utils.DefaultBoolean.False;
            }
            else if (e.ButtonID == "btnPrint")
            {
                e.Visible = (statusVal == pendingAudit?.STS_Id.ToString())
                    ? DevExpress.Utils.DefaultBoolean.True
                    : DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void ASPxGridView2_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["AccedeExpenseID"] = (sender as ASPxGridView)?.GetMasterRowKeyValue();
        }

        [WebMethod]
        public static string GetCosCenterFrmDeptAJAX(string dept_id)
        {
            var page = new AccedeInvoiceNonPODashboard();
            return page.GetCosCenterFrmDept(dept_id);
        }

        public string GetCosCenterFrmDept(string dept_id)
        {
            if (!Int32.TryParse(dept_id, out int id)) return "";
            var dept = context.ITP_S_OrgDepartmentMasters.FirstOrDefault(x => x.ID == id);
            return dept?.SAP_CostCenter ?? "";
        }

        [WebMethod]
        public static bool AddInvoiceReportAJAX(string expName, string expDate, string Comp, string CostCenter, string expCat,
            string Purpose, bool isTrav, string currency, string department, string payType, string CTComp_id,
            string CTDept_id, string CompLoc, string vendorName, string vendorTIN, string vendorAddress)
        {
            return new AccedeInvoiceNonPODashboard()
                .AddInvoiceReport(expName, expDate, Comp, CostCenter, expCat, Purpose, isTrav, currency,
                                  department, payType, CTComp_id, CTDept_id, CompLoc, vendorName, vendorTIN, vendorAddress);
        }

        public bool AddInvoiceReport(string expName, string expDate, string Comp, string CostCenter, string expCat,
            string Purpose, bool isTrav, string currency, string department, string payType, string CTComp_id,
            string CTDept_id, string CompLoc, string vendorName, string vendorTIN, string vendorAddress)
        {
            try
            {
                var docType = context.ITP_S_DocumentTypes.FirstOrDefault(x => x.DCT_Name == "ACDE InvoiceNPO");
                if (docType == null) return false;

                var gen = new GenerateDocNo();
                gen.RunStoredProc_GenerateDocNum(Convert.ToInt32(docType.DCT_Id), Convert.ToInt32(Comp), 1032);
                var docNo = gen.GetLatest_DocNum(Convert.ToInt32(docType.DCT_Id), Convert.ToInt32(Comp), 1032);

                var main = new ACCEDE_T_InvoiceMain
                {
                    VendorCode = expName,
                    ReportDate = Convert.ToDateTime(expDate),
                    PaymentType = 3,
                    InvoiceType_ID = 3,
                    CostCenter = string.IsNullOrWhiteSpace(CostCenter) ? null : CostCenter,
                    ExpenseCat = Int32.TryParse(expCat, out int ec) ? ec : (int?)null,
                    Purpose = Purpose,
                    Status = 13,
                    UserId = HttpContext.Current.Session["userID"]?.ToString(),
                    DocNo = docNo,
                    DateCreated = DateTime.Now,
                    Exp_Currency = currency,
                    InvChargedTo_CompanyId = Int32.TryParse(CTComp_id, out int ctc) ? ctc : (int?)null,
                    InvChargedTo_DeptId = Int32.TryParse(CTDept_id, out int ctd) ? ctd : (int?)null,
                    InvComp_Location_Id = Int32.TryParse(CompLoc, out int cl) ? cl : (int?)null,
                    VendorName = vendorName,
                    VendorTIN = vendorTIN,
                    VendorAddress = vendorAddress
                };

                context.ACCEDE_T_InvoiceMains.InsertOnSubmit(main);
                context.SubmitChanges();

                HttpContext.Current.Session["NonPOInvoiceId"] = main.ID;
                return true;
            }
            catch
            {
                return false;
            }
        }

        [WebMethod]
        public static VendorSet CheckVendorDetailsAJAX(string vendor)
        {
            return VendorLookupService.GetVendor(vendor);
        }

        // Replaced to use centralized lookup (kept for any server-side internal use)
        public VendorSet CheckVendorDetails(string vendor) => VendorLookupService.GetVendor(vendor);

        protected void drpdown_vendor_Callback(object sender, CallbackEventArgsBase e)
        {
            var raw = e.Parameter ?? "";
            var parts = raw.Split('|');
            var companyIdStr = parts.Length > 0 ? parts[0] : "";
            var flag = parts.Length > 1 ? parts[1] : "";
            bool force = false;

            if (!string.IsNullOrWhiteSpace(flag))
            {
                var f = flag.Trim().ToLowerInvariant();
                force = f == "force" || f == "refresh" || f == "1" || f == "true";
            }

            if (!Int32.TryParse(companyIdStr, out int companyId))
                return;

            var compCode = context.CompanyMasters
                .Where(x => x.WASSId == companyId)
                .Select(x => x.SAP_Id)
                .FirstOrDefault().ToString();

            if (string.IsNullOrWhiteSpace(compCode))
                return;

            var vendors = GetOrRefreshVendorList(compCode, force);

            drpdown_vendor.DataSource = vendors;
            drpdown_vendor.ValueField = "VENDCODE";
            drpdown_vendor.TextField = "VENDNAME";
            drpdown_vendor.Columns.Clear();
            drpdown_vendor.Columns.Add("VENDCODE");
            drpdown_vendor.Columns.Add("VENDNAME");
            drpdown_vendor.TextFormatString = "{0} - {1}";
            drpdown_vendor.DataBindItems();
            drpdown_vendor.ValidationSettings.RequiredField.IsRequired = true;

            if (drpdown_vendor is ASPxComboBox combo)
            {
                var last = GetLastVendorRefresh(compCode);
                if (last.HasValue)
                    combo.JSProperties["cpVendorLastRefresh"] = last.Value.ToString("o");
                combo.JSProperties["cpVendorCount"] = vendors.Count;
                combo.JSProperties["cpVendorForced"] = force;
            }
        }

        [WebMethod]
        public static int RefreshVendorCacheAJAX(int companyId)
        {
            var page = new AccedeInvoiceNonPODashboard();
            var compCode = page.context.CompanyMasters
                .Where(x => x.WASSId == companyId)
                .Select(x => x.SAP_Id)
                .FirstOrDefault().ToString();
            if (string.IsNullOrWhiteSpace(compCode))
                return 0;
            return page.GetOrRefreshVendorList(compCode, true).Count;
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter?.Split('|');
            if (param == null || param.Length < 2) return;
            var comp = param[0];
            var dept = param[1];

            SqlCostCenter.SelectParameters["Company_ID"].DefaultValue = comp;
            SqlCostCenter.DataBind();

            drpdown_CostCenter.DataSourceID = null;
            drpdown_CostCenter.DataSource = SqlCostCenter;
            drpdown_CostCenter.DataBind();

            if (Int32.TryParse(dept, out int deptId))
            {
                var deptDetails = context.ITP_S_OrgDepartmentMasters.FirstOrDefault(x => x.ID == deptId);
                if (deptDetails?.SAP_CostCenter != null)
                    drpdown_CostCenter.Value = deptDetails.SAP_CostCenter;
            }
        }

        protected void drpdown_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            sqlDept.SelectParameters["CompanyId"].DefaultValue = e.Parameter ?? "";
            sqlDept.SelectParameters["UserId"].DefaultValue = drpdown_vendor.Value != null ? drpdown_vendor.Value.ToString() : (Session["userID"]?.ToString() ?? "");
            sqlDept.DataBind();

            drpdown_Department.DataSourceID = null;
            drpdown_Department.DataSource = sqlDept;
            drpdown_Department.DataBindItems();

            if (drpdown_Department.Items.Count == 1)
                drpdown_Department.SelectedIndex = 0;
        }

        protected void drpdown_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = e.Parameter ?? "";
            SqlCTDepartment.DataBind();

            drpdown_CTDepartment.DataSourceID = null;
            drpdown_CTDepartment.DataSource = SqlCTDepartment;
            drpdown_CTDepartment.DataBind();

            if (drpdown_CTDepartment.Items.Count == 1)
                drpdown_CTDepartment.SelectedIndex = 0;
        }

        protected void drpdown_CompLocation_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = e.Parameter ?? "";
            SqlCompLocation.DataBind();

            drpdown_CompLocation.DataSourceID = null;
            drpdown_CompLocation.DataSource = SqlCompLocation;
            drpdown_CompLocation.DataBind();
        }

        protected void drpdown_Comp_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlUserCompany.SelectParameters["UserId"].DefaultValue = e.Parameter ?? "";
            SqlUserCompany.DataBind();

            drpdown_vendor.DataSourceID = null;
            drpdown_vendor.DataSource = SqlUserCompany;
            drpdown_vendor.DataBindItems();
        }

        protected void drpdown_EmpId_Callback(object sender, CallbackEventArgsBase e)
        {
            var compId = e.Parameter;
            if (string.IsNullOrWhiteSpace(compId)) return;

            SqlUser.SelectParameters["Company_ID"].DefaultValue = compId;
            SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"]?.ToString();
            SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
            SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();

            var dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;
            if (dv == null) return;

            var dt = dv.ToTable();
            var row = dt.NewRow();
            row["DelegateFor_UserID"] = Session["userID"]?.ToString();
            row["FullName"] = Session["userFullName"]?.ToString();
            dt.Rows.Add(row);

            drpdown_vendor.DataSource = dt;
            drpdown_vendor.TextField = "FullName";
            drpdown_vendor.ValueField = "DelegateFor_UserID";
            drpdown_vendor.DataBind();
            drpdown_vendor.Value = Session["userID"]?.ToString();
        }

        protected void CAGrid_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["AccedeExpenseID"] = (sender as ASPxGridView)?.GetMasterRowKeyValue();
        }

        protected void expenseGrid_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName != "Status") return;

            var payReleased = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Disbursed");
            var pendingAudit = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Pending at Audit");
            var returnedAudit = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Returned by Audit");
            var pendingP2P = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Pending at P2P");
            var returnedP2P = context.ITP_S_Status.FirstOrDefault(x => x.STS_Name == "Returned by P2P");

            string val = e.CellValue?.ToString();
            if (string.IsNullOrEmpty(val)) return;

            if (val == "7" || val == "5" || val == payReleased?.STS_Id.ToString())
            {
                e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");
            }
            else if (val == "2" || val == "3" || val == "18" || val == "19"
                     || val == returnedAudit?.STS_Id.ToString()
                     || val == returnedP2P?.STS_Id.ToString())
            {
                e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#E67C0E");
            }
            else if (val == pendingAudit?.STS_Id.ToString() || val == pendingP2P?.STS_Id.ToString() || val == "1")
            {
                e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#006DD6");
            }
            else if (val == "8")
            {
                e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#CC2A17");
            }
            else
            {
                e.Cell.ForeColor = System.Drawing.Color.Gray;
            }
            e.Cell.Font.Bold = true;
        }
    }
}