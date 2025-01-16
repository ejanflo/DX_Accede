using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using System;
using System.Configuration;
using System.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Security
{
    public partial class SecurityUserAccess : System.Web.UI.Page
    {
        string pAppID = "";
        string pCompID = "";
        ITPORTALDataContext dbContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

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


                //if (!AnfloSession.Current.hasPageAccess(empCode, appID, pageName))
                //{
                //    Session["appID"] = appID.ToString();
                //    Session["pageName"] = pageName.ToString();

                //    Response.Redirect("~/ErrorAccess.aspx");
                //}
                ////End ------------------ Page Security

            }
            else
            {
                Session["prevURL"] = Request.Url.AbsoluteUri;
                Response.Redirect("~/Logon.aspx");
            }

        }

        protected void gridUserApp_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["UserId"] = listBoxUser.Value;
        }

        protected void gridUserAppCompany_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {

            //Session["MasterAppID"] = e.Parameters[0];
            //Session["MasterUserID"] = listBoxUser.Value;
            pAppID = e.Parameters.Replace("null", "");
            gridUserAppCompany.DataSource = null; gridUserAppCompany.DataBind();

            if (pAppID.Length > 1)
            {

                //pAppID = e.Parameters[0].ToString();
                pAppID = e.Parameters.Split('|').First();
                Session["MasterAppID"] = pAppID;
                Session["MasterUserID"] = listBoxUser.Value.ToString();

                //it exists
                //sqlUserCompany.SelectParameters["AppId"].DefaultValue = pAppID;
                //sqlUserCompany.SelectParameters["UserId"].DefaultValue = listBoxUser.Value.ToString();
                gridUserAppCompany.DataBind();
                Session["MasterAppID"] = "";
            }
            gridSecurityUser.FocusedRowIndex = 0;
        }

        protected void gridUserAppRole_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            pCompID = e.Parameters.Replace("null", "");
            //gridUserAppRole.DataSource = null; gridUserAppRole.DataBind();

            if (pCompID.Length > 1)
            {

                //pAppID = e.Parameters[0].ToString();
                pCompID = e.Parameters.Split('|').First();
                Session["MasterAppID"] = pAppID;
                Session["MasterCompanyID"] = pCompID;
                Session["MasterUserID"] = listBoxUser.Value.ToString();

                //it exists
                //sqlUserCompany.SelectParameters["AppId"].DefaultValue = pAppID;
                //sqlUserCompany.SelectParameters["UserId"].DefaultValue = listBoxUser.Value.ToString();
                //gridUserAppRole.DataBind();
                Session["MasterAppID"] = "";
                Session["MasterCompanyID"] = "";
            }


        }

        protected void gridUserAppCompany_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["AppId"] = Session["MasterAppID_UAC"].ToString();
            e.NewValues["UserId"] = listBoxUser.Value;
        }


        protected void gridUserApp_DataBound(object sender, EventArgs e)
        {
            //gridUserAppCompany.Dispose();
            if (gridUserApp.VisibleRowCount > 0)
            {
                gridUserApp.FocusedRowIndex = -1;
                Session["MasterAppID"] = "";
                gridUserAppCompany.DataSource = null; gridUserAppCompany.DataBind();
                //int focusedRowIndex = gridUserApp.FocusedRowIndex;

                //if (focusedRowIndex >= 0)
                //{
                //    pAppID = gridUserApp.GetRowValues(focusedRowIndex, "SecurityApp_Id").ToString();
                //}

                //if (pAppID.Length > 1)
                //{
                //    Session["MasterAppID"] = pAppID;
                //    Session["MasterUserID"] = listBoxUser.Value.ToString();
                //    //it exists
                //    sqlUserCompany.SelectParameters["AppId"].DefaultValue = pAppID;
                //    sqlUserCompany.SelectParameters["UserId"].DefaultValue = listBoxUser.Value.ToString();
                //    gridUserAppCompany.DataBind();
                //}


            }
        }

        protected void gridUserAppCompany_RowInserted(object sender, DevExpress.Web.Data.ASPxDataInsertedEventArgs e)
        {

        }

        protected void gridUserAppCompany_DataBound(object sender, EventArgs e)
        {
            if (gridUserAppCompany.VisibleRowCount > 0)
            {
                gridUserAppCompany.FocusedRowIndex = -1;
            }

        }

        protected void gridUserAppCompany_BeforePerformDataSelect(object sender, EventArgs e)
        {

            // Delay for 2 seconds (2000 milliseconds)
            //Thread.Sleep(2000);
            string jAppID = "";
            int focusedRowIndex = gridUserApp.FocusedRowIndex;

            if (focusedRowIndex >= 0)
            {
                jAppID = gridUserApp.GetRowValues(focusedRowIndex, "SecurityApp_Id").ToString();
                //gridUserAppCompany.FocusedRowIndex = focusedRowIndex;
            }

            Session["MasterAppID_UAC"] = jAppID;
            Session["MasterUserID"] = listBoxUser.Value.ToString();

        }

        protected void gridUserAppRole_BeforePerformDataSelect(object sender, EventArgs e)
        {
            ////// Delay for 2 seconds (2000 milliseconds)
            //////Thread.Sleep(2000);
            ////string jAppID = "";
            ////string kAppID = "";
            ////int focusedRowIndeAppx = gridUserApp.FocusedRowIndex;
            ////int focusedRowIndexCompany = gridUserAppCompany.FocusedRowIndex;

            ////if (focusedRowIndexCompany >= 0)
            ////{
            ////    jAppID = gridUserApp.GetRowValues(focusedRowIndeAppx, "SecurityApp_Id").ToString();
            ////    kAppID = gridUserAppCompany.GetRowValues(focusedRowIndexCompany, "CompanyId").ToString();
            ////}

            ////Session["MasterAppID"] = jAppID;
            ////Session["MasterCompanyID"] = kAppID;
            ////Session["MasterUserID"] = listBoxUser.Value.ToString();


            ////sqlRolesFiltered.SelectParameters["AppId"].DefaultValue = Session["MasterAppID"].ToString();
            ///
            Session["MasterUserID"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            Session["MasterCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");

            sqlRolesFiltered.SelectParameters["AppId"].DefaultValue = Session["MasterAppID"].ToString();
            sqlDept.SelectParameters["Company_ID"].DefaultValue = Session["MasterCompanyID"].ToString();
        }

        protected void gridUserAppRole_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            //string jAppID = Session["MasterAppID"].ToString();
            //string kAppID = Session["MasterCompanyID"].ToString();

            //int focusedRowIndeAppx = gridUserApp.FocusedRowIndex;
            //int focusedRowIndexCompany = gridUserAppCompany.FocusedRowIndex;
            //if (focusedRowIndexCompany >= 0)
            //{
            //    jAppID = gridUserApp.GetRowValues(focusedRowIndeAppx, "SecurityApp_Id").ToString();
            //    kAppID = gridUserAppCompany.GetRowValues(focusedRowIndexCompany, "CompanyId").ToString();
            //}

            ////e.NewValues["SecurityApp_Id"] = Session["MasterAppID"].ToString();
            ////e.NewValues["CompanyId"] = Session["MasterCompanyID"].ToString();
            //e.NewValues["SecurityApp_Id"] = jAppID;
            //e.NewValues["CompanyId"] = kAppID;
            //e.NewValues["UserId"] = listBoxUser.Value;

            e.NewValues["SecurityApp_Id"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            e.NewValues["CompanyId"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");
            e.NewValues["UserId"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
        }

        protected void gridUserDept_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterUserID"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            Session["MasterCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");

            sqlRolesFiltered.SelectParameters["AppId"].DefaultValue = Session["MasterAppID"].ToString();
            sqlDept.SelectParameters["Company_ID"].DefaultValue = Session["MasterCompanyID"].ToString();
        }

        protected void gridUserDept_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["UserId"] = (sender as ASPxGridView).GetMasterRowFieldValues("UserId");
            e.NewValues["AppId"] = (sender as ASPxGridView).GetMasterRowFieldValues("AppId");
            e.NewValues["CompanyId"] = (sender as ASPxGridView).GetMasterRowFieldValues("CompanyId");
        }

        protected void gridSecurityUser_DataBound(object sender, EventArgs e)
        {
            if (!IsPostBack)
                gridSecurityUser.FocusedRowIndex = 0;
            //int focusedRowIndex = gridSecurityUser.FocusedRowIndex;

            //if (focusedRowIndex >= 0)
            //{
            //    gridSecurityUser.FocusedRowIndex = 0;
            //}
        }

        protected void gridSecurityUser_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
        {
            listBoxUser.DataBind();
        }

        protected void gridSecurityUser_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["IsActive"] = true;
            //var count = dbContext.Orders.Count(doc => doc.EmployeeID == pEmpID);// && me.me_pkey != this.me_pkey);
            var count = dbContext.ITP_S_SecurityUsers.Count(user => user.UserId == e.NewValues["UserId"].ToString());
            if (count > 0)
            {
                gridSecurityUser.CancelEdit();
                e.Cancel = true;
            }

        }

        protected void gridSecurityUser_HtmlRowCreated(object sender, ASPxGridViewTableRowEventArgs e)
        {
            if (e.RowType == DevExpress.Web.GridViewRowType.Data)
            {
                e.Row.Height = Unit.Pixel(10);
            }
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {

        }

        protected void gridUserOrgRole_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["UserId"] = listBoxUser.Value;
        }

        protected void gridOrgRoleUsers_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterOrgRoleID"] = (sender as ASPxGridView).GetMasterRowFieldValues("OrgRoleId");
        }

        protected void gridOrgRoleUsers_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["OrgRoleId"] = (sender as ASPxGridView).GetMasterRowFieldValues("OrgRoleId");
        }
    }
}