using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class Accede_Expense_Report : System.Web.UI.Page
    {
        // CREATE object of DATABASE-ITPORTAL
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());
                    var EmpCode = Session["userID"].ToString();

                    SqlUserCompany.SelectParameters["UserId"].DefaultValue = EmpCode;
                    SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = EmpCode;

                    //drpdown_EmpId.Value = EmpCode.ToString();
                    //drpdown_EmpId.DataBindItems();

                    //drpdown_EmpId.Value = EmpCode;
                }
                else
                    Response.Redirect("~/Logon.aspx");

            }
            catch (Exception ex)
            {
                Response.Redirect("~/Logon.aspx");
            }
            
        }

        protected void expenseGrid_ToolbarItemClick(object source, DevExpress.Web.Data.ASPxGridViewToolbarItemClickEventArgs e)
        {
            
        }

        protected void expenseGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            //string[] args = e.Parameters.Split('|');
            //string rowKey = args[0];
            //string buttonId = args[1];

            //object IDValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "ID");
            //object statValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "Status");
            //object companyValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "Company_ID");
            //object prepValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "User_ID");
            //object docnoValue = expenseGrid.GetRowValuesByKeyValue(rowKey, "DocNo");

            //var query = from a in context.ITP_S_Status
            //            where a.STS_Id == int.Parse(statValue.ToString())
            //            select a.STS_Description;
            //string stat = query.FirstOrDefault();

            //Session["cID"] = IDValue;
            //Session["comp"] = companyValue;
            //Session["stat"] = stat;
            //Session["prep"] = prepValue;
            //Session["docno"] = docnoValue;

            //if (buttonId == "btnView")
            //{
            //    expenseGrid.JSProperties["cp_btnid"] = "btnView";
            //    expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportReview.aspx";
            //}
            //else if (buttonId == "btnEdit")
            //{
            //    Session["edit"] = true;
            //    expenseGrid.JSProperties["cp_btnid"] = "btnEdit";
            //    expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportSaves.aspx";
            //}
            //else if (buttonId == "btnPrint")
            //{
            //    expenseGrid.JSProperties["cp_btnid"] = "btnPrint";
            //    expenseGrid.JSProperties["cp_url"] = "AccedeExpenseReportPrint.aspx";
            //}

            Session["ExpenseId"] = e.Parameters.Split('|').First();
            if(e.Parameters.Split('|').Last() == "btnEdit")
            {
                ASPxWebControl.RedirectOnCallback("AccedeExpenseReportEdit1.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnView")
            {
                ASPxWebControl.RedirectOnCallback("AccedeExpenseViewPage.aspx");
            }
            if (e.Parameters.Split('|').Last() == "btnPrint")
            {
                Session["cID"] = e.Parameters.Split('|').First();
                ASPxWebControl.RedirectOnCallback("AccedeExpenseReportPrinting.aspx");
            }

        }

        protected void expenseGrid_CustomButtonInitialize(object sender, DevExpress.Web.ASPxGridViewCustomButtonEventArgs e)
        {
            
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnEdit") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = expenseGrid.GetRowValues(e.VisibleIndex, "Status");

                var returned_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();
                var returnP2PStats = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by P2P").FirstOrDefault();

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (statusValue.ToString() == "15" || statusValue.ToString() == "13" || statusValue.ToString() == "3" || statusValue.ToString() == returned_audit.STS_Id.ToString() || statusValue.ToString() == returnP2PStats.STS_Id.ToString()))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }

            if (e.VisibleIndex >= 0 && e.ButtonID == "btnPrint") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = expenseGrid.GetRowValues(e.VisibleIndex, "Status");
                var completeStat = context.ITP_S_Status.Where(x => x.STS_Name == "Complete").FirstOrDefault();
                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (statusValue.ToString() == completeStat.STS_Id.ToString()))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void ASPxGridView2_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["AccedeExpenseID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = drpdown_Department.Value != null ? drpdown_Department.Value.ToString() : "";
            SqlCostCenter.DataBind();

            //drpdown_CostCenter.DataSourceID = null;
            //drpdown_CostCenter.DataSource = SqlCostCenter;
            //drpdown_CostCenter.DataBindItems();

            //if(drpdown_CostCenter.Items.Count == 1)
            //{
            //    drpdown_CostCenter.SelectedIndex = 0;
            //}

        }

        [WebMethod]
        public static string GetCosCenterFrmDeptAJAX(string dept_id)
        {
            Accede_Expense_Report accede = new Accede_Expense_Report();
            return accede.GetCosCenterFrmDept(dept_id);
        }

        public string GetCosCenterFrmDept(string dept_id)
        {
            var deptCostCenter = context.ITP_S_OrgDepartmentMasters.Where(x=>x.ID == Convert.ToInt32(dept_id)).FirstOrDefault();
            if (deptCostCenter != null && deptCostCenter.SAP_CostCenter != null) 
            { 
                return deptCostCenter.SAP_CostCenter.ToString();
            }
            else
            {
                return "";
            }
        }

        [WebMethod]
        public static bool AddExpenseReportAJAX(string expName, string expDate, string Comp, string CostCenter, string expCat, string Purpose, bool isTrav, string currency, string department, string payType, string classification, string CTComp_id, string CTDept_id, string CompLoc)
        {
            Accede_Expense_Report accede = new Accede_Expense_Report();
            
            return accede.AddExpenseReport(expName, expDate, Comp, CostCenter, expCat, Purpose, isTrav, currency, department, payType, classification, CTComp_id, CTDept_id, CompLoc); 
        }

        public bool AddExpenseReport(string expName, string expDate, string Comp, string CostCenter, string expCat, string Purpose, bool isTrav, string currency, string department, string payType, string classification, string CTComp_id, string CTDept_id, string CompLoc)
        {
            var expDoctype = context.ITP_S_DocumentTypes.Where(x=>x.DCT_Name == "ACDE Expense").FirstOrDefault();
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(Convert.ToInt32(expDoctype.DCT_Id), Convert.ToInt32(Comp), 1032);
                var docNo = generateDocNo.GetLatest_DocNum(Convert.ToInt32(expDoctype.DCT_Id), Convert.ToInt32(Comp), 1032);

                ACCEDE_T_ExpenseMain main = new ACCEDE_T_ExpenseMain();
                {
                    main.ExpenseName = expName;
                    main.ReportDate = Convert.ToDateTime(expDate);
                    main.ExpenseType_ID = Convert.ToInt32(payType);
                    if(Comp != "")
                    {
                        main.CompanyId = Convert.ToInt32(Comp);
                    }
                    
                    if(CostCenter != "")
                    {
                        main.CostCenter = CostCenter;
                    }
                    main.ExpenseCat = Convert.ToInt32(expCat);
                    main.Purpose = Purpose;
                    main.Status = 13;
                    main.UserId = Session["userID"].ToString();
                    main.DocNo = docNo;
                    main.DateCreated = DateTime.Now;
                    main.isTravel = isTrav;
                    main.Exp_Currency = currency;
                    if(department != "")
                    {
                        main.Dept_Id = Convert.ToInt32(department);
                    }
                    main.ExpenseClassification = Convert.ToInt32(classification);
                    main.ExpChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    main.ExpChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    main.ExpComp_Location_Id = Convert.ToInt32(CompLoc);
                }
                context.ACCEDE_T_ExpenseMains.InsertOnSubmit(main);
                context.SubmitChanges();

                Session["ExpenseId"] = main.ID;
                
            }
            catch (Exception ex)
            {
                return false;
            }
            
            return true;
        }

        protected void CAGrid_BeforePerformDataSelect(object sender, EventArgs e)
        {
            Session["AccedeExpenseID"] = (sender as ASPxGridView).GetMasterRowKeyValue();
        }

        protected void expenseGrid_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "Status")
            {
                var pay_released = context.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").FirstOrDefault();
                var pending_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                var return_audit = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by Audit").FirstOrDefault();
                var pendingP2P = context.ITP_S_Status.Where(x => x.STS_Name == "Pending at P2P").FirstOrDefault();
                var return_p2p = context.ITP_S_Status.Where(x => x.STS_Name == "Returned by P2P").FirstOrDefault();

                string value = e.CellValue.ToString();
                if (value == "7" || value == "5")
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");//approved
                    e.Cell.Font.Bold = true;
                }
                else if (value == "2" || value == "3" || value == "18" || value == "19")
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#E67C0E");//rejected
                    e.Cell.Font.Bold = true;
                }
                else if (value == return_audit.STS_Id.ToString() || value == return_p2p.STS_Id.ToString())
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#E67C0E");//returned by audit/p2p
                    e.Cell.Font.Bold = true;
                }
                else if (value == pending_audit.STS_Id.ToString() || value == pendingP2P.STS_Id.ToString())
                {
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#006DD6");//pending audit/p2p
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
                    e.Cell.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0D6943");//disbursed
                    e.Cell.Font.Bold = true;
                }
                else
                {
                    e.Cell.ForeColor = System.Drawing.Color.Gray;
                    e.Cell.Font.Bold = true;
                }
            }
        }

        protected void drpdown_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            sqlDept.SelectParameters["CompanyId"].DefaultValue = e.Parameter != null ? e.Parameter.ToString() : "";
            sqlDept.SelectParameters["UserId"].DefaultValue = drpdown_EmpId.Value != null ? drpdown_EmpId.Value.ToString() : Session["userID"].ToString();
            sqlDept.DataBind();

            drpdown_Department.DataSourceID = null;
            drpdown_Department.DataSource = sqlDept;
            drpdown_Department.DataBindItems();

            if(drpdown_Department.Items.Count == 1)
            {
                drpdown_Department.SelectedIndex = 0;
            }
        }

        protected void drpdown_Comp_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlUserCompany.SelectParameters["UserId"].DefaultValue = e.Parameter != null ? e.Parameter.ToString() : "";
            SqlUserCompany.DataBind();

            drpdown_EmpId.DataSourceID = null;
            drpdown_EmpId.DataSource = SqlUserCompany;
            drpdown_EmpId.DataBindItems();
        }

        protected void drpdown_EmpId_Callback(object sender, CallbackEventArgsBase e)
        {
            //var comp_id = drpdown_Comp.Value != null ? Convert.ToInt32(drpdown_Comp.Value) : 0;
            var comp_id = e.Parameter.ToString();
            if (comp_id != "")
            {
                SqlUser.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
                SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();

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
                    drpdown_EmpId.DataSource = dt;
                    drpdown_EmpId.TextField = "FullName";   // Ensure text field is set correctly
                    drpdown_EmpId.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly

                    drpdown_EmpId.Value = Session["userID"].ToString();
                    drpdown_EmpId.DataBind();
                }
            }
            


        }

        protected void drpdown_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();

            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
            SqlCTDepartment.DataBind();

            drpdown_CTDepartment.DataSourceID = null;
            drpdown_CTDepartment.DataSource = SqlCTDepartment;
            drpdown_CTDepartment.DataBind();

            if(drpdown_CTDepartment.Items.Count == 1)
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