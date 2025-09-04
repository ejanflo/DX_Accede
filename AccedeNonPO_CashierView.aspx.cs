using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeNonPO_CashierView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                    if (!IsPostBack)
                    {
                        string encryptedID = Request.QueryString["secureToken"];
                        if (!string.IsNullOrEmpty(encryptedID))
                        {
                            //Start ------------------ Page Security
                            string empCode = Session["userID"].ToString();
                            int appID = 26; //22-ITPORTAL; 13-CAR; 26-RS; 1027-RFP; 1028-UAR

                            string url = Request.Url.AbsolutePath; // Get the current URL
                            string pageName = Path.GetFileNameWithoutExtension(url); // Get the filename without extension
                            //if (!AnfloSession.Current.hasPageAccess(empCode, appID, pageName))
                            //{
                            //    Session["appID"] = appID.ToString();
                            //    Session["pageName"] = pageName.ToString();

                            //    Response.Redirect("~/ErrorAccess.aspx");
                            //}
                            //End ------------------ Page Security

                            int actID = Convert.ToInt32(Decrypt(encryptedID));

                            var actDetails = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.WFA_Id == Convert.ToInt32(actID))
                                .FirstOrDefault();

                            var invDetails = _DataContext.ACCEDE_T_InvoiceMains
                                .Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id))
                                .FirstOrDefault();

                            var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE InvoiceNPO").Where(x => x.App_Id == 1032).FirstOrDefault();

                            sqlMain.SelectParameters["ID"].DefaultValue = invDetails.ID.ToString();
                            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : null;
                            SqlCA.SelectParameters["Exp_ID"].DefaultValue = invDetails.ID.ToString();
                            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = invDetails.ID.ToString();
                            SqlExpDetails.SelectParameters["InvMain_ID"].DefaultValue = invDetails.ID.ToString();
                            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = invDetails.ID.ToString();

                            SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType.DCT_Id.ToString();

                            //var inv = _DataContext.ACCEDE_T_InvoiceMains
                            //    .Where(x => x.ID == invDetails.ID)
                            //    .FirstOrDefault();

                            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(invDetails.WF_Id).ToString();
                            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(invDetails.FAPWF_Id).ToString();

                            var status_id = invDetails.Status.ToString();
                            var user_id = invDetails.UserId.ToString();

                            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                            var btnDisburse = FormExpApprovalView.FindItemOrGroupByName("disburseBtn") as LayoutItem;

                            if (myLayoutGroup != null)
                            {
                                myLayoutGroup.Caption = "Invoice Document -" + invDetails.DocNo.ToString() + " (View)";
                            }

                            string raw = invDetails.VendorName.ToString();
                            string cleaned = raw.Replace("\r", "").Replace("\n", "");
                            var vendors = SAPVendor.GetVendorData("")
                                .GroupBy(x => new { x.VENDCODE, x.VENDNAME })
                                .Select(g => g.First())
                                .ToList();

                            var payee = vendors.Where(x => x.VENDCODE == cleaned).FirstOrDefault();
                            //txt_Vendor.Text = payee.VendorName.ToString();

                            var ExpDetails = _DataContext.ACCEDE_T_InvoiceLineDetails.Where(x => x.InvMain_ID == invDetails.ID);
                            decimal totalExp = 0;
                            foreach (var item in ExpDetails)
                            {
                                totalExp += Convert.ToDecimal(item.NetAmount);
                            }
                            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";

                            txt_InvoiceNo.Text = invDetails.InvoiceNo?.ToString();

                            //var vendorDetails = _DataContext.ACCEDE_S_Vendors.Where(x => x.VendorCode == invDetails.VendorName).FirstOrDefault();
                            //if (vendorDetails != null)
                            //{
                            //    string tin = vendorDetails.TaxID.ToString();

                            //    if (tin.Length > 9)
                            //    {
                            //        string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3, 3)}-{tin.Substring(6, 3)}-{tin.Substring(9)}";
                            //        txt_TIN.Text = formattedTin;
                            //    }
                            //    else if (tin.Length > 6)
                            //    {
                            //        string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3, 3)}-{tin.Substring(6)}";
                            //        txt_TIN.Text = formattedTin;
                            //    }
                            //    else if (tin.Length > 3)
                            //    {
                            //        string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3)}";
                            //        txt_TIN.Text = formattedTin;
                            //    }
                            //    else
                            //    {
                            //        txt_TIN.Text = tin; // less than 3 digits, no formatting
                            //    }

                            //    string Clean(string input)
                            //    {
                            //        if (string.IsNullOrWhiteSpace(input))
                            //            return "";

                            //        // remove line breaks and trim
                            //        string cleanedVendorstr = input.Replace("\r", " ").Replace("\n", " ").Trim();

                            //        return ", " + cleanedVendorstr;
                            //    }

                            //    memo_VendorAddress.Text =
                            //        (vendorDetails.Address1 ?? "").Replace("\r", " ").Replace("\n", " ").Trim()
                            //        + Clean(vendorDetails.City ?? "")
                            //        + Clean(vendorDetails.State ?? "");


                            //}

                            var pendingCashierStats = _DataContext.ITP_S_Status
                                .Where(x => x.STS_Name == "Pending at Cashier")
                                .FirstOrDefault();

                            if (status_id == pendingCashierStats.STS_Id.ToString())
                            {
                                btnDisburse.ClientVisible = true;
                            }
                            var PendingAuditStat = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                            //if (status_id == PendingAuditStat.STS_Id.ToString())
                            //{
                            //    var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                            //    print.ClientVisible = true;
                            //}

                            //if (status_id == "1" && expDetails.UserId == empCode)
                            //{
                            //    btnRecall.ClientVisible = true;
                            //}


                            var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                                            .Where(x => x.IsExpenseReim != true)
                                            .Where(x => x.IsExpenseCA != true)
                                            .Where(x => x.Status != 4)
                                            .Where(x => x.Exp_ID == Convert.ToInt32(invDetails.ID))
                                            .Where(x => x.isTravel != true)
                                            .FirstOrDefault();

                            if (ptvRFP == null)
                            {
                                var reim = FormExpApprovalView.FindItemOrGroupByName("reimItem") as LayoutItem;
                                if (reim != null)
                                {
                                    reim.ClientVisible = true;
                                    //ReimburseGrid.Visible = false;
                                }

                            }
                            else
                            {
                                var reim = FormExpApprovalView.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                                if (reim != null)
                                {
                                    reim.ClientVisible = true;
                                    link_rfp.Value = ptvRFP.RFP_DocNum;
                                }

                                txt_SAPDoc.Text = ptvRFP.SAPDocNo != null ? ptvRFP.SAPDocNo : "";
                            }
                        }
                        else
                        {
                            Response.Redirect("~/AccedeInvoiceNonPODashboard.aspx");
                        }
                    }


                }
                else
                {
                    Response.Redirect("~/Logon.aspx");
                }
            }
            catch (Exception ex)
            {
                //Session["MyRequestPath"] = Request.Url.AbsoluteUri;
                Response.Redirect("~/Logon.aspx");
            }
        }

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        [WebMethod]
        public static string DisburseAJAX(string secureToken)
        {
            AccedeNonPO_CashierView page = new AccedeNonPO_CashierView();
            return page.Disburse(secureToken);
        }

        public string Disburse(string secureToken)
        {
            try
            {
                if (!string.IsNullOrEmpty(secureToken))
                {
                    int actID = Convert.ToInt32(Decrypt(secureToken));
                    var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                                .Where(x => x.IsExpenseReim != true)
                                .Where(x => x.IsExpenseCA != true)
                                .Where(x => x.Status != 4)
                                .Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id))
                                .Where(x => x.isTravel != true)
                                .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();

                    var release_cash_status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disbursed").FirstOrDefault();
                    var completed_status = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Complete")
                        .FirstOrDefault();

                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Document_Id == rfp_main.ID)
                        .Where(x => x.Status == wfDetails.Status)
                        .FirstOrDefault();

                    //UPDATE EXP MAIN ACTIVITY
                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();
                    wfDetails.Status = release_cash_status.STS_Id;

                    //Update current reimburse Activity
                    if (reimActDetails != null)
                    {
                        reimActDetails.Status = release_cash_status.STS_Id;
                        reimActDetails.DateAction = DateTime.Now;
                        reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                    }

                    inv_main.Status = completed_status.STS_Id;
                    rfp_main.Status = release_cash_status.STS_Id;

                    Session["passRFPID"] = rfp_main.ID.ToString();

                    _DataContext.SubmitChanges();

                    return "success";
                }
                else
                {
                    return "Secure token is empty.";
                }

                    
            }
            catch (Exception ex)
            {

                return ex.Message;
            }
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int actID = Convert.ToInt32(Decrypt(encryptedID));

                var actDetails = _DataContext.ITP_T_WorkflowActivities
                    .Where(x => x.WFA_Id == Convert.ToInt32(actID))
                    .FirstOrDefault();

                var rfp_main = _DataContext.ACCEDE_T_RFPMains
                            .Where(x => x.IsExpenseReim != true)
                            .Where(x => x.IsExpenseCA != true)
                            .Where(x => x.Status != 4)
                            .Where(x => x.Exp_ID == Convert.ToInt32(actDetails.Document_Id))
                            .Where(x => x.isTravel != true)
                            .FirstOrDefault();

                Session["passRFPID"] = rfp_main.ID.ToString();

                Response.Redirect("~/RFPPrintPage.aspx");
            }
                
        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (!string.IsNullOrEmpty(encryptedID))
            {

                int actID = Convert.ToInt32(Decrypt(encryptedID));

                var actDetails = _DataContext.ITP_T_WorkflowActivities
                    .Where(x => x.WFA_Id == Convert.ToInt32(actID))
                    .FirstOrDefault();

                var invMain = _DataContext.ACCEDE_T_InvoiceMains.Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id)).FirstOrDefault();

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

                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE InvoiceNPO")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                    {
                        docs.FileAttachment = file.FileBytes;
                        docs.FileName = file.FileName;
                        docs.Doc_ID = Convert.ToInt32(Session["NonPOExpenseId"]);
                        docs.App_ID = 1032;
                        docs.DocType_Id = 1016;
                        docs.User_ID = Session["userID"].ToString();
                        docs.FileExtension = file.FileName.Split('.').Last();
                        docs.Description = file.FileName.Split('.').First();
                        docs.FileSize = filesizeStr;
                        docs.Doc_No = Session["DocNo"].ToString();
                        docs.Company_ID = Convert.ToInt32(invMain.InvChargedTo_CompanyId);
                        docs.DateUploaded = DateTime.Now;
                        docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                    }
                    ;
                    _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                }
                _DataContext.SubmitChanges();
                SqlDocs.DataBind();
                DocumentGrid.DataBind();
            }

        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = e.Parameters.ToString();
            SqlExpMap.DataBind();

            ExpAllocGrid.DataBind();
        }

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpDetailAttach.SelectParameters["ExpDetail_Id"].DefaultValue = e.Parameters.ToString();
            SqlExpDetailAttach.DataBind();

            DocuGrid1.DataBind();
        }
    }
}