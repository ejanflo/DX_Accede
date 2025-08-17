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
    public partial class AccedeNonPO_AuditView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        decimal dueComp = new decimal(0.00);
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

                            Session["ExpId"] = actDetails.Document_Id;
                            sqlMain.SelectParameters["ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlCADetails.SelectParameters["Exp_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = actDetails.Document_Id.ToString();

                            var exp = _DataContext.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id))
                                .FirstOrDefault();

                            var vendor = _DataContext.ACCEDE_S_Vendors.Where(x => x.VendorCode == exp.ExpenseName.ToString().Trim()).FirstOrDefault();
                            if (vendor != null)
                            {
                                txt_vendor.Text = vendor.VendorName.ToString();
                            }

                            SqlIO.SelectParameters["CompanyId"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();

                            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();
                            SqlCompany.SelectParameters["WASSId"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();
                            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();

                            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = Convert.ToInt32(exp.ExpChargedTo_CompanyId).ToString();

                            var expType = _DataContext.ACCEDE_S_ExpenseTypes
                                .Where(x => x.ExpenseType_ID == Convert.ToInt32(exp.ExpenseType_ID))
                                .FirstOrDefault();

                            txt_ExpType.Text = expType.Description;

                            txt_ReportDate.Text = Convert.ToDateTime(exp.ReportDate).ToString("MMMM dd, yyyy");
                            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;

                            if (myLayoutGroup != null)
                            {
                                myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";
                            }

                            var RFPCA = _DataContext.ACCEDE_T_RFPMains
                                .Where(x => x.Exp_ID == Convert.ToInt32(actDetails.Document_Id))
                                .Where(x => x.isTravel != true)
                                .Where(x => x.IsExpenseCA == true);

                            var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                                .Where(x => x.ExpenseMain_ID == Convert.ToInt32(actDetails.Document_Id));

                            decimal totalExp = 0;
                            foreach (var item in ExpDetails)
                            {
                                totalExp += Convert.ToDecimal(item.NetAmount);
                            }
                            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + exp.Exp_Currency + " ";

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

                            //APPROVE AND FORWARD BUTTON AND GENERATE AAF WF
                            //var wfDetails = _DataContext.ITP_S_WorkflowDetails
                            //    .Where(x => x.WF_Id == actDetails.WF_Id)
                            //    .Where(x => x.WFD_Id == actDetails.WFD_Id)
                            //    .FirstOrDefault();

                            //if (wfDetails != null)
                            //{
                            //    var nxWFDetails = _DataContext.ITP_S_WorkflowDetails
                            //    .Where(x => x.WF_Id == actDetails.WF_Id)
                            //    .Where(x => x.Sequence == (Convert.ToInt32(wfDetails.Sequence) + 1))
                            //    .FirstOrDefault();


                            //    var if_WF_isRA = _DataContext.ITP_S_WorkflowHeaders
                            //        .Where(x => x.WF_Id == wfDetails.WF_Id)
                            //        .FirstOrDefault();


                            //    var aaf = FormExpApprovalView.FindItemOrGroupByName("AAF") as LayoutItem;

                            //    if (nxWFDetails == null && if_WF_isRA.IsRA != true)
                            //    {
                            //        aaf.ClientVisible = true;
                            //    }

                            //}

                        }
                        else
                        {
                            Response.Redirect("~/AllAccedeApprovalPage.aspx");
                        }
                    }

                }
                else
                {
                    Response.Redirect("~/Logon.aspx");
                }

            }
            catch (Exception)
            {
                if (!IsPostBack)
                {
                    Response.Redirect("~/Logon.aspx");
                }
                //Response.Redirect("~/AllAccedeApprovalPage.aspx");
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

                var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id)).FirstOrDefault();

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
                        .Where(x => x.DCT_Name == "ACDE Expense")
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
                        docs.Company_ID = Convert.ToInt32(expMain.ExpChargedTo_CompanyId);
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
            Session["ExpDetailsID"] = null;

            DocuGrid_edit.DataSourceID = null;
            DocuGrid_edit.DataSource = SqlExpDetailAttach;
            DocuGrid_edit.DataBind();
        }

        protected void ExpAllocGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            //decimal totalAmnt = new decimal(0.00);
            int deletedRowIndex = Convert.ToInt32(e.Keys[ExpAllocGrid_edit.KeyFieldName].ToString());
            var expAllocs = _DataContext.ACCEDE_T_ExpenseDetailsMaps
                .Where(x => x.ExpenseDetailMap_ID == Convert.ToInt32(deletedRowIndex))
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
            var expAllocs = _DataContext.ACCEDE_T_ExpenseDetailsMaps
                .Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));

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
                e.NewValues["ExpenseReportDetail_ID"] = Convert.ToInt32(Session["ExpDetailsID"]);
                e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);

                grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;
            }
        }

        protected void ExpAllocGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            decimal totalNetAmount = 0;
            var RowIndex = e.NewValues["ExpenseDetailMap_ID"].ToString();
            var newAmnt = e.NewValues["NetAmount"].ToString();
            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");
                object ID_Obj = ExpAllocGrid_edit.GetRowValues(i, "ExpenseDetailMap_ID");

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
                    docsMap.ExpDetail_Id = Convert.ToInt32(Session["ExpDetailsID"]);
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
        public static string btnApproveClickAjax(string approve_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            AccedeNonPO_AuditView page = new AccedeNonPO_AuditView();
            return page.btnApproveClick(approve_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType);
        }

        public string btnApproveClick(string approve_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();

                    AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();

                    var payMethod = "";
                    var tranType = "";

                    exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    exp_main.CostCenter = costCenter;
                    exp_main.Exp_Currency = curr;
                    exp_main.PaymentType = Convert.ToInt32(payType);

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
                    .Where(x => x.Status == 1)
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
                            new_activity_exp.CompanyId = exp_main.ExpChargedTo_CompanyId;
                            new_activity_exp.Document_Id = exp_main.ID;
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

                            exp.SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, approve_remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                        }
                    }
                    else
                    {
                        var pending_cashier = _DataContext.ITP_S_Status
                                .Where(x => x.STS_Name == "Pending at Cashier")
                                .FirstOrDefault();

                        if (rfp_main != null)
                        {
                            rfp_main.Status = Convert.ToInt32(pending_cashier.STS_Id);
                        }

                        exp_main.Status = Convert.ToInt32(pending_cashier.STS_Id);

                        var wfID = _DataContext.ITP_S_WorkflowHeaders
                                .Where(x => x.Company_Id == exp_main.ExpChargedTo_CompanyId)
                                .Where(x => x.Name == "ACDE CASHIER")
                                .FirstOrDefault();

                        if (wfID != null)
                        {
                            var expDocType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
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
                                Status = pending_cashier.STS_Id,
                                DateAssigned = currentDate,
                                WF_Id = wfID.WF_Id,
                                WFD_Id = wfdID,
                                OrgRole_Id = orID,
                                Document_Id = Convert.ToInt32(exp_main.ID),
                                AppId = 1032,
                                Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";",
                                CompanyId = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId),
                                AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                                IsActive = true,
                            };
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                            if (rfp_main != null)
                            {
                                //Insert reimburse activity to ITP_T_WorkflowActivity
                                ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                                {
                                    Status = pending_cashier.STS_Id,
                                    DateAssigned = currentDate,
                                    WF_Id = wfID.WF_Id,
                                    WFD_Id = wfdID,
                                    OrgRole_Id = orID,
                                    Document_Id = Convert.ToInt32(rfp_main.ID),
                                    AppId = 1032,
                                    Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";",
                                    CompanyId = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId),
                                    AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                                    IsActive = true,
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);
                            }

                        }
                        else
                        {
                            return "There is no workflow (ACDE CASHIER) setup for your company. Please contact Admin to setup the workflow.";
                        }

                        var creator_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == exp_main.UserId)
                            .FirstOrDefault();

                        var sender_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == Session["UserID"].ToString())
                            .FirstOrDefault();

                        exp.SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, approve_remarks, "Approve", payMethod.ToString(), tranType.ToString(), "PendingAudit");

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

        [WebMethod]
        public static string btnReturnClickAjax(string return_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            AccedeNonPO_AuditView page = new AccedeNonPO_AuditView();
            return page.btnReturnClick(return_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType);
        }

        public string btnReturnClick(string return_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));
                    var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
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
                        .Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID)
                        .FirstOrDefault();

                    var returned_audit = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by Audit")
                        .FirstOrDefault();

                    if (returned_audit != null)
                    {
                        exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        exp_main.ExpenseClassification = Convert.ToInt32(ClassType);
                        exp_main.CostCenter = costCenter;
                        exp_main.Status = returned_audit.STS_Id;

                        if (rfp_main != null)
                        {

                            rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                            rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                            rfp_main.SAPCostCenter = costCenter;
                            rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);

                            rfp_main.Status = returned_audit.STS_Id;
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
                            //UPDATE ACTIVITY RFP
                            wfDetail_reim.Status = returned_audit.STS_Id;
                            wfDetail_reim.DateAction = DateTime.Now;
                            wfDetail_reim.Remarks = Session["AuthUser"].ToString() + ": " + return_remarks + ";";
                            wfDetail_reim.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        var wfID = _DataContext.ITP_S_WorkflowHeaders
                            .Where(x => x.Company_Id == exp_main.CompanyId)
                            .Where(x => x.Name == "ACDE AUDIT")
                            .FirstOrDefault();

                        //UPDATE WF ACTIVITY EXPENSE
                        wfDetails.Status = returned_audit.STS_Id;
                        wfDetails.DateAction = DateTime.Now;
                        wfDetails.Remarks = Session["AuthUser"].ToString() + ": " + return_remarks + ";";
                        wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                    }

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == exp_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    exp.SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, return_remarks, "Return", "", tranType.Description, "");
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
    }
}