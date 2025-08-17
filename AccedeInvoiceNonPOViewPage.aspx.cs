using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeNonPOEditPage;

namespace DX_WebTemplate
{
    public partial class AccedeInvoiceNonPOViewPage : System.Web.UI.Page
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

                            int expID = Convert.ToInt32(Decrypt(encryptedID));

                            var expDetails = _DataContext.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == Convert.ToInt32(expID))
                                .FirstOrDefault();

                            sqlMain.SelectParameters["ID"].DefaultValue = expDetails.ID.ToString();
                            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = expDetails.ID.ToString();
                            SqlCA.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                            SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = expDetails.ID.ToString();
                            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = expDetails.ID.ToString();

                            var exp = _DataContext.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == expDetails.ID)
                                .FirstOrDefault();

                            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                            var status_id = exp.Status.ToString();
                            var user_id = exp.UserId.ToString();

                            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                            var btnRecall = FormExpApprovalView.FindItemOrGroupByName("recallBtn") as LayoutItem;
                            var btn_Edit = FormExpApprovalView.FindItemOrGroupByName("edit_btn") as LayoutItem;

                            if (myLayoutGroup != null)
                            {
                                myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";
                            }

                            var vendor = _DataContext.ACCEDE_S_Vendors.Where(x => x.VendorCode == exp.ExpenseName).FirstOrDefault();
                            txt_Vendor.Text = vendor.VendorName.ToString().Trim();

                            //var RFPCA = _DataContext.ACCEDE_T_RFPMains
                            //    .Where(x => x.Exp_ID == expDetails.ID)
                            //    .Where(x => x.IsExpenseCA == true)
                            //    .Where(x => x.isTravel != true);

                            //decimal totalCA = 0;
                            //foreach (var item in RFPCA)
                            //{
                            //    totalCA += Convert.ToDecimal(item.Amount);
                            //}
                            //caTotal.Text = totalCA.ToString("#,##0.00") + "  PHP ";

                            var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == expDetails.ID);
                            decimal totalExp = 0;
                            foreach (var item in ExpDetails)
                            {
                                totalExp += Convert.ToDecimal(item.NetAmount);
                            }
                            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";
                            //decimal dueComp = totalCA - totalExp;

                            //if (dueComp < 0)
                            //{
                            //    var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            //    dueField.Caption = "Net Due to Employee";
                            //}
                            //else
                            //{
                            //    var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            //    dueField.Caption = "Net Due to Company";

                            //    if (dueComp > 0)
                            //    {
                            //        var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                            //        AR_Reference.ClientVisible = true;
                            //    }
                            //}

                            //dueTotal.Text = FormatDecimal(dueComp) + "  PHP ";
                            var returnAuditStats = _DataContext.ITP_S_Status
                                .Where(x => x.STS_Name == "Returned by Audit")
                                .FirstOrDefault();

                            var returnP2PStats = _DataContext.ITP_S_Status
                                .Where(x => x.STS_Name == "Returned by P2P")
                                .FirstOrDefault();

                            if (status_id == "3" || status_id == "13" || status_id == "15" || status_id == returnAuditStats.STS_Id.ToString() || status_id == returnP2PStats.STS_Id.ToString() && user_id == Session["userID"].ToString())
                            {
                                btn_Edit.ClientVisible = true;
                            }
                            var PendingAuditStat = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                            if (status_id == PendingAuditStat.STS_Id.ToString())
                            {
                                var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                                print.ClientVisible = true;
                            }

                            if (status_id == "1" && expDetails.UserId == empCode)
                            {
                                btnRecall.ClientVisible = true;
                            }


                            var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                                            .Where(x => x.IsExpenseReim != true)
                                            .Where(x => x.IsExpenseCA != true)
                                            .Where(x => x.Status != 4)
                                            .Where(x => x.Exp_ID == Convert.ToInt32(exp.ID))
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

        public static string FormatDecimal(decimal value)
        {
            if (value < 0)
            {
                return $"({Math.Abs(value).ToString("#,##0.00")})";
            }
            return value.ToString("#,##0.00");
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            string encryptedID = Request.QueryString["secureToken"];
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int expID = Convert.ToInt32(Decrypt(encryptedID));
                Session["cID"] = expID;
                Response.Redirect("~/AccedeExpenseReportPrinting.aspx");
            }
                
        }

        //PDF/IMAGE VIEWER
        [WebMethod]
        public static object AJAXGetDocument(string fileId, string appId)
        {
            DocumentViewer doc = new DocumentViewer();

            return doc.GetDocument(fileId, appId);
        }

        public object GetDocument(string fileId, string appId)
        {
            byte[] bytes;
            string fileName, contentType;
            string constr = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT FileName, FileAttachment, FileExtension FROM ITP_T_FileAttachment WHERE ID = @fileId AND App_ID = @appId";
                    cmd.Parameters.AddWithValue("@fileId", Convert.ToInt32(fileId));
                    cmd.Parameters.AddWithValue("@appId", Convert.ToInt32(appId));
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        sdr.Read();
                        bytes = (byte[])sdr["FileAttachment"];
                        contentType = sdr["FileExtension"].ToString();
                        fileName = sdr["FileName"].ToString();
                    }
                    con.Close();
                }
            }

            if (contentType == "png" || contentType == "jpg" || contentType == "jpeg" || contentType == "gif" || contentType == "JPEG" || contentType == "JPG" || contentType == "PNG" || contentType == "GIF")
            {
                string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            else
                return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }


        [WebMethod]
        public static string RecallExpMainAJAX(string remarks, string secureToken)
        {
            AccedeInvoiceNonPOViewPage exp = new AccedeInvoiceNonPOViewPage();

            return exp.RecallExpMain(remarks, secureToken);
        }

        public string RecallExpMain(string remarks, string secureToken)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int expID = Convert.ToInt32(Decrypt(encryptedID));

                    string remarksInput = remarks.Trim();
                    var doc_id = expID;
                    var approver_org_id = 0;
                    var expDocType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .FirstOrDefault();

                    if (!string.IsNullOrEmpty(remarksInput))
                    {
                        foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                            .Where(x => x.Document_Id == doc_id)
                            .Where(x => x.AppDocTypeId == expDocType.DCT_Id)
                            .Where(x => x.AppId == 1032)
                            .Where(x => x.Status == 1))
                        {
                            rs.Status = 15;
                            rs.DateAction = DateTime.Now;
                            rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                            approver_org_id = Convert.ToInt32(rs.OrgRole_Id.ToString());
                        }

                        var reimRFP = _DataContext.ACCEDE_T_RFPMains
                            .Where(x => x.IsExpenseReim == true)
                            .Where(x => x.Status != 4)
                            .Where(x => x.Exp_ID == doc_id)
                            .Where(x => x.isTravel != true)
                            .FirstOrDefault();

                        if (reimRFP != null)
                        {
                            var rfpDocType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE RFP")
                                .FirstOrDefault();

                            foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                            .Where(x => x.Document_Id == reimRFP.ID)
                            .Where(x => x.AppDocTypeId == rfpDocType.DCT_Id)
                            .Where(x => x.AppId == 1032)
                            .Where(x => x.Status == 1))
                            {
                                rs.Status = 15;
                                rs.DateAction = DateTime.Now;
                                rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                            }
                        }

                        var comp_id = 0;
                        var doc_no = "";
                        var date_created = "";
                        var document_purpose = "";
                        var creator_email = "";
                        var creator_fullname = "";
                        var approver_id = "";
                        var payMethod = "";
                        var tranType = "";

                        foreach (var item in _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == doc_id))
                        {
                            item.Status = 15;

                            comp_id = Convert.ToInt32(item.CompanyId);
                            doc_no = item.DocNo.ToString();
                            date_created = item.DateCreated.ToString();
                            document_purpose = item.Purpose;

                            approver_id = _DataContext.ITP_S_SecurityUserOrgRoles
                                .Where(x => x.OrgRoleId == approver_org_id)
                                .FirstOrDefault().UserId;

                            creator_fullname = _DataContext.ITP_S_UserMasters
                                .Where(x => x.EmpCode == item.UserId)
                                .FirstOrDefault().FullName;

                            creator_email = _DataContext.ITP_S_UserMasters
                                .Where(x => x.EmpCode == item.UserId)
                                .FirstOrDefault().Email;

                            if (item.PaymentType != null && item.PaymentType != 0)
                            {
                                payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == item.PaymentType).FirstOrDefault().PMethod_name;
                            }

                            if (item.ExpenseType_ID != null && item.ExpenseType_ID != 0)
                            {
                                tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == item.ExpenseType_ID).FirstOrDefault().Description;
                            }
                        }
                        _DataContext.SubmitChanges();



                        ///////---START EMAIL PROCESS-----////////

                        var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                                  .FirstOrDefault();

                        foreach (var item in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == approver_org_id))
                        {
                            var receiver_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.UserId)
                                  .FirstOrDefault();

                            RFPViewPage exp = new RFPViewPage();

                            exp.SendEmailToApprover(approver_id.ToString(), comp_id, creator_fullname, creator_email, doc_no, date_created, document_purpose, payMethod, tranType, remarks, "Recalled");

                        }

                    }

                    return "success";
                }
                else
                {
                    return "Secure token is null. Please refresh page.";
                }
                
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        protected void CAWFActivityGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAWFActivity.SelectParameters["Document_Id"].DefaultValue = e.Parameters.ToString();
            SqlCAWFActivity.DataBind();

            CAWFActivityGrid.DataBind();
        }

        protected void CADocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAFileAttach.SelectParameters["Doc_ID"].DefaultValue = e.Parameters.ToString();
            SqlCAFileAttach.DataBind();

            CADocuGrid.DataBind();
        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpMap.SelectParameters["ExpenseReportDetail_ID"].DefaultValue = e.Parameters.ToString();
            SqlExpMap.DataBind();

            ExpAllocGrid.DataBind();
        }

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpDetailAttach.SelectParameters["ExpDetail_Id"].DefaultValue = e.Parameters.ToString();
            SqlExpDetailAttach.DataBind();

            DocuGrid1.DataBind();
        }

        [WebMethod]
        public static RFPDetails DisplayCADetailsAJAX(int item_id)
        {
            AccedeExpenseViewPage rfp = new AccedeExpenseViewPage();
            return rfp.DisplayCADetails(item_id);
        }

        public RFPDetails DisplayCADetails(int item_id)
        {
            var rfpCA = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.ID == item_id)
                .FirstOrDefault();

            RFPDetails rfp = new RFPDetails();
            if (rfpCA != null)
            {
                var compName = _DataContext.CompanyMasters
                    .Where(x => x.WASSId == rfpCA.Company_ID)
                    .FirstOrDefault().CompanyShortName;

                var deptName = _DataContext.ITP_S_OrgDepartmentMasters
                    .Where(x => x.ID == rfpCA.Department_ID)
                    .FirstOrDefault().DepDesc;

                var payMethName = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfpCA.PayMethod)
                    .FirstOrDefault().PMethod_name;

                var payeeName = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == rfpCA.Payee)
                    .FirstOrDefault();

                var tranTypeName = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfpCA.TranType)
                    .FirstOrDefault().RFPTranType_Name;

                var rawfDetail = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.WF_Id == Convert.ToInt32(rfpCA.WF_Id))
                    .FirstOrDefault();

                var fapwfDetail = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.WF_Id == Convert.ToInt32(rfpCA.FAPWF_Id))
                    .FirstOrDefault();

                rfp.company = compName != null ? compName : "";
                rfp.department = deptName != null ? deptName : "";
                rfp.payMethod = payMethName != null ? payMethName : "";
                rfp.tranType = tranTypeName != null ? tranTypeName : "";
                rfp.CostCenter = rfpCA.SAPCostCenter != null ? rfpCA.SAPCostCenter : "";
                rfp.payee = payeeName.FullName != null ? payeeName.FullName : "";
                rfp.purpose = rfpCA.Purpose != null ? rfpCA.Purpose : "";
                rfp.amount = rfpCA.Amount != null ? rfpCA.Amount.ToString() : "";
                rfp.currency = rfpCA.Currency != null ? rfpCA.Currency : "";
                rfp.docNum = rfpCA.RFP_DocNum != null ? rfpCA.RFP_DocNum : "";
                rfp.RAWF = rawfDetail.Name != null ? rawfDetail.Name : "";
                rfp.FAPWF = fapwfDetail.Name != null ? fapwfDetail.Name : "";
            }
            return rfp;
        }

        [WebMethod]
        public static string RedirectToEditAJAX(string secureToken)
        {
            AccedeInvoiceNonPOViewPage page = new AccedeInvoiceNonPOViewPage();

            return page.RedirectToEdit(secureToken);
        }

        public string RedirectToEdit(string secureToken)
        {
            string encryptedID = secureToken;
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int expID = Convert.ToInt32(Decrypt(encryptedID));

                Session["NonPOExpenseId"] = expID;

                return "success";
            }
            else
            {
                return "Secure Token is null. Please refresh the page or login again.";
            }
        }

        //Display Expense detail data to modal
        [WebMethod]
        public static ExpDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeInvoiceNonPOViewPage exp = new AccedeInvoiceNonPOViewPage();
            return exp.DisplayExpDetails(expDetailID);
        }

        public ExpDetailsNonPO DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_ExpenseDetails
                .Where(x => x.ExpenseReportDetail_ID == expDetailID)
                .FirstOrDefault();

            var exp_detailsMap = _DataContext.ACCEDE_T_ExpenseDetailsMaps.Where(x => x.ExpenseReportDetail_ID == expDetailID);
            decimal totalAmnt = 0;

            foreach (var item in exp_detailsMap)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }

            totalAmnt = Convert.ToDecimal(exp_details.GrossAmount) - totalAmnt;

            ExpDetailsNonPO exp_det_class = new ExpDetailsNonPO();

            if (exp_details != null)
            {
                exp_det_class.dateAdded = Convert.ToDateTime(exp_details.DateAdded).ToString("MM/dd/yyyy hh:mm:ss");

                exp_det_class.supplier = exp_details.Supplier ?? exp_det_class.supplier;
                var particulars_desc = _DataContext.ACCEDE_S_Particulars.Where(x => x.ID == Convert.ToInt32(exp_details.Particulars)).FirstOrDefault();
                exp_det_class.particulars = particulars_desc.P_Name != null ? particulars_desc.P_Description+" - "+ particulars_desc.P_Name : exp_det_class.particulars;
                exp_det_class.acctCharge = exp_details.AccountToCharged ?? exp_det_class.acctCharge;
                exp_det_class.tin = exp_details.TIN ?? exp_det_class.tin;
                exp_det_class.invoice = exp_details.InvoiceOR ?? exp_det_class.invoice;
                exp_det_class.costCenter = exp_details.CostCenterIOWBS ?? exp_det_class.costCenter;
                exp_det_class.grossAmnt = exp_details.GrossAmount != null ? Convert.ToDecimal(exp_details.GrossAmount) : exp_det_class.grossAmnt;
                exp_det_class.vat = exp_details.VAT != null ? Convert.ToDecimal(exp_details.VAT) : exp_det_class.vat;
                exp_det_class.ewt = exp_details.EWT != null ? Convert.ToDecimal(exp_details.EWT) : exp_det_class.ewt;
                exp_det_class.netAmnt = exp_details.NetAmount != null ? Convert.ToDecimal(exp_details.NetAmount) : exp_det_class.netAmnt;
                exp_det_class.expMainId = exp_details.ExpenseMain_ID != null ? Convert.ToInt32(exp_details.ExpenseMain_ID) : exp_det_class.expMainId;
                exp_det_class.preparerId = exp_details.Preparer_ID ?? exp_det_class.preparerId;
                exp_det_class.io = exp_details.ExpDtl_IO ?? exp_det_class.io;
                exp_det_class.remarks = exp_details.ExpDetail_remarks ?? exp_det_class.remarks;
                exp_det_class.wbs = exp_details.ExpDtl_WBS ?? exp_det_class.wbs;

                //var exp_details_nonpo = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(exp_details.ExpenseReportDetail_ID)).FirstOrDefault();
                //exp_det_class.Assignment = exp_details_nonpo.Assignment ?? exp_det_class.Assignment;
                //exp_det_class.UserId = exp_details_nonpo.UserId ?? exp_det_class.UserId;
                //exp_det_class.Allowance = exp_details_nonpo.Allowance ?? exp_det_class.Allowance;
                //exp_det_class.SLCode = exp_details_nonpo.SLCode ?? exp_det_class.SLCode;
                //exp_det_class.EWTTaxType_Id = exp_details_nonpo.EWTTaxType_Id != null ? Convert.ToInt32(exp_details_nonpo.EWTTaxType_Id) : exp_det_class.EWTTaxType_Id;
                //exp_det_class.EWTTaxAmount = exp_details_nonpo.EWTTaxAmount != null ? Convert.ToDecimal(exp_details_nonpo.EWTTaxAmount) : exp_det_class.EWTTaxAmount;
                //exp_det_class.EWTTaxCode = exp_details_nonpo.EWTTaxCode ?? exp_det_class.EWTTaxCode;
                //exp_det_class.InvoiceTaxCode = exp_details_nonpo.InvoiceTaxCode ?? exp_det_class.InvoiceTaxCode;
                //exp_det_class.Asset = exp_details_nonpo.Asset ?? exp_det_class.Asset;
                //exp_det_class.SubAssetCode = exp_details_nonpo.SubAssetCode ?? exp_det_class.SubAssetCode;
                //exp_det_class.TransactionType = exp_details_nonpo.TransactionType ?? exp_det_class.TransactionType;
                //exp_det_class.AltRecon = exp_details_nonpo.AltRecon ?? exp_det_class.AltRecon;
                //exp_det_class.SpecialGL = exp_details_nonpo.SpecialGL ?? exp_det_class.SpecialGL;
                exp_det_class.Qty = exp_details.Qty ?? exp_det_class.Qty;
                exp_det_class.UnitPrice = exp_details.UnitPrice ?? exp_det_class.UnitPrice;

                exp_det_class.totalAllocAmnt = totalAmnt;

                Session["ExpDetailsID"] = expDetailID.ToString();

            }

            return exp_det_class;
        }
    }
}