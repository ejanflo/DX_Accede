using DevExpress.DocumentServices.ServiceModel.DataContracts;
using DevExpress.Pdf.Xmp;
using DevExpress.Web;
using System;
using System.Collections.Concurrent;
using System.Configuration;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;

namespace DX_WebTemplate
{
    public partial class AllAccedeP2PPage : System.Web.UI.Page
    {
        // DataContext per request (WebForms pattern). Read-mostly, so disable tracking to reduce overhead.
        private static readonly CultureInfo FormatCulture = CultureInfo.InvariantCulture;
        private static readonly string CurrencyFormat = "#,##0.00";
        private readonly ITPORTALDataContext context =
            new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString)
            {
                ObjectTrackingEnabled = false,
                DeferredLoadingEnabled = false
            };

        // Cache document type names (ID -> Name). Safe for multi-threaded reads; updated only if new IDs encountered.
        private static readonly ConcurrentDictionary<int, string> _docTypeNameCache = new ConcurrentDictionary<int, string>();

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
            // Quickly bail if not one of the columns we customize
            var caption = e.Column.Caption;
            if (caption != "Document No." &&
                caption != "Employee Name/Vendor" &&
                caption != "Department" &&
                caption != "Remarks" &&
                caption != "Purpose" &&
                caption != "Preparer")
            {
                return;
            }

            // Read row metadata
            var appObj = e.GetFieldValue("AppDocTypeId");
            var tranObj = e.GetFieldValue("TranType");
            var idObj = e.GetFieldValue("Document_Id");

            int appId = SafeToInt(appObj);
            int tranType = SafeToInt(tranObj);
            int docId = SafeToInt(idObj);

            if (appId == 0 || docId == 0)
            {
                e.DisplayText = string.Empty;
                return;
            }

            string docTypeName = GetDocTypeName(appId);
            if (string.IsNullOrEmpty(docTypeName))
            {
                e.DisplayText = string.Empty;
                return;
            }

            switch (caption)
            {
                case "Document No.":
                    e.DisplayText = GetDocumentNumber(docTypeName, docId);
                    break;
                case "Employee Name/Vendor":
                    e.DisplayText = GetEmployeeOrVendorName(docTypeName, docId, tranType);
                    break;
                case "Department":
                    e.DisplayText = GetDepartment(docTypeName, docId);
                    break;
                case "Remarks":
                    e.DisplayText = GetRemarks(docTypeName, docId);
                    break;
                case "Amount":
                    e.DisplayText = GetAmountDisplay(docTypeName, docId);
                    break;
                case "Purpose":
                    e.DisplayText = GetPurpose(docTypeName, docId);
                    break;
                case "Preparer":
                    e.DisplayText = GetPreparer(docTypeName, docId);
                    break;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var parameters = e.Parameters.Split('|');
            if (parameters.Length == 0) return;

            string rowKey = parameters[0];
            string command = parameters[parameters.Length - 1];

            // Batch fetch row values only once
            var documentId = expenseGrid.GetRowValuesByKeyValue(rowKey, "Document_Id");
            var companyId = expenseGrid.GetRowValuesByKeyValue(rowKey, "CompanyId");
            var wfaId = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            var wfId = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            var wfdId = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");
            var status = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            var appDocTypeIdObj = expenseGrid.GetRowValuesByKeyValue(rowKey, "AppDocTypeId");

            Session["TravelExp_Id"] = documentId;
            Session["comp"] = companyId;
            Session["PassActID"] = wfaId;
            Session["wfa"] = wfaId;
            Session["wf"] = wfId;
            Session["wfd"] = wfdId;
            Session["doc_stat"] = status;

            int appDocTypeId = SafeToInt(appDocTypeIdObj);
            string docTypeName = GetDocTypeName(appDocTypeId);

            string actID = Convert.ToString(wfaId);
            string encryptedID = Encrypt(actID);

            // Maintain existing session semantics
            Session["ExpId_p2p"] = rowKey;
            Session["passP2PRFPID"] = rowKey;

            Debug.WriteLine("Main ID: " + Session["TravelExp_Id"]);
            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (command == "btnView")
            {
                if (docTypeName == "ACDE RFP")
                {
                    ASPxWebControl.RedirectOnCallback($"~/AccedeP2P_RFPViewPage.aspx?secureToken={encryptedID}");
                }
                else if (docTypeName == "ACDE Expense")
                {
                    // Load only what we need
                    int id = SafeToInt(documentId);
                    var expenseTypeId = context.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == id)
                        .Select(x => (int?)x.ExpenseType_ID)
                        .FirstOrDefault();

                    if (expenseTypeId == 3)
                        ASPxWebControl.RedirectOnCallback($"~/AccedeNonPO_P2PView.aspx?secureToken={encryptedID}");
                    else
                        ASPxWebControl.RedirectOnCallback($"~/AccedeP2PViewPage.aspx?secureToken={encryptedID}");
                }
                else if (docTypeName == "ACDE Expense Travel")
                {
                    int id = SafeToInt(documentId);
                    var travelInfo = context.ACCEDE_T_TravelExpenseMains
                        .Where(x => x.ID == id)
                        .Select(x => new { x.Preparer_Id, x.Employee_Id })
                        .FirstOrDefault();

                    if (travelInfo != null)
                    {
                        Session["prep"] = travelInfo.Preparer_Id;
                        Session["empid"] = travelInfo.Employee_Id;
                    }
                    ASPxWebControl.RedirectOnCallback("~/TravelExpenseReview.aspx");
                }
                else if (docTypeName == "ACDE InvoiceNPO")
                {
                    ASPxWebControl.RedirectOnCallback($"~/AccedeNonPO_P2PView.aspx?secureToken={encryptedID}");
                }
            }
        }

        private static int SafeToInt(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            int result;
            return int.TryParse(value.ToString(), out result) ? result : 0;
        }

        private string GetDocTypeName(int appId)
        {
            if (appId == 0) return string.Empty;
            return _docTypeNameCache.GetOrAdd(appId, id =>
                context.ITP_S_DocumentTypes
                       .Where(x => x.DCT_Id == id)
                       .Select(x => x.DCT_Name)
                       .FirstOrDefault() ?? string.Empty);
        }

        private string GetDocumentNumber(string docTypeName, int docId)
        {
            switch (docTypeName)
            {
                case "ACDE RFP":
                    return NullToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.RFP_DocNum).FirstOrDefault());
                case "ACDE Expense":
                    return NullToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.DocNo).FirstOrDefault());
                case "ACDE Expense Travel":
                    return NullToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Doc_No).FirstOrDefault());
                case "ACDE InvoiceNPO":
                    return NullToString(context.ACCEDE_T_InvoiceMains.Where(x => x.ID == docId).Select(x => x.DocNo).FirstOrDefault());
            }
            return string.Empty;
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
                            var data = context.ACCEDE_T_RFPMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Currency, x.Amount })
                                .FirstOrDefault();
                            if (data == null) return string.Empty;
                            return data.Currency + " " + (data.Amount ?? 0m).ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE Expense":
                        {
                            var main = context.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Exp_Currency })
                                .FirstOrDefault();

                            var total = context.ACCEDE_T_ExpenseDetails
                                .Where(d => d.ExpenseMain_ID == id)
                                .Select(d => (decimal?)d.NetAmount)
                                .Sum() ?? 0m;

                            return (main?.Exp_Currency ?? "") + " " + total.ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE Expense Travel":
                        {
                            // Determine currency from RFP associated (reim or CA)
                            var rfpTravel = context.ACCEDE_T_RFPMains
                                .Where(x => x.Exp_ID == id && x.isTravel == true)
                                .Select(x => new { x.Currency, x.IsExpenseReim, x.IsExpenseCA, x.Status })
                                .ToList();

                            string currency = rfpTravel
                                .Where(x => Convert.ToBoolean(x.IsExpenseReim) && x.Status != 4)
                                .Select(x => x.Currency)
                                .FirstOrDefault()
                                ?? rfpTravel.Where(x => Convert.ToBoolean(x.IsExpenseCA)).Select(x => x.Currency).FirstOrDefault()
                                ?? string.Empty;

                            var total = context.ACCEDE_T_TravelExpenseDetails
                                .Where(d => d.TravelExpenseMain_ID == id)
                                .Select(d => (decimal?)d.Total_Expenses)
                                .Sum() ?? 0m;

                            return currency + " " + total.ToString(CurrencyFormat, FormatCulture);
                        }
                    case "ACDE InvoiceNPO":
                        {
                            var main = context.ACCEDE_T_InvoiceMains
                                .Where(x => x.ID == id)
                                .Select(x => new { x.Exp_Currency })
                                .FirstOrDefault();

                            var total = context.ACCEDE_T_InvoiceLineDetails
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

        private string GetEmployeeOrVendorName(string docTypeName, int docId, int tranType)
        {
            switch (docTypeName)
            {
                case "ACDE RFP":
                    {
                        var payeeRaw = context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.Payee).FirstOrDefault();
                        return GetUserFullNameFromRaw(payeeRaw);
                    }
                case "ACDE Expense":
                    {
                        var nameRaw = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.ExpenseName).FirstOrDefault();
                        if (tranType == 3) // Vendor / Non-employee scenario
                            return NullToString(nameRaw);
                        return GetUserFullNameFromRaw(nameRaw);
                    }
                case "ACDE Expense Travel":
                    {
                        var empRaw = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Employee_Id).FirstOrDefault().ToString();
                        return GetUserFullNameFromRaw(empRaw);
                    }
                case "ACDE InvoiceNPO":
                    return NullToString(context.ACCEDE_T_InvoiceMains.Where(x => x.ID == docId).Select(x => x.VendorName).FirstOrDefault());
            }
            return string.Empty;
        }

        private string GetDepartment(string docTypeName, int docId)
        {
            int deptId = 0;
            switch (docTypeName)
            {
                case "ACDE RFP":
                    deptId = SafeToInt(context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.Department_ID).FirstOrDefault());
                    break;
                case "ACDE Expense":
                    deptId = SafeToInt(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.ExpChargedTo_DeptId).FirstOrDefault());
                    break;
                case "ACDE Expense Travel":
                    {
                        var depCode = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Dep_Code).FirstOrDefault();
                        deptId = SafeToInt(depCode);
                        break;
                    }
                case "ACDE InvoiceNPO":
                    deptId = SafeToInt(context.ACCEDE_T_InvoiceMains.Where(x => x.ID == docId).Select(x => x.InvChargedTo_DeptId).FirstOrDefault());
                    break;
            }

            if (deptId == 0) return string.Empty;

            var depDesc = context.ITP_S_OrgDepartmentMasters
                .Where(x => x.ID == deptId)
                .Select(x => x.DepDesc)
                .FirstOrDefault();

            return NullToString(depDesc).ToUpperInvariant();
        }

        private string GetRemarks(string docTypeName, int docId)
        {
            switch (docTypeName)
            {
                case "ACDE RFP":
                    return NullToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.Remarks).FirstOrDefault());
                case "ACDE Expense":
                    return NullToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.remarks).FirstOrDefault());
                case "ACDE Expense Travel":
                    return NullToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Remarks).FirstOrDefault());
            }
            return string.Empty;
        }

        private string GetPurpose(string docTypeName, int docId)
        {
            switch (docTypeName)
            {
                case "ACDE RFP":
                    return NullToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.Purpose).FirstOrDefault());
                case "ACDE Expense":
                    return NullToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.Purpose).FirstOrDefault());
                case "ACDE Expense Travel":
                    return NullToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Purpose).FirstOrDefault());
                case "ACDE InvoiceNPO":
                    return NullToString(context.ACCEDE_T_InvoiceMains.Where(x => x.ID == docId).Select(x => x.Purpose).FirstOrDefault());
            }
            return string.Empty;
        }

        private string GetPreparer(string docTypeName, int docId)
        {
            string userId = null;
            switch (docTypeName)
            {
                case "ACDE RFP":
                    userId = context.ACCEDE_T_RFPMains.Where(x => x.ID == docId).Select(x => x.User_ID).FirstOrDefault();
                    break;
                case "ACDE Expense":
                    userId = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == docId).Select(x => x.UserId).FirstOrDefault();
                    break;
                case "ACDE Expense Travel":
                    userId = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docId).Select(x => x.Preparer_Id).FirstOrDefault());
                    break;
                case "ACDE InvoiceNPO":
                    userId = context.ACCEDE_T_InvoiceMains.Where(x => x.ID == docId).Select(x => x.UserId).FirstOrDefault();
                    break;
            }
            if (string.IsNullOrEmpty(userId)) return string.Empty;

            var fullName = context.ITP_S_UserMasters
                .Where(x => x.EmpCode == userId)
                .Select(x => x.FullName)
                .FirstOrDefault();

            return NullToString(fullName).ToUpperInvariant();
        }

        private string GetUserFullNameFromRaw(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return string.Empty;
            var digits = ExtractDigits(raw);
            if (string.IsNullOrEmpty(digits)) return string.Empty;

            var fullName = context.ITP_S_UserMasters
                .Where(x => x.EmpCode == digits)
                .Select(x => x.FullName)
                .FirstOrDefault();

            return NullToString(fullName).ToUpperInvariant();
        }

        private static string ExtractDigits(string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            var sb = new StringBuilder(input.Length);
            for (int i = 0; i < input.Length; i++)
            {
                char c = input[i];
                if (char.IsDigit(c)) sb.Append(c);
            }
            return sb.ToString();
        }

        private static string NullToString(object value)
        {
            return value == null ? string.Empty : Convert.ToString(value);
        }

        private T GetOrAddRowCache<T>(string key, Func<T> factory)
        {
            var items = HttpContext.Current.Items;
            if (items[key] is T cached) return cached;
            var created = factory();
            items[key] = created;
            return created;
        }

        private string Encrypt(string plainText)
        {
            // NOTE: Base64 is NOT encryption. Replace with proper crypto (e.g., AES) if confidentiality is required.
            if (plainText == null) return string.Empty;
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(plainText));
        }
    }
}