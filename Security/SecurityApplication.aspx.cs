using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Security
{
    public partial class SecurityApplication : System.Web.UI.Page
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

        protected void gridRoles_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }
        protected void gridRoles_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["AppId"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void gridUsers_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }
        protected void gridUsers_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["SecurityApp_Id"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void gridUserCompany_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterUserID"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            Session["MasterSecurityAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("SecurityApp_Id");
        }
        protected void gridUserCompany_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["UserId"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            e.NewValues["AppId"] = (sender as ASPxGridView).GetMasterRowFieldValues("SecurityApp_Id");
        }

        protected void gridUserRole_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterUserID"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            Session["MasterCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");

            //ASPxComboBox comboRole = (sender as ASPxGridView).Columns["SecurityRole_Id"].;
            //ASPxComboBox comboRole = (sender as ASPxGridView).FindRowCellTemplateControl(e.)
            sqlRoles.SelectParameters["AppId"].DefaultValue = Session["MasterAppID"].ToString();


        }
        protected void gridUserRole_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["UserId"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            e.NewValues["SecurityApp_Id"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            e.NewValues["CompanyId"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");

        }

        protected void gridUserRole_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            //if (e.DataColumn.FieldName == "" && e.CellValue != null)
            //{
            //    ASPxComboBox comboRole = (sender as ASPxGridView).FindRowCellTemplateControl(e.VisibleIndex, (sender as ASPxGridView).Columns[""] as GridViewDataColumn, "UserAppRoles_Id") as ASPxComboBox;

            //    sqlRoles.SelectParameters["AppId"].DefaultValue = Session["MasterSecurityAppID"].ToString();
            //    comboRole.DataBind();
            //}
        }


    }
}