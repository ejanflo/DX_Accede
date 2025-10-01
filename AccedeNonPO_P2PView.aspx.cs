using DevExpress.Data.Filtering.Helpers;
using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
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
using static DX_WebTemplate.AccedeNonPOEditPage;
using System.Data.Linq;
using static DX_WebTemplate.AccedeModels;

namespace DX_WebTemplate
{
    public partial class AccedeNonPO_P2PView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        decimal dueComp = new decimal(0.00);
        private static readonly Func<ITPORTALDataContext, int, ITP_T_WorkflowActivity> QueryWorkflowActivity =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int id) =>
                ctx.ITP_T_WorkflowActivities.SingleOrDefault(a => a.WFA_Id == id));

        private static readonly Func<ITPORTALDataContext, int, ACCEDE_T_InvoiceMain> QueryInvoiceMain =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int id) =>
                ctx.ACCEDE_T_InvoiceMains.SingleOrDefault(i => i.ID == id));

        private static readonly Func<ITPORTALDataContext, int, ACCEDE_S_ExpenseType> QueryExpenseType =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int id) =>
                ctx.ACCEDE_S_ExpenseTypes.SingleOrDefault(e => e.ExpenseType_ID == id));

        private static readonly Func<ITPORTALDataContext, int, decimal?> QueryInvoiceDetailsNetSum =
            CompiledQuery.Compile((ITPORTALDataContext ctx, int invMainId) =>
                ctx.ACCEDE_T_InvoiceLineDetails
                   .Where(d => d.InvMain_ID == invMainId)
                   .Select(d => (decimal?)d.NetAmount)
                   .Sum());

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AnfloSession.Current.ValidCookieUser())
            {
                Response.Redirect("~/Logon.aspx");
                return;
            }

            // Re-establish / refresh session (unchanged logic)
            AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

            if (IsPostBack) return;

            string encryptedID = Request.QueryString["secureToken"];
            if (string.IsNullOrWhiteSpace(encryptedID))
            {
                Response.Redirect("~/AllAccedeApprovalPage.aspx");
                return;
            }

            int actID;
            try
            {
                actID = Convert.ToInt32(Decrypt(encryptedID));
            }
            catch
            {
                Response.Redirect("~/AllAccedeApprovalPage.aspx");
                return;
            }

            // 1. Load workflow activity (compiled query)
            var actDetails = QueryWorkflowActivity(_DataContext, actID);
            if (actDetails == null)
            {
                Response.Redirect("~/AllAccedeApprovalPage.aspx");
                return;
            }

            // 2. Load invoice main once
            var inv = QueryInvoiceMain(_DataContext, Convert.ToInt32(actDetails.Document_Id));
            if (inv == null)
            {
                Response.Redirect("~/AllAccedeApprovalPage.aspx");
                return;
            }

            // 3. Get doc type (cached / single call)
            var docType = _DataContext.ITP_S_DocumentTypes
                .FirstOrDefault(x => x.DCT_Name == "ACDE InvoiceNPO" && x.App_Id == 1032);

            // 4. Prepare frequently reused strings
            string docIdStr = inv.ID.ToString();
            string wfIdStr = Convert.ToInt32(inv.WF_Id).ToString();
            string fapWfIdStr = Convert.ToInt32(inv.FAPWF_Id).ToString();
            string companyIdStr = inv.InvChargedTo_CompanyId?.ToString();
            string expDocTypeIdStr = docType?.DCT_Id.ToString();

            Session["ExpId"] = actDetails.Document_Id;

            // 5. Assign SqlDataSource parameters (grouped logically)
            sqlMain.SelectParameters["ID"].DefaultValue = docIdStr;
            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = docIdStr;
            SqlDocs.SelectParameters["DocType_Id"].DefaultValue = expDocTypeIdStr;
            SqlCADetails.SelectParameters["Exp_ID"].DefaultValue = docIdStr;
            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = docIdStr;
            SqlExpDetails.SelectParameters["InvMain_ID"].DefaultValue = docIdStr;
            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = docIdStr;
            SqlIO.SelectParameters["CompanyId"].DefaultValue = companyIdStr;
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = companyIdStr;
            SqlCompany.SelectParameters["WASSId"].DefaultValue = companyIdStr;
            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = companyIdStr;
            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = wfIdStr;
            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = fapWfIdStr;
            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = companyIdStr;

            // 6. Expense type (compiled query)
            var expType = inv.InvoiceType_ID.HasValue
                ? QueryExpenseType(_DataContext, Convert.ToInt32(inv.InvoiceType_ID))
                : null;

            if (expType != null)
                txt_ExpType.Text = expType.Description;

            // 7. Vendor name (avoid loading entire vendor list)
            //SetVendorName(inv.VendorCode);

            // 8. Populate lightweight UI fields
            txt_InvoiceNo.Text = inv.InvoiceNo;
            txt_ReportDate.Text = inv.ReportDate.HasValue
                ? inv.ReportDate.Value.ToString("MMMM dd, yyyy")
                : "";

            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
            if (myLayoutGroup != null)
            {
                myLayoutGroup.Caption = "Invoice Document -" + inv.DocNo + " (View)";
            }

            // 9. Sum expense details (single aggregate query)
            decimal totalExp = QueryInvoiceDetailsNetSum(_DataContext, inv.ID) ?? 0m;
            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + inv.Exp_Currency + " ";

            // 10. RFP (pending / travel flags)
            var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                .FirstOrDefault(x =>
                    x.IsExpenseReim != true &&
                    x.IsExpenseCA != true &&
                    x.Status != 4 &&
                    x.Exp_ID == inv.ID &&
                    x.isTravel != true);

            if (ptvRFP == null)
            {
                // Show reim info group when no existing RFP
                var reimItem = FormExpApprovalView.FindItemOrGroupByName("reimItem") as LayoutItem;
                if (reimItem != null)
                    reimItem.ClientVisible = true;
            }
            else
            {
                var reimLayout = FormExpApprovalView.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                if (reimLayout != null)
                {
                    reimLayout.ClientVisible = true;
                    link_rfp.Value = ptvRFP.RFP_DocNum;
                }
            }
        }

        private void SetVendorName(object vendorCodeObj)
        {
            if (vendorCodeObj == null) return;
            string vendorCode = vendorCodeObj.ToString().Trim();
            if (string.IsNullOrEmpty(vendorCode)) return;

            string cacheKey = "VendorName_" + vendorCode;
            var cached = HttpRuntime.Cache[cacheKey] as string;
            if (cached != null)
            {
                txt_vendor.Text = cached;
                return;
            }

            // Assumes GetVendorData can accept a filter. If not, consider adding a dedicated method.
            var vendor = SAPConnector.GetVendorData(vendorCode)
                .FirstOrDefault(x => x.VENDCODE == vendorCode);

            if (vendor != null)
            {
                txt_vendor.Text = vendor.VENDNAME;
                HttpRuntime.Cache.Insert(cacheKey, vendor.VENDNAME, null,
                    DateTime.UtcNow.AddMinutes(15), System.Web.Caching.Cache.NoSlidingExpiration);
            }
        }

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        protected void ExpGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnEdit") // Ensure it's a data row and the button is the desired one
            {
                e.Visible = DevExpress.Utils.DefaultBoolean.True;

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

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp = param[0];
            var dept = param[1];

            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = comp;
            SqlCostCenterCT.DataBind();

            var dept_details = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(dept)).FirstOrDefault();

            drpdown_CostCenter.DataSourceID = null;
            drpdown_CostCenter.DataSource = SqlCostCenterCT;
            drpdown_CostCenter.DataBind();

            drpdown_CostCenter.Value = dept_details.SAP_CostCenter.ToString();
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

        protected void ExpAllocGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            decimal totalNetAmount = 0;

            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount_edit.Value))
            //{
            //    ExpAllocGrid_edit.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}
            ASPxGridView grid = (ASPxGridView)sender;

            grid.JSProperties["cpComputeUnalloc_edit"] = totalNetAmount;
        }

        protected void DocuGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["InvDetailsID"] = null;

            DocuGrid_edit.DataSourceID = null;
            DocuGrid_edit.DataSource = SqlExpDetailAttach;
            DocuGrid_edit.DataBind();
        }

        protected void ExpAllocGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            //decimal totalAmnt = new decimal(0.00);
            int deletedRowIndex = Convert.ToInt32(e.Keys[ExpAllocGrid_edit.KeyFieldName].ToString());
            var expAllocs = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(x => x.InvoiceDetailMap_ID == Convert.ToInt32(deletedRowIndex))
                .FirstOrDefault();
            //ASPxGridView grid = (ASPxGridView)sender;
            //foreach (var item in expAllocs)
            //{
            //    totalAmnt += Convert.ToDecimal(item.NetAmount);
            //}
            //grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;

            decimal totalNetAmount = 0;
            decimal finalTotalAmnt = 0;
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            //{
            //    ExpAllocGrid.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}

            finalTotalAmnt = totalNetAmount - Convert.ToDecimal(expAllocs.NetAmount);
            ASPxGridView grid = (ASPxGridView)sender;
            grid.JSProperties["cpComputeUnalloc_edit"] = finalTotalAmnt;
        }

        protected void ExpAllocGrid_edit_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            var expAllocs = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(x => x.InvoiceReportDetail_ID == Convert.ToInt32(Session["InvDetailsID"]));

            decimal totalAmnt = new decimal(0.00);

            ASPxGridView grid = (ASPxGridView)sender;

            foreach (var item in expAllocs)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }

            totalAmnt = totalAmnt + Convert.ToDecimal(e.NewValues["NetAmount"]);
            if (totalAmnt > Convert.ToDecimal(total_edit.Value))
            {
                grid.Styles.Footer.ForeColor = System.Drawing.Color.Red;

                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;

                e.Cancel = true;

            }
            else
            {
                e.NewValues["InvoiceReportDetail_ID"] = Convert.ToInt32(Session["InvDetailsID"]);
                e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);

                grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;
            }
        }

        protected void ExpAllocGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            decimal totalNetAmount = 0;
            var RowIndex = e.NewValues["InvoiceDetailMap_ID"].ToString();
            var newAmnt = e.NewValues["NetAmount"].ToString();
            string ID_ObjID = "";
            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");
                object ID_Obj = ExpAllocGrid_edit.GetRowValues(i, "InvoiceDetailMap_ID");
                ID_ObjID = ExpAllocGrid_edit.GetRowValues(i, "InvoiceReportDetail_ID").ToString();

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    if (RowIndex.ToString() == ID_Obj.ToString())
                    {
                        netAmount = Convert.ToDecimal(newAmnt);
                    }
                    totalNetAmount += netAmount;
                }
            }

            //if (totalNetAmount > Convert.ToDecimal(grossAmount_edit.Value))
            //{
            //    ExpAllocGrid_edit.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}
            ASPxGridView grid = (ASPxGridView)sender;




            //e.Cancel = true;

            SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = ID_ObjID;

            // 🔑 Rebind your data (otherwise grid will show "no data to display")
            grid.DataSourceID = null;
            grid.DataSource = SqlExpMap;
            grid.DataBind();

            grid.JSProperties["cpComputeUnalloc_edit"] = totalNetAmount;
        }

        protected void DocuGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var expFile_Id = e.Keys["File_Id"].ToString();

            var expFile = _DataContext.ITP_T_FileAttachments
                .Where(x => x.ID == Convert.ToInt32(expFile_Id))
                .FirstOrDefault();

            var expMap = _DataContext.ACCEDE_T_ExpenseDetailFileAttaches
                .Where(x => x.FileAttach_Id == Convert.ToInt32(expFile_Id))
                .FirstOrDefault();

            if (expFile != null)
            {
                _DataContext.ITP_T_FileAttachments.DeleteOnSubmit(expFile);
                _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.DeleteOnSubmit(expMap);
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }

        protected void DocuGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var expFile_Id = e.Keys["File_Id"].ToString();

            var expFile = _DataContext.ITP_T_FileAttachments
                .Where(x => x.ID == Convert.ToInt32(expFile_Id))
                .FirstOrDefault();

            if (expFile != null)
            {
                expFile.Description = e.NewValues["Description"].ToString();
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }

        protected void UploadControllerExpD_edit_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            foreach (var file in UploadControllerExpD_edit.UploadedFiles)
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
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                }
                ;
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                _DataContext.SubmitChanges();

                ACCEDE_T_ExpenseDetailFileAttach docsMap = new ACCEDE_T_ExpenseDetailFileAttach();
                {
                    docsMap.FileAttach_Id = docs.ID;
                    docsMap.ExpDetail_Id = Convert.ToInt32(Session["InvDetailsID"]);
                }
                _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.InsertOnSubmit(docsMap);
                _DataContext.SubmitChanges();
            }

            SqlDocs.DataBind();
        }

        [WebMethod]
        public static string CheckSAPVAlidAJAX(string SAPDoc, string secureToken)
        {
            AccedeNonPO_P2PView page = new AccedeNonPO_P2PView();
            return page.CheckSAPVAlid(SAPDoc, secureToken);
        }

        public string CheckSAPVAlid(string SAPDoc, string secureToken)
        {
            if (!string.IsNullOrEmpty(secureToken))
            {
                int actID = Convert.ToInt32(Decrypt(secureToken));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                var reimRFP = _DataContext.ACCEDE_T_RFPMains
                                        .Where(x => x.IsExpenseReim != true)
                                        .Where(x => x.IsExpenseCA != true)
                                        .Where(x => x.Status != 4)
                                        .Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id))
                                        .Where(x => x.isTravel != true)
                                        .FirstOrDefault();

                var rfpCheck = _DataContext.ACCEDE_T_RFPMains.Where(x => x.SAPDocNo == SAPDoc).FirstOrDefault();

                if (rfpCheck != null && SAPDoc != reimRFP.SAPDocNo)
                {
                    return "error";
                }
                else
                {
                    return "clear";
                }
            }
            else
            {
                return "Secure token is null.";
            }

        }

        /////////---------- START OF APPROVAL PHASE ---------------////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        [WebMethod]
        public static string btnApproveClickAjax(string approve_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType, string sapDoc)
        {
            AccedeNonPO_P2PView page = new AccedeNonPO_P2PView();
            return page.btnApproveClick(approve_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType, sapDoc);
        }

        public string btnApproveClick(string approve_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType, string sapDoc)
        {
            if(sapDoc == "")
            {
                return "SAPDOC error";
            }
            else
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

                        AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();

                        var payMethod = "";
                        var tranType = "";

                        inv_main.InvChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        inv_main.InvChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        inv_main.CostCenter = costCenter;
                        inv_main.Exp_Currency = curr;
                        inv_main.PaymentType = Convert.ToInt32(payType);

                        if (rfp_main != null)
                        {
                            payMethod = _DataContext.ACCEDE_S_PayMethods
                                .Where(x => x.ID == rfp_main.PayMethod)
                                .FirstOrDefault().PMethod_name;

                            tranType = _DataContext.ACCEDE_S_RFPTranTypes
                                .Where(x => x.ID == rfp_main.TranType)
                                .FirstOrDefault().RFPTranType_Name;

                            rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                            rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                            rfp_main.SAPCostCenter = costCenter;
                            rfp_main.SAPDocNo = sapDoc;
                        }

                        var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                        var exp_app_doctype = wfDetails.AppDocTypeId;

                        var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Document_Id == rfp_main.ID)
                        .Where(x => x.Status == wfDetails.Status)
                        .FirstOrDefault();

                        var next_seq = 0;
                        var wfAct_detail = 0;

                        wfAct_detail = Convert.ToInt32(wfDetails.WFD_Id);

                        //Update current expense Activity
                        wfDetails.Status = 7;
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                        //Update current reimburse Activity
                        if (reimActDetails != null)
                        {
                            reimActDetails.Status = 7;
                            reimActDetails.DateAction = DateTime.Now;
                            reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";";
                            reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        var wf_detail_query = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WFD_Id == wfAct_detail)
                            .FirstOrDefault();

                        var wfHead_data = _DataContext.ITP_S_WorkflowHeaders
                            .Where(x => x.WF_Id == wf_detail_query.WF_Id)
                            .FirstOrDefault();

                        next_seq = Convert.ToInt32(wf_detail_query.Sequence) + 1;

                        var nex_wf_detail_query = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WF_Id == wf_detail_query.WF_Id)
                            .Where(x => x.Sequence == next_seq)
                            .FirstOrDefault();

                        var nex_org_role = 0;
                        var nex_wf_detail_id = 0;

                        if (nex_wf_detail_query != null)
                        {
                            nex_org_role = Convert.ToInt32(nex_wf_detail_query.OrgRole_Id);
                            nex_wf_detail_id = Convert.ToInt32(nex_wf_detail_query.WFD_Id);

                            var org_id = nex_org_role;
                            var date2day = DateTime.Now;
                            //DELEGATE CHECK
                            foreach (var del in _DataContext.ITP_S_TaskDelegations.Where(x => x.OrgRole_ID_Orig == nex_org_role).Where(x => x.DateFrom <= date2day).Where(x => x.DateTo >= date2day).Where(x => x.isActive == true))
                            {
                                if (del != null)
                                {
                                    org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                                }

                            }

                            if (reimActDetails != null)
                            {
                                //Insert new activity to RFP_MAIN Reimbursement

                                ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                                {
                                    new_activity.Status = 1;
                                    new_activity.AppId = 1032;
                                    new_activity.CompanyId = rfp_main.ChargedTo_CompanyId;
                                    new_activity.Document_Id = rfp_main.ID;
                                    new_activity.WF_Id = wf_detail_query.WF_Id;
                                    new_activity.DateAssigned = DateTime.Now;
                                    new_activity.DateCreated = DateTime.Now;
                                    new_activity.IsActive = true;
                                    new_activity.OrgRole_Id = org_id;
                                    new_activity.WFD_Id = nex_wf_detail_id;
                                    new_activity.AppDocTypeId = rfp_app_docType.DCT_Id;
                                }
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                            }

                            //Insert new activity to Expense

                            ITP_T_WorkflowActivity new_activity_exp = new ITP_T_WorkflowActivity();
                            {
                                new_activity_exp.Status = 1;
                                new_activity_exp.AppId = 1032;
                                new_activity_exp.CompanyId = inv_main.InvChargedTo_CompanyId;
                                new_activity_exp.Document_Id = inv_main.ID;
                                new_activity_exp.WF_Id = wf_detail_query.WF_Id;
                                new_activity_exp.DateAssigned = DateTime.Now;
                                new_activity_exp.DateCreated = DateTime.Now;
                                new_activity_exp.IsActive = true;
                                new_activity_exp.OrgRole_Id = org_id;
                                new_activity_exp.WFD_Id = nex_wf_detail_id;
                                new_activity_exp.AppDocTypeId = exp_app_doctype;
                            }
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity_exp);

                            ///////---START EMAIL PROCESS-----////////
                            foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                            {
                                var nexApprover_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == user.UserId)
                                    .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Session["UserID"].ToString())
                                    .FirstOrDefault();

                                exp.SendEmailTo(inv_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, approve_remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                            }
                        }
                        else
                        {
                            var pending_audit = _DataContext.ITP_S_Status
                                    .Where(x => x.STS_Name == "Pending at Audit")
                                    .FirstOrDefault();

                            if (rfp_main != null)
                            {
                                rfp_main.Status = Convert.ToInt32(pending_audit.STS_Id);
                            }

                            inv_main.Status = Convert.ToInt32(pending_audit.STS_Id);

                            var wfID = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.Company_Id == inv_main.InvChargedTo_CompanyId)
                                    .Where(x => x.Name == "ACDE AUDIT")
                                    .FirstOrDefault();

                            if (wfID != null)
                            {
                                var expDocType = _DataContext.ITP_S_DocumentTypes
                                    .Where(x => x.DCT_Name == "ACDE InvoiceNPO" || x.DCT_Description == "Accede Invoice Non-PO")
                                    .Select(x => x.DCT_Id)
                                    .FirstOrDefault();

                                // GET WORKFLOW DETAILS ID
                                var wfDetails2 = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                where wfd.WF_Id == wfID.WF_Id && wfd.Sequence == 1
                                                select wfd.WFD_Id;
                                int wfdID = wfDetails2.FirstOrDefault();

                                // GET ORG ROLE ID
                                var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                              where or.WF_Id == wfID.WF_Id && or.Sequence == 1
                                              select or.OrgRole_Id;
                                int orID = (int)orgRole.FirstOrDefault();

                                //INSERT EXPENSE TO ITP_T_WorkflowActivity
                                DateTime currentDate = DateTime.Now;
                                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                {
                                    Status = pending_audit.STS_Id,
                                    DateAssigned = currentDate,
                                    WF_Id = wfID.WF_Id,
                                    WFD_Id = wfdID,
                                    OrgRole_Id = orID,
                                    Document_Id = Convert.ToInt32(inv_main.ID),
                                    AppId = 1032,
                                    Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";",
                                    CompanyId = Convert.ToInt32(inv_main.InvChargedTo_CompanyId),
                                    AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE InvoiceNPO" || x.DCT_Description == "Accede Invoice Non-PO").Select(x => x.DCT_Id).FirstOrDefault(),
                                    IsActive = true,
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                                if (rfp_main != null)
                                {
                                    //Insert reimburse activity to ITP_T_WorkflowActivity
                                    ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                                    {
                                        Status = pending_audit.STS_Id,
                                        DateAssigned = currentDate,
                                        WF_Id = wfID.WF_Id,
                                        WFD_Id = wfdID,
                                        OrgRole_Id = orID,
                                        Document_Id = Convert.ToInt32(rfp_main.ID),
                                        AppId = 1032,
                                        Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";",
                                        CompanyId = Convert.ToInt32(inv_main.InvChargedTo_CompanyId),
                                        AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                                        IsActive = true,
                                    };
                                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);
                                }

                            }
                            else
                            {
                                return "There is no workflow (ACDE AUDIT) setup for your company. Please contact Admin to setup the workflow.";
                            }

                            var creator_detail = _DataContext.ITP_S_UserMasters
                                .Where(x => x.EmpCode == inv_main.UserId)
                                .FirstOrDefault();

                            var sender_detail = _DataContext.ITP_S_UserMasters
                                .Where(x => x.EmpCode == Session["UserID"].ToString())
                                .FirstOrDefault();

                            exp.SendEmailTo(inv_main.ID, creator_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, approve_remarks, "Approve", payMethod.ToString(), tranType.ToString(), "PendingAudit");

                        }

                        _DataContext.SubmitChanges();

                        return "success";
                    }
                    else
                    {
                        return "Secure token is null.";
                    }
                }
                catch (Exception ex)
                {

                    return ex.Message;
                }
            }
                
        }

        [WebMethod]
        public static string btnReturnClickAjax(string return_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType, string sapDoc)
        {
            AccedeNonPO_P2PView page = new AccedeNonPO_P2PView();
            return page.btnReturnClick(return_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType, sapDoc);
        }

        public string btnReturnClick(string return_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType, string sapDoc)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));
                    var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                    .Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id))
                    .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                                    .Where(x => x.IsExpenseReim != true)
                                    .Where(x => x.IsExpenseCA != true)
                                    .Where(x => x.Status != 4)
                                    .Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id))
                                    .Where(x => x.isTravel != true)
                                    .FirstOrDefault();

                    //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                    var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                        .Where(x => x.ExpenseType_ID == inv_main.InvoiceType_ID)
                        .FirstOrDefault();

                    var returned_p2p = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by P2P")
                        .FirstOrDefault();

                    if (returned_p2p != null)
                    {
                        inv_main.InvChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        inv_main.InvChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        inv_main.CostCenter = costCenter;
                        inv_main.Status = returned_p2p.STS_Id;

                        if (rfp_main != null)
                        {

                            rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                            rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                            rfp_main.SAPCostCenter = costCenter;
                            rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);

                            rfp_main.Status = returned_p2p.STS_Id;
                            rfp_main.SAPDocNo = sapDoc;
                        }

                        var rfpDocType = _DataContext.ITP_S_DocumentTypes
                            .Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment")
                            .Select(x => x.DCT_Id)
                            .FirstOrDefault();

                        var wfDetail_reim = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.Document_Id == rfp_main.ID)
                                .Where(x => x.Status == wfDetails.Status)
                                .Where(x => x.AppDocTypeId == rfpDocType)
                                .FirstOrDefault();

                        if (wfDetail_reim != null)
                        {
                            //UPDATE ACTIVITY REIM
                            wfDetail_reim.Status = returned_p2p.STS_Id;
                            wfDetail_reim.DateAction = DateTime.Now;
                            wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ": " + return_remarks + ";";
                            wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        var wfID = _DataContext.ITP_S_WorkflowHeaders
                            .Where(x => x.Company_Id == inv_main.CompanyId)
                            .Where(x => x.Name == "ACDE P2P")
                            .FirstOrDefault();

                        //UPDATE WF ACTIVITY EXPENSE
                        wfDetails.Status = returned_p2p.STS_Id;
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": " + return_remarks + ";";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                    }

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == inv_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    exp.SendEmailTo(inv_main.ID, creator_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, return_remarks, "Return", "", tranType.Description, "");
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

        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsEditAJAX(int expDetailID)
        {
            AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
            return exp.DisplayExpDetailsEdit(expDetailID);

        }

        public InvDetailsNonPO DisplayExpDetailsEdit(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_InvoiceLineDetails
                .Where(x => x.ID == expDetailID)
                .FirstOrDefault();

            var exp_detailsMap = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.Where(x => x.InvoiceReportDetail_ID == expDetailID);
            decimal totalAmnt = 0;

            foreach (var item in exp_detailsMap)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }

            totalAmnt = Convert.ToDecimal(exp_details.TotalAmount) - totalAmnt;

            InvDetailsNonPO exp_det_class = new InvDetailsNonPO();

            if (exp_details != null)
            {
                exp_det_class.dateAdded = Convert.ToDateTime(exp_details.DateAdded).ToString("MM/dd/yyyy hh:mm:ss");

                //exp_det_class.supplier = exp_details.Supplier ?? exp_det_class.supplier;
                exp_det_class.particulars = exp_details.Particulars?.ToString() ?? exp_det_class.particulars;
                exp_det_class.acctCharge = exp_details.AcctToCharged ?? exp_det_class.acctCharge;
                //exp_det_class.tin = exp_details.TIN ?? exp_det_class.tin;
                exp_det_class.InvoiceOR = exp_details.InvoiceNo ?? exp_det_class.InvoiceOR;
                //exp_det_class.costCenter = exp_details.CostCenterIOWBS ?? exp_det_class.costCenter;
                exp_det_class.grossAmnt = exp_details.TotalAmount != null ? Convert.ToDecimal(exp_details.TotalAmount) : exp_det_class.grossAmnt;
                //exp_det_class.vat = exp_details.VAT != null ? Convert.ToDecimal(exp_details.VAT) : exp_det_class.vat;
                //exp_det_class.ewt = exp_details.EWT != null ? Convert.ToDecimal(exp_details.EWT) : exp_det_class.ewt;
                exp_det_class.netAmnt = exp_details.NetAmount != null ? Convert.ToDecimal(exp_details.NetAmount) : exp_det_class.netAmnt;
                exp_det_class.expMainId = exp_details.InvMain_ID != null ? Convert.ToInt32(exp_details.InvMain_ID) : exp_det_class.expMainId;
                exp_det_class.preparerId = exp_details.Preparer_ID ?? exp_det_class.preparerId;
                //exp_det_class.io = exp_details.ExpDtl_IO ?? exp_det_class.io;
                exp_det_class.LineDesc = exp_details.LineDescription ?? exp_det_class.LineDesc;
                //exp_det_class.wbs = exp_details.ExpDtl_WBS ?? exp_det_class.wbs;

                //var exp_details_nonpo = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(exp_details.ExpenseReportDetail_ID)).FirstOrDefault();
                //exp_det_class.Assignment = exp_details_nonpo.Assignment ?? exp_det_class.Assignment;
                //exp_det_class.UserId = exp_details_nonpo.UserId ?? exp_det_class.UserId;
                //exp_det_class.Allowance = exp_details_nonpo.Allowance ?? exp_det_class.Allowance;
                //exp_det_class.SLCode = exp_details_nonpo.SLCode ?? exp_det_class.SLCode;
                //exp_det_class.EWTTaxType_Id = exp_details_nonpo.EWTTaxType_Id != null ? Convert.ToInt32(exp_details_nonpo.EWTTaxType_Id) : exp_det_class.EWTTaxType_Id;
                //exp_det_class.EWTTaxAmount = exp_details_nonpo.EWTTaxAmount != null ? Convert.ToDecimal(exp_details_nonpo.EWTTaxAmount) : exp_det_class.EWTTaxAmount;
                exp_det_class.EWTTaxCode = exp_details.EWTTaxType_Id ?? exp_det_class.EWTTaxCode;
                exp_det_class.InvoiceTaxCode = exp_details.InvoiceTaxCode ?? exp_det_class.InvoiceTaxCode;
                //exp_det_class.Asset = exp_details_nonpo.Asset ?? exp_det_class.Asset;
                //exp_det_class.SubAssetCode = exp_details_nonpo.SubAssetCode ?? exp_det_class.SubAssetCode;
                //exp_det_class.TransactionType = exp_details_nonpo.TransactionType ?? exp_det_class.TransactionType;
                //exp_det_class.AltRecon = exp_details_nonpo.AltRecon ?? exp_det_class.AltRecon;
                //exp_det_class.SpecialGL = exp_details_nonpo.SpecialGL ?? exp_det_class.SpecialGL;
                exp_det_class.Qty = exp_details.Qty ?? exp_det_class.Qty;
                exp_det_class.UnitPrice = exp_details.UnitPrice ?? exp_det_class.UnitPrice;
                exp_det_class.uom = exp_details.UOM ?? exp_det_class.uom;
                exp_det_class.ewt = exp_details.EWT ?? exp_det_class.ewt;
                exp_det_class.vat = exp_details.VAT ?? exp_det_class.vat;
                exp_det_class.ewtperc = exp_details.EWTPerc ?? exp_det_class.ewtperc;
                exp_det_class.netvat = exp_details.NOVAT ?? exp_det_class.netvat;
                exp_det_class.isVatCompute = exp_details.isVatComputed ?? exp_det_class.isVatCompute;

                exp_det_class.totalAllocAmnt = totalAmnt;

                Session["InvDetailsID"] = expDetailID.ToString();

            }

            return exp_det_class;
        }

        [WebMethod]
        public static string SaveExpDetailsAJAX(
            string dateAdd,
            //string tin_no, 
            string invoice_no,
            //string cost_center,
            string gross_amount,
            string net_amount,
            //string supp, 
            string particu,
            string acctCharge,
            //string vat_amnt, 
            //string ewt_amnt, 
            string currency,
            //string io, 
            //string wbs,
            string remarks,
            string EWTTAmount,
            string assign,
            string allowance,
            string EWTTType,
            string EWTTCode,
            string InvTCode,
            string qty,
            string unit_price,
            string asset,
            string subasset,
            string altRecon,
            string SLCode,
            string SpecialGL,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            AccedeNonPO_P2PView exp = new AccedeNonPO_P2PView();
            return exp.SaveExpDetails(
                dateAdd,
                //tin_no, 
                invoice_no,
                //cost_center,
                gross_amount,
                net_amount,
                //supp, 
                particu,
                acctCharge,
                //vat_amnt, 
                //ewt_amnt, 
                currency,
                // io, 
                // wbs, 
                remarks,
                EWTTAmount,
                assign,
                allowance,
                EWTTType,
                EWTTCode,
                InvTCode,
                qty,
                unit_price,
                asset,
                subasset,
                altRecon,
                SLCode,
                SpecialGL,
                uom,
                ewt,
                vat,
                ewtperc,
                netvat,
                isVatCompute);
        }

        public string SaveExpDetails(
            string dateAdd,
            //string tin_no, 
            string invoice_no,
            //string cost_center,
            string gross_amount,
            string net_amount,
            //string supp, 
            string particu,
            string acctCharge,
            //string vat_amnt, 
            //string ewt_amnt, 
            string currency,
            //string io, 
            //string wbs,
            string remarks,
            string EWTTAmount,
            string assign,
            string allowance,
            string EWTTType,
            string EWTTCode,
            string InvTCode,
            string qty,
            string unit_price,
            string asset,
            string subasset,
            string altRecon,
            string SLCode,
            string SpecialGL,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            try
            {
                decimal totalNetAmnt = new decimal(0.00);
                var invDtlMap = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Where(x => x.InvoiceReportDetail_ID == Convert.ToInt32(Session["InvDetailsID"]));

                var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.ID == Convert.ToInt32(Session["InvDetailsID"]))
                        .FirstOrDefault();

                foreach (var item in invDtlMap)
                {
                    totalNetAmnt += Convert.ToDecimal(item.NetAmount);
                }

                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if (totalNetAmnt < gross && invDtlMap.Count() > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + ". Please check the allocation amounts.";
                    return error;
                }
                else
                {
                    

                    if (expDetail != null)
                    {
                        expDetail.DateAdded = Convert.ToDateTime(dateAdd);
                        //expDetail.TIN = string.IsNullOrEmpty(tin_no) ? (string)null : tin_no;
                        expDetail.InvoiceNo = string.IsNullOrEmpty(invoice_no) ? (string)null : invoice_no;
                        //expDetail.CostCenterIOWBS = cost_center;
                        expDetail.TotalAmount = Convert.ToDecimal(gross_amount);
                        expDetail.NetAmount = Convert.ToDecimal(net_amount);
                        //expDetail.Supplier = string.IsNullOrEmpty(supp) ? (string)null : supp;
                        expDetail.Particulars = Convert.ToInt32(particu);
                        //expDetail.AcctToCharged = Convert.ToInt32(acctCharge);
                        //expDetail.VAT = Convert.ToDecimal(vat_amnt);
                        //expDetail.EWT = Convert.ToDecimal(ewt_amnt);
                        //expDetail.ExpDtl_Currency = currency;
                        //expDetail.ExpDtl_IO = string.IsNullOrEmpty(io) ? (string)null : io;
                        //expDetail.ExpDtl_WBS = string.IsNullOrEmpty(wbs) ? (string)null : wbs;
                        expDetail.LineDescription = remarks;
                        expDetail.Qty = Convert.ToDecimal(qty);
                        expDetail.UnitPrice = Convert.ToDecimal(unit_price);
                        expDetail.EWTTaxType_Id = EWTTType;
                        expDetail.InvoiceTaxCode = InvTCode;
                        expDetail.EWT = Convert.ToDecimal(ewt);
                        expDetail.VAT = Convert.ToDecimal(vat);
                        expDetail.UOM = uom;
                        expDetail.EWTPerc = Convert.ToDecimal(ewtperc);
                        expDetail.NOVAT = Convert.ToDecimal(netvat);
                        expDetail.isVatComputed = Convert.ToBoolean(isVatCompute);
                    }

                    //var expDetailNonPO = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(Session["ExpDetailsID"])).FirstOrDefault();
                    //if(expDetailNonPO != null)
                    //{
                    //    expDetailNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
                    //    expDetailNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
                    //    expDetailNonPO.EWTTaxCode = EWTTCode;
                    //    expDetailNonPO.InvoiceTaxCode = InvTCode;
                    //    expDetailNonPO.Asset = asset;
                    //    expDetailNonPO.SubAssetCode = subasset;
                    //    expDetailNonPO.AltRecon = altRecon;
                    //    expDetailNonPO.SLCode = SLCode;
                    //    expDetailNonPO.SpecialGL = SpecialGL;
                    //}
                    //else
                    //{
                    //    ACCEDE_T_ExpenseDetailsInvNonPO expNonPO = new ACCEDE_T_ExpenseDetailsInvNonPO();
                    //    {
                    //        expNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
                    //        expNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
                    //        expNonPO.EWTTaxCode = EWTTCode;
                    //        expNonPO.InvoiceTaxCode = InvTCode;
                    //        expNonPO.Asset = asset;
                    //        expNonPO.SubAssetCode = subasset;
                    //        expNonPO.AltRecon = altRecon;
                    //        expNonPO.SLCode = SLCode;
                    //        expNonPO.SpecialGL = SpecialGL;
                    //    }

                    //    _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.InsertOnSubmit(expNonPO);

                    //}


                }

                _DataContext.SubmitChanges();

                var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(expDetail.InvMain_ID))
                    .Where(x => x.isTravel != true)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true)
                    .FirstOrDefault();

                //var rfpReim = _DataContext.ACCEDE_T_RFPMains
                //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                //    .Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true)
                //    .Where(x => x.isTravel != true)
                //    .FirstOrDefault();

                var expDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == Convert.ToInt32(expDetail.InvMain_ID));

                //decimal totalReim = new decimal(0);
                //decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                //foreach (var ca in rfpCA)
                //{
                //    totalCA += Convert.ToDecimal(ca.Amount);
                //}

                foreach (var exp in expDetails)
                {
                    totalExpense += Convert.ToDecimal(exp.NetAmount);
                }

                if (totalExpense > 0 && ptvRFP != null)
                {
                    ptvRFP.Amount = totalExpense;
                }
                else
                {
                    if (ptvRFP != null)
                    {
                        ptvRFP.Amount = totalExpense;
                        ptvRFP.Status = 4;
                    }

                }


                //totalReim = totalCA - totalExpense;
                //if (totalReim < 0)
                //{
                //    if (rfpReim != null)
                //    {
                //        rfpReim.Amount = Math.Abs(totalReim);
                //    }
                //}
                //else
                //{
                //    if (rfpReim != null)
                //    {
                //        rfpReim.Status = 4;
                //    }

                //}

                _DataContext.SubmitChanges();
                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            AccedeNonPO_P2PView exp = new AccedeNonPO_P2PView();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public bool RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.RFP_DocNum == rfpDoc)
                    .FirstOrDefault();

                if (rfp != null)
                {
                    Session["passRFPID"] = rfp.ID;
                }
                return true;
            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeNonPO_P2PView exp = new AccedeNonPO_P2PView();
            return exp.DisplayExpDetails(expDetailID);
        }

        public InvDetailsNonPO DisplayExpDetails(int invDetailID)
        {
            var invDetails = _DataContext.ACCEDE_T_InvoiceLineDetails.FirstOrDefault(x => x.ID == invDetailID);
            if (invDetails == null) return new InvDetailsNonPO();

            var particularsName = _DataContext.ACCEDE_S_Particulars
                .Where(x => x.ID == invDetails.Particulars)
                .Select(x => x.P_Name)
                .FirstOrDefault();

            decimal allocated = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(x => x.InvoiceReportDetail_ID == invDetailID)
                .Select(x => (decimal?)x.NetAmount).Sum() ?? 0m;

            decimal remaining = (invDetails.TotalAmount ?? 0m) - allocated;

            var ewttarget = invDetails.EWTTaxType_Id?.Trim();

            var ewtlist = SAPDataProvider.GetEWT();

            // Primary match: by code (case-insensitive, trimmed)
            var ewtmatch = ewtlist.FirstOrDefault(x =>
                string.Equals(x.EWTCODE?.Trim(), ewttarget, StringComparison.OrdinalIgnoreCase));

            // Optional fallback: try description if code not found
            if (ewtmatch == null)
            {
                ewtmatch = ewtlist.FirstOrDefault(x =>
                    string.Equals(x.EWTDESC?.Trim(), ewttarget, StringComparison.OrdinalIgnoreCase));
            }

            var vattarget = invDetails.InvoiceTaxCode?.Trim();

            var vatlist = SAPDataProvider.GetVAT();

            // Primary match: by code (case-insensitive, trimmed)
            var vatmatch = vatlist.FirstOrDefault(x =>
                string.Equals(x.VATCODE?.Trim(), vattarget, StringComparison.OrdinalIgnoreCase));

            // Optional fallback: try description if code not found
            if (vatmatch == null)
            {
                vatmatch = vatlist.FirstOrDefault(x =>
                    string.Equals(x.VATDESC?.Trim(), vattarget, StringComparison.OrdinalIgnoreCase));
            }

            var dto = new InvDetailsNonPO
            {
                dateAdded = invDetails.DateAdded.HasValue ? invDetails.DateAdded.Value.ToString("MM/dd/yyyy hh:mm:ss") : "",
                particulars = particularsName ?? "",
                acctCharge = Convert.ToInt32(invDetails.AcctToCharged),
                InvoiceOR = invDetails.InvoiceNo ?? "",
                grossAmnt = invDetails.TotalAmount ?? 0m,
                netAmnt = invDetails.NetAmount ?? 0m,
                expMainId = invDetails.InvMain_ID ?? 0,
                preparerId = invDetails.Preparer_ID ?? "",
                LineDesc = invDetails.LineDescription ?? "",
                Qty = invDetails.Qty ?? 0m,
                UnitPrice = invDetails.UnitPrice ?? 0m,
                uom = invDetails.UOM ?? "",
                EWTTaxType_Id = ewtmatch?.EWTDESC,
                InvoiceTaxCode = vatmatch?.VATDESC,
                ewt = invDetails.EWT ?? 0m,
                vat = invDetails.VAT ?? 0m,
                ewtperc = invDetails.EWTPerc ?? 0m,
                netvat = invDetails.NOVAT ?? 0m,
                isVatCompute = invDetails.isVatComputed ?? false,
                totalAllocAmnt = remaining
            };

            Session["InvDetailsID"] = invDetailID.ToString();
            return dto;
        }

        protected void ExpAllocGrid_edit_BatchUpdate(object sender, DevExpress.Web.Data.ASPxDataBatchUpdateEventArgs e)
        {
            var grid = (ASPxGridView)sender;

            if (Session["InvDetailsID"] == null)
            {
                e.Handled = true;
                return;
            }

            int detailId = Convert.ToInt32(Session["InvDetailsID"]);

            // Base total before applying this batch
            decimal baseTotal = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(m => m.InvoiceReportDetail_ID == detailId)
                .Sum(m => (decimal?)m.NetAmount) ?? 0m;

            decimal delta = 0m;

            // Updates
            foreach (var upd in e.UpdateValues)
            {
                decimal oldNet = Convert.ToDecimal(upd.OldValues["NetAmount"] ?? 0m);
                decimal newNet = Convert.ToDecimal(upd.NewValues["NetAmount"] ?? 0m);
                delta += (newNet - oldNet);
            }

            // Inserts
            foreach (var ins in e.InsertValues)
            {
                decimal newNet = Convert.ToDecimal(ins.NewValues["NetAmount"] ?? 0m);
                delta += newNet;
            }

            // Deletes
            foreach (var del in e.DeleteValues)
            {
                // Fix: Use `Values` instead of `OldValues` for delete operations
                decimal oldNet = Convert.ToDecimal(del.Values["NetAmount"] ?? 0m);
                delta -= oldNet;
            }

            decimal finalTotal = baseTotal + delta;

            decimal maxAllowed = 0m;
            if (decimal.TryParse(total_edit.Value?.ToString(), out var tmp))
                maxAllowed = tmp;

            if (maxAllowed > 0 && finalTotal > maxAllowed)
            {
                grid.JSProperties["cpAllocationExceeded"] = true;
                //grid.JSProperties["cpComputeUnalloc_edit"] = finalTotal;
                e.Handled = true; // Abort persistence

                SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = detailId.ToString();

                // 🔑 Rebind your data (otherwise grid will show "no data to display")
                grid.DataSourceID = null;
                grid.DataSource = SqlExpMap;
                grid.DataBind();

                return;
            }

            // Persist updates
            foreach (var upd in e.UpdateValues)
            {
                int key = Convert.ToInt32(upd.Keys["InvoiceDetailMap_ID"]);
                var entity = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Single(m => m.InvoiceDetailMap_ID == key);

                entity.NetAmount = Convert.ToDecimal(upd.NewValues["NetAmount"] ?? 0m);
                if (upd.NewValues.Contains("Remarks"))
                    entity.EDM_Remarks = upd.NewValues["Remarks"]?.ToString();
                if (upd.NewValues.Contains("CostCenterIOWBS"))
                    entity.CostCenterIOWBS = upd.NewValues["CostCenterIOWBS"]?.ToString();
            }

            // Persist inserts
            foreach (var ins in e.InsertValues)
            {
                var map = new ACCEDE_T_InvoiceLineDetailsMap
                {
                    InvoiceReportDetail_ID = detailId,
                    NetAmount = Convert.ToDecimal(ins.NewValues["NetAmount"] ?? 0m),
                    CostCenterIOWBS = (ins.NewValues.Contains("CostCenterIOWBS")
                                      ? ins.NewValues["CostCenterIOWBS"]?.ToString()
                                      : ins.NewValues.Contains("CostCenter")
                                        ? ins.NewValues["CostCenter"]?.ToString()
                                        : null),
                    EDM_Remarks = ins.NewValues["Remarks"]?.ToString(),
                    Preparer_ID = Session["userID"]?.ToString()
                };
                _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.InsertOnSubmit(map);
            }

            // Persist deletes
            foreach (var del in e.DeleteValues)
            {
                int key = Convert.ToInt32(del.Keys["InvoiceDetailMap_ID"]);
                var entity = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Single(m => m.InvoiceDetailMap_ID == key);
                _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.DeleteOnSubmit(entity);
            }

            _DataContext.SubmitChanges();

            SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = detailId.ToString();

            // 🔑 Rebind your data (otherwise grid will show "no data to display")
            grid.DataSourceID = null;
            grid.DataSource = SqlExpMap;
            grid.DataBind();

            grid.JSProperties["cpComputeUnalloc_edit"] = finalTotal;
            e.Handled = true; // We applied everything manually
        
        }
    }
}