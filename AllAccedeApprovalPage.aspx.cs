using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DevExpress.XtraEditors.Mask.MaskSettings;

namespace DX_WebTemplate
{
    public partial class AllAccedeApprovalPage : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
            }
            else
                Response.Redirect("~/Logon.aspx");
        }

        protected void expenseGrid_CustomColumnDisplayText(object sender, DevExpress.Web.ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.Caption == "Document No.")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string docno = "";
                if (appname == "ACDE RFP")
                    docno = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.RFP_DocNum).FirstOrDefault();
                else if (appname == "ACDE Expense")
                    docno = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.DocNo).FirstOrDefault();
                else if (appname == "ACDE Expense Travel")
                    docno = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Doc_No).FirstOrDefault();

                e.DisplayText = docno;
            }

            if (e.Column.Caption == "Employee Name")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string empname = "";
                if (appname == "ACDE RFP")
                {
                    string userid = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Payee).FirstOrDefault();
                    empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense")
                {
                    string userid = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpenseName).FirstOrDefault();
                    empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense Travel")
                {
                    string userid = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Employee_Id).FirstOrDefault());
                    empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }

                e.DisplayText = empname;
            }

            if (e.Column.Caption == "Department")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string department = "";
                if (appname == "ACDE RFP")
                {
                    int depid = Convert.ToInt32(context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Department_ID).FirstOrDefault());
                    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == depid).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense")
                {
                    int depid = Convert.ToInt32(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.Dept_Id).FirstOrDefault());
                    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == depid).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense Travel")
                {
                    string depid = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Dep_Code).FirstOrDefault());
                    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(depid)).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                }

                e.DisplayText = department;
            }

            if (e.Column.Caption == "Remarks")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string remarks = "";
                if (appname == "ACDE RFP")
                    remarks = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault();
                else if (appname == "ACDE Expense")
                    remarks = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.remarks).FirstOrDefault();
                else if (appname == "ACDE Expense Travel")
                    remarks = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault();

                e.DisplayText = remarks;
            }

            if (e.Column.Caption == "Purpose")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string purpose = "";
                if (appname == "ACDE RFP")
                    purpose = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault();
                else if (appname == "ACDE Expense")
                    purpose = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault();
                else if (appname == "ACDE Expense Travel")
                    purpose = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault();

                e.DisplayText = purpose;
            }

            if (e.Column.Caption == "Preparer")
            {
                var app = Convert.ToInt32(e.GetFieldValue("AppDocTypeId"));
                var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));
                var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                string preparer = "";
                if (appname == "ACDE RFP")
                {
                    string userid = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.User_ID).FirstOrDefault();
                    preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense")
                {
                    string userid = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault();
                    preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }
                else if (appname == "ACDE Expense Travel")
                {
                    string userid = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Preparer_Id).FirstOrDefault());
                    preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                }

                e.DisplayText = preparer;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];

            Session["TravelExp_Id"] = e.Parameters.Split('|').First();
            Session["comp"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "CompanyId");
            Session["PassActID"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            Session["wfa"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            Session["wf"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            Session["wfd"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");
            Session["doc_stat"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            var app = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == Convert.ToInt32(expenseGrid.GetRowValuesByKeyValue(rowKey, "AppDocTypeId"))).Select(x => x.DCT_Name).FirstOrDefault();

            string actID = Convert.ToString(Session["wfa"]);
            string encryptedID = Encrypt(actID);


            Debug.WriteLine("Main ID: " + Session["TravelExp_Id"]);
            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (e.Parameters.Split('|').Last() == "btnEdit")
            {
                ASPxWebControl.RedirectOnCallback("TravelExpenseAdd.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnView")
            {
                if (app == "ACDE RFP")
                {
                    //ASPxWebControl.RedirectOnCallback("RFPApprovalView.aspx");
                    string redirectUrl = $"RFPApprovalView.aspx?secureToken={encryptedID}";
                    ASPxWebControl.RedirectOnCallback(redirectUrl);
                }
                else if (app == "ACDE Expense")
                {
                    //ASPxWebControl.RedirectOnCallback("ExpenseApprovalView.aspx");
                    string redirectUrl = $"ExpenseApprovalView.aspx?secureToken={encryptedID}";
                    ASPxWebControl.RedirectOnCallback(redirectUrl);
                }
                else if (app == "ACDE Expense Travel")
                {
                    Session["prep"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Preparer_Id).FirstOrDefault();
                    Session["empid"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Employee_Id).FirstOrDefault();
                    ASPxWebControl.RedirectOnCallback("TravelExpenseReview.aspx");
                }
                    
            }
        }

        private string Encrypt(string plainText)
        {
            // Example: Use a proper encryption library like AES or RSA for actual implementations
            // This is just a placeholder for encryption logic
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText));
        }
    }
}