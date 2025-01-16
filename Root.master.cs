using System;
using System.Web;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class RootMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            string greetings = string.Empty;
            if (DateTime.Now.Hour < 12)
            {
                greetings = "Good Morning, ";
            }
            else if (DateTime.Now.Hour < 17)
            {
                greetings = "Good Afternoon, ";
            }
            else
            {
                greetings = "Good Evening, ";
            }

            try
            {
                LoginName loginName = HeadLoginView.FindControl("HeadLoginName") as LoginName;

                if (loginName != null)
                {
                    if (AnfloSession.Current.ValidCookieUser() && Session["userFirstName"] == null)
                    {
                        AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                    }

                    var userFName = Session["userFirstName"].ToString();

                    //loginName.FormatString = "JESSY PIMENTERA"; //Session["empName"].ToString();
                    if (Session["userFirstName"] != null)
                    //if (AnfloSession.Current.UserName != null)
                    {
                        loginName.FormatString = greetings + " " + FirstCharToUpper(Session["userFirstName"].ToString().ToLower()) + "! ";
                        //loginName.FormatString = greetings + " " + FirstCharToUpper(AnfloSession.Current.UserName.ToLower()) + "! ";
                    }
                }

            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }

        }

        public string FirstCharToUpper(string input)
        {
            switch (input)
            {
                case null: throw new ArgumentNullException(nameof(input));
                case "": throw new ArgumentException($"{nameof(input)} cannot be empty", nameof(input));
                default: return input[0].ToString().ToUpper() + input.Substring(1);
            }
        }
    }
}