using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Setup
{
    public partial class TaskDelegation : System.Web.UI.Page
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
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void gridPendingActivity_ToolbarItemClick(object source, DevExpress.Web.Data.ASPxGridViewToolbarItemClickEventArgs e)
        {
            if (e.Item.Name == "DelegateTo")
            {
                //System.Windows.Forms.MessageBox.Show("Delegated!");
                List<int> selectedRowKeys = gridPendingActivity.GetSelectedFieldValues(gridPendingActivity.KeyFieldName).Cast<int>().ToList();
                foreach (int rowKey in selectedRowKeys)
                {
                    //string col1Value = gridPendingActivity.GetRowValues(rowKey, "OrgRole_Id").ToString();
                    //string col2Value = gridPendingActivity.GetRowValues(rowKey, "Document_No").ToString();
                    // process the values as needed
                    string delegateTo_OrgRole_ID = cboDelegateTo.SelectedIndex.ToString();
                    

                }
            }
        }

        protected void cboDelegateTo_SelectedIndexChanged(object sender, EventArgs e)
        {
            System.Windows.Forms.MessageBox.Show(cboDelegateTo.SelectedIndex.ToString());
        }

        protected void btnDelegate_Click(object sender, EventArgs e)
        {
            System.Windows.Forms.MessageBox.Show(cboDelegateTo.SelectedIndex.ToString());
        }
    }
}