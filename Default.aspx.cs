using DevExpress.Web;
using DevExpress.Web.FormLayout.Internal.RuntimeHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //if (AnfloSession.Current.ValidCookieUser() && Session["AuthUser"] == null)
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                }
                else
                {
                    Response.Redirect("~/Logon.aspx");
                }

                //if (Session["userFirstName"] != null)
                //{

                //}
                //else
                //{
                //    Response.Redirect("~/Logon.aspx");
                //}
            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }

            var obj = formTile.FindItemOrGroupByName("layoutGroupMain");
            //if (DateTime.Now.Hour < 12)
            //{
            //    obj.Caption = "Good Morning";
            //}
            //else if (DateTime.Now.Hour < 17)
            //{
            //    obj.Caption = "Good Afternoon";
            //}
            //else
            //{
            //    obj.Caption = "Good Evening";
            //}
            obj.Caption = "Anflo Group Apps";


        }

        protected void cardTiles_BeforePerformDataSelect(object sender, EventArgs e)
        {
            try
            {
                Session["MasterUserID"] = Session["userID"];
            }
            catch
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void cardTiles_HtmlCardPrepared(object sender, DevExpress.Web.ASPxCardViewHtmlCardPreparedEventArgs e)
        {
            //cardTiles.CardLayoutProperties.Items.
            //if (e.Card.)
            //{
            //}
            //    // Find the custom command button element
            //    var customButtonElement = e.Card.FindControl("btnIcon") as DevExpress.Web.ASPxButton;
            //customButtonElement.Image.IconID = "businessobjects_bo_skull_svg_gray_32x32";
        }

        protected void cardTiles_CustomButtonInitialize(object sender, DevExpress.Web.ASPxCardViewCustomCommandButtonEventArgs e)
        {
            //var id = (int)cardTiles.GetCardValues(e.VisibleIndex, "ID");
            //if (id % 2 == 0)
            //    e.Image.IconID = "chart_charttype_doughnut_svg_gray_32x32";
            //else
            //    e.Image.IconID = "arrange_editwrappoints_32x32office2013";

            string icon = cardTiles.GetCardValues(e.VisibleIndex, "Icon").ToString();
            e.Image.IconID = icon;
        }
    }
}