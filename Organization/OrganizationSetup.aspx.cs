using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Organization
{
    public partial class OrganizationSetup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void gridDivision_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("WASSId");
        }
        protected void gridDivision_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["Company_ID"] = (sender as ASPxGridView).GetMasterRowFieldValues("WASSId");
        }

        protected void gridSectionChild_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterDepCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("Company_ID");
            Session["MasterDepCode"] = (sender as ASPxGridView).GetMasterRowFieldValues("DepCode");

        }

        protected void gridDepartmentChild_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["MasterDivCompanyID"] = (sender as ASPxGridView).GetMasterRowFieldValues("Company_ID");
            Session["MasterDivCode"] = (sender as ASPxGridView).GetMasterRowFieldValues("DivCode");
        }

        protected void gridDepartmentChild_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["Div_Code"] = (sender as ASPxGridView).GetMasterRowFieldValues("DivCode");
            e.NewValues["Company_ID"] = (sender as ASPxGridView).GetMasterRowFieldValues("Company_ID");
        }
    }
}