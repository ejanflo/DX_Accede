using DevExpress.DataAccess.DataFederation;
using DevExpress.DataProcessing.InMemoryDataProcessor.GraphGenerator;
using DevExpress.Pdf.Xmp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class CashierInquiryPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        // Central constants to avoid magic strings
        private const string DT_RFP = "ACDE RFP";
        private const string DT_EXP = "ACDE Expense";
        private const string DT_EXP_TRAVEL = "ACDE Expense Travel";
        private const string DT_INVOICE_NPO = "ACDE InvoiceNPO";
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    if (!IsPostBack)
                    {
                        var pcTabs = ASPxFormLayout1.FindItemOrGroupByName("layoutTab") as TabbedLayoutGroup;
                        string tabName = Request.QueryString["tab"];
                        if (!string.IsNullOrEmpty(tabName))
                        {
                            if (tabName == "rfpDisbursedTab")
                                pcTabs.ActiveTabIndex = 1;
                            else if (tabName == "expenseDisbursedTab")
                                pcTabs.ActiveTabIndex = 2;
                        }
                    }

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

                    SqlRFPDisbursed.SelectParameters["ActedBy_User_Id"].DefaultValue = empCode;
                    SqlExpDisbursed.SelectParameters["ActedBy_User_Id"].DefaultValue = empCode;
                    //SqlRFPDisbursed.SelectParameters["STS_Name"].DefaultValue = "Disbursed";

                    var p2pStatus = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Cashier").FirstOrDefault();
                    SqlRFP.SelectParameters["Status"].DefaultValue = p2pStatus.STS_Id.ToString();
                    SqlRFP.SelectParameters["RoleUserId"].DefaultValue = empCode;
                    SqlRFP.SelectParameters["Role_Name"].DefaultValue = "Accede Cashier";

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

        protected void gridMain_CustomButtonInitialize(object sender, DevExpress.Web.ASPxGridViewCustomButtonEventArgs e)
        {
            //if (e.VisibleIndex >= 0 && e.ButtonID == "btnPrint") // Ensure it's a data row and the button is the desired one
            //{
            //    //Get the value of the "Status" column for the current row
            //    object statusValue = gridMain.GetRowValues(e.VisibleIndex, "Status");

            //    //Check if the status is "saved" and make the button visible accordingly
            //    if (statusValue != null && (statusValue.ToString() == "7"))
            //        e.Visible = DevExpress.Utils.DefaultBoolean.True;
            //    else
            //        e.Visible = DevExpress.Utils.DefaultBoolean.False;
            //}
        }

        protected void gridMain_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[2];
            string source = args[1];

            

        }

        private string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
                return string.Empty;
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(plainText));
        }

        protected void gridMainDisbursed_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[2];
            string source = args[1];

            object GetVal(string field) => gridMainDisbursed.GetRowValuesByKeyValue(rowKey, field);

            var documentIdObj = GetVal("Document_Id");
            var companyIdObj = GetVal("ChargedTo_CompanyId");
            var wfaIdObj = GetVal("WFA_Id");
            var wfIdObj = GetVal("WF_Id");
            var wfdIdObj = GetVal("WFD_Id");
            var statusObj = GetVal("Status");
            var appDocTypeIdObj = GetVal("AppDocTypeId");

            Session["passRFPID"] = documentIdObj;

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

            string actID = Convert.ToString(wfaIdObj);
            string encryptedID = Encrypt(actID);

            int docId = SafeToInt(documentIdObj);
            var expMain = _DataContext.ACCEDE_T_ExpenseMains.FirstOrDefault(x => x.ID == docId);

            if (buttonId == "btnPrint")
                ASPxWebControl.RedirectOnCallback("~/RFPPrintPage.aspx");

            if (buttonId == "btnViewDisbursed")
            {
                if (source == DT_RFP)
                {
                    ASPxWebControl.RedirectOnCallback("~/RFPViewPage.aspx");
                }
                else if (source == DT_EXP)
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
                else if (source == DT_EXP_TRAVEL)
                {
                    Session["prep"] = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == SafeToInt(Session["TravelExp_Id"]))
                        .Select(x => x.Preparer_Id).FirstOrDefault();
                    Session["empid"] = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == SafeToInt(Session["TravelExp_Id"]))
                        .Select(x => x.Employee_Id).FirstOrDefault();
                    ASPxWebControl.RedirectOnCallback("~/TravelExpenseView.aspx");
                }
                else if (source == DT_INVOICE_NPO)
                {
                    string redirectUrl = $"~/AccedeNonPO_CashierView.aspx?secureToken={encryptedID}";
                    ASPxWebControl.RedirectOnCallback(redirectUrl);
                }

            }

            //if (buttonId == "btnPrint")
            //    ASPxWebControl.RedirectOnCallback("~/RFPPrintPage.aspx");

            //if (buttonId == "btnViewDisbursed")
            //    ASPxWebControl.RedirectOnCallback("~/RFPViewPage.aspx");
        }

        private int SafeToInt(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            int.TryParse(value.ToString(), out int result);
            return result;
        }

        protected void gridMainDisbursed_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            //if (e.DataColumn.FieldName == "Amount")
            //{
            //    if (e.CellValue != null && e.CellValue is decimal)
            //    {
            //        e.Cell.Text = ((decimal)e.CellValue).ToString("#,##0.##");
            //    }
            //}

            //if (e.DataColumn.FieldName == "Status")
            //{
            //    string value = e.CellValue.ToString();
            //    if (value == "7")
            //    {
            //        e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");//approved
            //        e.Cell.Font.Bold = true;
            //    }
            //    else if (value == "2" || value == "3" || value == "18" || value == "19")
            //    {
            //        e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#E67C0E");//rejected
            //        e.Cell.Font.Bold = true;
            //    }
            //    else if (value == "1")
            //    {
            //        e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#006DD6");//pending
            //        e.Cell.Font.Bold = true;
            //    }
            //    else if (value == "8")
            //    {
            //        e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#CC2A17");//disapproved
            //        e.Cell.Font.Bold = true;
            //    }
            //    else
            //    {
            //        e.Cell.ForeColor = System.Drawing.Color.Gray;
            //        e.Cell.Font.Bold = true;
            //    }
            //}
        }

        protected void gridMainDisburseExp_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[1];

            Session["ExpenseID"] = rowKey;

            //if (buttonId == "btnPrint")
            //    ASPxWebControl.RedirectOnCallback("~/RFPPrintPage.aspx");

            if (buttonId == "btnViewDisbursedExp")
                ASPxWebControl.RedirectOnCallback("~/AccedeExpenseViewPage.aspx");
        }

        protected void gridMainDisburseExp_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {

        }
    }
}