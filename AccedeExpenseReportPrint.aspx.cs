using DX_WebTemplate.XtraReports;
using System;
using System.Configuration;
using System.Globalization;
using System.Linq;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseReportPrint : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            docViewer.DisableHttpHandlerValidation = true;
            if (!IsPostBack)
            {
                // Create an instance of your report
                AccedeExpenseReportView report = new AccedeExpenseReportView();
                AccedeRFPForm report2 = new AccedeRFPForm();

                try
                {
                    //Requestor Request Date
                    var reqApprDate = DateTime.Now;

                    //Recommending Approval
                    var recAppr1 = "Ronald T. Garcia";
                    var recAppr1Pos = "Recommending Approver 1";
                    var recAppr1Date = DateTime.Now;

                    var recAppr2 = "Ian James V. Gaspar";
                    var recAppr2Pos = "Recommending Approver 2";
                    var recAppr2Date = DateTime.Now;

                    //FAP Approver
                    var finAppr1 = "Ni Wang Kho";
                    var finAppr1Pos = "FAP Approver No. 1";
                    var finAppr1Date = DateTime.Now;

                    var finAppr2 = "Tiburcio Z. Policarpio";
                    var finAppr2Pos = "FAP Approver No. 2";
                    var finAppr2Date = DateTime.Now;

                    var finAppr3 = "John S. Doe";
                    var finAppr3Pos = "FAP Approver No. 3";
                    var finAppr3Date = DateTime.Now;

                    var finAppr4 = "Cleofin R. Pardillo";
                    var finAppr4Pos = "FAP Approver No. 4";
                    var finAppr4Date = DateTime.Now;

                    var cashinwords = ""; var depcode = ""; var costcenter = "";
                    var em = context.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["cID"].ToString())).FirstOrDefault();
                    var company = context.CompanyMasters
                            .Where(x => x.WASSId == Convert.ToInt32(em.CompanyId))
                            .Select(x => x.CompanyDesc)
                            .FirstOrDefault();
                    var fullname = context.ITP_S_UserMasters
                            .Where(x => x.EmpCode == Convert.ToString(em.UserId))
                    .Select(x => x.FullName)
                            .FirstOrDefault();
                    var desig = context.ITP_S_UserMasters
                        .Where(x => x.EmpCode == Convert.ToString(em.UserId))
                        .Select(x => x.DesDesc)
                        .FirstOrDefault();
                    var stat_id = context.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").Select(x => x.STS_Id).FirstOrDefault();
                    var cashadvance = context.ACCEDE_T_RFPMains.Where(x => x.TranType == 1 && x.Status == Convert.ToInt32(stat_id) && x.IsExpenseCA == true && x.Exp_ID == em.ID).Sum(x => x.Amount);
                    var reimbursement = context.ACCEDE_T_RFPMains.Where(x => x.TranType == 2 && x.IsExpenseReim == true && x.Exp_ID == em.ID).Sum(x => x.Amount);
                    var cashexpense = context.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == em.ID).Sum(x => x.NetAmount);

                    var rfp = context.ACCEDE_T_RFPMains.Where(x => x.IsExpenseReim == true && x.Exp_ID == em.ID).FirstOrDefault();


                    if (rfp != null)
                    {
                        cashinwords = ConvertCurrencyToWords(Convert.ToDecimal(rfp.Amount));
                        depcode = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfp.Department_ID).Select(x => x.DepCode).FirstOrDefault();
                        costcenter = rfp.SAPCostCenter;
                    }

                    // Set the RA 

                    var ra1 = context.vw_ACCEDE_I_RAWFActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == true)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .FirstOrDefault();

                    var ra2 = context.vw_ACCEDE_I_RAWFActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == true)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .Skip(1) // Skip the first row (index 0)
                        .Take(1) // Take only one row (index 1)
                        .SingleOrDefault(); // Retrieve the single result;

                    if (ra1 != null)
                    {
                        recAppr1 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra1.ActedBy_User_Id)
                        .FirstOrDefault().FullName;
                        recAppr1Date = Convert.ToDateTime(ra1.DateAction);
                    }
                    else
                    {
                        recAppr1 = "";
                    }

                    if (ra2 != null)
                    {
                        recAppr2 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra2.ActedBy_User_Id).FirstOrDefault().FullName;
                        recAppr2Date = Convert.ToDateTime(ra2.DateAction);
                    }
                    else
                    {
                        recAppr2 = "";
                        recAppr2Date = Convert.ToDateTime("01/01/0001");
                    }

                    var fin1 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == false || x.IsRA == null)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .FirstOrDefault();

                    var fin2 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == false || x.IsRA == null)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .Skip(1) // Skip the first row (index 0)
                        .Take(1) // Take only one row (index 1)
                        .SingleOrDefault(); // Retrieve the single result;

                    var fin3 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == false || x.IsRA == null)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .Skip(2) // Skip the first row (index 0)
                        .Take(1) // Take only one row (index 1)
                        .SingleOrDefault(); // Retrieve the single result;

                    var fin4 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == em.ID).Where(x => x.Status == 7)
                        .Where(x => x.IsRA == false || x.IsRA == null)
                        .Where(x => x.DCT_Name == "ACDE Expense")
                        .OrderBy(x => x.WFA_Id)
                        .Skip(3) // Skip the first row (index 0)
                        .Take(1) // Take only one row (index 1)
                        .SingleOrDefault(); // Retrieve the single result;

                    var fin1_id = fin1 != null ? fin1.ActedBy_User_Id : "";
                    var fin2_id = fin2 != null ? fin2.ActedBy_User_Id : "";
                    var fin3_id = fin3 != null ? fin3.ActedBy_User_Id : "";
                    var fin4_id = fin4 != null ? fin4.ActedBy_User_Id : "";

                    if (fin1 != null)
                    {
                        finAppr1 = context.ITP_S_UserMasters.Where(x => x.EmpCode == fin1_id).FirstOrDefault().FullName;
                        finAppr1Date = Convert.ToDateTime(fin1.DateAction);
                    }
                    else
                    {
                        finAppr1 = "";
                        finAppr1Date = Convert.ToDateTime("01/01/0001");
                    }

                    if (fin2 != null && fin2_id != fin1_id)
                    {
                        finAppr2 = context.ITP_S_UserMasters.Where(x => x.EmpCode == fin2_id).FirstOrDefault().FullName;
                        finAppr2Date = Convert.ToDateTime(fin2.DateAction);
                    }
                    else
                    {
                        finAppr2 = "";
                        finAppr2Date = Convert.ToDateTime("01/01/0001");
                    }

                    if (fin3 != null && fin3_id != fin1_id && fin3_id != fin2_id)
                    {
                        finAppr3 = context.ITP_S_UserMasters.Where(x => x.EmpCode == fin3_id).FirstOrDefault().FullName;
                        finAppr3Date = Convert.ToDateTime(fin3.DateAction);
                    }
                    else
                    {
                        finAppr3 = "";
                        finAppr3Date = Convert.ToDateTime("01/01/0001");
                    }

                    if (fin4 != null && fin4_id != fin1_id && fin4_id != fin2_id && fin4_id != fin3_id)
                    {
                        finAppr4 = context.ITP_S_UserMasters.Where(x => x.EmpCode == fin4_id).FirstOrDefault().FullName;
                        finAppr4Date = Convert.ToDateTime(fin3.DateAction);
                    }
                    else
                    {
                        finAppr4 = "";
                        finAppr4Date = Convert.ToDateTime("01/01/0001");
                    }

                    // Set the parameter value
                    report.Parameters["id"].Value = Convert.ToInt32(Session["cID"].ToString());
                    report2.Parameters["id"].Value = Convert.ToInt32(Session["cID"].ToString());
                    report.Parameters["company"].Value = company.ToString();
                    report2.Parameters["company"].Value = company.ToString();
                    report.Parameters["fullname"].Value = FormatName(fullname.ToString());
                    report.Parameters["fullname2"].Value = fullname.ToUpper();
                    report2.Parameters["fullname"].Value = fullname.ToUpper();
                    report.Parameters["cashadvance"].Value = cashadvance;
                    report.Parameters["reimbursement"].Value = reimbursement;
                    report2.Parameters["cashinwords"].Value = cashinwords.ToUpper();
                    report2.Parameters["depcost"].Value = depcode.ToUpper() + " - " + costcenter;
                    report.Parameters["desig"].Value = desig.ToUpper();
                    report.Parameters["companyid"].Value = em.CompanyId.ToString();
                    report2.Parameters["companyid"].Value = em.CompanyId.ToString();

                    report.Parameters["recAppr1"].Value = recAppr1.ToUpper();
                    report.Parameters["recAppr2"].Value = recAppr2.ToUpper();
                    report.Parameters["recAppr1Pos"].Value = recAppr1Pos.ToUpper(); ;
                    report.Parameters["recAppr2Pos"].Value = recAppr2Pos.ToUpper(); ;

                    report.Parameters["finAppr1"].Value = finAppr1.ToUpper();
                    report.Parameters["finAppr2"].Value = finAppr2.ToUpper();
                    report.Parameters["finAppr3"].Value = finAppr3.ToUpper();
                    report.Parameters["finAppr4"].Value = finAppr4.ToUpper();
                    report.Parameters["finAppr1Pos"].Value = finAppr1Pos.ToUpper();
                    report.Parameters["finAppr2Pos"].Value = finAppr2Pos.ToUpper();
                    report.Parameters["finAppr3Pos"].Value = finAppr3Pos.ToUpper();
                    report.Parameters["finAppr4Pos"].Value = finAppr4Pos.ToUpper();
                    report.Parameters["finAppr1Date"].Value = finAppr1Date;
                    report.Parameters["finAppr2Date"].Value = finAppr2Date;
                    report.Parameters["finAppr3Date"].Value = finAppr3Date;
                    report.Parameters["finAppr4Date"].Value = finAppr4Date;
                    report.Parameters["reqApprDate"].Value = reqApprDate;
                    report.Parameters["recAppr1Date"].Value = recAppr1Date;
                    report.Parameters["recAppr2Date"].Value = recAppr2Date;

                    // Create report and generate its document.
                    report.CreateDocument();
                    report2.CreateDocument();

                    if (cashexpense > cashadvance && em.ExpenseType_ID == 2)
                    {
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
                    }

                    // Reset all page numbers in the resulting document.
                    report.PrintingSystem.ContinuousPageNumbering = true;

                    docViewer.OpenReport(report);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        static string FormatName(string name)
        {
            TextInfo textInfo = CultureInfo.CurrentCulture.TextInfo;
            string[] parts = name.Split(' ');
            for (int i = 0; i < parts.Length; i++)
            {
                if (!parts[i].Contains('.') || parts[i].Contains('-') || parts[i] == "CO." || parts[i] == "INC." || parts[i] == "BRGY." || parts[i] == "SR." || parts[i] == "JR.")
                    parts[i] = textInfo.ToTitleCase(parts[i].ToLower());
                else if (parts[i].EndsWith("."))
                    parts[i] = parts[i].Substring(0, parts[i].Length - 1) + ".";
            }
            return string.Join(" ", parts);
        }

        private static string[] unitsMap = { "Siro", "Wan", "To", "Tree", "Por", "Payb", "Seks", "Seben", "Eyt", "Nayn", "Tin",
                                         "Eleben", "Twelb", "Tirten", "Porten", "Pepten", "Seksten", "Sebenten", "Eyte", "Naynte" };
        private static string[] tensMap = { "Siro", "Tin", "Twente", "Terte", "Porte", "Pepte", "Sekste", "Sebente", "Eyte", "Naynte" };

        public static string ConvertToWords(int number)
        {
            if (number == 0)
                return "Siro";

            if (number < 0)
                return "Minus " + ConvertToWords(Math.Abs(number));

            string words = "";

            if ((number / 1000000) > 0)
            {
                words += ConvertToWords(number / 1000000) + " Melyon ";
                number %= 1000000;
            }

            if ((number / 1000) > 0)
            {
                words += ConvertToWords(number / 1000) + " Tawsan ";
                number %= 1000;
            }

            if ((number / 100) > 0)
            {
                words += ConvertToWords(number / 100) + " Hanrid ";
                number %= 100;
            }

            if (number > 0)
            {
                if (number < 20)
                    words += unitsMap[number];
                else
                {
                    words += tensMap[number / 10];
                    if ((number % 10) > 0)
                        words += " " + unitsMap[number % 10];
                }
            }

            return words.Trim();
        }

        public static string ConvertCurrencyToWords(decimal number)
        {
            int integerPart = (int)number;
            int fractionalPart = (int)((number - integerPart) * 100); // Assume two decimal places

            string words = ConvertToWords(integerPart) + " Peso" + (integerPart != 1 ? "s" : "");

            if (fractionalPart > 0)
                words += " and " + ConvertToWords(fractionalPart) + " Centavo" + (fractionalPart != 1 ? "s" : "");

            return words;
        }
    }
}