using DevExpress.Data;
using DevExpress.Web;
using DevExpress.Web.Data;
using DevExpress.XtraExport.Helpers;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TravelExpenseEdit : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        DataSet ds = null;
        DataSet dsExpAlloc = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                    if (mainExp != null)
                    {
                        ExpenseEditForm.Items[0].Caption = "Update Travel Expense Doc No: " + mainExp.Doc_No;
                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());
                        Session["DocNo"] = mainExp.Doc_No.ToString();
                    }

                    CAGrid.DataBind();
                    ExpenseGrid.DataBind();

                    InitializeExpCA(mainExp);
                }
                else
                    Response.Redirect("~/Logon.aspx");
            }
            catch (Exception ex)
            {
                //Response.Redirect("~/Logon.aspx");
                Debug.WriteLine(ex.Message);
            }
        }

        private void InitializeExpCA(ACCEDE_T_TravelExpenseMain mainExp)
        {
            try
            {
                var due_lbl = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                var reimItem = ExpenseEditForm.FindItemOrGroupByName("reimItem") as LayoutItem;
                var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutGroup;

                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reimDetails.ClientVisible = true;
                    reimTB.Text = Convert.ToString(reim.RFP_DocNum);

                    CAGrid.Enabled = false;
                    ExpenseGrid.Enabled = false;
                }

                var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                var userId = Convert.ToString(Session["userID"]);

                var totalca = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId)
                    .Sum(x => (decimal?)x.Amount) ?? 0;

                var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Where(x => x.TravelExpenseMain_ID == travelExpId)
                    .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                var countCA = _DataContext.ACCEDE_T_RFPMains
                    .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId);

                var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                    .Count(x => x.TravelExpenseMain_ID == travelExpId);

                var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                if (totalexp > totalca)
                {
                    due_lbl.Caption = "Due To Employee";
                    if (reim != null)
                        reimItem.ClientVisible = false;
                    else
                        reimItem.ClientVisible = true;
                }
                else
                {
                    reimItem.ClientVisible = false;
                    due_lbl.Caption = "Due To Company";
                }

                drpdown_expenseType.Value = expType;
                lbl_caTotal.Text = totalca.ToString();
                lbl_expenseTotal.Text = totalexp.ToString();
                lbl_dueTotal.Text = totalexp > totalca ? $"({(totalexp - totalca):N2})" : (totalca - totalexp).ToString("N2");

                var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                SqlWF.SelectParameters["UserId"].DefaultValue = mainExp.Employee_Id.ToString();
                SqlWF.SelectParameters["CompanyId"].DefaultValue = mainExp.Company_Id.ToString();
                SqlWF.DataBind();

                Session["mainwfid"] = Convert.ToString(_DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == mainExp.Employee_Id.ToString() && x.CompanyId == mainExp.Company_Id).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                SqlWorkflowSequence.DataBind();

                Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                SqlFAPWF2.DataBind();
                SqlFAPWF.DataBind();
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        protected void UploadController_FilesUploadComplete(object sender, DevExpress.Web.FilesUploadCompleteEventArgs e)
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(companyCB.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
        }

        protected void capopGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            capopGrid.DataBind();
            capopGrid.Selection.UnselectAll();
        }

        [WebMethod]
        public static object AddCA_AJAX(List<int> selectedValues)
        {
            try
            {
                TravelExpenseAdd accede = new TravelExpenseAdd();
                return accede.AddCA(selectedValues);
            }
            catch (Exception ex)
            {
                return string.Empty;
            }
        }

        public object AddCA(List<int> selectedIds)
        {
            try
            {
                var expMain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                expMain.ExpenseType_ID = 1;

                foreach (var id in selectedIds)
                {
                    // INSERT TO ACCEDE_T_ExpenseCA
                    ACCEDE_T_ExpenseCA ca = new ACCEDE_T_ExpenseCA()
                    {
                        RFPMain_ID = id,
                        User_ID = Convert.ToInt32(Session["userID"]),
                        IsUploaded = false
                    };
                    _DataContext.ACCEDE_T_ExpenseCAs.InsertOnSubmit(ca);
                    _DataContext.SubmitChanges();

                    // UPDATE TO ACCEDE_T_RFPMain
                    var updateRFPMain = _DataContext.ACCEDE_T_RFPMains
                        .Where(ex => ex.User_ID == Convert.ToString(Session["userID"]) && ex.ID == id);

                    foreach (ACCEDE_T_RFPMain ex in updateRFPMain)
                    {
                        ex.IsExpenseCA = true;
                        ex.Exp_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    }
                    _DataContext.SubmitChanges();
                }

                return GetExpCA();
            }
            catch (Exception ex)
            {
                return string.Empty;
            }
        }

        [WebMethod]
        public static string AddExpDetailsAJAX(string dateAdd, string tin_no, string invoice_no, string cost_center,
            string gross_amount, string net_amount, string supp, string particu, string acctCharge, string vat_amnt, string ewt_amnt)
        {
            AccedeExpenseReportEdit1 exp = new AccedeExpenseReportEdit1();
            return exp.AddExpDetails(dateAdd, tin_no, invoice_no, cost_center,
            gross_amount, net_amount, supp, particu, acctCharge, vat_amnt, ewt_amnt, string.Empty, string.Empty, string.Empty, string.Empty);
        }


        [WebMethod]
        public static object RemoveFromExp_AJAX(int item_id, string btnCommand)
        {
            TravelExpenseAdd exp = new TravelExpenseAdd();

            return exp.RemoveFromExp(item_id, btnCommand);
        }

        public object RemoveFromExp(int item_id, string btnCommand)
        {
            try
            {
                if (btnCommand == "btnRemoveCA")
                {
                    var CA_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == item_id).FirstOrDefault();
                    CA_RFP.Exp_ID = null;
                    var rfpReim_upd = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                    if (rfpReim_upd != null)
                    {
                        rfpReim_upd.Amount = Convert.ToDecimal(rfpReim_upd.Amount) + Convert.ToDecimal(CA_RFP.Amount);
                    }

                    _DataContext.SubmitChanges();
                }

                if (btnCommand == "btnRemoveExp")
                {
                    var exp_det = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == item_id).FirstOrDefault();
                    var exp_det_map = _DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(x => x.TravelExpenseDetail_ID == item_id);
                    _DataContext.ACCEDE_T_TravelExpenseDetails.DeleteOnSubmit(exp_det);
                    _DataContext.ACCEDE_T_TravelExpenseDetailsMaps.DeleteAllOnSubmit(exp_det_map);

                    var Reim_RFP_exp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseReim == true).FirstOrDefault();

                    var updated_exp_det = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseMain_ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    if (updated_exp_det == null)
                    {
                        if (Reim_RFP_exp != null)
                        {
                            var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Reim_RFP_exp.ID).FirstOrDefault();
                            _DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                        }
                    }
                    else
                    {
                        var rfp_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.Status == 7);
                        var totalCA = new decimal(0.00);
                        foreach (var item in rfp_CA)
                        {
                            totalCA += Convert.ToDecimal(item.Amount);

                        }

                        var expDetail = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseMain_ID == Convert.ToInt32(Session["TravelExp_Id"]));
                        var totalExp = new decimal(0.00);
                        foreach (var item in expDetail)
                        {
                            totalExp += Convert.ToDecimal(item.Total_Expenses);
                        }

                        decimal totalDue = new decimal(0);
                        totalDue = totalCA - totalExp;

                        if (totalDue > 0)
                        {
                            if (Reim_RFP_exp != null)
                            {
                                var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Reim_RFP_exp.ID).FirstOrDefault();
                                _DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                            }

                        }
                        if (Reim_RFP_exp != null)
                        {
                            Reim_RFP_exp.Amount = Math.Abs(totalCA - totalExp);
                        }
                    }
                    _DataContext.SubmitChanges();
                }

                if (btnCommand == "btnRemoveReim")
                {
                    var Reim_RFP = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == item_id).FirstOrDefault();
                    _DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                }

                var expMain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.Status == 7);
                if (rfpCA.Count() > 0)
                {
                    expMain.ExpenseType_ID = 1;
                }
                else
                {
                    expMain.ExpenseType_ID = 2;
                }

                return GetExpCA();
            }
            catch (Exception ex)
            {
                return string.Empty;
            }
        }

        private object GetExpCA()
        {
            var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
            var userId = Convert.ToString(Session["userID"]);

            var totalca = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId)
                .Sum(x => (decimal?)x.Amount) ?? 0;

            var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                .Where(x => x.TravelExpenseMain_ID == travelExpId)
                .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

            var countCA = _DataContext.ACCEDE_T_RFPMains
                .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.isTravel == true && x.User_ID == userId);

            var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                .Count(x => x.TravelExpenseMain_ID == travelExpId);

            var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

            var allTot = totalexp > totalca
                ? $"({(totalexp - totalca):N2})"
                : (totalca - totalexp).ToString("N2");

            var totExpCA = totalexp > totalca
                ? Convert.ToDecimal(totalexp - totalca)
                : Convert.ToDecimal(totalca - totalexp);

            return new { totalca, totalexp, expType, allTot, totExpCA };
        }

        protected void costCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            sqlCostCenter.SelectParameters["CompanyId"].DefaultValue = companyCB.Value.ToString();
            sqlCostCenter.DataBind();
        }

        protected void dept_reim_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlDepartment.SelectParameters["CompanyId"].DefaultValue = companyCB.Value.ToString();
            SqlDepartment.DataBind();

            dept_reim.DataSourceID = null;
            dept_reim.DataSource = SqlDepartment;
            dept_reim.DataBind();
        }

        [WebMethod]
        public static string CostCenterUpdateField(string dept_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            var cc = rfp.GetCostCenter(dept_id);
            return cc;
        }

        [WebMethod]
        public static bool AddRFPReimburseAJAX(string empname, DateTime reportdate, string company, string department, string purpose,
            string amount)
        {
            TravelExpenseEdit exp = new TravelExpenseEdit();

            return exp.AddRFPReimburse(empname, reportdate, company, department, purpose,
            amount);
        }

        public bool AddRFPReimburse(string empname, DateTime reportdate, string company, string department, string purpose,
            string amount)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(company), 1032);
                var docNum = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(company), 1032);

                var expMain = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();

                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true);
                var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).FirstOrDefault();
                var expDetails = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseMain_ID == Convert.ToInt32(Session["TravelExp_Id"]));

                decimal totalReim = new decimal(0);
                decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                foreach (var ca in rfpCA)
                {
                    totalCA += Convert.ToDecimal(ca.Amount);
                }

                foreach (var exp in expDetails)
                {
                    totalExpense += Convert.ToDecimal(exp.Total_Expenses);
                }

                totalReim = totalCA - totalExpense;

                ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain();
                {
                    rfp.Company_ID = Convert.ToInt32(company);
                    rfp.PayMethod = 2; //2 - Cash
                    rfp.Purpose = purpose;
                    rfp.Department_ID = Convert.ToInt32(department);
                    rfp.SAPCostCenter = Convert.ToString(_DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.Company_ID == Convert.ToInt32(company) && x.ID == Convert.ToInt32(department)).Select(x => x.SAP_CostCenter).FirstOrDefault());
                    rfp.Payee = Convert.ToString(_DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == empname).Select(x => x.FullName).FirstOrDefault());
                    rfp.Amount = Convert.ToDecimal(Math.Abs(totalReim));
                    rfp.Exp_ID = expMain.ID;
                    rfp.TranType = 2;
                    rfp.IsExpenseReim = true;
                    rfp.isTravel = true;
                    rfp.DateCreated = DateTime.Now;
                    rfp.RFP_DocNum = docNum.ToString();
                    rfp.User_ID = Session["userID"].ToString();
                    rfp.Status = expMain.Status;

                }

                _DataContext.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                _DataContext.SubmitChanges();

                return true;
            }
            catch (Exception ex)
            {
                return false;
                throw;
            }
        }

        [WebMethod]
        public static object SaveSubmitTravelExpenseAJAX(string empname, DateTime reportdate, string company, string department, DateTime datefrom, DateTime dateto, DateTime timedepart, DateTime timearrive, string trip, string purpose, string expenseType, string btnaction)
        {
            TravelExpenseEdit tra = new TravelExpenseEdit();
            return tra.SaveSubmitTravelExpense(empname, reportdate, company, department, datefrom, dateto, timedepart, timearrive, trip, purpose, expenseType, btnaction);
        }

        public object SaveSubmitTravelExpense(string empname, DateTime reportdate, string company, string department, DateTime datefrom, DateTime dateto, DateTime timedepart, DateTime timearrive, string trip, string purpose, string expenseType, string btnaction)
        {
            try
            {
                var expCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).FirstOrDefault();

                if (expenseType == "1")
                {
                    if (expCA == null)
                    {
                        return new { message = "require CA" };
                    }
                }
                else
                {
                    if (expCA != null)
                    {
                        return new { message = "This transaction should be a Liquidation since you attached a Cash Advance." };
                    }
                }

                var tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == Convert.ToInt32(expenseType)).FirstOrDefault();
                var exp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();

                exp.Employee_Id = Convert.ToInt32(empname);
                exp.Date_Created = reportdate;
                exp.Company_Id = Convert.ToInt32(company);
                exp.Dep_Code = department;
                exp.Date_From = datefrom;
                exp.Date_To = dateto;
                exp.Time_Departed = timedepart.TimeOfDay;
                exp.Time_Arrived = timearrive.TimeOfDay;
                exp.Trip_To = trip;
                exp.Purpose = purpose;
                exp.ExpenseType_ID = Convert.ToInt32(tranType.ExpenseType_ID);
                exp.WF_Id = Convert.ToInt32(Session["mainwfid"]);
                exp.FAPWF_Id = Convert.ToInt32(Session["fapwfid"]);

                //Update reimbursement Workflows
                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.IsExpenseReim == true).FirstOrDefault();

                if (reim != null)
                {
                    reim.WF_Id = Convert.ToInt32(Session["mainwfid"]);
                    reim.FAPWF_Id = Convert.ToInt32(Session["fapwfid"]);
                    reim.Status = 13;

                    var rfp_id = Convert.ToString(reim.ID);
                    var rfp_doc = Convert.ToString(reim.RFP_DocNum);
                    Session["rfp_id"] = rfp_id;
                    Session["rfp_doc"] = rfp_doc;
                }

                _DataContext.SubmitChanges();

                if (btnaction == "Submit" || btnaction == "CreateSubmit")
                {
                    int wfID = Convert.ToInt32(Convert.ToInt32(Session["mainwfid"]));

                    // GET WORKFLOW DETAILS ID
                    var wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                    where wfd.WF_Id == wfID && wfd.Sequence == 1
                                    select wfd.WFD_Id;
                    int wfdID = wfDetails.FirstOrDefault();

                    // GET ORG ROLE ID
                    var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                  where or.WF_Id == wfID && or.Sequence == 1
                                  select or.OrgRole_Id;
                    int orID = (int)orgRole.FirstOrDefault();

                    //Add reim to workflow activity
                    if (reim != null)
                    {
                        //change reimbursement status to pending
                        reim.Status = 1;

                        ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                        {
                            Status = 1,
                            DateAssigned = DateTime.Now,
                            DateAction = null,
                            WF_Id = wfID,
                            WFD_Id = wfdID,
                            OrgRole_Id = orID,
                            Document_Id = Convert.ToInt32(reim.ID),
                            AppId = 1032,
                            CompanyId = Convert.ToInt32(company),
                            AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                            IsActive = true,
                        };
                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);

                    }

                    //change expense rep status to pending
                    exp.Status = 1;

                    //INSERT EXPENSE TO ITP_T_WorkflowActivity
                    DateTime currentDate = DateTime.Now;

                    ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                    {
                        Status = 1,
                        DateAssigned = currentDate,
                        DateAction = null,
                        WF_Id = wfID,
                        WFD_Id = wfdID,
                        OrgRole_Id = orID,
                        Document_Id = Convert.ToInt32(Session["TravelExp_Id"]),
                        AppId = 1032,
                        CompanyId = Convert.ToInt32(company),
                        AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense").Select(x => x.DCT_Id).FirstOrDefault(),
                        IsActive = true,
                    };
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                    _DataContext.SubmitChanges();

                    //InsertAttachment(Convert.ToInt32(Session["ExpenseId"]));
                    SendEmail(Convert.ToInt32(wfa.Document_Id), orID, Convert.ToInt32(company), 1);
                }

                return new { message = "success", rfp_doc = Convert.ToString(Session["rfp_doc"]) };
            }
            catch (Exception ex)
            {
                return new { message = ex.Message };
                throw;
            }
        }

        public void SendEmail(int doc_id, int org_id, int comps_id, int statusID)
        {
            DateTime currentDate = DateTime.Now;

            var status = _DataContext.ITP_S_Status
                .Where(x => x.STS_Id == statusID)
                .Select(x => x.STS_Description)
                .FirstOrDefault();

            ///////---START EMAIL PROCESS-----////////
            var user_userID = _DataContext.ITP_S_SecurityUserOrgRoles
                .Where(um => um.OrgRoleId == org_id)
                .Select(um => um.UserId)
                .FirstOrDefault();
            var user_email = _DataContext.ITP_S_UserMasters
                .Where(x => x.EmpCode == user_userID)
                .FirstOrDefault();
            var comp_name = _DataContext.CompanyMasters
                .Where(x => x.WASSId == comps_id)
                .FirstOrDefault();

            //Start--   Get Text info
            var queryText = from texts in _DataContext.ITP_S_Texts
                            where texts.Type == "Email" && texts.Name == "Pending"
                            select texts;

            var emailMessage = "";
            var emailSubMessage = "";
            var emailColor = "";

            foreach (var text in queryText)
            {
                emailMessage = text.Text1.ToString();
                emailSubMessage = text.Text2.ToString();
                emailColor = text.Color.ToString();
            }
            //End--     Get Text info

            var requestor_fullname = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
                .Select(um => um.Email)
                .FirstOrDefault();

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/AccedeExpenseReportApproval.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + doc_id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_ExpenseDetails
                          where er.ExpenseMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_id + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Particulars</th><th>Supplier</th><th>Net Amount</th><th>Date Created</th></tr>";

            foreach (var item in queryER)
            {
                var exp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.Particulars + "</td>" +
                            "<td style='text-align: center;'>" + item.Supplier + "</td>" +
                            "<td style='text-align: center;'>" + item.NetAmount + "</td>" +
                            "<td style='text-align: center;'>" + item.DateAdded.Value.ToLongDateString() + "</td>" +
                            "</tr>";
            }
            emailDetails += "</table>";

            //End of Body Details Sample
            string emailTemplate = anflo
                .Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender,
                emailDetails, senderRemarks, emailSite, emailColor);

            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
            {
            };
        }


        [WebMethod]
        public static ExpDetails DisplayExpDetailsAJAX(int expDetailID)
        {
            TravelExpenseEdit exp = new TravelExpenseEdit();
            return exp.DisplayExpDetails(expDetailID);
        }

        public ExpDetails DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == expDetailID).FirstOrDefault();
            ExpDetails exp_det_class = new ExpDetails();

            if (exp_details != null)
            {
                exp_det_class.travelDate = Convert.ToDateTime(exp_details.TravelExpenseDetail_Date).ToString("MM/dd/yyyy hh:mm:ss");
                if (exp_details.LocParticulars != null)
                {
                    exp_det_class.locParticulars = exp_details.LocParticulars;
                }
                if (exp_details.Total_Expenses != null)
                {
                    exp_det_class.totalExp = exp_details.Total_Expenses.ToString();
                }

                Session["ExpDetailsID"] = expDetailID.ToString();
            }

            return exp_det_class;
        }


        public class ExpDetails
        {
            public string travelDate { get; set; }
            public string locParticulars { get; set; }
            public string totalExp { get; set; }
        }

        protected void ExpenseEditForm_Init(object sender, EventArgs e)
        {
            InitializeDataSet();
        }

        private void InitializeDataSet()
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("ReimTranspo_ID", "ReimTranspo_Type", "ReimTranspo_Amount"),
                    CreateDataTable("FixedAllow_ID", "FixedAllow_ForP", "FixedAllow_Amount"),
                    CreateDataTable("MiscTravelExp_ID", "MiscTravelExp_Type", "MiscTravelExp_Amount", "MiscTravelExp_Specify"),
                    CreateDataTable("OtherBusinessExp_ID", "OtherBusinessExp_Type", "OtherBusinessExp_Amount", "OtherBusinessExp_Specify"),
                    CreateDataTable("Entertainment_ID", "Entertainment_Explain", "Entertainment_Amount"),
                    CreateDataTable("BusinessMeal_ID", "BusinessMeal_Explain", "BusinessMeal_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
            {
                ds = (DataSet)Session["DataSet"];
            }
        }

        private DataTable CreateDataTable(string idColumnName, params string[] columnNames)
        {
            var table = new DataTable();
            table.Columns.Add(idColumnName, typeof(int));
            foreach (var columnName in columnNames)
            {
                Type columnType = columnName.Contains("Amount") ? typeof(decimal) : typeof(string);
                table.Columns.Add(columnName, columnType);
            }
            table.PrimaryKey = new[] { table.Columns[idColumnName] };
            return table;
        }

        private int GetNewId(int tableIndex, string idColumn)
        {
            var table = ds.Tables[tableIndex];
            return table.Rows.Count == 0 ? 0 : table.AsEnumerable().Max(row => row.Field<int>(idColumn)) + 1;
        }

        private void RowInsert(ASPxGridView gridView, int tableIndex, ASPxDataInsertingEventArgs e, string idColumn)
        {
            e.NewValues["TravelExpenseDetail_ID"] = Convert.ToInt32(Session["ExpDetailsID"]);
            e.NewValues["User_ID"] = Convert.ToInt32(Session["userID"]);

            gridView.DataBind();
            gridView.JSProperties["cpSummary"] = gridView.GetTotalSummaryValue(gridView.TotalSummary[idColumn.Replace("_ID", "_Amount")]);
        }

        private void RowDelete(ASPxGridView gridView, int tableIndex, ASPxDataDeletingEventArgs e, string idColumn)
        {
            gridView.DataBind();
            gridView.JSProperties["cpSummary"] = gridView.GetTotalSummaryValue(gridView.TotalSummary[idColumn.Replace("_ID", "_Amount")]);
        }

        protected void reimTranGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 0, e, "ReimTranspo_ID");
        }

        protected void reimTranGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 0, e, "ReimTranspo_ID");
        }

        protected void fixedAllowGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 1, e, "FixedAllow_ID");
        }

        protected void fixedAllowGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 1, e, "FixedAllow_ID");
        }

        protected void miscTravelGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 2, e, "MiscTravelExp_ID");
        }

        protected void miscTravelGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 2, e, "MiscTravelExp_ID");
        }

        protected void otherBusGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 3, e, "OtherBusinessExp_ID");
        }

        protected void otherBusGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 3, e, "OtherBusinessExp_ID");
        }

        protected void entertainmentGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 4, e, "Entertainment_ID");
        }

        protected void entertainmentGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 4, e, "Entertainment_ID");
        }

        protected void busMealsGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            RowInsert((ASPxGridView)sender, 5, e, "BusinessMeal_ID");
        }

        protected void busMealsGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 5, e, "BusinessMeal_ID");
        }

        [WebMethod]
        public static object AddTravelExpenseDetailsAJAX(string locParticulars, DateTime travelDate, string totalExp)
        {
            TravelExpenseAdd exp = new TravelExpenseAdd();
            return exp.AddTravelExpenseDetails(locParticulars, travelDate, totalExp);
        }

        public object AddTravelExpenseDetails(string locParticulars, DateTime travelDate, string totalExp)
        {
            try
            {
                if (Convert.ToString(Session["expAction"]) == "add")
                {
                    // Initialize and set main travel expense details
                    var trav = new ACCEDE_T_TravelExpenseDetail
                    {
                        TravelExpenseDetail_Date = travelDate,
                        LocParticulars = locParticulars,
                        TravelExpenseMain_ID = Convert.ToInt32(Session["TravelExp_Id"]),
                        Total_Expenses = Convert.ToDecimal(totalExp)
                    };
                    _DataContext.ACCEDE_T_TravelExpenseDetails.InsertOnSubmit(trav);
                    _DataContext.SubmitChanges();

                    var travExpDetailId = trav.TravelExpenseDetail_ID;
                    var dataSet = (DataSet)Session["DataSet"];

                    // Define a helper method for adding mapped data
                    void InsertMappedData<T>(DataTable table, Action<T, DataRow> mapAction) where T : class, new()
                    {
                        foreach (DataRow row in table.Rows)
                        {
                            var map = new T();
                            mapAction(map, row);
                            _DataContext.GetTable<T>().InsertOnSubmit(map);
                        }
                    }

                    // Insert all mapped allocations using the helper method
                    InsertMappedData<ACCEDE_T_TraExpReimTranspoMap>(dataSet.Tables[0], (map, row) =>
                    {
                        map.ReimTranspo_Type = Convert.ToString(row["ReimTranspo_Type"]);
                        map.ReimTranspo_Amount = Convert.ToDecimal(row["ReimTranspo_Amount"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    InsertMappedData<ACCEDE_T_TraExpFixedAllowMap>(dataSet.Tables[1], (map, row) =>
                    {
                        map.FixedAllow_ForP = Convert.ToString(row["FixedAllow_ForP"]);
                        map.FixedAllow_Amount = Convert.ToDecimal(row["FixedAllow_Amount"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    InsertMappedData<ACCEDE_T_TraExpMiscTravelMap>(dataSet.Tables[2], (map, row) =>
                    {
                        map.MiscTravelExp_Type = Convert.ToString(row["MiscTravelExp_Type"]);
                        map.MiscTravelExp_Amount = Convert.ToDecimal(row["MiscTravelExp_Amount"]);
                        map.MiscTravelExp_Specify = Convert.ToString(row["MiscTravelExp_Specify"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    InsertMappedData<ACCEDE_T_TraExpOtherBusMap>(dataSet.Tables[3], (map, row) =>
                    {
                        map.OtherBusinessExp_Type = Convert.ToString(row["OtherBusinessExp_Type"]);
                        map.OtherBusinessExp_Amount = Convert.ToDecimal(row["OtherBusinessExp_Amount"]);
                        map.OtherBusinessExp_Specify = Convert.ToString(row["OtherBusinessExp_Specify"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    InsertMappedData<ACCEDE_T_TraExpEntertainmentMap>(dataSet.Tables[4], (map, row) =>
                    {
                        map.Entertainment_Explain = Convert.ToString(row["Entertainment_Explain"]);
                        map.Entertainment_Amount = Convert.ToDecimal(row["Entertainment_Amount"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    InsertMappedData<ACCEDE_T_TraExpBusinessMealMap>(dataSet.Tables[5], (map, row) =>
                    {
                        map.BusinessMeal_Explain = Convert.ToString(row["BusinessMeal_Explain"]);
                        map.BusinessMeal_Amount = Convert.ToDecimal(row["BusinessMeal_Amount"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    // Commit all changes at once
                    _DataContext.SubmitChanges();
                }
                else if (Convert.ToString(Session["expAction"]) == "edit")
                {
                    var updateExpDetail = _DataContext.ACCEDE_T_TravelExpenseDetails
                     .Where(x => x.TravelExpenseDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));

                    foreach (ACCEDE_T_TravelExpenseDetail ex in updateExpDetail)
                    {
                        //.IsExpenseCA = false;
                        ex.Total_Expenses = Convert.ToDecimal(totalExp);
                        ex.LocParticulars = locParticulars;
                        ex.TravelExpenseDetail_Date = travelDate;
                        ex.TravelExpenseMain_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    }
                    _DataContext.SubmitChanges();
                }

                return GetExpCA();
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        protected void CAGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            // Get the key value of the row being deleted
            var keyValue = e.Values["RFPMain_ID"];
            if (keyValue != null)
            {
                var updateRFP = _DataContext.ACCEDE_T_RFPMains
                     .Where(x => x.ID == Convert.ToInt32(keyValue));

                foreach (ACCEDE_T_RFPMain ex in updateRFP)
                {
                    //.IsExpenseCA = false;
                    ex.Exp_ID = null;
                }
                _DataContext.SubmitChanges();
            }
            else
                Debug.WriteLine("Column value not found in e.Values[\"RFPMain_ID\"]");
        }

        private DataTable GetDataTableFromSqlDataSource(SqlDataSource sqlDataSource)
        {
            DataView dataView = (DataView)sqlDataSource.Select(DataSourceSelectArguments.Empty);
            return dataView.ToTable();
        }

        protected void addExpCallback_Callback(object sender, CallbackEventArgsBase e)
        {
            // Clear the DataSet tables for the "add" action
            ds = (DataSet)Session["DataSet"];
            foreach (DataTable table in ds.Tables)
            {
                table.Clear();
            }
            if (e.Parameter == "add")
            {
                Session["expAction"] = "add";
            }
            else if (e.Parameter == "edit")
            {
                Session["expAction"] = "edit";

                // Load data from SqlDataSources into DataTables and merge
                ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlRTMap));
                ds.Tables[1].Merge(GetDataTableFromSqlDataSource(SqlFAMap));
                ds.Tables[2].Merge(GetDataTableFromSqlDataSource(SqlMTMap));
                ds.Tables[3].Merge(GetDataTableFromSqlDataSource(SqlOBMap));
                ds.Tables[4].Merge(GetDataTableFromSqlDataSource(SqlEMap));
                ds.Tables[5].Merge(GetDataTableFromSqlDataSource(SqlBMMap));
            }

            // Bind the tables to the grids
            reimTranGrid.DataSource = ds.Tables[0];
            fixedAllowGrid.DataSource = ds.Tables[1];
            miscTravelGrid.DataSource = ds.Tables[2];
            otherBusGrid.DataSource = ds.Tables[3];
            entertainmentGrid.DataSource = ds.Tables[4];
            busMealsGrid.DataSource = ds.Tables[5];

            // Data bind to refresh the grids
            reimTranGrid.DataBind();
            fixedAllowGrid.DataBind();
            miscTravelGrid.DataBind();
            otherBusGrid.DataBind();
            entertainmentGrid.DataBind();
            busMealsGrid.DataBind();

            reimTranGrid.JSProperties["cpSummary"] = reimTranGrid.GetTotalSummaryValue(reimTranGrid.TotalSummary["ReimTranspo_Amount"]);
            fixedAllowGrid.JSProperties["cpSummary"] = fixedAllowGrid.GetTotalSummaryValue(fixedAllowGrid.TotalSummary["FixedAllow_Amount"]);
            miscTravelGrid.JSProperties["cpSummary"] = miscTravelGrid.GetTotalSummaryValue(miscTravelGrid.TotalSummary["MiscTravelExp_Amount"]);
            otherBusGrid.JSProperties["cpSummary"] = otherBusGrid.GetTotalSummaryValue(otherBusGrid.TotalSummary["OtherBusinessExp_Amount"]);
            entertainmentGrid.JSProperties["cpSummary"] = entertainmentGrid.GetTotalSummaryValue(entertainmentGrid.TotalSummary["Entertainment_Amount"]);
            busMealsGrid.JSProperties["cpSummary"] = busMealsGrid.GetTotalSummaryValue(busMealsGrid.TotalSummary["BusinessMeal_Amount"]);
        }

        protected void wfCallback_Callback(object sender, CallbackEventArgsBase e)
        {
            var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();

            Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && Convert.ToDecimal(e.Parameter) >= x.Minimum && Convert.ToDecimal(e.Parameter) <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? null;

            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
            drpdown_FAPWF.DataBind();
            drpdown_FAPWF.SelectedIndex = 0;
            FAPWFGrid.DataBind();
        }

        [WebMethod]
        public static object SaveTotExpAJAX(string totexp)
        {
            TravelExpenseAdd tra = new TravelExpenseAdd();
            return tra.SaveTotExp(totexp);
        }

        public object SaveTotExp(string totexp)
        {
            try
            {
                if (Convert.ToString(Session["expAction"]) == "edit")
                {
                    var upd = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));
                    foreach (ACCEDE_T_TravelExpenseDetail t in upd)
                    {
                        t.Total_Expenses = Convert.ToDecimal(totexp);
                    }
                    _DataContext.SubmitChanges();
                }
                return GetExpCA();
            }
            catch (Exception)
            {
                return false;
            }
        }

        [WebMethod]
        public static bool CheckReimburseValidationAJAX(string t_amount)
        {
            TravelExpenseAdd ex = new TravelExpenseAdd();
            return ex.CheckReimburseValidation(t_amount);
        }

        public bool CheckReimburseValidation(string t_amount)
        {
            try
            {
                var rfp_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true);
                var totalCA = new decimal(0.00);
                foreach (var item in rfp_CA)
                {
                    totalCA += Convert.ToDecimal(item.Amount);

                }

                var expDetail = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseMain_ID == Convert.ToInt32(Session["TravelExp_Id"]));
                var totalExp = new decimal(0.00);
                foreach (var item in expDetail)
                {
                    totalExp += Convert.ToDecimal(item.Total_Expenses);
                }

                decimal totalDue = new decimal(0);
                totalDue = totalCA - totalExp;

                if (totalDue < 0 && Math.Abs(totalDue) > Convert.ToDecimal(t_amount))
                {
                    var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true);
                    if (rfpReim.Count() > 0)
                    {
                        return false;
                    }
                    else
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
                throw;
            }
        }

        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            TravelExpenseAdd exp = new TravelExpenseAdd();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public bool RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.RFP_DocNum == rfpDoc).FirstOrDefault();
                if (rfp != null)
                {
                    Session["passRFPID"] = rfp.ID;
                }
                return true;
            }
            catch (Exception ex) { return false; }
        }
    }
}