using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportSaves : System.Web.UI.Page
    {
        // CREATE objects of DATABASE-ITPORTAL, CLASS-WebClear.cs 
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                //name.Text = Session["userFullName"].ToString().ToUpper();
                //company.Text = context.CompanyMasters
                //    .Where(x => x.WASSId == Convert.ToInt32(Session["userCompanyID"].ToString()))
                //    .Select(x => x.CompanyDesc)
                //    .FirstOrDefault();
                rfpPayee.Text = Session["userFullName"].ToString().ToUpper();

                //dateFiled.Date = DateTime.Now;
                //dateFiled.DisplayFormatString = "MMMM dd, yyyy";
                //dateAdded.Date = DateTime.Now;
                //dateAdded.DisplayFormatString = "MMMM dd, yyyy";

                vatTB.Value = context.ACCEDE_S_Computations
                    .Where(x => x.Type == "VAT")
                    .Select(x => x.Value1)
                    .FirstOrDefault();
                vatTB.JSProperties["cpVAT"] = vatTB.Value;
                ewtTB.Value = context.ACCEDE_S_Computations
                    .Where(x => x.Type == "EWT")
                    .Select(x => x.Value2)
                    .FirstOrDefault();
                ewtTB.JSProperties["cpEWT"] = ewtTB.Value;
            }
            else
                Response.Redirect("~/Logon.aspx");
        }


        public void Send_Email()
        {
            ///////---START EMAIL PROCESS-----////////
            //var user_userID = context.ITP_S_SecurityUserOrgRoles
            //    .Where(um => um.OrgRoleId == orID)
            //    .Select(um => um.UserId)
            //    .FirstOrDefault();
            //var user_email = context.ITP_S_UserMasters
            //.Where(x => x.EmpCode == user_userID)
            //    .FirstOrDefault();
            //var comp_name = context.CompanyMasters
            //    .Where(x => x.WASSId == compID)
            //    .FirstOrDefault();

            ////Start--   Get Text info
            //var queryText = from texts in context.ITP_S_Texts
            //                where texts.Type == "Email" && texts.Name == "Pending"
            //                select texts;

            //var emailMessage = "";
            //var emailSubMessage = "";
            //var emailColor = "";

            //foreach (var text in queryText)
            //{
            //    emailMessage = text.Text1.ToString();
            //    emailSubMessage = text.Text2.ToString();
            //    emailColor = text.Color.ToString();
            //}
            ////End--     Get Text info

            //var requestor_fullname = context.ITP_S_UserMasters
            //    .Where(um => um.EmpCode == Convert.ToString(prepID))
            //    .Select(um => um.FullName)
            //    .FirstOrDefault();
            //var requestor_email = context.ITP_S_UserMasters
            //    .Where(um => um.EmpCode == Convert.ToString(prepID))
            //    .Select(um => um.Email)
            //    .FirstOrDefault();
            //string appName = "EC Clear (Employee Clearance Certificate)";
            //string recipientName = user_email.FullName;
            //string senderName = requestor_fullname;
            //string emailSender = requestor_email;
            //string senderRemarks = "";
            //string emailSite = "http://localhost:61185/ECClearApproval.aspx";
            //string sendEmailTo = user_email.Email;
            //string emailSubject = "EC Clear - " + newID + ": Pending for Approval";

            //ANFLO anflo = new ANFLO();

            ////Body Details Sample
            //string emailDetails = "";

            //var queryWC = from wfact in context.CLEAR_T_Headers
            //              where wfact.ID == newID
            //              select wfact;

            //emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            //emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            //emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            //emailDetails += "<tr><td>Document No.</td><td><strong>" + newID + "</strong></td></tr>";
            //emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            //emailDetails += "<tr><td>Status</td><td><strong>" + "Pending" + "</strong></td></tr>";
            //emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Clearance Certificate" + "</strong></td></tr>";
            //emailDetails += "</table>";
            //emailDetails += "<br>";

            //emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            //emailDetails += "<tr><th colspan='6'> Clearance Details </th> </tr>";
            //emailDetails += "<tr><th>Document No.</th><th>Employee Name</th><th>Designation</th><th>Company</th><th>Nature of Separation</th><th>Date of Separation</th></tr>";

            //foreach (var item in queryWC)
            //{
            //    string sepDesc = context.CLEAR_S_SeparationNatures
            //        .Where(wc => wc.ID == Convert.ToInt32(item.NatSep_ID))
            //        .Select(um => um.Separation_Nature)
            //        .FirstOrDefault();
            //    string documentID = newID.ToString();
            //    emailDetails +=
            //                "<tr>" +
            //                "<td style='text-align: center;'>" + documentID + "</td>" +
            //                "<td style='text-align: center;'>" + item.Full_Name + "</td>" +
            //                "<td style='text-align: center;'>" + item.Desig_Desc + "</td>" +
            //                "<td style='text-align: center;'>" + item.Company_Name + "</td>" +
            //                "<td style='text-align: center;'>" + sepDesc + "</td>" +
            //                "<td style='text-align: center;'>" + item.Sep_Date.Value.ToLongDateString() + "</td>" +
            //                "</tr>";
            //}
            //emailDetails += "</table>";

            ////End of Body Details Sample
            //string emailTemplate = anflo
            //    .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
            //    emailDetails, senderRemarks, emailSite, emailColor);

            //if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo, email))
            //{
            //};
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
                reimBtn.Visible = true;
                DocuGrid0.Visible = true;
                errImg.Visible = false;
                expenseType.Text = "Reimbursement";
                //ASPxFormLayout1.FindItemOrGroupByName("reimGroup").Visible = true;
            }
            else
            {
                //ASPxFormLayout1.FindItemOrGroupByName("reimGroup").Visible = false;
                reimBtn.Visible = false;
                DocuGrid0.Visible = false;
                errImg.Visible = true;
                expenseType.Text = "Liquidation";
            }
        }

        protected void amountCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
        {
            var checkMinAmount = context.ACCEDE_M_CheckMinAmounts
                .Count(x => x.CompanyId == Convert.ToInt32(company.Value) && Convert.ToDecimal(rfpAmount.Value) >= x.MaxAmount);

            if (checkMinAmount > 0)
                e.Result = "3";
        }

        protected void submitCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1008, Convert.ToInt32(company.Value), 1032);
                var docNo = generateDocNo.GetLatest_DocNum(1008, Convert.ToInt32(company.Value), 1032);

                // CHECK FIELDS BEFORE PERFORMING UPDATE QUERY
                DateTime dateCreated = dateFiled.Date != null ? dateFiled.Date : DateTime.MinValue;
                int? expenseTypeId = expenseType.Value != null && int.TryParse(expenseType.Value.ToString(), out int sep) ? sep : (int?)null;
                int userId = Convert.ToInt32(Session["userID"]);
                string expensePurpose = purpose.Text != null ? purpose.Text : "";
                string companyId = (string)company.Value != null ? (string)company.Value : "";

                // CHECK STATUS
                int ID = int.Parse(Session["cID"].ToString());
                var query = from wch in context.ACCEDE_T_ExpenseMains
                            where wch.ID == ID
                            select wch.Status;
                int? status = query.FirstOrDefault();

                // GET WORKFLOW ID
                var wf = from wfh in context.ITP_S_WorkflowHeaders
                         where wfh.App_Id == 1032 && wfh.Company_Id == Convert.ToInt32(companyId)
                         select wfh.WF_Id;
                int wfID = wf.FirstOrDefault();

                // GET WORKFLOW DETAILS ID
                var wfDetails = from wfd in context.ITP_S_WorkflowDetails
                                where wfd.WF_Id == wfID && wfd.Sequence == 1
                                select wfd.WFD_Id;
                int wfdID = wfDetails.FirstOrDefault();

                // GET ORG ROLE ID
                var orgRole = from or in context.ITP_S_WorkflowDetails
                              where or.WF_Id == wfID && or.Sequence == 1
                              select or.OrgRole_Id;
                int orID = (int)orgRole.FirstOrDefault();

                var updateER = context.ACCEDE_T_ExpenseMains.Where(a => a.ID == ID);

                foreach (ACCEDE_T_ExpenseMain ex in updateER)
                {
                    ex.ExpenseType_ID = expenseTypeId;
                    ex.UserId = userId.ToString();
                    ex.Purpose = expensePurpose;
                    ex.CompanyId = Convert.ToInt32(companyId);
                    ex.DateCreated = dateCreated;
                    ex.Status = 1;
                }
                context.SubmitChanges();

                // UPDATE ACCEDE_T_ExpenseDetail
                var updateExpDetails = context.ACCEDE_T_ExpenseDetails
                    .Where(ex => ex.Preparer_ID == Session["userID"].ToString() && ex.IsUploaded == false);

                foreach (ACCEDE_T_ExpenseDetail ex in updateExpDetails)
                {
                    ex.IsUploaded = true;
                    ex.ExpenseMain_ID = ID;
                }
                context.SubmitChanges();

                // UPDATE ACCEDE_T_RFPMain
                var updateRFPMain = context.ACCEDE_T_RFPMains
                    .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && (ex.IsExpenseCA == true || ex.IsExpenseReim == true) && (Convert.ToString(ex.Exp_ID) == null || Convert.ToString(ex.Exp_ID) == string.Empty));

                foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                {
                    ex.Exp_ID = ID;
                }
                context.SubmitChanges();

                //INSERT TO ITP_T_WorkflowActivity
                DateTime currentDate = DateTime.Now;

                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                {
                    Status = 1,
                    DateAssigned = currentDate,
                    DateAction = null,
                    WF_Id = wfID,
                    WFD_Id = wfdID,
                    OrgRole_Id = orID,
                    Document_Id = ID,
                    AppId = 1032,
                    CompanyId = Convert.ToInt32(companyId),
                    AppDocTypeId = context.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                    IsActive = true,
                };
                context.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }
            ASPxWebControl.RedirectOnCallback("~/AccedeExpenseReportView.aspx");
        }

        protected void rfpCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(company.Value), 1032);
                var docNo = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(company.Value), 1032);

                // INSERT TO ACCEDE_T_RFPMain
                ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain()
                {
                    Company_ID = Convert.ToInt32(company.Value),
                    Department_ID = Convert.ToInt32(rfpDept.Value),
                    PayMethod = Convert.ToInt32(rfpPaymethod.Value),
                    TranType = Convert.ToInt32(rfpTrantype.Value),
                    isTravel = Convert.ToBoolean(rfpTravel.Value),
                    SAPCostCenter = Convert.ToString(rfpcostCenter.Value),
                    IO_Num = Convert.ToString(rfpIO.Value),
                    Payee = rfpPayee.Text,
                    LastDayTransact = Convert.ToDateTime(rfpLastday.Value),
                    Amount = Convert.ToDecimal(rfpAmount.Value),
                    Purpose = Convert.ToString(rfpPurpose.Value),
                    User_ID = Convert.ToString(Session["userID"]),
                    Status = 1,
                    DateCreated = Convert.ToDateTime(DateTime.Now),
                    RFP_DocNum = docNo,
                    IsExpenseReim = true

                };
                context.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                context.SubmitChanges();

                DocuGrid0.DataBind();
                rfpPopup.ShowOnPageLoad = false;
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void DocuGrid1_DataBound(object sender, EventArgs e)
        {
            Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
        }

        protected void DocuGrid1_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            // Get the key value of the row being deleted
            var keyValue = e.Values["RFPMain_ID"];
            if (keyValue != null)
            {
                var updateRFP = context.ACCEDE_T_RFPMains
                     .Where(x => x.ID == Convert.ToInt32(keyValue));

                foreach (ACCEDE_T_RFPMain ex in updateRFP)
                {
                    ex.IsExpenseCA = false;
                }
                context.SubmitChanges();
            }
            else
            {
                Debug.WriteLine("Column value not found in e.Values[\"RFPMain_ID\"]");
            }

            Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            // Prevent the automatic delete operation
            //e.Cancel = true;
        }

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            e.NewValues["IsUploaded"] = false;
            e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);
        }

        protected void DocuGrid_DataBound(object sender, EventArgs e)
        {
            Session["expenseTotal"] = DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            expenseTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["expenseTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["expenseTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(Session["caTotal"]));

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
        }

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            Session["expenseTotal"] = DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            expenseTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["expenseTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["expenseTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
        }

        DataSet dsDoc = null;

        private int GetNewId()
        {
            dsDoc = (DataSet)Session["DataSetDoc"];
            DataTable table = dsDoc.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["ID"]);
            }
            return max + 1;
        }
        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            // Create a new data table if it doesn't exist in the data set
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

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["cID"].ToString());
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["cID"].ToString();
                    docs.Company_ID = Convert.ToInt32(Session["comp"].ToString());
                    docs.DateUploaded = DateTime.Now;
                };
                context.ITP_T_FileAttachments.InsertOnSubmit(docs);
                context.SubmitChanges();
            }
        }

        protected void popupSubmitBtn_Click(object sender, EventArgs e)
        {
            try
            {
                var accountChargeds = context.ACCEDE_S_AccountChargeds
                    .Where(a => a.AccCharged_ID == Convert.ToInt32(accountCharged.Value))
                    .Select(a => a.GLAccount).FirstOrDefault();
                var costCenters = context.ACCEDE_S_CostCenters
                    .Where(a => a.CostCenter_ID == Convert.ToInt32(costCenter.Value))
                    .Select(a => a.CostCenter).FirstOrDefault();

                // INSERT TO ACCEDE_T_ExpenseDetails
                ACCEDE_T_ExpenseDetail exp = new ACCEDE_T_ExpenseDetail()
                {
                    DateAdded = dateAdded.Date,
                    Supplier = supplier.Text,
                    TIN = tin.Text,
                    InvoiceOR = invoiceOR.Text,
                    Particulars = Convert.ToInt32(particulars.Value),
                    AccountToCharged = accountChargeds.ToString(),
                    CostCenterIOWBS = costCenters.ToString(),
                    GrossAmount = Convert.ToDecimal(grossAmount.Value),
                    VAT = Convert.ToDecimal(vat.Value),
                    EWT = Convert.ToDecimal(ewt.Value),
                    NetAmount = Convert.ToDecimal(netAmount.Value),
                    IsUploaded = false,
                    Preparer_ID = Session["userID"].ToString()

                };
                context.ACCEDE_T_ExpenseDetails.InsertOnSubmit(exp);
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }
            expensePopup.ShowOnPageLoad = false;
            DocuGrid.DataBind();
        }

        protected void popupSubmitBtn0_Click(object sender, EventArgs e)
        {
            for (var i = 0; i <= capopGrid.GetSelectedFieldValues("ID").Count() - 1; i++)
            {
                var data = capopGrid.GetSelectedFieldValues("ID");

                // INSERT TO ACCEDE_T_ExpenseCA
                ACCEDE_T_ExpenseCA ca = new ACCEDE_T_ExpenseCA()
                {
                    RFPMain_ID = Convert.ToInt32(data[i]),
                    User_ID = Convert.ToInt32(Session["userID"]),
                    IsUploaded = false
                };
                context.ACCEDE_T_ExpenseCAs.InsertOnSubmit(ca);
                context.SubmitChanges();

                // UPDATE TO ACCEDE_T_RFPMain
                var updateRFPMain = context.ACCEDE_T_RFPMains
                    .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && ex.ID == Convert.ToInt32(data[i]));

                foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                {
                    ex.IsExpenseCA = true;
                }
                context.SubmitChanges();
            }

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));

            //Response.Redirect("~/AccedeExpenseReportAdd.aspx");
            caPopup.ShowOnPageLoad = false;
            DocuGrid1.DataBind();
        }

        protected void capopGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            capopGrid.DataBind();
        }

        protected void saveBtn_Click(object sender, EventArgs e)
        {
            try
            {
                // CHECK FIELDS BEFORE PERFORMING UPDATE QUERY
                DateTime dateCreated = dateFiled.Date != null ? dateFiled.Date : DateTime.MinValue;
                int? expenseTypeId = expenseType.Value != null && int.TryParse(expenseType.Value.ToString(), out int sep) ? sep : (int?)null;
                int userId = Convert.ToInt32(Session["userID"]);
                string expensePurpose = purpose.Text != null ? purpose.Text : "";
                string companyId = (string)company.Value != null ? (string)company.Value : "";

                // CHECK STATUS
                int ID = int.Parse(Session["cID"].ToString());
                var query = from wch in context.ACCEDE_T_ExpenseMains
                            where wch.ID == ID
                            select wch.Status;
                int? status = query.FirstOrDefault();

                var updateER = context.ACCEDE_T_ExpenseMains.Where(a => a.ID == ID);

                foreach (ACCEDE_T_ExpenseMain ex in updateER)
                {
                    ex.ExpenseType_ID = expenseTypeId;
                    ex.UserId = userId.ToString();
                    ex.Purpose = expensePurpose;
                    ex.CompanyId = Convert.ToInt32(companyId);
                    ex.DateCreated = dateCreated;
                    ex.Status = status;
                }
                context.SubmitChanges();

                // UPDATE ACCEDE_T_ExpenseDetail
                var updateExpDetails = context.ACCEDE_T_ExpenseDetails
                    .Where(ex => ex.Preparer_ID == Session["userID"].ToString() && ex.IsUploaded == false);

                foreach (ACCEDE_T_ExpenseDetail ex in updateExpDetails)
                {
                    ex.IsUploaded = true;
                    ex.ExpenseMain_ID = ID;
                }
                context.SubmitChanges();

                // UPDATE ACCEDE_T_RFPMain
                var updateRFPMain = context.ACCEDE_T_RFPMains
                    .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && (ex.IsExpenseCA == true || ex.IsExpenseReim == true) && (Convert.ToString(ex.Exp_ID) == null || Convert.ToString(ex.Exp_ID) == string.Empty));

                foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                {
                    ex.Exp_ID = ID;
                }
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }
            Response.Redirect("~/AccedeExpenseReportView.aspx");
        }

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var updateRFP = context.ACCEDE_T_RFPMains
                     .Where(x => (x.IsExpenseCA == true || x.IsExpenseReim == true) && (x.Exp_ID == null || Convert.ToString(x.Exp_ID) == string.Empty));

            foreach (ACCEDE_T_RFPMain ex in updateRFP)
            {
                ex.IsExpenseCA = false;
            }
            context.SubmitChanges();

            Response.Redirect("~/AccedeExpenseReportView.aspx");
        }

        protected void rfppopupSubmitBtn_Click(object sender, EventArgs e)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(company.Value), 1032);
                var docNo = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(company.Value), 1032);

                // INSERT TO ACCEDE_T_RFPMain
                ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain()
                {
                    Company_ID = Convert.ToInt32(company.Value),
                    Department_ID = Convert.ToInt32(rfpDept.Value),
                    PayMethod = Convert.ToInt32(rfpPaymethod.Value),
                    TranType = Convert.ToInt32(rfpTrantype.Value),
                    isTravel = Convert.ToBoolean(rfpTravel.Value),
                    SAPCostCenter = Convert.ToString(rfpcostCenter.Value),
                    IO_Num = Convert.ToString(rfpIO.Value),
                    Payee = rfpPayee.Text,
                    LastDayTransact = Convert.ToDateTime(rfpLastday.Value),
                    Amount = Convert.ToDecimal(rfpAmount.Value),
                    Purpose = Convert.ToString(rfpPurpose.Value),
                    User_ID = Convert.ToString(Session["userID"]),
                    Status = 1,
                    DateCreated = Convert.ToDateTime(DateTime.Now),
                    RFP_DocNum = docNo,
                    IsExpenseReim = true
                };
                context.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }

            rfpPopup.ShowOnPageLoad = false;
            DocuGrid0.DataBind();
        }
    }
}