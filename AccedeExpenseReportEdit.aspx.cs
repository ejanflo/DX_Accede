using DevExpress.CodeParser;
using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Utils.About;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ListView;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using System.Configuration;
using System.Diagnostics;
using System.Security.Cryptography;
using DevExpress.XtraExport.Helpers;
using DevExpress.Data;
using DX_WebTemplate.Setup;
using System.Data;
using System.Data.SqlClient;
using System.ComponentModel.Design;
using DevExpress.DocumentServices.ServiceModel.DataContracts;
using System.Web.Services;
using DevExpress.XtraRichEdit.Model;
using System.Web.DynamicData;

namespace DX_WebTemplate
{
    public partial class Accede_ExpenseReport : System.Web.UI.Page
    {
        // CREATE objects of DATABASE-ITPORTAL
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    name.Text = Session["userFullName"].ToString().ToUpper();
                    company.Text = context.CompanyMasters
                        .Where(x => x.WASSId == Convert.ToInt32(Session["userCompanyID"].ToString()))
                        .Select(x => x.CompanyDesc)
                        .FirstOrDefault();
                    rfpPayee.Text = Session["userFullName"].ToString().ToUpper();

                    dateFiled.Date = DateTime.Now;
                    dateFiled.DisplayFormatString = "MMMM dd, yyyy";
                    dateAdded.Date = DateTime.Now;
                    dateAdded.DisplayFormatString = "MMMM dd, yyyy";

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

                    var mainExp = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                    sqlExpenseCA.SelectParameters["Exp_ID"].DefaultValue = mainExp.ID.ToString();
                    sqlRFPMain.SelectParameters["Exp_ID"].DefaultValue = mainExp.ID.ToString();
                    sqlExpenseDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = mainExp.ID.ToString();
                    sqlExpenseDetails.SelectParameters["Preparer_ID"].DefaultValue = Session["userID"].ToString();
                    SqlExpMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = mainExp.ID.ToString();
                    SqlWF.SelectParameters["UserId"].DefaultValue = Session["userID"].ToString();

                    var pay_released = context.ITP_S_Status.Where(x=>x.STS_Name == "Payment Released").FirstOrDefault();

                    sqlRFPMainCA.SelectParameters["User_ID"].DefaultValue = Session["userID"].ToString();
                    sqlRFPMainCA.SelectParameters["Status"].DefaultValue = pay_released.STS_Id.ToString();

                    Session["DocNo"] = mainExp.DocNo.ToString();
                    Session["ExpMain_ID"] = mainExp.ID;

                    var myLayoutGroup = ExpenseEditForm.FindItemOrGroupByName("EditFormName") as LayoutGroup;

                    if (mainExp != null)
                    {
                        myLayoutGroup.Caption = mainExp.DocNo + " (Edit)";

                    }

                    var due_total = dueTotal.Value != null ? dueTotal.Value.ToString().Replace("₱", "").Replace(",", "").Replace("(", "").Replace(")", "").Trim() : "0";

                    if (Convert.ToDecimal(due_total) > 0)
                    {
                        var due = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        due.Caption = "Net Due to Company";
                    }
                    else if (Convert.ToDecimal(due_total) < 0)
                    {
                        var due = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        due.Caption = "Net Due to Employee";
                    }
                    else
                    {
                        var due = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        due.Caption = "Net Due to Employee/Company";
                    }

                }
                else
                    Response.Redirect("~/Logon.aspx");
            }
            catch (Exception ex)
            {
                Response.Redirect("~/Logon.aspx");
            }
            
        }

        public void InsertAttachment(int newID)
        {
            ////Insert Attachments
            DataSet dsFile = (DataSet)Session["DataSetDoc"];
            DataTable dataTable = dsFile.Tables[0];

            if (dataTable.Rows.Count > 0)
            {
                string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize) OUTPUT INSERTED.ID VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize)";

                using (SqlConnection connection = new SqlConnection(connectionString1))
                using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                {
                    // Define the parameters for the SQL query
                    command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                    command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                    command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                    command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                    command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                    command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                    command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                    command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                    command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);

                    // Open the connection to the database
                    connection.Open();

                    // Loop through the rows in the DataTable and insert them into the database
                    foreach (DataRow row in dataTable.Rows)
                    {
                        command.Parameters["@filename"].Value = row["FileName"];
                        command.Parameters["@file_byte"].Value = row["FileByte"];
                        command.Parameters["@desc"].Value = row["FileDesc"];
                        command.Parameters["@date_upload"].Value = DateTime.Now;
                        command.Parameters["@app_id"].Value = 1032;
                        command.Parameters["@comp_id"].Value = Session["comp"] != null ? Session["userID"].ToString() : "0";
                        command.Parameters["@doc_id"].Value = newID;
                        command.Parameters["@doc_no"].Value = newID.ToString();
                        command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                        command.Parameters["@fileExt"].Value = row["FileExt"];
                        command.Parameters["@filesize"].Value = row["FileSize"];
                    }
                    // Close the connection to the database
                    connection.Close();
                }
            }
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID)
        {
            DateTime currentDate = DateTime.Now;

            var status = context.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Description)
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
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/AccedeExpenseReportApproval.aspx";
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
                    Preparer_ID = Session["userID"].ToString(),
                    ExpenseMain_ID = Convert.ToInt32(Session["ExpenseId"])

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

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            e.NewValues["IsUploaded"] = false;
            e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);
        }

        protected void submitCallback_Callback(object source, CallbackEventArgs e)
        {
            var reimburseCount = DocuGrid0.VisibleRowCount;
            string dueTotalValue = dueTotal.Text.ToString();

            // Remove Peso sign, comma, and parentheses
            string cleanedValue = dueTotalValue.Replace("₱", "").Replace(",", "").Replace("(", "").Replace(")", "").Trim();

            // Parse the cleaned string to a decimal
            decimal dueTotalDecimal = 0;
            
            try
            {
                int wfID = Convert.ToInt32(drpdown_WF.Value);

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

                // CHECK FIELDS BEFORE PERFORMING UPDATE QUERY
                DateTime dateCreated = dateFiled.Date != null ? dateFiled.Date : DateTime.MinValue;
                int? expenseTypeId = expenseType.Value != null && int.TryParse(expenseType.Value.ToString(), out int sep) ? sep : (int?)null;
                int userId = Convert.ToInt32(Session["userID"]);
                string expensePurpose = purpose.Text != null ? purpose.Text : "";
                int companyId = company.Value != null ? Convert.ToInt32(company.Value) : 0;
                int status = 1;
                int wf_id = drpdown_WF.Value != null ? Convert.ToInt32(drpdown_WF.Value) : 0;
                int fapwf_id = drpdwn_FAPWF.Value != null ? Convert.ToInt32(drpdwn_FAPWF.Value) : 0;

                var mainExp = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();

                //Update TO ACCEDE_T_ExpenseMain
                mainExp.ExpenseName = name.Value.ToString();
                mainExp.ExpenseType_ID = expenseTypeId;
                mainExp.UserId = userId.ToString();
                mainExp.Purpose = expensePurpose;
                mainExp.CompanyId = Convert.ToInt32(companyId);
                mainExp.ReportDate = dateCreated;
                mainExp.ExpenseCat = Convert.ToInt32(drpdown_ExpCategory.Value);
                mainExp.Status = status;
                if (wf_id != 0 && fapwf_id != 0)
                {
                    mainExp.WF_Id = wf_id;
                    mainExp.FAPWF_Id = fapwf_id;
                }

                var returned_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();
                var pending_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();

                //INSERT Reimburse to ITP_T_WorkflowActivity
                var reimId = context.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.TranType == 2).FirstOrDefault();

                if(reimId != null)
                {

                    if (returned_audit.STS_Id == mainExp.Status)
                    {
                        if (reimId.isReturnToAudit == true)
                        {
                            reimId.Status = pending_audit.STS_Id;
                        }
                        else
                        {
                            reimId.Status = 1;
                        }
                    }

                    ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                    {
                        Status = 1,
                        DateAssigned = DateTime.Now,
                        DateAction = null,
                        WF_Id = wfID,
                        WFD_Id = wfdID,
                        OrgRole_Id = orID,
                        Document_Id = Convert.ToInt32(reimId.ID),
                        AppId = 1032,
                        CompanyId = Convert.ToInt32(company.Value),
                        AppDocTypeId = context.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                        IsActive = true,
                    };
                    context.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);

                }

                //INSERT EXPENSE TO ITP_T_WorkflowActivity
                DateTime currentDate = DateTime.Now;

                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                {
                    Status = 1,
                    DateAssigned = currentDate,
                    DateAction = null,
                    WF_Id = wfID,
                    WFD_Id = wfdID,
                    OrgRole_Id = orID,
                    Document_Id = Convert.ToInt32(Session["ExpenseId"]),
                    AppId = 1032,
                    CompanyId = Convert.ToInt32(company.Value),
                    AppDocTypeId = context.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                    IsActive = true,
                };
                context.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                context.SubmitChanges();

                //InsertAttachment(Convert.ToInt32(Session["ExpenseId"]));
                SendEmail(Convert.ToInt32(wfa.Document_Id), orID, Convert.ToInt32(company.Value), 1);
            }
            catch (Exception)
            {
                throw;
            }
            ASPxWebControl.RedirectOnCallback("~/AccedeExpenseReportDashboard.aspx");

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
                    ex.Exp_ID = Convert.ToInt32(Session["ExpenseId"]);
                }
                context.SubmitChanges();
            }

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));

            //Response.Redirect("~/AccedeExpenseReportAdd.aspx");
            caPopup.ShowOnPageLoad = false;
            DocuGrid1.DataBind();
        }

        [WebMethod]
        public static bool AddCA_AJAX(List<int> selectedValues)
        {
            try
            {
                Accede_ExpenseReport accede = new Accede_ExpenseReport();
                bool result = accede.AddCA(selectedValues);
                return result;
            }
            catch (Exception ex)
            {
                // Log the error (ex.Message)
                return false;
            }
        }

        public bool AddCA(List<int> selectedIds)
        {
            try
            {
                foreach (var id in selectedIds)
                {
                    // INSERT TO ACCEDE_T_ExpenseCA
                    ACCEDE_T_ExpenseCA ca = new ACCEDE_T_ExpenseCA()
                    {
                        RFPMain_ID = id,
                        User_ID = Convert.ToInt32(Session["userID"]),
                        IsUploaded = false
                    };
                    context.ACCEDE_T_ExpenseCAs.InsertOnSubmit(ca);
                    context.SubmitChanges();

                    // UPDATE TO ACCEDE_T_RFPMain
                    var updateRFPMain = context.ACCEDE_T_RFPMains
                        .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && ex.ID == id);

                    foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                    {
                        ex.IsExpenseCA = true;
                        ex.Exp_ID = Convert.ToInt32(Session["ExpenseId"]);
                    }
                    context.SubmitChanges();
                }

                //caPopup.ShowOnPageLoad = false;
                //DocuGrid1.DataBind();
            }
            catch (Exception ex)
            {
                return false;
            }
            return true;
        }


        protected void DocuGrid1_DataBound(object sender, EventArgs e)
        {
            Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]) != null ? DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString() : "";
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            var CA_total = Session["caTotal"].ToString() != "" ? Session["caTotal"] : "0.00";
            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(CA_total));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(CA_total));
        }

        protected void DocuGrid_DataBound(object sender, EventArgs e)
        {
            var net = DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]) != null ? DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]) : 0;
            Session["expenseTotal"] = net.ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            expenseTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["expenseTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["expenseTotal"])) : string.Empty);

            var CA_total = Session["caTotal"].ToString() != "" ? Session["caTotal"] : "0.00";
            Compute_ExpCA(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(CA_total));
            ShowRmbmtButton(Convert.ToDecimal(Session["expenseTotal"]), Convert.ToDecimal(CA_total));

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
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

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            Session["expenseTotal"] = DocuGrid.GetTotalSummaryValue(DocuGrid.TotalSummary["NetAmount"]).ToString();
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            expenseTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["expenseTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["expenseTotal"])) : string.Empty);

            Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));


        }

        protected void capopGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            capopGrid.DataBind();
        }

        public void Compute_ExpCA(decimal expTotal, decimal caTotal)
        {
            
            CultureInfo cultureInfo = new CultureInfo("en-PH");
            if (expTotal > caTotal)
            {
                dueTotal.Text = "(" + string.Format(cultureInfo, "{0:C2}", (expTotal - caTotal)) + ")";
                ScriptManager.RegisterStartupScript(this, GetType(), "UpdateDueCaption", @"
                    var layoutControl = window['ExpenseEditForm'];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName('due_lbl');
                        if (layoutItem) {

                            layoutItem.SetCaption('Net Due to Employee');

                        }
                    }
                    
                
                ", true);

            }
            else if (caTotal > expTotal)
            {
                dueTotal.Text = string.Format(cultureInfo, "{0:C2}", (caTotal - expTotal));
                ScriptManager.RegisterStartupScript(this, GetType(), "UpdateDueCaption", @"
                    var layoutControl = window['ExpenseEditForm'];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName('due_lbl');
                        if (layoutItem) {

                            layoutItem.SetCaption('Net Due to Company');

                        }
                    }
                    
                
                ", true);
            }
            else
            {
                dueTotal.Text = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "UpdateDueCaption", @"
                    var layoutControl = window['ExpenseEditForm'];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName('due_lbl');
                        if (layoutItem) {

                            layoutItem.SetCaption('Net Due to Employee/Company');

                        }
                    }
                ", true);
            }
                

            var expenseDetailList = context.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));
            decimal totalExpAmnt = 0;

            var RFPCADetailList = context.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.TranType == 1);
            decimal totalCAAmnt = 0;

            foreach (var expense in expenseDetailList ?? Enumerable.Empty<ACCEDE_T_ExpenseDetail>())
            {
                totalExpAmnt += Convert.ToDecimal(expense.GrossAmount);
            }

            foreach (var rfpCA in RFPCADetailList ?? Enumerable.Empty<ACCEDE_T_RFPMain>())
            {
                totalCAAmnt += Convert.ToDecimal(rfpCA.Amount);
            }

            var reimburseDetails = context.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.TranType == 2).FirstOrDefault();
            var returned_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();

            if (reimburseDetails != null)
            {
                var checkMinAmount = context.ACCEDE_M_CheckMinAmounts.Where(x => x.CompanyId == Convert.ToInt32(reimburseDetails.Company_ID)).FirstOrDefault();
                if (totalExpAmnt > totalCAAmnt && totalExpAmnt != 0)
                {
                    if (returned_audit != null)
                    {
                        if(reimburseDetails.Status == returned_audit.STS_Id)
                        {
                            decimal new_amnt = Convert.ToDecimal(expTotal) - Convert.ToDecimal(caTotal);
                            if (reimburseDetails.Amount >= new_amnt)
                            {
                                reimburseDetails.isReturnToAudit = true;
                            }
                        }
                    }
                    reimburseDetails.Amount = Convert.ToDecimal(expTotal) - Convert.ToDecimal(caTotal);
                }
                else
                {
                    context.ACCEDE_T_RFPMains.DeleteOnSubmit(reimburseDetails);
                }
                    

                //reimburseDetails.Amount = Convert.ToDecimal(expTotal);
                //if (checkMinAmount != null)
                //{
                //    if (checkMinAmount.MaxAmount <= Convert.ToDecimal(expTotal))
                //    {
                //        reimburseDetails.PayMethod = 3;
                //    }
                //    else
                //    {
                //        reimburseDetails.PayMethod = 1;
                //    }
                //}
            }
            context.SubmitChanges();

            decimal totalExp = expTotal - caTotal;
            int comp_id = Convert.ToInt32(company.Value);

            var parameter = totalExp.ToString() + "|" + comp_id.ToString();

            CallbackEventArgsBase args = new CallbackEventArgsBase(parameter);
            drpdwn_FAPWF_Callback(drpdwn_FAPWF, args);

            ASPxGridViewCustomCallbackEventArgs argsGrid = new ASPxGridViewCustomCallbackEventArgs(parameter);
            FAPWFGrid_CustomCallback(FAPWFGrid, argsGrid);
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

        protected void rfpCallback_Callback(object source, CallbackEventArgs e)
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
                    IsExpenseReim = true,
                    IsExpenseCA = false,
                    Exp_ID = Convert.ToInt32(Session["ExpenseId"]),
                    WF_Id = Convert.ToInt32(drpdown_WF.Value),
                    FAPWF_Id = Convert.ToInt32(drpdwn_FAPWF.Value)
                };
                context.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                context.SubmitChanges();
            }
            catch (Exception)
            {
                throw;
            }

            rfpPopup.ShowOnPageLoad = false;
        }

        DataSet dsDoc = null;

        protected void ASPxFormLayout1_Init(object sender, EventArgs e)
        {
            //if (!IsPostBack || (Session["DataSetDoc"] == null))
            //{
            //    dsDoc = new DataSet();
            //    DataTable masterTable = new DataTable();
            //    masterTable.Columns.Add("ID", typeof(int));
            //    masterTable.Columns.Add("FileName", typeof(string));
            //    masterTable.Columns.Add("FileByte", typeof(byte[]));
            //    masterTable.Columns.Add("FileExt", typeof(string));
            //    masterTable.Columns.Add("FileSize", typeof(string));
            //    masterTable.Columns.Add("FileDesc", typeof(string));
            //    masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

            //    dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
            //    Session["DataSetDoc"] = dsDoc;
            //}
            //else
            //    dsDoc = (DataSet)Session["DataSetDoc"];
            //DocuGrid2.DataSource = dsDoc.Tables[0];
            //DocuGrid2.DataBind();
        }

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
                    docs.Doc_ID = Convert.ToInt32(Session["ExpenseId"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(company.Value);
                    docs.DateUploaded = DateTime.Now;
                };
                context.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            context.SubmitChanges();
            SqlDocs.DataBind();
            DocuGrid2.DataBind();
        }

        protected void saveBtn_Click(object sender, EventArgs e)
        {
            // CHECK FIELDS BEFORE PERFORMING UPDATE QUERY
            DateTime dateCreated = dateFiled.Date != null ? dateFiled.Date : DateTime.MinValue;
            int? expenseTypeId = expenseType.Value != null && int.TryParse(expenseType.Value.ToString(), out int sep) ? sep : (int?)null;
            int userId = Convert.ToInt32(Session["userID"]);
            string expensePurpose = purpose.Text != null ? purpose.Text : "";
            int companyId = company.Value != null ? Convert.ToInt32(company.Value) : 0;
            int status = 13;
            int wf_id = drpdown_WF.Value != null ? Convert.ToInt32(drpdown_WF.Value) : 0;
            int fapwf_id = drpdwn_FAPWF.Value != null ? Convert.ToInt32(drpdwn_FAPWF.Value) : 0;

            var mainExp = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();

            //Update TO ACCEDE_T_ExpenseMain
            mainExp.ExpenseName = name.Value.ToString();
            mainExp.ExpenseType_ID = expenseTypeId;
            mainExp.UserId = userId.ToString();
            mainExp.Purpose = expensePurpose;
            mainExp.CompanyId = Convert.ToInt32(companyId);
            mainExp.ReportDate = dateCreated;
            mainExp.ExpenseCat = Convert.ToInt32(drpdown_ExpCategory.Value);
            mainExp.Status = status;
            if(wf_id != 0 && fapwf_id != 0)
            {
                mainExp.WF_Id = wf_id;
                mainExp.FAPWF_Id = fapwf_id;
            }

            context.SubmitChanges();

            //InsertAttachment(mainExp.ID);
            Response.Redirect("~/AccedeExpenseReportDashboard.aspx");

        }

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            //var updateRFP = context.ACCEDE_T_RFPMains
            //         .Where(x => (x.IsExpenseCA == true || x.IsExpenseReim == true) && (x.Exp_ID == null || Convert.ToString(x.Exp_ID) == string.Empty));

            //foreach (ACCEDE_T_RFPMain ex in updateRFP)
            //{
            //    ex.IsExpenseCA = false;
            //}
            //context.SubmitChanges();

            //Response.Redirect("~/AccedeExpenseReportView.aspx");
        }

        protected void rfppopupSubmitBtn_Click(object sender, EventArgs e)
        {
            try
            {
                var countReimburse = context.ACCEDE_T_RFPMains.Where(x=>x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x=>x.TranType == 2).Count();
                if(countReimburse > 0) {

                    string message = "Reimbursement already applied!";
                    string script = $"<script>alert('{message}'); </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", script);
                }
                else
                {
                    GenerateDocNo generateDocNo = new GenerateDocNo();
                    generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(company.Value), 1032);
                    var docNo = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(company.Value), 1032);

                    // INSERT TO ACCEDE_T_RFPMain
                    ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain();
                    {
                        rfp.Company_ID = Convert.ToInt32(company.Value);
                        rfp.Department_ID = Convert.ToInt32(rfpDept.Value);
                        rfp.PayMethod = Convert.ToInt32(rfpPaymethod.Value);
                        rfp.TranType = Convert.ToInt32(rfpTrantype.Value);
                        rfp.isTravel = Convert.ToBoolean(rfpTravel.Value);
                        rfp.SAPCostCenter = Convert.ToString(rfpcostCenter.Value);
                        rfp.IO_Num = Convert.ToString(rfpIO.Value);
                        rfp.Payee = rfpPayee.Text;
                        if (Convert.ToBoolean(rfpTravel.Value) == true)
                        {
                            rfp.LastDayTransact = Convert.ToDateTime(rfpLastday.Value);
                        }
                        rfp.Amount = Convert.ToDecimal(rfpAmount.Value);
                        rfp.Purpose = Convert.ToString(rfpPurpose.Value);
                        rfp.User_ID = Convert.ToString(Session["userID"]);
                        rfp.Status = 13;
                        rfp.DateCreated = Convert.ToDateTime(DateTime.Now);
                        rfp.RFP_DocNum = docNo;
                        rfp.IsExpenseReim = true;
                        rfp.IsExpenseCA = false;
                        rfp.Exp_ID = Convert.ToInt32(Session["ExpenseId"]);
                        rfp.WF_Id = Convert.ToInt32(drpdown_WF.Value);
                        rfp.FAPWF_Id = Convert.ToInt32(drpdwn_FAPWF.Value);

                    }
                    context.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                    context.SubmitChanges();
                }
                
            }
            catch (Exception)
            {
                throw;
            }

            rfpPopup.ShowOnPageLoad = false;
            DocuGrid0.DataBind();
        }

        protected void amountCallback_Callback(object source, CallbackEventArgs e)
        {
            var checkMinAmount = context.ACCEDE_M_CheckMinAmounts
                .Count(x => x.CompanyId == Convert.ToInt32(company.Value) && Convert.ToDecimal(rfpAmount.Value) >= x.MaxAmount);

            if (checkMinAmount > 0)
                e.Result = "3";

        }

        protected void rfpAmount_ValueChanged(object sender, EventArgs e)
        {
            var checkMinAmount = context.ACCEDE_M_CheckMinAmounts
                .Count(x => x.CompanyId == Convert.ToInt32(company.Value) && Convert.ToDecimal(rfpAmount.Value) >= x.MaxAmount);

            if (checkMinAmount > 0)
                rfpPaymethod.SelectedIndex = 3;
        }

        [WebMethod]
        public static decimal CheckMinAmountAJAX(int comp_id, int payMethod)
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.CheckMinAmount(comp_id, payMethod);
        }

        //public decimal CheckMinAmount(int comp_id)
        //{
        //    var maxAmount = context.ACCEDE_M_CheckMinAmounts.Where(x => x.CompanyId == comp_id).FirstOrDefault();
        //    if (maxAmount != null)
        //    {
        //        return Convert.ToDecimal(maxAmount.MaxAmount);
        //    }
        //    return 0;
        //}

        [WebMethod]
        public static bool UpdateReimbursementAJAX(string totalAmount)
        {
            Accede_ExpenseReport page = new Accede_ExpenseReport();
            
            return page.UpdateReimbursement(totalAmount);
        }

        public bool UpdateReimbursement(string totalAmount)
        {
            try
            {
                var reimburseDetails = context.ACCEDE_T_RFPMains.Where(x=>x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x=>x.TranType == 2).FirstOrDefault();
                var returned_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();

                if (reimburseDetails != null)
                {
                    var checkMinAmount = context.ACCEDE_M_CheckMinAmounts.Where(x => x.CompanyId == Convert.ToInt32(reimburseDetails.Company_ID)).FirstOrDefault();

                    if (returned_audit != null)
                    {
                        if (reimburseDetails.Status == returned_audit.STS_Id)
                        {
                            decimal new_amnt = Convert.ToDecimal(totalAmount);
                            if (reimburseDetails.Amount >= new_amnt)
                            {
                                reimburseDetails.isReturnToAudit = true;
                            }
                        }
                    }

                    reimburseDetails.Amount = Convert.ToDecimal(totalAmount);
                    //if(checkMinAmount != null)
                    //{
                    //    if(checkMinAmount.MaxAmount <= Convert.ToDecimal(totalAmount))
                    //    {
                    //        reimburseDetails.PayMethod = 3;
                    //    }
                    //}
                }
                context.SubmitChanges();
                return true;
            }catch(Exception ex)
            {
                return false;
            }
        }

        protected void WFSequenceGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF.Value != null ? drpdown_WF.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        protected void drpdwn_FAPWF_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.Split('|').Last();
            var amount = e.Parameter.Split('|').First();

            var expAmnt = context.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpMain_ID"]));
            decimal totalExpAmnt = 0;
            if(expAmnt != null)
            {
                foreach (var item in expAmnt)
                {
                    totalExpAmnt += Convert.ToDecimal(item.GrossAmount);
                }
            }

            var wf = context.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(totalExpAmnt)).Where(x => x.Maximum >= Convert.ToDecimal(totalExpAmnt)).FirstOrDefault();
            if (wf != null)
            {
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF2.DataBind();

                drpdwn_FAPWF.DataSourceID = null;
                drpdwn_FAPWF.DataSource = SqlFAPWF2;
                drpdwn_FAPWF.DataBindItems();
                drpdwn_FAPWF.SelectedIndex = 0;


            }
            else
            {
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                SqlFAPWF2.DataBind();

                drpdwn_FAPWF.DataSourceID = null;
                drpdwn_FAPWF.DataSource = SqlFAPWF2;
                drpdwn_FAPWF.DataBindItems();
                drpdwn_FAPWF.SelectedIndex = 0;
            }
        }

        protected void FAPWFGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var comp_id = e.Parameters.Split('|').Last();
            var amount = e.Parameters.Split('|').First();

            var wf = context.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).FirstOrDefault();
            if (wf != null)
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();

            }
            else
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                SqlFAPWF.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();

                drpdwn_FAPWF.SelectedIndex = 0;
            }
        }
    }
}