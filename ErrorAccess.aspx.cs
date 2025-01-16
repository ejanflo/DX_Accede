using DevExpress.PivotGrid.OLAP;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class ErrorAccess : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                try
                {
                    int appID = Convert.ToInt32(Session["appID"].ToString());
                    string pageName = Session["pageName"].ToString();

                    var queryTilesRole =
                    from role in context.vw_AGA_I_TilesRoles
                    where role.App_ID == appID && role.URL.Contains(pageName)
                    select role;

                    var roleName = "";

                    foreach (var roleInfo in queryTilesRole)
                    {
                        roleName += roleInfo.Role_Name + "\n";
                    }

                    lblPage.Text = pageName;
                    lblRole.Text = roleName;
                }
                catch
                {
                    Response.Redirect("~/Logon.aspx");
                }
               

            }
            else
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void btnCancel_Clicked(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }

        protected void btnUserAccessRequest_Click(object sender, EventArgs e)
        {

        }

        protected void btnHelpdesk_Click(object sender, EventArgs e)
        {

        }
    }
}