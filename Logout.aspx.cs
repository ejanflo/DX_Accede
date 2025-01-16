using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //Clear Sessions
            Session.Abandon();

            //Get cookie then add expiration
            HttpCookie cookie = HttpContext.Current.Request.Cookies["AppAuthCookie"];
            if (cookie != null)
            {
                cookie.Expires = DateTime.Now.AddDays(-1);
                HttpContext.Current.Response.Cookies.Add(cookie);
            }

            //FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(HttpContext.Current.Request.Cookies["AppAuthCookie"].Value);
            //ticket.Expiration.AddDays(-1);

            //Redirect to Login Page
            Response.Redirect("~/Logon.aspx");
        }
    }
}