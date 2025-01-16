using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportApproval : System.Web.UI.Page
    {
        // CREATE objects of DATABASE-ITPORTAL
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

        protected void expenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[1];

            object IDValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "ID");
            object statValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            object companyValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "Company_ID");
            object prepValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "User_ID");
            object docnoValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "DocNo");
            object wfa = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFA_Id");
            object wf = expenseGrid.GetRowValuesByKeyValue(rowKey, "WF_Id");
            object wfd = expenseGrid.GetRowValuesByKeyValue(rowKey, "WFD_Id");

            var query = from a in context.ITP_S_Status
                        where a.STS_Id == int.Parse(statValue.ToString())
                        select a.STS_Description;
            string stat = query.FirstOrDefault();

            Session["cID"] = IDValue;
            Session["comp"] = companyValue;
            Session["stat"] = stat;
            Session["prep"] = prepValue;
            Session["docno"] = docnoValue;
            Session["wfa"] = wfa;
            Session["wf"] = wf;
            Session["wfd"] = wfd;

            if (buttonId == "btnView")
            {
                expenseGrid.JSProperties["cp_btnid"] = "btnView";
                expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportApprovalReview.aspx";
            }
            else if (buttonId == "btnEdit")
            {
                Session["edit"] = true;
                expenseGrid.JSProperties["cp_btnid"] = "btnEdit";
                expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportSaves.aspx";
            }
            else if (buttonId == "btnPrint")
            {
                expenseGrid.JSProperties["cp_btnid"] = "btnPrint";
                expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportPrint.aspx";
            }

        }
    }
}