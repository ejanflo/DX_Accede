using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;

namespace DX_WebTemplate
{
    public partial class Logon : System.Web.UI.Page
    {
        ITPORTALDataContext _dataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try 
            { 
                String adPath = "LDAP://dc=anflocor,dc=local"; //Fully-qualified Domain Name
                ADAuthentication adAuth = new ADAuthentication(adPath);

                if (true == adAuth.IsAuthenticated("ANFLOCOR", inputUserName.Value, inputPassword.Value))
                {
                    //invalidAlert.Visible = false;
                    //validAlert.Visible = true;
                    String groups = adAuth.GetGroups();

                    //Create the ticket, and add the groups.
                    bool isCookiePersistent = true;//chkPersist.Checked;
                    FormsAuthenticationTicket authTicket = new FormsAuthenticationTicket(1, inputUserName.Value,
                    DateTime.Now, DateTime.Now.AddMinutes(60), isCookiePersistent, groups);

                    //Encrypt the ticket.
                    String encryptedTicket = FormsAuthentication.Encrypt(authTicket);

                    //Create a cookie, and then add the encrypted ticket to the cookie as data.
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket);

                    if (true == isCookiePersistent)
                        authCookie.Expires = authTicket.Expiration;

                    //Add the cookie to the outgoing cookies collection.
                    Response.Cookies.Add(authCookie);

                    //register user to cookie for single sign-on
                    register_CookieUser(inputUserName.Value);

                    Session["AuthUser"] = authTicket;

                    //Create Sessions
                    AnfloSession.Current.CreateSession(inputUserName.Value);



                    //You can redirect now.
                    Response.Redirect("~/Default.aspx");
                }
                //account not found in AD or username/password is incorrect
                else
                {
                    invalidAlert.Visible = true;
                    validAlert.Visible = false;
                }
            }
            catch (Exception)
            {
                //tbUserName.ErrorText = "Error authenticating. " + ex.Message + " ---------------------------- " + ex.StackTrace;
                //tbUserName.IsValid = false;
                invalidAlert.Visible = true;
                validAlert.Visible = false;
                //errorLabel.Text = "Error authenticating. " + ex.Message;
            }

        }


        protected void register_CookieUser(string username)
        {
            // Create a new authentication ticket
            var ticket = new FormsAuthenticationTicket(1, username, DateTime.Now, DateTime.Now.AddMinutes(120), true, "");

            //Encrypt the ticket
            string encryptedTicket = FormsAuthentication.Encrypt(ticket);

            //Create a cookie, and then add the encrypted ticket to the cookie as data.
            HttpCookie cookie = new HttpCookie("AppAuthCookie", encryptedTicket);
            cookie.Path = "/";

            //Set the cookie
            Response.Cookies.Add(cookie);

            // Redirect the user to the Home page
            //Response.Redirect("Default.aspx");

        }

        protected void check_CookieUser()
        {
            if (Request.Cookies["AppAuthCookie"] != null)
            {
                // Decrypt the ticket from the cookie
                FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(Request.Cookies["AppAuthCookie"].Value);

                // Check if the ticket is valid
                if (ticket != null && !ticket.Expired)
                {
                    //// Authenticate the user using the ticket username
                    //if (AuthenticateUser(ticket.Name))
                    //{
                        //Set the current user identity
                    HttpContext.Current.User = new GenericPrincipal(new GenericIdentity(ticket.Name), null);
                    //}
                }
            }

            // If the user is not authenticated, redirect them to the login page
            if (!HttpContext.Current.User.Identity.IsAuthenticated)
            {
                Response.Redirect("Logon.aspx");
            }
        }

    }
}