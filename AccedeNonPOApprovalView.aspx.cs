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
using static DX_WebTemplate.AccedeModels;
using static DX_WebTemplate.AccedeNonPOEditPage;

namespace DX_WebTemplate
{
    public partial class AccedeNonPOApprovalView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        decimal dueComp = new decimal(0.00);

        protected void Page_Load(object sender, EventArgs e)
        {
            // Run initialization only once
            if (IsPostBack) return;

            try
            {
                if (!AnfloSession.Current.ValidCookieUser())
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                string encryptedID = Request.QueryString["secureToken"];
                if (string.IsNullOrWhiteSpace(encryptedID))
                {
                    Response.Redirect("~/AllAccedeApprovalPage.aspx");
                    return;
                }

                if (!TryDecryptId(encryptedID, out int actID))
                {
                    Response.Redirect("~/AllAccedeApprovalPage.aspx");
                    return;
                }

                var empCode = Session["userID"] as string;
                if (string.IsNullOrEmpty(empCode))
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                // Get activity & invoice
                var actDetails = _DataContext.ITP_T_WorkflowActivities.FirstOrDefault(x => x.WFA_Id == actID);
                if (actDetails == null)
                {
                    Response.Redirect("~/AllAccedeApprovalPage.aspx");
                    return;
                }

                var inv = _DataContext.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == actDetails.Document_Id);
                if (inv == null)
                {
                    Response.Redirect("~/AllAccedeApprovalPage.aspx");
                    return;
                }

                // Load doc type (Invoice Non-PO)
                var invoiceDocType = _DataContext.ITP_S_DocumentTypes
                    .FirstOrDefault(x => x.DCT_Name == "ACDE InvoiceNPO" && x.App_Id == 1032);

                // Set core datasource parameters + session
                InitializeSqlParameters(actDetails, inv, invoiceDocType);
                Session["ExpId"] = actDetails.Document_Id;

                // Vendor (attempt direct fetch)
                //PopulateVendor(inv);

                // Header/basic display setup
                PopulateHeaderInfo(inv);

                // Finance layout visibility
                ConfigureFinanceVisibility(empCode, actDetails, inv);

                // Expense type
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.FirstOrDefault(x => x.ExpenseType_ID == inv.InvoiceType_ID);
                if (expType != null)
                    txt_ExpType.Text = expType.Description;

                // Caption
                var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                if (myLayoutGroup != null)
                    myLayoutGroup.Caption = "Invoice Document -" + inv.DocNo + " (View)";

                // Totals
                ComputeTotals(inv, actDetails);

                // RFP / reimbursement related visibility
                SetupRFPRelated(inv, actDetails);

                // Forward workflow dropdowns / AAF
                SetupForwardWorkflow(empCode, actDetails, inv);
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        #region Helper Methods (Page_Load Optimization)

        private bool TryDecryptId(string encrypted, out int id)
        {
            id = 0;
            try
            {
                var raw = Decrypt(encrypted);
                return int.TryParse(raw, out id);
            }
            catch
            {
                return false;
            }
        }

        private void InitializeSqlParameters(ITP_T_WorkflowActivity act, ACCEDE_T_InvoiceMain inv, ITP_S_DocumentType invoiceDocType)
        {
            SetSelectParameter(sqlMain, "ID", act.Document_Id);
            SetSelectParameter(SqlDocs, "Doc_ID", act.Document_Id);
            SetSelectParameter(SqlDocs, "DocType_Id", invoiceDocType?.DCT_Id);
            SetSelectParameter(SqlCADetails, "Exp_ID", act.Document_Id);
            SetSelectParameter(SqlReimDetails, "Exp_ID", act.Document_Id);
            SetSelectParameter(SqlExpDetails, "InvMain_ID", act.Document_Id);
            SetSelectParameter(SqlWFActivity, "Document_Id", act.Document_Id);
            SetSelectParameter(SqlIO, "CompanyId", inv.InvChargedTo_CompanyId);
            SetSelectParameter(SqlCTDepartment, "Company_ID", inv.InvChargedTo_CompanyId);
            SetSelectParameter(SqlCompany, "UserId", inv.VendorName);
            SetSelectParameter(SqlWFSequence, "WF_Id", inv.WF_Id);
            SetSelectParameter(SqlFAPWFSequence, "WF_Id", inv.FAPWF_Id);
            SetSelectParameter(SqlCostCenterCT, "Company_ID", inv.InvChargedTo_CompanyId);
        }

        private void SetSelectParameter(SqlDataSource ds, string name, object value)
        {
            if (ds?.SelectParameters[name] == null) return;
            ds.SelectParameters[name].DefaultValue = value == null ? null : value.ToString();
        }

        private void PopulateVendor(ACCEDE_T_InvoiceMain inv)
        {
            if (inv == null) return;
            try
            {
                var code = inv.VendorCode?.Trim();
                if (!string.IsNullOrEmpty(code))
                {
                    // Attempt direct vendor fetch (preferred)
                    var vendor = SAPConnector.GetVendorData(code).FirstOrDefault();
                    if (vendor != null)
                    {
                        txt_vendor.Text = vendor.VENDNAME;
                        return;
                    }
                }

                // Fallback: (original broad fetch) - commented to avoid loading all vendors each time
                // var vendors = SAPVendor.GetVendorData("")
                //     .GroupBy(x => new { x.VENDCODE, x.VENDNAME })
                //     .Select(g => g.First())
                //     .FirstOrDefault(v => v.VENDCODE == inv.VendorCode.Trim());
                // if (vendors != null) txt_vendor.Text = vendors.VENDNAME;
            }
            catch
            {
                // Silent fail – keep UI usable
            }
        }

        private void PopulateHeaderInfo(ACCEDE_T_InvoiceMain inv)
        {
            txt_InvoiceNo.Text = inv.InvoiceNo ?? "";
            txt_ReportDate.Text = inv.ReportDate.HasValue
                ? inv.ReportDate.Value.ToString("MMMM dd, yyyy")
                : "";
        }

        private void ConfigureFinanceVisibility(string empCode, ITP_T_WorkflowActivity actDetails, ACCEDE_T_InvoiceMain inv)
        {
            // Get layout items once
            LayoutItem lbl_CTcomp = FormExpApprovalView.FindItemOrGroupByName("txt_CTComp") as LayoutItem;
            LayoutItem lbl_CTdept = FormExpApprovalView.FindItemOrGroupByName("txt_CTDept") as LayoutItem;
            LayoutItem lbl_CostCenter = FormExpApprovalView.FindItemOrGroupByName("txt_CostCenter") as LayoutItem;
            LayoutItem edit_CTcomp = FormExpApprovalView.FindItemOrGroupByName("edit_CTComp") as LayoutItem;
            LayoutItem edit_CTdept = FormExpApprovalView.FindItemOrGroupByName("edit_CTDept") as LayoutItem;
            LayoutItem edit_CostCenter = FormExpApprovalView.FindItemOrGroupByName("edit_CostCenter") as LayoutItem;
            LayoutItem edit_curr = FormExpApprovalView.FindItemOrGroupByName("edit_Curr") as LayoutItem;
            LayoutItem lbl_curr = FormExpApprovalView.FindItemOrGroupByName("txt_Curr") as LayoutItem;
            LayoutItem edit_paytype = FormExpApprovalView.FindItemOrGroupByName("edit_PayType") as LayoutItem;
            LayoutItem lbl_paytype = FormExpApprovalView.FindItemOrGroupByName("txt_PayType") as LayoutItem;

            var finApprover = _DataContext.vw_ACCEDE_FinApproverVerifies
                .FirstOrDefault(x => x.UserId == empCode && x.Role_Name == "Accede Finance Approver");

            bool isFinanceStage = finApprover != null && actDetails.WF_Id == inv.FAPWF_Id;

            if (isFinanceStage)
            {
                // Editable mode for finance approver (per original logic)
                SafeVisible(lbl_CTcomp, true);
                SafeVisible(lbl_CTdept, false);
                SafeVisible(lbl_CostCenter, false);
                SafeVisible(lbl_curr, false);
                SafeVisible(lbl_paytype, false);

                SafeVisible(edit_CTcomp, false);
                SafeVisible(edit_CTdept, true);
                SafeVisible(edit_CostCenter, true);
                SafeVisible(edit_curr, true);
                SafeVisible(edit_paytype, true);
            }
            else
            {
                SafeVisible(lbl_CTcomp, true);
                SafeVisible(lbl_CTdept, true);
                SafeVisible(lbl_CostCenter, true);
                SafeVisible(lbl_curr, true);
                SafeVisible(lbl_paytype, true);

                SafeVisible(edit_CTcomp, false);
                SafeVisible(edit_CTdept, false);
                SafeVisible(edit_CostCenter, false);
                SafeVisible(edit_curr, false);
                SafeVisible(edit_paytype, false);
            }
        }

        private void SafeVisible(LayoutItem item, bool visible)
        {
            if (item != null) item.ClientVisible = visible;
        }

        private void ComputeTotals(ACCEDE_T_InvoiceMain inv, ITP_T_WorkflowActivity actDetails)
        {
            var totalExp = _DataContext.ACCEDE_T_InvoiceLineDetails
                .Where(x => x.InvMain_ID == actDetails.Document_Id)
                .Select(x => (decimal?)x.NetAmount)
                .Sum() ?? 0m;

            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + inv.Exp_Currency + " ";
        }

        private void SetupRFPRelated(ACCEDE_T_InvoiceMain inv, ITP_T_WorkflowActivity actDetails)
        {
            var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                .FirstOrDefault(x =>
                    x.Exp_ID == inv.ID &&
                    x.IsExpenseReim != true &&
                    x.IsExpenseCA != true &&
                    x.Status != 4 &&
                    x.isTravel != true);

            if (ptvRFP == null)
            {
                var reimItem = FormExpApprovalView.FindItemOrGroupByName("reimItem") as LayoutItem;
                if (reimItem != null)
                    reimItem.ClientVisible = true;
            }
            else
            {
                var reimGroup = FormExpApprovalView.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                if (reimGroup != null)
                {
                    reimGroup.ClientVisible = true;
                    link_rfp.Value = ptvRFP.RFP_DocNum;
                }
            }
        }

        private void SetupForwardWorkflow(string empCode, ITP_T_WorkflowActivity actDetails, ACCEDE_T_InvoiceMain inv)
        {
            // Show AAF button (Approve & Forward) only if at last sequence of Finance WF (original logic)
            var currentDetail = _DataContext.ITP_S_WorkflowDetails
                .FirstOrDefault(x => x.WF_Id == actDetails.WF_Id && x.WFD_Id == actDetails.WFD_Id);

            if (currentDetail != null)
            {
                var next = _DataContext.ITP_S_WorkflowDetails
                    .FirstOrDefault(x => x.WF_Id == actDetails.WF_Id &&
                                         x.Sequence == currentDetail.Sequence + 1);

                var aafItem = FormExpApprovalView.FindItemOrGroupByName("AAF") as LayoutItem;
                if (aafItem != null)
                    aafItem.ClientVisible = (next == null && currentDetail.WF_Id == inv.FAPWF_Id);
            }

            // Role checks
            var finExec = _DataContext.vw_ACCEDE_FinApproverVerifies
                .FirstOrDefault(x => x.UserId == empCode && x.Role_Name == "Accede Finance Executive");
            var finCfo = _DataContext.vw_ACCEDE_FinApproverVerifies
                .FirstOrDefault(x => x.UserId == empCode && x.Role_Name == "Accede CFO");

            string containsFilter;
            if (finExec != null) containsFilter = "forward cfo";
            else if (finCfo != null) containsFilter = "forward pres";
            else containsFilter = "forward exec";

            var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                .Where(x => x.Name.Contains(containsFilter) && x.App_Id == 1032)
                .ToList();

            if (forwardWFList.Any())
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

        #endregion

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

        protected void WFSequenceGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            var invDetail = _DataContext.ACCEDE_T_InvoiceMains
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId"]))
                .FirstOrDefault();

            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = invDetail.WF_Id.ToString();
            SqlWFSequence.DataBind();

            WFGrid.DataSourceID = null;
            WFGrid.DataSource = SqlWFSequence;
            WFGrid.DataBind();

        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            var invDetail = _DataContext.ACCEDE_T_InvoiceMains
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId"]))
                .FirstOrDefault();

            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = invDetail.FAPWF_Id.ToString();
            SqlFAPWFSequence.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWFSequence;
            FAPWFGrid.DataBind();
        }

        [WebMethod]
        public static string btnApproveClickAjax(string approve_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            AccedeNonPOApprovalView rfp = new AccedeNonPOApprovalView();
            var isApprove = rfp.btnApproveClick(approve_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType);
            return isApprove;
        }

        public string btnApproveClick(string remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));

                    var act_detail_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == act_detail_id.Document_Id)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == act_detail_id.Document_Id)
                        .Where(x => x.Status != 4)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    //var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                    //        .Where(x => x.Exp_ID == act_detail_id.Document_Id)
                    //        .Where(x => x.IsExpenseCA == true)
                    //        .Where(x => x.isTravel != true)
                    //        .FirstOrDefault();



                    var payMethod = "";
                    var tranType = "";

                    inv_main.InvChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    inv_main.InvChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    inv_main.CostCenter = costCenter;
                    inv_main.Exp_Currency = curr;
                    inv_main.PaymentType = Convert.ToInt32(payType);
                    //exp_main.ExpenseClassification = Convert.ToInt32(ClassType);

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
                        //rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }
                    //else
                    //{


                    //    payMethod = _DataContext.ACCEDE_S_PayMethods
                    //        .Where(x => x.ID == rfp_main_ca.PayMethod)
                    //        .FirstOrDefault().PMethod_name;

                    //    tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    //        .Where(x => x.ID == rfp_main_ca.TranType)
                    //        .FirstOrDefault().RFPTranType_Name;

                    //}


                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var exp_app_doctype = act_detail_id.AppDocTypeId;

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    int reimId = 0;
                    if (rfp_main != null)
                    {
                        reimId = rfp_main.ID;
                    }
                    var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Document_Id == reimId)
                        .Where(x => x.Status == 1)
                        .FirstOrDefault();

                    var next_seq = 0;
                    var wf_detail = 0;

                    if (ExpActDetails != null)
                    {
                        wf_detail = Convert.ToInt32(ExpActDetails.WFD_Id);

                        //Update current expense Activity
                        ExpActDetails.Status = 7;
                        ExpActDetails.DateAction = DateTime.Now;
                        ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                        ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                        //Update current reimburse Activity
                        if (reimActDetails != null)
                        {
                            reimActDetails.Status = 7;
                            reimActDetails.DateAction = DateTime.Now;
                            reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                            reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        var wf_detail_query = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WFD_Id == wf_detail)
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

                                SendEmailTo(inv_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                            }
                        }
                        else //End of previous WF
                        {
                            if (wfHead_data.WF_Id.ToString() == inv_main.WF_Id.ToString()) //Meaning the Activity WF is equal to Exp Line Approver WF
                            {
                                //var RFPCA = _DataContext.ACCEDE_T_RFPMains
                                //.Where(x => x.Exp_ID == Convert.ToInt32(exp_main.ID))
                                //.Where(x => x.isTravel != true)
                                //.Where(x => x.IsExpenseCA == true);

                                //decimal totalCA = 0;
                                //foreach (var item in RFPCA)
                                //{
                                //    totalCA += Convert.ToDecimal(item.Amount);
                                //}

                                var ExpDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                                    .Where(x => x.InvMain_ID == Convert.ToInt32(inv_main.ID));

                                decimal totalExp = 0;
                                foreach (var item in ExpDetails)
                                {
                                    totalExp += Convert.ToDecimal(item.NetAmount);
                                }

                                //transition to finance wf
                                var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.WF_Id == inv_main.FAPWF_Id)
                                    .FirstOrDefault();

                                if (finance_wf_data != null)
                                {
                                    var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails
                                        .Where(x => x.WF_Id == finance_wf_data.WF_Id)
                                        .Where(x => x.Sequence == 1)
                                        .FirstOrDefault();

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

                                    if (reimActDetails != null)
                                    {
                                        //Insert new activity to RFP Reimburse
                                        ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                                        {
                                            new_activity.Status = 1;
                                            new_activity.AppId = 1032;
                                            new_activity.CompanyId = rfp_main.Company_ID;
                                            new_activity.Document_Id = rfp_main.ID;
                                            new_activity.WF_Id = fin_wfDetail_data.WF_Id;
                                            new_activity.DateAssigned = DateTime.Now;
                                            new_activity.DateCreated = DateTime.Now;
                                            new_activity.IsActive = true;
                                            new_activity.OrgRole_Id = org_id;
                                            new_activity.WFD_Id = fin_wfDetail_data.WFD_Id;
                                            new_activity.AppDocTypeId = rfp_app_docType.DCT_Id;
                                        }
                                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                                    }

                                    //Insert new activity to Expense
                                    ITP_T_WorkflowActivity new_activity_exp = new ITP_T_WorkflowActivity();
                                    {
                                        new_activity_exp.Status = 1;
                                        new_activity_exp.AppId = 1032;
                                        new_activity_exp.CompanyId = inv_main.CompanyId;
                                        new_activity_exp.Document_Id = inv_main.ID;
                                        new_activity_exp.WF_Id = fin_wfDetail_data.WF_Id;
                                        new_activity_exp.DateAssigned = DateTime.Now;
                                        new_activity_exp.DateCreated = DateTime.Now;
                                        new_activity_exp.IsActive = true;
                                        new_activity_exp.OrgRole_Id = org_id;
                                        new_activity_exp.WFD_Id = fin_wfDetail_data.WFD_Id;
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

                                        SendEmailTo(inv_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                                    }
                                }
                                else
                                {
                                    return "Workflow data does not exist.";
                                }

                                //End of Finance WF transition

                            }
                            else
                            {
                                var pending_P2P = _DataContext.ITP_S_Status
                                    .Where(x => x.STS_Name == "Pending at P2P")
                                    .FirstOrDefault();

                                if (rfp_main != null)
                                {
                                    rfp_main.Status = Convert.ToInt32(pending_P2P.STS_Id);
                                }

                                inv_main.Status = Convert.ToInt32(pending_P2P.STS_Id);

                                var wfID = _DataContext.ITP_S_WorkflowHeaders
                                        .Where(x => x.Company_Id == inv_main.InvChargedTo_CompanyId)
                                        .Where(x => x.Name == "ACDE P2P")
                                        .FirstOrDefault();

                                if (wfID != null)
                                {
                                    var expDocType = _DataContext.ITP_S_DocumentTypes
                                        .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
                                        .Select(x => x.DCT_Id)
                                        .FirstOrDefault();

                                    // GET WORKFLOW DETAILS ID
                                    var wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                    where wfd.WF_Id == wfID.WF_Id && wfd.Sequence == 1
                                                    select wfd.WFD_Id;
                                    int wfdID = wfDetails.FirstOrDefault();

                                    // GET ORG ROLE ID
                                    var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                                  where or.WF_Id == wfID.WF_Id && or.Sequence == 1
                                                  select or.OrgRole_Id;
                                    int orID = (int)orgRole.FirstOrDefault();

                                    //INSERT EXPENSE TO ITP_T_WorkflowActivity
                                    DateTime currentDate = DateTime.Now;
                                    ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                    {
                                        Status = pending_P2P.STS_Id,
                                        DateAssigned = currentDate,
                                        WF_Id = wfID.WF_Id,
                                        WFD_Id = wfdID,
                                        OrgRole_Id = orID,
                                        Document_Id = Convert.ToInt32(inv_main.ID),
                                        AppId = 1032,
                                        Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";",
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
                                            Status = pending_P2P.STS_Id,
                                            DateAssigned = currentDate,
                                            WF_Id = wfID.WF_Id,
                                            WFD_Id = wfdID,
                                            OrgRole_Id = orID,
                                            Document_Id = Convert.ToInt32(rfp_main.ID),
                                            AppId = 1032,
                                            Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";",
                                            CompanyId = Convert.ToInt32(inv_main.InvChargedTo_CompanyId),
                                            AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                                            IsActive = true,
                                        };
                                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);
                                    }

                                }
                                else
                                {
                                    return "There is no workflow (ACDE P2P) setup for your company. Please contact Admin to setup the workflow.";
                                }

                                var creator_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == inv_main.UserId)
                                    .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Session["UserID"].ToString())
                                    .FirstOrDefault();

                                SendEmailTo(inv_main.ID, creator_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Approve", payMethod.ToString(), tranType.ToString(), "PendingAudit");

                            }

                        }

                        _DataContext.SubmitChanges();
                    }

                    return "success";
                }

                return "Cannot load Expense Report data. Please reload the page or try login again.";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string btnReturnClickAjax(string return_remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            AccedeNonPOApprovalView rfp = new AccedeNonPOApprovalView();
            return rfp.btnReturnClick(return_remarks, secureToken, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType);
        }

        public string btnReturnClick(string remarks, string secureToken, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            try
            {

                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var exp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == exp_id.Document_Id)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_id.Document_Id)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.Status != 4)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                    var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                        .Where(x => x.ExpenseType_ID == inv_main.InvoiceType_ID)
                        .FirstOrDefault();

                    inv_main.InvChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    inv_main.InvChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    inv_main.CostCenter = costCenter;
                    inv_main.Exp_Currency = curr;
                    inv_main.PaymentType = Convert.ToInt32(payType);

                    if (rfp_main != null)
                    {
                        var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                        var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                            .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                            .Where(x => x.AppId == 1032)
                            .Where(x => x.Status == 1)
                            .Where(x => x.Document_Id == rfp_main.ID)
                            .FirstOrDefault();

                        rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        rfp_main.SAPCostCenter = costCenter;
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                        rfp_main.Currency = curr;
                        rfp_main.PayMethod = Convert.ToInt32(payType);

                        if (reimActDetails != null)
                        {
                            //Update Reimburse Activity
                            reimActDetails.Status = 3;
                            reimActDetails.DateAction = DateTime.Now;
                            reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                            reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        rfp_main.Status = 3;
                    }

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    //Update Expense Activity
                    ExpActDetails.Status = 3;
                    ExpActDetails.DateAction = DateTime.Now;
                    ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                    ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                    inv_main.Status = 3;

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == inv_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(inv_main.ID, creator_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Return", "", tranType.Description, "");
                    _DataContext.SubmitChanges();

                    return "success";
                }
                return "Cannot load Expense Report data. Please reload the page or try login again.";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string btnDisapproveClickAjax(string disapprove_remarks, string secureToken)
        {
            AccedeNonPOApprovalView rfp = new AccedeNonPOApprovalView();
            return rfp.btnDisapproveClick(disapprove_remarks, secureToken);
        }

        public string btnDisapproveClick(string remarks, string secureToken)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var exp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == exp_id.Document_Id)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_id.Document_Id)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                    var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                        .Where(x => x.ExpenseType_ID == inv_main.InvoiceType_ID)
                        .FirstOrDefault();

                    //exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    //exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    //exp_main.CostCenter = costCenter;
                    //exp_main.ExpenseClassification = Convert.ToInt32(ClassType);

                    if (rfp_main != null)
                    {
                        var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                        var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                            .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                            .Where(x => x.AppId == 1032)
                            .Where(x => x.Status == 1)
                            .Where(x => x.Document_Id == rfp_main.ID)
                            .FirstOrDefault();

                        //rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        //rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        //rfp_main.SAPCostCenter = costCenter;
                        //rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);

                        if (reimActDetails != null)
                        {
                            //Update Reimburse Activity
                            reimActDetails.Status = 8;
                            reimActDetails.DateAction = DateTime.Now;
                            reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                            reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        rfp_main.Status = 8;
                    }

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    //Update Expense Activity
                    ExpActDetails.Status = 8;
                    ExpActDetails.DateAction = DateTime.Now;
                    ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                    ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                    inv_main.Status = 8;

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == inv_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(inv_main.ID, creator_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Disapprove", "", tranType.Description, "");
                    _DataContext.SubmitChanges();

                    return "success";
                }
                return "Cannot load Expense Report data. Please reload the page or try login again.";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static RFPDetails DisplayCADetailsAJAX(int item_id)
        {
            ExpenseApprovalView rfp = new ExpenseApprovalView();
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
        public static RFPDetails DisplayReimDetailsAJAX(int item_id)
        {
            ExpenseApprovalView rfp = new ExpenseApprovalView();
            return rfp.DisplayReimDetails(item_id);
        }

        public RFPDetails DisplayReimDetails(int item_id)
        {
            Session["Reim_edit_id"] = item_id;
            var rfpReim = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.ID == item_id)
                .FirstOrDefault();

            RFPDetails rfp = new RFPDetails();
            if (rfpReim != null)
            {
                var compName = _DataContext.CompanyMasters
                    .Where(x => x.WASSId == rfpReim.Company_ID)
                    .FirstOrDefault().CompanyShortName;

                var deptName = _DataContext.ITP_S_OrgDepartmentMasters
                    .Where(x => x.ID == rfpReim.ChargedTo_DeptId)
                    .FirstOrDefault().DepDesc;

                var payMethName = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfpReim.PayMethod)
                    .FirstOrDefault().PMethod_name;

                var tranTypeName = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfpReim.TranType)
                    .FirstOrDefault().RFPTranType_Name;

                var payeeName = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == rfpReim.Payee)
                    .FirstOrDefault();

                var rawfDetail = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.WF_Id == Convert.ToInt32(rfpReim.WF_Id))
                    .FirstOrDefault();

                var fapwfDetail = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.WF_Id == Convert.ToInt32(rfpReim.FAPWF_Id))
                    .FirstOrDefault();

                rfp.company = compName != null ? compName : "";
                rfp.department = deptName != null ? deptName : "";
                rfp.payMethod = payMethName != null ? payMethName : "";
                rfp.tranType = tranTypeName != null ? tranTypeName : "";
                rfp.CostCenter = rfpReim.SAPCostCenter != null ? rfpReim.SAPCostCenter : "";
                rfp.payee = payeeName != null ? payeeName.FullName : "";
                rfp.purpose = rfpReim.Purpose != null ? rfpReim.Purpose : "";
                rfp.amount = rfpReim.Amount != null ? rfpReim.Amount.ToString() : "";
                rfp.currency = rfpReim.Currency != null ? rfpReim.Currency : "";
                rfp.docNum = rfpReim.RFP_DocNum != null ? rfpReim.RFP_DocNum : "";
                rfp.payMethod_id = rfpReim.PayMethod != null ? rfpReim.PayMethod.ToString() : "";
                rfp.RAWF = rawfDetail.Name != null ? rawfDetail.Name : "";
                rfp.FAPWF = fapwfDetail.Name != null ? fapwfDetail.Name : "";
            }
            return rfp;
        }

        [WebMethod]
        public static string SaveReimDetailsAJAX(string payMethod, string io)
        {
            ExpenseApprovalView exp = new ExpenseApprovalView();
            return exp.SaveReimDetails(payMethod, io);
        }

        public string SaveReimDetails(string payMethod, string io)
        {
            try
            {
                var reimDetails = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.ID == Convert.ToInt32(Session["Reim_edit_id"]))
                    .FirstOrDefault();

                reimDetails.PayMethod = Convert.ToInt32(payMethod);
                reimDetails.IO_Num = io;

                var caDetails = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(reimDetails.Exp_ID))
                    .Where(x => x.isTravel != true)
                    .Where(x => x.IsExpenseCA == true);

                if (caDetails.Count() == 0)
                {
                    var invMain = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == Convert.ToInt32(reimDetails.Exp_ID))
                        .FirstOrDefault();

                    invMain.PaymentType = Convert.ToInt32(payMethod);
                }
                _DataContext.SubmitChanges();
                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        //[WebMethod]
        //public static ExpItemDetails DisplayExpDetailsEditAJAX(int item_id)
        //{
        //    ExpenseApprovalView exp = new ExpenseApprovalView();
        //    return exp.DisplayExpDetailsEdit(item_id);

        //}

        //public ExpItemDetails DisplayExpDetailsEdit(int item_id)
        //{
        //    var expDetail = _DataContext.vw_ACCEDE_I_ExpenseDetails
        //        .Where(x => x.ExpenseReportDetail_ID == item_id)
        //        .FirstOrDefault();

        //    ExpItemDetails exp = new ExpItemDetails();
        //    if (expDetail != null)
        //    {
        //        var expMainMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(expDetail.ExpenseMain_ID)).FirstOrDefault();
        //        var acct_charge = _DataContext.ACDE_T_MasterCodes
        //            .Where(x => x.ID == Convert.ToInt32(expDetail.AccountToCharged))
        //            .FirstOrDefault();

        //        //var cost_center = _DataContext.ACCEDE_S_CostCenters.Where(x=>x.CostCenter_ID == Convert.ToInt32(expMain.CostCenterIOWBS)).FirstOrDefault();
        //        //var cc = _DataContext.ITP_S_OrgDepartmentMasters
        //        //    .Where(x=>x.ID == Convert.ToInt32(expMainMain.ExpChargedTo_DeptId))
        //        //    .FirstOrDefault();

        //        DateTime dateAdd = Convert.ToDateTime(expDetail.DateAdded);

        //        //Assign values to fields -- 
        //        exp.acctCharge = acct_charge != null ? acct_charge.Description : "";
        //        exp.costCenter = expDetail.CostCenterIOWBS != null ? expDetail.CostCenterIOWBS.ToString() : "";
        //        exp.particulars = expDetail.P_Name != null ? expDetail.P_Name.ToString() : "";
        //        exp.supplier = expDetail.Supplier != null ? expDetail.Supplier : "";
        //        exp.tin = expDetail.TIN != null ? expDetail.TIN : "";
        //        exp.invoice = expDetail.InvoiceOR != null ? expDetail.InvoiceOR : "";
        //        exp.gross = expDetail.GrossAmount != null ? expDetail.GrossAmount.ToString() : "";
        //        exp.dateCreated = dateAdd != null ? dateAdd.ToString("MMMM dd, yyyy") : "";
        //        exp.net = expDetail.NetAmount != null ? expDetail.NetAmount.ToString() : "0.00";
        //        exp.vat = expDetail.VAT != null ? expDetail.VAT.ToString() : "0.00";
        //        exp.ewt = expDetail.EWT != null ? expDetail.EWT.ToString() : "0.00";
        //        exp.io = expDetail.ExpDtl_IO != null ? expDetail.ExpDtl_IO.ToString() : "";
        //        exp.wbs = expDetail.ExpDtl_WBS != null ? expDetail.ExpDtl_WBS.ToString() : "";
        //        exp.remarks = expDetail.ExpDetail_remarks != null ? expDetail.ExpDetail_remarks.ToString() : "";
        //    }

        //    Session["ExpMainId"] = item_id.ToString();

        //    return exp;
        //}

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
            AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
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
            AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
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

        public bool SendEmailTo(int doc_id, string receiver_id, int Comp_id, string sender_fullname, string sender_email, string doc_no, string date_created, string document_purpose, string remarks, string status, string payMethod, string tranType, string status2)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                    .Where(x => x.ID == doc_id)
                    .FirstOrDefault();

                var requestor_detail = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == inv_main.UserId.ToString().Trim())
                    .FirstOrDefault();

                var user_email = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == receiver_id)
                    .FirstOrDefault();

                var comp_name = _DataContext.CompanyMasters
                    .Where(x => x.WASSId == Comp_id)
                    .FirstOrDefault();

                //Start--   Get Text info
                var queryText =
                        from texts in _DataContext.ITP_S_Texts
                        where texts.Type == "Email" && texts.Name == status
                        select texts;

                var emailMessage = "";
                var emailSubMessage = "";
                var emailColor = "";
                var emailSubTitle = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = text.Text2.ToString();
                    if (status2 == "PendingAudit")
                    {
                        emailSubMessage = "Your request is pending for audit. Please forward the original supporting documents to the Internal Audit Department and indicate the Accede Reference Document number";
                    }

                    if (status2 == "ApprovedP2P")
                    {
                        emailSubMessage = "Procure to Payment has approved your request. You can now proceed with the next steps based on the approved document.";
                    }

                    if (status2 == "PendingAR")
                    {
                        emailSubMessage = "Your document has been forwarded to the Cashier. Please proceed to return your excess cash advance.";
                    }

                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                    emailSubTitle = text.Text3.ToString();
                }
                //End--     Get Text info

                string appName = "ACCEDE Expense Report";
                string recipientName = user_email.FName;
                string senderName = sender_fullname;
                string emailSender = sender_email;
                string emailSite = "https://apps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = "ACCEDE Invoice Non-PO Document No. "+doc_no + ": " + emailSubTitle;
                string requestorName = requestor_detail.FullName;


                ANFLO anflo = new ANFLO();

                //Body Details Sample
                string emailDetails = "";

                emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
                emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>";
                emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>";
                emailDetails += "<tr><td>Preparer</td><td><strong>" + requestorName + "</strong></td></tr>";
                //emailDetails += "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>";
                emailDetails += "<tr><td>Transaction Type</td><td><strong>" + tranType + "</strong></td></tr>";
                emailDetails += "<tr><td>Status</td><td><strong>" + "Pending" + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Purpose</td><td><strong>" + document_purpose + "</strong></td></tr>";
                emailDetails += "</table>";
                emailDetails += "<br>";

                emailDetails += "</table>";
                //End of Body Details Sample

                //}
                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, remarks, emailSite, emailColor);

                if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }
            catch (Exception e)
            {
                return false;
            }
        }

        //[WebMethod]
        //public static string SaveExpDetailsAJAX(
        //    string dateAdd,
        //    //string tin_no, 
        //    string invoice_no,
        //    //string cost_center,
        //    string gross_amount,
        //    string net_amount,
        //    //string supp, 
        //    string particu,
        //    string acctCharge,
        //    //string vat_amnt, 
        //    //string ewt_amnt, 
        //    string currency,
        //    //string io, 
        //    //string wbs,
        //    string remarks,
        //    string EWTTAmount,
        //    string assign,
        //    string allowance,
        //    string EWTTType,
        //    string EWTTCode,
        //    string InvTCode,
        //    string qty,
        //    string unit_price,
        //    string asset,
        //    string subasset,
        //    string altRecon,
        //    string SLCode,
        //    string SpecialGL
        //    )
        //{
        //    AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
        //    return exp.SaveExpDetails(
        //        dateAdd,
        //        //tin_no, 
        //        invoice_no,
        //        //cost_center,
        //        gross_amount,
        //        net_amount,
        //        //supp, 
        //        particu,
        //        acctCharge,
        //        //vat_amnt, 
        //        //ewt_amnt, 
        //        currency,
        //        // io, 
        //        // wbs, 
        //        remarks,
        //        EWTTAmount,
        //        assign,
        //        allowance,
        //        EWTTType,
        //        EWTTCode,
        //        InvTCode,
        //        qty,
        //        unit_price,
        //        asset,
        //        subasset,
        //        altRecon,
        //        SLCode,
        //        SpecialGL);
        //}

        //public string SaveExpDetails(
        //    string dateAdd,
        //    //string tin_no, 
        //    string invoice_no,
        //    //string cost_center,
        //    string gross_amount,
        //    string net_amount,
        //    //string supp, 
        //    string particu,
        //    string acctCharge,
        //    //string vat_amnt, 
        //    //string ewt_amnt, 
        //    string currency,
        //    //string io, 
        //    //string wbs,
        //    string remarks,
        //    string EWTTAmount,
        //    string assign,
        //    string allowance,
        //    string EWTTType,
        //    string EWTTCode,
        //    string InvTCode,
        //    string qty,
        //    string unit_price,
        //    string asset,
        //    string subasset,
        //    string altRecon,
        //    string SLCode,
        //    string SpecialGL
        //    )
        //{
        //    try
        //    {
        //        decimal totalNetAmnt = new decimal(0.00);
        //        var invDtlMap = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
        //            .Where(x => x.InvoiceReportDetail_ID == Convert.ToInt32(Session["InvDetailsID"]));

        //        var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
        //                .Where(x => x.ID == Convert.ToInt32(Session["InvDetailsID"]))
        //                .FirstOrDefault();

        //        foreach (var item in invDtlMap)
        //        {
        //            totalNetAmnt += Convert.ToDecimal(item.NetAmount);
        //        }

        //        decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
        //        if (totalNetAmnt < gross && invDtlMap.Count() > 0)
        //        {
        //            string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + ". Please check the allocation amounts.";
        //            return error;
        //        }
        //        else
        //        {
                    

        //            if (expDetail != null)
        //            {
        //                expDetail.DateAdded = Convert.ToDateTime(dateAdd);
        //                //expDetail.TIN = string.IsNullOrEmpty(tin_no) ? (string)null : tin_no;
        //                //expDetail.InvoiceOR = string.IsNullOrEmpty(invoice_no) ? (string)null : invoice_no;
        //                //expDetail.CostCenterIOWBS = cost_center;
        //                expDetail.TotalAmount = Convert.ToDecimal(gross_amount);
        //                expDetail.NetAmount = Convert.ToDecimal(net_amount);
        //                //expDetail.Supplier = string.IsNullOrEmpty(supp) ? (string)null : supp;
        //                expDetail.Particulars = Convert.ToInt32(particu);
        //                expDetail.AcctToCharged = Convert.ToInt32(acctCharge);
        //                //expDetail.VAT = Convert.ToDecimal(vat_amnt);
        //                //expDetail.EWT = Convert.ToDecimal(ewt_amnt);
        //                //expDetail.ExpDtl_Currency = currency;
        //                //expDetail.ExpDtl_IO = string.IsNullOrEmpty(io) ? (string)null : io;
        //                //expDetail.ExpDtl_WBS = string.IsNullOrEmpty(wbs) ? (string)null : wbs;
        //                expDetail.LineDescription = remarks;
        //                expDetail.Qty = Convert.ToDecimal(qty);
        //                expDetail.UnitPrice = Convert.ToDecimal(unit_price);
        //            }

        //            //var expDetailNonPO = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(Session["InvDetailsID"])).FirstOrDefault();
        //            //if(expDetailNonPO != null)
        //            //{
        //            //    expDetailNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
        //            //    expDetailNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
        //            //    expDetailNonPO.EWTTaxCode = EWTTCode;
        //            //    expDetailNonPO.InvoiceTaxCode = InvTCode;
        //            //    expDetailNonPO.Asset = asset;
        //            //    expDetailNonPO.SubAssetCode = subasset;
        //            //    expDetailNonPO.AltRecon = altRecon;
        //            //    expDetailNonPO.SLCode = SLCode;
        //            //    expDetailNonPO.SpecialGL = SpecialGL;
        //            //}
        //            //else
        //            //{
        //            //    ACCEDE_T_ExpenseDetailsInvNonPO expNonPO = new ACCEDE_T_ExpenseDetailsInvNonPO();
        //            //    {
        //            //        expNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
        //            //        expNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
        //            //        expNonPO.EWTTaxCode = EWTTCode;
        //            //        expNonPO.InvoiceTaxCode = InvTCode;
        //            //        expNonPO.Asset = asset;
        //            //        expNonPO.SubAssetCode = subasset;
        //            //        expNonPO.AltRecon = altRecon;
        //            //        expNonPO.SLCode = SLCode;
        //            //        expNonPO.SpecialGL = SpecialGL;
        //            //    }

        //            //    _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.InsertOnSubmit(expNonPO);

        //            //}


        //        }

        //        _DataContext.SubmitChanges();

        //        var ptvRFP = _DataContext.ACCEDE_T_RFPMains
        //            .Where(x => x.Exp_ID == Convert.ToInt32(expDetail.InvMain_ID))
        //            .Where(x => x.isTravel != true)
        //            .Where(x => x.Status != 4)
        //            .Where(x => x.IsExpenseReim != true)
        //            .Where(x => x.IsExpenseCA != true);

        //        //var rfpReim = _DataContext.ACCEDE_T_RFPMains
        //        //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
        //        //    .Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true)
        //        //    .Where(x => x.isTravel != true)
        //        //    .FirstOrDefault();

        //        var expDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
        //            .Where(x => x.InvMain_ID == Convert.ToInt32(expDetail.InvMain_ID));

        //        //decimal totalReim = new decimal(0);
        //        //decimal totalCA = new decimal(0);
        //        decimal totalExpense = new decimal(0);

        //        //foreach (var ca in rfpCA)
        //        //{
        //        //    totalCA += Convert.ToDecimal(ca.Amount);
        //        //}

        //        foreach (var exp in expDetails)
        //        {
        //            totalExpense += Convert.ToDecimal(exp.NetAmount);
        //        }

        //        //totalReim = totalCA - totalExpense;
        //        //if (totalReim < 0)
        //        //{
        //        //    if (rfpReim != null)
        //        //    {
        //        //        rfpReim.Amount = Math.Abs(totalReim);
        //        //    }
        //        //}
        //        //else
        //        //{
        //        //    if (rfpReim != null)
        //        //    {
        //        //        rfpReim.Status = 4;
        //        //    }

        //        //}

        //        _DataContext.SubmitChanges();
        //        return "success";
        //    }
        //    catch (Exception ex)
        //    {
        //        return ex.Message;
        //    }
        //}

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = e.Parameters.ToString();
            SqlExpMap.DataBind();

            ExpAllocGrid.DataBind();
        }

        protected void ExpGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnEdit") // Ensure it's a data row and the button is the desired one
            {
                string encryptedID = Request.QueryString["secureToken"];
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == Convert.ToInt32(actID))
                        .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains.Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id)).FirstOrDefault();

                    var FinApproverVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .Where(x => x.Role_Name == "Accede Finance Approver")
                    .FirstOrDefault();

                    if (FinApproverVerify != null && actDetails.WF_Id == inv_main.FAPWF_Id)
                    {
                        e.Visible = DevExpress.Utils.DefaultBoolean.True;
                    }
                    else
                    {
                        e.Visible = DevExpress.Utils.DefaultBoolean.False;
                    }
                }
                    
            }
        }



        //PDF/IMAGE VIEWER
        [WebMethod]
        public static object AJAXGetDocument(string fileId, string appId)
        {
            DocumentViewer doc = new DocumentViewer();

            return doc.GetDocument(fileId, appId);
        }

        protected void WFSequenceGrid0_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var wf_id = e.Parameters.ToString();

            SqlWFSequenceForward.SelectParameters["WF_Id"].DefaultValue = wf_id;
            SqlWFSequenceForward.DataBind();

            WFSequenceGrid0.DataSourceID = null;
            WFSequenceGrid0.DataSource = SqlWFSequenceForward;
            WFSequenceGrid0.DataBind();
        }

        [WebMethod]
        public static string btnApproveForwardAJAX(string secureToken, string forwardWF, string remarks, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            AccedeNonPOApprovalView rfp = new AccedeNonPOApprovalView();

            return rfp.btnApproveForward(secureToken, forwardWF, remarks, CTComp_id, CTDept_id, costCenter, ClassType, curr, payType);

        }

        public string btnApproveForward(string secureToken, string forwardWF, string remarks, string CTComp_id, string CTDept_id, string costCenter, string ClassType, string curr, string payType)
        {
            try
            {
                string encryptedID = secureToken;

                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var exp_ActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var aaf_wf_data = _DataContext.ITP_S_WorkflowHeaders
                        .Where(x => x.WF_Id == Convert.ToInt32(forwardWF))
                        .FirstOrDefault();

                    var inv_main = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == exp_ActDetails.Document_Id)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_ActDetails.Document_Id)
                        .Where(x => x.Status != 4)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var exp_app_doctype = exp_ActDetails.AppDocTypeId;

                    inv_main.InvChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    inv_main.InvChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    inv_main.CostCenter = costCenter;
                    inv_main.Exp_Currency = curr;
                    inv_main.PaymentType = Convert.ToInt32(payType);

                    int reimId = 0;
                    if (rfp_main != null)
                    {
                        reimId = rfp_main.ID;

                        rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        rfp_main.SAPCostCenter = costCenter;
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }
                    var reimActDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.AppDocTypeId == Convert.ToInt32(rfp_app_docType.DCT_Id))
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Document_Id == reimId)
                        .Where(x => x.Status == 1)
                        .FirstOrDefault();

                    if (reimActDetails != null)
                    {
                        reimActDetails.Status = 7;
                        reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                        reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        reimActDetails.DateAction = DateTime.Now;
                    }

                    exp_ActDetails.Status = 7;
                    exp_ActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                    exp_ActDetails.ActedBy_User_Id = Session["userID"].ToString();
                    exp_ActDetails.DateAction = DateTime.Now;

                    var payMethod = "";
                    var tranType = "";

                    if (rfp_main != null)
                    {
                        payMethod = _DataContext.ACCEDE_S_PayMethods
                            .Where(x => x.ID == rfp_main.PayMethod)
                            .FirstOrDefault().PMethod_name;
                        tranType = _DataContext.ACCEDE_S_RFPTranTypes
                            .Where(x => x.ID == rfp_main.TranType)
                            .FirstOrDefault().RFPTranType_Name;
                    }
                    //else
                    //{
                    //    var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                    //        .Where(x => x.Exp_ID == exp_ActDetails.Document_Id)
                    //        .Where(x => x.IsExpenseCA == true)
                    //        .Where(x => x.isTravel != true)
                    //        .FirstOrDefault();

                    //    payMethod = _DataContext.ACCEDE_S_PayMethods
                    //        .Where(x => x.ID == rfp_main_ca.PayMethod)
                    //        .FirstOrDefault().PMethod_name;

                    //    tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    //        .Where(x => x.ID == rfp_main_ca.TranType)
                    //        .FirstOrDefault().RFPTranType_Name;
                    //}

                    if (aaf_wf_data != null)
                    {
                        var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails
                            .Where(x => x.WF_Id == aaf_wf_data.WF_Id)
                            .Where(x => x.Sequence == 1)
                            .FirstOrDefault();

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

                        if (rfp_main != null)
                        {
                            //Insert new activity to RFP Reimburse
                            ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                            {
                                new_activity.Status = 1;
                                new_activity.AppId = 1032;
                                new_activity.CompanyId = rfp_main.Company_ID;
                                new_activity.Document_Id = rfp_main.ID;
                                new_activity.WF_Id = fin_wfDetail_data.WF_Id;
                                new_activity.DateAssigned = DateTime.Now;
                                new_activity.DateCreated = DateTime.Now;
                                new_activity.IsActive = true;
                                new_activity.OrgRole_Id = org_id;
                                new_activity.WFD_Id = fin_wfDetail_data.WFD_Id;
                                new_activity.AppDocTypeId = rfp_app_docType.DCT_Id;
                            }
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                        }

                        //Insert new activity to Expense
                        ITP_T_WorkflowActivity new_activity_exp = new ITP_T_WorkflowActivity();
                        {
                            new_activity_exp.Status = 1;
                            new_activity_exp.AppId = 1032;
                            new_activity_exp.CompanyId = inv_main.CompanyId;
                            new_activity_exp.Document_Id = inv_main.ID;
                            new_activity_exp.WF_Id = fin_wfDetail_data.WF_Id;
                            new_activity_exp.DateAssigned = DateTime.Now;
                            new_activity_exp.DateCreated = DateTime.Now;
                            new_activity_exp.IsActive = true;
                            new_activity_exp.OrgRole_Id = org_id;
                            new_activity_exp.WFD_Id = fin_wfDetail_data.WFD_Id;
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

                            SendEmailTo(inv_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(inv_main.CompanyId), sender_detail.FullName, sender_detail.Email, inv_main.DocNo, inv_main.DateCreated.ToString(), inv_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                        }

                        _DataContext.SubmitChanges();
                        return "success";
                    }
                }

                return "Secure token is null.";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        protected void drpdown_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            drpdown_CTDepartment.DataSourceID = null;
            drpdown_CTDepartment.DataSource = SqlCTDepartment;
            drpdown_CTDepartment.DataBind();
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

            //var count = drpdown_CostCenter.Items.Count;
            //if (count == 1)
            //    drpdown_CostCenter.SelectedIndex = 0; drpdown_CostCenter.DataBind();
        }

        protected void CAWFActivityGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAWFActivity.SelectParameters["Document_Id"].DefaultValue = e.Parameters.ToString();
            SqlCAWFActivity.DataBind();

            CAWFActivityGrid.DataSourceID = null;
            CAWFActivityGrid.DataSource = SqlCAWFActivity;
            CAWFActivityGrid.DataBind();
        }

        protected void CADocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlCAFileAttach.SelectParameters["Doc_ID"].DefaultValue = e.Parameters.ToString();
            SqlCAFileAttach.DataBind();

            CADocuGrid.DataSourceID = null;
            CADocuGrid.DataSource = SqlCAFileAttach;
            CADocuGrid.DataBind();
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

        protected void DocuGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["InvDetailsID"] = null;

            DocuGrid_edit.DataSourceID = null;
            DocuGrid_edit.DataSource = SqlExpDetailAttach;
            DocuGrid_edit.DataBind();
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

        protected void DocuGrid1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpDetailAttach.SelectParameters["ExpDetail_Id"].DefaultValue = e.Parameters.ToString();
            SqlExpDetailAttach.DataBind();

            DocuGrid1.DataBind();
        }

        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
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
                if (upd.NewValues.Contains("EDM_Remarks"))
                    entity.EDM_Remarks = upd.NewValues["EDM_Remarks"]?.ToString();
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
                    EDM_Remarks = ins.NewValues["EDM_Remarks"]?.ToString(),
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