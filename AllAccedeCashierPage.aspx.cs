using DevExpress.DataProcessing.InMemoryDataProcessor.GraphGenerator;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AllAccedeCashierPage : System.Web.UI.Page
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
            object value = e.GetFieldValue("AppDocTypeId");
            int app = (value != DBNull.Value) ? Convert.ToInt32(value) : 0;
            var id = Convert.ToInt32(e.GetFieldValue("Document_Id"));

            if (e.Column.Caption == "Document No.")
            {
                string docno = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                        docno = Convert.ToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.RFP_DocNum).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense")
                        docno = Convert.ToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.DocNo).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense Travel")
                        docno = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Doc_No).FirstOrDefault() ?? string.Empty);
                }

                e.DisplayText = docno;
            }

            if (e.Column.Caption == "Employee Name")
            {
                string empname = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                    {
                        string useridRaw = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Payee).FirstOrDefault();
                        string userid = new string(useridRaw?.Where(char.IsDigit).ToArray());
                        if (!string.IsNullOrEmpty(userid))
                        {
                            empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault()?.ToUpper() ?? string.Empty;
                        }
                    }
                    else if (appname == "ACDE Expense")
                    {
                        string useridRaw = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpenseName).FirstOrDefault();
                        string userid = new string(useridRaw?.Where(char.IsDigit).ToArray());
                        if (!string.IsNullOrEmpty(userid))
                        {
                            empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault()?.ToUpper() ?? string.Empty;
                        }
                    }
                    else if (appname == "ACDE Expense Travel")
                    {
                        string useridRaw = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Employee_Id).FirstOrDefault());
                        string userid = new string(useridRaw?.Where(char.IsDigit).ToArray());
                        if (!string.IsNullOrEmpty(userid))
                        {
                            empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault()?.ToUpper() ?? string.Empty;
                        }
                    }
                }

                e.DisplayText = empname;
            }

            if (e.Column.Caption == "Location")
            {
                string loc_id = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                    {
                        loc_id = Convert.ToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Comp_Location_Id).FirstOrDefault());
                        //if (depid != 0)
                        //    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == depid).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                    }
                    else if (appname == "ACDE Expense")
                    {
                        loc_id = Convert.ToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.ExpComp_Location_Id).FirstOrDefault());
                        //if (depid != 0)
                        //    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == depid).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                    }
                    else if (appname == "ACDE Expense Travel")
                    {
                        loc_id = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.LocBranch).FirstOrDefault());
                        //if (!string.IsNullOrEmpty(depid))
                        //    department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(depid)).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                    }
                }

                e.Value = loc_id;
            }

            if (e.Column.Caption == "Remarks")
            {
                string remarks = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                        remarks = Convert.ToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense")
                        remarks = Convert.ToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.remarks).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense Travel")
                        remarks = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Remarks).FirstOrDefault() ?? string.Empty);
                }

                e.DisplayText = remarks;
            }

            if (e.Column.Caption == "Purpose")
            {
                string purpose = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                        purpose = Convert.ToString(context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense")
                        purpose = Convert.ToString(context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault() ?? string.Empty);
                    else if (appname == "ACDE Expense Travel")
                        purpose = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Purpose).FirstOrDefault() ?? string.Empty);
                }

                e.DisplayText = purpose;
            }

            if (e.Column.Caption == "Preparer")
            {
                string preparer = "";

                if (app != 0)
                {
                    var appname = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == app).Select(x => x.DCT_Name).FirstOrDefault();
                    if (appname == "ACDE RFP")
                    {
                        string userid = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).Select(x => x.User_ID).FirstOrDefault();
                        if (!string.IsNullOrEmpty(userid))
                            preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                    }
                    else if (appname == "ACDE Expense")
                    {
                        string userid = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == id).Select(x => x.UserId).FirstOrDefault();
                        if (!string.IsNullOrEmpty(userid))
                            preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                    }
                    else if (appname == "ACDE Expense Travel")
                    {
                        string userid = Convert.ToString(context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Preparer_Id).FirstOrDefault());
                        if (!string.IsNullOrEmpty(userid))
                            preparer = context.ITP_S_UserMasters.Where(x => x.EmpCode == userid).Select(x => x.FullName).FirstOrDefault().ToUpper();
                    }
                }

                e.DisplayText = preparer;
            }
        }

        protected void expenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];

            Session["TravelExp_Id"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Document_Id");
            Session["comp"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "CompanyId");
            Session["PassActID"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            Session["wfa"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            Session["wf"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            Session["wfd"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");
            Session["doc_stat"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            Session["stat_desc"] = "Cashier";
            var app = context.ITP_S_DocumentTypes.Where(x => x.DCT_Id == Convert.ToInt32(expenseGrid.GetRowValuesByKeyValue(rowKey, "AppDocTypeId"))).Select(x => x.DCT_Name).FirstOrDefault();

            string actID = Convert.ToString(Session["wfa"]);
            string encryptedID = Encrypt(actID);
            Session["passRFPID"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Document_Id");
            Session["ExpenseId"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Document_Id");


            Debug.WriteLine("Main ID: " + Session["TravelExp_Id"]);
            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (e.Parameters.Split('|').Last() == "btnEdit")
            {
                //ASPxWebControl.RedirectOnCallback("TravelExpenseAdd.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnView")
            {
                if (app == "ACDE RFP")
                {
                    ASPxWebControl.RedirectOnCallback("~/RFPViewPage.aspx");
                }
                else if (app == "ACDE Expense")
                {
                    string redirectUrl = $"~/AccedeCashierExpenseViewPage.aspx?secureToken={encryptedID}";
                    ASPxWebControl.RedirectOnCallback(redirectUrl);
                }
                else if (app == "ACDE Expense Travel")
                {
                    Session["prep"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Preparer_Id).FirstOrDefault();
                    Session["empid"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Employee_Id).FirstOrDefault();
                    ASPxWebControl.RedirectOnCallback("~/TravelExpenseReview.aspx");
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