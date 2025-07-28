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
                    var cType = formRFP.FindItemOrGroupByName("ClassType") as LayoutItem;
                    var tType = formRFP.FindItemOrGroupByName("TravType") as LayoutItem;

                    Session["Doc_No"] = rfp_details.RFP_DocNum.ToString();

                    if (!IsPostBack)
                    {
                        SqlCompany.SelectParameters["UserId"].DefaultValue = empCode;
                        SqlDepartment.SelectParameters["UserId"].DefaultValue = empCode;
                        SqlDepartment.SelectParameters["CompanyId"].DefaultValue = rfp_details.Company_ID.ToString();
                        //SqlWF.SelectParameters["UserId"].DefaultValue = empCode;
                        //SqlWF.SelectParameters["CompanyId"].DefaultValue = rfp_details.Company_ID.ToString();
                        SqlExpense.SelectParameters["UserId"].DefaultValue = empCode;
                        SqlCAHistory.SelectParameters["User_ID"].DefaultValue = empCode;
                        SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = rfp_details.ChargedTo_CompanyId != null ? rfp_details.ChargedTo_CompanyId.ToString() : "";

                        SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = empCode;

                        SqlMain.SelectParameters["ID"].DefaultValue = rfp_id.ToString();
                        SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp_details.WF_Id.ToString();
                        SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                        SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                        SqlDocs.SelectParameters["Doc_ID"].DefaultValue = rfp_id.ToString();
                        SqlDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : null;
                        SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();
                        SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();
                        var depCode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfp_details.Department_ID).FirstOrDefault();
                        SqlWF.SelectParameters["WF_Id"].DefaultValue = rfp_details.WF_Id.ToString();

                        SqlUser.SelectParameters["Company_ID"].DefaultValue = rfp_details.Company_ID.ToString();
                        SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                        SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                        SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();
                        drpdown_Payee.DataSourceID = null;
                        drpdown_Payee.DataSource = SqlUser;
                        drpdown_Payee.DataBind();

                        // Get the existing data from SqlDataSource
                        DataView dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;

                        if (dv != null)
                        {
                            // Convert DataView to DataTable to modify it
                            DataTable dt = dv.ToTable();

                            // Add a new row manually
                            DataRow newRow = dt.NewRow();
                            newRow["DelegateFor_UserID"] = Session["userID"].ToString();
                            newRow["FullName"] = Session["userFullName"].ToString();
                            dt.Rows.Add(newRow);

                            // Rebind the ComboBox with the updated list
                            drpdown_Payee.DataSource = dt;
                            drpdown_Payee.TextField = "FullName";   // Ensure text field is set correctly
                            drpdown_Payee.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly
                            drpdown_Payee.DataBind();
                        }
                    }
                    

                    PLD.MinDate = DateTime.Now;

                    if (rfp_details != null)
                    {
                        if (rfp_details.isTravel == true)
                        {
                            rdButton_Trav.Checked = true;
                            rdButton_NonTrav.Checked = false;
                            cType.ClientVisible = false;
                            if(rfp_details.isForeignTravel != null && rfp_details.isForeignTravel == true)
                            {
                                drpdown_TravType.Value = "1";
                            }
                            else
                            {
                                drpdown_TravType.Value = "2";
                            }
                        }
                        else
                        {
                            rdButton_Trav.Checked = false;
                            rdButton_NonTrav.Checked = true;
                            tType.ClientVisible = false;
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
        public static int UpdateRFPMainAjax(string Comp_ID, string Dept_ID, string Paymethod, string tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, string amount, string purpose, string wf_id, string status, string exp_id, string fap, string wbs, string pld, string curr, string travType, string classification, string CTComp_ID, string CTDept_ID, string compLoc)
        {
            RFPEditPage rfp = new RFPEditPage();
            return rfp.UpdateRFPMain(Convert.ToInt32(Comp_ID), Convert.ToInt32(Dept_ID), Convert.ToInt32(Paymethod), Convert.ToInt32(tranType), isTrav, costCenter, io, payee, lastDay, Convert.ToDecimal(amount), purpose, Convert.ToInt32(wf_id), Convert.ToInt32(status), Convert.ToInt32(exp_id), Convert.ToInt32(fap), wbs, pld, curr, travType, classification, CTComp_ID, CTDept_ID, compLoc);
        }

        public int UpdateRFPMain(int Comp_ID, int Dept_ID, int Paymethod, int tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, decimal amount, string purpose, int wf_id, int status, int exp_id, int fap, string wbs, string pld, string curr, string travType, string classification, string CTComp_ID, string CTDept_ID, string compLoc)
        {
            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["EditRFPID"])).FirstOrDefault();
            
            if (rfp_main != null)
            {
                rfp_main.Company_ID = Comp_ID;
                rfp_main.Comp_Location_Id = Convert.ToInt32(compLoc);
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
                    rfp_main.Classification_Type_Id = null;
                    rfp_main.LastDayTransact = Convert.ToDateTime(lastDay);
                    if (travType == "1")
                    {
                        rfp_main.isForeignTravel = true;
                    }
                    else
                    {
                        rfp_main.isForeignTravel = false;
                    }
                }
                else
                {
                    rfp_main.LastDayTransact = null;
                    rfp_main.isForeignTravel = null;

                    rfp_main.Classification_Type_Id = Convert.ToInt32(classification);
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

                rfp_main.Currency = curr;
                rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_ID);
                rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_ID);
                
                //if(remarks != "")
                //{
                //    rfp_main.Remarks = remarks;
                //}
            }
            
            if (status == 1)
            {

                RFPCreationPage rfpCreatePage = new RFPCreationPage();
                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                                where app.WF_Id == Convert.ToInt32(wf_id)
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
            SqlDepartment.SelectParameters["CompanyId"].DefaultValue = e.Parameter.ToString();
            SqlDepartment.DataBind();

            drpdown_Department.DataSourceID = null;
            drpdown_Department.DataSource = SqlDepartment;
            drpdown_Department.DataBind();

            var dept = _DataContext.ITP_S_SecurityAppUserCompanyDepts.Where(x => x.CompanyId == Convert.ToInt32(e.Parameter))
                .Where(x => x.UserId == Session["userID"].ToString());

            //if (dept != null)
            //{
            //    drpdown_Department.SelectedIndex = 0;
            //}
        }

        protected void drpdown_WF_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            //var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(drpdown_Department.Value)).FirstOrDefault();

            //SqlWF.SelectParameters["CompanyId"].DefaultValue = drpdown_Company.Value.ToString();
            //SqlWF.SelectParameters["DepCode"].DefaultValue = depcode != null ? depcode.DepCode.ToString() : "0";
            //SqlWF.DataBind();

            //drpdown_WF.DataSourceID = null;
            //drpdown_WF.DataSource = SqlWF;
            //drpdown_WF.DataBind();

            //var wf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.CompanyId == Convert.ToInt32(drpdown_Company.Value))
            //        .Where(x => x.UserId == Session["userID"].ToString())
            //        .Where(x => x.DepCode == (depcode != null ? depcode.DepCode : "0"))
            //        .Where(x => x.IsRA == true);

            //if (wf != null)
            //{
            //    if (wf.Count() == 1)
            //    {
            //        drpdown_WF.SelectedIndex = 0;
            //    }
            //}

            var param = e.Parameter.Split('|');
            var dept_id = param[0] != "" ? param[0] : "0";
            var comp = param[1] != "" ? param[1] : "0";
            var emp = param[2] != "" ? param[2] : "";
            var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(dept_id)).FirstOrDefault();
            //var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x=>x.ID == Convert.ToInt32(comp)).FirstOrDefault();

            var wfMapCheck = _DataContext.vw_ACCEDE_I_WFMappings.Where(x => x.UserId == emp)
                            .Where(x => x.Company_Id == Convert.ToInt32(comp))
                            .FirstOrDefault();

            if (wfMapCheck != null)
            {
                SqlWF.SelectParameters["WF_Id"].DefaultValue = wfMapCheck.WF_ID.ToString();
                drpdown_WF.DataSourceID = null;
                drpdown_WF.DataSource = SqlWF;
                drpdown_WF.SelectedIndex = 0;
                drpdown_WF.DataBind();
            }
            else
            {
                if (depcode != null)
                {
                    var rawf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == emp)
                            .Where(x => x.CompanyId == Convert.ToInt32(comp))
                            .Where(x => x.DepCode == depcode.DepCode)
                            //.Where(x => x.IsRA == true)
                            .FirstOrDefault();

                    if (rawf != null)
                    {
                        SqlWF.SelectParameters["WF_Id"].DefaultValue = rawf.WF_Id.ToString();
                        drpdown_WF.DataSourceID = null;
                        drpdown_WF.DataSource = SqlWF;
                        drpdown_WF.SelectedIndex = 0;
                        drpdown_WF.DataBind();
                    }
                    else
                    {
                        SqlWF.SelectParameters["WF_Id"].DefaultValue = "0";
                        drpdown_WF.DataSourceID = null;
                        drpdown_WF.DataSource = SqlWF;
                        drpdown_WF.DataBind();

                    }
                }
            }
        }

        protected void drpdwn_FAPWF_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp_id = param[1];
            var amount = param[2];
            var classTypeId = param[3] != "null" ? param[3] : "0";
            var tripType = param[0] != null ? param[0] : "";
            //var comp_id = drpdown_CTCompany.Value != null ? drpdown_CTCompany.Value : 0;
            //var amount = spinEdit_Amount.Value != null ? spinEdit_Amount.Value : "0.00";
            //var classTypeId = drpdown_classification.Value != null ? drpdown_classification.Value : 0;
            var classType = _DataContext.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(classTypeId)).FirstOrDefault();
            //var tripType = e.Parameter != "" ? e.Parameter.ToString() : "";

            if (Convert.ToInt64(comp_id) != 0)
            {
                if (classType != null)
                {
                    if (Convert.ToBoolean(classType.withFAPLogic) == true)
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == true)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

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
                            drpdwn_FAPWF.DataBindItems();
                        }
                    }
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

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
                }
                else
                {
                    if (tripType.ToString() == "1")
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == true)
                            .Where(x => x.Description.Contains("rfpforeign"))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

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
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                            .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                            .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

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

                }



            }
        }

        protected void WFSequenceGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = e.Parameters != null ? e.Parameters.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            //var comp_id = e.Parameters.Split('|').Last();
            //var amount = e.Parameters.Split('|').First();

            //var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).FirstOrDefault();
            //if (wf != null)
            //{
            //    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
            //    SqlFAPWF.DataBind();

            //    FAPWFGrid.DataSourceID = null;
            //    FAPWFGrid.DataSource = SqlFAPWF;
            //    FAPWFGrid.DataBind();

            //    drpdwn_FAPWF.SelectedIndex = 0;
            //}
            //else
            //{
            //    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
            //    SqlFAPWF.DataBind();

            //    FAPWFGrid.DataSourceID = null;
            //    FAPWFGrid.DataSource = SqlFAPWF;
            //    FAPWFGrid.DataBind();

            //    drpdwn_FAPWF.SelectedIndex = 0;
            //}

            var param = e.Parameters.Split('|');
            var comp_id = param[1];
            var amount = param[2];
            var classTypeId = param[3] != "null" ? param[3] : "0";
            var tripType = param[0] != null ? param[0] : "";
            //var comp_id = drpdown_CTCompany.Value != null ? drpdown_CTCompany.Value : 0;
            //var amount = spinEdit_Amount.Value != null ? spinEdit_Amount.Value : "0.00";
            //var classTypeId = drpdown_classification.Value != null ? drpdown_classification.Value : 0;
            var classType = _DataContext.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(classTypeId)).FirstOrDefault();
            //var tripType = e.Parameter != "" ? e.Parameter.ToString() : "";

            if (Convert.ToInt64(comp_id) != 0)
            {
                if (classType != null)
                {
                    if (Convert.ToBoolean(classType.withFAPLogic) == true)
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == true)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                        else
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataBind();
                        }
                    }
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();

                        }
                        else
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                    }
                }
                else
                {
                    if (tripType.ToString() == "1")
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == true)
                            .Where(x => x.Description.Contains("foreign"))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                        else
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                    }
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                            .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                            .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                        else
                        {
                            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF.DataBind();

                            FAPWFGrid.DataSourceID = null;
                            FAPWFGrid.DataSource = SqlFAPWF;
                            FAPWFGrid.DataBind();
                        }
                    }

                }



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
            var comp_id = e.Parameter.ToString();
            if (comp_id != "")
            {
                SqlUser.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
                SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();
            }
            // Get the existing data from SqlDataSource
            DataView dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;

            if (dv != null)
            {
                // Convert DataView to DataTable to modify it
                DataTable dt = dv.ToTable();

                // Add a new row manually
                DataRow newRow = dt.NewRow();
                newRow["DelegateFor_UserID"] = Session["userID"].ToString();
                newRow["FullName"] = Session["userFullName"].ToString();
                dt.Rows.Add(newRow);

                // Rebind the ComboBox with the updated list
                drpdown_Payee.DataSource = dt;
                drpdown_Payee.TextField = "FullName";   // Ensure text field is set correctly
                drpdown_Payee.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly
                drpdown_Payee.DataBind();
            }
        }

        protected void drpdown_currency_Callback(object sender, CallbackEventArgsBase e)
        {
            var travType = e.Parameter != null ? e.Parameter.ToString() : "";
            var USDCurrency = _DataContext.ACDE_T_Currencies.Where(x => x.CurrDescription == "USD").FirstOrDefault();
            var PHPCurrency = _DataContext.ACDE_T_Currencies.Where(x => x.CurrDescription == "PHP").FirstOrDefault();
            if (travType == "1")
            {
                drpdown_currency.Value = USDCurrency.ID.ToString();
                drpdown_currency.Text = USDCurrency.CurrDescription.ToString();
                drpdown_currency.DataBind();
            }
            else
            {
                drpdown_currency.Value = PHPCurrency.ID.ToString();
                drpdown_currency.Text = PHPCurrency.CurrDescription.ToString();
                drpdown_currency.DataBind();
            }
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

        protected void drpdown_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = e.Parameter.ToString();
            SqlCTDepartment.DataBind();

            drpdown_CTDepartment.DataSourceID = null;
            drpdown_CTDepartment.DataSource = SqlCTDepartment;
            drpdown_CTDepartment.DataBind();

            var dept = _DataContext.ITP_S_SecurityAppUserCompanyDepts.Where(x => x.CompanyId == Convert.ToInt32(e.Parameter))
                .Where(x => x.UserId == Session["userID"].ToString());

            if (dept != null)
            {
                drpdown_CTDepartment.SelectedIndex = 0;
            }
        }

        protected void drpdown_CompLocation_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();

            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = comp_id;
            SqlCompLocation.DataBind();

            drpdown_CompLocation.DataSourceID = null;
            drpdown_CompLocation.DataSource = SqlCompLocation;
            drpdown_CompLocation.DataBind();
        }
    }
}