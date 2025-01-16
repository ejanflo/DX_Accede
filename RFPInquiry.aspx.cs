using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class RFPInquiry : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

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

                    SqlRFP.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlWF.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlDepartmentEdit.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlCompanyEdit.SelectParameters["UserId"].DefaultValue = empCode;

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

        protected void gridMain_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["passRFPID"] = e.Parameters.Split('|').First();
            //ASPxWebControl.RedirectOnCallback("RFPViewPage.aspx");

            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

            Session["CompID"] = rfp_main.Company_ID;

            SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Session["CompID"].ToString();
            SqlDepartmentEdit.DataBind();

            Department_modal.DataSourceID = null;
            Department_modal.DataSource = SqlDepartmentEdit;
            Department_modal.DataBind();
        }

        protected void ASPxGridView2_BeforePerformDataSelect1(object sender, EventArgs e)
        {
            Session["MainRFP_ID"] =
                (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void ASPxGridView2_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
        {

        }

        protected void Department_modal_Callback(object sender, CallbackEventArgsBase e)
        {
            if (e != null)
            {
                Session["CompID"] = e.Parameter;
            }
            SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Session["CompID"].ToString();
            SqlDepartmentEdit.DataBind();

            Department_modal.DataSourceID = null;
            Department_modal.DataSource = SqlDepartmentEdit;
            Department_modal.DataBind();
        }

        protected void WFSequenceGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF_modal.Value != null ? drpdown_WF_modal.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }
    }
}