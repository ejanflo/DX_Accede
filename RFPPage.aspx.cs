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
    public partial class RFPPage : System.Web.UI.Page
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

                    SqlRFP.SelectParameters["User_ID"].DefaultValue = empCode;
                    SqlWF.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlDepartmentEdit.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlCompanyEdit.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlExpense.SelectParameters["UserId"].DefaultValue = empCode;

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

        protected void ASPxGridView2_BeforePerformDataSelect1(object sender, EventArgs e)
        {
            Session["MainRFP_ID"] =
                (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void ASPxGridView2_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {

        }

        protected void gridMain_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[1];

            Session["passRFPID"] = rowKey;
            //ASPxWebControl.RedirectOnCallback("RFPViewPage.aspx");

            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

            Session["CompID"] = rfp_main.Company_ID;

            SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Session["CompID"].ToString();
            SqlDepartmentEdit.DataBind();

            if (rfp_main.FAPWF_Id != null)
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_main.FAPWF_Id.ToString();
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = rfp_main.FAPWF_Id.ToString();
                SqlFAPWF.DataBind();
                SqlFAPWF2.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();

                FAPWF_modal.DataSourceID = null;
                FAPWF_modal.DataSource = SqlFAPWF2;
                FAPWF_modal.DataBind();

                FAPWF_modal.SelectedIndex = 0;
            }

            if (buttonId == "btnPrint")
                ASPxWebControl.RedirectOnCallback("~/RFPPrintPage.aspx");
            //Session["passRFPID"] = e.Parameters.ToString();
            ////ASPxWebControl.RedirectOnCallback("RFPViewPage.aspx");

            //var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

            //Session["CompID"] = rfp_main.Company_ID;

            //SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Session["CompID"].ToString();
            //SqlDepartmentEdit.DataBind();

            //if(rfp_main.FAPWF_Id != null)
            //{
            //    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_main.FAPWF_Id.ToString();
            //    SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = rfp_main.FAPWF_Id.ToString();
            //    SqlFAPWF.DataBind();
            //    SqlFAPWF2.DataBind();

            //    FAPWFGrid.DataSourceID = null;
            //    FAPWFGrid.DataSource = SqlFAPWF;
            //    FAPWFGrid.DataBind();

            //    FAPWF_modal.DataSourceID = null;
            //    FAPWF_modal.DataSource = SqlFAPWF2;
            //    FAPWF_modal.DataBind();

            //    FAPWF_modal.SelectedIndex = 0;
            //}
            if (buttonId == "btnView")
                ASPxWebControl.RedirectOnCallback("~/RFPViewPage.aspx");

        }

        [WebMethod]
        public static RFPData RFPDetailsViewAJAX(int RFP_ID)
        {
            RFPData rfp = new RFPData();
            RFPPage page = new RFPPage();

            rfp = page.RFPDetailsView(RFP_ID);

            return rfp;
        }

        public RFPData RFPDetailsView(int RFP_ID)
        {
            var rfp_data = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == RFP_ID).FirstOrDefault();
            var cc = rfp_data.SAPCostCenter != null ? rfp_data.SAPCostCenter :"";
            var io = rfp_data.IO_Num != null ? rfp_data.IO_Num : "";
            var isTrav = rfp_data.isTravel;
            var payee = rfp_data.Payee;
            var status = rfp_data.Status != null ? _DataContext.ITP_S_Status.Where(x => x.STS_Id == rfp_data.Status).FirstOrDefault().STS_Name : "";
            var lastDate = Convert.ToDateTime(rfp_data.LastDayTransact).ToString("MM/dd/yyyy hh:mm:ss");
            var expCat = rfp_data.AcctCharged != null ? rfp_data.AcctCharged.ToString() : "";
            var pld = Convert.ToDateTime(rfp_data.PLDate).ToString("MM/dd/yyyy hh:mm:ss");

            RFPData rfp = new RFPData();
            if (rfp_data != null )
            {
                {
                    rfp.company = Convert.ToInt32(rfp_data.Company_ID);
                    rfp.department = Convert.ToInt32(rfp_data.Department_ID);
                    rfp.department_str = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfp_data.Department_ID).FirstOrDefault().DepDesc;
                    rfp.Payment = Convert.ToInt32(rfp_data.PayMethod);
                    rfp.TranType = Convert.ToInt32(rfp_data.TranType);
                    if(rfp_data.TranType == 1)
                    {
                        rfp.pld = pld;
                    }
                    rfp.CostCenter = cc != null ? cc.ToString() : "";
                    rfp.IO = io != null ? io.ToString() : "";
                    rfp.isTrav = Convert.ToBoolean(isTrav);
                    rfp.Payee = payee != null ? payee.ToString() : "";
                    rfp.Status = status != null ? status.ToString() : "";
                    if(rfp_data.LastDayTransact!=null )
                    {
                        rfp.LastDate = lastDate.ToString();
                    }
                    rfp.DocNum = rfp_data.RFP_DocNum != null ? rfp_data.RFP_DocNum.ToString() : "";
                    rfp.amount = Convert.ToDecimal(rfp_data.Amount);
                    rfp.purpose = rfp_data.Purpose;
                    rfp.workflow = Convert.ToInt32(rfp_data.WF_Id);
                    rfp.ExpenseRep = rfp_data.Exp_ID != null ? rfp_data.Exp_ID.ToString() : "";
                    rfp.fap_id = Convert.ToInt32(rfp_data.FAPWF_Id);

                    var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(rfp_data.Company_ID)).Where(x=>x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(rfp_data.Amount)).FirstOrDefault();

                    if (wf != null)
                    {
                        rfp.fap_name = _DataContext.ITP_S_WorkflowHeaders.Where(x=>x.WF_Id == Convert.ToInt32(wf.WF_Id)).FirstOrDefault().Description;
                    }

                    rfp.wbs = rfp_data.WBS != null ? rfp_data.WBS.ToString() : "";
                    rfp.expCat = expCat;
                     
                    
                }
            }
            
            return rfp;
        }


        protected void WFSequenceGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF_modal.Value != null ? drpdown_WF_modal.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        [WebMethod]
        public static int UpdateRFPMainAjax(string Comp_ID, string Dept_ID, string Paymethod, string tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, string amount, string purpose, string wf_id, string status, string exp_id, string fap_wf, string wbs, string expCat)
        {
            RFPPage rfp = new RFPPage();
            if(exp_id == "")
            {
                exp_id = "0";
            }
            return rfp.UpdateRFPMain(Convert.ToInt32(Comp_ID), Convert.ToInt32(Dept_ID), Convert.ToInt32(Paymethod), Convert.ToInt32(tranType), isTrav, costCenter, io, payee, lastDay, Convert.ToDecimal(amount), purpose, Convert.ToInt32(wf_id), Convert.ToInt32(status), Convert.ToInt32(exp_id), Convert.ToInt32(fap_wf), wbs, expCat);
        }
        public int UpdateRFPMain(int Comp_ID, int Dept_ID, int Paymethod, int tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, decimal amount, string purpose, int wf_id, int status, int exp_id, int fap_wf, string wbs, string expCat)
        {
            try
            {

                var rfp_id = Session["passRFPID"];

                var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(rfp_id)).FirstOrDefault();

                if (rfp_main != null)
                {
                    rfp_main.Company_ID = Convert.ToInt32(Comp_ID);
                    rfp_main.Department_ID = Convert.ToInt32(Dept_ID);
                    rfp_main.PayMethod = Convert.ToInt32(Paymethod);
                    rfp_main.TranType = Convert.ToInt32(tranType);
                    if(tranType == 1)
                    {
                        rfp_main.IsExpenseCA = true;
                        rfp_main.IsExpenseReim = false;
                    }
                    
                    if(tranType == 2)
                    {
                        rfp_main.IsExpenseCA = false;
                        rfp_main.IsExpenseReim = true;
                    }
                    rfp_main.SAPCostCenter = costCenter.ToString();
                    if (io != null)
                    {
                        rfp_main.IO_Num = io.ToString();
                    }
                    rfp_main.isTravel = Convert.ToBoolean(isTrav);
                    rfp_main.Payee = payee.ToString();
                    rfp_main.Amount = Convert.ToDecimal(amount);
                    rfp_main.Purpose = purpose.ToString();
                    rfp_main.WF_Id = Convert.ToInt32(wf_id);
                    rfp_main.Status = status;
                    if(exp_id != 0)
                    {
                        rfp_main.Exp_ID = exp_id;
                    }
                    rfp_main.FAPWF_Id = fap_wf;

                    if(Comp_ID == 5)
                    {
                        rfp_main.WBS = wbs.ToString();
                    }
                    else
                    {
                        rfp_main.WBS = "";
                    }

                    if(expCat != "")
                    {
                        rfp_main.AcctCharged = Convert.ToInt32(expCat);
                    }
                    
                }

                _DataContext.SubmitChanges();

                if(status == 1)
                {
                    var successInsert = InsertWorkflowAct(Convert.ToInt32(rfp_id));

                    if (successInsert)
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }

                return 1;
                
            }catch (Exception ex)
            {
                return 0;
            }
            

        }

        public bool InsertWorkflowAct(int RFP_ID)
        {
            try
            {
                var rfp_main_query = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == RFP_ID).FirstOrDefault();
                var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == rfp_main_query.PayMethod).FirstOrDefault();
                var tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfp_main_query.TranType).FirstOrDefault();

                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                               where app.WF_Id == rfp_main_query.WF_Id
                               where app.Sequence == 1
                               select app;

                ITP_T_WorkflowActivity activity = new ITP_T_WorkflowActivity();

                foreach (var app in Approver)
                {
                    var org_id = app.OrgRole_Id;
                    var date2day = DateTime.Now;

                    //DELEGATE CHECK
                    foreach (var del in _DataContext.ITP_S_TaskDelegations.Where(x => x.OrgRole_ID_Orig == app.OrgRole_Id).Where(x => x.DateFrom <= date2day).Where(x => x.DateTo >= date2day).Where(x => x.isActive == true))
                    {
                        if (del != null)
                        {
                            org_id = del.OrgRole_ID_Delegate;
                        }

                    }

                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                    //INSERTING TO ACTIVITY TABLE
                    {
                        activity.Status = 1;
                        activity.DateAssigned = DateTime.Now;
                        activity.OrgRole_Id = org_id;
                        activity.WF_Id = app.WF_Id;
                        activity.WFD_Id = app.WFD_Id;
                        activity.IsActive = true;
                        activity.IsDelete = false;
                        activity.DateCreated = DateTime.Now;
                        activity.Document_Id = RFP_ID;
                        activity.AppId = app.App_Id;
                        activity.CompanyId = app.Company_Id;
                        activity.AppDocTypeId = app_docType.DCT_Id;
                    }
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(activity);
                    _DataContext.SubmitChanges();

                    var creator_details = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == app.UserId).FirstOrDefault();

                    bool emailApprover = SendEmailToApprover(app.UserId, Convert.ToInt32(app.Company_Id), creator_details.FullName, creator_details.Email, rfp_main_query.RFP_DocNum, rfp_main_query.DateCreated.ToString(), rfp_main_query.Purpose, payMethod.PMethod_name, tranType.RFPTranType_Name);

                    if (!emailApprover)
                    {
                        return false;
                    }
                }

                return true;
            }
            catch (Exception e)
            {
                return false;
            }

        }

        public bool SendEmailToApprover(string approver_id, int Comp_id, string creator_fullname, string creator_email, string doc_no, string date_created, string document_purpose, string payMethod, string tranType)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == approver_id)
                                    .FirstOrDefault();

                var comp_name = _DataContext.CompanyMasters.Where(x => x.WASSId == Comp_id)
                            .FirstOrDefault();

                //Start--   Get Text info
                var queryText =
                        from texts in _DataContext.ITP_S_Texts
                        where texts.Type == "Email" && texts.Name == "Pending"
                        select texts;

                var emailMessage = "";
                var emailSubMessage = "";
                var emailColor = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = text.Text2.ToString();
                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                }
                //End--     Get Text info

                string appName = "Request For Payment (RFP)";
                string recipientName = user_email.FName;
                string senderName = creator_fullname;
                string emailSender = creator_email;
                string emailSite = "https://devapps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": Pending for Approval";


                ANFLO anflo = new ANFLO();

                //Body Details Sample
                string emailDetails = "";

                emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
                emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>";
                emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>";
                emailDetails += "<tr><td>Requestor</td><td><strong>" + senderName + "</strong></td></tr>";
                emailDetails += "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>";
                emailDetails += "<tr><td>Transaction Type</td><td><strong>" + tranType + "</strong></td></tr>";
                emailDetails += "<tr><td>Status</td><td><strong>" + "Pending" + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Purpose</td><td><strong>" + document_purpose + "</strong></td></tr>";
                emailDetails += "</table>";
                emailDetails += "<br>";

                emailDetails += "</table>";
                //End of Body Details Sample

                //}
                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, "", emailSite, emailColor);

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
        public static string PayeeDefaultValueAJAX()
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.PayeeDefaultValue();
        }

        public string PayeeDefaultValue()
        {
            var userFullname = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["userID"].ToString()).FirstOrDefault();
            return userFullname.FullName.ToString();
        }

        protected void Department_modal_Callback(object sender, CallbackEventArgsBase e)
        {

            if (e != null && e.Parameter != "")
            {
                Session["CompID"] = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(e.Parameter)).FirstOrDefault().Company_ID;
            }

            if (Session["CompID"] != null)
            {
                SqlDepartmentEdit.SelectParameters["CompanyId"].DefaultValue = Session["CompID"].ToString();
                SqlDepartmentEdit.DataBind();

                Department_modal.Value = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(e.Parameter)).FirstOrDefault().Department_ID.ToString();
                Department_modal.DataBind();
            }
        }

        //[WebMethod]
        //public static decimal CheckMinAmountAJAX(int comp_id)
        //{
        //    RFPCreationPage rfp = new RFPCreationPage();

        //    return rfp.CheckMinAmount(comp_id);
        //}

        //public decimal CheckMinAmount(int comp_id)
        //{
        //    var minAmount = _DataContext.ACCEDE_M_CheckMinAmounts.Where(x => x.CompanyId == comp_id).FirstOrDefault();
        //    if (minAmount != null)
        //    {
        //        return Convert.ToDecimal(minAmount.CheckMinAmount);
        //    }
        //    return 0;
        //}

        protected void gridMain_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "Amount")
            {
                if (e.CellValue != null && e.CellValue is decimal)
                {
                    e.Cell.Text = ((decimal)e.CellValue).ToString("#,##0.##");
                }
            }

            if (e.DataColumn.FieldName == "Status")
            {
                var pendingAudit = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                var pendingP2P = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at P2P").FirstOrDefault();
                var lquidated = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Liquidated").FirstOrDefault();

                var pay_released = _DataContext.ITP_S_Status.Where(x=>x.STS_Name == "Disbursed").FirstOrDefault();
                string value = e.CellValue.ToString();
                if (value == "7" || value == lquidated.STS_Id.ToString())
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");//approved
                    e.Cell.Font.Bold = true;
                }
                else if (value == "2" || value == "3" || value == "18" || value == "19")
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#E67C0E");//rejected
                    e.Cell.Font.Bold = true;
                }
                else if (value == "1")
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#006DD6");//pending
                    e.Cell.Font.Bold = true;
                }
                else if (value == "8")
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#CC2A17");//disapproved
                    e.Cell.Font.Bold = true;
                }
                else if (value == pay_released.STS_Id.ToString())
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");//payment released
                    e.Cell.Font.Bold = true;
                }
                else if (value == pendingAudit.STS_Id.ToString() || value == pendingP2P.STS_Id.ToString())
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#006DD6");//payment released
                    e.Cell.Font.Bold = true;
                }
                else
                {
                    e.Cell.ForeColor = System.Drawing.Color.Gray;
                    e.Cell.Font.Bold = true;
                }
            }
        }

        protected void FAPWFGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var comp_id = e.Parameters.Split('|').Last();
            var amount = e.Parameters.Split('|').First();

            var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).FirstOrDefault();
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();
            }
        }

        protected void FAPWF_modal_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.Split('|').Last();
            var amount = e.Parameter.Split('|').First();

            var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).FirstOrDefault();
            if (wf != null)
            {
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF2.DataBind();

                FAPWF_modal.DataSourceID = null;
                FAPWF_modal.DataSource = SqlFAPWF2;
                FAPWF_modal.DataBindItems();
                FAPWF_modal.SelectedIndex = 0;
            }
        }

        protected void gridMain_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnPrint") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = gridMain.GetRowValues(e.VisibleIndex, "Status");
                var disburseStat = _DataContext.ITP_S_Status.Where(x=>x.STS_Name == "Disbursed").FirstOrDefault();
                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (statusValue.ToString() == disburseStat.STS_Id.ToString()))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void drpdown_WF_modal_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlWF.SelectParameters["CompanyId"].DefaultValue = Company_modal.Value.ToString();
            SqlWF.DataBind();

            drpdown_WF_modal.DataSourceID = null;
            drpdown_WF_modal.DataSource = SqlWF;
            drpdown_WF_modal.DataBind();

            var wf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.CompanyId == Convert.ToInt32(Company_modal.Value))
                    .Where(x => x.UserId == Session["userID"].ToString());

            if (wf != null)
            {
                if (wf.Count() == 1)
                {
                    drpdown_WF_modal.SelectedIndex = 0;
                }
            }
        }
    }

    public class RFPData
    {
        public int company { get; set; }
        public int department { get; set; }
        public string department_str { get; set; }
        public string CostCenter { get; set; }
        public string IO { get; set; }
        public int Payment { get; set; }
        public int TranType { get; set; }
        public bool isTrav { get; set; }
        public string Payee { get; set; }
        public string Status { get; set; }
        public string LastDate { get; set; }
        public string DocNum { get; set; }
        public decimal amount { get; set; }
        public string purpose { get; set; }
        public int workflow { get; set; }
        public string ExpenseRep { get; set; }
        public int fap_id { get; set; }
        public string fap_name { get; set; }
        public string wbs { get; set; }
        public string expCat { get;set; }
        public string pld { get; set; }
    }
}