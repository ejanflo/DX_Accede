using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;

namespace DX_WebTemplate
{
    public partial class AllAccedeCashierPage : System.Web.UI.Page
    {
        private readonly ITPORTALDataContext _context =
            new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        // Caches for this request lifecycle
        private readonly Dictionary<int, string> _docTypeNameCache = new Dictionary<int, string>();
        private readonly Dictionary<(int DocTypeId, int DocId), DocumentDisplayData> _docDataCache =
            new Dictionary<(int DocTypeId, int DocId), DocumentDisplayData>();

        // Central constants to avoid magic strings
        private const string DT_RFP = "ACDE RFP";
        private const string DT_EXP = "ACDE Expense";
        private const string DT_EXP_TRAVEL = "ACDE Expense Travel";
        private const string DT_INVOICE_NPO = "ACDE InvoiceNPO";

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
            if (e.Column == null)
                return;

            // Acquire common field values once
            int docTypeId = SafeToInt(e.GetFieldValue("AppDocTypeId"));
            int tranType = SafeToInt(e.GetFieldValue("TranType"));
            int docId = SafeToInt(e.GetFieldValue("Document_Id"));
            if (docTypeId == 0 || docId == 0)
            {
                return;
            }

            string docTypeName = GetDocTypeName(docTypeId);
            if (string.IsNullOrEmpty(docTypeName))
                return;

            // Get or build aggregated data for this row
            var data = GetDocumentDisplayData(docTypeId, docTypeName, docId, tranType);

            // Switch on caption (existing logic preserved)
            switch (e.Column.Caption)
            {
                case "Document No.":
                    e.DisplayText = data.DocNo ?? string.Empty;
                    break;
                case "Employee Name/Vendor":
                    e.DisplayText = data.EmployeeOrVendor ?? string.Empty;
                    break;
                case "Department":
                    e.DisplayText = data.Department ?? string.Empty;
                    break;
                case "Remarks":
                    e.DisplayText = data.Remarks ?? string.Empty;
                    break;
                case "Purpose":
                    e.DisplayText = data.Purpose ?? string.Empty;
                    break;
                case "Preparer":
                    e.DisplayText = data.Preparer ?? string.Empty;
                    break;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(e.Parameters))
                return;

            var args = e.Parameters.Split('|');
            string rowKey = args[0];
            string command = args.Length > 1 ? args[args.Length - 1] : string.Empty;

            // Minimize repeated GetRowValuesByKeyValue calls
            object GetVal(string field) => expenseGrid.GetRowValuesByKeyValue(rowKey, field);

            var documentIdObj = GetVal("Document_Id");
            var companyIdObj = GetVal("CompanyId");
            var wfaIdObj = GetVal("WFA_Id");
            var wfIdObj = GetVal("WF_Id");
            var wfdIdObj = GetVal("WFD_Id");
            var statusObj = GetVal("Status");
            var appDocTypeIdObj = GetVal("AppDocTypeId");

            Session["TravelExp_Id"] = documentIdObj;
            Session["comp"] = companyIdObj;
            Session["PassActID"] = wfaIdObj;
            Session["wfa"] = wfaIdObj;
            Session["wf"] = wfIdObj;
            Session["wfd"] = wfdIdObj;
            Session["doc_stat"] = statusObj;
            Session["stat_desc"] = "Cashier";
            Session["passRFPID"] = documentIdObj;
            Session["ExpenseId"] = documentIdObj;

            int appDocTypeId = SafeToInt(appDocTypeIdObj);
            string appName = GetDocTypeName(appDocTypeId);

            string actID = Convert.ToString(wfaIdObj);
            string encryptedID = Encrypt(actID);

            int docId = SafeToInt(documentIdObj);
            var expMain = _context.ACCEDE_T_ExpenseMains.FirstOrDefault(x => x.ID == docId);

            Debug.WriteLine("Main ID: " + Session["TravelExp_Id"]);
            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (command == "btnEdit")
            {
                // (Left intentionally - original commented out logic)
            }
            else if (command == "btnView")
            {
                if (appName == DT_RFP)
                {
                    ASPxWebControl.RedirectOnCallback("~/RFPViewPage.aspx");
                }
                else if (appName == DT_EXP)
                {
                    if (expMain != null && expMain.ExpenseType_ID == 3)
                    {
                        string redirectUrl = $"~/AccedeNonPO_CashierView.aspx?secureToken={encryptedID}";
                        ASPxWebControl.RedirectOnCallback(redirectUrl);
                    }
                    else
                    {
                        string redirectUrl = $"~/AccedeCashierExpenseViewPage.aspx?secureToken={encryptedID}";
                        ASPxWebControl.RedirectOnCallback(redirectUrl);
                    }
                }
                else if (appName == DT_EXP_TRAVEL)
                {
                    Session["prep"] = _context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == SafeToInt(Session["TravelExp_Id"]))
                        .Select(x => x.Preparer_Id).FirstOrDefault();
                    Session["empid"] = _context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == SafeToInt(Session["TravelExp_Id"]))
                        .Select(x => x.Employee_Id).FirstOrDefault();
                    ASPxWebControl.RedirectOnCallback("~/TravelExpenseReview.aspx");
                }
                else if (appName == DT_INVOICE_NPO)
                {
                    string redirectUrl = $"~/AccedeNonPO_CashierView.aspx?secureToken={encryptedID}";
                    ASPxWebControl.RedirectOnCallback(redirectUrl);
                }
            }
        }

        private string GetDocTypeName(int docTypeId)
        {
            if (docTypeId <= 0) return string.Empty;
            if (_docTypeNameCache.TryGetValue(docTypeId, out var name))
                return name;

            name = _context.ITP_S_DocumentTypes
                .Where(x => x.DCT_Id == docTypeId)
                .Select(x => x.DCT_Name)
                .FirstOrDefault() ?? string.Empty;

            _docTypeNameCache[docTypeId] = name;
            return name;
        }

        private DocumentDisplayData GetDocumentDisplayData(int docTypeId, string docTypeName, int docId, int tranType)
        {
            var key = (docTypeId, docId);
            if (_docDataCache.TryGetValue(key, out var cached))
                return cached;

            var data = new DocumentDisplayData();

            switch (docTypeName)
            {
                case DT_RFP:
                    {
                        var row = _context.ACCEDE_T_RFPMains
                            .Where(x => x.ID == docId)
                            .Select(x => new
                            {
                                x.RFP_DocNum,
                                x.Payee,
                                x.Department_ID,
                                x.Remarks,
                                x.Purpose,
                                x.User_ID
                            })
                            .FirstOrDefault();

                        if (row != null)
                        {
                            data.DocNo = row.RFP_DocNum ?? string.Empty;
                            data.EmployeeOrVendor = ResolveEmployeeNameFromMixed(row.Payee);
                            data.Department = ResolveDepartment(row.Department_ID);
                            data.Remarks = row.Remarks ?? string.Empty;
                            data.Purpose = row.Purpose ?? string.Empty;
                            data.Preparer = ResolveUserFullName(row.User_ID);
                        }
                        break;
                    }
                case DT_EXP:
                    {
                        var row = _context.ACCEDE_T_ExpenseMains
                            .Where(x => x.ID == docId)
                            .Select(x => new
                            {
                                x.DocNo,
                                x.ExpenseName,
                                x.ExpChargedTo_DeptId,
                                remarks = x.remarks,
                                x.Purpose,
                                x.UserId
                            })
                            .FirstOrDefault();

                        if (row != null)
                        {
                            data.DocNo = row.DocNo ?? string.Empty;
                            if (tranType != 3)
                                data.EmployeeOrVendor = ResolveEmployeeNameFromMixed(row.ExpenseName);
                            else
                                data.EmployeeOrVendor = row.ExpenseName ?? string.Empty;

                            data.Department = ResolveDepartment(row.ExpChargedTo_DeptId);
                            data.Remarks = row.remarks ?? string.Empty;
                            data.Purpose = row.Purpose ?? string.Empty;
                            data.Preparer = ResolveUserFullName(row.UserId);
                        }
                        break;
                    }
                case DT_EXP_TRAVEL:
                    {
                        var row = _context.ACCEDE_T_TravelExpenseMains
                            .Where(x => x.ID == docId)
                            .Select(x => new
                            {
                                x.Doc_No,
                                x.Employee_Id,
                                x.Dep_Code,
                                x.Remarks,
                                x.Purpose,
                                Preparer_Id = x.Preparer_Id
                            })
                            .FirstOrDefault();

                        if (row != null)
                        {
                            data.DocNo = row.Doc_No ?? string.Empty;
                            data.EmployeeOrVendor = ResolveEmployeeNameFromMixed(row.Employee_Id.ToString());
                            data.Department = ResolveDepartmentString(row.Dep_Code);
                            data.Remarks = row.Remarks ?? string.Empty;
                            data.Purpose = row.Purpose ?? string.Empty;
                            data.Preparer = ResolveUserFullName(row.Preparer_Id.ToString());
                        }
                        break;
                    }
                case DT_INVOICE_NPO:
                    {
                        var row = _context.ACCEDE_T_InvoiceMains
                            .Where(x => x.ID == docId)
                            .Select(x => new
                            {
                                x.DocNo,
                                x.VendorName,
                                x.InvChargedTo_DeptId,
                                x.Purpose,
                                x.UserId
                            })
                            .FirstOrDefault();

                        if (row != null)
                        {
                            data.DocNo = row.DocNo ?? string.Empty;
                            data.EmployeeOrVendor = row.VendorName ?? string.Empty;
                            data.Department = ResolveDepartment(row.InvChargedTo_DeptId);
                            data.Purpose = row.Purpose ?? string.Empty;
                            data.Preparer = ResolveUserFullName(row.UserId);
                        }
                        break;
                    }
            }

            _docDataCache[key] = data;
            return data;
        }

        private string ResolveEmployeeNameFromMixed(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return string.Empty;
            string digits = new string(raw.Where(char.IsDigit).ToArray());
            if (string.IsNullOrEmpty(digits)) return string.Empty;

            var name = _context.ITP_S_UserMasters
                .Where(x => x.EmpCode == digits)
                .Select(x => x.FullName)
                .FirstOrDefault();

            return name?.ToUpper() ?? string.Empty;
        }

        private string ResolveDepartment(object deptIdObj)
        {
            int depId = SafeToInt(deptIdObj);
            if (depId <= 0) return string.Empty;

            var depName = _context.ITP_S_OrgDepartmentMasters
                .Where(x => x.ID == depId)
                .Select(x => x.DepDesc)
                .FirstOrDefault();

            return depName?.ToUpper() ?? string.Empty;
        }

        private string ResolveDepartmentString(string deptIdStr)
        {
            if (string.IsNullOrWhiteSpace(deptIdStr))
                return string.Empty;

            if (!int.TryParse(deptIdStr, out int depId))
                return string.Empty;

            return ResolveDepartment(depId);
        }

        private string ResolveUserFullName(string empCode)
        {
            if (string.IsNullOrEmpty(empCode))
                return string.Empty;

            var name = _context.ITP_S_UserMasters
                .Where(x => x.EmpCode == empCode)
                .Select(x => x.FullName)
                .FirstOrDefault();

            return name?.ToUpper() ?? string.Empty;
        }

        private int SafeToInt(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            int.TryParse(value.ToString(), out int result);
            return result;
        }

        private string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
                return string.Empty;
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(plainText));
        }

        protected override void OnUnload(EventArgs e)
        {
            base.OnUnload(e);
            _context.Dispose();
        }

        private sealed class DocumentDisplayData
        {
            public string DocNo { get; set; }
            public string EmployeeOrVendor { get; set; }
            public string Department { get; set; }
            public string Remarks { get; set; }
            public string Purpose { get; set; }
            public string Preparer { get; set; }
        }
    }
}