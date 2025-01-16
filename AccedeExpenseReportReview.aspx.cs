using DevExpress.CodeParser;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportReview : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                //DocuGrid.StylesPager.CurrentPageNumber.BackColor = System.Drawing.ColorTranslator.FromHtml("#06838");
                ASPxFormLayout1.Items[0].Caption = "Document No. " + Session["docno"] + " (" + Session["stat"] + ")";

                string status = !string.IsNullOrEmpty(Session["stat"]?.ToString()) ? Session["stat"].ToString() : "";

                if (status == "Saved" || status == "Returned")
                    editBTN.Visible = true;
                else
                    editBTN.Visible = false;
            }
            else
                Response.Redirect("~/Logon.aspx");
        }

        protected void DocuGrid1_DataBound(object sender, EventArgs e)
        {
            Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
        }

        protected void DocuGrid_DataBound(object sender, EventArgs e)
        {
            Session["expenseTotal"] = DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            expenseTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["expenseTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["expenseTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
        }

        public void Compute_ExpCA(decimal expTotal, decimal caTotal)
        {
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            if (expTotal > caTotal)
                dueTotal.Text = "(" + string.Format(cultureInfo, "{0:C2}", (expTotal - caTotal)) + ")";
            else if (caTotal > expTotal)
                dueTotal.Text = string.Format(cultureInfo, "{0:C2}", (caTotal - expTotal));
            else
                dueTotal.Text = "";
        }

        public void ShowRmbmtButton(decimal expTotal, decimal caTotal)
        {
            if (expTotal > caTotal && !string.IsNullOrEmpty(expTotal.ToString()) && !string.IsNullOrEmpty(caTotal.ToString()))
            {
                DocuGrid0.Visible = true;
                errImg.Visible = false;
                expenseType.Text = "Reimbursement";
                //ASPxFormLayout1.FindItemOrGroupByName("reimGroup").Visible = true;
            }
            else
            {
                //ASPxFormLayout1.FindItemOrGroupByName("reimGroup").Visible = false;
                DocuGrid0.Visible = false;
                errImg.Visible = true;
                expenseType.Text = "Liquidation";
            }
        }
    }
}