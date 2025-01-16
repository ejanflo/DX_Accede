using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Security
{
    public partial class EmulateUser : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {

                // Decrypt the ticket from the cookie
                FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(HttpContext.Current.Request.Cookies["AppAuthCookie"].Value);
                AnfloSession.Current.CreateSession(ticket.Name);


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
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void btnEmulate_Click(object sender, EventArgs e)
        {
            string usercookie = "";
            try
            {
                usercookie = Session["userID"].ToString();
            }
            catch (Exception ex)
            {
                Response.Redirect("~/Logon.aspx?" + ex.Message);
            }

            if (AnfloSession.Current.isAdminUser(usercookie))
                {
                //Clear Current Logged User
                    Session.Abandon();

                    HttpCookie cookie = HttpContext.Current.Request.Cookies["AppAuthCookie"];
                    if (cookie != null)
                    {
                        cookie.Expires = DateTime.Now.AddDays(-1);
                        HttpContext.Current.Response.Cookies.Add(cookie);
                    }
                //Create new session for Emulated User
                Response.Redirect(AnfloSession.Current.CreateSessionEmulate(cboUser.SelectedItem.Value.ToString()) ? "~/Default.aspx" : "~/Logon.aspx?Admin=Invalid");
                }
            else
            {
                Response.Redirect("~/Logon.aspx?YouAreNotAnAdminBitch");
            }
            
        }
    }
}