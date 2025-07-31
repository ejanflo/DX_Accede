using DevExpress.Data.Filtering.Helpers;
using DevExpress.Drawing;
using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class RFPApprovalView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        string conString = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (AnfloSession.Current.ValidCookieUser())
            {
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                try
                {
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

                            //sqlMain.SelectParameters["UserId"].DefaultValue = empCode;
                            int actID = Convert.ToInt32(Decrypt(encryptedID)); // Implement the Decrypt method securely
                                                                 // Use actID as needed

                            var actDetails = _DataContext.ITP_T_WorkflowActivities
                                .Where(x => x.WFA_Id == actID).FirstOrDefault();

                            var wfDetails = _DataContext.ITP_S_WorkflowDetails
                                .Where(x=>x.WF_Id == actDetails.WF_Id)
                                .Where(x=>x.WFD_Id == actDetails.WFD_Id)
                                .FirstOrDefault();

                            var nxWFDetails = _DataContext.ITP_S_WorkflowDetails
                                .Where(x=>x.WF_Id == actDetails.WF_Id)
                                .Where(x=>x.Sequence == (Convert.ToInt32(wfDetails.Sequence) + 1))
                                .FirstOrDefault();

                            var if_WF_isRA = _DataContext.ITP_S_WorkflowHeaders
                                .Where(x => x.WF_Id == wfDetails.WF_Id)
                                .FirstOrDefault();


                            var rfp_main = _DataContext.ACCEDE_T_RFPMains
                                .Where(x => x.ID == actDetails.Document_Id)
                                .FirstOrDefault();

                            var exp_details = _DataContext.ACCEDE_T_ExpenseMains
                                .Where(x => x.ID == rfp_main.Exp_ID)
                                .FirstOrDefault();

                            var app_docType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE RFP")
                                .Where(x => x.App_Id == 1032)
                                .FirstOrDefault();

                            var rfpType = _DataContext.ACCEDE_S_RFPTranTypes
                                .Where(x => x.ID == Convert.ToInt32(rfp_main.TranType))
                                .FirstOrDefault();

                            if (Convert.ToBoolean(rfp_main.isTravel) != true)
                            {
                                lbl_TranType.Text = rfpType.RFPTranType_Name + " - Non Travel";
                            }
                            else
                            {
                                lbl_TranType.Text = rfpType.RFPTranType_Name;
                            }

                            var disburse_stat = _DataContext.ITP_S_Status
                                .Where(x => x.STS_Name == "Disbursed")
                                .FirstOrDefault();

                            var pld = formRFP.FindItemOrGroupByName("pld") as LayoutItem;
                            var wbs = formRFP.FindItemOrGroupByName("wbs") as LayoutItem;
                            var ldt = formRFP.FindItemOrGroupByName("ldt") as LayoutItem;
                            var aaf = formRFP.FindItemOrGroupByName("AAF") as LayoutItem;

                            if(nxWFDetails == null && if_WF_isRA.IsRA != true)
                            {
                                aaf.ClientVisible = true;
                            }

                            if (rfp_main != null)
                            {
                                var myLayoutGroup = formRFP.FindItemOrGroupByName("ApprovalPage") as LayoutGroup;
                                var CALayoutGroup = formRFP.FindItemOrGroupByName("Unliq_CA") as LayoutGroup;

                                if (myLayoutGroup != null)
                                {
                                    //var tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x=>x.ID == rfp_main.TranType).FirstOrDefault();
                                    //var tranTypeName = tranType != null ? tranType.RFPTranType_Name : "";
                                    //myLayoutGroup.Caption = tranTypeName + " " + rfp_main.RFP_DocNum.ToString() + " (View)";
                                    myLayoutGroup.Caption = rfp_main.RFP_DocNum.ToString() + " (View)";
                                }

                                if (rfp_main.isTravel == true)
                                {
                                    ldt.Visible = true;

                                    if (rfp_main.isForeignTravel != null && rfp_main.isForeignTravel == true)
                                    {
                                        lbl_TravType.Text = "Foreign";
                                    }
                                    else
                                    {
                                        lbl_TravType.Text = "Domestic";
                                    }
                                }

                                if (rfp_main.Company_ID == 5)
                                {
                                    wbs.Visible = true;
                                }

                                if (rfp_main.TranType == 1)
                                {
                                    pld.Visible = true;
                                    if (rfp_main.PLDate != null)
                                    {
                                        DateTime date = Convert.ToDateTime(rfp_main.PLDate.ToString());
                                        lbl_pld.Value = date.ToString("MM/dd/yyyy");
                                    }

                                }
                                if (exp_details != null)
                                {
                                    lbl_expLink.Text = exp_details.DocNo.ToString();
                                }
                                else
                                {
                                    ExpBtn.Visible = false;
                                }

                                if (rfp_main.AcctCharged != null && rfp_main.AcctCharged != 0)
                                {

                                    edit_AcctCharged.Value = rfp_main.AcctCharged;
                                    edit_AcctCharged.DataBind();
                                }

                                var unliquidated_CA = _DataContext.ACCEDE_T_RFPMains
                                    .Where(x => x.IsExpenseCA == true)
                                    .Where(x => x.Status == Convert.ToInt32(disburse_stat.STS_Id))
                                    .Where(x => x.User_ID == rfp_main.User_ID);

                                if (unliquidated_CA.Count() > 0)
                                {
                                    CALayoutGroup.Caption = "There is/are " + unliquidated_CA.Count().ToString() + " unliquidated Cash Advance/s.";
                                    CALayoutGroup.ParentContainerStyle.ForeColor = System.Drawing.Color.Red;
                                }
                                else
                                {
                                    CALayoutGroup.Caption = "There are no unliquidated Cash Advance/s.";

                                }

                                

                            }
                            

                            var FinApproverVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                                .Where(x => x.UserId == empCode)
                                .Where(x => x.Role_Name == "Accede Finance Approver")
                                .FirstOrDefault();

                            var lbl_CTcomp = formRFP.FindItemOrGroupByName("lblCTComp") as LayoutItem;
                            var lbl_CTdept = formRFP.FindItemOrGroupByName("lblCTDept") as LayoutItem;
                            var lbl_CostCenter = formRFP.FindItemOrGroupByName("lblCostCenter") as LayoutItem;
                            var edit_CTcomp = formRFP.FindItemOrGroupByName("editCTComp") as LayoutItem;
                            var edit_CTdept = formRFP.FindItemOrGroupByName("editCTDept") as LayoutItem;
                            var edit_CostCenter = formRFP.FindItemOrGroupByName("editCostCenter") as LayoutItem;
                            var lbl_classType = formRFP.FindItemOrGroupByName("lblClassType") as LayoutItem;
                            var edit_classType = formRFP.FindItemOrGroupByName("editClassType") as LayoutItem;
                            var lbl_TravelType = formRFP.FindItemOrGroupByName("lblTravelType") as LayoutItem;
                            var lbl_LDOT = formRFP.FindItemOrGroupByName("lblLDOT") as LayoutItem;

                            

                            if (FinApproverVerify != null)
                            {
                                var lbl_PM = formRFP.FindItemOrGroupByName("lbl_PM") as LayoutItem;
                                var lbl_IO = formRFP.FindItemOrGroupByName("lbl_IO") as LayoutItem;
                                var lbl_Acct = formRFP.FindItemOrGroupByName("lbl_Acct") as LayoutItem;
                                var edit_PM = formRFP.FindItemOrGroupByName("edit_PM") as LayoutItem;
                                var edit_IO = formRFP.FindItemOrGroupByName("edit_IO") as LayoutItem;
                                var edit_Acct = formRFP.FindItemOrGroupByName("edit_Acct") as LayoutItem;
                                var amnt = formRFP.FindItemOrGroupByName("Amount_lbl") as LayoutItem;

                                lbl_PM.ClientVisible = false;
                                edit_PM.ClientVisible = true;

                                lbl_CTcomp.ClientVisible = false;
                                lbl_CTdept.ClientVisible = false;
                                lbl_CostCenter.ClientVisible = false;
                                edit_CTcomp.ClientVisible = true;
                                edit_CTdept.ClientVisible = true;
                                edit_CostCenter.ClientVisible = true;
                                

                                if (rfp_main.PayMethod != null)
                                {
                                    edit_PM.FieldName = "PayMethod";
                                }

                                if (rfp_main.isTravel == true)
                                {
                                    lbl_TravelType.ClientVisible = true;
                                    lbl_LDOT.ClientVisible = true;
                                    lbl_classType.ClientVisible = false;
                                    edit_classType.ClientVisible = false;
                                }
                                else
                                {
                                    edit_classType.ClientVisible = true;
                                    lbl_classType.ClientVisible = false;
                                }

                                lbl_IO.ClientVisible = false;
                                edit_IO.ClientVisible = true;

                                lbl_Acct.ClientVisible = false;
                                edit_Acct.ClientVisible = true;

                                if (rfp_main.AcctCharged != null && rfp_main.AcctCharged != 0)
                                {

                                    edit_Acct.FieldName = "AcctCharged";
                                }


                            }
                            else
                            {
                                if (rfp_main.isTravel == true)
                                {
                                    lbl_TravType.ClientVisible = true;
                                    lbl_LDOT.ClientVisible = true;
                                    lbl_classType.ClientVisible = false;
                                    edit_classType.ClientVisible = false;
                                }
                                else
                                {
                                    lbl_classType.ClientVisible = true;
                                }
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
                                    .Where(x=>x.Company_Id == rfp_main.Company_ID)
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
                            }else if(FinCFOVerify != null)
                            {
                                var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Name.Contains("forward pres"))
                                    .Where(x => x.Company_Id == rfp_main.Company_ID)
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
                                    .Where(x => x.Company_Id == rfp_main.Company_ID)
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


                            lbl_Amount.Value = rfp_main.Currency + " " + Convert.ToDecimal(rfp_main.Amount).ToString("#,#00.00");

                            SqlActivity.SelectParameters["Document_Id"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp_main.WF_Id.ToString();
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_main.FAPWF_Id.ToString();
                            SqlMain.SelectParameters["ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlRFPDocs.SelectParameters["Doc_ID"].DefaultValue = actDetails.Document_Id.ToString();
                            SqlRFPDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";
                            SqlCAHistory.SelectParameters["User_ID"].DefaultValue = rfp_main.User_ID.ToString();
                            SqlCAHistory.SelectParameters["Status"].DefaultValue = disburse_stat.STS_Id.ToString();
                            SqlCompany.SelectParameters["UserId"].DefaultValue = rfp_main.User_ID.ToString();
                            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = rfp_main.ChargedTo_CompanyId.ToString();
                            SqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = rfp_main.ChargedTo_DeptId.ToString();
                            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = rfp_main.ChargedTo_CompanyId.ToString();
                        }
                    }
                    }
                    
                catch (Exception ex)
                {
                    Response.Redirect("~/Logon.aspx");
                }
                    
            }
            else
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        protected void formRFP_Init(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        public static string btnApproveClickAjax(string approve_remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            RFPApprovalView rfp = new RFPApprovalView();
            var isApprove = rfp.btnApproveClick(approve_remarks, pMethod, io, acctCharge, cCenter, secureToken, CTComp_id, CTDept_id, ClassType);
            return isApprove;
        }

        public string btnApproveClick(string approve_remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var rfp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == rfp_id.Document_Id)
                        .FirstOrDefault();

                    var payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main.PayMethod)
                        .FirstOrDefault();

                    var tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main.TranType)
                        .FirstOrDefault();

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    // update RFP Main details
                    rfp_main.SAPCostCenter = cCenter;
                    rfp_main.PayMethod = Convert.ToInt32(pMethod);
                    rfp_main.IO_Num = io;
                    if (acctCharge != null && acctCharge != "")
                    {
                        rfp_main.AcctCharged = Convert.ToInt32(acctCharge);
                    }

                    if(rfp_main.isTravel != true)
                    {
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }

                    rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    var next_seq = 0;
                    var wf_detail = 0;


                    if (actDetails != null)
                    {
                        wf_detail = Convert.ToInt32(actDetails.WFD_Id);
                        actDetails.Status = 7;
                        actDetails.DateAction = DateTime.Now;
                        actDetails.Remarks = approve_remarks;
                        actDetails.ActedBy_User_Id = Session["userID"].ToString();

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
                            foreach (var del in _DataContext.ITP_S_TaskDelegations
                                .Where(x => x.OrgRole_ID_Orig == nex_org_role)
                                .Where(x => x.DateFrom <= date2day)
                                .Where(x => x.DateTo >= date2day)
                                .Where(x => x.isActive == true))
                            {
                                if (del != null)
                                {
                                    org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                                }

                            }

                            var app_docType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE RFP")
                                .Where(x => x.App_Id == 1032)
                                .FirstOrDefault();

                            ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                            {
                                new_activity.Status = 1;
                                new_activity.AppId = 1032;
                                new_activity.CompanyId = rfp_main.Company_ID;
                                new_activity.Document_Id = rfp_main.ID;
                                new_activity.WF_Id = wf_detail_query.WF_Id;
                                new_activity.DateAssigned = DateTime.Now;
                                new_activity.DateCreated = DateTime.Now;
                                new_activity.IsActive = true;
                                new_activity.OrgRole_Id = org_id;
                                new_activity.WFD_Id = nex_wf_detail_id;
                                new_activity.AppDocTypeId = app_docType.DCT_Id;
                            }
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                            ///////---START EMAIL PROCESS-----////////
                            foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles
                                .Where(x => x.OrgRoleId == org_id))
                            {
                                var nexApprover_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == user.UserId)
                                    .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Session["UserID"].ToString())
                                    .FirstOrDefault();

                                SendEmailTo(Convert.ToInt32(rfp_main.ID), nexApprover_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, approve_remarks, "Pending", payMethod.PMethod_name, tranType.RFPTranType_Name, "");

                            }
                        }
                        else //End of previous WF
                        {
                            if (actDetails.WF_Id == rfp_main.WF_Id)
                            {
                                //transition to finance wf
                                //var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032)
                                //                .Where(x => x.Company_Id == rfp_main.Company_ID)
                                //                .Where(x => x.Minimum <= rfp_main.Amount)
                                //                .Where(x => x.Maximum >= rfp_main.Amount)
                                //                .Where(x => x.IsRA != true || x.IsRA == null)
                                //                .Where(x => x.IsActive == true)
                                //                .FirstOrDefault();

                                var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.WF_Id == rfp_main.FAPWF_Id)
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
                                    foreach (var del in _DataContext.ITP_S_TaskDelegations
                                        .Where(x => x.OrgRole_ID_Orig == fin_wfDetail_data.OrgRole_Id)
                                        .Where(x => x.DateFrom <= date2day)
                                        .Where(x => x.DateTo >= date2day)
                                        .Where(x => x.isActive == true))
                                    {
                                        if (del != null)
                                        {
                                            org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                                        }

                                    }

                                    var app_docType = _DataContext.ITP_S_DocumentTypes
                                        .Where(x => x.DCT_Name == "ACDE RFP")
                                        .Where(x => x.App_Id == 1032)
                                        .FirstOrDefault();

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
                                        new_activity.AppDocTypeId = app_docType.DCT_Id;
                                    }
                                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                                    ///////---START EMAIL PROCESS-----////////
                                    foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles
                                        .Where(x => x.OrgRoleId == org_id))
                                    {
                                        var nexApprover_detail = _DataContext.ITP_S_UserMasters
                                            .Where(x => x.EmpCode == user.UserId)
                                            .FirstOrDefault();

                                        var sender_detail = _DataContext.ITP_S_UserMasters
                                            .Where(x => x.EmpCode == Session["UserID"].ToString())
                                            .FirstOrDefault();

                                        SendEmailTo(Convert.ToInt32(rfp_main.ID), nexApprover_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, approve_remarks, "Pending", payMethod.PMethod_name, tranType.RFPTranType_Name, "");

                                    }
                                }
                                else
                                {
                                    return "Finance WF data not found.";
                                }

                                //End of Finance WF transition
                            }
                            else
                            {
                                var payMethodDesc = _DataContext.ACCEDE_S_PayMethods
                                    .Where(x => x.ID == rfp_main.PayMethod)
                                    .FirstOrDefault();

                                var app_docType = _DataContext.ITP_S_DocumentTypes
                                    .Where(x => x.DCT_Name == "ACDE RFP")
                                    .Where(x => x.App_Id == 1032)
                                    .FirstOrDefault();

                                if (payMethodDesc.PMethod_desc == "Check")
                                {
                                    var P2PStatus = _DataContext.ITP_S_Status
                                        .Where(x => x.STS_Name == "Pending at P2P")
                                        .FirstOrDefault();

                                    rfp_main.Status = P2PStatus.STS_Id;


                                    ///////

                                    var wfID_p2p = _DataContext.ITP_S_WorkflowHeaders
                                        .Where(x => x.Company_Id == rfp_main.ChargedTo_CompanyId)
                                        .Where(x => x.Name == "ACDE P2P")
                                        .FirstOrDefault();

                                    if (wfID_p2p != null)
                                    {
                                        

                                        // GET WORKFLOW DETAILS ID
                                        var wfDetails_p2p = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                            where wfd.WF_Id == wfID_p2p.WF_Id && wfd.Sequence == 1
                                                            select wfd.WFD_Id;
                                        int wfdID_p2p = wfDetails_p2p.FirstOrDefault();

                                        // GET ORG ROLE ID
                                        var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                                      where or.WF_Id == wfID_p2p.WF_Id && or.Sequence == 1
                                                      select or.OrgRole_Id;
                                        int orID = (int)orgRole.FirstOrDefault();

                                        if (P2PStatus != null && orgRole != null)
                                        {
                                            //INSERT CASH ADVANCE ACTIVITY TO ITP_T_WorkflowActivity
                                            DateTime currentDate = DateTime.Now;
                                            ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                            {
                                                Status = P2PStatus.STS_Id,
                                                DateAssigned = currentDate,
                                                WF_Id = wfID_p2p.WF_Id,
                                                WFD_Id = wfdID_p2p,
                                                OrgRole_Id = orID,
                                                Document_Id = rfp_main.ID,
                                                AppId = 1032,
                                                ActedBy_User_Id = Session["userID"].ToString(),
                                                CompanyId = Convert.ToInt32(rfp_main.ChargedTo_CompanyId),
                                                AppDocTypeId = app_docType.DCT_Id,
                                                IsActive = true,
                                                Remarks = approve_remarks
                                            };
                                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                                        }

                                        _DataContext.SubmitChanges();
                                    }
                                    else
                                    {
                                        return "There is no workflow (ACDE P2P) setup for your company. Please contact Admin to setup the workflow.";
                                    }

                                    var creator_detail = _DataContext.ITP_S_UserMasters
                                        .Where(x => x.EmpCode == rfp_main.User_ID)
                                        .FirstOrDefault();

                                    var sender_detail = _DataContext.ITP_S_UserMasters
                                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                                        .FirstOrDefault();

                                    SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, approve_remarks, "Approve", payMethod.PMethod_name, tranType.RFPTranType_Name, "PendingP2P");

                                }
                                else
                                {
                                    var CashierStatus = _DataContext.ITP_S_Status
                                        .Where(x => x.STS_Name == "Pending at Cashier")
                                        .FirstOrDefault();

                                    rfp_main.Status = CashierStatus.STS_Id;

                                    var wfID_cash = _DataContext.ITP_S_WorkflowHeaders
                                        .Where(x => x.Company_Id == rfp_main.ChargedTo_CompanyId)
                                        .Where(x => x.Name == "ACDE CASHIER")
                                        .FirstOrDefault();

                                    if (wfID_cash != null)
                                    {
                                        var expDocType = _DataContext.ITP_S_DocumentTypes
                                            .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
                                            .Select(x => x.DCT_Id)
                                            .FirstOrDefault();

                                        // GET WORKFLOW DETAILS ID
                                        var wfDetails_cash = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                             where wfd.WF_Id == wfID_cash.WF_Id && wfd.Sequence == 1
                                                             select wfd.WFD_Id;
                                        int wfdID_cash = wfDetails_cash.FirstOrDefault();

                                        // GET ORG ROLE ID
                                        var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                                      where or.WF_Id == wfID_cash.WF_Id && or.Sequence == 1
                                                      select or.OrgRole_Id;
                                        int orID = (int)orgRole.FirstOrDefault();

                                        if (CashierStatus != null && orgRole != null)
                                        {
                                            //INSERT Reim ACTIVITY TO ITP_T_WorkflowActivity
                                            DateTime currentDate = DateTime.Now;
                                            ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                            {
                                                Status = CashierStatus.STS_Id,
                                                DateAssigned = currentDate,
                                                DateCreated = currentDate,
                                                WF_Id = wfID_cash.WF_Id,
                                                WFD_Id = wfdID_cash,
                                                OrgRole_Id = orID,
                                                Document_Id = rfp_main.ID,
                                                AppId = 1032,
                                                ActedBy_User_Id = Session["userID"].ToString(),
                                                CompanyId = Convert.ToInt32(rfp_main.ChargedTo_CompanyId),
                                                AppDocTypeId = app_docType.DCT_Id,
                                                IsActive = true,
                                                Remarks = approve_remarks
                                            };
                                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                                        }

                                        _DataContext.SubmitChanges();

                                        var creator_detail = _DataContext.ITP_S_UserMasters
                                        .Where(x => x.EmpCode == rfp_main.User_ID)
                                        .FirstOrDefault();

                                        var sender_detail = _DataContext.ITP_S_UserMasters
                                            .Where(x => x.EmpCode == Session["UserID"].ToString())
                                            .FirstOrDefault();

                                        SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, approve_remarks, "Approve", payMethod.PMethod_name, tranType.RFPTranType_Name, "PendingCash");

                                    }
                                    else
                                    {
                                        return "There is no workflow (ACDE Cashier) setup for your company. Please contact Admin to setup the workflow.";
                                    }

                                }

                            }

                        }

                        _DataContext.SubmitChanges();
                    }

                    return "success";
                }

                return "Secure Token not found.";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static bool btnReturnClickAjax(string return_remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            RFPApprovalView rfp = new RFPApprovalView();
            return rfp.btnReturnClick(return_remarks, pMethod, io, acctCharge, cCenter, secureToken, CTComp_id, CTDept_id, ClassType);
        }

        public bool btnReturnClick(string remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            try
            {

                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var rfp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == rfp_id.Document_Id)
                        .FirstOrDefault();

                    var payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main.PayMethod)
                        .FirstOrDefault();

                    var tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main.TranType)
                        .FirstOrDefault();

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    actDetails.Status = 3;
                    actDetails.DateAction = DateTime.Now;
                    actDetails.Remarks = remarks;
                    actDetails.ActedBy_User_Id = Session["userID"].ToString();

                    // update RFP Main details
                    rfp_main.SAPCostCenter = cCenter;
                    rfp_main.PayMethod = Convert.ToInt32(pMethod);
                    rfp_main.IO_Num = io;
                    rfp_main.AcctCharged = Convert.ToInt32(acctCharge);
                    rfp_main.Status = 3;

                    if (rfp_main.isTravel != null)
                    {
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }

                    rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == rfp_main.User_ID)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, remarks, "Return", payMethod.PMethod_name, tranType.RFPTranType_Name, "");
                    _DataContext.SubmitChanges();

                    return true;
                }

                return false;
            }catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static bool btnDisapproveClickAjax(string disapprove_remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            RFPApprovalView rfp = new RFPApprovalView();
            return rfp.btnDisapproveClick(disapprove_remarks, pMethod, io, acctCharge, cCenter, secureToken, CTComp_id, CTDept_id, ClassType);
        }

        public bool btnDisapproveClick(string remarks, string pMethod, string io, string acctCharge, string cCenter, string secureToken, string CTComp_id, string CTDept_id, string ClassType)
        {
            try
            {

                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var rfp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == rfp_id.Document_Id)
                        .FirstOrDefault();

                    var payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main.PayMethod)
                        .FirstOrDefault();

                    var tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main.TranType)
                        .FirstOrDefault();

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    actDetails.Status = 8;
                    actDetails.DateAction = DateTime.Now;
                    actDetails.Remarks = remarks;
                    actDetails.ActedBy_User_Id = Session["userID"].ToString();

                    // update RFP Main details
                    rfp_main.SAPCostCenter = cCenter;
                    rfp_main.PayMethod = Convert.ToInt32(pMethod);
                    rfp_main.IO_Num = io;
                    rfp_main.AcctCharged = Convert.ToInt32(acctCharge);
                    rfp_main.Status = 8;

                    if (rfp_main.isTravel != null)
                    {
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }

                    rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == rfp_main.User_ID)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, remarks, "Disapprove", payMethod.PMethod_name, tranType.RFPTranType_Name, "");
                    _DataContext.SubmitChanges();

                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static bool SaveFinChangesAJAX(int payM, string SAPDoc, int AcctCharged, string cCenter)
        {
            RFPApprovalView rfp = new RFPApprovalView();

            return rfp.SaveFinChanges(payM, SAPDoc, AcctCharged, cCenter);
        }

        public bool SaveFinChanges(int payM, string SAPDoc, int AcctCharged, string cCenter)
        {
            try
            {
                string encryptedID = Request.QueryString["secureToken"];
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var act_details = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == Convert.ToInt32(act_details.Document_Id))
                        .FirstOrDefault();

                    rfp_main.PayMethod = payM;
                    rfp_main.SAPDocNo = SAPDoc;
                    rfp_main.AcctCharged = AcctCharged;
                    rfp_main.SAPCostCenter = cCenter;

                    _DataContext.SubmitChanges();

                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
            
        }

        public bool SendEmailTo(int doc_id, string receiver_id, int Comp_id, string sender_fullname, string sender_email, string doc_no, string date_created, string document_purpose, string remarks, string status, string payMethod, string tranType, string status2)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var rfp_detail = _DataContext.ACCEDE_T_RFPMains
                    .Where(x=>x.ID == doc_id)
                    .FirstOrDefault();

                var requestor_detail = _DataContext.ITP_S_UserMasters
                    .Where(x=>x.EmpCode == rfp_detail.Payee)
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
                    if(status2 == "PendingP2P")
                    {
                        emailSubMessage = "Your request is now pending at P2P for disbursement.";
                    }

                    if (status2 == "PendingCash")
                    {
                        emailSubMessage = "Your request is now pending at Cashier for disbursement of cash.";
                    }
                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                    emailSubTitle = text.Text3.ToString();
                }
                //End--     Get Text info

                string appName = "Request For Payment (RFP)";
                string recipientName = user_email.FName;
                string senderName = sender_fullname;
                string emailSender = sender_email;
                string emailSite = "https://apps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": "+ emailSubTitle;
                string requestorName = requestor_detail.FullName.ToString();


                ANFLO anflo = new ANFLO();

                //Body Details Sample
                string emailDetails = "";

                emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
                emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>";
                emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>";
                emailDetails += "<tr><td>Requestor</td><td><strong>" + requestorName + "</strong></td></tr>";
                emailDetails += "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>";
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
        public static string btnApproveForwardAJAX(string secureToken, string forwardWF, string remarks, string pMethod, string io, string acctCharge, string cCenter, string CTComp_id, string CTDept_id, string ClassType)
        {
            RFPApprovalView rfp = new RFPApprovalView();

            return rfp.btnApproveForward(secureToken, forwardWF, remarks, pMethod, io, acctCharge, cCenter, CTComp_id, CTDept_id, ClassType);

        }

        public string btnApproveForward(string secureToken, string forwardWF, string remarks, string pMethod, string io, string acctCharge, string cCenter, string CTComp_id, string CTDept_id, string ClassType)
        {
            try
            {
                string encryptedID = secureToken;

                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var rfp_id = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var actDetails = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.WFA_Id == actID)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == rfp_id.Document_Id)
                        .FirstOrDefault();

                    var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails
                        .Where(x => x.WF_Id == Convert.ToInt32(forwardWF))
                        .Where(x => x.Sequence == 1)
                        .FirstOrDefault();

                    var org_id = fin_wfDetail_data.OrgRole_Id;
                    var date2day = DateTime.Now;

                    // update RFP Main details
                    rfp_main.SAPCostCenter = cCenter;
                    rfp_main.PayMethod = Convert.ToInt32(pMethod);
                    rfp_main.IO_Num = io;
                    if (acctCharge != null && acctCharge != "")
                    {
                        rfp_main.AcctCharged = Convert.ToInt32(acctCharge);
                    }

                    if (rfp_main.isTravel != null)
                    {
                        rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    }

                    rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);

                    //DELEGATE CHECK
                    foreach (var del in _DataContext.ITP_S_TaskDelegations
                        .Where(x => x.OrgRole_ID_Orig == fin_wfDetail_data.OrgRole_Id)
                        .Where(x => x.DateFrom <= date2day)
                        .Where(x => x.DateTo >= date2day)
                        .Where(x => x.isActive == true))
                    {
                        if (del != null)
                        {
                            org_id = Convert.ToInt32(del.OrgRole_ID_Delegate);
                        }

                    }
                    var payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main.PayMethod)
                        .FirstOrDefault();

                    var tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main.TranType)
                        .FirstOrDefault();

                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

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
                        new_activity.AppDocTypeId = app_docType.DCT_Id;
                    }
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);

                    actDetails.Status = 7;
                    actDetails.DateAction = DateTime.Now;
                    actDetails.Remarks = remarks;
                    actDetails.ActedBy_User_Id = Session["userID"].ToString();

                    // update RFP Main details
                    rfp_main.Status = 1;

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == rfp_main.User_ID)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();


                    SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.Company_ID), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, remarks, "Return", payMethod.PMethod_name, tranType.RFPTranType_Name, "");
                    _DataContext.SubmitChanges();

                    return "success";
                }

                return "Secure token is null.";
            }
            catch(Exception ex)
            {
                return ex.Message;
            }
            
        }

        protected void edit_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            edit_Department.DataSourceID = null;
            edit_Department.DataSource = SqlCTDepartment;
            edit_Department.DataBind();
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp_id = param[0];
            var Dept_id = param[1] != "null" ? param[1] : "0";

            var dept_details = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(Dept_id)).FirstOrDefault();

            SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
            SqlCostCenterCT.DataBind();

            drpdown_CostCenter.DataSourceID = null;
            drpdown_CostCenter.DataSource = SqlCostCenterCT;
            drpdown_CostCenter.DataBind();

            if (dept_details != null)
            {
                drpdown_CostCenter.Value = dept_details.SAP_CostCenter.ToString();
            }


            //var count = drpdown_CostCenter.Items.Count;
            //if(count == 1)
            //    drpdown_CostCenter.SelectedIndex = 0; drpdown_CostCenter.DataBind();

        }
    }
}