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
    public partial class AccedeApprovalPage : System.Web.UI.Page
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
                    int appID = 1032; //22-ITPORTAL; 13-CAR; 26-RS; 1027-RFP; 1028-UAR

                    string url = Request.Url.AbsolutePath; // Get the current URL
                    string pageName = Path.GetFileNameWithoutExtension(url); // Get the filename without extension


                    //if (!AnfloSession.Current.hasPageAccess(empCode, appID, pageName))
                    //{
                    //    Session["appID"] = appID.ToString();
                    //    Session["pageName"] = pageName.ToString();

                    //    Response.Redirect("~/ErrorAccess.aspx");
                    //}
                    //End ------------------ Page Security

                    sqlMain.SelectParameters["UserId"].DefaultValue = empCode;

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

            Session["PassActID"] = e.Parameters.Split('|').First();
            string actID = e.Parameters.Split('|').First();
            var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();
            string encryptedID = Encrypt(actID); // Implement the Encrypt method securely

            if (e.Parameters.Split('|').Last() == app_docType.DCT_Id.ToString())
            {
                //ASPxWebControl.RedirectOnCallback("RFPApprovalView.aspx");
                string redirectUrl = $"RFPApprovalView.aspx?secureToken={encryptedID}";
                ASPxWebControl.RedirectOnCallback(redirectUrl);
            }
            else
            {
                //ASPxWebControl.RedirectOnCallback("ExpenseApprovalView.aspx");
                string redirectUrl = $"ExpenseApprovalView.aspx?secureToken={encryptedID}";
                ASPxWebControl.RedirectOnCallback(redirectUrl);
            }

        }

        private string Encrypt(string plainText)
        {
            // Example: Use a proper encryption library like AES or RSA for actual implementations
            // This is just a placeholder for encryption logic
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText));
        }

        protected void gridMain_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            // Check if the cell being processed is for the target column where you want to display the combined value
            if (e.DataColumn.FieldName == "Amount") // Replace with the field name of the column where you want the combined value
            {
                // Retrieve the values from the "Currency" and "Amount" columns for the current row
                string currency = e.GetValue("Currency").ToString();
                string amountStr = e.GetValue("Amount").ToString();
                string amount = Convert.ToDecimal(amountStr != "" ? amountStr : "0.00").ToString("#,#00.00");

                // Combine the values and assign them to the target cell
                e.Cell.Text = $"{currency} {amount}";
            }
        }
    }
}