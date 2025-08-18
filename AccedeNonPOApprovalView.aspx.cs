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

namespace DX_WebTemplate
{
    public partial class AccedeNonPOApprovalView : System.Web.UI.Page
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
                            if(vendor != null)
                            {
                                txt_vendor.Text = vendor.VendorName.ToString();
                            }

                            txt_InvoiceNo.Text = exp.InvoiceNonPO_No.ToString();

                            var vendorDetails = _DataContext.ACCEDE_S_Vendors.Where(x => x.VendorCode == exp.ExpenseName).FirstOrDefault();
                            if (vendorDetails != null)
                            {
                                string tin = vendorDetails.TaxID.ToString();

                                if (tin.Length > 9)
                                {
                                    string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3, 3)}-{tin.Substring(6, 3)}-{tin.Substring(9)}";
                                    txt_TIN.Text = formattedTin;
                                }
                                else if (tin.Length > 6)
                                {
                                    string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3, 3)}-{tin.Substring(6)}";
                                    txt_TIN.Text = formattedTin;
                                }
                                else if (tin.Length > 3)
                                {
                                    string formattedTin = $"{tin.Substring(0, 3)}-{tin.Substring(3)}";
                                    txt_TIN.Text = formattedTin;
                                }
                                else
                                {
                                    txt_TIN.Text = tin; // less than 3 digits, no formatting
                                }

                                string Clean(string input)
                                {
                                    if (string.IsNullOrWhiteSpace(input))
                                        return "";

                                    // remove line breaks and trim
                                    string cleanedVendorstr = input.Replace("\r", " ").Replace("\n", " ").Trim();

                                    return ", " + cleanedVendorstr;
                                }

                                memo_VendorAddress.Text =
                                    (vendorDetails.Address1 ?? "").Replace("\r", " ").Replace("\n", " ").Trim()
                                    + Clean(vendorDetails.City ?? "")
                                    + Clean(vendorDetails.State ?? "");


                            }

                            SqlIO.SelectParameters["CompanyId"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();

                            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = exp.ExpChargedTo_CompanyId.ToString();
                            SqlCompany.SelectParameters["UserId"].DefaultValue = exp.ExpenseName.ToString();

                            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = Convert.ToInt32(exp.ExpChargedTo_CompanyId).ToString();

                            var FinApproverVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                                .Where(x => x.UserId == empCode)
                                .Where(x => x.Role_Name == "Accede Finance Approver")
                                .FirstOrDefault();

                            var lbl_CTcomp = FormExpApprovalView.FindItemOrGroupByName("txt_CTComp") as LayoutItem;
                            var lbl_CTdept = FormExpApprovalView.FindItemOrGroupByName("txt_CTDept") as LayoutItem;
                            var lbl_CostCenter = FormExpApprovalView.FindItemOrGroupByName("txt_CostCenter") as LayoutItem;
                            var edit_CTcomp = FormExpApprovalView.FindItemOrGroupByName("edit_CTComp") as LayoutItem;
                            var edit_CTdept = FormExpApprovalView.FindItemOrGroupByName("edit_CTDept") as LayoutItem;
                            var edit_CostCenter = FormExpApprovalView.FindItemOrGroupByName("edit_CostCenter") as LayoutItem;
                            var lbl_classType = FormExpApprovalView.FindItemOrGroupByName("txt_ClassType") as LayoutItem;
                            var edit_classType = FormExpApprovalView.FindItemOrGroupByName("edit_ClassType") as LayoutItem;
                            var edit_curr = FormExpApprovalView.FindItemOrGroupByName("edit_Curr") as LayoutItem;
                            var lbl_curr = FormExpApprovalView.FindItemOrGroupByName("txt_Curr") as LayoutItem;
                            var edit_paytype = FormExpApprovalView.FindItemOrGroupByName("edit_PayType") as LayoutItem;
                            var lbl_paytype = FormExpApprovalView.FindItemOrGroupByName("txt_PayType") as LayoutItem;

                            var expType = _DataContext.ACCEDE_S_ExpenseTypes
                                .Where(x => x.ExpenseType_ID == Convert.ToInt32(exp.ExpenseType_ID))
                                .FirstOrDefault();

                            if (FinApproverVerify != null && actDetails.WF_Id.ToString() == exp.FAPWF_Id.ToString())
                            {
                                //lbl_CTcomp.ClientVisible = false;
                                lbl_CTcomp.ClientVisible = true;
                                lbl_CTdept.ClientVisible = false;
                                lbl_CostCenter.ClientVisible = false;
                                lbl_curr.ClientVisible = false;
                                lbl_paytype.ClientVisible = false;
                                //edit_CTcomp.ClientVisible = true;
                                edit_CTcomp.ClientVisible = false;
                                edit_CTdept.ClientVisible = true;
                                edit_CostCenter.ClientVisible = true;
                                edit_curr.ClientVisible = true;
                                edit_paytype.ClientVisible = true;

                                //edit_classType.ClientVisible = true;
                                //lbl_classType.ClientVisible = false;
                            }
                            else
                            {
                                lbl_CTcomp.ClientVisible = true;
                                lbl_CTdept.ClientVisible = true;
                                lbl_CostCenter.ClientVisible = true;
                                lbl_curr.ClientVisible = true;
                                lbl_paytype.ClientVisible = true;
                                edit_CTcomp.ClientVisible = false;
                                edit_CTdept.ClientVisible = false;
                                edit_CostCenter.ClientVisible = false;
                                edit_curr.ClientVisible = false;
                                edit_paytype.ClientVisible = false;

                                //edit_classType.ClientVisible = false;
                                //lbl_classType.ClientVisible = true;
                            }

                            txt_ExpType.Text = expType.Description;

                            //if (Convert.ToBoolean(exp.isTravel) != true)
                            //{
                            //    txt_ExpType.Text = expType.Description + " - Non Travel";
                            //}
                            //else
                            //{
                            //    txt_ExpType.Text = expType.Description;
                            //}

                            txt_ReportDate.Text = Convert.ToDateTime(exp.ReportDate).ToString("MMMM dd, yyyy");
                            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;

                            if (myLayoutGroup != null)
                            {
                                myLayoutGroup.Caption = "Invoice Document -" + exp.DocNo.ToString() + " (View)";
                            }

                            var RFPCA = _DataContext.ACCEDE_T_RFPMains
                                .Where(x => x.Exp_ID == Convert.ToInt32(actDetails.Document_Id))
                                .Where(x => x.isTravel != true)
                                .Where(x => x.IsExpenseCA == true);

                            //decimal totalCA = 0;
                            //foreach (var item in RFPCA)
                            //{
                            //    totalCA += Convert.ToDecimal(item.Amount);
                            //}
                            //caTotal.Text = totalCA.ToString("#,##0.00") + "  " + exp.Exp_Currency + " ";

                            var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                                .Where(x => x.ExpenseMain_ID == Convert.ToInt32(actDetails.Document_Id));

                            decimal totalExp = 0;
                            foreach (var item in ExpDetails)
                            {
                                totalExp += Convert.ToDecimal(item.NetAmount);
                            }
                            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + exp.Exp_Currency + " ";

                            //dueComp = totalCA - totalExp;
                            //if (dueComp < 0)
                            //{
                            //    var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            //    dueField.Caption = "Net Due to Employee";
                            //}
                            //else
                            //{
                            //    var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                            //    dueField.Caption = "Net Due to Company";

                            //    //DO NOT DELETE THIS CODE
                            //    if (dueComp > 0)
                            //    {
                            //        var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                            //        AR_Reference.ClientVisible = true;
                            //    }
                            //}

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
                            var wfDetails = _DataContext.ITP_S_WorkflowDetails
                                .Where(x => x.WF_Id == actDetails.WF_Id)
                                .Where(x => x.WFD_Id == actDetails.WFD_Id)
                                .FirstOrDefault();

                            if (wfDetails != null)
                            {
                                var nxWFDetails = _DataContext.ITP_S_WorkflowDetails
                                .Where(x => x.WF_Id == actDetails.WF_Id)
                                .Where(x => x.Sequence == (Convert.ToInt32(wfDetails.Sequence) + 1))
                                .FirstOrDefault();


                                var if_WF_isRA = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.WF_Id == wfDetails.WF_Id)
                                    .FirstOrDefault();


                                var aaf = FormExpApprovalView.FindItemOrGroupByName("AAF") as LayoutItem;

                                if (nxWFDetails == null && if_WF_isRA.IsRA != true)
                                {
                                    aaf.ClientVisible = true;
                                }

                                var FinExecVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                                    .Where(x => x.UserId == empCode)
                                    .Where(x => x.Role_Name == "Accede Finance Executive")
                                    .FirstOrDefault();

                                var FinCFOVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                                    .Where(x => x.UserId == empCode)
                                    .Where(x => x.Role_Name == "Accede CFO")
                                    .FirstOrDefault();

                                if (FinExecVerify != null)
                                {
                                    var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                        .Where(x => x.Name.Contains("forward cfo"))
                                        .Where(x => x.App_Id == 1032)
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
                                        .Where(x => x.Name.Contains("forward pres"))
                                        .Where(x => x.App_Id == 1032)
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
                                        .Where(x => x.Name.Contains("forward exec"))
                                        .Where(x => x.App_Id == 1032)
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

                            //dueTotal.Text = "PHP " + FormatDecimal(dueComp) + "  " + exp.Exp_Currency + " ";

                            //grossAmount_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //netAmount_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //vat_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //ewt_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;

                            //gross_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //net_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //vat_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            //net_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;


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
            var expDetail = _DataContext.ACCEDE_T_ExpenseMains
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId"]))
                .FirstOrDefault();

            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = expDetail.WF_Id.ToString();
            SqlWFSequence.DataBind();

            WFGrid.DataSourceID = null;
            WFGrid.DataSource = SqlWFSequence;
            WFGrid.DataBind();

        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            var expDetail = _DataContext.ACCEDE_T_ExpenseMains
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId"]))
                .FirstOrDefault();

            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = expDetail.FAPWF_Id.ToString();
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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
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

                    exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    exp_main.CostCenter = costCenter;
                    exp_main.Exp_Currency = curr;
                    exp_main.PaymentType = Convert.ToInt32(payType);
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

                                SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

                            }
                        }
                        else //End of previous WF
                        {
                            if (wfHead_data.WF_Id.ToString() == exp_main.WF_Id.ToString()) //Meaning the Activity WF is equal to Exp Line Approver WF
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

                                var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                                    .Where(x => x.ExpenseMain_ID == Convert.ToInt32(exp_main.ID));

                                decimal totalExp = 0;
                                foreach (var item in ExpDetails)
                                {
                                    totalExp += Convert.ToDecimal(item.NetAmount);
                                }

                                //transition to finance wf
                                var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.WF_Id == exp_main.FAPWF_Id)
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
                                        new_activity_exp.CompanyId = exp_main.CompanyId;
                                        new_activity_exp.Document_Id = exp_main.ID;
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

                                        SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

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

                                exp_main.Status = Convert.ToInt32(pending_P2P.STS_Id);

                                var wfID = _DataContext.ITP_S_WorkflowHeaders
                                        .Where(x => x.Company_Id == exp_main.ExpChargedTo_CompanyId)
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
                                        Document_Id = Convert.ToInt32(exp_main.ID),
                                        AppId = 1032,
                                        Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";",
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
                                            Status = pending_P2P.STS_Id,
                                            DateAssigned = currentDate,
                                            WF_Id = wfID.WF_Id,
                                            WFD_Id = wfdID,
                                            OrgRole_Id = orID,
                                            Document_Id = Convert.ToInt32(rfp_main.ID),
                                            AppId = 1032,
                                            Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";",
                                            CompanyId = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId),
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
                                    .Where(x => x.EmpCode == exp_main.UserId)
                                    .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Session["UserID"].ToString())
                                    .FirstOrDefault();

                                SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Approve", payMethod.ToString(), tranType.ToString(), "PendingAudit");

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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
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
                        .Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID)
                        .FirstOrDefault();

                    exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    exp_main.CostCenter = costCenter;
                    exp_main.ExpenseClassification = Convert.ToInt32(ClassType);
                    exp_main.Exp_Currency = curr;
                    exp_main.PaymentType = Convert.ToInt32(payType);

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

                    exp_main.Status = 3;

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == exp_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Return", "", tranType.Description, "");
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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
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
                        .Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID)
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

                    exp_main.Status = 8;

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == exp_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Disapprove", "", tranType.Description, "");
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
                    var expMain = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(reimDetails.Exp_ID))
                        .FirstOrDefault();

                    expMain.PaymentType = Convert.ToInt32(payMethod);
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
        public static ExpDetailsNonPO DisplayExpDetailsEditAJAX(int expDetailID)
        {
            AccedeNonPOApprovalView exp = new AccedeNonPOApprovalView();
            return exp.DisplayExpDetailsEdit(expDetailID);

        }

        public ExpDetailsNonPO DisplayExpDetailsEdit(int expDetailID)
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
                exp_det_class.particulars = exp_details.Particulars?.ToString() ?? exp_det_class.particulars;
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

        public bool SendEmailTo(int doc_id, string receiver_id, int Comp_id, string sender_fullname, string sender_email, string doc_no, string date_created, string document_purpose, string remarks, string status, string payMethod, string tranType, string status2)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == doc_id)
                    .FirstOrDefault();

                var requestor_detail = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == exp_main.UserId.ToString().Trim())
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
                string emailSubject = doc_no + ": " + emailSubTitle;
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
            string SpecialGL
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
                SpecialGL);
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
            string SpecialGL
            )
        {
            try
            {
                decimal totalNetAmnt = new decimal(0.00);
                var expDtlMap = _DataContext.ACCEDE_T_ExpenseDetailsMaps
                    .Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));

                foreach (var item in expDtlMap)
                {
                    totalNetAmnt += Convert.ToDecimal(item.NetAmount);
                }

                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if (totalNetAmnt < gross && expDtlMap.Count() > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + ". Please check the allocation amounts.";
                    return error;
                }
                else
                {
                    var expDetail = _DataContext.ACCEDE_T_ExpenseDetails
                        .Where(x => x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]))
                        .FirstOrDefault();

                    if (expDetail != null)
                    {
                        expDetail.DateAdded = Convert.ToDateTime(dateAdd);
                        //expDetail.TIN = string.IsNullOrEmpty(tin_no) ? (string)null : tin_no;
                        expDetail.InvoiceOR = string.IsNullOrEmpty(invoice_no) ? (string)null : invoice_no;
                        //expDetail.CostCenterIOWBS = cost_center;
                        expDetail.GrossAmount = Convert.ToDecimal(gross_amount);
                        expDetail.NetAmount = Convert.ToDecimal(net_amount);
                        //expDetail.Supplier = string.IsNullOrEmpty(supp) ? (string)null : supp;
                        expDetail.Particulars = Convert.ToInt32(particu);
                        expDetail.AccountToCharged = acctCharge;
                        //expDetail.VAT = Convert.ToDecimal(vat_amnt);
                        //expDetail.EWT = Convert.ToDecimal(ewt_amnt);
                        expDetail.ExpDtl_Currency = currency;
                        //expDetail.ExpDtl_IO = string.IsNullOrEmpty(io) ? (string)null : io;
                        //expDetail.ExpDtl_WBS = string.IsNullOrEmpty(wbs) ? (string)null : wbs;
                        expDetail.ExpDetail_remarks = remarks;
                        expDetail.Qty = Convert.ToDecimal(qty);
                        expDetail.UnitPrice = Convert.ToDecimal(unit_price);
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
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOExpenseId"]))
                    .Where(x => x.isTravel != true)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true);

                //var rfpReim = _DataContext.ACCEDE_T_RFPMains
                //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOExpenseId"]))
                //    .Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true)
                //    .Where(x => x.isTravel != true)
                //    .FirstOrDefault();

                var expDetails = _DataContext.ACCEDE_T_ExpenseDetails
                    .Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["NonPOExpenseId"]));

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

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlExpMap.SelectParameters["ExpenseReportDetail_ID"].DefaultValue = e.Parameters.ToString();
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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(actDetails.Document_Id)).FirstOrDefault();

                    var FinApproverVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .Where(x => x.Role_Name == "Accede Finance Approver")
                    .FirstOrDefault();

                    if (FinApproverVerify != null && actDetails.WF_Id == exp_main.FAPWF_Id)
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

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
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

                    exp_main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    exp_main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    exp_main.CostCenter = costCenter;
                    exp_main.ExpenseClassification = Convert.ToInt32(ClassType);
                    exp_main.Exp_Currency = curr;
                    exp_main.PaymentType = Convert.ToInt32(payType);

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
                            new_activity_exp.CompanyId = exp_main.CompanyId;
                            new_activity_exp.Document_Id = exp_main.ID;
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

                            SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString(), "");

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

        protected void DocuGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["ExpDetailsID"] = null;

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
    }

}