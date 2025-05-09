using DevExpress.ClipboardSource.SpreadsheetML;
using DevExpress.CodeParser;
using DevExpress.Pdf.Native.DocumentSigning;
using DevExpress.Pdf.Xmp;
using DevExpress.Utils;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
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

                    string empCode = Session["userID"].ToString();
                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();
                    var status = "";
                    Session["statusid"] = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").Select(x => x.STS_Id).FirstOrDefault();
                    Session["appdoctype"] = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault();

                    if (mainExp != null)
                    {
                        Session["isForeignTravel"] = mainExp.ForeignDomestic == "Foreign" ? 1 : 0;
                        Session["ford"] = mainExp.ForeignDomestic;
                        Session["currency"] = mainExp.ForeignDomestic == "Domestic" ? '₱' : mainExp.ForeignDomestic == "Foreign" ? '$' : ' ';
                        status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault();
                        Session["doc_stat2"] = status;

                        ExpenseEditForm.Items[0].Caption = "Travel Expense Document No.: " + mainExp.Doc_No + " (" + status + ")";

                        if (status == "Pending at Finance" || status == "Pending at P2P")
                        {
                            chargedCB.ClientEnabled = true;
                            chargedCB0.ClientEnabled = true;
                            chargedCB.DropDownButton.Visible = true;
                            chargedCB0.DropDownButton.Visible = true;
                        }
                        else
                        {
                            chargedCB.ClientEnabled = false;
                            chargedCB0.ClientEnabled = false;
                            chargedCB.DropDownButton.Visible = false;
                            chargedCB0.DropDownButton.Visible = false;
                        }
                        
                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());
                        Session["DocNo"] = mainExp.Doc_No.ToString();

                        var forAccounting = ExpenseEditForm.FindItemOrGroupByName("forAccounting") as LayoutGroup;
                        if (status.Contains("Pending at Finance"))
                            forAccounting.ClientVisible = true;
                        else
                            forAccounting.ClientVisible = false;

                        var disapproveItem = ExpenseEditForm.FindItemOrGroupByName("disapproveItem") as LayoutItem;
                        var returnItem = ExpenseEditForm.FindItemOrGroupByName("returnItem") as LayoutItem;
                        var returnPrevItem = ExpenseEditForm.FindItemOrGroupByName("returnPrevItem") as LayoutItem;
                        var forwardItem = ExpenseEditForm.FindItemOrGroupByName("forwardItem") as LayoutItem;

                        // GET WORKFLOW ID 
                        var wfID = Convert.ToInt32(Session["wf"]);
                        // GET WORKFLOWDETAILS ID
                        var wfdID = Convert.ToInt32(Session["wfd"]);
                        // GET SEQUENCE
                        var sequence = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WFD_Id == wfdID)
                            .Select(x => x.Sequence)
                            .FirstOrDefault() + 1;
                        // GET ORGROLE ID
                        var orgRoleID = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WF_Id == wfID && x.Sequence == sequence)
                            .Select(x => x.OrgRole_Id)
                            .FirstOrDefault();

                        if ((status == "Pending at Finance") && orgRoleID == null)
                        {
                            forwardItem.Visible = true;

                            var FinExecVerify = _DataContext.vw_ACCEDE_FinApproverVerifies.Where(x => x.UserId == empCode)
                                .Where(x => x.Role_Name == "Accede Finance Executive").FirstOrDefault();

                            var FinCFOVerify = _DataContext.vw_ACCEDE_FinApproverVerifies.Where(x => x.UserId == empCode)
                                .Where(x => x.Role_Name == "Accede CFO").FirstOrDefault();

                            if (FinExecVerify != null)
                            {
                                var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Name.Contains("forward cfo") && x.App_Id == 1032 && (x.Company_Id == mainExp.Company_Id || x.Company_Id == mainExp.ChargedToComp))
                                    .ToList();

                                if (forwardWFList.Any()) // Ensure there's data before binding
                                {
                                    drpdown_ForwardWF.DataSource = forwardWFList;
                                    drpdown_ForwardWF.ValueField = "WF_Id";
                                    drpdown_ForwardWF.TextField = "Name";
                                    drpdown_ForwardWF.DataBind();

                                    if (drpdown_ForwardWF.Items.Count == 1)
                                    {
                                        drpdown_ForwardWF.SelectedIndex = 0;
                                        SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = forwardWFList[0].WF_Id.ToString();

                                    }
                                }
                            }
                            else if (FinCFOVerify != null)
                            {
                                var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Name.Contains("forward pres") && x.App_Id == 1032 && (x.Company_Id == mainExp.Company_Id || x.Company_Id == mainExp.ChargedToComp))
                                    .ToList();

                                if (forwardWFList.Any()) // Ensure there's data before binding
                                {
                                    drpdown_ForwardWF.DataSource = forwardWFList;
                                    drpdown_ForwardWF.ValueField = "WF_Id";
                                    drpdown_ForwardWF.TextField = "Name";
                                    drpdown_ForwardWF.DataBind();

                                    if (drpdown_ForwardWF.Items.Count == 1)
                                    {
                                        drpdown_ForwardWF.SelectedIndex = 0;
                                        SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = forwardWFList[0].WF_Id.ToString();

                                    }
                                }
                            }
                            else
                            {
                                var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Name.Contains("forward exec") && x.App_Id == 1032 && (x.Company_Id == mainExp.Company_Id || x.Company_Id == mainExp.ChargedToComp))
                                    .ToList();

                                if (forwardWFList.Any()) // Ensure there's data before binding
                                {
                                    drpdown_ForwardWF.DataSource = forwardWFList;
                                    drpdown_ForwardWF.ValueField = "WF_Id";
                                    drpdown_ForwardWF.TextField = "Name";
                                    drpdown_ForwardWF.DataBind();

                                    if (drpdown_ForwardWF.Items.Count == 1)
                                    {
                                        drpdown_ForwardWF.SelectedIndex = 0;
                                        SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = forwardWFList[0].WF_Id.ToString();
                                    }
                                }
                            }
                        }
                        else if ((status == "Forwarded") && orgRoleID == null)
                        {
                            forwardItem.Visible = true;

                            var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Name.Contains("forward"))
                                    .Where(x => x.App_Id == 1032)
                                    .Where(x => (x.Company_Id == mainExp.Company_Id || x.Company_Id == mainExp.ChargedToComp))
                                    .ToList();

                            if (forwardWFList.Any()) // Ensure there's data before binding
                            {
                                drpdown_ForwardWF.DataSource = forwardWFList;
                                drpdown_ForwardWF.ValueField = "WF_Id";
                                drpdown_ForwardWF.TextField = "Name";
                                drpdown_ForwardWF.DataBind();

                                if (drpdown_ForwardWF.Items.Count == 1)
                                {
                                    drpdown_ForwardWF.SelectedIndex = 0;
                                    SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = forwardWFList[0].WF_Id.ToString();
                                }
                            }
                        }
                        else
                        {
                            forwardItem.Visible = false;
                        }

                        if (status == "Pending at Finance" || status == "Pending at P2P" || mainExp.ExpenseType_ID != 1)
                        {
                            disapproveItem.Visible = false;
                        }

                        if (status == "Pending at Audit")
                        {
                            disapproveItem.Visible = false;
                            returnBtn.Text = "Return to Creator";
                            returnPrevItem.ClientVisible = true;
                        }

                        if (status == "Pending at Cashier")
                        {
                            disapproveItem.Visible = false;
                            returnItem.Visible = false;

                            var fapWACount = _DataContext.ITP_T_WorkflowActivities.Count(x => x.AppId == 1032 && x.AppDocTypeId == app_docType.DCT_Id && x.Document_Id == mainExp.ID && x.WF_Id == mainExp.FAPWF_Id);

                            if (fapWACount > 0)
                            {
                                approveBtn.Text = "Disburse";
                                approvePopBtn.Text = "Disburse";
                                ApprovePopup.HeaderText = "Disburse Expense Item";
                                ASPxFormLayout1_E2.Text = "Are you sure to disburse item?";
                            }
                            else
                            {
                                approveBtn.Text = "Approve";
                                approvePopBtn.Text = "Approve";
                                ApprovePopup.HeaderText = "Approve Expense Report";
                                ASPxFormLayout1_E2.Text = "Are you sure to approve item?";
                            }
                        }
                    }

                    CAGrid.DataBind();
                    ExpenseGrid.DataBind();

                    InitializeExpCA(mainExp, status);
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

        private void InitializeExpCA(ACCEDE_T_TravelExpenseMain mainExp, string status)
        {
            try
            {
                var due_lbl = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutItem;
                var remItem = ExpenseEditForm.FindItemOrGroupByName("remItem") as LayoutItem;

                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.isTravel == true && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reimDetails.ClientVisible = true;
                    reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                }

                var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                var userId = Convert.ToString(Session["prep"]);

                var totalca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId && x.isTravel == true)
                    .Sum(x => (decimal?)x.Amount) ?? 0;
                Session["totalCA"] = totalca;

                var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Where(x => x.TravelExpenseMain_ID == travelExpId)
                    .Sum(x => (decimal?)x.Total_Expenses) ?? 0;
                Session["totalEXP"] = totalexp;

                var countCA = _DataContext.ACCEDE_T_RFPMains
                    .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId && x.isTravel == true);

                var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Count(x => x.TravelExpenseMain_ID == travelExpId);

                var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                if (totalexp > totalca)
                {
                    remItem.ClientVisible = false;
                    due_lbl.Caption = "Due To Employee";
                    if (reim != null)
                        reimDetails.ClientVisible = true;
                    else
                        reimDetails.ClientVisible = false;
                }
                else if (totalca > totalexp)
                {
                    due_lbl.Caption = "Due To Company";
                    reimDetails.ClientVisible = false;
                    remItem.ClientVisible = true;

                    if (status == "Pending at Cashier")
                    {
                        arNoTB.ClientEnabled = true;
                        UploadController.ClientVisible = true;
                    }
                    else if(status == "Pending")
                        remItem.ClientVisible = false;
                }
                else
                {
                    due_lbl.Caption = "Due To Company";
                    reimDetails.ClientVisible = false;
                    remItem.ClientVisible = false;
                }

                departmentCB.Value = expType;
                lbl_caTotal.Text = Convert.ToString(Session["currency"]) + totalca.ToString("N2");
                lbl_expenseTotal.Text = Convert.ToString(Session["currency"]) + totalexp.ToString("N2");
                lbl_dueTotal.Text = totalexp > totalca ? "(" + Convert.ToString(Session["currency"]) + "" + (totalexp - totalca).ToString("N2") + ")" : Convert.ToString(Session["currency"]) + (totalca - totalexp).ToString("N2");

                var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                if (mainExp != null)
                {
                    Session["mainwfid"] = Convert.ToString(mainExp.WF_Id);
                    SqlWF.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();

                    Session["fapwfid"] = Convert.ToString(mainExp.FAPWF_Id);
                    SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                }
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
                    docs.Description = String.Empty;
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


        public void SendEmailComplete(int id, int status, int prepID, string remarks, int sender)
        {
            ///////---START EMAIL PROCESS-----////////
            var main = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).FirstOrDefault();
            var compname = _DataContext.CompanyMasters.Where(x => x.WASSId == main.Company_Id).Select(x => x.CompanyShortName).FirstOrDefault();
            var docno = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Doc_No).FirstOrDefault();
            var stat = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == status)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == "Complete"
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
            string senderName = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.FullName).FirstOrDefault());
            string emailSender = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.Email).FirstOrDefault());
            string senderRemarks = remarks;
            string emailSite = "https://devapps.anflocor.com/Accede/AllAccedeApprovalPage.aspx";
            string sendEmailTo = requestor_email;
            string emailSubject = "Document No. " + docno + " (" + stat.STS_Description + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";
            string currentDate = DateTime.Now.ToShortDateString();

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + compname + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + main.Doc_No + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + stat.STS_Description + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            }
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
            string emailSite = "https://devapps.anflocor.com/Accede/AllAccedeApprovalPage.aspx";
            string sendEmailTo = requestor_email;
            string emailSubject = "Document No. " + id + " (" + stat.STS_Description + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";
            string currentDate = DateTime.Now.ToShortDateString();

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == id
                          select er;


            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + stat.STS_Description + "</strong></td></tr>";
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
                            "<td style='text-align: center;'>" + item.TravelExpenseDetail_Date.Value.ToShortDateString() + "</td>" +
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
            }
        }

        public void SendEmailFromCashP2P(int id, int status, int prepID, int sender)
        {
            string currentDate = DateTime.Now.ToShortDateString();

            var main = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).FirstOrDefault();
            var compname = _DataContext.CompanyMasters.Where(x => x.WASSId == main.Company_Id).Select(x => x.CompanyShortName).FirstOrDefault();
            var stat = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == status)
                .Select(x => x.STS_Description)
                .FirstOrDefault();

            ///////---START EMAIL PROCESS-----////////

            //Start--   Get Text info

            var emailMessage = "Your request is now " + stat;
            var emailSubMessage = "Please forward the necessary documents and indicate the Document Reference Number.";
            var emailColor = "#006DD6";
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
            string recipientName = requestor_fullname;
            string senderName = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.FullName).FirstOrDefault());
            string emailSender = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.Email).FirstOrDefault());
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/Accede/AllAccedeApprovalPage.aspx";
            string sendEmailTo = requestor_email;
            string emailSubject = "Document No. " + main.Doc_No + " (" + stat + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + compname + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + main.Doc_No + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + stat + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            }
        }

        public void SendEmailFromAudit(int id, int status, int prepID, string remarks, int sender)
        {
            ///////---START EMAIL PROCESS-----////////
            var main = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).FirstOrDefault();
            var compname = _DataContext.CompanyMasters.Where(x => x.WASSId == main.Company_Id).Select(x => x.CompanyShortName).FirstOrDefault();
            var docno = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.Doc_No).FirstOrDefault();
            var stat = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == status)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == "PendingAudit"
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
            string senderName = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.FullName).FirstOrDefault());
            string emailSender = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(sender)).Select(x => x.Email).FirstOrDefault());
            string senderRemarks = remarks;
            string emailSite = "https://devapps.anflocor.com/Accede/AllAccedeApprovalPage.aspx";
            string sendEmailTo = requestor_email;
            string emailSubject = "Document No. " + docno + " (" + stat.STS_Description + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";
            string currentDate = DateTime.Now.ToShortDateString();

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + compname + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + main.Doc_No + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + stat.STS_Description + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            }
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID)
        {
            string currentDate = DateTime.Now.ToShortDateString();

            var docno = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).Select(x => x.Doc_No).FirstOrDefault();
            var main = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).FirstOrDefault();
            var preparer = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(main.Preparer_Id)).Select(x => x.FullName).FirstOrDefault();

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
                .Where(um => um.EmpCode == Convert.ToString(Session["userID"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = Convert.ToString(_DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["userID"]))
                .Select(um => um.Email)
                .FirstOrDefault()) ?? string.Empty;

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/Accede/AllAccedeApprovalPage.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + docno + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + docno + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + preparer + "</strong></td></tr>";
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
                            "<td style='text-align: center;'>" + item.TravelExpenseDetail_Date.Value.ToShortDateString() + "</td>" +
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
            }
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

        public void insertWA(int wf_id, int wfd_id, int org_id, int doc_id, int comps_id, int stat, int reim_docID, bool isforward = false)
        {
            try
            {
                DateTime currentDate = DateTime.Now;
                string stats = _DataContext.ITP_S_Status.Where(x => x.STS_Id == stat).Select(x => x.STS_Description).FirstOrDefault();

                if (stats == "Pending" || stats == "Pending at Finance" || stats == "Forwarded")
                {
                    SendEmail(doc_id, org_id, comps_id, stat);
                }

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
                    IsDelete = isforward,
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
                        IsDelete = isforward,
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
                if (action == "return" || action == "returnPrev")
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
                var rfpapp_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();
                var rfpwfa = _DataContext.ITP_T_WorkflowActivities.Where(x => x.AppDocTypeId == rfpapp_docType.DCT_Id && x.Document_Id == rfpid && x.AppId == 1032).Select(x => x.WFA_Id).FirstOrDefault();

                var updateRFPWFA = _DataContext.ITP_T_WorkflowActivities
                    .Where(e => e.Document_Id == rfpid && e.AppId == 1032 && e.AppDocTypeId == rfpapp_docType.DCT_Id && e.WFA_Id == rfpwfa);

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

                if (action == "returnPrev")
                {
                    status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Pending at Finance").Select(x => x.STS_Id).FirstOrDefault();
                    var fapWF = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).Select(x => x.FAPWF_Id).FirstOrDefault();
                    var fapWFD = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == fapWF && x.Sequence == 1).FirstOrDefault();

                    insertWA(Convert.ToInt32(fapWFD.WF_Id), Convert.ToInt32(fapWFD.WFD_Id), Convert.ToInt32(fapWFD.OrgRole_Id), id, compID, status, rfpid);
                }
                else
                {
                    SendEmailWithCC(id, userID, compID, status, prepID, cc, remarks);
                }

            }
            catch (Exception)
            {
                throw;
            }
        }

        [WebMethod]
        public static bool AJAXForwardDocument(string forwardWF, string aforwardRemarks, int chargedcomp, int chargeddept)
        {
            TravelExpenseReview tra = new TravelExpenseReview();

            return tra.ForwardDocument(forwardWF, aforwardRemarks, chargedcomp, chargeddept);
        }

        public bool ForwardDocument(string forwardWF, string aforwardRemarks, int chargedcomp, int chargeddept)
        {
            try
            {
                int docID = Convert.ToInt32(Session["TravelExp_Id"]);

                var updTraMain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docID);

                foreach (var item in updTraMain)
                {
                    item.ChargedToComp = Convert.ToInt32(chargedcomp);
                    item.ChargedToDept = Convert.ToInt32(chargeddept);
                    item.Remarks = aforwardRemarks;
                }
                _DataContext.SubmitChanges();

                int reim_docID = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == docID && x.IsExpenseReim == true).Where(x => x.isTravel == true).Select(x => x.ID).FirstOrDefault();

                var updRfpMain = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);
                
                foreach (var item in updRfpMain)
                {
                    item.ChargedTo_CompanyId = Convert.ToInt32(chargedcomp);
                    item.ChargedTo_DeptId = Convert.ToInt32(chargeddept);
                    item.Remarks = aforwardRemarks;
                }
                _DataContext.SubmitChanges();

                var doctype_id = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault();
                var pmid = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == docID && x.IsExpenseReim == true).Where(x => x.isTravel == true).Select(x => x.PayMethod).FirstOrDefault();
                var reimPayMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == pmid).Select(x => x.PMethod_name).FirstOrDefault();
                string userID = Convert.ToString(Session["userID"]);
                int preparerID = Convert.ToInt32(Session["prep"]);
                var cc = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(Session["empid"])).Select(x => x.Email).FirstOrDefault();
                int usercompanyID = Convert.ToInt32(Session["userCompanyID"]);
                int companyID = int.Parse(Session["comp"].ToString());
                
                var travelmain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docID).FirstOrDefault();

                var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == Convert.ToInt32(forwardWF)).Where(x => x.Sequence == 1).FirstOrDefault();

                var wfID = Convert.ToInt32(Session["wf"]);
                var wfaID = Convert.ToInt32(Session["wfa"]);

                var org_id = fin_wfDetail_data.OrgRole_Id;

                var date2day = DateTime.Now;
                //DELEGATE CHECK
                foreach (var del in _DataContext.ITP_S_TaskDelegations.Where(x => x.OrgRole_ID_Orig == fin_wfDetail_data.OrgRole_Id).Where(x => x.DateFrom <= date2day).Where(x => x.DateTo >= date2day).Where(x => x.isActive == true))
                {
                    if (del != null)
                    {
                        org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                    }
                }

                var fstatus = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Forwarded").Select(x => x.STS_Id).FirstOrDefault();

                updateWA(docID, wfID, wfaID, 7, "", aforwardRemarks, userID, DateTime.Now, reim_docID);
                insertWA(Convert.ToInt32(fin_wfDetail_data.WF_Id), Convert.ToInt32(fin_wfDetail_data.WFD_Id), Convert.ToInt32(org_id), Convert.ToInt32(travelmain.ID), Convert.ToInt32(travelmain.Company_Id), Convert.ToInt32(fstatus), reim_docID, true);

                return true;
            }
            catch (Exception ex)
            {
                return false;
                throw ex;
            }
        }

        [WebMethod]
        public static bool AJAXApproveDocument(string remarks, int chargedcomp, int chargeddept, string arNo)
        {
            TravelExpenseReview rev = new TravelExpenseReview();
            rev.ApproveDocument(remarks, chargedcomp, chargeddept, arNo);

            return true;
        }

        public void ApproveDocument(string remarks, int chargedcomp, int chargeddept, string arNo)
        {
            try
            {
                int docID = Convert.ToInt32(Session["TravelExp_Id"]);

                var updTraMain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == docID);

                foreach (var item in updTraMain)
                {
                    item.ChargedToComp = Convert.ToInt32(chargedcomp);
                    item.ChargedToDept = Convert.ToInt32(chargeddept);
                    item.Remarks = remarks;
                    item.ARRefNo = arNo;
                }
                _DataContext.SubmitChanges();

                int reim_docID = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == docID && x.IsExpenseReim == true).Where(x => x.isTravel == true).Select(x => x.ID).FirstOrDefault();

                var updRfpMain = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);

                foreach (var item in updRfpMain)
                {
                    item.ChargedTo_CompanyId = Convert.ToInt32(chargedcomp);
                    item.ChargedTo_DeptId = Convert.ToInt32(chargeddept);
                    item.Remarks = remarks;
                }
                _DataContext.SubmitChanges();

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
                    var completeStat = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Completed").Select(x => x.STS_Id).FirstOrDefault();
                    if (Convert.ToString(Session["doc_stat2"]) == "Pending at Cashier")
                    {
                        if (Convert.ToDecimal(Session["totalCA"]) > Convert.ToDecimal(Session["totalEXP"]))
                        {
                            var FAPwflow = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID).Select(x => x.FAPWF_Id).FirstOrDefault();
                            var FAPwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == FAPwflow && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                            var FAPorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == FAPwflow && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault() ?? 0;
                            var FAPstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Finance").Select(s => s.STS_Id).FirstOrDefault();

                            insertWA((int)FAPwflow, FAPwfd, (int)FAPorID, docID, companyID, FAPstatus, reim_docID);
                        }
                        else
                        {
                            var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID);
                            foreach (ACCEDE_T_TravelExpenseMain t in travel)
                            {
                                t.Status = completeStat;
                            }
                            _DataContext.SubmitChanges();

                            var updateReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);
                            foreach (ACCEDE_T_RFPMain r in updateReim)
                            {
                                r.Status = completeStat;
                            }
                            _DataContext.SubmitChanges();

                            SendEmailComplete(docID, completeStat, Convert.ToInt32(Session["prep"]), remarks, Convert.ToInt32(Session["userID"]));
                            //SendEmailWithCC(docID, Convert.ToString(userID), companyID, completeStat, Convert.ToInt32(Session["prep"]), string.Empty, remarks);
                        }
                    }
                    else if (Convert.ToString(Session["doc_stat2"]) == "Pending at P2P")
                    {
                        if (Convert.ToDecimal(Session["totalCA"]) < Convert.ToDecimal(Session["totalEXP"]) && reimPayMethod == "Check")
                        {
                            var cashierwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                            var cashierwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                            var cashierorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                            var cashstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Cashier" || s.STS_Name == "Pending at Cashier").Select(s => s.STS_Id).FirstOrDefault();

                            insertWA(cashierwf, cashierwfd, (int)cashierorID, docID, companyID, cashstatus, reim_docID);
                            SendEmailFromCashP2P(docID, cashstatus, Convert.ToInt32(Session["prep"]), Convert.ToInt32(Session["userID"]));
                        }
                        else
                        {
                            var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID);
                            foreach (ACCEDE_T_TravelExpenseMain t in travel)
                            {
                                t.Status = completeStat;
                            }
                            _DataContext.SubmitChanges();

                            var updateReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == reim_docID);
                            foreach (ACCEDE_T_RFPMain r in updateReim)
                            {
                                r.Status = completeStat;
                            }
                            _DataContext.SubmitChanges();

                            SendEmailComplete(docID, completeStat, Convert.ToInt32(Session["prep"]), remarks, Convert.ToInt32(Session["userID"]));
                        }
                    }
                    else
                    {
                        var cashWF = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                        var countCashWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == cashWF && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id);

                        var hasRetStatus2 = _DataContext.ITP_T_WorkflowActivities.Any(w => w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id && w.Status == 3);

                        if ((Convert.ToDecimal(Session["totalCA"]) > Convert.ToDecimal(Session["totalEXP"])) && (countCashWF <= 0 && !hasRetStatus2 ))
                        {
                            var cashierwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                            var cashierwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                            var cashierorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                            var cashstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Cashier" || s.STS_Name == "Pending at Cashier").Select(s => s.STS_Id).FirstOrDefault();

                            insertWA(cashierwf, cashierwfd, (int)cashierorID, docID, companyID, cashstatus, reim_docID);
                            SendEmailComplete(docID, completeStat, Convert.ToInt32(Session["prep"]), remarks, Convert.ToInt32(Session["userID"]));
                        }
                        else
                        {
                            var fapwf = _DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == docID).Select(x => x.FAPWF_Id).FirstOrDefault() ?? 0;
                            var fapwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == fapwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                            var orID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == fapwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault() ?? 0;

                            var countFAPWF = _DataContext.ITP_T_WorkflowActivities.Count(w => w.WF_Id == fapwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id);

                            var hasRetStatus = _DataContext.ITP_T_WorkflowActivities.Any(w => w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id && w.Status == 3);

                            if (countFAPWF > 0 && (!hasRetStatus || Convert.ToString(Session["doc_stat2"]) == "Forwarded" || Convert.ToString(Session["doc_stat2"]) == "Pending at Audit" || Convert.ToString(Session["doc_stat2"]) == "Pending at Finance"))
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

                                    var audRetStat = _DataContext.ITP_S_Status.Where(w => w.STS_Description == "Returned by Audit").Select(w => w.STS_Id).FirstOrDefault();
                                    var hasReturnStatus = _DataContext.ITP_T_WorkflowActivities.Any(w => w.WF_Id == audwf && w.AppId == 1032 && w.Document_Id == docID && w.AppDocTypeId == doctype_id && w.Status == audRetStat);

                                    if (countAUDWF > 0 && (!hasReturnStatus || Convert.ToString(Session["doc_stat2"]) == "Pending at Audit"))
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
                                                SendEmailFromCashP2P(docID, p2pstatus, Convert.ToInt32(Session["prep"]), Convert.ToInt32(Session["userID"]));
                                            }
                                            else
                                            {
                                                var cashierwf = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE CASHIER" && w.App_Id == 1032 && w.Company_Id == companyID).Select(x => x.WF_Id).FirstOrDefault();
                                                var cashierwfd = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                                                var cashierorID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == cashierwf && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                                                var cashstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Cashier" || s.STS_Name == "Pending at Cashier").Select(s => s.STS_Id).FirstOrDefault();

                                                insertWA(cashierwf, cashierwfd, (int)cashierorID, docID, companyID, cashstatus, reim_docID);
                                                SendEmailFromCashP2P(docID, cashstatus, Convert.ToInt32(Session["prep"]), Convert.ToInt32(Session["userID"]));
                                            }
                                        }
                                    }
                                    else
                                    {
                                        Debug.WriteLine("No AUDWF");
                                        var audstatus = _DataContext.ITP_S_Status.Where(s => s.STS_Description == "Pending at Audit" || s.STS_Name == "Pending at Audit").Select(s => s.STS_Id).FirstOrDefault();
                                        insertWA(Convert.ToInt32(audwf), Convert.ToInt32(audwfd), Convert.ToInt32(audorID), docID, companyID, audstatus, reim_docID);
                                        
                                        SendEmailFromAudit(docID, audstatus, Convert.ToInt32(Session["prep"]), string.Empty, Convert.ToInt32(Session["userID"]));
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
            TraDocuGrid.DataSource = dsDoc.Tables[0];
            TraDocuGrid.DataBind();
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
            }

            // Bind the tables to the grids
            ASPxGridView22.DataSource = ds.Tables[0];
            ASPxGridView22.DataBind();

            TraDocuGrid.DataSource = SqlDocs2;
            TraDocuGrid.DataBind();
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
        }

        protected void ASPxGridView22_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "ReimTranspo_Amount1" || e.Column.FieldName == "ReimTranspo_Amount2" || e.Column.FieldName == "ReimTranspo_Amount3" || e.Column.FieldName == "FixedAllow_Amount" || e.Column.FieldName == "MiscTravel_Amount" || e.Column.FieldName == "Entertainment_Amount" || e.Column.FieldName == "BusMeals_Amount" || e.Column.FieldName == "OtherBus_Amount")
            {
                if (Convert.ToString(e.Value) == "0" || Convert.ToString(e.Value) == "0.00")
                    e.DisplayText = string.Empty;
            }
        }

        protected void ForwardSequenceGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var wf_id = e.Parameters.ToString();

            SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = wf_id;
            SqlWFSequenceForward.DataBind();

            ForwardSequenceGrid.DataSourceID = null;
            ForwardSequenceGrid.DataSource = SqlWFSequenceForward;
            ForwardSequenceGrid.DataBind();
        }

        protected void locBranch_Callback(object sender, CallbackEventArgsBase e)
        {
            ASPxComboBox combo = sender as ASPxComboBox;

            if (combo != null)
            {
                // Example: Check if the selected value is 0
                if (combo.Value != null && combo.Value.ToString() == "0")
                {
                    combo.Value = null; // Set to null if value is 0
                }
            }
        }

        protected void locBranch_DataBound(object sender, EventArgs e)
        {
            ASPxComboBox combo = sender as ASPxComboBox;

            if (combo != null)
            {
                // Example: Check if the selected value is 0
                if (combo.Value != null && combo.Value.ToString() == "0")
                {
                    combo.Value = null; // Set to null if value is 0
                }
            }
        }

        protected void DocumentGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
            var userId = Convert.ToString(Session["prep"]);
            var statid = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == travelExpId).Select(x => x.Status).FirstOrDefault();
            var status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == statid).Select(x => x.STS_Description).FirstOrDefault();

            var totalca = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId && x.isTravel == true)
                .Sum(x => (decimal?)x.Amount) ?? 0;

            var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                .Where(x => x.TravelExpenseMain_ID == travelExpId)
                .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

            if (totalca > totalexp && status == "Pending at Cashier")
            {
                if (e.VisibleIndex >= 0)
                {
                    if (e.ButtonID == "btnSupEdit" || e.ButtonID == "btnSupDelete")
                        e.Visible = DefaultBoolean.True;
                }
            }
            else
            {
                if (e.VisibleIndex >= 0)
                {
                    if (e.ButtonID == "btnSupEdit" || e.ButtonID == "btnSupDelete")
                        e.Visible = DefaultBoolean.False;
                }
            }
        }
    }
}