using DevExpress.Data.Filtering.Helpers;
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
    public partial class AccedeCashierExpenseViewPage : System.Web.UI.Page
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

                    var expID = Session["ExpenseId"];
                    var expDetails = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(expID))
                        .FirstOrDefault();

                    sqlMain.SelectParameters["ID"].DefaultValue = expDetails.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlCA.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlReim.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlReimDetails.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = expDetails.ID.ToString();

                    var exp = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                        .FirstOrDefault();

                    SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                    SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                    var status_id = exp.Status.ToString();
                    var user_id = exp.UserId.ToString();

                    var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                    var btnAR = FormExpApprovalView.FindItemOrGroupByName("SaveAR") as LayoutItem;
                    var btnDisburse = FormExpApprovalView.FindItemOrGroupByName("CashSave") as LayoutItem;

                    if (myLayoutGroup != null)
                    {
                        myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";

                    }

                    var RFPCA = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.isTravel != true);

                    decimal totalCA = 0;
                    foreach (var item in RFPCA)
                    {
                        totalCA += Convert.ToDecimal(item.Amount);
                    }
                    caTotal.Text = totalCA.ToString("#,##0.00") + "  PHP ";

                    var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails
                        .Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));

                    decimal totalExp = 0;
                    foreach (var item in ExpDetails)
                    {
                        totalExp += Convert.ToDecimal(item.NetAmount);
                    }
                    expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";
                    dueComp = totalCA - totalExp;

                    if (dueComp < 0)
                    {
                        var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Employee";

                        var reimRFP = _DataContext.ACCEDE_T_RFPMains
                            .Where(x => x.IsExpenseReim == true)
                            .Where(x => x.Status != 4)
                            .Where(x => x.isTravel != true)
                            .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]));

                        if(reimRFP != null)
                        {
                            var SAPdoc = FormExpApprovalView.FindItemOrGroupByName("SAPDoc") as LayoutItem;
                            SAPdoc.ClientVisible = true;

                            btnDisburse.ClientVisible = true;
                        }

                    }
                    else
                    {
                        var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Company";

                        if (dueComp > 0)
                        {
                            var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                            AR_Reference.ClientVisible = true;

                            btnAR.ClientVisible = true;
                            btnDisburse.ClientVisible = false;
                        }
                    }

                    dueTotal.Text = FormatDecimal(dueComp) + "  PHP ";

                    //if (status_id == "3" || status_id == "13" || status_id == "15" || status_id == "18" || status_id == "19" && user_id == Session["userID"].ToString())
                    //{
                    //    btnEdit.ClientVisible = true;
                    //}

                    //if (status_id == "7")
                    //{
                    //    var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                    //    print.ClientVisible = true;
                    //}

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

        [WebMethod]
        public static string SaveCashierChangesAJAX(string SAPDoc, int stats)
        {
            AccedeCashierExpenseViewPage rfp = new AccedeCashierExpenseViewPage();

            return rfp.SaveCashierChanges(SAPDoc, stats);
        }

        public string SaveCashierChanges(string SAPDoc, int stats)
        {
            try
            {
                var app_docType_rfp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                var app_docType_exp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                    .FirstOrDefault();

                var completed_status = _DataContext.ITP_S_Status
                    .Where(x => x.STS_Name == "Complete")
                    .FirstOrDefault();

                var rfp_main_reim = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                    .Where(x=>x.IsExpenseReim == true).Where(x=>x.Status != 4)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == exp_main.ID)
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var release_cash_status = _DataContext.ITP_S_Status
                    .Where(x => x.STS_Description == "Disbursed")
                    .FirstOrDefault();

                var cashierWF = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.Name == "ACDE CASHIER")
                    .Where(x => x.Company_Id == Convert.ToInt32(exp_main.ExpChargedTo_CompanyId))
                    .FirstOrDefault();

                var cashierWFDetail = _DataContext.ITP_S_WorkflowDetails
                    .Where(x => x.WF_Id == Convert.ToInt32(cashierWF.WF_Id))
                    .FirstOrDefault();

                var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles
                    .Where(x => x.OrgRoleId == Convert.ToInt32(cashierWFDetail.OrgRole_Id))
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .FirstOrDefault();

                var rfp_app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                var exp_app_doctype = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                var payMethod = "";
                var tranType = "";

                if (rfp_main_reim != null)
                {
                    payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main_reim.PayMethod)
                        .FirstOrDefault().PMethod_name;

                    tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main_reim.TranType)
                        .FirstOrDefault().RFPTranType_Name;
                }
                else
                {
                    payMethod = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.ID == rfp_main_ca.PayMethod)
                        .FirstOrDefault().PMethod_name;

                    tranType = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.ID == rfp_main_ca.TranType)
                        .FirstOrDefault().RFPTranType_Name;

                }

                if (stats == 1)
                {
                    if (rfp_main_reim != null)
                    {
                        rfp_main_reim.SAPDocNo = SAPDoc;
                        if (release_cash_status != null && cashierWF != null && cashierWFDetail != null && orgRole != null)
                        {

                            ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                            {
                                new_activity.Status = release_cash_status.STS_Id;
                                new_activity.AppId = 1032;
                                new_activity.CompanyId = rfp_main_reim.ChargedTo_CompanyId;
                                new_activity.Document_Id = rfp_main_reim.ID;
                                new_activity.WF_Id = cashierWFDetail.WF_Id;
                                new_activity.DateAssigned = DateTime.Now;
                                new_activity.DateCreated = DateTime.Now;
                                new_activity.IsActive = true;
                                new_activity.OrgRole_Id = cashierWFDetail.OrgRole_Id;
                                new_activity.WFD_Id = cashierWFDetail.WFD_Id;
                                new_activity.AppDocTypeId = app_docType_rfp.DCT_Id;
                                new_activity.ActedBy_User_Id = Session["userID"].ToString();
                                new_activity.DateAction = DateTime.Now;
                            }
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);
                            rfp_main_reim.Status = release_cash_status.STS_Id;
                        }
                        else
                        {
                            //error in setup
                            return "There is an error in setup. Please contact admin regarding this issue.";
                        }
                    }

                    ITP_T_WorkflowActivity new_activity_exp = new ITP_T_WorkflowActivity();
                    {
                        new_activity_exp.Status = release_cash_status.STS_Id;
                        new_activity_exp.AppId = 1032;
                        new_activity_exp.CompanyId = exp_main.ExpChargedTo_CompanyId;
                        new_activity_exp.Document_Id = exp_main.ID;
                        new_activity_exp.WF_Id = cashierWFDetail.WF_Id;
                        new_activity_exp.DateAssigned = DateTime.Now;
                        new_activity_exp.DateCreated = DateTime.Now;
                        new_activity_exp.IsActive = true;
                        new_activity_exp.OrgRole_Id = cashierWFDetail.OrgRole_Id;
                        new_activity_exp.WFD_Id = cashierWFDetail.WFD_Id;
                        new_activity_exp.AppDocTypeId = app_docType_exp.DCT_Id;
                        new_activity_exp.ActedBy_User_Id = Session["userID"].ToString();
                        new_activity_exp.DateAction = DateTime.Now;
                    }
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity_exp);

                    exp_main.Status = completed_status.STS_Id;
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
        public static string ReleaseARReferenceAJAX(string ARReference)
        {
            AccedeCashierExpenseViewPage exp = new AccedeCashierExpenseViewPage();
            return exp.ReleaseARReference(ARReference);

        }

        public string ReleaseARReference(string ARReference)
        {
            var exp_main = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                    .FirstOrDefault();

            var rfp_main_reim = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                    .Where(x => x.IsExpenseReim == true).Where(x => x.Status != 4)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

            var app_docType_exp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

            var app_docType_rfp = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

            var rfp_main_ca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == exp_main.ID)
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

            var payMethod = "";
            var tranType = "";

            if (rfp_main_reim != null)
            {
                payMethod = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfp_main_reim.PayMethod)
                    .FirstOrDefault().PMethod_name;

                tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfp_main_reim.TranType)
                    .FirstOrDefault().RFPTranType_Name;

                rfp_main_reim.Status = 1;
            }
            else
            {
                payMethod = _DataContext.ACCEDE_S_PayMethods
                    .Where(x => x.ID == rfp_main_ca.PayMethod)
                    .FirstOrDefault().PMethod_name;

                tranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.ID == rfp_main_ca.TranType)
                    .FirstOrDefault().RFPTranType_Name;

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

                if (rfp_main_reim != null)
                {
                    //Insert new activity to RFP Reimburse
                    ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                    {
                        new_activity.Status = 1;
                        new_activity.AppId = 1032;
                        new_activity.CompanyId = rfp_main_reim.Company_ID;
                        new_activity.Document_Id = rfp_main_reim.ID;
                        new_activity.WF_Id = fin_wfDetail_data.WF_Id;
                        new_activity.DateAssigned = DateTime.Now;
                        new_activity.DateCreated = DateTime.Now;
                        new_activity.IsActive = true;
                        new_activity.OrgRole_Id = org_id;
                        new_activity.WFD_Id = fin_wfDetail_data.WFD_Id;
                        new_activity.AppDocTypeId = app_docType_rfp.DCT_Id;
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
                    new_activity_exp.AppDocTypeId = app_docType_exp.DCT_Id;
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

                    ExpenseApprovalView exp = new ExpenseApprovalView();

                    exp.SendEmailTo(exp_main.ID, nexApprover_detail.EmpCode, Convert.ToInt32(exp_main.CompanyId), sender_detail.FullName, sender_detail.Email, exp_main.DocNo, exp_main.DateCreated.ToString(), exp_main.Purpose, "", "Pending", payMethod.ToString(), tranType.ToString(), "");

                }

                exp_main.AR_Reference_No = ARReference;
                exp_main.Status = 1;
                _DataContext.SubmitChanges();
            }
            else
            {
                return "Workflow data does not exist.";
            }

            //End of Finance WF transition

            return "success";
            
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            Session["cID"] = Session["ExpenseId"];
            Response.Redirect("~/AccedeExpenseReportPrinting.aspx");
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
    }
}