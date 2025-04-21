using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TravelExpense : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                Session["Employee_Id"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.Employee_Id == Convert.ToInt32(Session["userID"])).Select(x => x.Employee_Id).FirstOrDefault();
                Session["Preparer_Id"] = context.ACCEDE_T_TravelExpenseMains.Where(x => x.Preparer_Id == Convert.ToInt32(Session["userID"])).Select(x => x.Preparer_Id).FirstOrDefault();

                sqlTravelExp.SelectParameters["Preparer_Id"].DefaultValue = !string.IsNullOrEmpty(Convert.ToString(Session["Preparer_Id"])) ? Convert.ToString(Session["Preparer_Id"]) : "0";
                sqlTravelExp.SelectParameters["Employee_Id"].DefaultValue = !string.IsNullOrEmpty(Convert.ToString(Session["Employee_Id"])) ? Convert.ToString(Session["Employee_Id"]) : "0";

                employeeCB.Value = Session["userID"];
                //compCB.Value = Convert.ToString(Session["userCompanyID"]);
                //var depcode = context.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(Session["userID"])).Select(x => x.DepCode).FirstOrDefault();
                //var isdep = Convert.ToString(context.ITP_S_OrgDepartmentMasters.Where(x => x.DepCode == depcode && x.Company_ID == Convert.ToInt32(Session["userCompanyID"])).Select(x => x.ID).FirstOrDefault());

                //if (isdep == "0")
                //    chargedCB.SelectedIndex = -1;
                //else
                //    chargedCB.Value = isdep;
                sqlCompany.SelectParameters["UserId"].DefaultValue = Session["userID"].ToString();


                SqlDepartmentEdit.SelectParameters["UserId"].DefaultValue = Convert.ToString(Session["userID"]);
                SqlCompanyEdit.SelectParameters["UserId"].DefaultValue = Convert.ToString(Session["userID"]);

                SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Convert.ToString(compCB.Value);
                SqlDepartmentEdit.DataBind();

                sqlName.SelectParameters["EmpCode"].DefaultValue = Session["userID"].ToString();

                DataView dv = (DataView)sqlName.Select(DataSourceSelectArguments.Empty);
                DataTable dt = dv.ToTable();

                var list = dt.AsEnumerable()
                             .Select(row => new MyItem
                             {
                                 ID = row.Field<string>("EmpCode"),
                                 Name = row.Field<string>("FullName")
                             })
                             .ToList();

                DataView dv1 = (DataView)SqlUsersDelegated.Select(DataSourceSelectArguments.Empty);
                DataTable dt1 = dv1.ToTable();

                var list2 = dt1.AsEnumerable()
                             .Select(row => new MyItem
                             {
                                 ID = row.Field<string>("DelegateFor_UserID"),
                                 Name = row.Field<string>("FullName")
                             })
                             .ToList();

                var combinedList = list.Concat(list2).ToList();

                employeeCB.DataSource = combinedList;
                employeeCB.TextField = "Name";
                employeeCB.ValueField = "ID";
                employeeCB.DataBind();
            }
            else
                Response.Redirect("~/Logon.aspx");
        }

        public class MyItem
        {
            public string ID { get; set; }
            public string Name { get; set; }
        }

        [WebMethod]

        public static UserInfo AJAXGetUserInfo(string fullname)
        {
            TravelExpense travel = new TravelExpense();
            UserInfo user = travel.GetUserInfo(fullname);

            return user;
        }

        [WebMethod]
        public static bool AJAXSaveTravelExpense(string empcode, string companyid, string department_code, string chargedtoComp, string chargedtoDept, string tripto, DateTime datefrom, DateTime dateto, string timedepart, string timearrive, string purpose, string ford, string locbranch)
        {
            DateTime timeDepart = Convert.ToDateTime(timedepart);
            DateTime timeArrive = Convert.ToDateTime(timearrive);
            TravelExpense travel = new TravelExpense();
            return travel.SaveTravelExpense(empcode, companyid, department_code, chargedtoComp, chargedtoDept, tripto, datefrom, dateto, timeDepart.ToString("HH:mm"), timeArrive.ToString("HH:mm"), purpose, ford, DateTime.Now, locbranch);
        }

        public UserInfo GetUserInfo(string fullname)
        {
            UserInfo user = new UserInfo();

            try
            {
                // USE LINQ TO QUERY DATA FROM DATABASE
                var query = from emp in context.ITP_S_UserMasters
                            where emp.FullName == fullname && emp.IsActive == true
                            select emp;

                // BIND RESULT TO FIELDS
                foreach (ITP_S_UserMaster emp in query)
                {
                    user.depcode = context.ITP_S_OrgDepartmentMasters.Where(x => x.DepCode == emp.DepCode && x.Company_ID == emp.CompanyID).Select(x => x.ID).FirstOrDefault();
                    user.companyid = emp.CompanyID;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

            return user;
        }

        public bool SaveTravelExpense(string empcode, string companyid, string department_code, string chargedtoComp, string chargedtoDept, string tripto, DateTime datefrom, DateTime dateto, string timedepart, string timearrive, string purpose, string ford, DateTime datecreated, string locbranch)
        {
            try
            {
                var app_docType = Convert.ToInt32(context.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault());
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(Convert.ToInt32(app_docType), Convert.ToInt32(chargedtoComp), 1032);
                var docNo = generateDocNo.GetLatest_DocNum(Convert.ToInt32(app_docType), Convert.ToInt32(chargedtoComp), 1032);

                ACCEDE_T_TravelExpenseMain travelMain = new ACCEDE_T_TravelExpenseMain();
                {
                    travelMain.Employee_Id = Convert.ToInt32(empcode);
                    travelMain.Company_Id = Convert.ToInt32(companyid);
                    travelMain.Dep_Code = department_code;
                    travelMain.ChargedToComp = Convert.ToInt32(chargedtoComp) == 0 ? Convert.ToInt32(null) : Convert.ToInt32(chargedtoComp);
                    travelMain.ChargedToDept = Convert.ToInt32(chargedtoDept) == 0 ? Convert.ToInt32(null) : Convert.ToInt32(chargedtoDept);
                    travelMain.Trip_To = tripto;
                    travelMain.Date_From = datefrom;
                    travelMain.Date_To = dateto;
                    travelMain.Time_Departed = TimeSpan.Parse(timedepart);
                    travelMain.Time_Arrived = TimeSpan.Parse(timearrive);
                    travelMain.Purpose = purpose;
                    travelMain.ForeignDomestic = ford;
                    travelMain.Date_Created = datecreated;
                    travelMain.Doc_No = docNo;
                    travelMain.Preparer_Id = Convert.ToInt32(Session["userID"]);
                    travelMain.LocBranch = Convert.ToInt32(locbranch);
                }
                context.ACCEDE_T_TravelExpenseMains.InsertOnSubmit(travelMain);
                context.SubmitChanges();

                Session["TravelExp_Id"] = travelMain.ID;
                Session["main_action"] = "add";

            }
            catch (Exception)
            {
                return false;
            }

            return true;
        }

        protected void expenseGrid_CustomColumnDisplayText(object sender, DevExpress.Web.ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "Time_Arrived" && e.Column.Caption == "Time Arrived")
            {
                TimeSpan time = (TimeSpan)e.Value;
                DateTime time1 = new DateTime(time.Ticks);
                e.DisplayText = time1.ToString("hh:mm tt", new CultureInfo("en-us"));
            }

            if (e.Column.FieldName == "Time_Departed" && e.Column.Caption == "Time Departed")
            {
                TimeSpan time = (TimeSpan)e.Value;
                DateTime time1 = new DateTime(time.Ticks);
                e.DisplayText = time1.ToString("hh:mm tt", new CultureInfo("en-us"));
            }

            if (e.Column.FieldName == "Employee_Id" && e.Column.Caption == "Employee Name")
            {
                var name = context.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(e.Value)).Select(x => x.FullName).FirstOrDefault();
                e.DisplayText = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(name.ToLower());

            }

            if (e.Column.FieldName == "Preparer_Id" && e.Column.Caption == "Prepared By")
            {
                var name = context.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(e.Value)).Select(x => x.FullName).FirstOrDefault();
                e.DisplayText = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(name.ToLower());

            }
        }

        protected void expenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];

            Session["TravelExp_Id"] = e.Parameters.Split('|').First();
            Session["prep"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Preparer_Id");
            Session["doc_stat"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            Session["main_action"] = "edit";
            if (e.Parameters.Split('|').Last() == "btnEdit")
            {
                ASPxWebControl.RedirectOnCallback("TravelExpenseAdd.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnView")
            {
                ASPxWebControl.RedirectOnCallback("TravelExpenseView.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnPrint")
            {
                expenseGrid.JSProperties["cp_btnid"] = "btnPrint";
                expenseGrid.JSProperties["cp_url"] = "TravelExpensePrint.aspx";
            }
        }

        protected void expenseGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnEdit") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = expenseGrid.GetRowValues(e.VisibleIndex, "Status");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (statusValue.ToString() == "13" || statusValue.ToString() == "3"))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else if(statusValue.ToString() == "")
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }

            if (e.VisibleIndex >= 0 && e.ButtonID == "btnPrint") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = expenseGrid.GetRowValues(e.VisibleIndex, "Status");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (statusValue.ToString() == "7" || statusValue.ToString() == "5"))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void depCB_Callback(object sender, CallbackEventArgsBase e)
        {
            if (e.Parameter != null && e.Parameter != "")
            {
                SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = e.Parameter.ToString();
                SqlDepartmentEdit.SelectParameters["UserId"].DefaultValue = employeeCB.Value.ToString();
                SqlDepartmentEdit.DataBind();

                depCB.DataSourceID = null;
                depCB.DataSource = SqlDepartmentEdit;
                depCB.DataBind();

                depCB.SelectedIndex = 0;
            }
        }

        protected void chargedCB0_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlDepartment.DataBind();

            chargedCB0.DataSourceID = null;
            chargedCB0.DataSource = SqlDepartment;
            chargedCB0.DataBind();
        }

        protected void locBranch_Callback(object sender, CallbackEventArgsBase e)
        {
            if (e.Parameter != null && e.Parameter != "")
            {
                SqlLocBranch.SelectParameters["Comp_Id"].DefaultValue = e.Parameter.ToString();
                SqlLocBranch.DataBind();

                locBranch.DataSourceID = null;
                locBranch.DataSource = SqlLocBranch;
                locBranch.DataBind();
            }
        }
    }
}

public class UserInfo
{
    public int depcode { get; set; }
    public int companyid { get; set; }
}