using DevExpress.Web;
using System;
using System.IO;
using System.Web;

namespace DX_WebTemplate.Workflow
{
    public partial class SecurityWorkflowGroup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                //Start ------------------ Page Security
                string empCode = Session["userID"].ToString();
                int appID = 22; //22-ITPORTAL; 13-CAR; 26-RS; 1027-RFP; 1028-UAR

                string url = Request.Url.AbsolutePath; // Get the current URL
                string pageName = Path.GetFileNameWithoutExtension(url); // Get the filename without extension


                if (!AnfloSession.Current.hasPageAccess(empCode, appID, pageName))
                {
                    Session["appID"] = appID.ToString();
                    Session["pageName"] = pageName.ToString();

                    Response.Redirect("~/ErrorAccess.aspx");
                }
                //End ------------------ Page Security

            }
            else
            {
                Response.Redirect("Logon.aspx");
            }

        }
        protected void gridGroupDetail_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterGroupID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("App_Id");
            Session["MasterCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("Company_Id");

            sqlWorkflow.SelectParameters["App_Id"].DefaultValue = Session["MasterAppID"].ToString();
            sqlWorkflow.SelectParameters["Company_Id"].DefaultValue = Session["MasterCompanyID"].ToString();
        }

        protected void gridGroupDetail_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["WFG_Id"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }
    }
}
