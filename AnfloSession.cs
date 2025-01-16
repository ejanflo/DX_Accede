using DevExpress.Xpo;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Security;

namespace DX_WebTemplate
{
    public class AnfloSession
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        public AnfloSession()
        {
            AnfloGroup = "Anflo Group of Companies";
        }

        /// <summary>
        /// Gets the current session.
        /// </summary>
        public static AnfloSession Current
        {
            get
            {
                AnfloSession session =
                  (AnfloSession)HttpContext.Current.Session["__AnfloSession__"];
                if (session == null)
                {
                    session = new AnfloSession();
                    HttpContext.Current.Session["__AnfloSession__"] = session;
                }
                return session;
            }
        }
        //// **** add your session properties here, e.g like this:
        public string AnfloGroup { get; set; }

        /// <summary>
        /// Create Session, returned true if created successfully
        /// </summary>
        /// <param name="username">User Name</param>
        /// <returns></returns>
        public bool CreateSession(string username)
        {
            bool sessionCreated = true;

            try
            {
                FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(HttpContext.Current.Request.Cookies["AppAuthCookie"].Value);
                username = ticket.Name;

                var usermaster =
                from users in context.ITP_S_UserMasters
                where users.UserName == username
                select users;

                foreach (var user in usermaster)
                {
                    HttpContext.Current.Session["AuthUser"] = user.UserName;
                    HttpContext.Current.Session["userFullName"] = user.FullName;
                    HttpContext.Current.Session["userID"] = user.EmpCode;
                    HttpContext.Current.Session["userLastName"] = user.LName;
                    HttpContext.Current.Session["userFirstName"] = user.FName;
                    HttpContext.Current.Session["userCompanyID"] = user.CompanyID;
                    HttpContext.Current.Session["userCompanyName"] = user.CompanyName;
                    HttpContext.Current.Session["userDivDesc"] = user.DivDesc;
                    HttpContext.Current.Session["userDepDesc"] = user.DepDesc;
                    HttpContext.Current.Session["userSecDesc"] = user.SecDesc;
                    HttpContext.Current.Session["userDesDesc"] = user.DesDesc;
                    HttpContext.Current.Session["userEmail"] = user.Email;
                    HttpContext.Current.Session["userJobLevel"] = user.JobLevel;
                    HttpContext.Current.Session["userIsSouth"] = user.isSouth;

                    HttpContext.Current.Session["empName"] = user.UserName;
                }
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); sessionCreated = false; }
            

            return sessionCreated;
        }

        public bool CreateSessionEmulate(string username)
        {
            bool sessionCreated = true;

            try
            {
                // Create a new authentication ticket
                var ticket = new FormsAuthenticationTicket(1, username, DateTime.Now, DateTime.Now.AddMinutes(5), true, "");

                //Encrypt the ticket
                string encryptedTicket = FormsAuthentication.Encrypt(ticket);

                //Create a cookie, and then add the encrypted ticket to the cookie as data.
                HttpCookie cookie = new HttpCookie("AppAuthCookie", encryptedTicket);
                cookie.Path = "/";

                //Set the cookie
                HttpContext.Current.Response.Cookies.Add(cookie);

                var usermaster =
                from users in context.ITP_S_UserMasters
                where users.UserName == username
                select users;

                foreach (var user in usermaster)
                {
                    HttpContext.Current.Session["AuthUser"] = user.UserName;
                    HttpContext.Current.Session["userFullName"] = user.FullName;
                    HttpContext.Current.Session["userID"] = user.EmpCode;
                    HttpContext.Current.Session["userLastName"] = user.LName;
                    HttpContext.Current.Session["userFirstName"] = user.FName;
                    HttpContext.Current.Session["userCompanyID"] = user.CompanyID;
                    HttpContext.Current.Session["userCompanyName"] = user.CompanyName;
                    HttpContext.Current.Session["userDivDesc"] = user.DivDesc;
                    HttpContext.Current.Session["userDepDesc"] = user.DepDesc;
                    HttpContext.Current.Session["userSecDesc"] = user.SecDesc;
                    HttpContext.Current.Session["userDesDesc"] = user.DesDesc;
                    HttpContext.Current.Session["userEmail"] = user.Email;
                    HttpContext.Current.Session["userJobLevel"] = user.JobLevel;
                    HttpContext.Current.Session["userIsSouth"] = user.isSouth;
                }
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); sessionCreated = false; }


            return sessionCreated;
        }

        public bool ValidCookieUser()
        {
            bool isValidUser = false;

            if (HttpContext.Current.Request.Cookies["AppAuthCookie"] != null)
            {
                // Decrypt the ticket from the cookie
                FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(HttpContext.Current.Request.Cookies["AppAuthCookie"].Value);

                // Check if the ticket is valid
                if (ticket != null && !ticket.Expired)
                {
                    isValidUser = true;
                    //Set the current user identity
                    HttpContext.Current.User = new GenericPrincipal(new GenericIdentity(ticket.Name), null);
                    //}
                }
                else { isValidUser = false; }
            }

            // If the user is not authenticated, redirect them to the login page
            if (!HttpContext.Current.User.Identity.IsAuthenticated)
            {
                isValidUser = false;
            }

            return isValidUser;
        }


        public bool isAdminUser(string empCode)
        {
            bool iAdmin = false;
            //var count = dbContext.Orders.Count(doc => doc.EmployeeID == pEmpID);// && me.me_pkey != this.me_pkey);
            //docExists = count > 0;

            var count = context.ITP_S_SecurityUserAppRoles.Count(role => role.UserId == empCode && role.SecurityRole_Id == 1);

            iAdmin = count > 0 ? true : false;

            return iAdmin;
        }

        public bool hasPageAccess(string empCode, int appID, string pageName)
        {
            bool accessFound = false;

            var count = context.vw_AGA_I_UserTiles.Count(access => access.UserId == empCode && access.App_ID == appID && access.URL.Contains(pageName));

            accessFound = count > 0 ? true : false;

            return accessFound;
        }

    }
}