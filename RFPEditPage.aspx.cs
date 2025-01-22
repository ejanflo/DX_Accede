using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;

namespace DX_WebTemplate
{
    public partial class RFPEditPage : System.Web.UI.Page
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

                    //sqlMain.SelectParameters["UserId"].DefaultValue = empCode;
                    var rfp_id = Convert.ToInt32(Session["EditRFPID"]);
                    var rfp_details = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == rfp_id).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                    var pld = formRFP.FindItemOrGroupByName("PLD") as LayoutItem;
                    var wbs = formRFP.FindItemOrGroupByName("WBS") as LayoutItem;

                    Session["Doc_No"] = rfp_details.RFP_DocNum.ToString();

                    SqlCompany.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlDepartment.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlDepartment.SelectParameters["CompanyId"].DefaultValue = rfp_details.Company_ID.ToString();
                    SqlWF.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlWF.SelectParameters["CompanyId"].DefaultValue = rfp_details.Company_ID.ToString();
                    SqlExpense.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlCAHistory.SelectParameters["User_ID"].DefaultValue = empCode;

                    SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = empCode;

                    SqlMain.SelectParameters["ID"].DefaultValue = rfp_id.ToString();
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp_details.WF_Id.ToString();
                    SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = rfp_id.ToString();
                    SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : null;

                    var depCode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x=>x.ID == rfp_details.Department_ID).FirstOrDefault();
                    SqlWF.SelectParameters["Minimum"].DefaultValue = rfp_details.Amount.ToString();
                    SqlWF.SelectParameters["Maximum"].DefaultValue = rfp_details.Amount.ToString();
                    SqlWF.SelectParameters["DepCode"].DefaultValue = depCode.DepCode.ToString();

                    SqlUser.SelectParameters["Company_ID"].DefaultValue = rfp_details.Company_ID.ToString();
                    SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                    SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                    SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();

                    PLD.MinDate = DateTime.Now;

                    if (rfp_details != null)
                    {
                        if (rfp_details.isTravel == true)
                        {
                            rdButton_Trav.Checked = true;
                            rdButton_NonTrav.Checked = false;
                        }
                        else
                        {
                            rdButton_Trav.Checked = false;
                            rdButton_NonTrav.Checked = true;
                        }

                        if (rfp_details.TranType == 1)
                        {
                            pld.ClientVisible = true;
                        }

                        if (rfp_details.Company_ID == 5)
                        {
                            wbs.ClientVisible = true;
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


        [WebMethod]
        public static decimal CheckMinAmountAJAX(int comp_id, int payMethod)
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.CheckMinAmount(comp_id, payMethod);
        }

        [WebMethod]
        public static int UpdateRFPMainAjax(string Comp_ID, string Dept_ID, string Paymethod, string tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, string amount, string purpose, string wf_id, string status, string exp_id, string fap, string wbs, string pld)
        {
            RFPEditPage rfp = new RFPEditPage();
            return rfp.UpdateRFPMain(Convert.ToInt32(Comp_ID), Convert.ToInt32(Dept_ID), Convert.ToInt32(Paymethod), Convert.ToInt32(tranType), isTrav, costCenter, io, payee, lastDay, Convert.ToDecimal(amount), purpose, Convert.ToInt32(wf_id), Convert.ToInt32(status), Convert.ToInt32(exp_id), Convert.ToInt32(fap), wbs, pld);
        }

        public int UpdateRFPMain(int Comp_ID, int Dept_ID, int Paymethod, int tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, decimal amount, string purpose, int wf_id, int status, int exp_id, int fap, string wbs, string pld)
        {
            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["EditRFPID"])).FirstOrDefault();
            
            if (rfp_main != null)
            {
                rfp_main.Company_ID = Comp_ID;
                rfp_main.Department_ID = Dept_ID;
                rfp_main.PayMethod = Paymethod;
                rfp_main.TranType = tranType;
                if (tranType == 1)
                {
                    rfp_main.IsExpenseCA = true;
                    rfp_main.IsExpenseReim = false;
                }
                if (tranType == 2)
                {
                    rfp_main.IsExpenseCA = false;
                    rfp_main.IsExpenseReim = true;
                }
                rfp_main.isTravel = isTrav;
                rfp_main.SAPCostCenter = costCenter;
                rfp_main.IO_Num = io;
                rfp_main.Payee = payee;
                if(isTrav == true)
                {
                    rfp_main.LastDayTransact = Convert.ToDateTime(lastDay);
                }
                else
                {
                    rfp_main.LastDayTransact = null;
                }
                rfp_main.Amount = Convert.ToDecimal(amount);
                rfp_main.Purpose = purpose;
                rfp_main.WF_Id = wf_id;
                rfp_main.Status = status;
                if (exp_id != 0)
                {
                    rfp_main.Exp_ID = exp_id;
                }
                rfp_main.FAPWF_Id = fap;
                if (Comp_ID != 5)
                {
                    rfp_main.WBS = null;
                }
                else
                {
                    rfp_main.WBS = wbs;
                }
                //if (exp_cat != "")
                //{
                //    rfp_main.AcctCharged = Convert.ToInt32(exp_cat);
                //}
                //else
                //{
                //    rfp_main.AcctCharged = null;
                //}

                if (tranType == 1)
                {
                    rfp_main.PLDate = Convert.ToDateTime(pld);
                }
                else
                {
                    rfp_main.PLDate = null;
                }

                //if(remarks != "")
                //{
                //    rfp_main.Remarks = remarks;
                //}
            }
            

            if (status == 1)
            {
                RFPCreationPage rfpCreatePage = new RFPCreationPage();
                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                                where app.WF_Id == Convert.ToInt32(rfp_main.WF_Id)
                                where app.Sequence == 1
                                select app;

                bool ins_wf = rfpCreatePage.InsertWorkflowAct(rfp_main.ID);

                if (!ins_wf)
                {
                    return 0;
                }

            }

            _DataContext.SubmitChanges();

            return rfp_main.ID;

        }

        protected void formRFP_E2_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {

        }

        protected void formEmployee_DataBound(object sender, EventArgs e)
        {

        }

        protected void formRFP_E4_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            SqlDepartment.SelectParameters["CompanyId"].DefaultValue = drpdown_Company.Value.ToString();
            SqlDepartment.DataBind();

            drpdown_Department.DataSourceID = null;
            drpdown_Department.DataSource = SqlDepartment;
            drpdown_Department.DataBind();

            var dept = _DataContext.ITP_S_SecurityAppUserCompanyDepts.Where(x => x.CompanyId == Convert.ToInt32(drpdown_Company.Value))
                .Where(x => x.UserId == Session["userID"].ToString());

            if (dept != null)
            {
                drpdown_Department.SelectedIndex = 0;
            }
        }

        protected void drpdown_WF_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(drpdown_Department.Value)).FirstOrDefault();
            var amount = spinEdit_Amount.Value != null ? spinEdit_Amount.Value.ToString() : "0";
            SqlWF.SelectParameters["CompanyId"].DefaultValue = drpdown_Company.Value.ToString();
            SqlWF.SelectParameters["Minimum"].DefaultValue = amount;
            SqlWF.SelectParameters["Maximum"].DefaultValue = amount;
            SqlWF.SelectParameters["DepCode"].DefaultValue = depcode != null ? depcode.DepCode.ToString() : "0";
            SqlWF.DataBind();

            drpdown_WF.DataSourceID = null;
            drpdown_WF.DataSource = SqlWF;
            drpdown_WF.DataBind();

            var wf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.CompanyId == Convert.ToInt32(drpdown_Company.Value))
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                    .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                    .Where(x => x.DepCode == (depcode != null ? depcode.DepCode : "0"))
                    .Where(x => x.IsRA == true);

            if (wf != null)
            {
                if (wf.Count() == 1)
                {
                    drpdown_WF.SelectedIndex = 0;
                }
            }
        }

        protected void drpdwn_FAPWF_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.Split('|').Last();
            var amount = e.Parameter.Split('|').First();

            var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).FirstOrDefault();
            if (wf != null)
            {
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF2.DataBind();

                drpdwn_FAPWF.DataSourceID = null;
                drpdwn_FAPWF.DataSource = SqlFAPWF2;
                drpdwn_FAPWF.DataBindItems();
                drpdwn_FAPWF.SelectedIndex = 0;


            }
            else
            {
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                SqlFAPWF2.DataBind();

                drpdwn_FAPWF.DataSourceID = null;
                drpdwn_FAPWF.DataSource = SqlFAPWF2;
                drpdwn_FAPWF.DataBindItems();
                drpdwn_FAPWF.SelectedIndex = 0;
            }
        }

        protected void WFSequenceGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF.Value != null ? drpdown_WF.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            var comp_id = e.Parameters.Split('|').Last();
            var amount = e.Parameters.Split('|').First();

            var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).FirstOrDefault();
            if (wf != null)
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                SqlFAPWF.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();

                drpdwn_FAPWF.SelectedIndex = 0;
            }
            else
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                SqlFAPWF.DataBind();

                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();

                drpdwn_FAPWF.SelectedIndex = 0;
            }
        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["EditRFPID"].ToString());
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["Doc_No"].ToString();
                    docs.Company_ID = Convert.ToInt32(drpdown_Company.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
        }

        [WebMethod]
        public static decimal MaxAmountAJAX(string comp_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            return rfp.MaxAmountPerComp(Convert.ToInt32(comp_id));
        }

        protected void drpdown_Payee_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = drpdown_Company.Value != null ? Convert.ToInt32(drpdown_Company.Value) : 0;
            if (comp_id != 0)
            {
                SqlUser.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
                SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();
            }
            drpdown_Payee.DataSourceID = null;
            drpdown_Payee.DataSource = SqlUser;

            drpdown_Payee.Value = Session["userID"].ToString();
            drpdown_Payee.DataBind();

            if (drpdown_Payee.Items.Count() > 0)
            {
                drpdown_Payee.Value = Session["userID"].ToString();
                drpdown_Payee.DataBind();
            }
            else
            {
                drpdown_Payee.DataSourceID = null;
                drpdown_Payee.DataSource = SqlUserSelf;
                drpdown_Payee.Value = Session["userID"].ToString();
                drpdown_Payee.DataBind();
            }
        }
    }
}