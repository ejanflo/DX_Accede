using DevExpress.Internal.WinApi.Windows.UI.Notifications;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class UserDelegationPage : System.Web.UI.Page
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

                    //sqlMain.SelectParameters["UserId"].DefaultValue = empCode;

                    SqlCompany.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlMain.SelectParameters["DelegatorUserID"].DefaultValue = empCode;

                    drpdown_Comp.DataSourceID = null;
                    drpdown_Comp.DataSource = SqlCompany;
                    drpdown_Comp.DataBind();
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

        [WebMethod]
        public static bool InsertDelegationAJAX(string comp_id, string user_id, string dateFrom, string dateTo, bool is_active, string remarks)
        {
            UserDelegationPage del = new UserDelegationPage();
            return del.InsertDelegation(Convert.ToInt32(comp_id), user_id, Convert.ToDateTime(dateFrom), Convert.ToDateTime(dateTo), is_active, remarks);
        }

        public bool InsertDelegation(int comp_id, string user_id, DateTime dateFrom, DateTime dateTo, bool is_active, string remarks)
        {
            try
            {
                ITP_S_UserDelegation del = new ITP_S_UserDelegation();
                {
                    del.Company_ID = comp_id;
                    del.DelegatorUserID = Session["userID"].ToString();
                    del.DelegateUserID = user_id;
                    del.DateFrom = dateFrom;
                    del.DateTo = dateTo;
                    del.isActive = is_active;
                    del.Remarks = remarks;
                }

                _DataContext.ITP_S_UserDelegations.InsertOnSubmit(del);
                _DataContext.SubmitChanges();

                return true;

            }catch (Exception ex)
            {
                return false;
            }
        }
    }
}