using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeUtilities : System.Web.UI.Page
    { 
        // CREATE object of DATABASE-ITPORTAL
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

            }
            else
                Response.Redirect("~/Logon.aspx");
        }

        protected void saveBTN_Click(object sender, EventArgs e)
        {
            try
            {
                var vat = context.ACCEDE_S_Computations
                    .Where(w => w.Type == "VAT");
                foreach (ACCEDE_S_Computation v in vat)
                {
                    v.Value1 = Convert.ToDecimal(vatTB.Text);
                }
                context.SubmitChanges();

                var ewt = context.ACCEDE_S_Computations
                        .Where(w => w.Type == "EWT");
                foreach (ACCEDE_S_Computation ew in ewt)
                {
                    ew.Value1 = Convert.ToDecimal(vatTB.Text);
                    ew.Value2 = Convert.ToDecimal(ewtTB.Text);
                }
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }

            Response.Redirect("~/AccedeUtilities.aspx");
        }

        protected void ASPxFormLayout1_Init(object sender, EventArgs e)
        {
            vatTB.Text = context.ACCEDE_S_Computations.Where(x => x.Type == "VAT").Select(x => x.Value1.ToString()).FirstOrDefault();
            ewtTB.Text = context.ACCEDE_S_Computations.Where(x => x.Type == "EWT").Select(x => x.Value2.ToString()).FirstOrDefault();
        }
    }
}