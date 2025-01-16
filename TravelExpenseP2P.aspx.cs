using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TravelExpenseP2P : System.Web.UI.Page
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
            Session["comp"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Company_Id");
            Session["wfa"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            Session["wf"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            Session["wfd"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");
            Session["empid"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Employee_Id");
            Session["doc_stat"] = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");

            Debug.WriteLine("WFA :" + Session["wfa"]);
            Debug.WriteLine("WF :" + Session["wf"]);
            Debug.WriteLine("WFD :" + Session["wfd"]);

            if (e.Parameters.Split('|').Last() == "btnEdit")
            {
                ASPxWebControl.RedirectOnCallback("TravelExpenseAdd.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnView")
            {
                ASPxWebControl.RedirectOnCallback("TravelExpenseReview.aspx");
            }
        }
    }
}