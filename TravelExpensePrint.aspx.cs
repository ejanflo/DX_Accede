using DevExpress.CodeParser.VB;
using DX_WebTemplate.XtraReports;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TravelExpensePrint : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            ASPxWebDocumentViewer1.DisableHttpHandlerValidation = true;
            if (!IsPostBack)
            {
                AccedeTravelMain report = new AccedeTravelMain();

                try
                {
                    var id = Convert.ToInt32(Session["TravelExp_Id"]);
                    var travel = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).FirstOrDefault();

                    if (travel != null)
                    {
                        var audwf = context.ITP_S_WorkflowHeaders.Where(x => x.Name == "ACCEDE AUDIT" && x.Description == "ACCEDE AUDIT" && x.App_Id == 1032).Select(x => x.WF_Id).FirstOrDefault();
                        var audapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == audwf && x.AppId == 1032).FirstOrDefault();
                        var audapprdate = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == audwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var audapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == audapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        var finwf = travel.FAPWF_Id;
                        var finapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == finwf && x.AppId == 1032).FirstOrDefault();
                        var finapprdate = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == finwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var finapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == finapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        var depwf = travel.WF_Id;
                        var depapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == depwf && x.AppId == 1032).FirstOrDefault();
                        var depapprdate = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == depwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var depapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == depapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        var totalca = context.ACCEDE_T_RFPMains
                            .Where(x => x.Exp_ID == id && x.TranType == 1 && x.User_ID == Convert.ToString(Session["userID"]))
                            .Sum(x => (decimal?)x.Amount) ?? 0;

                        var totalexp = context.ACCEDE_T_TravelExpenseDetails
                            .Where(x => x.TravelExpenseMain_ID == id)
                            .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                        var companyid = travel.Company_Id;
                        var companyname = context.CompanyMasters.Where(x => x.WASSId == companyid).Select(x => x.CompanyDesc).FirstOrDefault().ToUpper();
                        var exptype = travel.ExpenseType_ID;
                        var datefrom = travel.Date_From;
                        var dateto = travel.Date_To;
                        var tripto = travel.Trip_To.ToUpper();
                        var timearrived = travel.Time_Arrived;
                        var timedeparted = travel.Time_Departed;
                        var empname = context.ITP_S_UserMasters.Where(x => x.EmpCode == Convert.ToString(travel.Employee_Id)).Select(x => x.FullName).FirstOrDefault().ToUpper();
                        var empdate = DateTime.Now;
                        var department = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(travel.Dep_Code)).Select(x => x.DepDesc).FirstOrDefault().ToUpper();
                        var purpose = travel.Purpose.ToUpper();

                        report.Parameters["id"].Value = id;
                        report.Parameters["companyid"].Value = companyid;
                        report.Parameters["companyname"].Value = companyname;
                        report.Parameters["exptype"].Value = exptype;
                        report.Parameters["datefrom"].Value = datefrom;
                        report.Parameters["dateto"].Value = dateto;
                        report.Parameters["tripto"].Value = tripto;
                        report.Parameters["timearrived"].Value = timearrived.HasValue ? (DateTime?)DateTime.Today.Add(timearrived.Value) : null;
                        report.Parameters["timedeparted"].Value = timedeparted.HasValue ? (DateTime?)DateTime.Today.Add(timedeparted.Value) : null;
                        report.Parameters["empname"].Value = empname;
                        report.Parameters["department"].Value = department;
                        report.Parameters["purpose"].Value = purpose;
                        report.Parameters["totalca"].Value = totalca;
                        report.Parameters["totalexp"].Value = totalexp;
                        report.Parameters["empdate"].Value = empdate;
                        report.Parameters["audapprname"].Value = audapprname;
                        report.Parameters["audapprdate"].Value = audapprdate;
                        report.Parameters["finapprname"].Value = finapprname;
                        report.Parameters["finapprdate"].Value = finapprdate;
                        report.Parameters["depapprname"].Value = depapprname;
                        report.Parameters["depapprdate"].Value = depapprdate;

                    }

                    // Create report and generate its document.
                    report.CreateDocument();

                    // Reset all page numbers in the resulting document.
                    report.PrintingSystem.ContinuousPageNumbering = true;

                    // View report on document viewer
                    ASPxWebDocumentViewer1.OpenReport(report);
                }
                catch (Exception)
                {

                    throw;
                }
            }
        }
    }
}