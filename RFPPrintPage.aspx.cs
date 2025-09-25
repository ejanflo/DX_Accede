using DX_WebTemplate.XtraReports;
using System;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web.Services;

namespace DX_WebTemplate
{
    public partial class RFPPrintPage : System.Web.UI.Page
    {
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            ASPxWebDocumentViewer1.DisableHttpHandlerValidation = true;
            if (!IsPostBack)
            {
                // Create an instance of your report
                AccedeRFPForm report = new AccedeRFPForm();

                try
                {
                    var cashinwords = "";
                    var companyid = "";
                    var company = "";
                    var costcenter = "";
                    var depcode = "";
                    var fullname = "";
                    var requestor = "";
                    var desig = "";
                    var isReprint = 0;

                    var chargeComp = "";
                    var chargeDept = "";
                    var classification = "";
                    var foreignDomestic = "";

                    //Recommending Approval
                    var recAppr1 = "Ronald T. Garcia";
                    var recAppr1Pos = "Line Approver 1";
                    var recAppr1Date = DateTime.Now;

                    var recAppr2 = "Ian James V. Gaspar";
                    var recAppr2Pos = "Line Approver 2";
                    var recAppr2Date = DateTime.Now;

                    var recAppr3 = "Ian James V. Gaspar";
                    var recAppr3Pos = "Line Approver 3";
                    var recAppr3Date = DateTime.Now;

                    var recAppr4 = "Ian James V. Gaspar";
                    var recAppr4Pos = "Line Approver 4";
                    var recAppr4Date = DateTime.Now;

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

                    //Forward Approver
                    var forAppr1 = "Jane Smith";
                    var forAppr1Pos = "";
                    var forAppr1Date = DateTime.Now;

                    var forAppr2 = "John S. Doe";
                    var forAppr2Pos = "";
                    var forAppr2Date = DateTime.Now;

                    var id = Convert.ToInt32(Session["passRFPID"]); //Pass session RFP_ID
                    var rfp = context.ACCEDE_T_RFPMains.Where(x => x.ID == id).FirstOrDefault();

                    //Requestor Request Date
                    var reqApprDate = Convert.ToDateTime(rfp.DateCreated);

                    companyid = rfp.Company_ID.ToString();

                    if (rfp != null)
                    {
                        company = context.CompanyMasters
                            .Where(x => x.WASSId == Convert.ToInt32(rfp.Company_ID))
                            .Select(x => x.CompanyShortName)
                            .FirstOrDefault();

                        var rfpSig = context.ACCEDE_T_RFPSignatures
                                    .FirstOrDefault(x => x.RFPMain_Id == Convert.ToInt32(rfp.ID));

                        if (rfpSig != null)
                        {
                            byte[] imgBytes = rfpSig.Signature.ToArray(); // raw image bytes
                            report.Tag = imgBytes; // store as byte[]
                        }

                        if (rfp.TranType == 3)
                        {
                            string raw = rfp.Payee.ToString();
                            string cleaned = raw.Replace("\r", "").Replace("\n", "");
                            var vendors = SAPConnector.GetVendorData("")
                                .GroupBy(x => new { x.VENDCODE, x.VENDNAME })
                                .Select(g => g.First())
                                .ToList();
                            var payee = vendors.Where(x => x.VENDCODE == cleaned).FirstOrDefault();
                            fullname = "";//payee.VENDNAME.ToString();

                            requestor = context.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Convert.ToString(rfp.User_ID))
                                    .Select(x => x.FullName)
                                    .FirstOrDefault();
                        }
                        else
                        {
                            fullname = context.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Convert.ToString(rfp.User_ID))
                                    .Select(x => x.FullName)
                                    .FirstOrDefault();

                            requestor = context.ITP_S_UserMasters
                                    .Where(x => x.EmpCode == Convert.ToString(rfp.User_ID))
                                    .Select(x => x.FullName)
                                    .FirstOrDefault();
                        }
                            
                        desig = context.ITP_S_UserMasters
                            .Where(x => x.EmpCode == Convert.ToString(rfp.User_ID))
                            .Select(x => x.DesDesc)
                            .FirstOrDefault();
                        depcode = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == rfp.Department_ID).Select(x => x.DepCode).FirstOrDefault();
                        costcenter = rfp.SAPCostCenter;
                        cashinwords = ConvertCurrencyToWords(Convert.ToDecimal(rfp.Amount));
                        isReprint = Convert.ToInt32(rfp.isRePrint);

                        // Set the RA 

                        //var ra1 = context.vw_ACCEDE_I_RAWFActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                        //    //.Where(x => x.IsRA == true)
                        //    .Where(x => x.WF_Id == rfp.WF_Id)
                        //    .Where(x=>x.DCT_Name == "ACDE RFP")
                        //    .OrderBy(x => x.WFA_Id)
                        //    .FirstOrDefault();

                        //var ra2 = context.vw_ACCEDE_I_RAWFActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                        //    //.Where(x => x.IsRA == true)
                        //    .Where(x => x.WF_Id == rfp.WF_Id)
                        //    .Where(x => x.DCT_Name == "ACDE RFP")
                        //    .Where(x => x.ActedBy_User_Id != ra1.ActedBy_User_Id)
                        //    .OrderBy(x => x.WFA_Id);
                        //    //.Skip(1) // Skip the first row (index 0)
                        //    //.Take(1) // Take only one row (index 1)
                        //    //.SingleOrDefault(); // Retrieve the single result;

                        // Set the RA (distinct approvers by first occurrence, but use their latest action)
                        var raBase = context.vw_ACCEDE_I_RAWFActivities
                            .Where(x => x.Document_Id == id
                                     && x.Status == 7
                                     && x.WF_Id == rfp.WF_Id
                                     && x.DCT_Name == "ACDE RFP");

                        // Determine the first two distinct approvers in sequence (by smallest WFA_Id)
                        var orderedApproverIds = raBase
                            .GroupBy(a => a.ActedBy_User_Id)
                            .Select(g => new
                            {
                                UserId = g.Key,
                                FirstWfa = g.Min(a => a.WFA_Id)
                            })
                            .OrderBy(x => x.FirstWfa)
                            .Select(x => x.UserId)
                            .ToList();

                        var ra1UserId = orderedApproverIds.FirstOrDefault();
                        var ra2UserId = orderedApproverIds.Skip(1).FirstOrDefault();
                        var ra3UserId = orderedApproverIds.Skip(2).FirstOrDefault();
                        var ra4UserId = orderedApproverIds.Skip(3).FirstOrDefault();

                        // For each approver, get the most recent approval activity
                        var ra1 = ra1UserId == null
                            ? null
                            : raBase.Where(a => a.ActedBy_User_Id == ra1UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        var ra2 = ra2UserId == null
                            ? null
                            : raBase.Where(a => a.ActedBy_User_Id == ra2UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        var ra3 = ra3UserId == null
                            ? null
                            : raBase.Where(a => a.ActedBy_User_Id == ra3UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        var ra4 = ra4UserId == null
                            ? null
                            : raBase.Where(a => a.ActedBy_User_Id == ra4UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        if (ra1 != null)
                        {
                            recAppr1 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra1.ActedBy_User_Id)
                                .Select(x => x.FullName)
                                .FirstOrDefault();
                            recAppr1Date = Convert.ToDateTime(ra1.DateAction);
                        }
                        else
                        {
                            recAppr1 = "";
                        }

                        if (ra2 != null)
                        {
                            recAppr2 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra2.ActedBy_User_Id)
                                .Select(x => x.FullName)
                                .FirstOrDefault();
                            recAppr2Date = Convert.ToDateTime(ra2.DateAction);
                        }
                        else
                        {
                            recAppr2 = "";
                            recAppr2Date = Convert.ToDateTime("01/01/0001");
                        }

                        if (ra3 != null)
                        {
                            recAppr3 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra3.ActedBy_User_Id)
                            .FirstOrDefault().FullName;
                            recAppr3Date = Convert.ToDateTime(ra3.DateAction);
                        }
                        else
                        {
                            recAppr3 = "";
                            recAppr3Date = Convert.ToDateTime("01/01/0001");
                        }

                        if (ra4 != null)
                        {
                            recAppr4 = context.ITP_S_UserMasters.Where(x => x.EmpCode == ra4.ActedBy_User_Id).FirstOrDefault().FullName;
                            recAppr4Date = Convert.ToDateTime(ra4.DateAction);
                        }
                        else
                        {
                            recAppr4 = "";
                            recAppr4Date = Convert.ToDateTime("01/01/0001");
                        }

                        var fin1 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                            .Where(x=>x.WF_Id == rfp.FAPWF_Id)
                            //.Where(x => x.IsRA == false || x.IsRA == null)
                            //.Where(x => !x.WF_Name.Contains("ACDE AUDIT"))
                            //.Where(x => !x.WF_Name.Contains("ACDE P2P"))
                            //.Where(x => !x.WF_Name.Contains("ACDE CASHIER"))
                            //.Where(x => x.DCT_Name == "ACDE RFP")
                            .OrderBy(x => x.WFA_Id)
                            .FirstOrDefault();

                        var fin2 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                            .Where(x => x.WF_Id == rfp.FAPWF_Id)
                            //.Where(x => x.IsRA == false || x.IsRA == null)
                            //.Where(x => !x.WF_Name.Contains("ACDE AUDIT"))
                            //.Where(x => !x.WF_Name.Contains("ACDE P2P"))
                            //.Where(x => !x.WF_Name.Contains("ACDE CASHIER"))
                            //.Where(x => x.DCT_Name == "ACDE RFP")
                            .OrderBy(x => x.WFA_Id)
                            .Skip(1) // Skip the first row (index 0)
                            .Take(1) // Take only one row (index 1)
                            .SingleOrDefault(); // Retrieve the single result;

                        var fin3 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                            .Where(x => x.WF_Id == rfp.FAPWF_Id)
                            //.Where(x => x.IsRA == false || x.IsRA == null)
                            //.Where(x => !x.WF_Name.Contains("ACDE AUDIT"))
                            //.Where(x => !x.WF_Name.Contains("ACDE P2P"))
                            //.Where(x => !x.WF_Name.Contains("ACDE CASHIER"))
                            //.Where(x => x.DCT_Name == "ACDE RFP")
                            .OrderBy(x => x.WFA_Id)
                            .Skip(2) // Skip the first row (index 0)
                            .Take(1) // Take only one row (index 1)
                            .SingleOrDefault(); // Retrieve the single result;

                        var fin4 = context.vw_ACCEDE_I_WorkflowActivities.Where(x => x.Document_Id == id).Where(x => x.Status == 7)
                            .Where(x => x.WF_Id == rfp.FAPWF_Id)
                            //.Where(x => x.IsRA == false || x.IsRA == null)
                            //.Where(x => !x.WF_Name.Contains("ACDE AUDIT"))
                            //.Where(x => !x.WF_Name.Contains("ACDE P2P"))
                            //.Where(x => !x.WF_Name.Contains("ACDE CASHIER"))
                            //.Where(x => x.DCT_Name == "ACDE RFP")
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

                        // Set the Forward Approver
                        var forBase = context.vw_ACCEDE_I_WorkflowActivities
                            .Where(x => x.Document_Id == id
                                     && x.Status == 7
                                     && x.WF_Id != rfp.WF_Id
                                     && x.WF_Id != rfp.FAPWF_Id
                                     && x.WF_Name.Contains("ACDE AUDIT") == false
                                     && x.WF_Name.Contains("ACDE P2P") == false
                                     && x.WF_Name.Contains("ACDE CASHIER") == false
                                     && x.DCT_Name == "ACDE RFP");

                        // Determine the first two distinct approvers in sequence (by smallest WFA_Id)
                        var ForOrderedApproverIds = forBase
                            .GroupBy(a => a.ActedBy_User_Id)
                            .Select(g => new
                            {
                                UserId = g.Key,
                                FirstWfa = g.Min(a => a.WFA_Id)
                            })
                            .OrderBy(x => x.FirstWfa)
                            .Select(x => x.UserId)
                            .ToList();

                        var for1UserId = ForOrderedApproverIds.FirstOrDefault();
                        var for2UserId = ForOrderedApproverIds.Skip(1).FirstOrDefault();

                        // For each approver, get the most recent approval activity
                        var for1 = for1UserId == null
                            ? null
                            : forBase.Where(a => a.ActedBy_User_Id == for1UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        var for2 = for2UserId == null
                            ? null
                            : forBase.Where(a => a.ActedBy_User_Id == for2UserId)
                                    .OrderByDescending(a => a.DateAction)
                                    .ThenByDescending(a => a.WFA_Id)
                                    .FirstOrDefault();

                        if (for1 != null)
                        {
                            forAppr1 = context.ITP_S_UserMasters.Where(x => x.EmpCode == for1.ActedBy_User_Id)
                                .Select(x => x.FullName)
                                .FirstOrDefault();
                            forAppr1Date = Convert.ToDateTime(for1.DateAction);
                        }
                        else
                        {
                            forAppr1 = "";
                            forAppr1Date = Convert.ToDateTime("01/01/0001");
                        }

                        if (for2 != null)
                        {
                            forAppr2 = context.ITP_S_UserMasters.Where(x => x.EmpCode == for2.ActedBy_User_Id)
                                .Select(x => x.FullName)
                                .FirstOrDefault();
                            forAppr2Date = Convert.ToDateTime(for2.DateAction);
                        }
                        else
                        {
                            forAppr2 = "";
                            forAppr2Date = Convert.ToDateTime("01/01/0001");
                        }

                        //Payment method in text
                        var payMethod = context.ACCEDE_S_PayMethods.Where(x => x.ID == rfp.PayMethod).FirstOrDefault();

                        //Transaction type in text
                        var tranType = "";
                        if (rfp.PayMethod != null)
                        {
                            tranType = context.ACCEDE_S_RFPTranTypes.Where(x => x.ID == rfp.TranType).FirstOrDefault().RFPTranType_Name;
                        }

                        var payeeSig = "";
                        var dateReceived = DateTime.Now;

                        if(rfpSig != null)
                        {
                            if (rfp.PayMethod == 3)
                            {
                                payeeSig = rfpSig.Signee_Fullname;
                            }
                            dateReceived = Convert.ToDateTime(rfpSig.DateReceived);
                        }
                        

                        //Account to be charged in text
                        var acctCharge = "";
                        if (rfp.AcctCharged != null)
                        {
                            acctCharge = context.ACDE_T_MasterCodes.Where(x => x.ID == rfp.AcctCharged).FirstOrDefault().Description;
                        }

                        //Last day transact in text
                        var lastDayTran = "";
                        if (rfp.LastDayTransact != null)
                        {
                            lastDayTran = Convert.ToDateTime(rfp.LastDayTransact).ToString("MM/dd/yyyy");
                        }

                        //Projected Liquidation date in text
                        var PLdate = "";
                        if (rfp.PLDate != null)
                        {
                            PLdate = Convert.ToDateTime(rfp.PLDate).ToString("MM/dd/yyyy");
                        }

                        //Charged to Company in text
                        if (rfp.ChargedTo_CompanyId != null)
                        {
                            var chargeCompId = context.CompanyMasters.Where(x => x.WASSId == Convert.ToInt32(rfp.ChargedTo_CompanyId)).Select(x => x.CompanyShortName).FirstOrDefault() ?? String.Empty;
                            chargeComp = chargeCompId.ToString();
                        }

                        //Charged to Department in text
                        if (rfp.ChargedTo_DeptId != null)
                        {
                            var chargeDeptId = context.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(rfp.ChargedTo_DeptId)).Select(x => x.DepCode).FirstOrDefault() ?? String.Empty;
                            chargeDept = chargeDeptId.ToString();
                        }

                        //Classification in text
                        if (rfp.Classification_Type_Id != null)
                        {
                            var classificationId = context.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(rfp.Classification_Type_Id)).Select(x => x.ClassificationName).FirstOrDefault() ?? String.Empty;
                            classification = classificationId.ToString();
                        }

                        //isForeignTravel in text
                        if (rfp.isForeignTravel == true)
                            foreignDomestic = "FOREIGN";
                        else
                            foreignDomestic = "DOMESTIC";

                        // Set the parameter value
                        report.Parameters["isRePrint"].Value = isReprint; // SET ang value diri sa watermark 

                        report.Parameters["id"].Value = rfp.ID;
                        report.Parameters["company"].Value = company.ToString();
                        report.Parameters["companyid"].Value = companyid;
                        report.Parameters["fullname"].Value = fullname.ToUpper();
                        report.Parameters["requestor"].Value = requestor.ToUpper();
                        report.Parameters["cashinwords"].Value = cashinwords.ToUpper();
                        report.Parameters["desig"].Value = desig.ToUpper();
                        report.Parameters["depcost"].Value = depcode.ToUpper() + " - " + costcenter;
                        report.Parameters["chargeComp"].Value = chargeComp.ToUpper();
                        report.Parameters["chargeDept"].Value = chargeDept.ToUpper();
                        report.Parameters["classification"].Value = classification.ToUpper();
                        report.Parameters["foreignDomestic"].Value = foreignDomestic.ToUpper();
                        report.Parameters["reqApprDate"].Value = reqApprDate;

                        report.Parameters["recAppr1"].Value = recAppr1.ToUpper();
                        report.Parameters["recAppr2"].Value = recAppr2.ToUpper();
                        report.Parameters["recAppr3"].Value = recAppr3.ToUpper();
                        report.Parameters["recAppr4"].Value = recAppr4.ToUpper();
                        report.Parameters["recAppr1Pos"].Value = recAppr1Pos.ToUpper(); 
                        report.Parameters["recAppr2Pos"].Value = recAppr2Pos.ToUpper();
                        report.Parameters["recAppr3Pos"].Value = recAppr3Pos.ToUpper();
                        report.Parameters["recAppr4Pos"].Value = recAppr4Pos.ToUpper();
                        report.Parameters["recAppr1Date"].Value = recAppr1Date;
                        report.Parameters["recAppr2Date"].Value = recAppr2Date;
                        report.Parameters["recAppr3Date"].Value = recAppr3Date;
                        report.Parameters["recAppr4Date"].Value = recAppr4Date;

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

                        report.Parameters["forAppr1"].Value = forAppr1.ToUpper();
                        report.Parameters["forAppr2"].Value = forAppr2.ToUpper();
                        report.Parameters["forAppr1Pos"].Value = forAppr1Pos.ToUpper();
                        report.Parameters["forAppr2Pos"].Value = forAppr2Pos.ToUpper();
                        report.Parameters["forAppr1Date"].Value = forAppr1Date;
                        report.Parameters["forAppr2Date"].Value = forAppr2Date;

                        report.Parameters["payMethodStr"].Value = payMethod != null ? payMethod.PMethod_name.ToString() : "";
                        report.Parameters["tranTypeStr"].Value = tranType != null ? tranType.ToString() : "";
                        report.Parameters["AcctChargeStr"].Value = acctCharge != null ? acctCharge.ToString() : "";
                        report.Parameters["LastDayTranStr"].Value = lastDayTran != null ? lastDayTran.ToString() : "";
                        report.Parameters["PLDateStr"].Value = PLdate != null ? PLdate.ToString() : "";
                        report.Parameters["payeeSig"].Value = payeeSig != null ? payeeSig.ToString() : "";
                        report.Parameters["dateReceived"].Value = dateReceived != null ? dateReceived.ToString("MM/dd/yyyy") : DateTime.Now.ToString("MM/dd/yyyy");
                    }

                    // Create report and generate its document.
                    report.CreateDocument();

                    // Reset all page numbers in the resulting document.
                    report.PrintingSystem.ContinuousPageNumbering = true;

                    // View report on document viewer
                    ASPxWebDocumentViewer1.OpenReport(report);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        [WebMethod]
        public static bool SetRePrintAJAX(bool val)
        {
            RFPPrintPage exp = new RFPPrintPage();
            return exp.SetRePrint(val);
        }

        public bool SetRePrint(bool val)
        {
            try
            {
                var rfp = context.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"]));

                foreach (var item in rfp)
                {
                    item.isRePrint = val;
                }
                context.SubmitChanges();
                return true;

            }
            catch (Exception)
            {
                return false;
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

        private static string[] unitsMap = { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
                                         "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen" };
        private static string[] tensMap = { "Zero", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety" };

        public static string ConvertToWords(int number)
        {
            if (number == 0)
                return "Zero";

            if (number < 0)
                return "Minus " + ConvertToWords(Math.Abs(number));

            string words = "";

            if ((number / 1000000) > 0)
            {
                words += ConvertToWords(number / 1000000) + " Million ";
                number %= 1000000;
            }

            if ((number / 1000) > 0)
            {
                words += ConvertToWords(number / 1000) + " Thousand ";
                number %= 1000;
            }

            if ((number / 100) > 0)
            {
                words += ConvertToWords(number / 100) + " Hundred ";
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