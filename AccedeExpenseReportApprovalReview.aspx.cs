using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportApprovalReview : System.Web.UI.Page
    {
        // CREATE objects of DATABASE-ITPORTA
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                //DocuGrid.StylesPager.CurrentPageNumber.BackColor = System.Drawing.ColorTranslator.FromHtml("#06838");
                ASPxFormLayout1.Items[0].Caption = "Document No. " + Session["docno"] + " (" + Session["stat"] + ")";

                //string status = !string.IsNullOrEmpty(Session["stat"]?.ToString()) ? Session["stat"].ToString() : "";

                //if (status == "Saved" || status == "Returned")
                //    editBTN.Visible = true;
                //else
                //    editBTN.Visible = false;
            }
            else
                Response.Redirect("~/Logon.aspx");
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID, string remarks = "")
        {
            DateTime currentDate = DateTime.Now;

            var status = context.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Description)
                .FirstOrDefault();

            var statusName = context.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Name)
                .FirstOrDefault();

            ///////---START EMAIL PROCESS-----////////
            var user_userID = context.ITP_S_SecurityUserOrgRoles
                .Where(um => um.OrgRoleId == org_id)
                .Select(um => um.UserId)
                .FirstOrDefault();
            var user_email = context.ITP_S_UserMasters
                .Where(x => x.EmpCode == user_userID)
                .FirstOrDefault();
            var comp_name = context.CompanyMasters
                .Where(x => x.WASSId == comps_id)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in context.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == statusName
                            select texts;

            var emailMessage = "";
            var emailSubMessage = "";
            var emailColor = "";

            foreach (var text in queryText)
            {
                emailMessage = text.Text1.ToString();
                emailSubMessage = text.Text2.ToString();
                emailColor = text.Color.ToString();
            }
            //End--     Get Text info

            var requestor_fullname = context.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = context.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.Email)
                .FirstOrDefault();

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = remarks;
            string emailSite = "https://apps.anflocor.com/AccedeExpenseReportApproval.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + doc_id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in context.ACCEDE_T_ExpenseDetails
                          where er.ExpenseMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Particulars</th><th>Supplier</th><th>Net Amount</th><th>Date Created</th></tr>";

            foreach (var item in queryER)
            {
                var exp = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var expType = context.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.Particulars + "</td>" +
                            "<td style='text-align: center;'>" + item.Supplier + "</td>" +
                            "<td style='text-align: center;'>" + item.NetAmount + "</td>" +
                            "<td style='text-align: center;'>" + item.DateAdded.Value.ToLongDateString() + "</td>" +
                            "</tr>";
            }
            emailDetails += "</table>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            };
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

        protected void approveCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
        {
            var newID = Convert.ToInt32(Session["cID"]);
            // GET WORKFLOW ID
            var wf = Convert.ToInt32(Session["wf"]);

            // GET WORKFLOW DETAILS ID
            var wfa = Convert.ToInt32(Session["wfa"]);

            // GET WORKFLOW DETAILS ID
            var wfd = Convert.ToInt32(Session["wfd"]);

            // GET SEQUENCE
            var sequence = context.ITP_S_WorkflowDetails
                    .Where(x => x.WFD_Id == wfd)
                    .Select(x => x.Sequence)
                    .FirstOrDefault() + 1;

            // GET ORG ROLE ID
            var orgRoleID = context.ITP_S_WorkflowDetails
                    .Where(or => or.WF_Id == wf && or.Sequence == sequence)
                    .Select(or => or.OrgRole_Id)
                    .FirstOrDefault();

            //UPDATE ITP_T_WORKFLOWACTIVITY
            try
            {
                var updateWFA = context.ITP_T_WorkflowActivities
                    .Where(a => a.Document_Id == newID && a.WF_Id == wf && a.WFA_Id == wfa);

                foreach (var ex in updateWFA)
                {
                    ex.DateAction = DateTime.Now;
                    ex.Status = 7;
                    ex.ActedBy_User_Id = Convert.ToString(Session["userID"]);
                }
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }

            if (orgRoleID != null)
            {
                //INSERT TO ITP_T_WorkflowActivity
                DateTime currentDate = DateTime.Now;

                ITP_T_WorkflowActivity wact = new ITP_T_WorkflowActivity()
                {
                    Status = 1,
                    DateAssigned = currentDate,
                    DateAction = null,
                    WF_Id = wf,
                    WFD_Id = wfd,
                    OrgRole_Id = orgRoleID,
                    Document_Id = newID,
                    AppId = 1032,
                    CompanyId = Convert.ToInt32(company.Value),
                    AppDocTypeId = context.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                    IsActive = true,
                };
                context.ITP_T_WorkflowActivities.InsertOnSubmit(wact);
                context.SubmitChanges();

                SendEmail(Convert.ToInt32(wact.Document_Id), 2055, Convert.ToInt32(company.Value), 1);
            }
            else
            {
                var EM = context.ACCEDE_T_ExpenseMains
                    .Where(w => w.ID == newID);
                foreach (ACCEDE_T_ExpenseMain w in EM)
                {
                    w.Status = 7;
                }
                context.SubmitChanges();

                SendEmail(newID, 2055, Convert.ToInt32(company.Value), 7);
            }

            ASPxWebControl.RedirectOnCallback("~/AccedeExpenseReportApproval.aspx");
        }

        protected void retdapprCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
        {
            var newID = Convert.ToInt32(Session["cID"]);

            if (Convert.ToString(e.Parameter) == "Return")
            {
                var EM = context.ACCEDE_T_ExpenseMains
                    .Where(w => w.ID == newID);
                foreach (ACCEDE_T_ExpenseMain w in EM)
                {
                    w.Status = 3;
                }
                context.SubmitChanges();

                var wfa = context.ITP_T_WorkflowActivities
                    .Where(w => w.WFA_Id == Convert.ToInt32(Session["wfa"]));
                foreach (ITP_T_WorkflowActivity act in wfa)
                {
                    act.Status = 3;
                    act.DateAction = DateTime.Now;
                    act.Remarks = remarks.Text;
                    act.ActedBy_User_Id = Convert.ToString(Session["userID"]);
                }
                context.SubmitChanges();

                SendEmail(newID, 2055, Convert.ToInt32(company.Value), 3, remarks.Text);
            }
            else if (Convert.ToString(e.Parameter) == "Disapprove")
            {
                var EM = context.ACCEDE_T_ExpenseMains
                    .Where(w => w.ID == newID);
                foreach (ACCEDE_T_ExpenseMain w in EM)
                {
                    w.Status = 8;
                }
                context.SubmitChanges();

                var wfa = context.ITP_T_WorkflowActivities
                    .Where(w => w.WFA_Id == Convert.ToInt32(Session["wfa"]));
                foreach (ITP_T_WorkflowActivity act in wfa)
                {
                    act.Status = 8;
                    act.DateAction = DateTime.Now;
                    act.Remarks = remarks.Text;
                    act.ActedBy_User_Id = Convert.ToString(Session["userID"]);
                }
                context.SubmitChanges();

                SendEmail(newID, 2055, Convert.ToInt32(company.Value), 8, remarks.Text);
            }

            ASPxWebControl.RedirectOnCallback("~/AccedeExpenseReportApproval.aspx");
        }
    }
}