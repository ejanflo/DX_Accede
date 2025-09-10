using DevExpress.Pdf.Xmp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AllAccedeApprovalPage : System.Web.UI.Page
    {
        private static readonly CultureInfo FormatCulture = CultureInfo.InvariantCulture;
        private static readonly string CurrencyFormat = "#,##0.00";

        private readonly ITPORTALDataContext context =
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

        #region Utility / Caching Helpers

        private static int ToInt(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            int.TryParse(value.ToString(), out var v);
            return v;
        }

        private static string Upper(string value) =>
            string.IsNullOrEmpty(value) ? string.Empty : value.ToUpperInvariant();

        private T GetOrAddRowCache<T>(string key, Func<T> factory)
        {
            var items = HttpContext.Current.Items;
            if (items[key] is T cached) return cached;
            var created = factory();
            items[key] = created;
            return created;
        }

        private string GetDocumentTypeName(int docTypeId)
        {
            if (docTypeId == 0) return null;
            string cacheKey = "DocTypeName_" + docTypeId;
            return GetOrAddRowCache(cacheKey, () =>
                context.ITP_S_DocumentTypes
                       .Where(x => x.DCT_Id == docTypeId)
                       .Select(x => x.DCT_Name)
                       .FirstOrDefault());
        }

        // Pseudocode:
        // 1. Identify CS0411 cause: generic type inference fails in GetMainEntity because switch returns multiple unrelated LINQ-to-SQL entity types (and null).
        // 2. Force generic argument explicitly to a common type (object) when calling GetOrAddRowCache.
        // 3. Keep method return type dynamic so downstream code behavior unchanged.
        // 4. No other logic changes.
        // 5. Add clarifying comment for future maintenance.

        private dynamic GetMainEntity(string docTypeName, int id)
        {
            if (id == 0 || string.IsNullOrEmpty(docTypeName)) return null;
            string cacheKey = $"Main_{docTypeName}_{id}";

            // Explicitly specify <object> to avoid CS0411 (type inference failure due to heterogeneous return types in switch).
            return GetOrAddRowCache<object>(cacheKey, () =>
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        return context.ACCEDE_T_RFPMains.FirstOrDefault(x => x.ID == id);
                    case "ACDE Expense":
                        return context.ACCEDE_T_ExpenseMains.FirstOrDefault(x => x.ID == id);
                    case "ACDE Expense Travel":
                        return context.ACCEDE_T_TravelExpenseMains.FirstOrDefault(x => x.ID == id);
                    case "ACDE InvoiceNPO":
                        return context.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == id);
                    default:
                        return null;
                }
            });
        }

        private string GetEmployeeOrVendorName(string docTypeName, int id)
        {
            string cacheKey = $"EmpVend_{docTypeName}_{id}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        {
                            var payeeRaw = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Payee).FirstOrDefault();
                            var empDigits = new string((payeeRaw ?? string.Empty).Where(char.IsDigit).ToArray());
                            if (!string.IsNullOrEmpty(empDigits))
                            {
                                return Upper(context.ITP_S_UserMasters.Where(x => x.EmpCode == empDigits).Select(x => x.FullName).FirstOrDefault());
                            }
                            return string.Empty;
                        }
                    case "ACDE Expense":
                        {
                            var expenseName = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpenseName).FirstOrDefault();
                            return Upper(expenseName);
                        }
                    case "ACDE Expense Travel":
                        {
                            var empRaw = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Employee_Id).FirstOrDefault()?.ToString();
                            var empDigits = new string((empRaw ?? string.Empty).Where(char.IsDigit).ToArray());
                            if (!string.IsNullOrEmpty(empDigits))
                            {
                                return Upper(context.ITP_S_UserMasters.Where(x => x.EmpCode == empDigits).Select(x => x.FullName).FirstOrDefault());
                            }
                            return string.Empty;
                        }
                    case "ACDE InvoiceNPO":
                        {
                            var vendor = context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.VendorName).FirstOrDefault();
                            return Upper(vendor);
                        }
                    default:
                        return string.Empty;
                }
            });
        }

        private string GetDepartment(string docTypeName, int id)
        {
            string cacheKey = $"Dept_{docTypeName}_{id}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                int deptId = 0;
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        deptId = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Department_ID ?? 0).FirstOrDefault();
                        break;
                    case "ACDE Expense":
                        deptId = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpChargedTo_DeptId ?? 0).FirstOrDefault();
                        break;
                    case "ACDE Expense Travel":
                        var depCode = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Dep_Code).FirstOrDefault();
                        int.TryParse(depCode, out deptId);
                        break;
                    case "ACDE InvoiceNPO":
                        deptId = context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.InvChargedTo_DeptId ?? 0).FirstOrDefault();
                        break;
                }

                if (deptId > 0)
                {
                    return Upper(context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == deptId).Select(x => x.DepDesc).FirstOrDefault());
                }
                return string.Empty;
            });
        }

        private string GetTranType(string docTypeName, int tranId)
        {
            if (tranId == 0) return string.Empty;
            string cacheKey = $"TranType_{docTypeName}_{tranId}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        return context.ACCEDE_S_RFPTranTypes.Where(x => x.ID == tranId).Select(x => x.RFPTranType_Desc).FirstOrDefault() ?? string.Empty;
                    case "ACDE Expense":
                    case "ACDE Expense Travel":
                    case "ACDE InvoiceNPO":
                        return context.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == tranId).Select(x => x.Description).FirstOrDefault() ?? string.Empty;
                    default:
                        return string.Empty;
                }
            });
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

        private string GetRemarks(string docTypeName, int id)
        {
            string cacheKey = $"Remarks_{docTypeName}_{id}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        return context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault() ?? string.Empty;
                    case "ACDE Expense":
                        return context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.remarks).FirstOrDefault() ?? string.Empty;
                    case "ACDE Expense Travel":
                        return context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault() ?? string.Empty;
                    default:
                        return string.Empty;
                }
            });
        }

        private string GetPreparer(string docTypeName, int id)
        {
            string cacheKey = $"Preparer_{docTypeName}_{id}";
            return GetOrAddRowCache(cacheKey, () =>
            {
                string userId = null;
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        userId = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.User_ID).FirstOrDefault();
                        break;
                    case "ACDE Expense":
                        userId = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault();
                        break;
                    case "ACDE Expense Travel":
                        userId = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Preparer_Id.ToString()).FirstOrDefault();
                        break;
                    case "ACDE InvoiceNPO":
                        userId = context.ACCEDE_T_InvoiceMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault();
                        break;
                }

                if (string.IsNullOrEmpty(userId)) return string.Empty;

                return Upper(context.ITP_S_UserMasters.Where(x => x.EmpCode == userId).Select(x => x.FullName).FirstOrDefault());
            });
        }

        #endregion

        protected void expenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            // Common row-level basics
            int appId = ToInt(e.GetFieldValue("AppDocTypeId"));
            int tranTypeId = ToInt(e.GetFieldValue("TranType"));
            int docId = ToInt(e.GetFieldValue("Document_Id"));

            if (docId == 0 || appId == 0) return;

            string docTypeName = GetDocumentTypeName(appId);
            if (string.IsNullOrEmpty(docTypeName)) return;

            switch (e.Column.Caption)
            {
                case "Employee Name/Vendor":
                    e.DisplayText = GetEmployeeOrVendorName(docTypeName, docId);
                    break;

                case "Department":
                    e.DisplayText = GetDepartment(docTypeName, docId);
                    break;

                case "Transaction Type":
                    e.DisplayText = GetTranType(docTypeName, tranTypeId);
                    break;

                case "Amount":
                    e.DisplayText = GetAmountDisplay(docTypeName, docId);
                    break;

                case "Remarks":
                    e.DisplayText = GetRemarks(docTypeName, docId);
                    break;

                case "Preparer":
                    e.DisplayText = GetPreparer(docTypeName, docId);
                    break;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            // Parameters: expected format "<rowKey>|<action>"
            var parts = (e.Parameters ?? string.Empty).Split('|');
            if (parts.Length == 0) return;

            string rowKey = parts[0];
            string action = parts.Length > 1 ? parts[1] : string.Empty;

            // Batch fetch of needed row values (reduces multiple GetRowValuesByKeyValue calls)
            var neededFields = new[]
            {
                "Document_Id","CompanyId","WFA_Id","WF_Id","WFD_Id","Status",
                "AppDocTypeId"
            };

            var rowValues = expenseGrid.GetRowValuesByKeyValue(rowKey, neededFields) as object[];
            if (rowValues == null) return;

            int idx = 0;
            var documentId = ToInt(rowValues[idx++]);
            var companyId = rowValues[idx++];
            var wfaId = rowValues[idx++];
            var wfId = rowValues[idx++];
            var wfdId = rowValues[idx++];
            var status = rowValues[idx++];
            var appDocTypeId = ToInt(rowValues[idx++]);

            Session["TravelExp_Id"] = documentId;
            Session["comp"] = companyId;
            Session["PassActID"] = wfaId;
            Session["wfa"] = wfaId;
            Session["wf"] = wfId;
            Session["wfd"] = wfdId;
            Session["doc_stat"] = status;
            Session["stat_desc"] = "LineFAP";

            // These two are only meaningful for travel expense forms; keep original logic safe
            Session["prep"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == documentId).Select(x => x.Preparer_Id).FirstOrDefault();
            Session["empid"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == documentId).Select(x => x.Employee_Id).FirstOrDefault();

            string docTypeName = GetDocumentTypeName(appDocTypeId);

            string actID = Convert.ToString(Session["PassActID"]);
            string encryptedID = Encrypt(actID);

            // Pre-fetch main entities only when necessary
            var expenseMain = docTypeName == "ACDE Expense"
                ? context.ACCEDE_T_ExpenseMains.FirstOrDefault(x => x.ID == documentId)
                : null;

            if (action == "btnEdit")
            {
                ASPxWebControl.RedirectOnCallback("~/TravelExpenseAdd.aspx");
                return;
            }

            if (action == "btnView")
            {
                switch (docTypeName)
                {
                    case "ACDE RFP":
                        ASPxWebControl.RedirectOnCallback($"~/RFPApprovalView.aspx?secureToken={encryptedID}");
                        break;
                    case "ACDE Expense":
                        if (expenseMain != null && expenseMain.ExpenseType_ID == 3)
                            ASPxWebControl.RedirectOnCallback($"~/AccedeNonPOApprovalView.aspx?secureToken={encryptedID}");
                        else
                            ASPxWebControl.RedirectOnCallback($"~/ExpenseApprovalView.aspx?secureToken={encryptedID}");
                        break;
                    case "ACDE Expense Travel":
                        ASPxWebControl.RedirectOnCallback("~/TravelExpenseReview.aspx");
                        break;
                    case "ACDE InvoiceNPO":
                        ASPxWebControl.RedirectOnCallback($"~/AccedeNonPOApprovalView.aspx?secureToken={encryptedID}");
                        break;
                }
            }
        }

        private string Encrypt(string plainText)
        {
            // NOTE: This is simple Base64 encoding, NOT real encryption. Replace with proper crypto if security is required.
            if (plainText == null) return string.Empty;
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(plainText));
        }
    }
}