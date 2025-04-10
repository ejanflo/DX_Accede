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
                AccedeTravelMainTrails report2 = new AccedeTravelMainTrails();

                try
                {
                    var id = Convert.ToInt32(Session["TravelExp_Id"]);
                    var travel = context.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == id).FirstOrDefault();

                    DateTime finapprdate = DateTime.Now;
                    DateTime depapprdate = DateTime.Now;
                    DateTime fwdapprdate0 = DateTime.Now;
                    DateTime fwdapprdate = DateTime.Now;
                    DateTime p2papprdate = DateTime.Now;
                    DateTime cashapprdate = DateTime.Now;
                    var finapprname = string.Empty;
                    var depapprname = string.Empty;
                    var fwdapprname0 = string.Empty;
                    var fwdapprname = string.Empty;
                    var p2papprname = string.Empty;
                    var cashapprname = string.Empty;

                    if (travel != null)
                    {
                        // Audit Approvers
                        var audwf = context.ITP_S_WorkflowHeaders.Where(x => x.Name == "ACDE AUDIT" && x.Company_Id == travel.Company_Id && x.Description == "ACDE AUDIT" && x.App_Id == 1032).Select(x => x.WF_Id).FirstOrDefault();
                        var audapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == audwf && x.AppId == 1032).FirstOrDefault();
                        var audapprdate = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == audwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var audapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == audapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        // FAP Approvers
                        var finwf = travel.FAPWF_Id;
                        var finwfd0 = context.ITP_S_WorkflowDetails.Where(x => x.WF_Id == finwf && x.Sequence == 1).Select(x => x.WFD_Id).FirstOrDefault();
                        var finapprid0 = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == finwfd0 && x.WF_Id == finwf && x.AppId == 1032).FirstOrDefault();
                        var finapprdate0 = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == finwfd0 && x.WF_Id == finwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var finapprname0 = context.ITP_S_UserMasters.Where(x => x.EmpCode == finapprid0.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        var finwfd = context.ITP_S_WorkflowDetails.Where(x => x.WF_Id == finwf && x.Sequence == 2).FirstOrDefault();

                        if (finwfd != null)
                        {
                            var finapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == finwfd.WFD_Id && x.WF_Id == finwf && x.AppId == 1032).Select(x => x.ActedBy_User_Id).FirstOrDefault();
                            finapprdate = (DateTime)context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == finwfd.WFD_Id && x.WF_Id == finwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                            finapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == finapprid).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }

                        // Line Manager Approvers
                        var depwf = travel.WF_Id;

                        var depwfd0 = context.ITP_S_WorkflowDetails.Where(x => x.WF_Id == depwf && x.Sequence == 1).Select(x => x.WFD_Id).FirstOrDefault();
                        var depapprid0 = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == depwfd0 && x.WF_Id == depwf && x.AppId == 1032).Select(x => x.ActedBy_User_Id).FirstOrDefault();
                        var depapprdate0 = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == depwfd0 && x.WF_Id == depwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                        var depapprname0 = context.ITP_S_UserMasters.Where(x => x.EmpCode == depapprid0).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;

                        var depwfd = context.ITP_S_WorkflowDetails.Where(x => x.WF_Id == depwf && x.Sequence == 2).FirstOrDefault();

                        if (depwfd != null)
                        {
                            var depapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == depwfd.WFD_Id && x.WF_Id == depwf && x.AppId == 1032).Select(x => x.ActedBy_User_Id).FirstOrDefault();
                            depapprdate = (DateTime)context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WFD_Id == depwfd.WFD_Id && x.WF_Id == depwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                            depapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == depapprid).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }

                        // P2P Approvers
                        var p2pwf = context.ITP_S_WorkflowHeaders.Where(x => x.Name == "ACDE P2P" && x.Company_Id == travel.Company_Id && x.Description == "ACDE P2P" && x.App_Id == 1032).Select(x => x.WF_Id).FirstOrDefault();
                        var p2papprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == p2pwf && x.AppId == 1032).FirstOrDefault();

                        if (p2papprid != null)
                        {
                            p2papprdate = (DateTime)context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == p2pwf && x.AppId == 1032).Select(x => x.DateAction).FirstOrDefault();
                            p2papprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == p2papprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }

                        // Cashier Approvers
                        var cashpwf = context.ITP_S_WorkflowHeaders.Where(x => x.Name == "ACDE CASHIER" && x.Company_Id == travel.Company_Id && x.Description == "ACDE CASHIER" && x.App_Id == 1032).Select(x => x.WF_Id).FirstOrDefault();
                        var cashapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.WF_Id == cashpwf && x.AppId == 1032).FirstOrDefault();

                        if (cashapprid != null)
                        {
                            cashapprdate = (DateTime)cashapprid.DateAction;
                            cashapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == cashapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }

                        // Forwarded Approvers
                        var fwdapprid0 = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.IsDelete == true && x.AppId == 1032).FirstOrDefault();
                        if (fwdapprid0 != null)
                        {
                            fwdapprdate0 = (DateTime)fwdapprid0.DateAction;
                            fwdapprname0 = context.ITP_S_UserMasters.Where(x => x.EmpCode == fwdapprid0.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }

                        var fwdapprid = context.ITP_T_WorkflowActivities.Where(x => x.Document_Id == travel.ID && x.IsDelete == true && x.AppId == 1032).OrderByDescending(x => x.WFA_Id).FirstOrDefault();

                        if (fwdapprid != null)
                        {
                            fwdapprdate = (DateTime)fwdapprid.DateAction;
                            fwdapprname = context.ITP_S_UserMasters.Where(x => x.EmpCode == fwdapprid.ActedBy_User_Id).Select(x => x.FullName).FirstOrDefault().ToUpper() ?? string.Empty;
                        }


                        var totalca = context.ACCEDE_T_RFPMains
                            .Where(x => x.Exp_ID == id && x.TranType == 1 && x.User_ID == Convert.ToString(Session["userID"]))
                            .Sum(x => (decimal?)x.Amount) ?? 0;

                        var totalexp = context.ACCEDE_T_TravelExpenseDetails
                            .Where(x => x.TravelExpenseMain_ID == id)
                            .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                        var ford = travel.ForeignDomestic.ToUpper();
                        var docnum = travel.Doc_No;
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
                        var chargedto = "";
                        var cComp = (context.CompanyMasters.Where(x => x.WASSId == travel.ChargedToComp).Select(x => x.CompanyShortName).FirstOrDefault() ?? string.Empty).ToUpper();
                        var cDept = (context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == travel.ChargedToDept).Select(x => x.DepCode).FirstOrDefault() ?? string.Empty).ToUpper();

                        if (!string.IsNullOrEmpty(cComp) && !string.IsNullOrEmpty(cDept))
                            chargedto = cComp + " - " + cDept;
                        else if (!string.IsNullOrEmpty(cComp) && string.IsNullOrEmpty(cDept))
                            chargedto = cComp;
                        else if (string.IsNullOrEmpty(cComp) && !string.IsNullOrEmpty(cDept))
                            chargedto = cDept;

                        report.Parameters["id"].Value = id; 
                        report2.Parameters["id2"].Value = id;
                        report2.Parameters["docnum"].Value = docnum;
                        report.Parameters["ford"].Value = ford;
                        report.Parameters["docnum"].Value = docnum;
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
                        report.Parameters["chargedto"].Value = chargedto;
                        report.Parameters["purpose"].Value = purpose;
                        report.Parameters["totalca"].Value = totalca;
                        report.Parameters["totalexp"].Value = totalexp;
                        report.Parameters["empdate"].Value = empdate;
                        report.Parameters["audapprname"].Value = audapprname;
                        report.Parameters["audapprdate"].Value = audapprdate;
                        report.Parameters["finapprname0"].Value = finapprname0;
                        report.Parameters["finapprdate0"].Value = finapprdate0;
                        report.Parameters["finapprname"].Value = finapprname;
                        report.Parameters["finapprdate"].Value = finapprdate;
                        report.Parameters["depapprname0"].Value = depapprname0;
                        report.Parameters["depapprdate0"].Value = depapprdate0;
                        report.Parameters["depapprname"].Value = depapprname;
                        report.Parameters["depapprdate"].Value = depapprdate;
                        report.Parameters["p2papprname"].Value = p2papprname;
                        report.Parameters["p2papprdate"].Value = p2papprdate;
                        report.Parameters["cashapprname"].Value = cashapprname;
                        report.Parameters["cashapprdate"].Value = cashapprdate;
                        report.Parameters["fwdapprname0"].Value = fwdapprname0;
                        report.Parameters["fwdapprdate0"].Value = fwdapprdate0;
                        report.Parameters["fwdapprname"].Value = fwdapprname;
                        report.Parameters["fwdapprdate"].Value = fwdapprdate;
                    }

                    // Create report and generate its document.
                    report.CreateDocument();
                    report2.CreateDocument();

                    // Merge pages of two reports, page-by-page.
                    int minPageCount = Math.Min(report.Pages.Count, report2.Pages.Count);
                    for (int i = 0; i < minPageCount; i++)
                    {
                        report.Pages.Insert(i * 2 + 1, report2.Pages[i]);
                    }
                    if (report2.Pages.Count != minPageCount)
                    {
                        for (int i = minPageCount; i < report2.Pages.Count; i++)
                        {
                            report.Pages.Add(report2.Pages[i]);
                        }
                    }

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