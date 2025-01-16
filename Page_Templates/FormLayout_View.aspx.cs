using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Page_Templates
{
    public partial class FormLayout_View : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
            }
            else
            {
                Response.Redirect("~/Logon.aspx");
            }

        }

        protected void formEmployee_DataBound(object sender, EventArgs e)
        {
            bindEmpTerritory();
        }

        protected void gridEmpTerritory_BeforePerformDataSelect(object sender, EventArgs e)
        {
            //if (txtEmpID.Text != "")
            //{
            //    bindEmpTerritory();
            //}
        }

        protected void gridEmpTerritory_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["EmployeeID"] = txtEmpID.Text;
        }

        void bindEmpTerritory()
        {
            sqlEmpTerritory.SelectParameters["EmployeeID"].DefaultValue = "1"; // txtEmpID.Text;
            gridEmpTerritory.DataBind();
        }
    }
}