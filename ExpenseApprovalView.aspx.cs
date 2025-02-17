using DevExpress.Data.Linq.Helpers;
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

namespace DX_WebTemplate
{
    public partial class ExpenseApprovalView : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

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

                            int actID = Convert.ToInt32(Decrypt(encryptedID));
                            
                            var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                            Session["ExpId"] = wfDetails.Document_Id;
                            sqlMain.SelectParameters["ID"].DefaultValue = wfDetails.Document_Id.ToString();
                            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = wfDetails.Document_Id.ToString();
                            SqlCADetails.SelectParameters["Exp_ID"].DefaultValue = wfDetails.Document_Id.ToString();
                            SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = wfDetails.Document_Id.ToString();
                            SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = wfDetails.Document_Id.ToString();
                            SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = wfDetails.Document_Id.ToString();

                            var exp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();
                            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                            var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == Convert.ToInt32(exp.ExpenseType_ID)).FirstOrDefault();
                            if (Convert.ToBoolean(exp.isTravel) != true)
                            {
                                txt_ExpType.Text = expType.Description + " - Non Travel";
                            }
                            else
                            {
                                txt_ExpType.Text = expType.Description;
                            }

                            txt_ReportDate.Text = Convert.ToDateTime(exp.ReportDate).ToString("MMMM dd, yyyy");
                            var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;

                            if (myLayoutGroup != null)
                            {
                                myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";
                            }

                            var RFPCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(wfDetails.Document_Id)).Where(x => x.IsExpenseCA == true);
                            decimal totalCA = 0;
                            foreach (var item in RFPCA)
                            {
                                totalCA += Convert.ToDecimal(item.Amount);
                            }
                            caTotal.Text = totalCA.ToString("#,##0.00") + "  " + exp.Exp_Currency + " ";

                            var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(wfDetails.Document_Id));
                            decimal totalExp = 0;
                            foreach (var item in ExpDetails)
                            {
                                totalExp += Convert.ToDecimal(item.NetAmount);
                            }
                            expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + exp.Exp_Currency + " ";

                            decimal dueComp = totalCA - totalExp;
                            if (dueComp < 0)
                            {
                                var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                                dueField.Caption = "Net Due to Employee";
                            }
                            else
                            {
                                var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                                dueField.Caption = "Net Due to Company";
                            }


                            dueTotal.Text = "PHP " + FormatDecimal(dueComp) + "  " + exp.Exp_Currency + " ";

                            grossAmount_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            netAmount_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            vat_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            ewt_edit.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;

                            gross_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            net_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            vat_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;
                            ewt_lbl.DisplayFormatString = "#,##0.00" + " " + exp.Exp_Currency;

                        }
                        else
                        {
                            Response.Redirect("~/AccedeApprovalPage.aspx");
                        }
                    }
                    
                }
                catch (Exception ex)
                {
                    //Session["MyRequestPath"] = Request.Url.AbsoluteUri;
                    Response.Redirect("~/AccedeApprovalPage.aspx");
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
            var expDetail = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpId"])).FirstOrDefault();
            SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = expDetail.WF_Id.ToString();
            SqlWFSequence.DataBind();

            WFGrid.DataSourceID = null;
            WFGrid.DataSource = SqlWFSequence;
            WFGrid.DataBind();

        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            var expDetail = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpId"])).FirstOrDefault();
            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = expDetail.FAPWF_Id.ToString();
            SqlFAPWFSequence.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWFSequence;
            FAPWFGrid.DataBind();
        }

        [WebMethod]
        public static string btnApproveClickAjax(string approve_remarks, string secureToken)
        {
            ExpenseApprovalView rfp = new ExpenseApprovalView();
            var isApprove = rfp.btnApproveClick(approve_remarks, secureToken);
            return isApprove;
        }

        public string btnApproveClick(string remarks, string secureToken)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));

                    var act_detail_id = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == act_detail_id.Document_Id).FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == act_detail_id.Document_Id)
                        .Where(x => x.Status != 4)
                        .Where(x => x.IsExpenseReim == true)
                        .FirstOrDefault();

                    var payMethod = "";
                    var tranType = "";

                    if (rfp_main != null)
                    {
                        payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault().PMethod_name;
                        tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfp_main.TranType).FirstOrDefault().RFPTranType_Name;
                    }
                    else
                    {
                        var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == act_detail_id.Document_Id).Where(x => x.IsExpenseCA == true).FirstOrDefault();
                        payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main_ca.PayMethod).FirstOrDefault().PMethod_name;
                        tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfp_main_ca.TranType).FirstOrDefault().RFPTranType_Name;
                    }


                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();
                    var exp_app_doctype = act_detail_id.AppDocTypeId;

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

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

                        //Update expense Activity
                        ExpActDetails.Status = 7;
                        ExpActDetails.DateAction = DateTime.Now;
                        ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                        ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                        //Update reimburse Activity
                        if (reimActDetails != null)
                        {
                            reimActDetails.Status = 7;
                            reimActDetails.DateAction = DateTime.Now;
                            reimActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                            reimActDetails.ActedBy_User_Id = Session["userID"].ToString();
                        }

                        var wf_detail_query = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WFD_Id == wf_detail).FirstOrDefault();
                        var wfHead_data = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.WF_Id == wf_detail_query.WF_Id).FirstOrDefault();

                        next_seq = Convert.ToInt32(wf_detail_query.Sequence) + 1;

                        var nex_wf_detail_query = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == wf_detail_query.WF_Id).Where(x => x.Sequence == next_seq).FirstOrDefault();

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
                                    new_activity.CompanyId = rfp_main.Company_ID;
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
                                new_activity_exp.CompanyId = exp_main.CompanyId;
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
                                var nexApprover_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == user.UserId)
                                          .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                                          .FirstOrDefault();

                                SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString());

                            }
                        }
                        else //End of previous WF
                        {
                            if (wfHead_data.IsRA == true)
                            {
                                //transition to finance wf
                                var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.WF_Id == exp_main.FAPWF_Id).FirstOrDefault();

                                if (finance_wf_data != null)
                                {
                                    var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == finance_wf_data.WF_Id).Where(x => x.Sequence == 1).FirstOrDefault();
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
                                        var nexApprover_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == user.UserId)
                                                  .FirstOrDefault();

                                        var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                                                  .FirstOrDefault();

                                        SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString());

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
                                var pending_audit = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                                if (rfp_main != null)
                                {
                                    rfp_main.Status = Convert.ToInt32(pending_audit.STS_Id);
                                }

                                exp_main.Status = Convert.ToInt32(pending_audit.STS_Id);

                                var creator_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == exp_main.UserId)
                                                  .FirstOrDefault();

                                var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                                          .FirstOrDefault();

                                SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Approve", payMethod.ToString(), tranType.ToString());

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
        public static string btnReturnClickAjax(string return_remarks, string secureToken)
        {
            ExpenseApprovalView rfp = new ExpenseApprovalView();
            return rfp.btnReturnClick(return_remarks, secureToken);
        }

        public string btnReturnClick(string remarks, string secureToken)
        {
            try
            {

                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var exp_id = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == exp_id.Document_Id).FirstOrDefault();
                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_id.Document_Id)
                        .Where(x => x.IsExpenseReim == true)
                        .Where(x => x.Status != 4)
                        .FirstOrDefault();

                    //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                    var tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID).FirstOrDefault();

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

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    //Update Expense Activity
                    ExpActDetails.Status = 3;
                    ExpActDetails.DateAction = DateTime.Now;
                    ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                    ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                    exp_main.Status = 3;

                    var creator_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == exp_main.UserId)
                                                  .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                              .FirstOrDefault();


                    SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Return", "", tranType.Description);
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
            ExpenseApprovalView rfp = new ExpenseApprovalView();
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
                    var exp_id = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == exp_id.Document_Id).FirstOrDefault();
                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_id.Document_Id)
                        .Where(x => x.IsExpenseReim == true)
                        .FirstOrDefault();

                    //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                    var tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID).FirstOrDefault();

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

                    var ExpActDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();

                    //Update Expense Activity
                    ExpActDetails.Status = 8;
                    ExpActDetails.DateAction = DateTime.Now;
                    ExpActDetails.Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";";
                    ExpActDetails.ActedBy_User_Id = Session["userID"].ToString();

                    exp_main.Status = 8;

                    var creator_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == exp_main.UserId)
                                                  .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                              .FirstOrDefault();


                    SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Disapprove", "", tranType.Description);
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
            var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x=>x.ID == item_id).FirstOrDefault();
            RFPDetails rfp = new RFPDetails();
            if (rfpCA != null)
            {
                var compName = _DataContext.CompanyMasters.Where(x=>x.WASSId == rfpCA.Company_ID).FirstOrDefault().CompanyShortName;
                var deptName = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfpCA.Department_ID).FirstOrDefault().DepDesc;
                var payMethName = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfpCA.PayMethod).FirstOrDefault().PMethod_name;
                var tranTypeName = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfpCA.TranType).FirstOrDefault().RFPTranType_Name;

                rfp.company = compName != null ? compName : "";
                rfp.department = deptName != null ? deptName : "";
                rfp.payMethod = payMethName != null ? payMethName : "";
                rfp.tranType = tranTypeName != null ? tranTypeName : "";
                rfp.CostCenter = rfpCA.SAPCostCenter != null ? rfpCA.SAPCostCenter : "";
                rfp.payee = rfpCA.Payee != null ? rfpCA.Payee : "";
                rfp.purpose = rfpCA.Purpose != null ? rfpCA.Purpose : "";
                rfp.amount = rfpCA.Amount != null ? rfpCA.Amount.ToString() : "";
                rfp.currency = rfpCA.Currency != null ? rfpCA.Currency : "";
                rfp.docNum = rfpCA.RFP_DocNum != null ? rfpCA.RFP_DocNum : "";
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
            var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == item_id).FirstOrDefault();
            RFPDetails rfp = new RFPDetails();
            if (rfpReim != null)
            {
                var compName = _DataContext.CompanyMasters.Where(x => x.WASSId == rfpReim.Company_ID).FirstOrDefault().CompanyShortName;
                var deptName = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfpReim.Department_ID).FirstOrDefault().DepDesc;
                var payMethName = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfpReim.PayMethod).FirstOrDefault().PMethod_name;
                var tranTypeName = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfpReim.TranType).FirstOrDefault().RFPTranType_Name;
                var payeeName = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == rfpReim.Payee).FirstOrDefault();

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
            }
            return rfp;
        }

        [WebMethod]
        public static string SaveReimDetailsAJAX(string payMethod)
        {
            ExpenseApprovalView exp = new ExpenseApprovalView();
            return exp.SaveReimDetails(payMethod);
        }

        public string SaveReimDetails(string payMethod)
        {
            try
            {
                var reimDetails = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["Reim_edit_id"])).FirstOrDefault();
                reimDetails.PayMethod = Convert.ToInt32(payMethod);

                var caDetails = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(reimDetails.Exp_ID))
                    .Where(x => x.IsExpenseCA == true);

                if(caDetails.Count() == 0 )
                {
                    var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x=>x.ID == Convert.ToInt32(reimDetails.Exp_ID)).FirstOrDefault();
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

        [WebMethod]
        public static ExpItemDetails DisplayExpDetailsAJAX(int item_id)
        {
            ExpenseApprovalView exp = new ExpenseApprovalView();
            return exp.DisplayExpDetails(item_id);

        }

        public ExpItemDetails DisplayExpDetails(int item_id)
        {
            var expMain = _DataContext.vw_ACCEDE_I_ExpenseDetails.Where(x=>x.ExpenseReportDetail_ID == item_id).FirstOrDefault();
            ExpItemDetails exp = new ExpItemDetails();
            if(expMain != null)
            {
                var acct_charge = _DataContext.ACDE_T_MasterCodes.Where(x => x.ID == Convert.ToInt32(expMain.AccountToCharged)).FirstOrDefault();
                //var cost_center = _DataContext.ACCEDE_S_CostCenters.Where(x=>x.CostCenter_ID == Convert.ToInt32(expMain.CostCenterIOWBS)).FirstOrDefault();
                var cc = _DataContext.ACCEDE_S_CostCenters.Where(x=>x.CostCenter == expMain.CostCenterIOWBS).FirstOrDefault();
                DateTime dateAdd = Convert.ToDateTime(expMain.DateAdded);

                exp.acctCharge = acct_charge != null ? acct_charge.Description : "";
                exp.costCenter = cc != null ? cc.CostCenter.ToString() + " - " + cc.Department.ToString() : "";
                exp.particulars = expMain.P_Name != null ? expMain.P_Name.ToString() : "";
                exp.supplier = expMain.Supplier != null ? expMain.Supplier : "";
                exp.tin = expMain.TIN != null ? expMain.TIN : "";
                exp.invoice = expMain.InvoiceOR != null ? expMain.InvoiceOR : "";
                exp.gross = expMain.GrossAmount != null ? expMain.GrossAmount.ToString() : "";
                exp.dateCreated = dateAdd != null ? dateAdd.ToString("MMMM dd, yyyy") : "";
                exp.net = expMain.NetAmount != null ? expMain.NetAmount.ToString() : "0.00";
                exp.vat = expMain.VAT != null ? expMain.VAT.ToString() : "0.00";
                exp.ewt = expMain.EWT != null ? expMain.EWT.ToString() : "0.00";
                exp.io = expMain.ExpDtl_IO != null ? expMain.ExpDtl_IO.ToString() : "";
                exp.wbs = expMain.ExpDtl_WBS != null ? expMain.ExpDtl_WBS.ToString() : "";
            }

            Session["ExpMainId"] = item_id.ToString();

            return exp;
        }

        public bool SendEmailTo(int doc_id, string receiver_id, int Comp_id, string sender_fullname, string sender_email, string doc_no, string date_created, string document_purpose, string remarks, string status, string payMethod, string tranType)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains.Where(x=>x.ID == doc_id).FirstOrDefault();

                var requestor_detail = _DataContext.ITP_S_UserMasters.Where(x=>x.EmpCode == exp_main.ExpenseName).FirstOrDefault();
                var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == receiver_id)
                                    .FirstOrDefault();

                var comp_name = _DataContext.CompanyMasters.Where(x => x.WASSId == Comp_id)
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
                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                    emailSubTitle = text.Text3.ToString();
                }
                //End--     Get Text info

                string appName = "ACCEDE Expense Report";
                string recipientName = user_email.FName;
                string senderName = sender_fullname;
                string emailSender = sender_email;
                string emailSite = "https://devapps.anflocor.com";
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
                emailDetails += "<tr><td>Requestor</td><td><strong>" + requestorName + "</strong></td></tr>";
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
        public static string SaveExpDetailsAJAX(string net_amount, string vat_amnt, string ewt_amnt, string io, string wbs)
        {
            ExpenseApprovalView exp = new ExpenseApprovalView();
            return exp.SaveExpDetails(net_amount, vat_amnt, ewt_amnt, io, wbs);
        }

        public string SaveExpDetails(string net_amount, string vat_amnt, string ewt_amnt, string io, string wbs)
        {
            try
            {
                var expDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x=>x.ExpenseReportDetail_ID == Convert.ToInt32(Session["ExpMainId"])).FirstOrDefault();
                expDetails.NetAmount = Convert.ToDecimal(net_amount);
                expDetails.VAT = Convert.ToDecimal(vat_amnt);
                expDetails.EWT = Convert.ToDecimal(ewt_amnt);
                expDetails.ExpDtl_IO = io;
                expDetails.ExpDtl_WBS = wbs;


                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x=>x.Exp_ID == Convert.ToInt32(expDetails.ExpenseMain_ID)).Where(x=>x.IsExpenseReim == true).FirstOrDefault();

                if(reim != null)
                {
                    reim.Amount = Convert.ToDecimal(net_amount);
                }

                _DataContext.SubmitChanges();

                return "success";

            }
            catch (Exception e)
            {
                return e.Message;
            }
        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {

        }

        protected void ExpGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnEdit") // Ensure it's a data row and the button is the desired one
            {
                var FinApproverVerify = _DataContext.vw_ACCEDE_FinApproverVerifies.Where(x => x.UserId == Session["userID"].ToString())
                        .Where(x => x.Role_Name == "Accede Finance Approver").FirstOrDefault();

                if (FinApproverVerify != null)
                {
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                }
                else
                {
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
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
        public static string btnApproveForwardAJAX(string secureToken, string forwardWF, string remarks)
        {
            RFPApprovalView rfp = new RFPApprovalView();

            return rfp.btnApproveForward(secureToken, forwardWF, remarks);

        }

        public string btnApproveForward(string secureToken, string forwardWF, string remarks)
        {
            try
            {
                string encryptedID = secureToken;

                if (!string.IsNullOrEmpty(encryptedID))
                {
                    var actID = Convert.ToInt32(Decrypt(encryptedID));
                    var exp_id = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();
                    var finance_wf_data = _DataContext.ITP_S_WorkflowHeaders
                        .Where(x => x.WF_Id == Convert.ToInt32(forwardWF))
                        .FirstOrDefault();

                    var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == exp_id.Document_Id)
                        .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == exp_id.Document_Id)
                        .Where(x => x.Status != 4)
                        .Where(x => x.IsExpenseReim == true)
                        .FirstOrDefault();

                    var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    var exp_app_doctype = exp_id.AppDocTypeId;

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
                    else
                    {
                        var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                            .Where(x => x.Exp_ID == exp_id.Document_Id)
                            .Where(x => x.IsExpenseCA == true)
                            .FirstOrDefault();
                        payMethod = _DataContext.ACCEDE_S_PayMethods
                            .Where(x => x.ID == rfp_main_ca.PayMethod)
                            .FirstOrDefault().PMethod_name;
                        tranType = _DataContext.ACCEDE_S_RFPTranTypes
                            .Where(x => x.ID == rfp_main_ca.TranType)
                            .FirstOrDefault().RFPTranType_Name;
                    }

                    if (finance_wf_data != null)
                    {
                        var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails.Where(x => x.WF_Id == finance_wf_data.WF_Id).Where(x => x.Sequence == 1).FirstOrDefault();
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
                            var nexApprover_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == user.UserId)
                                      .FirstOrDefault();

                            var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                                      .FirstOrDefault();

                            SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Pending", payMethod.ToString(), tranType.ToString());

                        }
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
    }

    public class RFPDetails
    {
        public string company { get; set; }
        public string department { get; set; }
        public string payMethod { get; set; }
        public string CostCenter { get; set; }
        public string tranType { get; set; }
        public string payee { get; set; }
        public string purpose { get; set; }
        public string amount { get; set; }
        public string currency { get; set; }
        public string docNum { get; set; }
        public string payMethod_id { get; set; }
    }

    public class ExpItemDetails
    {
        public string particulars { get; set; }
        public string supplier { get; set; }
        public string tin { get; set; }
        public string invoice { get; set; }
        public string gross { get; set; }
        public string dateCreated { get; set; }
        public string acctCharge { get; set; }
        public string costCenter { get; set; }
        public string net { get; set; }
        public string vat { get; set; }
        public string ewt { get; set; }
        public string io { get; set; }
        public string wbs { get; set; }
    }

}