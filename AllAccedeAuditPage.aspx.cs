using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace DX_WebTemplate
{
    public partial class AllAccedeAuditPage : System.Web.UI.Page
    {
        // Keep one DataContext per page instance; dispose at end of lifecycle.
        private static readonly CultureInfo FormatCulture = CultureInfo.InvariantCulture;
        private static readonly string CurrencyFormat = "#,##0.00";
        private readonly ITPORTALDataContext _context =
            new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
            }
            else
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void expenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            // Get commonly used field values once.
            int appDocTypeId = SafeToInt(e.GetFieldValue("AppDocTypeId"));
            int tranType = SafeToInt(e.GetFieldValue("TranType"));
            int documentId = SafeToInt(e.GetFieldValue("Document_Id"));

            if (appDocTypeId == 0 || documentId == 0)
                return;

            string appName = GetDocTypeName(appDocTypeId);
            if (string.IsNullOrEmpty(appName))
                return;

            switch (e.Column.Caption)
            {
                case "Document No.":
                    e.DisplayText = GetDocumentNumber(appName, documentId);
                    break;

                case "Employee Name/Vendor":
                    e.DisplayText = GetEmployeeOrVendor(appName, documentId, tranType);
                    break;

                case "Department":
                    e.DisplayText = GetDepartment(appName, documentId);
                    break;

                case "Remarks":
                    e.DisplayText = GetRemarks(appName, documentId);
                    break;

                case "Amount":
                    e.DisplayText = GetAmountDisplay(appName, documentId);
                    break;

                case "Purpose":
                    e.DisplayText = GetPurpose(appName, documentId);
                    break;

                case "Preparer":
                    e.DisplayText = GetPreparer(appName, documentId);
                    break;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            if (args.Length == 0) return;

            string rowKey = args[0];
            string action = args.Length > 1 ? args[args.Length - 1] : string.Empty;

            object docIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "Document_Id");
            object companyIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "CompanyId");
            object wfaIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            object wfIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            object wfdIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");
            object statusObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            object appDocTypeIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "AppDocTypeId");

            Session["TravelExp_Id"] = docIdObj;
            Session["comp"] = companyIdObj;
            Session["PassActID"] = wfaIdObj;
            Session["wfa"] = wfaIdObj;
            Session["wf"] = wfIdObj;
            Session["wfd"] = wfdIdObj;
            Session["doc_stat"] = statusObj;

            int appDocTypeId = SafeToInt(appDocTypeIdObj);
            string appName = GetDocTypeName(appDocTypeId);

            string actID = Convert.ToString(Session["wfa"] ?? string.Empty);
            string encryptedID = Encrypt(actID);

            Session["ExpenseId"] = rowKey;
            Session["ExpId_audit"] = rowKey;

            int docId = SafeToInt(docIdObj);

            var expenseMain = GetOrCache("EXP_MAIN_" + docId, () =>
                _context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).FirstOrDefault());

            Debug.WriteLine("Main ID: " + Session["TravelExp_Id"]);
            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (action == "btnView")
            {
                if (appName == "ACDE RFP")
                {
                    // Redirect logic can be added here when needed.
                }
                else if (appName == "ACDE Expense")
                {
                    if (expenseMain != null && expenseMain.ExpenseType_ID == 3)
                    {
                        ASPxWebControl.RedirectOnCallback($"~/AccedeNonPO_AuditView.aspx?secureToken={encryptedID}");
                    }
                    else
                    {
                        ASPxWebControl.RedirectOnCallback($"~/AccedeAuditViewPage.aspx?secureToken={encryptedID}");
                    }
                }
                else if (appName == "ACDE Expense Travel")
                {
                    var travel = GetOrCache("TRAVEL_" + docId, () =>
                        _context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).FirstOrDefault());

                    if (travel != null)
                    {
                        Session["prep"] = travel.Preparer_Id;
                        Session["empid"] = travel.Employee_Id;
                    }
                    ASPxWebControl.RedirectOnCallback("~/TravelExpenseReview.aspx");
                }
                else if (appName == "ACDE InvoiceNPO")
                {
                    ASPxWebControl.RedirectOnCallback($"~/AccedeNonPO_AuditView.aspx?secureToken={encryptedID}");
                }
            }
        }

        private string GetDocumentNumber(string appName, int id)
        {
            switch (appName)
            {
                case "ACDE RFP":
                    return SafeString(_context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.RFP_DocNum).FirstOrDefault());
                case "ACDE Expense":
                    return SafeString(_context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.DocNo).FirstOrDefault());
                case "ACDE Expense Travel":
                    return SafeString(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Doc_No).FirstOrDefault());
                case "ACDE InvoiceNPO":
                    return SafeString(_context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.DocNo).FirstOrDefault());
                default:
                    return string.Empty;
            }
        }

        private string GetEmployeeOrVendor(string appName, int id, int tranType)
        {
            if (appName == "ACDE RFP")
            {
                string raw = _context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Payee).FirstOrDefault();
                return GetUserFullNameFromMixed(raw);
            }
            if (appName == "ACDE Expense")
            {
                string raw = _context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpenseName).FirstOrDefault();
                if (tranType == 3) // If vendor string directly
                    return SafeUpper(raw);
                return GetUserFullNameFromMixed(raw);
            }
            if (appName == "ACDE Expense Travel")
            {
                string empCodeRaw = SafeString(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Employee_Id).FirstOrDefault());
                return GetUserFullNameFromMixed(empCodeRaw);
            }
            if (appName == "ACDE InvoiceNPO")
            {
                return SafeString(_context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.VendorName).FirstOrDefault());
            }
            return string.Empty;
        }

        private string GetDepartment(string appName, int id)
        {
            int deptId = 0;
            if (appName == "ACDE RFP")
                deptId = SafeToInt(_context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Department_ID).FirstOrDefault());
            else if (appName == "ACDE Expense")
                deptId = SafeToInt(_context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpChargedTo_DeptId).FirstOrDefault());
            else if (appName == "ACDE Expense Travel")
                deptId = SafeToInt(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Dep_Code).FirstOrDefault());
            else if (appName == "ACDE InvoiceNPO")
                deptId = SafeToInt(_context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.InvChargedTo_DeptId).FirstOrDefault());

            if (deptId == 0) return string.Empty;
            return GetDepartmentDescription(deptId);
        }

        private string GetRemarks(string appName, int id)
        {
            if (appName == "ACDE RFP")
                return SafeString(_context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault());
            if (appName == "ACDE Expense")
                return SafeString(_context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.remarks).FirstOrDefault());
            if (appName == "ACDE Expense Travel")
                return SafeString(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault());
            return string.Empty;
        }

        private string GetPurpose(string appName, int id)
        {
            if (appName == "ACDE RFP")
                return SafeString(_context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault());
            if (appName == "ACDE Expense")
                return SafeString(_context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault());
            if (appName == "ACDE Expense Travel")
                return SafeString(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault());
            if (appName == "ACDE InvoiceNPO")
                return SafeString(_context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault());
            return string.Empty;
        }

        private string GetPreparer(string appName, int id)
        {
            string userId = string.Empty;
            if (appName == "ACDE RFP")
                userId = SafeString(_context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.User_ID).FirstOrDefault());
            else if (appName == "ACDE Expense")
                userId = SafeString(_context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault());
            else if (appName == "ACDE Expense Travel")
                userId = SafeString(_context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Preparer_Id).FirstOrDefault());
            else if (appName == "ACDE InvoiceNPO")
                userId = SafeString(_context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault());

            if (string.IsNullOrEmpty(userId)) return string.Empty;
            return GetUserFullName(userId);
        }

        // Helper / Caching

        private string GetDocTypeName(int docTypeId)
        {
            if (docTypeId <= 0) return string.Empty;
            var cache = GetPerRequestCache<int, string>("DOC_TYPE_CACHE");
            string name;
            if (!cache.TryGetValue(docTypeId, out name))
            {
                name = _context.ITP_S_DocumentTypes.Where(d => d.DCT_Id == docTypeId)
                        .Select(d => d.DCT_Name).FirstOrDefault() ?? string.Empty;
                cache[docTypeId] = name;
            }
            return name;
        }

        private string GetUserFullNameFromMixed(string raw)
        {
            string digits = ExtractDigits(raw);
            if (string.IsNullOrEmpty(digits)) return string.Empty;
            return GetUserFullName(digits);
        }

        private string GetUserFullName(string empCode)
        {
            var cache = GetPerRequestCache<string, string>("USER_NAME_CACHE");
            string name;
            if (!cache.TryGetValue(empCode, out name))
            {
                name = _context.ITP_S_UserMasters.Where(x => x.EmpCode == empCode)
                        .Select(x => x.FullName).FirstOrDefault();
                name = SafeUpper(name);
                cache[empCode] = name;
            }
            return name;
        }

        private string GetDepartmentDescription(int deptId)
        {
            var cache = GetPerRequestCache<int, string>("DEPT_CACHE");
            string desc;
            if (!cache.TryGetValue(deptId, out desc))
            {
                desc = _context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == deptId)
                        .Select(x => x.DepDesc).FirstOrDefault();
                desc = SafeUpper(desc);
                cache[deptId] = desc;
            }
            return desc;
        }

        private string GetAmountDisplay(string docTypeName, int id)
        {
            string cacheKey = $"Amount_{docTypeName}_{id}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        {
                            var data = _context.ACCEDE_T_RFPMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Currency, x.Amount })
                                .FirstOrDefault();
                            if (data == null) return string.Empty;
                            return data.Currency + " " + (data.Amount ?? 0m).ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE Expense":
                        {
                            var main = _context.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Exp_Currency })
                                .FirstOrDefault();

                            var total = _context.ACCEDE_T_ExpenseDetails
                                .Where(d => d.ExpenseMain_ID == id)
                                .Select(d => (decimal?)d.NetAmount)
                                .Sum() ?? 0m;

                            return (main?.Exp_Currency ?? "") + " " + total.ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE Expense Travel":
                        {
                            // Determine currency from RFP associated (reim or CA)
                            var rfpTravel = _context.ACCEDE_T_RFPMains
                                .Where(x => x.Exp_ID == id && x.isTravel == true)
                                .Select(x => new { x.Currency, x.IsExpenseReim, x.IsExpenseCA, x.Status })
                                .ToList();

                            string currency = rfpTravel
                                .Where(x => Convert.ToBoolean(x.IsExpenseReim) && x.Status != 4)
                                .Select(x => x.Currency)
                                .FirstOrDefault()
                                ?? rfpTravel.Where(x => Convert.ToBoolean(x.IsExpenseCA)).Select(x => x.Currency).FirstOrDefault()
                                ?? string.Empty;

                            var total = _context.ACCEDE_T_TravelExpenseDetails
                                .Where(d => d.TravelExpenseMain_ID == id)
                                .Select(d => (decimal?)d.Total_Expenses)
                                .Sum() ?? 0m;

                            return currency + " " + total.ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE InvoiceNPO":
                        {
                            var main = _context.ACCEDE_T_InvoiceMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Exp_Currency })
                                .FirstOrDefault();

                            var total = _context.ACCEDE_T_InvoiceLineDetails
                                .Where(d => d.InvMain_ID == id)
                                .Select(d => (decimal?)d.NetAmount)
                                .Sum() ?? 0m;

                            return (main?.Exp_Currency ?? "") + " " + total.ToString(CurrencyFormat, FormatCulture);
                        }
                    default:
                        return string.Empty;
                }
            });
        }

        private static string ExtractDigits(string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            var chars = input.Where(char.IsDigit).ToArray();
            return chars.Length == 0 ? string.Empty : new string(chars);
        }

        private static string SafeString(object o) => o == null ? string.Empty : Convert.ToString(o);

        private static string SafeUpper(string value) => string.IsNullOrEmpty(value) ? string.Empty : value.ToUpper();

        private static int SafeToInt(object o)
        {
            if (o == null || o == DBNull.Value) return 0;
            int v;
            return int.TryParse(o.ToString(), out v) ? v : 0;
        }

        private T GetOrCache<T>(string key, Func<T> loader)
        {
            var items = HttpContext.Current.Items;
            if (items[key] == null)
            {
                items[key] = loader();
            }
            return (T)items[key];
        }

        private Dictionary<TKey, TValue> GetPerRequestCache<TKey, TValue>(string key)
        {
            var items = HttpContext.Current.Items;
            var cache = items[key] as Dictionary<TKey, TValue>;
            if (cache == null)
            {
                cache = new Dictionary<TKey, TValue>();
                items[key] = cache;
            }
            return cache;
        }

        private string Encrypt(string plainText)
        {
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText ?? string.Empty));
        }

        protected override void OnUnload(EventArgs e)
        {
            base.OnUnload(e);
            _context.Dispose();
        }


        private T GetOrAddRowCache<T>(string key, Func<T> factory)
        {
            var items = HttpContext.Current.Items;
            if (items[key] is T cached) return cached;
            var created = factory();
            items[key] = created;
            return created;
        }
    }
}