using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.XtraReports
{
    public partial class ReportViewer : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            xrTest testXR = new xrTest();

            testXR.Parameters[0].Value = 1;
            ASPxWebDocumentViewer1.OpenReport(testXR);
        }
    }
}