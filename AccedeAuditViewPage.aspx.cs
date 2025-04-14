using DevExpress.Pdf.Native.BouncyCastle.Ocsp;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Security.Cryptography;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeExpenseReportEdit1;
using static DX_WebTemplate.TravelExpenseAdd;

namespace DX_WebTemplate
{
    public partial class AccedeAuditViewPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

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

                    //var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(Session["PassActID"])).FirstOrDefault();
                    var exp_details = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(Session["ExpId_audit"]))
                        .FirstOrDefault();

                    //Session["ExpId_audit"] = wfDetails.Document_Id;
                    sqlMain.SelectParameters["ID"].DefaultValue = exp_details.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = exp_details.ID.ToString();
                    SqlCA.SelectParameters["Exp_ID"].DefaultValue = exp_details.ID.ToString();
                    SqlReim.SelectParameters["Exp_ID"].DefaultValue = exp_details.ID.ToString();
                    SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = exp_details.ID.ToString();
                    SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = exp_details.ID.ToString();
                    SqlCADetails.SelectParameters["Exp_ID"].DefaultValue = exp_details.ID.ToString();
                    SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = exp_details.ID.ToString();

                    SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp_details.WF_Id).ToString();
                    SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp_details.FAPWF_Id).ToString();
                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";
                    var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;

                    if (myLayoutGroup != null)
                    {
                        myLayoutGroup.Caption = exp_details.DocNo.ToString() + " (View)";
                    }

                    var RFPCA = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(exp_details.ID))
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.isTravel != true);

                    decimal totalCA = 0;
                    foreach (var item in RFPCA)
                    {
                        totalCA += Convert.ToDecimal(item.Amount);
                    }
                    caTotal.Text = totalCA.ToString("#,##0.00") + "  PHP ";

                    var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                        .Where(x => x.ExpenseMain_ID == Convert.ToInt32(exp_details.ID));

                    decimal totalExp = 0;
                    foreach (var item in ExpDetails)
                    {
                        totalExp += Convert.ToDecimal(item.NetAmount);
                    }
                    expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";

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

                        if (dueComp > 0)
                        {
                            var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                            AR_Reference.ClientVisible = true;
                        }
                    }


                    dueTotal.Text = "PHP " + FormatDecimal(dueComp) + "  PHP ";

                    //GENERATE AAF WF
                    var forwardWFList = _DataContext.vw_ACCEDE_I_ApproveForwardWFs
                                    .Where(x => x.Company_Id == exp_details.CompanyId)
                                    .Where(x => x.Name.Contains("forward cfo") || x.Name.Contains("forward exec") || x.Name.Contains("forward pres"))
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
                    //END APPROVER FORWARD WF

                    //LAST APPROVER DETAILS
                    var lastActDetails = _DataContext.ITP_S_WorkflowHeaders
                        .Where(x=>x.WF_Id == exp_details.FAPWF_Id)
                        .FirstOrDefault();

                    txt_FinanceWF.Value = lastActDetails.Name;
                    //END LAST APPROVER DETAILS

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
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId_audit"]))
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
                .Where(x => x.ID == Convert.ToInt32(Session["ExpId_audit"]))
                .FirstOrDefault();

            SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = expDetail.FAPWF_Id.ToString();
            SqlFAPWFSequence.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWFSequence;
            FAPWFGrid.DataBind();
        }

        [WebMethod]
        public static string btnApproveClickAjax(string approve_remarks)
        {
            AccedeAuditViewPage rfp = new AccedeAuditViewPage();
            return rfp.btnApproveClick(approve_remarks);
        }

        public string btnApproveClick(string approve_remarks)
        {
            try
            {
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["ExpId_audit"]))
                    .FirstOrDefault();

                var rfp_main_reimburse = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == exp_main.ID)
                    .Where(x => x.IsExpenseReim == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var rfp_main_CA = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpId_audit"]))
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true);

                var liquidated_status = _DataContext.ITP_S_Status
                    .Where(x=>x.STS_Name == "Liquidated")
                    .FirstOrDefault();

                if (rfp_main_reimburse != null)
                {
                    var payMethodDesc = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main_reimburse.PayMethod)
                        .FirstOrDefault();

                    var tranTypeDesc = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main_reimburse.TranType)
                        .FirstOrDefault();

                    if (payMethodDesc.PMethod_desc == "Check")
                    {
                        var P2PStatus = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Name == "Pending at P2P")
                            .FirstOrDefault();

                        rfp_main_reimburse.Status = P2PStatus.STS_Id;
                        exp_main.Status = P2PStatus.STS_Id;
                        foreach(var item in rfp_main_CA)
                        {
                            item.Status = liquidated_status.STS_Id;
                        }
                    }
                    else
                    {
                        var Cash_status = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Name == "Pending at Cashier")
                            .FirstOrDefault();

                        rfp_main_reimburse.Status = Cash_status.STS_Id;
                        exp_main.Status = Cash_status.STS_Id;
                        foreach (var item in rfp_main_CA)
                        {
                            item.Status = liquidated_status.STS_Id;
                        }
                        var creator_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == rfp_main_reimburse.User_ID)
                            .FirstOrDefault();

                        var sender_detail = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == Session["UserID"].ToString())
                            .FirstOrDefault();

                        RFPApprovalView rfp = new RFPApprovalView();
                        rfp.SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(rfp_main_reimburse.ChargedTo_CompanyId), sender_detail.FullName, sender_detail.Email, rfp_main_reimburse.RFP_DocNum, rfp_main_reimburse.DateCreated.ToString(), rfp_main_reimburse.Purpose, approve_remarks, "Approve", payMethodDesc.PMethod_name, tranTypeDesc.RFPTranType_Name, "");

                    }
                }
                else
                {
                    var P2PStatus = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Pending at P2P")
                        .FirstOrDefault();
                    
                    exp_main.Status = P2PStatus.STS_Id;
                    foreach (var item in rfp_main_CA)
                    {
                        item.Status = liquidated_status.STS_Id;
                    }
                }

                var wfID = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.Company_Id == exp_main.ExpChargedTo_CompanyId)
                    .Where(x => x.Name == "ACDE AUDIT")
                    .FirstOrDefault();

                if(wfID != null)
                {
                    var expDocType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
                        .Select(x => x.DCT_Id)
                        .FirstOrDefault();

                    var returned_audit = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by Audit")
                        .FirstOrDefault();

                    var activityReturned = _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.AppDocTypeId == expDocType)
                        .Where(x => x.Document_Id == Convert.ToInt32(Session["ExpId_audit"]))
                        .Where(x=>x.Status == returned_audit.STS_Id)
                        .FirstOrDefault();

                    if(activityReturned != null)
                    {
                        activityReturned.Status = 7;
                        activityReturned.DateAction = DateTime.Now;
                    }
                    else
                    {
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
                            Status = 7,
                            DateAssigned = currentDate,
                            DateAction = currentDate,
                            WF_Id = wfID.WF_Id,
                            WFD_Id = wfdID,
                            OrgRole_Id = orID,
                            Document_Id = Convert.ToInt32(Session["ExpId_audit"]),
                            AppId = 1032,
                            Remarks = Session["AuthUser"].ToString() + ": " + approve_remarks + ";",
                            ActedBy_User_Id = Session["userID"].ToString(),
                            CompanyId = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId),
                            AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                            IsActive = true,
                        };
                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                        
                    }
                    _DataContext.SubmitChanges();

                }
                else
                {
                    return "There is no workflow (ACDE AUDIT) setup for your company. Please contact Admin to setup the workflow.";
                }
                

                return "success";
            }
            catch(Exception ex)
            {
                return ex.Message;
            }
            
        }

        [WebMethod]
        public static bool btnReturnClickAjax(string return_remarks)
        {
            AccedeAuditViewPage rfp = new AccedeAuditViewPage();
            return rfp.btnReturnClick(return_remarks);
        }

        public bool btnReturnClick(string remarks)
        {
            try
            {
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["ExpId_audit"]))
                    .FirstOrDefault();
                
                //var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main.PayMethod).FirstOrDefault();
                var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                    .Where(x => x.ExpenseType_ID == exp_main.ExpenseType_ID)
                    .FirstOrDefault();

                var returned_audit = _DataContext.ITP_S_Status
                    .Where(x=>x.STS_Name == "Returned by Audit")
                    .FirstOrDefault();

                if(returned_audit != null) 
                {
                    exp_main.Status = returned_audit.STS_Id;
                }

                var expDocType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
                    .Select(x => x.DCT_Id)
                    .FirstOrDefault();

                var activityReturned = _DataContext.ITP_T_WorkflowActivities
                    .Where(x => x.AppId == 1032)
                    .Where(x => x.AppDocTypeId == expDocType)
                    .Where(x => x.Document_Id == Convert.ToInt32(Session["ExpId_audit"]))
                    .Where(x => x.Status == returned_audit.STS_Id)
                    .FirstOrDefault();

                if (activityReturned != null)
                {
                    activityReturned.Status = returned_audit.STS_Id;
                    activityReturned.DateAction = DateTime.Now;
                }
                else
                {
                    var wfID = _DataContext.ITP_S_WorkflowHeaders
                        .Where(x => x.Company_Id == exp_main.ExpChargedTo_CompanyId)
                        .Where(x => x.Name == "ACDE AUDIT")
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
                        Status = returned_audit.STS_Id,
                        DateAssigned = currentDate,
                        DateAction = currentDate,
                        WF_Id = wfID.WF_Id,
                        WFD_Id = wfdID,
                        OrgRole_Id = orID,
                        Document_Id = Convert.ToInt32(Session["ExpId_audit"]),
                        AppId = 1032,
                        Remarks = Session["AuthUser"].ToString() + ": " + remarks + ";",
                        ActedBy_User_Id = Session["userID"].ToString(),
                        CompanyId = Convert.ToInt32(exp_main.ExpChargedTo_CompanyId),
                        AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                        IsActive = true,
                    };
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);

                    var creator_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == exp_main.UserId)
                        .FirstOrDefault();

                    var sender_detail = _DataContext.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Session["UserID"].ToString())
                        .FirstOrDefault();

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    exp.SendEmailTo(exp_main.ID, creator_detail.EmpCode, Convert.ToInt32(exp_main.ExpChargedTo_CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, remarks, "Return", "", tranType.Description, "");
                    _DataContext.SubmitChanges();
                }

                _DataContext.SubmitChanges();

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static ExpItemDetails DisplayExpDetailsAJAX1(int item_id)
        {
            AccedeAuditViewPage exp = new AccedeAuditViewPage();
            return exp.DisplayExpDetails(item_id);

        }

        public ExpItemDetails DisplayExpDetails(int item_id)
        {
            var expMain = _DataContext.vw_ACCEDE_I_ExpenseDetails
                .Where(x => x.ExpenseReportDetail_ID == item_id)
                .FirstOrDefault();

            ExpItemDetails exp = new ExpItemDetails();
            if (expMain != null)
            {
                var expMainMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(expMain.ExpenseMain_ID)).FirstOrDefault();
                var acct_charge = _DataContext.ACDE_T_MasterCodes
                    .Where(x => x.ID == Convert.ToInt32(expMain.AccountToCharged))
                    .FirstOrDefault();

                //var cost_center = _DataContext.ACCEDE_S_CostCenters.Where(x=>x.CostCenter_ID == Convert.ToInt32(expMain.CostCenterIOWBS)).FirstOrDefault();
                var cc = _DataContext.ITP_S_OrgDepartmentMasters
                    .Where(x => x.ID == Convert.ToInt32(expMainMain.ExpChargedTo_DeptId))
                    .FirstOrDefault();

                DateTime dateAdd = Convert.ToDateTime(expMain.DateAdded);

                exp.acctCharge = acct_charge != null ? acct_charge.Description : "";
                exp.costCenter = cc != null ? cc.SAP_CostCenter.ToString() : "";
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

            Session["ExpMainIdAudit"] = item_id;

            return exp;
        }

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        [WebMethod]
        public static string btnApproveForwardAJAX(string forwardWF, string remarks)
        {
            AccedeAuditViewPage rfp = new AccedeAuditViewPage();

            return rfp.btnApproveForward(forwardWF, remarks);

        }

        public string btnApproveForward(string forwardWF, string remarks)
        {
            try
            {
                int ExpID = Convert.ToInt32(Session["ExpId_audit"]);

                //Getting RFP reimbursement main details
                var rfp_main = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == ExpID)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                //Getting RFP doctype
                var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                //Getting expense doctype
                var exp_app_doctype = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                //Getting Forwarded Status
                var forwardStats = _DataContext.ITP_S_Status
                    .Where(x=>x.STS_Name == "Forward")
                    .FirstOrDefault();

                //Getting Expense Report Main details
                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == ExpID)
                    .FirstOrDefault(); 

                //Getting the forward WF details (Sequence 1)
                var fin_wfDetail_data = _DataContext.ITP_S_WorkflowDetails
                    .Where(x => x.WF_Id == Convert.ToInt32(forwardWF))
                    .Where(x => x.Sequence == 1).FirstOrDefault();
                    
                var org_id = fin_wfDetail_data.OrgRole_Id;
                var date2day = DateTime.Now;

                //DELEGATE CHECK and change org_id if there are any delegation
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
                //Getting Paymethod and TranType
                var payMethod = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfp_main.PayMethod)
                    .FirstOrDefault();

                var tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfp_main.TranType)
                    .FirstOrDefault();

                if (rfp_main != null)
                {
                    //Insert new activity to RFP Reimburse
                    ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                    {
                        new_activity.Status = 1;
                        new_activity.AppId = 1032;
                        new_activity.CompanyId = rfp_main.ChargedTo_CompanyId;
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
                    new_activity_exp.CompanyId = exp_main.ExpChargedTo_CompanyId;
                    new_activity_exp.Document_Id = exp_main.ID;
                    new_activity_exp.WF_Id = fin_wfDetail_data.WF_Id;
                    new_activity_exp.DateAssigned = DateTime.Now;
                    new_activity_exp.DateCreated = DateTime.Now;
                    new_activity_exp.IsActive = true;
                    new_activity_exp.OrgRole_Id = org_id;
                    new_activity_exp.WFD_Id = fin_wfDetail_data.WFD_Id;
                    new_activity_exp.AppDocTypeId = exp_app_doctype.DCT_Id;
                }
                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity_exp);

                // update RFP Main details
                rfp_main.Status = 1;

                //update expense main details
                exp_main.Status = 1;

                var creator_detail = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == exp_main.UserId)
                    .FirstOrDefault();

                var sender_detail = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == Session["UserID"].ToString())
                    .FirstOrDefault();

                RFPApprovalView rfp = new RFPApprovalView();

                rfp.SendEmailTo(Convert.ToInt32(rfp_main.ID), creator_detail.EmpCode, Convert.ToInt32(rfp_main.ChargedTo_CompanyId), sender_detail.FullName, sender_detail.Email, rfp_main.RFP_DocNum, rfp_main.DateCreated.ToString(), rfp_main.Purpose, remarks, "Return", payMethod.PMethod_name, tranType.RFPTranType_Name, "");
                _DataContext.SubmitChanges();

                return "success";
             
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

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

        //AJAX FUNCTION RETURNING DOCUMENT TO LAST APPROVER
        [WebMethod]
        public static string btnReturnAppClickAjax(string return_remarks)
        {
            AccedeAuditViewPage exp = new AccedeAuditViewPage();
            return exp.btnReturnAppClick(return_remarks);
        }

        public string btnReturnAppClick(string return_remarks)
        {
            try
            {
                var doc_id = Convert.ToInt32(Session["ExpId_audit"]);
                var exp_details = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == doc_id)
                    .FirstOrDefault();

                var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                    .Where(x => x.ExpenseType_ID == exp_details.ExpenseType_ID)
                    .FirstOrDefault();

                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                var lastActDetails = _DataContext.ITP_T_WorkflowActivities
                    .Where(x => x.Document_Id == doc_id)
                    .Where(x => x.AppDocTypeId == app_docType.DCT_Id)
                    .Where(x => x.Status == 7)
                    .OrderByDescending(x => x.WFA_Id)
                    .FirstOrDefault();

                var lastAppDetails = _DataContext.ITP_S_UserMasters
                    .Where(x => x.EmpCode == lastActDetails.ActedBy_User_Id)
                    .FirstOrDefault();

                var returned_audit = _DataContext.ITP_S_Status
                    .Where(x => x.STS_Name == "Returned by Audit")
                    .FirstOrDefault();

                var wfID = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.Company_Id == exp_details.ExpChargedTo_CompanyId)
                    .Where(x => x.Name == "ACDE AUDIT")
                    .FirstOrDefault();

                // GET WORKFLOW DETAILS ID FROM AUDIT WF
                var wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                where wfd.WF_Id == wfID.WF_Id && wfd.Sequence == 1
                                select wfd.WFD_Id;
                int wfdID = wfDetails.FirstOrDefault();

                // GET ORG ROLE ID FROM AUDIT WF
                var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                              where or.WF_Id == wfID.WF_Id && or.Sequence == 1
                              select or.OrgRole_Id;
                int orID = (int)orgRole.FirstOrDefault();

                //INSERT RETURN EXPENSE STATUS TO ITP_T_WorkflowActivity
                DateTime currentDate = DateTime.Now;
                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                {
                    Status = returned_audit.STS_Id,
                    DateAssigned = currentDate,
                    DateAction = currentDate,
                    WF_Id = wfID.WF_Id,
                    WFD_Id = wfdID,
                    OrgRole_Id = orID,
                    Document_Id = doc_id,
                    Remarks = Session["AuthUser"].ToString() + ": " + return_remarks + ";",
                    AppId = 1032,
                    ActedBy_User_Id = Session["userID"].ToString(),
                    CompanyId = Convert.ToInt32(exp_details.ExpChargedTo_CompanyId),
                    AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                    IsActive = true,
                };
                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                //END RETURN EXPENSE STATUS


                // CHANGE WORKFLOW DETAILS ID FROM FAP WF
                wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                where wfd.WF_Id == exp_details.FAPWF_Id && wfd.Sequence == 1
                                select wfd.WFD_Id;
                wfdID = wfDetails.FirstOrDefault();

                // CHANGE ORG ROLE ID FROM FAP WF
                orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                              where or.WF_Id == exp_details.FAPWF_Id && or.Sequence == 1
                              select or.OrgRole_Id;
                orID = (int)orgRole.FirstOrDefault();

                //INSERT LAST APPROVER PENDING STATUS TO ITP_T_WorkflowActivity
                ITP_T_WorkflowActivity wfa_pending = new ITP_T_WorkflowActivity()
                {
                    Status = 1,
                    DateAssigned = currentDate,
                    WF_Id = exp_details.FAPWF_Id,
                    WFD_Id = wfdID,
                    OrgRole_Id = orID,
                    Document_Id = doc_id,
                    AppId = 1032,
                    CompanyId = Convert.ToInt32(exp_details.ExpChargedTo_CompanyId),
                    AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                    IsActive = true,
                };
                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_pending);
                //END PENDING STATUS

                exp_details.Status = 1;

                var creator_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == exp_details.UserId)
                                              .FirstOrDefault();

                var sender_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                          .FirstOrDefault();

                ExpenseApprovalView exp = new ExpenseApprovalView();

                exp.SendEmailTo(exp_details.ID, lastActDetails.ActedBy_User_Id, Convert.ToInt32(exp_details.ExpChargedTo_CompanyId), sender_detail.FullName, sender_detail.Email, exp_details.DocNo, exp_details.DateCreated.ToString(), exp_details.Purpose, return_remarks, "ReturnApprover", "", tranType.Description, "");
                _DataContext.SubmitChanges();

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
    
}