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
    public partial class SetupTile : System.Web.UI.Page
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

        protected void gridTileInGroup_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterGroupID"] =
                (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void gridTileInGroup_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["TileGroup_ID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void gridTileGroupIncluded_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterTileID"] =
                (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void gridTileRole_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterTileID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
            Session["MasterAppID"] = (sender as ASPxGridView).GetMasterRowFieldValues("App_ID");

            sqlRoles.SelectParameters["AppId"].DefaultValue = Session["MasterAppID"].ToString();
        }

        protected void gridTileRole_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["SecurityApp_ID"] = (sender as ASPxGridView).GetMasterRowFieldValues("App_ID");
            e.NewValues["Tile_ID"] = (sender as ASPxGridView).GetMasterRowKeyValue();

        }
    }
}