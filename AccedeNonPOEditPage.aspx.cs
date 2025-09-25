using DevExpress.Web;
using DevExpress.XtraRichEdit.Model;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Runtime.Caching;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DX_WebTemplate.AccedeModels;
using static DX_WebTemplate.SAPVendor;

namespace DX_WebTemplate
{
    public partial class AccedeNonPOEditPage : System.Web.UI.Page
    {
        string ITPORTALcon = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        // NEW: in‑memory cache for frequently reused lookups (vendor list etc.)
        private static readonly ObjectCache _cache = MemoryCache.Default;
        private const string SapClientParam = "sap-client=300";

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!AnfloSession.Current.ValidCookieUser())
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                // Establish session (only once per request)
                AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                // Fast validation of critical session values
                var empCode = Session["userID"] as string;
                if (string.IsNullOrEmpty(empCode) || Session["NonPOInvoiceId"] == null)
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                int invoiceId;
                if (!Int32.TryParse(Session["NonPOInvoiceId"].ToString(), out invoiceId))
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                // Single fetch of main invoice entity
                var mainInv = _DataContext.ACCEDE_T_InvoiceMains
                    .FirstOrDefault(x => x.ID == invoiceId);

                if (mainInv == null)
                {
                    Response.Redirect("~/Logon.aspx");
                    return;
                }

                // Check if there is RFP generated
                var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .Where(x => x.isTravel != true)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true)
                    .FirstOrDefault();

                // Set RFP Details visible
                var ptvLayoutItem = ExpenseEditForm.FindItemOrGroupByName("ReimLayout") as LayoutGroup;
                if (ptvRFP != null)
                {
                    ptvLayoutItem.ClientVisible = true; link_rfp.Value = ptvRFP.RFP_DocNum;
                }
                    

                // Preload document type once
                var appDocType = _DataContext.ITP_S_DocumentTypes
                    .FirstOrDefault(x => x.DCT_Name == "ACDE InvoiceNPO" && x.App_Id == 1032);

                // Always set SQLDataSource parameters (needed for callbacks / partial updates)
                SetSqlParameters(mainInv, appDocType, empCode);

                // Compute totals with a single DB aggregation (replaces foreach loop)
                var totalExp = _DataContext.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == mainInv.ID)
                    .Select(x => (decimal?)x.NetAmount)
                    .Sum() ?? 0m;

                lbl_expenseTotal.Text = totalExp.ToString("#,##0.00") + "  " + mainInv.Exp_Currency;
                if(Session["InvoiceNo"] != null)
                    invoice_add.Value = Session["InvoiceNo"].ToString();

                // UI caption update (cheap)
                var layoutGroup = ExpenseEditForm.FindItemOrGroupByName("EditFormName") as LayoutGroup;
                if (layoutGroup != null)
                    layoutGroup.Caption = mainInv.DocNo + " (Edit)";

                // Initialize in-memory datasets only once
                if (!IsPostBack)
                {
                    EnsureExpenseAllocDataSet();
                    EnsureDocumentDataSet();
                }
                else
                {
                    // Rebind from session (avoid rebuilding)
                    RebindSessionData();
                }



                // Bind vendors & workflows only on initial load (heavy operations)
                if (!IsPostBack && !IsCallback)
                {
                    BindVendorDropdown(mainInv);
                    SetupWorkflows(mainInv, empCode, totalExp);
                }

                // Persist frequently reused values
                Session["DocNo"] = mainInv.DocNo;
                Session["ExpMain_ID"] = mainInv.ID;


            }
            catch (Exception)
            {
                if (!IsPostBack)
                    Response.Redirect("~/Logon.aspx");
            }
        }



        // --- HELPERS (NEW / REFACTORED) --------------------------------------------------

        private void EnsureExpenseAllocDataSet()
        {
            if (!IsPostBack || (Session["DataSetInvAlloc"] == null))
            {
                dsExpAlloc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("CostCenter", typeof(string));
                masterTable.Columns.Add("NetAmount", typeof(decimal));
                masterTable.Columns.Add("Remarks", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsExpAlloc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetInvAlloc"] = dsExpAlloc;

            }
            else
            {
                dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
                ExpAllocGrid.DataSource = dsExpAlloc.Tables[0];
                ExpAllocGrid.DataBind();
            }
        }

        private void SetSqlParameters(ACCEDE_T_InvoiceMain mainInv, ITP_S_DocumentType appDocType, string empCode)
        {
            var idStr = mainInv.ID.ToString();
            SqlExpDetails.SelectParameters["InvMain_ID"].DefaultValue = idStr;
            SqlMain.SelectParameters["ID"].DefaultValue = idStr;
            SqlDocs.SelectParameters["Doc_ID"].DefaultValue = idStr;
            SqlDocs.SelectParameters["DocType_Id"].DefaultValue = appDocType != null ? appDocType.DCT_Id.ToString() : null;

            SqlCompany.SelectParameters["UserId"].DefaultValue = empCode;
            sqlCostCenter.SelectParameters["Company_ID"].DefaultValue = mainInv.InvChargedTo_CompanyId.ToString();
            SqlDepartment.SelectParameters["UserId"].DefaultValue = empCode;
            SqlRFPMainReim.SelectParameters["Exp_ID"].DefaultValue = mainInv.ID.ToString();
            sqlDept.SelectParameters["CompanyId"].DefaultValue = mainInv.CompanyId.ToString();
            sqlDept.SelectParameters["UserId"].DefaultValue = empCode;
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = mainInv.InvChargedTo_CompanyId.ToString();
            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = mainInv.InvChargedTo_CompanyId.ToString();
        }

        private void BindVendorDropdown(ACCEDE_T_InvoiceMain mainInv)
        {
            // Company SAP code
            var compCode = _DataContext.CompanyMasters
                .Where(x => x.WASSId == Convert.ToInt32(mainInv.InvChargedTo_CompanyId))
                .Select(x => x.SAP_Id)
                .FirstOrDefault();

            if (string.IsNullOrEmpty(compCode.ToString()))
                return;

            var vendorList = GetVendorListCached(compCode.ToString());

            drpdown_vendor.DataSource = vendorList;
            drpdown_vendor.ValueField = "VENDCODE";
            drpdown_vendor.TextField = "VENDNAME";
            drpdown_vendor.Columns.Clear();
            drpdown_vendor.Columns.Add("VENDCODE");
            drpdown_vendor.Columns.Add("VENDNAME");
            drpdown_vendor.TextFormatString = "{0} - {1}";
            drpdown_vendor.DataBindItems();
            drpdown_vendor.ValidationSettings.RequiredField.IsRequired = true;
        }

        // (Optional) replace old GetVendorListCached calls with this wrapper; keep original method if still referenced elsewhere.
        private List<VendorSet> GetVendorListCached(string compCode)
        {
            return GetOrRefreshVendorList(compCode, false);
        }

        private void SetupWorkflows(ACCEDE_T_InvoiceMain mainInv, string empCode, decimal totalExp)
        {
            // FAP Workflow (unchanged logic but consolidated + guard)
            //var fapWf = _DataContext.ITP_S_WorkflowHeaders
            //    .Where(x => x.Company_Id == Convert.ToInt32(mainInv.InvChargedTo_CompanyId)
            //             && x.App_Id == 1032
            //             && (x.With_DivHead == false || x.With_DivHead == null)
            //             && x.IsRA != true
            //             && x.Minimum <= Math.Abs(totalExp)
            //             && x.Maximum >= Math.Abs(totalExp))
            //    .FirstOrDefault();

            var fapWf = _DataContext.ITP_S_WorkflowHeaders
                .Where(x => x.Company_Id == Convert.ToInt32(mainInv.InvChargedTo_CompanyId))
                .Where(x => x.App_Id == 1032)
                .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                .Where(x => x.IsRA == false || x.IsRA == null)
                .Where(x => x.Minimum <= Math.Abs(totalExp))
                .Where(x => x.Maximum >= Math.Abs(totalExp))
                .FirstOrDefault();

            if (fapWf != null)
            {
                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = fapWf.WF_Id.ToString();
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = fapWf.WF_Id.ToString();
                drpdwn_FAPWF.SelectedIndex = 0;
            }

            // RA / Main Workflow
            var depcode = _DataContext.ITP_S_OrgDepartmentMasters
                .FirstOrDefault(x => x.ID == (mainInv.Dept_Id ?? 0));

            var wfMap = _DataContext.vw_ACCEDE_I_WFMappings
                .FirstOrDefault(x => x.UserId == mainInv.VendorName && x.Company_Id == Convert.ToInt32(mainInv.CompanyId));

            if (wfMap != null)
            {
                SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = wfMap.WF_ID.ToString();
                SqlWF.SelectParameters["WF_Id"].DefaultValue = wfMap.WF_ID.ToString();
                drpdown_WF.DataSourceID = null;
                drpdown_WF.DataSource = SqlWF;
                drpdown_WF.SelectedIndex = 0;
                drpdown_WF.DataBind();

                WFSequenceGrid.DataSourceID = null;
                WFSequenceGrid.DataSource = SqlWorkflowSequence;
                WFSequenceGrid.DataBind();
            }
            else if (depcode != null)
            {
                SqlWFAmount.SelectParameters["UserId"].DefaultValue = empCode;
                SqlWFAmount.SelectParameters["CompanyId"].DefaultValue = mainInv.InvChargedTo_CompanyId.ToString();
                SqlWFAmount.SelectParameters["totalExp"].DefaultValue = totalExp.ToString(CultureInfo.InvariantCulture);
                SqlWFAmount.SelectParameters["DepCode"].DefaultValue = depcode.DepCode;
                SqlWFAmount.SelectParameters["AppId"].DefaultValue = "1032";
                SqlWFAmount.DataBind();

                drpdown_WF.DataSourceID = null;
                drpdown_WF.DataSource = SqlWFAmount;
                drpdown_WF.SelectedIndex = 0;
                drpdown_WF.DataBind();
            }
        }

        

        private void EnsureDocumentDataSet()
        {
            if (Session["DataSetInvDoc"] == null)
            {
                var ds = new DataSet();
                DataTable master = new DataTable();
                master.Columns.Add("ID", typeof(int));
                master.Columns.Add("FileName", typeof(string));
                master.Columns.Add("FileByte", typeof(byte[]));
                master.Columns.Add("FileExt", typeof(string));
                master.Columns.Add("FileSize", typeof(string));
                master.Columns.Add("FileDesc", typeof(string));
                master.PrimaryKey = new[] { master.Columns["ID"] };
                ds.Tables.Add(master);
                Session["DataSetInvDoc"] = ds;
            }
            else
            {
                dsDoc = (DataSet)Session["DataSetInvDoc"];
                DocuGrid.DataSource = dsDoc.Tables[0];
                DocuGrid.DataBind();
            }
        }

        private void RebindSessionData()
        {
            if (Session["DataSetInvAlloc"] is DataSet allocDs)
            {
                dsExpAlloc = allocDs;
                ExpAllocGrid.DataSource = dsExpAlloc.Tables[0];
                ExpAllocGrid.DataBind();
            }
            if (Session["DataSetInvDoc"] is DataSet docDs)
            {
                dsDoc = docDs;
                DocuGrid.DataSource = dsDoc.Tables[0];
                DocuGrid.DataBind();
            }
        }


        DataSet dsDoc = null;
        DataSet dsExpAlloc = null;
        private int GetNewId()
        {
            dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
            DataTable table = dsExpAlloc.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["ID"]);
            }
            return max + 1;
        }

        private int GetDocNewId()
        {
            dsDoc = (DataSet)Session["DataSetInvDoc"];
            DataTable table = dsDoc.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["ID"]);
            }
            return max + 1;
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

                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE InvoiceNPO")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["NonPOInvoiceId"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(exp_CTCompany.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                }
                ;
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
            DocumentGrid.DataBind();
        }

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {

        }

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {

        }

        protected void WFSequenceGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            //var param = e.Parameters.Split('|');
            //var dept_id = param[0] != "null" ? param[0] : "0";
            //var comp = param[1] != "null" ? param[1] : "0";
            //var depcode = _DataContext.ITP_S_OrgDepartmentMasters
            //    .Where(x => x.ID == Convert.ToInt32(dept_id))
            //    .FirstOrDefault();

            //var expMain = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"])).FirstOrDefault();

            //var wfMapCheck = _DataContext.vw_ACCEDE_I_WFMappings.Where(x => x.UserId == expMain.ExpenseName)
            //                .Where(x => x.Company_Id == Convert.ToInt32(comp))
            //                .FirstOrDefault();

            //if (wfMapCheck != null)
            //{
            //    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = wfMapCheck.WF_ID.ToString();

            //    WFSequenceGrid.DataSourceID = null;
            //    WFSequenceGrid.DataSource = SqlWorkflowSequence;
            //    WFSequenceGrid.DataBind();
            //}
            //else
            //{
            //    if(depcode != null)
            //    {
            //        var rawf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == expMain.ExpenseName)
            //                    .Where(x => x.CompanyId == Convert.ToInt32(comp))
            //                    .Where(x => x.DepCode == depcode.DepCode)
            //                    //.Where(x => x.IsRA == true)
            //                    .FirstOrDefault();

            //        if (rawf != null)
            //        {
            //            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rawf.WF_Id.ToString();
            //            SqlWorkflowSequence.DataBind();

            //            WFSequenceGrid.DataSourceID = null;
            //            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            //            WFSequenceGrid.DataBind();
            //        }
            //        else
            //        {
            //            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = "0";
            //            WFSequenceGrid.DataSourceID = null;
            //            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            //            WFSequenceGrid.DataBind();

            //        }
            //    }

            //}

            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = e.Parameters != null ? e.Parameters.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();

        }

        protected void FAPWFGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = e.Parameters != null ? e.Parameters.ToString() : "";
            SqlFAPWF.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWF;
            FAPWFGrid.DataBind();
        }

        //protected void capopGrid_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        //{
        //    capopGrid.DataBind();
        //}

        [WebMethod]
        public static bool AddCA_AJAX(List<int> selectedValues)
        {
            try
            {
                AccedeNonPOEditPage accede = new AccedeNonPOEditPage();
                bool result = accede.AddCA(selectedValues);
                return result;
            }
            catch (Exception ex)
            {
                // Log the error (ex.Message)
                return false;
            }
        }

        public bool AddCA(List<int> selectedIds)
        {
            try
            {
                var expMain = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .FirstOrDefault();

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
                        ex.Exp_ID = Convert.ToInt32(Session["NonPOInvoiceId"]);
                        ex.isTravel = false;

                        expMain.PaymentType = ex.PayMethod;
                    }

                    _DataContext.SubmitChanges();
                }

                //caPopup.ShowOnPageLoad = false;
                //DocuGrid1.DataBind();
            }
            catch (Exception ex)
            {
                return false;
            }
            return true;
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
            {
                Debug.WriteLine("Column value not found in e.Values[\"RFPMain_ID\"]");
            }

            //Session["caTotal"] = DocuGrid1.GetTotalSummaryValue(DocuGrid1.TotalSummary["Amount"]).ToString();
            //CultureInfo cultureInfo = new CultureInfo("en-PH");
            //caTotal.Text = (string)(!string.IsNullOrEmpty((string)Session["caTotal"]) ? string.Format(cultureInfo, "{0:C2}", Convert.ToDecimal(Session["caTotal"])) : string.Empty);

            //Compute_ExpCA(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            //ShowRmbmtButton(Convert.ToDecimal(expenseTotal.Text.Trim(new Char[] { '₱' })), Convert.ToDecimal(caTotal.Text.Trim(new Char[] { '₱' })));
            // Prevent the automatic delete operation
            //e.Cancel = true;
        }

        [WebMethod]
        public static string AddExpDetailsAJAX(
            string dateAdd, 
            string invoice_no, 
            string gross_amount, 
            string net_amount, 
            string particu, 
            string expCat, 
            string currency, 
            string qty, 
            string unit_price, 
            string itemDesc,
            string assign,
            string allowance,
            string EWTTaxType,
            string EWTTAmount,
            string EWTTCode,
            string asset,
            string subasset,
            string AltRecon,
            string SLCode,
            string SpecialGL,
            string invoiceTCode,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            return exp.AddExpDetails (
                dateAdd, 
                invoice_no, 
                gross_amount, 
                net_amount, 
                particu, 
                expCat, 
                currency, 
                qty, 
                unit_price, 
                itemDesc,
                assign,
                allowance,
                EWTTaxType,
                EWTTAmount,
                EWTTCode,
                asset,
                subasset,
                AltRecon,
                SLCode,
                SpecialGL,
                invoiceTCode,
                uom,
                ewt,
                vat,
                ewtperc,
                netvat,
                isVatCompute
                );
        }

        // Helper: clear temporary session datasets after successful persistence
        private void ClearInvoiceTempDataSets()
        {
            try
            {
                Session.Remove("DataSetInvAlloc");
                Session.Remove("DataSetInvDoc");
                dsExpAlloc = null;
                dsDoc = null;
            }
            catch { /* swallow – non‑critical */ }
        }

        public string AddExpDetails(
            string dateAdd,
            string invoice_no,
            string gross_amount,
            string net_amount,
            string particu,
            string expCat,
            string currency,
            string qty,
            string unit_price,
            string itemDesc,
            string assign,
            string allowance,
            string EWTTaxType,
            string EWTTAmount,
            string EWTTCode,
            string asset,
            string subasset,
            string AltRecon,
            string SLCode,
            string SpecialGL,
            string invoiceTCode,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            try
            {

                decimal totalNetAmnt = new decimal(0.00);
                DataSet dsAlloc = (DataSet)Session["DataSetInvAlloc"];
                DataTable dataTableAlloc = dsAlloc.Tables[0];

                foreach (DataRow row in dataTableAlloc.Rows)
                {
                    // Only summing; object creation removed (it was unused)
                    totalNetAmnt += Convert.ToDecimal(row["NetAmount"]);
                }

                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if (totalNetAmnt < gross && dataTableAlloc.Rows.Count > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + " " + currency + ". Please check the allocation amounts.";
                    return error;
                }
                else if (totalNetAmnt > gross && dataTableAlloc.Rows.Count > 0)
                {
                    string error = "Allocation Exceeded!";
                    return error;
                }
                else
                {
                    var invMain = _DataContext.ACCEDE_T_InvoiceMains
                        .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .FirstOrDefault();

                    var rfpCA = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.isTravel != true);

                    var LastExpDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .OrderByDescending(x => x.LineNum)
                        .FirstOrDefault();

                    ACCEDE_T_InvoiceLineDetail inv = new ACCEDE_T_InvoiceLineDetail();
                    {
                        inv.DateAdded = Convert.ToDateTime(dateAdd);

                        if (!string.IsNullOrEmpty(invoice_no))
                            inv.InvoiceNo = invoice_no;

                        inv.TotalAmount = Convert.ToDecimal(gross_amount);
                        inv.NetAmount = Convert.ToDecimal(net_amount);
                        inv.Particulars = Convert.ToInt32(particu);
                        if (expCat != "0")
                            inv.AcctToCharged = Convert.ToInt32(expCat);
                        inv.Qty = Convert.ToDecimal(qty);
                        inv.UnitPrice = Convert.ToDecimal(unit_price);
                        inv.InvMain_ID = Convert.ToInt32(Session["NonPOInvoiceId"]);
                        inv.Preparer_ID = Session["userID"].ToString();
                        inv.LineDescription = itemDesc;
                        inv.EWT = Convert.ToDecimal(ewt);
                        inv.VAT = Convert.ToDecimal(vat);
                        inv.UOM = uom;
                        inv.EWTPerc = Convert.ToDecimal(ewtperc);
                        inv.NOVAT = Convert.ToDecimal(netvat);
                        inv.isVatComputed = Convert.ToBoolean(isVatCompute);
                        inv.LineNum = (LastExpDetail != null ? LastExpDetail.LineNum + 1 : 1);
                    }
                    _DataContext.ACCEDE_T_InvoiceLineDetails.InsertOnSubmit(inv);
                    _DataContext.SubmitChanges();
                    var ExpDetail_ID = inv.ID;

                    // Insert allocation mappings
                    if (dataTableAlloc.Rows.Count > 0)
                    {
                        foreach (DataRow row in dataTableAlloc.Rows)
                        {
                            var map = new ACCEDE_T_InvoiceLineDetailsMap
                            {
                                CostCenterIOWBS = row["CostCenter"].ToString(),
                                NetAmount = Convert.ToDecimal(row["NetAmount"]),
                                InvoiceReportDetail_ID = ExpDetail_ID,
                                Preparer_ID = Session["userID"].ToString(),
                                EDM_Remarks = row["Remarks"].ToString()
                            };
                            _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.InsertOnSubmit(map);
                        }
                    }
                    _DataContext.SubmitChanges();

                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE InvoiceNPO")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    // Insert file attachments mapped to this line
                    DataSet dsFile = (DataSet)Session["DataSetInvDoc"];
                    DataTable dataTable = dsFile.Tables[0];

                    if (dataTable.Rows.Count > 0)
                    {
                        foreach (DataRow row in dataTable.Rows)
                        {
                            var attach = new ITP_T_FileAttachment
                            {
                                FileName = row["FileName"].ToString(),
                                FileAttachment = (byte[])row["FileByte"],
                                Description = row["FileDesc"].ToString(),
                                DateUploaded = DateTime.Now,
                                App_ID = 1032,
                                User_ID = Session["userID"] != null ? Session["userID"].ToString() : "0",
                                FileExtension = row["FileExt"].ToString(),
                                FileSize = row["FileSize"].ToString(),
                                DocType_Id = app_docType != null ? app_docType.DCT_Id : 0
                            };
                            _DataContext.ITP_T_FileAttachments.InsertOnSubmit(attach);
                            _DataContext.SubmitChanges();

                            var attachMap = new ACCEDE_T_ExpenseDetailFileAttach
                            {
                                ExpDetail_Id = ExpDetail_ID,
                                FileAttach_Id = attach.ID
                            };
                            _DataContext.ACCEDE_T_ExpenseDetailFileAttaches.InsertOnSubmit(attachMap);
                            _DataContext.SubmitChanges();
                        }
                    }

                    var rfpReim = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .Where(x => x.Status != 4)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    var expDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));

                    decimal totalExpense = 0m;
                    foreach (var expDtl in expDetails)
                        totalExpense += Convert.ToDecimal(expDtl.NetAmount);

                    if (totalExpense >= 0 && rfpReim != null)
                    {
                        rfpReim.Amount = totalExpense;
                    }

                    _DataContext.SubmitChanges();

                    // NEW: Clear session datasets after successful persistence
                    ClearInvoiceTempDataSets();
                }

                Session["InvoiceNo"] = invoice_no;

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        protected void drpdwn_FAPWF_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp_id = param[0];
            var classTypeVal = param[1];
            var mainInv = _DataContext.ACCEDE_T_InvoiceMains
                .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                .FirstOrDefault();

            //var rfpCA = _DataContext.ACCEDE_T_RFPMains
            //    .Where(x => x.Exp_ID == mainInv.ID)
            //    .Where(x => x.IsExpenseCA == true)
            //    .Where(x => x.isTravel != true);

            //var totalCA = new decimal(0.00);
            //foreach (var item in rfpCA)
            //{
            //    totalCA += Convert.ToDecimal(item.Amount);

            //}
            //if (totalCA >= 0)
            //{
            //    drpdown_expenseType.Text = "Liquidation";
            //}
            //else
            //{
            //    drpdown_expenseType.Text = "Reimbursement";
            //}

            var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                .Where(x => x.InvMain_ID == mainInv.ID);

            var totalExp = new decimal(0.00);
            foreach (var item in expDetail)
            {
                totalExp += Convert.ToDecimal(item.TotalAmount);
            }

            //var totalDue = new decimal(0.00);
            //totalDue = totalCA - totalExp;

            //// - - Setting FAP workflow - - ////
            var classTypeId = classTypeVal != "" ? classTypeVal : "0";
            var classType = _DataContext.ACCEDE_S_ExpenseClassifications
                .Where(x => x.ID == Convert.ToInt32(classTypeId))
                .FirstOrDefault();

            var fapwf_id = 0;

            var fapwf = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.Company_Id == Convert.ToInt32(comp_id))
                    .Where(x => x.App_Id == 1032)
                    .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                    .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
                    .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
                    .Where(x => x.IsRA == null || x.IsRA == false)
                    .FirstOrDefault();

            if (fapwf != null)
            {
                fapwf_id = fapwf.WF_Id;
            }

            //if (classType != null && Convert.ToBoolean(classType.withFAPLogic) == true)
            //{
            //    var fapwf = _DataContext.ITP_S_WorkflowHeaders
            //        .Where(x => x.Company_Id == Convert.ToInt32(comp_id))
            //        .Where(x => x.App_Id == 1032)
            //        .Where(x => x.With_DivHead == true)
            //        .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
            //        .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
            //        .Where(x => x.IsRA == null || x.IsRA == false)
            //        .FirstOrDefault();

            //    if (fapwf != null)
            //    {
            //        fapwf_id = fapwf.WF_Id;
            //    }
            //}
            //else
            //{
            //    var fapwf = _DataContext.ITP_S_WorkflowHeaders
            //        .Where(x => x.Company_Id == Convert.ToInt32(comp_id))
            //        .Where(x => x.App_Id == 1032)
            //        .Where(x => x.With_DivHead == false || x.With_DivHead == null)
            //        .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalExp)))
            //        .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalExp)))
            //        .Where(x => x.IsRA == null || x.IsRA == false)
            //        .FirstOrDefault();

            //    if (fapwf != null)
            //    {
            //        fapwf_id = fapwf.WF_Id;
            //    }

            //}

            if (fapwf_id != 0)
            {

                SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();
                SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = fapwf_id.ToString();
                drpdwn_FAPWF.SelectedIndex = 0;
                drpdwn_FAPWF.DataBind();

                SqlFAPWF.DataBind();
                FAPWFGrid.DataSourceID = null;
                FAPWFGrid.DataSource = SqlFAPWF;
                FAPWFGrid.DataBind();
            }
        }

        [WebMethod]
        public static bool RemoveFromExp_AJAX(int item_id, string btnCommand)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();

            return exp.RemoveFromExp(item_id, btnCommand);
        }

        public bool RemoveFromExp(int item_id, string btnCommand)
        {
            try
            {
                if (btnCommand == "btnRemoveCA")
                {
                    var CA_RFP = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == item_id)
                        .FirstOrDefault();

                    CA_RFP.Exp_ID = null;
                    var rfpReim_upd = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    if (rfpReim_upd != null)
                    {
                        rfpReim_upd.Amount = Convert.ToDecimal(rfpReim_upd.Amount) + Convert.ToDecimal(CA_RFP.Amount);
                    }
                }

                if (btnCommand == "btnRemoveExp")
                {
                    var exp_det = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.ID == item_id)
                        .FirstOrDefault();

                    if (exp_det.LineNum != null)
                    {
                        var allExp = _DataContext.ACCEDE_T_InvoiceLineDetails.Where(x => x.InvMain_ID == Convert.ToInt32(exp_det.InvMain_ID));
                        foreach (var item in allExp)
                        {
                            if (item.LineNum > exp_det.LineNum)
                            {
                                item.LineNum = item.LineNum - 1;
                            }
                        }
                    }

                    var exp_det_map = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                        .Where(x => x.InvoiceReportDetail_ID == item_id);

                    _DataContext.ACCEDE_T_InvoiceLineDetails.DeleteOnSubmit(exp_det);
                    _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.DeleteAllOnSubmit(exp_det_map);
                    _DataContext.SubmitChanges();

                    var Reim_RFP_exp = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .Where(x => x.Status != 4).Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    var updated_exp_det = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .FirstOrDefault();

                    if (updated_exp_det == null)
                    {
                        if (Reim_RFP_exp != null)
                        {
                            var Reim_RFP = _DataContext.ACCEDE_T_RFPMains
                                .Where(x => x.ID == Reim_RFP_exp.ID)
                                .FirstOrDefault();

                            //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                            Reim_RFP.Status = 4;
                        }
                    }
                    else
                    {
                        //var rfp_CA = _DataContext.ACCEDE_T_RFPMains
                        //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        //    .Where(x => x.IsExpenseCA == true)
                        //    .Where(x => x.isTravel != true);

                        //var totalCA = new decimal(0.00);
                        //foreach (var item in rfp_CA)
                        //{
                        //    totalCA += Convert.ToDecimal(item.Amount);

                        //}

                        var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                            .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));

                        var totalExp = new decimal(0.00);
                        foreach (var item in expDetail)
                        {
                            totalExp += Convert.ToDecimal(item.TotalAmount);
                        }

                        decimal totalDue = new decimal(0);
                        //totalDue = totalCA - totalExp;

                        if (totalExp >= 0)
                        {
                            if (Reim_RFP_exp != null)
                            {
                                var Reim_RFP = _DataContext.ACCEDE_T_RFPMains
                                    .Where(x => x.ID == Reim_RFP_exp.ID)
                                    .FirstOrDefault();

                                //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                                Reim_RFP.Amount = totalExp;
                            }

                        }
                        //if (Reim_RFP_exp != null)
                        //{
                        //    Reim_RFP_exp.Amount = Math.Abs(totalCA - totalExp);
                        //}
                    }
                }

                if (btnCommand == "btnRemoveReim")
                {
                    var Reim_RFP = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == item_id)
                        .FirstOrDefault();

                    //_DataContext.ACCEDE_T_RFPMains.DeleteOnSubmit(Reim_RFP);
                    Reim_RFP.Status = 4;
                }

                var expMain = _DataContext.ACCEDE_T_ExpenseMains
                    .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .FirstOrDefault();

                var rfpCA = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true);

                //if (rfpCA.Count() > 0)
                //{
                //    expMain.ExpenseType_ID = 1;
                //}
                //else
                //{
                //    expMain.ExpenseType_ID = 2;
                //}

                _DataContext.SubmitChanges();

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }


        [WebMethod]
        public static string CostCenterUpdateField(string dept_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            var cc = rfp.GetCostCenter(dept_id);
            return cc;
        }

        [WebMethod]
        public static string AddRFPPayVendorAJAX(
            string comp_id, 
            string payMethod, 
            string purpose, 
            string dept_id, 
            string cCenter,
            string payee, 
            string acctCharge, 
            //bool isTravelrfp, 
            //string wbs, 
            string currency, 
            string CTComp_id, 
            string CTDept_id, 
            string compLoc, 
            string wf, 
            string fapwf)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();

            return exp.AddRFPPayVendor(comp_id, payMethod, purpose, dept_id, cCenter,
            payee, acctCharge, currency, CTComp_id, CTDept_id, compLoc, wf, fapwf);
        }

        public string AddRFPPayVendor(string comp_id, string payMethod, string purpose, string dept_id, string cCenter,
            string payee, string acctCharge, string currency, string CTComp_id, string CTDept_id, string compLoc, string wf, string fapwf)
        {
            try
            {
                GenerateDocNo generateDocNo = new GenerateDocNo();
                generateDocNo.RunStoredProc_GenerateDocNum(1011, Convert.ToInt32(comp_id), 1032);
                var docNum = generateDocNo.GetLatest_DocNum(1011, Convert.ToInt32(comp_id), 1032);

                var invMain = _DataContext.ACCEDE_T_InvoiceMains
                    .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .FirstOrDefault();

                //var rfpCA = _DataContext.ACCEDE_T_RFPMains
                //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                //    .Where(x => x.IsExpenseCA == true)
                //    .Where(x => x.isTravel != true);

                var rfpPayVendor = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .Where(x => x.Status != 4).Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var invDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));

                //var LiqReimTranType = _DataContext.ACCEDE_S_RFPTranTypes
                //    .Where(x => x.RFPTranType_Name == "Liquidation with Reimbursement")
                //    .FirstOrDefault();

                var PayVendorTranType = _DataContext.ACCEDE_S_RFPTranTypes
                    .Where(x => x.RFPTranType_Name == "Payment To Vendor")
                    .FirstOrDefault();

                //decimal totalReim = new decimal(0);
                //decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                if (wf == "" || fapwf == "")
                {
                    return "Error in workflow details. Please check your workflow.";
                }

                //foreach (var ca in rfpCA)
                //{
                //    totalCA += Convert.ToDecimal(ca.Amount);
                //}

                foreach (var inv in invDetails)
                {
                    totalExpense += Convert.ToDecimal(inv.NetAmount);
                }

                //totalReim = totalCA - totalExpense;

                if (rfpPayVendor == null)
                {
                    ACCEDE_T_RFPMain rfp = new ACCEDE_T_RFPMain();
                    {
                        rfp.Company_ID = Convert.ToInt32(comp_id);
                        rfp.PayMethod = Convert.ToInt32(payMethod);
                        rfp.Purpose = purpose;
                        rfp.Department_ID = Convert.ToInt32(dept_id);
                        rfp.SAPCostCenter = cCenter;
                        //if (io != "")
                        //{
                        //    rfp.IO_Num = io;
                        //}
                        rfp.Payee = payee;
                        rfp.AcctCharged = Convert.ToInt32(acctCharge);
                        rfp.Amount = Convert.ToDecimal(Math.Abs(totalExpense));
                        //if (remarks != "")
                        //{
                        //    rfp.Remarks = remarks;
                        //}
                        rfp.Exp_ID = invMain.ID;
                        //if (totalCA > 0)
                        //{
                        //    rfp.TranType = LiqReimTranType.ID;
                        //}
                        //else
                        //{
                        //    rfp.TranType = ReimTranType.ID;
                        //}
                        rfp.TranType = PayVendorTranType.ID;
                        rfp.IsExpenseReim = false;
                        rfp.IsExpenseCA = false;
                        rfp.isTravel = false;//isTravelrfp;
                        rfp.DateCreated = DateTime.Now;
                        rfp.RFP_DocNum = docNum.ToString();
                        //if (wbs != "")
                        //{
                        //    rfp.WBS = wbs;
                        //}
                        rfp.User_ID = Session["userID"].ToString();
                        rfp.Currency = currency;
                        rfp.Status = invMain.Status;
                        //rfp.Classification_Type_Id = Convert.ToInt32(classification);
                        rfp.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                        rfp.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                        if (compLoc != "")
                        {
                            rfp.Comp_Location_Id = Convert.ToInt32(compLoc);
                        }
                        rfp.WF_Id = Convert.ToInt32(wf);
                        rfp.FAPWF_Id = Convert.ToInt32(fapwf);
                    }

                    _DataContext.ACCEDE_T_RFPMains.InsertOnSubmit(rfp);
                }

                //expMain.PaymentType = Convert.ToInt32(payMethod);

                _DataContext.SubmitChanges();

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        // Helper method (optional to reuse)
        int? TryParseInt(string value)
        {
            return int.TryParse(value, out var result) ? (int?)result : null;
        }

        DateTime? TryParseDate(string value)
        {
            return DateTime.TryParse(value, out var result) ? (DateTime?)result : null;
        }

        string ToNullIfEmpty(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value;
        }


        [WebMethod]
        public static string UpdateExpenseAJAX(
            string dateFile, 
            string repName, 
            string comp_id, 
            string expType, 
            string expCat,
            string purpose, 
            bool trav, 
            string wf, 
            string fapwf, 
            string currency, 
            string department, 
            string payType, 
            string btn, 
            string costCenter, 
            string CTCompany_id, 
            string CTDept_id, 
            string compLoc,
            string invoiceNum,
            string vendorCode,
            string vendorTIN,
            string vendorAddress)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            return exp.UpdateExpense(dateFile, repName, comp_id, expType, expCat, purpose, trav, wf, fapwf, currency, department, payType, btn, costCenter, CTCompany_id, CTDept_id, compLoc, invoiceNum, vendorCode, vendorTIN, vendorAddress);
        }

        public string UpdateExpense(string dateFile, string repName, string comp_id, string expType, string expCat,
            string purpose, bool trav, string wf, string fapwf, string currency, string department, string payType, string btn, string costCenter, string CTCompany_id, string CTDept_id, string compLoc, string invoiceNum, string vendorCode, string vendorTIN, string vendorAddress)
        {
            try
            {
                var inv = _DataContext.ACCEDE_T_InvoiceMains
                    .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .FirstOrDefault();

                var reim = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == inv.ID)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var expCA = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .Where(x => x.IsExpenseCA == true)
                    .Where(x => x.isTravel != true)
                    .FirstOrDefault();

                var expDet = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == inv.ID);

                //if (expType == "1")
                //{
                //    if (expCA == null && btn != "Save" && btn != "Save2")
                //    {
                //        return "require CA";
                //    }
                //}
                //else
                //{
                //    if (expCA != null)
                //    {
                //        return "This transaction should be a Liquidation since you attached a Cash Advance.";
                //    }
                //}

                //if (expCA == null && reim == null && btn != "Save" && btn != "Save2" && btn != "CreateSubmit" && expType != "3")
                //{
                //    return "This transaction cannot be submitted. Please check your Cash Advance, Expense Items, or Reimbursement.";
                //}

                //if (expCA != null && expDet.Count() == 0 && (btn == "Submit" || btn == "CreateSubmit"))
                //{
                //    return "You are trying to submit expense report without expense items. Please check your expense items.";
                //}

                //var tranType = _DataContext.ACCEDE_S_ExpenseTypes
                //    .Where(x => x.ExpenseType_ID == Convert.ToInt32(expType))
                //    .FirstOrDefault();

                // Assignment
                inv.ReportDate = TryParseDate(dateFile); // null if invalid or empty
                inv.VendorName = ToNullIfEmpty(repName);

                inv.CompanyId = TryParseInt(comp_id);

                //inv.InvoiceType_ID = 1; // invoice non-po id
                inv.ExpenseCat = TryParseInt(expCat);
                inv.Purpose = ToNullIfEmpty(purpose);
                //inv.isTravel = trav;

                inv.WF_Id = TryParseInt(wf);
                inv.FAPWF_Id = TryParseInt(fapwf);
                // exp.remarks = remarks;

                inv.Exp_Currency = ToNullIfEmpty(currency);
                inv.Dept_Id = TryParseInt(department);
                inv.CostCenter = ToNullIfEmpty(costCenter);

                inv.InvChargedTo_CompanyId = TryParseInt(CTCompany_id);
                inv.InvChargedTo_DeptId = TryParseInt(CTDept_id);
                inv.PaymentType = TryParseInt(payType);
                inv.InvComp_Location_Id = TryParseInt(compLoc);
                inv.PaymentType = TryParseInt(payType);
                inv.InvoiceNo = ToNullIfEmpty(invoiceNum);
                inv.VendorCode = ToNullIfEmpty(vendorCode);
                inv.VendorTIN = ToNullIfEmpty(vendorTIN);
                inv.VendorAddress = ToNullIfEmpty(vendorAddress);

                //if (compLoc != "")
                //{
                //    exp.ExpComp_Location_Id = Convert.ToInt32(compLoc);
                //}

                //if(payType != null)
                //{
                //    exp.PaymentType = Convert.ToInt32(payType);
                //}

                //if(AR != "")
                //{
                //    exp.AR_Reference_No = AR;
                //}

                //Update reimbursement Workflows

                if (reim != null)
                {
                    reim.Payee = vendorCode;
                    reim.WF_Id = Convert.ToInt32(wf);
                    reim.FAPWF_Id = Convert.ToInt32(fapwf);
                    reim.Status = 13;
                    reim.Currency = currency;
                }

                if (btn == "Submit" || btn == "CreateSubmit")
                {
                    var returnAuditStats = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by Audit")
                        .FirstOrDefault();

                    var returnP2PStats = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by P2P")
                        .FirstOrDefault();

                    var rfpDocType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment")
                        .Select(x => x.DCT_Id)
                        .FirstOrDefault();

                    if (inv.Status == returnAuditStats.STS_Id)
                    {
                        var pendingAuditStats = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Name == "Pending at Audit")
                            .FirstOrDefault();

                        inv.Status = pendingAuditStats.STS_Id;
                        if (reim != null)
                        {
                            reim.Status = pendingAuditStats.STS_Id;
                        }

                        var wfID_audit = _DataContext.ITP_S_WorkflowHeaders
                                .Where(x => x.Company_Id == inv.CompanyId)
                                .Where(x => x.Name == "ACDE AUDIT")
                                .FirstOrDefault();

                        if (wfID_audit != null)
                        {
                            var expDocType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE Expense" || x.DCT_Description == "Accede Expense")
                                .Select(x => x.DCT_Id)
                                .FirstOrDefault();

                            // GET WORKFLOW DETAILS ID
                            var wfDetails_audit = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                  where wfd.WF_Id == wfID_audit.WF_Id && wfd.Sequence == 1
                                                  select wfd.WFD_Id;
                            int wfdID_audit = wfDetails_audit.FirstOrDefault();

                            // GET ORG ROLE ID
                            var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                          where or.WF_Id == wfID_audit.WF_Id && or.Sequence == 1
                                          select or.OrgRole_Id;
                            int orID = (int)orgRole.FirstOrDefault();

                            if (pendingAuditStats != null && wfDetails_audit != null && orgRole != null)
                            {
                                //INSERT Reim ACTIVITY TO ITP_T_WorkflowActivity
                                DateTime currentDate = DateTime.Now;
                                ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                                {
                                    Status = pendingAuditStats.STS_Id,
                                    DateAssigned = currentDate,
                                    DateCreated = currentDate,
                                    WF_Id = wfID_audit.WF_Id,
                                    WFD_Id = wfdID_audit,
                                    OrgRole_Id = orID,
                                    Document_Id = inv.ID,
                                    AppId = 1032,
                                    ActedBy_User_Id = Session["userID"].ToString(),
                                    CompanyId = Convert.ToInt32(CTCompany_id),
                                    AppDocTypeId = rfpDocType,
                                    IsActive = true
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);


                                //INSERT EXPENSE ACTIVITY TO ITP_T_WorkflowActivity
                                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                {
                                    Status = pendingAuditStats.STS_Id,
                                    DateAssigned = currentDate,
                                    DateCreated = currentDate,
                                    WF_Id = wfID_audit.WF_Id,
                                    WFD_Id = wfdID_audit,
                                    OrgRole_Id = orID,
                                    Document_Id = inv.ID,
                                    AppId = 1032,
                                    ActedBy_User_Id = Session["userID"].ToString(),
                                    CompanyId = Convert.ToInt32(CTCompany_id),
                                    AppDocTypeId = expDocType,
                                    IsActive = true
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                            }

                            _DataContext.SubmitChanges();
                        }
                        else
                        {
                            return "There is no workflow (ACDE AUDIT) setup for your company. Please contact Admin to setup the workflow.";
                        }

                    }
                    else if (inv.Status == returnP2PStats.STS_Id)
                    {
                        var pendingP2PStats = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Name == "Pending at P2P")
                            .FirstOrDefault();

                        inv.Status = pendingP2PStats.STS_Id;
                        if (reim != null)
                        {
                            reim.Status = pendingP2PStats.STS_Id;
                        }

                        var wfID_p2p = _DataContext.ITP_S_WorkflowHeaders
                                .Where(x => x.Company_Id == inv.CompanyId)
                                .Where(x => x.Name == "ACDE P2P")
                                .FirstOrDefault();

                        if (wfID_p2p != null)
                        {
                            var expDocType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE InvoiceNPO" || x.DCT_Description == "Accede Invoice Non-PO")
                                .Select(x => x.DCT_Id)
                                .FirstOrDefault();

                            // GET WORKFLOW DETAILS ID
                            var wfDetails_p2p = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                where wfd.WF_Id == wfID_p2p.WF_Id && wfd.Sequence == 1
                                                select wfd.WFD_Id;
                            int wfdID_p2p = wfDetails_p2p.FirstOrDefault();

                            // GET ORG ROLE ID
                            var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                          where or.WF_Id == wfID_p2p.WF_Id && or.Sequence == 1
                                          select or.OrgRole_Id;
                            int orID = (int)orgRole.FirstOrDefault();

                            if (pendingP2PStats != null && wfDetails_p2p != null && orgRole != null)
                            {
                                DateTime currentDate = DateTime.Now;
                                if (reim != null)
                                {
                                    //INSERT Reim ACTIVITY TO ITP_T_WorkflowActivity
                                    ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                                    {
                                        Status = pendingP2PStats.STS_Id,
                                        DateAssigned = currentDate,
                                        DateCreated = currentDate,
                                        WF_Id = wfID_p2p.WF_Id,
                                        WFD_Id = wfdID_p2p,
                                        OrgRole_Id = orID,
                                        Document_Id = reim.ID,
                                        AppId = 1032,
                                        ActedBy_User_Id = Session["userID"].ToString(),
                                        CompanyId = Convert.ToInt32(CTCompany_id),
                                        AppDocTypeId = rfpDocType,
                                        IsActive = true
                                    };
                                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);
                                }

                                //INSERT EXPENSE ACTIVITY TO ITP_T_WorkflowActivity
                                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                {
                                    Status = pendingP2PStats.STS_Id,
                                    DateAssigned = currentDate,
                                    DateCreated = currentDate,
                                    WF_Id = wfID_p2p.WF_Id,
                                    WFD_Id = wfdID_p2p,
                                    OrgRole_Id = orID,
                                    Document_Id = inv.ID,
                                    AppId = 1032,
                                    ActedBy_User_Id = Session["userID"].ToString(),
                                    CompanyId = Convert.ToInt32(CTCompany_id),
                                    AppDocTypeId = expDocType,
                                    IsActive = true
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                            }

                            _DataContext.SubmitChanges();
                        }
                        else
                        {
                            return "There is no workflow (ACDE P2P) setup for your company. Please contact Admin to setup the workflow.";
                        }

                    }
                    else
                    {
                        int wfID = Convert.ToInt32(wf);

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

                        //IF DOCUMENT WAS RECALLED
                        //if (exp.Status == 15)//15 IS A RECALL STATUS
                        //{
                        //    var expDoctype = _DataContext.ITP_S_DocumentTypes
                        //        .Where(x => x.DCT_Name == "ACDE Expense")
                        //        .FirstOrDefault();

                        //    var wfAct = _DataContext.ITP_T_WorkflowActivities
                        //        .Where(x => x.Document_Id == exp.ID)
                        //        .Where(x => x.AppId == 1032)
                        //        .Where(x => x.AppDocTypeId == expDoctype.DCT_Id)
                        //        .Where(x => x.Status == 15)//15 IS A RECALL STATUS
                        //        .FirstOrDefault();

                        //    var wfDetail = _DataContext.ITP_S_WorkflowDetails
                        //        .Where(x => x.WFD_Id == wfAct.WFD_Id)
                        //        .FirstOrDefault();

                        //    wfID = Convert.ToInt32(wfDetail.WF_Id);

                        //    // GET WORKFLOW DETAILS ID
                        //    wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                        //                where wfd.WF_Id == wfID && wfd.Sequence == Convert.ToInt32(wfDetail.Sequence)
                        //                select wfd.WFD_Id;

                        //    wfdID = wfDetails.FirstOrDefault();

                        //    // GET ORG ROLE ID
                        //    orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                        //              where or.WF_Id == wfID && or.Sequence == Convert.ToInt32(wfDetail.Sequence)
                        //              select or.OrgRole_Id;

                        //    orID = (int)orgRole.FirstOrDefault();
                        //}
                        //END RECALL PROCESS

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
                                CompanyId = Convert.ToInt32(CTCompany_id),
                                AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment").Select(x => x.DCT_Id).FirstOrDefault(),
                                IsActive = true,
                            };
                            _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa_reim);

                        }

                        //change expense rep status to pending
                        inv.Status = 1;

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
                            Document_Id = Convert.ToInt32(Session["NonPOInvoiceId"]),
                            AppId = 1032,
                            CompanyId = Convert.ToInt32(CTCompany_id),
                            AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE InvoiceNPO" || x.DCT_Description == "Accede Invoice Non-PO").Select(x => x.DCT_Id).FirstOrDefault(),
                            IsActive = true,
                        };
                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                        _DataContext.SubmitChanges();

                        //InsertAttachment(Convert.ToInt32(Session["NonPOInvoiceId"]));
                        SendEmail(Convert.ToInt32(wfa.Document_Id), orID, Convert.ToInt32(comp_id), 1);
                    }

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
        public static decimal CheckMinAmountAJAX(int comp_id, int payMethod)
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.CheckMinAmount(comp_id, payMethod);
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

            var doc_main = _DataContext.ACCEDE_T_InvoiceMains.Where(x => x.ID == Convert.ToInt32(doc_id)).FirstOrDefault();

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

            var expMain = _DataContext.ACCEDE_T_InvoiceMains.Where(x => x.ID == doc_id).FirstOrDefault();

            //var requestor_fullname = _DataContext.ITP_S_UserMasters
            //    .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
            //    .Select(um => um.FullName)
            //    .FirstOrDefault();

            var requestor_fullname = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(expMain.UserId))
                .Select(um => um.FullName)
                .FirstOrDefault();

            //var requestor_email = _DataContext.ITP_S_UserMasters
            //    .Where(um => um.EmpCode == Convert.ToString(Session["prep"]))
            //    .Select(um => um.Email)
            //    .FirstOrDefault();

            var requestor_email = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(expMain.UserId))
                .Select(um => um.Email)
                .FirstOrDefault();

            string appName = "ACCEDE INVOICE NON-PO";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://apps.anflocor.com/AccedeApprovalPage.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + doc_id + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_InvoiceLineDetails
                          where er.InvMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_main.DocNo + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Particulars</th><th>Quantity</th><th>Unit Price</th><th>Total</th><th>Date Created</th></tr>";

            foreach (var item in queryER)
            {
                //var exp = _DataContext.ACCEDE_T_InvoiceMains
                //    .Where(x => x.ID == doc_id)
                //    .Select(x => x.ExpenseType_ID)
                //    .FirstOrDefault();

                var expType = "Invoice Non-PO";

                var particulars = _DataContext.ACCEDE_S_Particulars.Where(x => x.ID == Convert.ToInt32(item.Particulars)).FirstOrDefault();

                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + particulars.P_Name + "</td>" +
                            "<td style='text-align: center;'>" + item.Qty + "</td>" +
                            "<td style='text-align: center;'>" + item.UnitPrice + "</td>" +
                            "<td style='text-align: center;'>" + item.TotalAmount + "</td>" +
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
            }
            ;
        }

        protected void ExpAllocGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            decimal totalNetAmount = 0;

            ASPxGridView grid = (ASPxGridView)sender;

            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");
                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            totalNetAmount = Convert.ToDecimal(e.NewValues["NetAmount"]) + totalNetAmount;

            if (totalNetAmount > Convert.ToDecimal(total_add.Value))
            {
                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;

                e.Cancel = true;
            }
            else
            {
                dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
                ASPxGridView gridView = (ASPxGridView)sender;
                DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsExpAlloc.Tables[1] : dsExpAlloc.Tables[0];
                DataRow row = dataTable.NewRow();
                e.NewValues["ID"] = GetNewId();

                IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
                enumerator.Reset();
                while (enumerator.MoveNext())
                    if (enumerator.Key.ToString() != "Count")
                        row[enumerator.Key.ToString()] = enumerator?.Value;

                gridView.CancelEdit();
                e.Cancel = true;


                dataTable.Rows.Add(row);

                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
            }

        }

        protected void ExpAllocGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            // Get the index of the deleted row
            int deletedRowIndex = Convert.ToInt32(e.Keys[ExpAllocGrid.KeyFieldName].ToString());

            //Delete row
            e.Cancel = true;
            dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
            dsExpAlloc.Tables[0].Rows.Remove(dsExpAlloc.Tables[0].Rows.Find(e.Keys[ExpAllocGrid.KeyFieldName]));

            decimal totalNetAmount = 0;
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            //{
            //    ExpAllocGrid.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}

            ASPxGridView grid = (ASPxGridView)sender;
            grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
        }

        protected void ExpAllocGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            ASPxGridView grid = (ASPxGridView)sender;
            decimal totalNetAmount = 0;
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }

            if (totalNetAmount > Convert.ToDecimal(total_add.Value))
            {
                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;
                grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
            }
            else
            {
                grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
            }

        }

        //Display Expense detail data to modal
        [WebMethod]
        public static InvDetailsNonPO DisplayExpDetailsAJAX(int expDetailID)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            return exp.DisplayExpDetails(expDetailID);
        }

        public InvDetailsNonPO DisplayExpDetails(int invDetailID)
        {
            var inv_details = _DataContext.ACCEDE_T_InvoiceLineDetails
                .Where(x => x.ID == invDetailID)
                .FirstOrDefault();

            var exp_detailsMap = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.Where(x => x.InvoiceReportDetail_ID == invDetailID);
            decimal totalAmnt = 0;

            foreach (var item in exp_detailsMap)
            {
                totalAmnt += Convert.ToDecimal(item.NetAmount);
            }

            totalAmnt = Convert.ToDecimal(inv_details.TotalAmount) - totalAmnt;

            InvDetailsNonPO inv_det_class = new InvDetailsNonPO();

            if (inv_details != null)
            {
                inv_det_class.id = inv_details.ID;
                inv_det_class.dateAdded = Convert.ToDateTime(inv_details.DateAdded).ToString("MM/dd/yyyy hh:mm:ss");

                //exp_det_class.supplier = inv_details.Supplier ?? exp_det_class.supplier;
                inv_det_class.particulars = inv_details.Particulars?.ToString() ?? inv_det_class.particulars;
                inv_det_class.acctCharge = inv_details.AcctToCharged ?? inv_det_class.acctCharge;
                //exp_det_class.tin = inv_details.TIN ?? exp_det_class.tin;
                inv_det_class.InvoiceOR = inv_details.InvoiceNo ?? inv_det_class.InvoiceOR;
                //exp_det_class.costCenter = inv_details.CostCenterIOWBS ?? exp_det_class.costCenter;
                inv_det_class.grossAmnt = inv_details.TotalAmount != null ? Convert.ToDecimal(inv_details.TotalAmount) : inv_det_class.grossAmnt;
                //exp_det_class.vat = inv_details.VAT != null ? Convert.ToDecimal(inv_details.VAT) : exp_det_class.vat;
                //exp_det_class.ewt = inv_details.EWT != null ? Convert.ToDecimal(inv_details.EWT) : exp_det_class.ewt;
                inv_det_class.netAmnt = inv_details.NetAmount != null ? Convert.ToDecimal(inv_details.NetAmount) : inv_det_class.netAmnt;
                inv_det_class.expMainId = inv_details.InvMain_ID != null ? Convert.ToInt32(inv_details.InvMain_ID) : inv_det_class.expMainId;
                inv_det_class.preparerId = inv_details.Preparer_ID ?? inv_det_class.preparerId;
                //exp_det_class.io = inv_details.ExpDtl_IO ?? exp_det_class.io;
                inv_det_class.LineDesc = inv_details.LineDescription ?? inv_det_class.LineDesc;
                //exp_det_class.wbs = inv_details.ExpDtl_WBS ?? exp_det_class.wbs;

                //var exp_details_nonpo = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(exp_details.ExpenseReportDetail_ID)).FirstOrDefault();
                //exp_det_class.Assignment = exp_details_nonpo.Assignment ?? exp_det_class.Assignment;
                //exp_det_class.UserId = exp_details_nonpo.UserId ?? exp_det_class.UserId;
                //exp_det_class.Allowance = exp_details_nonpo.Allowance ?? exp_det_class.Allowance;
                //exp_det_class.SLCode = exp_details_nonpo.SLCode ?? exp_det_class.SLCode;
                //exp_det_class.EWTTaxType_Id = exp_details_nonpo.EWTTaxType_Id != null ? Convert.ToInt32(exp_details_nonpo.EWTTaxType_Id) : exp_det_class.EWTTaxType_Id;
                //exp_det_class.EWTTaxAmount = exp_details_nonpo.EWTTaxAmount != null ? Convert.ToDecimal(exp_details_nonpo.EWTTaxAmount) : exp_det_class.EWTTaxAmount;
                //exp_det_class.EWTTaxCode = exp_details_nonpo.EWTTaxCode ?? exp_det_class.EWTTaxCode;
                //exp_det_class.InvoiceTaxCode = exp_details_nonpo.InvoiceTaxCode ?? exp_det_class.InvoiceTaxCode;
                //exp_det_class.Asset = exp_details_nonpo.Asset ?? exp_det_class.Asset;
                //exp_det_class.SubAssetCode = exp_details_nonpo.SubAssetCode ?? exp_det_class.SubAssetCode;
                //exp_det_class.TransactionType = exp_details_nonpo.TransactionType ?? exp_det_class.TransactionType;
                //exp_det_class.AltRecon = exp_details_nonpo.AltRecon ?? exp_det_class.AltRecon;
                //exp_det_class.SpecialGL = exp_details_nonpo.SpecialGL ?? exp_det_class.SpecialGL;
                inv_det_class.Qty = inv_details.Qty ?? inv_det_class.Qty;
                inv_det_class.UnitPrice = inv_details.UnitPrice ?? inv_det_class.UnitPrice;
                inv_det_class.ewt = inv_details.EWT ?? inv_det_class.ewt;
                inv_det_class.vat = inv_details.VAT ?? inv_det_class.vat;
                inv_det_class.uom = inv_details.UOM ?? inv_det_class.uom;
                inv_det_class.totalAllocAmnt = totalAmnt;
                inv_det_class.ewtperc = inv_details.EWTPerc ?? inv_det_class.ewtperc;
                inv_det_class.netvat = inv_details.NOVAT ?? inv_det_class.netvat;
                inv_det_class.isVatCompute = inv_details.isVatComputed ?? inv_det_class.isVatCompute;

                Session["InvDetailsID"] = invDetailID.ToString();

            }

            return inv_det_class;
        }


        protected void ExpAllocGrid_edit_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            var newAmnt = e.NewValues["NetAmount"].ToString();
            string ID_ObjID = "";
            decimal totalAmnt = new decimal(0.00);

            ASPxGridView grid = (ASPxGridView)sender;

            for (int i = 0; i < grid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = grid.GetRowValues(i, "NetAmount");
                object ID_Obj = grid.GetRowValues(i, "InvoiceDetailMap_ID");
                ID_ObjID = grid.GetRowValues(i, "InvoiceReportDetail_ID").ToString();

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    
                    totalAmnt += netAmount;
                }
            }

            //foreach (var item in expAllocs)
            //{
            //    totalAmnt += Convert.ToDecimal(item.NetAmount);
            //}

            totalAmnt = totalAmnt + Convert.ToDecimal(e.NewValues["NetAmount"]);
            if (totalAmnt > Convert.ToDecimal(total_edit.Value))
            {
                grid.Styles.Footer.ForeColor = System.Drawing.Color.Red;

                // Set a custom JS property to pass the alert message to the client side
                grid.JSProperties["cpAllocationExceeded"] = true;

                e.Cancel = true;

            }
            else
            {
                e.NewValues["InvoiceReportDetail_ID"] = Convert.ToInt32(Session["InvDetailsID"]);
                e.NewValues["Preparer_ID"] = Convert.ToInt32(Session["userID"]);

                grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;
            }

            SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = Session["InvDetailsID"].ToString();
            SqlInvMap.DataBind();

            grid.DataSourceID = null;
            grid.DataSource = SqlInvMap;
            grid.DataBind();
        }

        protected void ExpAllocGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {

            //decimal totalAmnt = new decimal(0.00);
            int deletedRowIndex = Convert.ToInt32(e.Keys[ExpAllocGrid_edit.KeyFieldName].ToString());
            var expAllocs = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(x => x.InvoiceDetailMap_ID == Convert.ToInt32(deletedRowIndex))
                .FirstOrDefault();
            //ASPxGridView grid = (ASPxGridView)sender;
            //foreach (var item in expAllocs)
            //{
            //    totalAmnt += Convert.ToDecimal(item.NetAmount);
            //}
            //grid.JSProperties["cpComputeUnalloc_edit"] = totalAmnt;

            decimal totalNetAmount = 0;
            decimal finalTotalAmnt = 0;
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            //{
            //    ExpAllocGrid.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}

            finalTotalAmnt = totalNetAmount - Convert.ToDecimal(expAllocs.NetAmount);
            ASPxGridView grid = (ASPxGridView)sender;
            SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = Session["InvDetailsID"].ToString();
            SqlInvMap.DataBind();

            grid.DataSourceID = null;
            grid.DataSource = SqlInvMap;
            grid.DataBind();
            grid.JSProperties["cpComputeUnalloc_edit"] = finalTotalAmnt;
        }

        [WebMethod]
        public static string SaveExpDetailsAJAX(
            string dateAdd, 
            //string tin_no, 
            string invoice_no, 
            //string cost_center,
            string gross_amount, 
            string net_amount, 
            //string supp, 
            string particu, 
            string acctCharge, 
            //string vat_amnt, 
            //string ewt_amnt, 
            string currency, 
            //string io, 
            //string wbs,
            string remarks,
            string EWTTAmount,
            string assign,
            string allowance,
            string EWTTType,
            string EWTTCode,
            string InvTCode,
            string qty,
            string unit_price,
            string asset,
            string subasset,
            string altRecon,
            string SLCode,
            string SpecialGL,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            return exp.SaveExpDetails(
                dateAdd, 
                //tin_no, 
                invoice_no, 
                //cost_center,
                gross_amount, 
                net_amount, 
                //supp, 
                particu, 
                acctCharge, 
                //vat_amnt, 
                //ewt_amnt, 
                currency, 
               // io, 
               // wbs, 
                remarks,
                EWTTAmount,
                assign,
                allowance,
                EWTTType,
                EWTTCode,
                InvTCode,
                qty,
                unit_price,
                asset,
                subasset,
                altRecon,
                SLCode,
                SpecialGL,
                uom,
                ewt,
                vat,
                ewtperc,
                netvat,
                isVatCompute);
        }

        public string SaveExpDetails(
            string dateAdd,
            //string tin_no, 
            string invoice_no,
            //string cost_center,
            string gross_amount,
            string net_amount,
            //string supp, 
            string particu,
            string acctCharge,
            //string vat_amnt, 
            //string ewt_amnt, 
            string currency,
            //string io, 
            //string wbs,
            string remarks,
            string EWTTAmount,
            string assign,
            string allowance,
            string EWTTType,
            string EWTTCode,
            string InvTCode,
            string qty,
            string unit_price,
            string asset,
            string subasset,
            string altRecon,
            string SLCode,
            string SpecialGL,
            string uom,
            string ewt,
            string vat,
            string ewtperc,
            string netvat,
            string isVatCompute
            )
        {
            try
            {
                decimal totalNetAmnt = new decimal(0.00);
                var invDtlMap = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Where(x => x.InvoiceReportDetail_ID == Convert.ToInt32(Session["InvDetailsID"]));

                foreach (var item in invDtlMap)
                {
                    totalNetAmnt += Convert.ToDecimal(item.NetAmount);
                }

                decimal gross = Convert.ToDecimal(Convert.ToString(gross_amount));
                if (totalNetAmnt < gross && invDtlMap.Count() > 0)
                {
                    string error = "The total allocation amount is less than the gross amount of " + gross.ToString("#,#00.00") + ". Please check the allocation amounts.";
                    return error;
                }
                else
                {
                    var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.ID == Convert.ToInt32(Session["InvDetailsID"]))
                        .FirstOrDefault();

                    if (expDetail != null)
                    {
                        expDetail.DateAdded = Convert.ToDateTime(dateAdd);
                        //expDetail.TIN = string.IsNullOrEmpty(tin_no) ? (string)null : tin_no;
                        expDetail.InvoiceNo = string.IsNullOrEmpty(invoice_no) ? (string)null : invoice_no;
                        //expDetail.CostCenterIOWBS = cost_center;
                        expDetail.TotalAmount = Convert.ToDecimal(gross_amount);
                        expDetail.NetAmount = Convert.ToDecimal(net_amount);
                        //expDetail.Supplier = string.IsNullOrEmpty(supp) ? (string)null : supp;
                        expDetail.Particulars = Convert.ToInt32(particu);
                        //expDetail.AcctToCharged = Convert.ToInt32(acctCharge);
                        //expDetail.VAT = Convert.ToDecimal(vat_amnt);
                        //expDetail.EWT = Convert.ToDecimal(ewt_amnt);
                        //expDetail.ExpDtl_Currency = currency;
                        //expDetail.ExpDtl_IO = string.IsNullOrEmpty(io) ? (string)null : io;
                        //expDetail.ExpDtl_WBS = string.IsNullOrEmpty(wbs) ? (string)null : wbs;
                        expDetail.LineDescription = remarks;
                        expDetail.Qty = Convert.ToDecimal(qty);
                        expDetail.UnitPrice = Convert.ToDecimal(unit_price);
                        expDetail.EWT = Convert.ToDecimal(ewt);
                        expDetail.VAT = Convert.ToDecimal(vat);
                        expDetail.UOM = uom;
                        expDetail.EWTPerc = Convert.ToDecimal(ewtperc);
                        expDetail.NOVAT = Convert.ToDecimal(netvat);
                        expDetail.isVatComputed = Convert.ToBoolean(isVatCompute);
                    }

                    //var expDetailNonPO = _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.Where(x => x.ExpDetailMain_ID == Convert.ToInt32(Session["ExpDetailsID"])).FirstOrDefault();
                    //if(expDetailNonPO != null)
                    //{
                    //    expDetailNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
                    //    expDetailNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
                    //    expDetailNonPO.EWTTaxCode = EWTTCode;
                    //    expDetailNonPO.InvoiceTaxCode = InvTCode;
                    //    expDetailNonPO.Asset = asset;
                    //    expDetailNonPO.SubAssetCode = subasset;
                    //    expDetailNonPO.AltRecon = altRecon;
                    //    expDetailNonPO.SLCode = SLCode;
                    //    expDetailNonPO.SpecialGL = SpecialGL;
                    //}
                    //else
                    //{
                    //    ACCEDE_T_ExpenseDetailsInvNonPO expNonPO = new ACCEDE_T_ExpenseDetailsInvNonPO();
                    //    {
                    //        expNonPO.EWTTaxAmount = Convert.ToDecimal(EWTTAmount);
                    //        expNonPO.EWTTaxType_Id = Convert.ToInt32(EWTTType);
                    //        expNonPO.EWTTaxCode = EWTTCode;
                    //        expNonPO.InvoiceTaxCode = InvTCode;
                    //        expNonPO.Asset = asset;
                    //        expNonPO.SubAssetCode = subasset;
                    //        expNonPO.AltRecon = altRecon;
                    //        expNonPO.SLCode = SLCode;
                    //        expNonPO.SpecialGL = SpecialGL;
                    //    }

                    //    _DataContext.ACCEDE_T_ExpenseDetailsInvNonPOs.InsertOnSubmit(expNonPO);

                    //}


                }

                _DataContext.SubmitChanges();

                var ptvRFP = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .Where(x => x.isTravel != true)
                    .Where(x => x.Status != 4)
                    .Where(x => x.IsExpenseReim != true)
                    .Where(x => x.IsExpenseCA != true)
                    .FirstOrDefault();

                //var rfpReim = _DataContext.ACCEDE_T_RFPMains
                //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                //    .Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true)
                //    .Where(x => x.isTravel != true)
                //    .FirstOrDefault();

                var expDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));

                //decimal totalReim = new decimal(0);
                //decimal totalCA = new decimal(0);
                decimal totalExpense = new decimal(0);

                //foreach (var ca in rfpCA)
                //{
                //    totalCA += Convert.ToDecimal(ca.Amount);
                //}

                foreach (var exp in expDetails)
                {
                    totalExpense += Convert.ToDecimal(exp.NetAmount);
                }

                if(totalExpense > 0 && ptvRFP!=null)
                {
                    ptvRFP.Amount = totalExpense;
                }
                else
                {
                    if (ptvRFP != null)
                    {
                        ptvRFP.Amount = totalExpense;
                        ptvRFP.Status = 4;
                    }
                    
                }


                //totalReim = totalCA - totalExpense;
                //if (totalReim < 0)
                //{
                //    if (rfpReim != null)
                //    {
                //        rfpReim.Amount = Math.Abs(totalReim);
                //    }
                //}
                //else
                //{
                //    if (rfpReim != null)
                //    {
                //        rfpReim.Status = 4;
                //    }

                //}

                _DataContext.SubmitChanges();
                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        protected void ExpAllocGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            decimal totalNetAmount = 0;
            var id = e.Parameters.ToString();
            SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = id;
            SqlInvMap.DataBind();

            ExpAllocGrid_edit.DataSourceID = null;
            ExpAllocGrid_edit.DataSource = SqlInvMap;
            ExpAllocGrid_edit.DataBind();

            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount_edit.Value))
            //{
            //    ExpAllocGrid_edit.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}
            ASPxGridView grid = (ASPxGridView)sender;

            grid.JSProperties["cpComputeUnalloc_edit"] = totalNetAmount;
        }

        [WebMethod]
        public static bool UpdateCurrencyAJAX(string currency)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();

            return exp.UpdateCurrency(currency);
        }

        public bool UpdateCurrency(string currency)
        {
            try
            {
                var mainInv = _DataContext.ACCEDE_T_InvoiceMains
                    .Where(x => x.ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                    .FirstOrDefault();

                if (mainInv != null)
                {
                    mainInv.Exp_Currency = currency;

                    var invDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                        .Where(x => x.InvMain_ID == mainInv.ID);

                    //foreach (var inv in invDetails)
                    //{
                    //    inv.ExpDtl_Currency = currency;

                    //}

                    _DataContext.SubmitChanges();
                }

                return true;
            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            return exp.RedirectToRFPDetails(rfpDoc);
        }

        public bool RedirectToRFPDetails(string rfpDoc)
        {
            try
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.RFP_DocNum == rfpDoc)
                    .FirstOrDefault();

                if (rfp != null)
                {
                    Session["passRFPID"] = rfp.ID;
                }
                return true;
            }
            catch (Exception ex) { return false; }
        }

        [WebMethod]
        public static bool CheckReimburseValidationAJAX(string t_amount)
        {
            AccedeNonPOEditPage ex = new AccedeNonPOEditPage();
            return ex.CheckReimburseValidation(t_amount);
        }

        public bool CheckReimburseValidation(string t_amount)
        {
            try
            {
                //var rfp_CA = _DataContext.ACCEDE_T_RFPMains
                //    .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                //    .Where(x => x.isTravel != true)
                //    .Where(x => x.IsExpenseCA == true);

                //var totalCA = new decimal(0.00);
                //foreach (var item in rfp_CA)
                //{
                //    totalCA += Convert.ToDecimal(item.Amount);

                //}

                var expDetail = _DataContext.ACCEDE_T_InvoiceLineDetails
                    .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));

                var totalExp = new decimal(0.00);
                foreach (var item in expDetail)
                {
                    totalExp += Convert.ToDecimal(item.TotalAmount);
                }

                //decimal totalDue = new decimal(0);
                //totalDue = totalCA - totalExp;

                //if (totalExp > Convert.ToDecimal(t_amount))
                //{

                //}
                var rfpReim = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["NonPOInvoiceId"]))
                        .Where(x => x.Status != 4)
                        .Where(x => x.isTravel != true)
                        .Where(x => x.IsExpenseReim != true)
                        .Where(x => x.IsExpenseCA != true);

                if (rfpReim.Count() > 0)
                {
                    return false;
                }
                else
                {
                    return true;
                }

            }
            catch (Exception ex) { return false; }
        }

        
        protected void exp_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();

            sqlDept.SelectParameters["CompanyId"].DefaultValue = comp_id.ToString();

            exp_Department.DataSourceID = null;
            exp_Department.DataSource = sqlDept;
            exp_Department.DataBind();

        }

        protected void UploadControllerExpD_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            // Create a new data table if it doesn't exist in the data set
            DataSet ImgDS = (DataSet)Session["DataSetInvDoc"];
            foreach (var file in UploadControllerExpD.UploadedFiles)
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

                // Add a new row to the data table with the uploaded file data
                DataRow row = ImgDS.Tables[0].NewRow();
                row["ID"] = GetDocNewId();
                row["FileName"] = file.FileName;
                row["FileByte"] = file.FileBytes;
                row["FileExt"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["FileDesc"] = file.FileName.Split('.').First();
                ImgDS.Tables[0].Rows.Add(row);


            }

            // Bind the data set to the grid view
            DocuGrid.DataSource = ImgDS.Tables[0];

            DocuGrid.DataBind();
        }

        protected void DocuGrid_RowDeleting1(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            int i = DocuGrid.FindVisibleIndexByKeyValue(e.Keys[DocuGrid.KeyFieldName]);
            //Control c = DocuGrid.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            dsDoc = (DataSet)Session["DataSetInvDoc"];
            dsDoc.Tables[0].Rows.Remove(dsDoc.Tables[0].Rows.Find(e.Keys[DocuGrid.KeyFieldName]));
        }

        protected void DocuGrid_RowUpdating1(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            dsDoc = (DataSet)Session["DataSetInvDoc"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsDoc.Tables[1] : dsDoc.Tables[0];
            DataRow row = dataTable.Rows.Find(e.Keys[0]);
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                row[enumerator.Key.ToString()] = enumerator.Value;
            gridView.CancelEdit();
            e.Cancel = true;
        }

        protected void UploadControllerExpD_edit_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            foreach (var file in UploadControllerExpD_edit.UploadedFiles)
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

                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE InvoiceNPO")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                }
                ;
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                _DataContext.SubmitChanges();

                ACCEDE_T_InvoiceLineDetailFileAttach docsMap = new ACCEDE_T_InvoiceLineDetailFileAttach();
                {
                    docsMap.FileAttach_Id = docs.ID;
                    docsMap.ExpDetail_Id = Convert.ToInt32(Session["InvDetailsID"]);
                }
                _DataContext.ACCEDE_T_InvoiceLineDetailFileAttaches.InsertOnSubmit(docsMap);
                _DataContext.SubmitChanges();
            }

            SqlDocs.DataBind();

        }

        //protected void dept_reim_Callback(object sender, CallbackEventArgsBase e)
        //{
        //    SqlDepartment.SelectParameters["CompanyId"].DefaultValue = exp_CTCompany.Value.ToString() ;
        //    SqlDepartment.DataBind();

        //    dept_reim.DataSourceID = null;
        //    dept_reim.DataSource = SqlDepartment;
        //    dept_reim.DataBind();
        //}
        protected void DocuGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var expFile_Id = e.Keys["File_Id"].ToString();

            var expFile = _DataContext.ITP_T_FileAttachments
                .Where(x => x.ID == Convert.ToInt32(expFile_Id))
                .FirstOrDefault();

            if (expFile != null)
            {
                expFile.Description = e.NewValues["Description"].ToString();
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }

        protected void DocuGrid_edit_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            ASPxGridView gridView = (ASPxGridView)sender;
            var invFile_Id = e.Keys["File_Id"].ToString();

            var invFile = _DataContext.ITP_T_FileAttachments
                .Where(x => x.ID == Convert.ToInt32(invFile_Id))
                .FirstOrDefault();

            var invMap = _DataContext.ACCEDE_T_InvoiceLineDetailFileAttaches
                .Where(x => x.FileAttach_Id == Convert.ToInt32(invFile_Id))
                .FirstOrDefault();

            if (invFile != null)
            {
                _DataContext.ITP_T_FileAttachments.DeleteOnSubmit(invFile);
                _DataContext.ACCEDE_T_InvoiceLineDetailFileAttaches.DeleteOnSubmit(invMap);
                _DataContext.SubmitChanges();
            }

            DocuGrid_edit.DataBind();
            e.Cancel = true;
            gridView.CancelEdit();
        }


        protected void DocuGrid_edit_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            Session["InvDetailsID"] = null;

            DocuGrid_edit.DataSourceID = null;
            DocuGrid_edit.DataSource = SqlExpDetailAttach;
            DocuGrid_edit.DataBind();
        }

        protected void exp_Company_Callback(object sender, CallbackEventArgsBase e)
        {

        }

        protected void drpdown_WF_Callback(object sender, CallbackEventArgsBase e)
        {

            var param = e.Parameter.Split('|');
            var dept_id = param[0] != "null" ? param[0] : "0";
            var comp = param[1] != "null" ? param[1] : "0";
            var emp = Session["userID"].ToString();
            var expDetails = _DataContext.ACCEDE_T_InvoiceLineDetails
                            .Where(x => x.InvMain_ID == Convert.ToInt32(Session["NonPOInvoiceId"]));
            var totalExp = new decimal(0.00);

            foreach (var exp in expDetails)
            {
                totalExp += Convert.ToDecimal(exp.NetAmount);
            }

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
                    //var rawf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == emp)
                    //        .Where(x => x.CompanyId == Convert.ToInt32(comp))
                    //        .Where(x => x.DepCode == depcode.DepCode)
                    //        //.Where(x => x.IsRA == true)
                    //        .FirstOrDefault();

                    //if (rawf != null)
                    //{
                    //    SqlWF.SelectParameters["WF_Id"].DefaultValue = rawf.WF_Id.ToString();
                    //    drpdown_WF.DataSourceID = null;
                    //    drpdown_WF.DataSource = SqlWF;
                    //    drpdown_WF.SelectedIndex = 0;
                    //    drpdown_WF.DataBind();
                    //}
                    //else
                    //{
                    //    SqlWF.SelectParameters["WF_Id"].DefaultValue = "0";
                    //    drpdown_WF.DataSourceID = null;
                    //    drpdown_WF.DataSource = SqlWF;
                    //    drpdown_WF.DataBind();

                    //}

                    SqlWFAmount.SelectParameters["UserId"].DefaultValue = emp;
                    SqlWFAmount.SelectParameters["CompanyId"].DefaultValue = comp;
                    SqlWFAmount.SelectParameters["totalExp"].DefaultValue = totalExp.ToString();
                    SqlWFAmount.SelectParameters["DepCode"].DefaultValue = depcode.DepCode;
                    SqlWFAmount.SelectParameters["AppId"].DefaultValue = "1032";
                    SqlWFAmount.DataBind();

                    drpdown_WF.DataSourceID = null;
                    drpdown_WF.DataSource = SqlWFAmount;
                    drpdown_WF.SelectedIndex = 0;
                    drpdown_WF.DataBind();
                }
            }
        }

        
        protected void exp_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            exp_CTDepartment.DataSourceID = null;
            exp_CTDepartment.DataSource = SqlCTDepartment;
            exp_CTDepartment.DataBind();
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp_id = param[0];
            var dept_id = param[1] != "null" ? param[1] : "0";
            var CostCenter = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(dept_id)).FirstOrDefault();

            sqlCostCenter.SelectParameters["Company_ID"].DefaultValue = comp_id;
            sqlCostCenter.DataBind();

            //drpdown_CostCenter.DataSourceID = null;
            //drpdown_CostCenter.DataSource = sqlCostCenter;
            //drpdown_CostCenter.DataBind();
            if (CostCenter != null)
            {
                drpdown_CostCenter.DataSourceID = null;
                drpdown_CostCenter.DataSource = sqlCostCenter;
                drpdown_CostCenter.DataBind();
                drpdown_CostCenter.Value = CostCenter.SAP_CostCenter != null ? CostCenter.SAP_CostCenter.ToString() : "";
            }

            //var count = drpdown_CostCenter.Items.Count;
            //if (count == 1)
            //    drpdown_CostCenter.SelectedIndex = 0; drpdown_CostCenter.DataBind();
        }

        protected void exp_CompLocation_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();

            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = comp_id;
            SqlCompLocation.DataBind();

            exp_CompLocation.DataSourceID = null;
            exp_CompLocation.DataSource = SqlCompLocation;
            exp_CompLocation.DataBind();
        }

        protected void costCenter_edit_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            sqlCostCenter.SelectParameters["Company_ID"].DefaultValue = comp_id;
            sqlCostCenter.DataBind();

            //costCenter_edit.DataSourceID = null;
            //costCenter_edit.DataSource = sqlCostCenter;
            //costCenter_edit.DataBind();
        }

        [WebMethod]
        public static string GenerateTempCostAllocAJAX()
        {
            string filePath = HttpContext.Current.Server.MapPath("~/Temp/CostAllocation.xlsx");

            AccedeNonPOEditPage exp = new AccedeNonPOEditPage();
            exp.GenerateTempCostAlloc(filePath);

            // Return a URL to be used by JS to trigger download
            return "/accede/Temp/CostAllocation.xlsx";
        }


        public void GenerateTempCostAlloc(string filePath)
        {
            List<string> costCenters = GetCostCenters();
            // Set the LicenseContext for EPPlus
            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

            using (var package = new ExcelPackage())
            {
                var ws = package.Workbook.Worksheets.Add("MainSheet");
                var hiddenSheet = package.Workbook.Worksheets.Add("Hidden");

                ws.Cells[1, 1].Value = "COST CENTER";
                ws.Cells[1, 2].Value = "AMOUNT";
                ws.Cells[1, 3].Value = "REMARKS";

                // Add Cost Centers to HiddenSheet
                int i = 1;
                foreach (var cc in costCenters)
                {
                    hiddenSheet.Cells[i, 1].Value = cc;
                    i++;
                }

                // Define named range
                var range = hiddenSheet.Cells[1, 1, costCenters.Count, 1];
                var namedRange = package.Workbook.Names.Add("CostCenterList", range);
                hiddenSheet.Hidden = eWorkSheetHidden.VeryHidden;

                // Add data validation that references the named range
                for (int row = 2; row <= 100; row++)
                {
                    var validation = ws.DataValidations.AddListValidation(ws.Cells[row, 1].Address);
                    validation.Formula.ExcelFormula = "CostCenterList";

                    ws.Column(1).Width = 35;
                    ws.Column(2).Width = 25;
                    ws.Column(3).Width = 25;

                    ws.Cells["A1"].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    ws.Cells["B1"].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    ws.Cells["C1"].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    ws.Cells["A1"].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray);
                    ws.Cells["B1"].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray);
                    ws.Cells["C1"].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray);
                    ws.Cells["A1"].Style.Font.Bold = true;
                    ws.Cells["B1"].Style.Font.Bold = true;
                    ws.Cells["C1"].Style.Font.Bold = true;

                    ws.Cells["B2:B100"].Style.Numberformat.Format = "#,##0.00";

                    var validationAmnt = ws.DataValidations.AddDecimalValidation(ws.Cells[row, 2].Address);
                    validationAmnt.ShowErrorMessage = true;
                    validationAmnt.Error = "Please enter a valid number (decimal or integer).";
                    validationAmnt.ErrorTitle = "Invalid Input";
                    validationAmnt.Operator = OfficeOpenXml.DataValidation.ExcelDataValidationOperator.between;
                    validationAmnt.Formula.Value = 0;       // Minimum value allowed
                    validationAmnt.Formula2.Value = 999999; // Max value (you can change this as needed)
                }

                package.SaveAs(new System.IO.FileInfo(filePath));
            }
        }


        private List<string> GetCostCenters()
        {
            var costCenterList = _DataContext.ITP_S_OrgDepartmentMasters
                .Where(x => x.SAP_CostCenter != null)
                .OrderBy(x => x.DepDesc)
                .Select(x => x.SAP_CostCenter)
                .Distinct()
                .ToList();

            return costCenterList;
        }

        protected void UploadControllerExpD0_FileUploadComplete(object sender, FileUploadCompleteEventArgs e)
        {
            string filePath = Server.MapPath("~/Temp/" + e.UploadedFile.FileName);
            e.UploadedFile.SaveAs(filePath);

            // Process the uploaded Excel file and insert data into SQL Server
            ProcessAndInsertData(filePath);

            File.Delete(filePath); // Delete the uploaded file if needed
        }

        private void ProcessAndInsertData(string filePath)
        {
            // Set the LicenseContext for EPPlus
            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using (var package = new ExcelPackage(new FileInfo(filePath)))
            {
                decimal totalNetAmount = 0;
                var worksheet = package.Workbook.Worksheets[0]; // Assuming the data is on the first worksheet

                for (int row = 2; row <= worksheet.Dimension.End.Row; row++)
                {
                    string cc = worksheet.Cells[row, 1].Text?.Trim();
                    string rawAmount = worksheet.Cells[row, 2].Text?.Replace(",", "").Trim();

                    // Stop reading once CostCenter or Amount is blank
                    if (string.IsNullOrEmpty(cc) && string.IsNullOrEmpty(rawAmount))
                        break;

                    if (string.IsNullOrEmpty(rawAmount))
                        throw new Exception($"Amount is required in row {row}.");

                    if (!decimal.TryParse(rawAmount, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal amnt))
                        throw new Exception($"Invalid amount format in row {row}: '{rawAmount}'");

                    string remarks = worksheet.Cells[row, 3].Text?.Trim();
                    int id = GetNewId();
                    InsertDataIntoDataTable(id, cc, amnt, remarks);

                    totalNetAmount += amnt;
                }

                ASPxGridView grid = (ASPxGridView)ExpAllocGrid;
                grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;

            }
        }

        private void InsertDataIntoDataTable(int id, string cc, decimal amnt, string remarks)
        {
            decimal totalNetAmount = 0;
            ASPxGridView grid = (ASPxGridView)ExpAllocGrid;

            // Sum up all existing NetAmounts
            for (int i = 0; i < grid.VisibleRowCount; i++)
            {
                object netAmountObj = grid.GetRowValues(i, "NetAmount");
                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    totalNetAmount += Convert.ToDecimal(netAmountObj);
                }
            }

            // Add the new amount
            totalNetAmount += amnt;

            // Compare with gross
            //decimal gross = Convert.ToDecimal(grossAmount.Value);
            //if (totalNetAmount > gross)
            //{
            //    grid.JSProperties["cpAllocationExceeded"] = true;
            //    return;
            //}

            // Get session and data table
            dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
            ASPxGridView gridView = (ASPxGridView)ExpAllocGrid;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsExpAlloc.Tables[1] : dsExpAlloc.Tables[0];

            // Create and fill new row
            DataRow row = dataTable.NewRow();
            row["ID"] = id;
            row["CostCenter"] = cc;
            row["NetAmount"] = amnt;
            row["Remarks"] = remarks;
            dataTable.Rows.Add(row);


        }

        protected void ExpAllocGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            dsExpAlloc = (DataSet)Session["DataSetInvAlloc"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? dsExpAlloc.Tables[1] : dsExpAlloc.Tables[0];
            DataRow row = dataTable.Rows.Find(e.Keys[0]);
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                row[enumerator.Key.ToString()] = enumerator.Value;
            gridView.CancelEdit();
            e.Cancel = true;

            decimal totalNetAmount = 0;
            for (int i = 0; i < ExpAllocGrid.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid.GetRowValues(i, "NetAmount");

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    totalNetAmount += netAmount;
                }
            }
            //if (totalNetAmount > Convert.ToDecimal(grossAmount.Value))
            //{
            //    ExpAllocGrid.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}

            ASPxGridView grid = (ASPxGridView)sender;
            grid.JSProperties["cpComputeUnalloc"] = totalNetAmount;
        }

        protected void ExpAllocGrid_edit_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            decimal totalNetAmount = 0;
            var RowIndex = e.NewValues["InvoiceDetailMap_ID"].ToString();
            var newAmnt = e.NewValues["NetAmount"].ToString();
            string ID_ObjID = "";
            // Check if the grid is bound to a DataTable, List, or other collection
            for (int i = 0; i < ExpAllocGrid_edit.VisibleRowCount; i++)
            {
                // Get the value of NetAmount from each visible row
                object netAmountObj = ExpAllocGrid_edit.GetRowValues(i, "NetAmount");
                object ID_Obj = ExpAllocGrid_edit.GetRowValues(i, "InvoiceDetailMap_ID");
                ID_ObjID = ExpAllocGrid_edit.GetRowValues(i, "InvoiceReportDetail_ID").ToString();

                if (netAmountObj != null && netAmountObj != DBNull.Value)
                {
                    decimal netAmount = Convert.ToDecimal(netAmountObj);
                    if (RowIndex.ToString() == ID_Obj.ToString())
                    {
                        netAmount = Convert.ToDecimal(newAmnt);
                    }
                    totalNetAmount += netAmount;
                }
            }

            //if (totalNetAmount > Convert.ToDecimal(grossAmount_edit.Value))
            //{
            //    ExpAllocGrid_edit.Styles.Footer.ForeColor = System.Drawing.Color.Red;
            //}
            ASPxGridView grid = (ASPxGridView)sender;

            


            //e.Cancel = true;

            SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = ID_ObjID;

            // 🔑 Rebind your data (otherwise grid will show "no data to display")
            grid.DataSourceID = null;
            grid.DataSource = SqlInvMap;
            grid.DataBind();

            grid.JSProperties["cpComputeUnalloc_edit"] = totalNetAmount;
        }

        protected void ExpAllocGrid_edit_BatchUpdate(object sender, DevExpress.Web.Data.ASPxDataBatchUpdateEventArgs e)
        {
            var grid = (ASPxGridView)sender;

            if (Session["InvDetailsID"] == null)
            {
                e.Handled = true;
                return;
            }

            int detailId = Convert.ToInt32(Session["InvDetailsID"]);

            // Base total before applying this batch
            decimal baseTotal = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                .Where(m => m.InvoiceReportDetail_ID == detailId)
                .Sum(m => (decimal?)m.NetAmount) ?? 0m;

            decimal delta = 0m;

            // Updates
            foreach (var upd in e.UpdateValues)
            {
                decimal oldNet = Convert.ToDecimal(upd.OldValues["NetAmount"] ?? 0m);
                decimal newNet = Convert.ToDecimal(upd.NewValues["NetAmount"] ?? 0m);
                delta += (newNet - oldNet);
            }

            // Inserts
            foreach (var ins in e.InsertValues)
            {
                decimal newNet = Convert.ToDecimal(ins.NewValues["NetAmount"] ?? 0m);
                delta += newNet;
            }

            // Deletes
            foreach (var del in e.DeleteValues)
            {
                // Fix: Use `Values` instead of `OldValues` for delete operations
                decimal oldNet = Convert.ToDecimal(del.Values["NetAmount"] ?? 0m);
                delta -= oldNet;
            }

            decimal finalTotal = baseTotal + delta;

            decimal maxAllowed = 0m;
            if (decimal.TryParse(total_edit.Value?.ToString(), out var tmp))
                maxAllowed = tmp;

            if (maxAllowed > 0 && finalTotal > maxAllowed)
            {
                grid.JSProperties["cpAllocationExceeded"] = true;
                //grid.JSProperties["cpComputeUnalloc_edit"] = finalTotal;
                e.Handled = true; // Abort persistence

                SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = detailId.ToString();

                // 🔑 Rebind your data (otherwise grid will show "no data to display")
                grid.DataSourceID = null;
                grid.DataSource = SqlInvMap;
                grid.DataBind();

                return;
            }

            // Persist updates
            foreach (var upd in e.UpdateValues)
            {
                int key = Convert.ToInt32(upd.Keys["InvoiceDetailMap_ID"]);
                var entity = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Single(m => m.InvoiceDetailMap_ID == key);

                entity.NetAmount = Convert.ToDecimal(upd.NewValues["NetAmount"] ?? 0m);
                if (upd.NewValues.Contains("Remarks"))
                    entity.EDM_Remarks = upd.NewValues["Remarks"]?.ToString();
                if (upd.NewValues.Contains("CostCenterIOWBS"))
                    entity.CostCenterIOWBS = upd.NewValues["CostCenterIOWBS"]?.ToString();
            }

            // Persist inserts
            foreach (var ins in e.InsertValues)
            {
                var map = new ACCEDE_T_InvoiceLineDetailsMap
                {
                    InvoiceReportDetail_ID = detailId,
                    NetAmount = Convert.ToDecimal(ins.NewValues["NetAmount"] ?? 0m),
                    CostCenterIOWBS = (ins.NewValues.Contains("CostCenterIOWBS")
                                      ? ins.NewValues["CostCenterIOWBS"]?.ToString()
                                      : ins.NewValues.Contains("CostCenter")
                                        ? ins.NewValues["CostCenter"]?.ToString()
                                        : null),
                    EDM_Remarks = ins.NewValues["Remarks"]?.ToString(),
                    Preparer_ID = Session["userID"]?.ToString()
                };
                _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.InsertOnSubmit(map);
            }

            // Persist deletes
            foreach (var del in e.DeleteValues)
            {
                int key = Convert.ToInt32(del.Keys["InvoiceDetailMap_ID"]);
                var entity = _DataContext.ACCEDE_T_InvoiceLineDetailsMaps
                    .Single(m => m.InvoiceDetailMap_ID == key);
                _DataContext.ACCEDE_T_InvoiceLineDetailsMaps.DeleteOnSubmit(entity);
            }

            _DataContext.SubmitChanges();

            SqlInvMap.SelectParameters["InvoiceReportDetail_ID"].DefaultValue = detailId.ToString();

            // 🔑 Rebind your data (otherwise grid will show "no data to display")
            grid.DataSourceID = null;
            grid.DataSource = SqlInvMap;
            grid.DataBind();

            grid.JSProperties["cpComputeUnalloc_edit"] = finalTotal;
            e.Handled = true; // We applied everything manually
        }

        // PERFORMANCE IMPROVEMENT: Efficient vendor lookup with server-side filtering + in‑memory caching.
        // -----------------------------------------------------------------------------
        // PSEUDOCODE
        // 1. Validate input vendor code -> if null/empty return null.
        // 2. Try get from MemoryCache (key: "VENDOR_<code>").
        // 3. If cached -> return.
        // 4. Build minimal OData query using $filter and $top=1 to avoid fetching entire set.
        // 5. Call SAPVendor.GetVendorData(query).
        // 6. Take first result; if found cache (sliding/absolute expiration).
        // 7. Return result.
        // 8. WebMethod now directly calls static service (no unnecessary page instantiation).
        // 9. (Optional) Provide TryGet pattern + small lock to avoid cache stampede.
        //
        // NOTES
        // - Keeps return type VendorSet for backward compatibility.
        // - Adds defensive try/catch (swallows errors but can be extended for logging).
        // - Requires: using System.Runtime.Caching;
        // -----------------------------------------------------------------------------

        // Replaced WebMethod to avoid creating a Page instance each call.
        [WebMethod]
        public static VendorSet CheckVendorDetailsAJAX(string vendor)
        {
            return VendorLookupService.GetVendor(vendor);
        }

        /// <summary>
        /// Centralized, cached vendor lookup.
        /// </summary>
        // REPLACE the previous VendorDataSetCache with this expanded version
        internal static class VendorDataSetCache
        {
            private static readonly object _sync = new object();
            private static readonly DataSet _ds = new DataSet("VendorCache");
            private static readonly DataTable _table;

            static VendorDataSetCache()
            {
                _table = new DataTable("Vendors");
                _table.Columns.Add("VENDCODE", typeof(string));
                _table.Columns.Add("VENDNAME", typeof(string));
                _table.Columns.Add("VENDCOCODE", typeof(string));
                _table.Columns.Add("VENDTIN", typeof(string));
                _table.Columns.Add("VENDSTREET", typeof(string));
                _table.Columns.Add("VENDCITY", typeof(string));
                _table.Columns.Add("VENDPOSTAL", typeof(string));
                // (Optional) Add VENDSTREET2, VENDCOUNTRY, etc., if also needed later
                _table.PrimaryKey = new[] { _table.Columns["VENDCODE"] };
                _ds.Tables.Add(_table);
            }

            public static void AddOrUpdate(IEnumerable<VendorSet> vendors)
            {
                if (vendors == null) return;
                lock (_sync)
                {
                    foreach (var v in vendors)
                    {
                        if (v == null || string.IsNullOrWhiteSpace(v.VENDCODE)) continue;
                        var code = v.VENDCODE.Trim().ToUpperInvariant();
                        var row = _table.Rows.Find(code);
                        if (row == null)
                        {
                            row = _table.NewRow();
                            row["VENDCODE"] = code;
                            row["VENDNAME"] = v.VENDNAME;
                            row["VENDCOCODE"] = v.VENDCOCODE;
                            row["VENDTIN"] = v.VENDTIN;
                            row["VENDSTREET"] = v.VENDSTREET;
                            row["VENDCITY"] = v.VENDCITY;
                            row["VENDPOSTAL"] = v.VENDPOSTAL;
                            _table.Rows.Add(row);
                        }
                        else
                        {
                            row["VENDNAME"] = v.VENDNAME;
                            row["VENDCOCODE"] = v.VENDCOCODE;
                            row["VENDTIN"] = v.VENDTIN;
                            row["VENDSTREET"] = v.VENDSTREET;
                            row["VENDCITY"] = v.VENDCITY;
                            row["VENDPOSTAL"] = v.VENDPOSTAL;
                        }
                    }
                }
            }

            public static VendorSet Get(string vendorCode)
            {
                if (string.IsNullOrWhiteSpace(vendorCode)) return null;
                var code = vendorCode.Trim().ToUpperInvariant();
                lock (_sync)
                {
                    var row = _table.Rows.Find(code);
                    if (row == null) return null;
                    return new VendorSet
                    {
                        VENDCODE = (string)row["VENDCODE"],
                        VENDNAME = row["VENDNAME"] as string,
                        VENDCOCODE = row["VENDCOCODE"] as string,
                        VENDTIN = row["VENDTIN"] as string,
                        VENDSTREET = row["VENDSTREET"] as string,
                        VENDCITY = row["VENDCITY"] as string,
                        VENDPOSTAL = row["VENDPOSTAL"] as string
                    };
                }
            }

            public static DataTable Table => _table;
        }

        // To resolve the CS0111 error, we need to ensure that there is only one definition of the method `GetVendorListCached` in the `AccedeNonPOEditPage` class.  
        // After reviewing the provided code, it appears that there are two conflicting definitions of `GetVendorListCached`.  
        // Below is the corrected version where we retain only one definition of the method.  

        
        // MODIFY VendorLookupService to also return the new fields
        internal static class VendorLookupService
        {
            private static readonly ObjectCache _cache = MemoryCache.Default;
            private static readonly TimeSpan AbsoluteLifetime = TimeSpan.FromMinutes(10);
            private static readonly TimeSpan SlidingLifetime = TimeSpan.FromMinutes(3);
            private static readonly object _lockRoot = new object();
            private const string SapClient = "sap-client=300";

            public static VendorSet GetVendor(string vendorCode)
            {
                if (string.IsNullOrWhiteSpace(vendorCode))
                    return null;

                // 1. DataSet
                var dsHit = VendorDataSetCache.Get(vendorCode);
                if (dsHit != null) return dsHit;

                vendorCode = vendorCode.Trim().ToUpperInvariant();
                string cacheKey = "VENDOR_" + vendorCode;

                // 2. MemoryCache
                var cached = _cache.Get(cacheKey) as VendorSet;
                if (cached != null) return cached;

                lock (_lockRoot)
                {
                    cached = _cache.Get(cacheKey) as VendorSet;
                    if (cached != null) return cached;

                    VendorSet result = null;
                    try
                    {
                        string query = $"{SapClient}&$filter=VENDCODE eq '{EscapeODataLiteral(vendorCode)}'&$top=1";
                        result = SAPConnector.GetVendorData(query)
                                          .FirstOrDefault(v => string.Equals(v.VENDCODE?.Trim(), vendorCode, StringComparison.OrdinalIgnoreCase));

                        if (result != null)
                        {
                            _cache.Set(
                                cacheKey,
                                result,
                                new CacheItemPolicy
                                {
                                    AbsoluteExpiration = DateTimeOffset.UtcNow.Add(AbsoluteLifetime),
                                    SlidingExpiration = SlidingLifetime
                                });

                            VendorDataSetCache.AddOrUpdate(new[] { result });
                        }
                    }
                    catch
                    {
                        return result;
                    }

                    return result;
                }
            }

            private static string EscapeODataLiteral(string value) => value.Replace("'", "''");
        }

        // Add near other static fields
        private static readonly object _vendorRefreshLock = new object();
        private static readonly Dictionary<string, DateTime> _vendorLastRefreshUtc = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);
        private static readonly TimeSpan VendorListMaxAge = TimeSpan.FromMinutes(30);

        // Core fetch without age / cache logic (extracted from existing GetVendorListCached body)
        private List<VendorSet> FetchVendorListFromSap(string compCode)
        {
            if (string.IsNullOrWhiteSpace(compCode))
                return new List<VendorSet>();

            string query = $"{SapClientParam}&$filter=VENDCOCODE eq '{compCode}'";
            var list = SAPConnector.GetVendorData(query)
                .GroupBy(v => v.VENDCODE?.Trim().ToUpperInvariant())
                .Select(g => g.First())
                .OrderBy(v => v.VENDNAME)
                .ToList();

            // Update dataset cache
            VendorDataSetCache.AddOrUpdate(list);
            return list;
        }

        // Unified access: returns cached list if fresh, else refreshes. Force overrides freshness.
        private List<VendorSet> GetOrRefreshVendorList(string compCode, bool force = false)
        {
            if (string.IsNullOrWhiteSpace(compCode))
                return new List<VendorSet>();

            string memKey = "VENDOR_LIST_" + compCode;
            var now = DateTime.UtcNow;

            if (!force)
            {
                if (_cache.Get(memKey) is List<VendorSet> cached &&
                    _vendorLastRefreshUtc.TryGetValue(compCode, out var last) &&
                    (now - last) < VendorListMaxAge &&
                    cached.Count > 0)
                {
                    return cached;
                }
            }

            lock (_vendorRefreshLock)
            {
                // Double check inside lock
                if (!force)
                {
                    if (_cache.Get(memKey) is List<VendorSet> cached2 &&
                        _vendorLastRefreshUtc.TryGetValue(compCode, out var last2) &&
                        (now - last2) < VendorListMaxAge &&
                        cached2.Count > 0)
                    {
                        return cached2;
                    }
                }

                var fresh = FetchVendorListFromSap(compCode);

                // Store in MemoryCache (shorter lifetime OK; we manage staleness via _vendorLastRefreshUtc)
                _cache.Set(memKey, fresh, DateTimeOffset.UtcNow.AddMinutes(15));
                _vendorLastRefreshUtc[compCode] = now;

                return fresh;
            }
        }


        protected void drpdown_vendor_Callback(object sender, CallbackEventArgsBase e)
        {
            // Expected: "companyId" OR "companyId|force"
            var raw = e.Parameter ?? "";
            var parts = raw.Split('|');
            var compIdStr = parts.Length > 0 ? parts[0] : "";
            var forceFlag = parts.Length > 1 ? parts[1] : "";

            bool force = false;
            if (!string.IsNullOrWhiteSpace(forceFlag))
            {
                var f = forceFlag.Trim().ToLowerInvariant();
                force = f == "force" || f == "refresh" || f == "1" || f == "true";
            }

            if (!int.TryParse(compIdStr, out int compId))
                return;

            var compCode = _DataContext.CompanyMasters
                .Where(x => x.WASSId == compId)
                .Select(x => x.SAP_Id)
                .FirstOrDefault().ToString();

            if (string.IsNullOrWhiteSpace(compCode))
                return;

            // Fetch (cached or refreshed)
            var vendors = GetOrRefreshVendorList(compCode, force);

            drpdown_vendor.DataSource = vendors;
            drpdown_vendor.ValueField = "VENDCODE";
            drpdown_vendor.TextField = "VENDNAME";
            drpdown_vendor.Columns.Clear();
            drpdown_vendor.Columns.Add("VENDCODE");
            drpdown_vendor.Columns.Add("VENDNAME");
            drpdown_vendor.TextFormatString = "{0} - {1}";
            drpdown_vendor.DataBindItems();
            drpdown_vendor.ValidationSettings.RequiredField.IsRequired = true;

            // (Optional) Expose metadata to client for diagnostics
            if (drpdown_vendor is ASPxComboBox combo)
            {
                if (_vendorLastRefreshUtc.TryGetValue(compCode, out var lastUtc))
                    combo.JSProperties["cpVendorLastRefresh"] = lastUtc.ToString("o");
                combo.JSProperties["cpVendorCount"] = vendors.Count;
                combo.JSProperties["cpVendorForced"] = force;
            }
        }

        [WebMethod]
        public static int RefreshVendorCacheAJAX(int companyId)
        {
            var page = new AccedeNonPOEditPage();
            var compCode = page._DataContext.CompanyMasters
                .Where(x => x.WASSId == companyId)
                .Select(x => x.SAP_Id)
                .FirstOrDefault().ToString();

            if (string.IsNullOrWhiteSpace(compCode))
                return 0;

            var list = page.GetOrRefreshVendorList(compCode, true);
            return list.Count;
        }
    }
}