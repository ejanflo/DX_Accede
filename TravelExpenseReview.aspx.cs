using DevExpress.ClipboardSource.SpreadsheetML;
using DevExpress.CodeParser;
using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Security.Cryptography;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class TravelExpenseReview : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        DataSet ds = null;
        DataSet dsDoc = null;

        void ApplyStylesToGrid(dynamic grid, string colorCode)
        {
            var color = ColorTranslator.FromHtml(colorCode);
            grid.StylesPager.CurrentPageNumber.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.DropDownButtonStyle.HoverStyle.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.ItemStyle.SelectedStyle.BackColor = color;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    string colorCode = "#06838";
                    ApplyStylesToGrid(CAGrid, colorCode);
                    ApplyStylesToGrid(ExpenseGrid, colorCode);
                    ApplyStylesToGrid(DocumentGrid, colorCode);
                    ApplyStylesToGrid(WFSequenceGrid, colorCode);
                    ApplyStylesToGrid(FAPWFGrid, colorCode);
                    ApplyStylesToGrid(ASPxGridView22, colorCode);
                    ApplyStylesToGrid(ASPxGridView22, colorCode);

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();
                    var status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault();
                    Session["doc_stat2"] = status;

                    if (mainExp != null)
                    {
                        ExpenseEditForm.Items[0].Caption = "Travel Expense Document No.: " + mainExp.Doc_No + " (" + status + ")";

                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());
                        Session["DocNo"] = mainExp.Doc_No.ToString();
                    }

                    CAGrid.DataBind();
                    ExpenseGrid.DataBind();

                    InitializeExpCA(mainExp);

                    var forAccounting = ExpenseEditForm.FindItemOrGroupByName("forAccounting") as LayoutGroup;
                    if (status.Contains("Pending at Finance"))
                        forAccounting.ClientVisible = true;
                    else
                        forAccounting.ClientVisible = false;

                    var disapproveItem = ExpenseEditForm.FindItemOrGroupByName("disapproveItem") as LayoutItem;
                    var returnItem = ExpenseEditForm.FindItemOrGroupByName("returnItem") as LayoutItem;

                    if (status == "Pending at Finance" || status == "Pending at P2P" || status == "Pending at Audit" || mainExp.ExpenseType_ID != 1)
                    {
                        disapproveItem.Visible = false;
                    }

                    if (status == "Pending at Cashier")
                    {
                        disapproveItem.Visible = false;
                        returnItem.Visible = false;
                    }
                }
                else
                    Response.Redirect("~/Logon.aspx");
            }
            catch (Exception ex)
            {
                //Response.Redirect("~/Logon.aspx");
                Debug.WriteLine(ex.Message);
            }
        }

        private void InitializeExpCA(ACCEDE_T_TravelExpenseMain mainExp)
        {
            try
            {
                var due_lbl = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutItem;

                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.isTravel == true && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reimDetails.ClientVisible = true;
                    reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                }

                var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                var userId = Convert.ToString(Session["prep"]);

                var totalca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId)
                    .Sum(x => (decimal?)x.Amount) ?? 0;
                Session["totalCA"] = totalca;

                var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Where(x => x.TravelExpenseMain_ID == travelExpId)
                    .Sum(x => (decimal?)x.Total_Expenses) ?? 0;
                Session["totalEXP"] = totalexp;

                var countCA = _DataContext.ACCEDE_T_RFPMains
                    .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId);

                var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Count(x => x.TravelExpenseMain_ID == travelExpId);

                var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                if (totalexp > totalca)
                {
                    due_lbl.Caption = "Due To Employee";
                }
                else
                {
                    due_lbl.Caption = "Due To Company";
                }

                drpdown_expenseType.Value = expType;
                lbl_caTotal.Text = totalca.ToString();
                lbl_expenseTotal.Text = totalexp.ToString();
                lbl_dueTotal.Text = totalexp > totalca ? $"({(totalexp - totalca):N2})" : (totalca - totalexp).ToString("N2");

                var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                SqlWF.SelectParameters["UserId"].DefaultValue = mainExp.Employee_Id.ToString();
                SqlWF.SelectParameters["CompanyId"].DefaultValue = mainExp.Company_Id.ToString();
                SqlWF.DataBind();

                Session["mainwfid"] = Convert.ToString(_DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == mainExp.Employee_Id.ToString() && x.CompanyId == mainExp.Company_Id).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                SqlWorkflowSequence.DataBind();

                Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF2.DataBind();
                SqlFAPWF.DataBind();
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void UploadController_FilesUploadComplete(object sender, DevExpress.Web.FilesUploadCompleteEventArgs e)
        {
            foreach (var file in UploadController.UploadedFiles)
            {
                var filesize = 0.00;
                var filesizeStr = "";
                if (Convert.ToInt32(file.ContentLength) > 999999)
                {
                    filesize = Convert.ToInt32(file.ContentLength) / 1000000;
                    filesizeStr = filesize.ToString() + " MB";
                }
                else if (Convert.ToInt32(file.ContentLength) > 999)
                {
                    filesize = Convert.ToInt32(file.ContentLength) / 1000;
                    filesizeStr = filesize.ToString() + " KB";
                }
                else
                {
                    filesize = Convert.ToInt32(file.ContentLength);
                    filesizeStr = filesize.ToString() + " Bytes";
                }

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(companyCB.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
        }

        public void SendEmailWithCC(int id, string userID, int compID, int status, int prepID, string cc, string remarks)
        {
            ///////---START EMAIL PROCESS-----////////
            var user_email = _DataContext.ITP_S_UserMasters
                .Where(x => x.EmpCode == userID)
                .FirstOrDefault();
            var comp_name = _DataContext.CompanyMasters
                .Where(x => x.WASSId == compID)
                .FirstOrDefault();
            var stat = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == status)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == stat.STS_Name
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

            var requestor_fullname = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(prepID))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(prepID))
                .Select(um => um.Email)
                .FirstOrDefault();
            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = requestor_fullname;
            string senderName = user_email.FullName;
            string emailSender = user_email.Email;
            string senderRemarks = remarks;
            string emailSite = "https://apps.anflocor.com/ecclear/WebClearView.aspx";
            string sendEmailTo = requestor_email;
            string emailSubject = "Document No. " + id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";
            DateTime currentDate = DateTime.Now;

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + recipientName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + stat.STS_Description + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Clearance Certificate" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Location/Particulars</th><th>Date</th><th>Total Expenses</th></tr>";

            foreach (var item in queryER)
            {
                var exp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.LocParticulars + "</td>" +
                            "<td style='text-align: center;'>" + item.TravelExpenseDetail_Date.Value.ToLongDateString() + "</td>" +
                            "<td style='text-align: center;'>" + item.Total_Expenses + "</td>" +
                            "</tr>";
            }
            emailDetails += "</table>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo, cc))
            {
            };
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID)
        {
            DateTime currentDate = DateTime.Now;

            var status = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Description)
                .FirstOrDefault();

            ///////---START EMAIL PROCESS-----////////
            var user_userID = _DataContext.ITP_S_SecurityUserOrgRoles
                .Where(um => um.OrgRoleId == org_id)
                .Select(um => um.UserId)
                .FirstOrDefault();
            var user_email = _DataContext.ITP_S_UserMasters
                .Where(x => x.EmpCode == user_userID)
                .FirstOrDefault();
            var comp_name = _DataContext.CompanyMasters
                .Where(x => x.WASSId == comps_id)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == "Pending"
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

            var requestor_fullname = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = Convert.ToString(_DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.Email)
                .FirstOrDefault()) ?? string.Empty;

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/AccedeExpenseReportApproval.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + doc_id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == doc_id
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
            emailDetails += "<tr><th>Expense Type</th><th>Location/Particulars</th><th>Date</th><th>Total Expenses</th></tr>";

            foreach (var item in queryER)
            {
                var exp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.LocParticulars + "</td>" +
                            "<td style='text-align: center;'>" + item.TravelExpenseDetail_Date.Value.ToLongDateString() + "</td>" +
                            "<td style='text-align: center;'>" + item.Total_Expenses + "</td>" +
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

        public void updateWA(int docID, int wfID, int wfaID, int status, string amount, string remarks, string userID, DateTime date, int reim_docID)
        {
            try
            {
                var updateWFA = _DataContext.ITP_T_WorkflowActivities
                    .Where(a => a.Document_Id == docID && a.WF_Id == wfID && a.WFA_Id == wfaID);

                foreach (var ex in updateWFA)
                {
                    ex.Remarks = remarks;
                    ex.DateAction = date;
                    ex.Status = status;
                    ex.ActedBy_User_Id = userID;
                }

                var updateRFPWFA = _DataContext.ITP_T_WorkflowActivities
                    .Where(a => a.Document_Id == reim_docID && a.WF_Id == wfID);

                foreach (var ex in updateRFPWFA)
                {
                    ex.Remarks = remarks;
                    ex.DateAction = date;
                    ex.Status = status;
                    ex.ActedBy_User_Id = userID;
                }

                _DataContext.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }
        }

        public void insertWA(int wf_id, int wfd_id, int org_id, int doc_id, int comps_id, int stat, int reim_docID)
        {
            try
            {
                DateTime currentDate = DateTime.Now;

                SendEmail(doc_id, org_id, comps_id, stat);

                var wfa = new ITP_T_WorkflowActivity()
                {
                    Status = stat,
                    DateAssigned = currentDate,
                    DateAction = null,
                    WF_Id = wf_id,
                    WFD_Id = wfd_id,
                    OrgRole_Id = org_id,
                    Document_Id = doc_id,
                    AppId = 1032,
                    CompanyId = comps_id,
                    IsActive = true,
                    AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel" || x.DCT_Description == "Accede Expense Travel").Select(x => x.DCT_Id).FirstOrDefault()
                };
                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                if (reim_docID != 0) 
                {
                    var reimwfa = new ITP_T_WorkflowActivity()
                    {
                        Status = stat,
                        DateAssigned = currentDate,
                        DateAction = null,
                        WF_Id = wf_id,
                        WFD_Id = wfd_id,
                        OrgRole_Id = org_id,
                        Document_Id = reim_docID,
                        AppId = 1032,
                        CompanyId = comps_id,
                        IsActive = true,
                        AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault()
                    };
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(reimwfa);
                }

                var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == doc_id);
                foreach (ACCEDE_T_TravelExpenseMain t in travel)
                {
                    t.Status = stat;
                }

                _DataContext.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }
        }


        [WebMethod]
        public static bool AJAXReturnDisapproveDocument(string action, string remarks)
        {
            TravelExpenseReview rev = new TravelExpenseReview();
            rev.ReturnDisapproveDocument(action, remarks);

            return true;
        }

        public void ReturnDisapproveDocument(string action, string remarks)
        {
            var id = Convert.ToInt32(Session["TravelExp_Id"]);
            var doc_status = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Status).FirstOrDefault();    
            var doc_desc = _DataContext.ITP_S_Status.Where(x => x.STS_Id == doc_status).Select(x => x.STS_Description).FirstOrDefault();
            var wfa = Convert.ToInt32(Session["wfa"]);
            var userID = Convert.ToString(Session["userID"]);
            var compID = Convert.ToInt32(Session["comp"]);
            var prepID = Convert.ToInt32(Session["prep"]);
            var status = 0;

            try
            {
                if (action == "return")
                {
                    if (doc_desc == "Pending at Audit")
                        status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Returned by Audit").Select(x => x.STS_Id).FirstOrDefault();
                    else if (doc_desc == "Pending at Finance")
                        status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Returned by Finance").Select(x => x.STS_Id).FirstOrDefault();
                    else
                        status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Returned").Select(x => x.STS_Id).FirstOrDefault();
                }
                else
                    status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disapproved").Select(x => x.STS_Id).FirstOrDefault();

                var cc = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(Session["empid"])).Select(x => x.Email).FirstOrDefault();

                //UPDATE RFP Main
                var updateRFPMain = _DataContext.ACCEDE_T_RFPMains
                    .Where(e => e.Exp_ID == id && e.IsExpenseReim == true);
                var rfpid = updateRFPMain.Select(x => x.ID).FirstOrDefault();

                foreach (ACCEDE_T_RFPMain e in updateRFPMain)
                {
                    e.Remarks = remarks;
                    e.Status = status;
                }
                _DataContext.SubmitChanges();

                //UPDATE Workflow Activity 
                var updateRFPWFA = _DataContext.ITP_T_WorkflowActivities
                    .Where(e => e.Document_Id == rfpid && e.AppId == 1032 && e.AppDocTypeId == 1011 && e.WFA_Id == wfa);

                foreach (ITP_T_WorkflowActivity e in updateRFPWFA)
                {
                    e.DateAction = DateTime.Now;
                    e.Remarks = remarks;
                    e.Status = status;
                    e.ActedBy_User_Id = userID;
                }
                _DataContext.SubmitChanges();


                //UPDATE Travel Main
                var updateTravelMain = _DataContext.ACCEDE_T_TravelExpenseMains
                    .Where(e => e.ID == id);

                foreach (ACCEDE_T_TravelExpenseMain e in updateTravelMain)
                {
                    e.Remarks = remarks;
                    e.Status = status;
                }

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();
                //UPDATE Workflow Activity 
                var updateWFA = _DataContext.ITP_T_WorkflowActivities
                    .Where(e => e.Document_Id == id && e.AppId == 1032 && e.AppDocTypeId == app_docType.DCT_Id && e.WFA_Id == wfa);

                foreach (ITP_T_WorkflowActivity e in updateWFA)
                {
                    e.DateAction = DateTime.Now;
                    e.Remarks = remarks;
                    e.Status = status;
                    e.ActedBy_User_Id = userID;
                }
                _DataContext.SubmitChanges();

                SendEmailWithCC(id, userID, compID, status, prepID, cc, remarks);
            }
            catch (Exception)
            {
                throw;
            }
        }


        [WebMethod]
        public static bool AJAXApproveDocument(string remarks)
        {
            TravelExpenseReview rev = new TravelExpenseReview();
            rev.ApproveDocument(remarks);

            return true;
        }

        public void ApproveDocument(string remarks)
        {
            try
            {
                int docID = Convert.ToInt32(Session["TravelExp_Id"]);
                int reim_docID = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == docID && x.IsExpenseReim == true).Where(x => x.isTravel == true).Select(x => x.ID).FirstOrDefault();
                var doctype_id = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault();
                var pmid = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == docID && x.IsExpenseReim == true).Where(x => x.isTravel == true).Select(x => x.PayMethod).FirstOrDefault();
                var reimPayMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == pmid).Select(x => x.PMethod_name).FirstOrDefault();
                string userID = Convert.ToString(Session["userID"]);
                int preparerID = Convert.ToInt32(Session["prep"]);
                var cc = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(Session["empid"])).Select(x => x.Email).FirstOrDefault();
                int usercompanyID = Convert.ToInt32(Session["userCompanyID"]);
                int companyID = int.Parse(Session["comp"].ToString());
                // GET WORKFLOW ID 
                var wfID = Convert.ToInt32(Session["wf"]);
                // GET WORKFLOWACTIVITY ID 
                var wfaID = Convert.ToInt32(Session["wfa"]);
                // GET WORKFLOWDETAILS ID
                var wfdID = Convert.ToInt32(Session["wfd"]);
                // GET SEQUENCE
                var sequence = _DataContext.ITP_S_WorkflowDetails
                    .Where(e => e.WFD_Id == wfdID)
                    .Select(e => e.Sequence)
                    .FirstOrDefault() + 1;
                // GET ORGROLE ID
                var orgRoleID = _DataContext.ITP_S_WorkflowDetails
                    .Where(e => e.WF_Id == wfID && e.Sequence == sequence)
                    .Select(e => e.OrgRole_Id)
                    .FirstOrDefault();
                // UPDATE WORKFLOWACTIVITY
                updateWA(docID, wfID, wfaID, 7, "", remarks, userID, DateTime.Now, reim_docID);

                // IF TRUE, INSERT TO WORKFLOWACTIVITY
                if (orgRoleID != null)
                {
                    var newwfdID = _DataContext.ITP_S_WorkflowDetails
                        .Where(e => e.Sequence == sequence && e.WF_Id == wfID && e.OrgRole_Id == orgRoleID)
                        .Select(e => e.WFD_Id)
                        .FirstOrDefault();

                    insertWA(wfID, newwfdID, Convert.ToInt32(orgRoleID), docID, companyID, Convert.ToInt32(Session["doc_stat"]), reim_docID);
                }
                else
                {
                    if (Convert.ToString(Session["doc_stat2"]) == "Pending at Cashier")
                    {
                        var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID);
                        foreach (ACCEDE_T_TravelExpenseMain t in travel)
                        {
                            t.Status = 7;
                        }
                        _DataContext.SubmitChanges();

                        var updateReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);
                        foreach (ACCEDE_T_RFPMain r in updateReim)
                        {
                            r.Status = 7;
                        }
                        _DataContext.SubmitChanges();
                    }
                    else if (Convert.ToString(Session["doc_stat2"]) == "Pending at P2P")
                    {
                        if (Convert.ToDecimal(Session["totalCA"]) < Convert.ToDecimal(Session["totalEXP"]) && reimPayMethod == "Check")
                        {
                            var cashierwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACCEDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                            var cashierwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                            var cashierorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                            var cashstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Cashier" || s.STS_Name == "Pending at Cashier").Select(s => s.STS_Id).FirstOrDefault();

                            insertWA(cashierwf, cashierwfd, (int)cashierorID, docID, companyID, cashstatus, reim_docID);
                        }
                        else
                        {
                            var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID);
                            foreach (ACCEDE_T_TravelExpenseMain t in travel)
                            {
                                t.Status = 7;
                            }
                            _DataContext.SubmitChanges();

                            var updateReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);
                            foreach (ACCEDE_T_RFPMain r in updateReim)
                            {
                                r.Status = 7;
                            }
                            _DataContext.SubmitChanges();
                        }
                    }
                    else
                    {
                        var fapwf = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID).Select(x => x.FAPWF_Id).FirstOrDefault() ?? 0;
                        var fapwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == fapwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                        var orID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == fapwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault() ?? 0;

                        var countFAPWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == fapwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id);

                        if (countFAPWF > 0)
                        {
                            Debug.WriteLine("There's FAPWF");
                            var fapRetStatus = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Returned by Finance").Select(x => x.STS_Id).FirstOrDefault();
                            var countApprovedFAPWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == fapwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id && (w.Status != 7 && w.Status != 8 && w.Status != fapRetStatus));

                            if (countApprovedFAPWF <= 0)
                            {
                                Debug.WriteLine("All FAPWF approved");

                                var audwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => (w.Name == "ACDE AUDIT" || w.Name == "ACCEDE AUDIT") && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                                var audwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == audwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                                var audorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == audwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();

                                var countAUDWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == audwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id);

                                if (countAUDWF > 0)
                                {
                                    Debug.WriteLine("There's AUDWF");
                                    var audRetStatus = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Returned by Audit").Select(x => x.STS_Id).FirstOrDefault();
                                    var countApprovedAUDWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == audwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id && w.Status != 7 && w.Status != 8 && w.Status != audRetStatus);

                                    if (countApprovedAUDWF <= 0)
                                    {
                                        Debug.WriteLine("All AUDWF approved");
                                        var updateWFA = _DataContext.ITP_T_WorkflowActivities.Where(a => a.Document_Id == docID && a.AppDocTypeId == doctype_id && a.WF_Id == wfID && a.WFA_Id == wfaID);

                                        foreach (var ex in updateWFA)
                                        {
                                            ex.Remarks = remarks;
                                            ex.DateAction = DateTime.Now;
                                            ex.Status = 7;
                                            ex.ActedBy_User_Id = userID;
                                        }                                        

                                        var liqStatus = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Liquidated").Select(x => x.STS_Id).FirstOrDefault();
                                        var updateCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.TranType == 1 && x.isTravel == true && x.Exp_ID == docID);
                                        foreach (ACCEDE_T_RFPMain r in updateCA)
                                        {
                                            r.Status = liqStatus;
                                        }
                                        _DataContext.SubmitChanges();

                                        if (Convert.ToDecimal(Session["totalCA"]) == Convert.ToDecimal(Session["totalEXP"]) || Convert.ToDecimal(Session["totalCA"]) > Convert.ToDecimal(Session["totalEXP"]) || (Convert.ToDecimal(Session["totalCA"]) < Convert.ToDecimal(Session["totalEXP"]) && reimPayMethod == "Check"))
                                        {
                                            var p2pwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE P2P" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                                            var p2pwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == p2pwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                                            var p2porID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == p2pwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                                            var p2pstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at P2P" || s.STS_Name == "Pending at P2P").Select(s => s.STS_Id).FirstOrDefault();

                                            insertWA(p2pwf, p2pwfd, (int)p2porID, docID, companyID, p2pstatus, reim_docID);
                                        }
                                        else
                                        {
                                            var cashierwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                                            var cashierwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                                            var cashierorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                                            var cashstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Cashier" || s.STS_Name == "Pending at Cashier").Select(s => s.STS_Id).FirstOrDefault();

                                            insertWA(cashierwf, cashierwfd, (int)cashierorID, docID, companyID, cashstatus, reim_docID);
                                        }
                                    }
                                }
                                else
                                {
                                    Debug.WriteLine("No AUDWF");
                                    var audstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Audit" || s.STS_Name == "Pending at Audit").Select(s => s.STS_Id).FirstOrDefault();
                                    insertWA(Convert.ToInt32(audwf), Convert.ToInt32(audwfd), Convert.ToInt32(audorID), docID, companyID, audstatus, reim_docID);
                                }
                            }
                        }
                        else
                        {
                            Debug.WriteLine("No FAPWF");
                            var fapstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Finance" || s.STS_Name == "Pending at Finance").Select(s => s.STS_Id).FirstOrDefault();
                            insertWA(fapwf, fapwfd, orID, docID, companyID, fapstatus, reim_docID);
                        }
                    }
                }
            }
            catch (Exception)
            {
                
                throw;
            }
        }

        protected void forAccountingGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            e.NewValues["TravelExpenseMain_ID"] = Convert.ToInt32(Session["TravelExp_Id"]);
        }


        [WebMethod]
        public static object RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            TravelExpenseReview exp = new TravelExpenseReview();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public object RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                int rfpCompany;
                int rfpPayMethod;
                int rfpTypeTransact;
                string rfpSAPDoc;
                int rfpDepartment;
                string rfpCostCenter;
                string rfpIO;
                string rfpPayee;
                decimal rfpAmount;
                DateTime rfpLastDayTransact;
                string rfpPurpose;
                string rfpstatus;

                var rfp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.RFP_DocNum == rfpDoc).FirstOrDefault();

                Session["passRFPID"] = rfp.ID;

                rfpCompany = Convert.ToInt32(rfp.Company_ID);
                rfpPayMethod = Convert.ToInt32(rfp.PayMethod);
                rfpTypeTransact = Convert.ToInt32(rfp.TranType);
                rfpSAPDoc = rfp.SAPDocNo;
                rfpDepartment = Convert.ToInt32(rfp.Department_ID);
                rfpCostCenter = rfp.SAPCostCenter;
                rfpIO = rfp.IO_Num;
                rfpPayee = rfp.Payee;
                rfpAmount = Convert.ToDecimal(rfp.Amount);
                rfpLastDayTransact = Convert.ToDateTime(rfp.LastDayTransact);
                rfpPurpose = rfp.Purpose;
                var stat = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(rfp.Exp_ID)).Select(x => x.Status).FirstOrDefault();
                rfpstatus = _DataContext.ITP_S_Status.Where(x => x.STS_Id == stat).Select(x => x.STS_Description).FirstOrDefault();

                return new { rfpCompany, rfpPayMethod, rfpTypeTransact, rfpSAPDoc, rfpDepartment, rfpCostCenter, rfpIO, rfpPayee, rfpAmount, rfpLastDayTransact, rfpstatus };

            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static bool UpdateRFPChangesAJAX(int rfpPayMethod, string rfpSAPDoc)
        {
            TravelExpenseReview exp = new TravelExpenseReview();
            return exp.UpdateRFPChanges(rfpPayMethod, rfpSAPDoc);
        }

        public bool UpdateRFPChanges(int rfpPayMethod, string rfpSAPDoc)
        {
            try
            {
                var id = Convert.ToInt32(Session["passRFPID"]);

                //UPDATE RFP Main
                var updateRFPMain = _DataContext.ACCEDE_T_RFPMains
                    .Where(e => e.ID == id && e.IsExpenseReim == true && e.isTravel == true);

                foreach (ACCEDE_T_RFPMain e in updateRFPMain)
                {
                    e.PayMethod = rfpPayMethod;
                    e.SAPDocNo = rfpSAPDoc;
                }
                _DataContext.SubmitChanges();

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        [WebMethod]
        public static ExpDetails DisplayExpDetailsAJAX(int expDetailID)
        {
            TravelExpenseReview exp = new TravelExpenseReview();
            return exp.DisplayExpDetails(expDetailID);
        }

        public ExpDetails DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == expDetailID).FirstOrDefault();
            ExpDetails exp_det_class = new ExpDetails();

            if (exp_details != null)
            {
                exp_det_class.travelDate = Convert.ToDateTime(exp_details.TravelExpenseDetail_Date).ToString("MM/dd/yyyy hh:mm:ss");
                if (exp_details.LocParticulars != null)
                {
                    exp_det_class.locParticulars = exp_details.LocParticulars;
                }
                if (exp_details.Total_Expenses != null)
                {
                    exp_det_class.totalExp = exp_details.Total_Expenses.ToString();
                }

                Session["ExpDetailsID"] = expDetailID.ToString();
            }

            return exp_det_class;
        }

        public class ExpDetails
        {
            public string travelDate { get; set; }
            public string locParticulars { get; set; }
            public string totalExp { get; set; }
        }

        protected void ExpenseEditForm_Init(object sender, EventArgs e)
        {
            InitializeDataSet();
        }

        private void InitializeDataSet()
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("TravelExpenseDetailMap_ID", "ReimTranspo_Type1", "ReimTranspo_Amount1", "ReimTranspo_Type2", "ReimTranspo_Amount2", "ReimTranspo_Type3", "ReimTranspo_Amount3", "FixedAllow_ForP", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount", "OtherBus_Type", "OtherBus_Specify", "OtherBus_Amount")
                    //CreateDataTable("ReimTranspo_ID", "ReimTranspo_Type", "ReimTranspo_Amount"),
                    //CreateDataTable("FixedAllow_ID", "FixedAllow_ForP", "FixedAllow_Amount"),
                    //CreateDataTable("MiscTravelExp_ID", "MiscTravelExp_Type", "MiscTravelExp_Amount", "MiscTravelExp_Specify"),
                    //CreateDataTable("OtherBusinessExp_ID", "OtherBusinessExp_Type", "OtherBusinessExp_Amount", "OtherBusinessExp_Specify"),
                    //CreateDataTable("Entertainment_ID", "Entertainment_Explain", "Entertainment_Amount"),
                    //CreateDataTable("BusinessMeal_ID", "BusinessMeal_Explain", "BusinessMeal_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
                ds = (DataSet)Session["DataSet"];



            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileAttachment", typeof(byte[]));
                masterTable.Columns.Add("FileExtension", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("Description", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;
            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
            ASPxGridView22.DataSource = dsDoc.Tables[0];
            ASPxGridView22.DataBind();
        }

        private DataTable CreateDataTable(string idColumnName, params string[] columnNames)
        {
            var table = new DataTable();
            table.Columns.Add(idColumnName, typeof(int));
            foreach (var columnName in columnNames)
            {
                Type columnType = columnName.Contains("Amount") ? typeof(decimal) : typeof(string);
                table.Columns.Add(columnName, columnType);
            }
            table.PrimaryKey = new[] { table.Columns[idColumnName] };
            return table;
        }

        private int GetNewId(int tableIndex, string idColumn)
        {
            var table = ds.Tables[tableIndex];
            return table.Rows.Count == 0 ? 0 : table.AsEnumerable().Max(row => row.Field<int>(idColumn)) + 1;
        }

        private DataTable GetDataTableFromSqlDataSource(SqlDataSource sqlDataSource)
        {
            DataView dataView = (DataView)sqlDataSource.Select(DataSourceSelectArguments.Empty);
            return dataView.ToTable();
        }

        protected void addExpCallback_Callback(object sender, CallbackEventArgsBase e)
        {
            // Clear the DataSet tables for the "add" action
            ds = (DataSet)Session["DataSet"];
            foreach (DataTable table in ds.Tables)
            {
                table.Clear();
            }
            if (e.Parameter == "add")
            {
                Session["expAction"] = "add";
            }
            else if (e.Parameter == "edit")
            {
                Session["expAction"] = "edit";

                // Load data from SqlDataSources into DataTables and merge
                ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlExpDetailsMap));

                //ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlRTMap));
                //ds.Tables[1].Merge(GetDataTableFromSqlDataSource(SqlFAMap));
                //ds.Tables[2].Merge(GetDataTableFromSqlDataSource(SqlMTMap));
                //ds.Tables[3].Merge(GetDataTableFromSqlDataSource(SqlOBMap));
                //ds.Tables[4].Merge(GetDataTableFromSqlDataSource(SqlEMap));
                //ds.Tables[5].Merge(GetDataTableFromSqlDataSource(SqlBMMap));

                //dsDoc.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlDocs2));
            }

            // Bind the tables to the grids
            ASPxGridView22.DataSource = ds.Tables[0];
            ASPxGridView22.DataBind();

            ASPxGridView22.DataSource = SqlDocs2;
            ASPxGridView22.DataBind();

            //reimTranGrid.DataSource = ds.Tables[0];
            //fixedAllowGrid.DataSource = ds.Tables[1];
            //miscTravelGrid.DataSource = ds.Tables[2];
            //otherBusGrid.DataSource = ds.Tables[3];
            //entertainmentGrid.DataSource = ds.Tables[4];
            //busMealsGrid.DataSource = ds.Tables[5];
            //TraDocuGrid.DataSource = dsDoc.Tables[0];

            //// Data bind to refresh the grids
            //reimTranGrid.DataBind();
            //fixedAllowGrid.DataBind();
            //miscTravelGrid.DataBind();
            //otherBusGrid.DataBind();
            //entertainmentGrid.DataBind();
            //busMealsGrid.DataBind();
            //TraDocuGrid.DataBind();

            //reimTranGrid.JSProperties["cpSummary"] = reimTranGrid.GetTotalSummaryValue(reimTranGrid.TotalSummary["ReimTranspo_Amount"]);
            //fixedAllowGrid.JSProperties["cpSummary"] = fixedAllowGrid.GetTotalSummaryValue(fixedAllowGrid.TotalSummary["FixedAllow_Amount"]);
            //miscTravelGrid.JSProperties["cpSummary"] = miscTravelGrid.GetTotalSummaryValue(miscTravelGrid.TotalSummary["MiscTravelExp_Amount"]);
            //otherBusGrid.JSProperties["cpSummary"] = otherBusGrid.GetTotalSummaryValue(otherBusGrid.TotalSummary["OtherBusinessExp_Amount"]);
            //entertainmentGrid.JSProperties["cpSummary"] = entertainmentGrid.GetTotalSummaryValue(entertainmentGrid.TotalSummary["Entertainment_Amount"]);
            //busMealsGrid.JSProperties["cpSummary"] = busMealsGrid.GetTotalSummaryValue(busMealsGrid.TotalSummary["BusinessMeal_Amount"]);
        }

        protected void ExpenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Fixed Allowances")
            {
                var amount = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.FixedAllow_Amount));

                if (amount.ToString() == "0.00" || string.IsNullOrEmpty(amount.ToString()))
                    e.DisplayText = "0.00";
                else
                {
                    e.DisplayText = amount.ToString("N");
                }
            }

            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            {
                var travelExpenseDetailId = Convert.ToInt32(e.Value);
                var total = _DataContext.ACCEDE_T_TravelExpenseDetailsMaps
                    .Where(or => or.TravelExpenseDetail_ID == travelExpenseDetailId)
                    .Sum(or =>
                        (or.ReimTranspo_Amount1 ?? 0) +
                        (or.ReimTranspo_Amount2 ?? 0) +
                        (or.ReimTranspo_Amount3 ?? 0) +
                        (or.MiscTravel_Amount ?? 0) +
                        (or.Entertainment_Amount ?? 0) +
                        (or.BusMeals_Amount ?? 0) +
                        (or.OtherBus_Amount ?? 0)
                    );

                e.DisplayText = total == 0 ? "0.00" : total.ToString("N");
            }

            //if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            //{
            //    var amount1 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpMiscTravelMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.MiscTravelExp_Amount));
            //    var amount2 = _DataContext.ACCEDE_T_TraExpReimTranspoMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.ReimTranspo_Amount) ?? 0;
            //    var amount3 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpOtherBusMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.OtherBusinessExp_Amount));
            //    var amount4 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpEntertainmentMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.Entertainment_Amount));
            //    var amount5 = Convert.ToDecimal(_DataContext.ACCEDE_T_TraExpBusinessMealMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.BusinessMeal_Amount));

            //    var total = Convert.ToDecimal(amount1 + amount2 + amount3 + amount4 + amount5);

            //    if (total.ToString() == "0.00" || string.IsNullOrEmpty(total.ToString()))
            //        e.DisplayText = "0.00";
            //    else
            //    {
            //        e.DisplayText = total.ToString("N");
            //    }
            //}
        }

        protected void ASPxGridView22_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "ReimTranspo_Amount1" || e.Column.FieldName == "ReimTranspo_Amount2" || e.Column.FieldName == "ReimTranspo_Amount3" || e.Column.FieldName == "FixedAllow_Amount" || e.Column.FieldName == "MiscTravel_Amount" || e.Column.FieldName == "Entertainment_Amount" || e.Column.FieldName == "BusMeals_Amount" || e.Column.FieldName == "OtherBus_Amount")
            {
                if (Convert.ToString(e.Value) == "0" || Convert.ToString(e.Value) == "0.00")
                    e.DisplayText = string.Empty;
            }
        }
    }
}