using DevExpress.DocumentServices.ServiceModel.DataContracts;
using DevExpress.Web;
using DevExpress.Web.Data;
using DevExpress.Web.Internal.XmlProcessor;
using DevExpress.XtraPrinting;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class TravelExpenseAdd : System.Web.UI.Page
    {
        string ITPORTALcon = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        DataSet ds = null;
        DataSet dsDoc = null;

        void ApplyStylesToGrid(dynamic grid, string colorCode)
        {
            var color = ColorTranslator.FromHtml(colorCode);
            grid.StylesPager.CurrentPageNumber.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.DropDownButtonStyle.HoverStyle.BackColor = color;
            grid.StylesPager.PageSizeItem.ComboBoxStyle.ItemStyle.SelectedStyle.BackColor = color;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    string colorCode = "#06838";
                    ApplyStylesToGrid(CAGrid, colorCode);
                    ApplyStylesToGrid(ExpenseGrid, colorCode);
                    ApplyStylesToGrid(DocumentGrid, colorCode);
                    ApplyStylesToGrid(WFSequenceGrid, colorCode);
                    ApplyStylesToGrid(FAPWFGrid, colorCode);
                    ApplyStylesToGrid(capopGrid, colorCode);
                    ApplyStylesToGrid(TraDocuGrid, colorCode);
                    ApplyStylesToGrid(ASPxGridView22, colorCode);

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();
                    Session["statusid"] = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").Select(x => x.STS_Id).FirstOrDefault();

                    if (mainExp != null)
                    {
                        var status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault() ?? string.Empty;

                        if (Convert.ToString(Session["main_action"]) == "edit")
                            ExpenseEditForm.Items[0].Caption = "Update Travel Expense Document No.: " + mainExp.Doc_No;
                        else
                            ExpenseEditForm.Items[0].Caption = "New Travel Expense";

                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());
                        Session["DocNo"] = mainExp.Doc_No.ToString();
                        Session["Employee_Id"] = mainExp.Employee_Id.ToString();
                    }

                    SqlExpDetailsMap.SelectParameters["TravelExpenseDetail_ID"].DefaultValue = "0";
                    ASPxGridView22.DataBind();
                    CAGrid.DataBind();
                    ExpenseGrid.DataBind();

                    InitializeExpCA(mainExp);

                    ASPxGridView22.DataSource = ds.Tables[0];
                    ASPxGridView22.DataBind();

                    //reimTranGrid.DataSource = ds.Tables[0];
                    //fixedAllowGrid.DataSource = ds.Tables[1];
                    //miscTravelGrid.DataSource = ds.Tables[2];
                    //otherBusGrid.DataSource = ds.Tables[3];
                    //entertainmentGrid.DataSource = ds.Tables[4];
                    //busMealsGrid.DataSource = ds.Tables[5];

                    //reimTranGrid.DataBind();
                    //fixedAllowGrid.DataBind();
                    //miscTravelGrid.DataBind();
                    //otherBusGrid.DataBind();
                    //entertainmentGrid.DataBind();
                    //busMealsGrid.DataBind();

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
                if (mainExp != null)
                {
                    var due_lbl = ExpenseEditForm.FindItemOrGroupByName("due_lbl") as LayoutItem;
                    var reimItem = ExpenseEditForm.FindItemOrGroupByName("reimItem") as LayoutItem;
                    var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutItem;

                    var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.IsExpenseReim == true).FirstOrDefault();

                    if (reim != null)
                    {
                        reimDetails.ClientVisible = true;
                        reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                    }

                    var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                    var userId = Convert.ToString(Session["userID"]);

                    var totalca = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId)
                        .Sum(x => (decimal?)x.Amount) ?? 0;

                    var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                        .Where(x => x.TravelExpenseMain_ID == travelExpId)
                        .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                    var countCA = _DataContext.ACCEDE_T_RFPMains
                        .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId);

                    var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                        .Count(x => x.TravelExpenseMain_ID == travelExpId);

                    var expType = countCA > 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

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

                    //SqlWF.SelectParameters["UserId"].DefaultValue = mainExp.Employee_Id.ToString();
                    //SqlWF.SelectParameters["CompanyId"].DefaultValue = mainExp.Company_Id.ToString();
                    //SqlWF.DataBind();
                    //drpdown_WF.Value = 2078; drpdown_WF.DataBind();

                    //// - - Setting RA Workflow - - ////

                    var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(mainExp.Dep_Code)).FirstOrDefault();

                    // Fetch data using the stored procedure
                    DataTable rawf = GetWorkflowHeadersByExpenseAndDepartment(mainExp.Employee_Id.ToString(), Convert.ToInt32(mainExp.Company_Id), totalexp, depcode != null ? depcode.DepCode : "0", 1032);

                    if (rawf != null && rawf.Rows.Count > 0)
                    {
                        // Get the first row's WF_Id value
                        DataRow firstRow = rawf.Rows[0];
                        int wfId = Convert.ToInt32(firstRow["WF_Id"]);

                        // Set the dropdown to the first item (if applicable)
                        drpdown_WF.SelectedIndex = 0;

                        // Update the SQL data source parameters
                        SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();
                        SqlWF.SelectParameters["WF_Id"].DefaultValue = wfId.ToString();
                    }
                    else
                    {
                        // Handle the case when no data is returned
                        drpdown_WF.SelectedIndex = -1; // Optionally reset the dropdown
                        SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = string.Empty;
                        SqlWF.SelectParameters["WF_Id"].DefaultValue = string.Empty;
                    }

                    //Session["mainwfid"] = Convert.ToString(_DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.UserId == mainExp.Employee_Id.ToString() && x.CompanyId == mainExp.Company_Id).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                    //SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                    //SqlWorkflowSequence.DataBind();

                    //Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? string.Empty;

                    //SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                    //SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                    //SqlFAPWF2.DataBind();
                    //SqlFAPWF.DataBind();

                    //// - - Setting FAP workflow - - ////
                    var fapwf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(mainExp.Company_Id))
                        .Where(x => x.App_Id == 1032)
                        .Where(x => x.Minimum <= Convert.ToDecimal(Math.Abs(totalexp)))
                        .Where(x => x.Maximum >= Convert.ToDecimal(Math.Abs(totalexp)))
                        .Where(x => x.IsRA == null || x.IsRA == false)
                        .FirstOrDefault();

                    if (fapwf != null)
                    {
                        drpdown_FAPWF.SelectedIndex = 0;
                        SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = fapwf.WF_Id.ToString();
                        SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = fapwf.WF_Id.ToString();
                    }
                }
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }

        private DataTable GetWorkflowHeadersByExpenseAndDepartment(string userId, int companyId, decimal totalExp, string depCode, int app_id)
        {
            DataTable dataTable = new DataTable();

            using (SqlConnection connection = new SqlConnection(ITPORTALcon))
            {
                using (SqlCommand command = new SqlCommand("sp_sel_ACCEDE_GetWorkflowHeadersByExpenseAndDepartment", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@CompanyId", companyId);
                    command.Parameters.AddWithValue("@totalExp", totalExp);
                    command.Parameters.AddWithValue("@DepCode", depCode);
                    command.Parameters.AddWithValue("@AppId", app_id);

                    // Open the connection
                    connection.Open();

                    // Execute the query and load the results into the DataTable
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        dataTable.Load(reader);
                    }
                }
            }

            return dataTable;
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    docs.App_ID = 1032;
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

        private int GetNewDocId()
        {
            dsDoc = (DataSet)Session["DataSetDoc"];
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

        protected void TraUploadController_FilesUploadComplete(object sender, DevExpress.Web.FilesUploadCompleteEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                foreach (var file in TraUploadController.UploadedFiles)
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

                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();

                    ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                    {
                        docs.FileAttachment = file.FileBytes;
                        docs.FileName = file.FileName;
                        docs.Doc_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                        docs.App_ID = 1032;
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
                    _DataContext.SubmitChanges();

                    ACCEDE_T_TravelExpenseDetailsFileAttach docs2 = new ACCEDE_T_TravelExpenseDetailsFileAttach();
                    {
                        docs2.FileAttachment_ID = docs.ID;
                        docs2.ExpenseDetails_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    };
                    _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(docs2);
                }
                _DataContext.SubmitChanges();
                SqlDocs.DataBind();
            }


            DataSet ImgDS = (DataSet)Session["DataSetDoc"];
            foreach (var file in TraUploadController.UploadedFiles)
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
                row["ID"] = GetNewDocId();
                row["FileName"] = file.FileName;
                row["FileAttachment"] = file.FileBytes;
                row["FileExtension"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["Description"] = "";
                ImgDS.Tables[0].Rows.Add(row);
            }

            // Bind the data set to the grid view
            Session["UploadedFilesTable"] = ImgDS.Tables[0];
            TraDocuGrid.DataSource = ImgDS.Tables[0];
            TraDocuGrid.DataBind();
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
                        ex.isTravel = true;
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
                    CA_RFP.isTravel = false;
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
                .Where(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId)
                .Sum(x => (decimal?)x.Amount) ?? 0;

            var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                .Where(x => x.TravelExpenseMain_ID == travelExpId)
                .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

            var countCA = _DataContext.ACCEDE_T_RFPMains
                .Count(x => x.Exp_ID == travelExpId && x.TranType == 1 && x.User_ID == userId);

            var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                .Count(x => x.TravelExpenseMain_ID == travelExpId);

            var expType = countCA > 0 && countExp == 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

            var allTot = totalexp > totalca
                ? $"({(totalexp - totalca):N2})"
                : (totalca - totalexp).ToString("N2");

            var totExpCA = totalexp > totalca 
                ? Convert.ToDecimal(totalexp - totalca) 
                : Convert.ToDecimal(totalca - totalexp);

            var rfpDocno = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == travelExpId && x.isTravel == true && x.IsExpenseReim == true).Select(x => x.RFP_DocNum).FirstOrDefault() ?? string.Empty;
            if (!string.IsNullOrEmpty(rfpDocno))
            {
                var rfp = _DataContext.ACCEDE_T_RFPMains.Where(x => x.RFP_DocNum == rfpDocno);

                foreach (ACCEDE_T_RFPMain r in rfp)
                {
                    r.Amount = totExpCA;
                }
                _DataContext.SubmitChanges();
            }

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
            TravelExpenseAdd exp = new TravelExpenseAdd();

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

                var rfpCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.isTravel == true);
                var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).Where(x => x.isTravel == true).FirstOrDefault();
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
                    rfp.SAPCostCenter = Convert.ToString(_DataContext.ACCEDE_S_CostCenters.Where(x => x.CompanyId == Convert.ToInt32(company) && x.DepartmentId == Convert.ToInt32(department)).Select(x => x.CostCenter).FirstOrDefault());
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
            TravelExpenseAdd tra = new TravelExpenseAdd();
            return tra.SaveSubmitTravelExpense(empname, reportdate, company, department, datefrom, dateto, timedepart, timearrive, trip, purpose, expenseType, btnaction);
        }

        public object SaveSubmitTravelExpense(string empname, DateTime reportdate, string company, string department, DateTime datefrom, DateTime dateto, DateTime timedepart, DateTime timearrive, string trip, string purpose, string expenseType, string btnaction)
        {
            try
            {
                var expCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.isTravel == true).FirstOrDefault();

                if (expenseType == "1")
                {
                    if (expCA == null)
                        return new { message = "require CA" };
                }
                else
                {
                    if (expCA != null)
                        return new { message = "This transaction should be a Liquidation since you attached a Cash Advance." };
                }

                var doc_status = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Status).FirstOrDefault();
                var doc_desc = _DataContext.ITP_S_Status.Where(x => x.STS_Id == doc_status).Select(x => x.STS_Description).FirstOrDefault();

                var tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == Convert.ToInt32(expenseType)).FirstOrDefault();
                var exp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                
                if (string.IsNullOrEmpty(doc_desc) || !doc_desc.Contains("Returned"))
                    exp.Status = 13;

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
                var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.IsExpenseReim == true).Where(x => x.isTravel == true).FirstOrDefault();

                if (reim != null)
                {
                    reim.WF_Id = Convert.ToInt32(Session["mainwfid"]);
                    reim.FAPWF_Id = Convert.ToInt32(Session["fapwfid"]);

                    if (string.IsNullOrEmpty(doc_desc) || !doc_desc.Contains("Returned"))
                        reim.Status = 13;

                    var rfp_id = Convert.ToString(reim.ID);
                    var rfp_doc = Convert.ToString(reim.RFP_DocNum);
                    Session["rfp_id"] = rfp_id;
                    Session["rfp_doc"] = rfp_doc;
                }

                _DataContext.SubmitChanges();

                if (btnaction == "Submit" || btnaction == "CreateSubmit")
                {
                    var new_stat = 0;
                    int wfID = 0;
                    int wfdID = 0;
                    int orID = 0;

                    if (doc_desc == "Returned by Audit")
                    {
                        new_stat = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Pending at Audit").Select(x => x.STS_Id).FirstOrDefault();
                        wfID = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE AUDIT" && w.App_Id == 1032 && w.Company_Id == Convert.ToInt32(company)).Select(x => x.WF_Id).FirstOrDefault();
                        wfdID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                        orID = (int)_DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                    }
                    else if(doc_desc == "Returned by Finance")
                    {
                        new_stat = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Pending at Finance").Select(x => x.STS_Id).FirstOrDefault();
                        wfID = (int)_DataContext.ACCEDE_T_TravelExpenseMains.Where(w => w.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.FAPWF_Id).FirstOrDefault();
                        wfdID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                        orID = (int)_DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                    }
                    else
                    {
                        new_stat = 1;
                        wfID = Convert.ToInt32(Convert.ToInt32(Session["mainwfid"]));

                        // GET WORKFLOW DETAILS ID
                        var wfDetails = from wfd in _DataContext.ITP_S_WorkflowDetails
                                        where wfd.WF_Id == wfID && wfd.Sequence == 1
                                        select wfd.WFD_Id;
                        wfdID = wfDetails.FirstOrDefault();

                        // GET ORG ROLE ID
                        var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                      where or.WF_Id == wfID && or.Sequence == 1
                                      select or.OrgRole_Id;
                        orID = (int)orgRole.FirstOrDefault();
                    }


                    //Add reim to workflow activity
                    if (reim != null)
                    {
                        //change reimbursement status to pending
                        reim.Status = new_stat;

                        ITP_T_WorkflowActivity wfa_reim = new ITP_T_WorkflowActivity()
                        {
                            Status = new_stat,
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
                    exp.Status = new_stat;

                    //INSERT EXPENSE TO ITP_T_WorkflowActivity
                    DateTime currentDate = DateTime.Now;

                    ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                    {
                        Status = new_stat,
                        DateAssigned = currentDate,
                        DateAction = null,
                        WF_Id = wfID,
                        WFD_Id = wfdID,
                        OrgRole_Id = orID,
                        Document_Id = Convert.ToInt32(Session["TravelExp_Id"]),
                        AppId = 1032,
                        CompanyId = Convert.ToInt32(company),
                        AppDocTypeId = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel" || x.DCT_Description == "Accede Expense Travel").Select(x => x.DCT_Id).FirstOrDefault(),
                        IsActive = true,
                    };
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);
                    _DataContext.SubmitChanges();

                    //InsertAttachment(Convert.ToInt32(Session["ExpenseId"]));
                    SendEmail(Convert.ToInt32(wfa.Document_Id), orID, Convert.ToInt32(company), new_stat);
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
            TravelExpenseAdd exp = new TravelExpenseAdd();
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
                    CreateDataTable("TravelExpenseDetailMap_ID", "ReimTranspo_Type1", "ReimTranspo_Amount1", "ReimTranspo_Type2", "ReimTranspo_Amount2", "ReimTranspo_Type3", "ReimTranspo_Amount3", "FixedAllow_ForP", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount", "OtherBus_Type", "OtherBus_Specify", "OtherBus_Amount")
                    //CreateDataTable("ReimTranspo_ID", "ReimTranspo_Type", "ReimTranspo_Amount"),
                    //CreateDataTable("FixedAllow_ID", "FixedAllow_ForP", "FixedAllow_Amount"),
                    //CreateDataTable("MiscTravelExp_ID", "MiscTravelExp_Type", "MiscTravelExp_Amount", "MiscTravelExp_Specify"),
                    //CreateDataTable("OtherBusinessExp_ID", "OtherBusinessExp_Type", "OtherBusinessExp_Amount", "OtherBusinessExp_Specify"),
                    //CreateDataTable("Entertainment_ID", "Entertainment_Explain", "Entertainment_Amount"),
                    //CreateDataTable("BusinessMeal_ID", "BusinessMeal_Explain", "BusinessMeal_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
                ds = (DataSet)Session["DataSet"];



            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileAttachment", typeof(byte[]));
                masterTable.Columns.Add("FileExtension", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("Description", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;
            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
            TraDocuGrid.DataSource = dsDoc.Tables[0];
            TraDocuGrid.DataBind();

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
            var table = ds.Tables[tableIndex];
            var newRow = table.NewRow();
            e.NewValues[idColumn] = GetNewId(tableIndex, idColumn);
            foreach (DictionaryEntry entry in e.NewValues)
            {
                if (entry.Key.ToString() != "Count")
                {
                    newRow[entry.Key.ToString()] = entry.Value;
                }
            }
            table.Rows.Add(newRow);
            gridView.CancelEdit();
            e.Cancel = true;
            gridView.DataBind();
            gridView.JSProperties["cpSummary"] = gridView.GetTotalSummaryValue(gridView.TotalSummary[idColumn.Replace("_ID", "_Amount")]);
        }

        private void RowDelete(ASPxGridView gridView, int tableIndex, ASPxDataDeletingEventArgs e, string idColumn)
        {
            var table = ds.Tables[tableIndex];
            var row = table.Rows.Find(e.Keys[gridView.KeyFieldName]);
            if (row != null)
            {
                table.Rows.Remove(row);
            }

            e.Cancel = true;
            gridView.DataBind();
            gridView.JSProperties["cpSummary"] = gridView.GetTotalSummaryValue(gridView.TotalSummary[idColumn.Replace("_ID", "_Amount")]);
        }

        private int GetNewId1()
        {
            ds = (DataSet)Session["DataSet"];
            DataTable table = ds.Tables[0];
            if (table.Rows.Count == 0) return 0;
            int max = Convert.ToInt32(table.Rows[0]["TravelExpenseDetailMap_ID"]);
            for (int i = 1; i < table.Rows.Count; i++)
            {
                if (Convert.ToInt32(table.Rows[i]["TravelExpenseDetailMap_ID"]) > max)
                    max = Convert.ToInt32(table.Rows[i]["TravelExpenseDetailMap_ID"]);
            }
            return max + 1;
        }

        void calcExp(ASPxGridView gridView)
        {
            gridView.DataBind();

            var ReimTranspo_Amount1 = gridView.GetTotalSummaryValue(gridView.TotalSummary["ReimTranspo_Amount1"]);
            var ReimTranspo_Amount2 = gridView.GetTotalSummaryValue(gridView.TotalSummary["ReimTranspo_Amount2"]);
            var ReimTranspo_Amount3 = gridView.GetTotalSummaryValue(gridView.TotalSummary["ReimTranspo_Amount3"]);
            var FixedAllow_Amount = gridView.GetTotalSummaryValue(gridView.TotalSummary["FixedAllow_Amount"]);
            var MiscTravel_Amount = gridView.GetTotalSummaryValue(gridView.TotalSummary["MiscTravel_Amount"]);
            var Entertainment_Amount = gridView.GetTotalSummaryValue(gridView.TotalSummary["Entertainment_Amount"]);
            var BusMeals_Amount = gridView.GetTotalSummaryValue(gridView.TotalSummary["BusMeals_Amount"]);
            var OtherBus_Amount = gridView.GetTotalSummaryValue(gridView.TotalSummary["OtherBus_Amount"]);

            decimal total = Convert.ToDecimal(ReimTranspo_Amount1) + Convert.ToDecimal(ReimTranspo_Amount2) + Convert.ToDecimal(ReimTranspo_Amount3) + Convert.ToDecimal(FixedAllow_Amount) + Convert.ToDecimal(MiscTravel_Amount) + Convert.ToDecimal(Entertainment_Amount) + Convert.ToDecimal(BusMeals_Amount) + Convert.ToDecimal(OtherBus_Amount);
            gridView.JSProperties["cpTotal"] = total.ToString();
        }

        protected void ASPxGridView22_RowInserting(object sender, ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TravelExpenseDetailsMap td = new ACCEDE_T_TravelExpenseDetailsMap();
                {
                    td.ReimTranspo_Type1 = Convert.ToString(e.NewValues["ReimTranspo_Type1"]);
                    td.ReimTranspo_Type2 = Convert.ToString(e.NewValues["ReimTranspo_Type2"]);
                    td.ReimTranspo_Type3 = Convert.ToString(e.NewValues["ReimTranspo_Type3"]);
                    td.ReimTranspo_Amount1 = Convert.ToDecimal(e.NewValues["ReimTranspo_Amount1"]);
                    td.ReimTranspo_Amount2 = Convert.ToDecimal(e.NewValues["ReimTranspo_Amount2"]);
                    td.ReimTranspo_Amount3 = Convert.ToDecimal(e.NewValues["ReimTranspo_Amount3"]);
                    td.FixedAllow_ForP = Convert.ToString(e.NewValues["FixedAllow_ForP"]);
                    td.FixedAllow_Amount = Convert.ToDecimal(e.NewValues["FixedAllow_Amount"]);
                    td.MiscTravel_Type = Convert.ToString(e.NewValues["MiscTravel_Type"]);
                    td.MiscTravel_Specify = Convert.ToString(e.NewValues["MiscTravel_Specify"]);
                    td.MiscTravel_Amount = Convert.ToDecimal(e.NewValues["MiscTravel_Amount"]);
                    td.Entertainment_Explain = Convert.ToString(e.NewValues["Entertainment_Explain"]);
                    td.Entertainment_Amount = Convert.ToDecimal(e.NewValues["Entertainment_Amount"]);
                    td.BusMeals_Explain = Convert.ToString(e.NewValues["BusMeals_Explain"]);
                    td.BusMeals_Amount = Convert.ToDecimal(e.NewValues["BusMeals_Amount"]);
                    td.OtherBus_Type = Convert.ToString(e.NewValues["OtherBus_Type"]);
                    td.OtherBus_Specify = Convert.ToString(e.NewValues["OtherBus_Specify"]);
                    td.OtherBus_Amount = Convert.ToDecimal(e.NewValues["OtherBus_Amount"]);
                    td.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                }
                _DataContext.ACCEDE_T_TravelExpenseDetailsMaps.InsertOnSubmit(td);
                _DataContext.SubmitChanges();
            }

            ds = (DataSet)Session["DataSet"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? ds.Tables[1] : ds.Tables[0];
            DataRow row = dataTable.NewRow();
            e.NewValues["TravelExpenseDetailMap_ID"] = GetNewId1();
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                if (enumerator.Key.ToString() != "Count")
                    row[enumerator.Key.ToString()] = enumerator.Value ?? DBNull.Value;
            gridView.CancelEdit();
            e.Cancel = true;
            dataTable.Rows.Add(row);

            calcExp((ASPxGridView)sender);
        }

        protected void ASPxGridView22_RowUpdating(object sender, ASPxDataUpdatingEventArgs e)
        {
            ds = (DataSet)Session["DataSet"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? ds.Tables[1] : ds.Tables[0];
            DataRow row = dataTable.Rows.Find(e.Keys[0]);
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                row[enumerator.Key.ToString()] = enumerator.Value ?? DBNull.Value;
            gridView.CancelEdit();
            e.Cancel = true;

            if (Session["expAction"].ToString() == "edit")
            {
                _DataContext.ExecuteCommand(
                    @"UPDATE ACCEDE_T_TravelExpenseDetailsMap 
                      SET ReimTranspo_Type1 = {0}, 
                          ReimTranspo_Amount1 = {1}, 
                          ReimTranspo_Type2 = {2}, 
                          ReimTranspo_Amount2 = {3}, 
                          ReimTranspo_Type3 = {4}, 
                          ReimTranspo_Amount3 = {5}, 
                          FixedAllow_ForP = {6}, 
                          FixedAllow_Amount = {7}, 
                          MiscTravel_Type = {8}, 
                          MiscTravel_Specify = {9}, 
                          MiscTravel_Amount = {10}, 
                          Entertainment_Explain = {11}, 
                          Entertainment_Amount = {12}, 
                          BusMeals_Explain = {13}, 
                          BusMeals_Amount = {14}, 
                          OtherBus_Type = {15}, 
                          OtherBus_Specify = {16}, 
                          OtherBus_Amount = {17}
                      WHERE TravelExpenseDetailMap_ID = {18}",
                    Convert.ToString(e.NewValues["ReimTranspo_Type1"]),
                    Convert.ToDecimal(e.NewValues["ReimTranspo_Amount1"]),
                    Convert.ToString(e.NewValues["ReimTranspo_Type2"]),
                    Convert.ToDecimal(e.NewValues["ReimTranspo_Amount2"]),
                    Convert.ToString(e.NewValues["ReimTranspo_Type3"]),
                    Convert.ToDecimal(e.NewValues["ReimTranspo_Amount3"]),
                    Convert.ToString(e.NewValues["FixedAllow_ForP"]),
                    Convert.ToDecimal(e.NewValues["FixedAllow_Amount"]),
                    Convert.ToString(e.NewValues["MiscTravel_Type"]),
                    Convert.ToString(e.NewValues["MiscTravel_Specify"]),
                    Convert.ToDecimal(e.NewValues["MiscTravel_Amount"]),
                    Convert.ToString(e.NewValues["Entertainment_Explain"]),
                    Convert.ToDecimal(e.NewValues["Entertainment_Amount"]),
                    Convert.ToString(e.NewValues["BusMeals_Explain"]),
                    Convert.ToDecimal(e.NewValues["BusMeals_Amount"]),
                    Convert.ToString(e.NewValues["OtherBus_Type"]),
                    Convert.ToString(e.NewValues["OtherBus_Specify"]),
                    Convert.ToDecimal(e.NewValues["OtherBus_Amount"]),
                    Convert.ToInt32(e.Keys["TravelExpenseDetailMap_ID"])
                );
            }

            calcExp((ASPxGridView)sender);
        }

        protected void ASPxGridView22_RowDeleting(object sender, ASPxDataDeletingEventArgs e)
        {
            int i = ASPxGridView22.FindVisibleIndexByKeyValue(e.Keys[ASPxGridView22.KeyFieldName]);
            Control c = ASPxGridView22.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            ds = (DataSet)Session["DataSet"];
            ds.Tables[0].Rows.Remove(ds.Tables[0].Rows.Find(e.Keys[ASPxGridView22.KeyFieldName]));

            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TravelExpenseDetailsMap WHERE TravelExpenseDetailMap_ID = {0}", Convert.ToInt32(e.Values["TravelExpenseDetailMap_ID"]));
            }

            calcExp((ASPxGridView)sender);
        }

        protected void reimTranGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpReimTranspoMap rt = new ACCEDE_T_TraExpReimTranspoMap();
                {
                    rt.ReimTranspo_Type = Convert.ToString(e.NewValues["ReimTranspo_Type"]);
                    rt.ReimTranspo_Amount = Convert.ToDecimal(e.NewValues["ReimTranspo_Amount"]);
                    rt.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    rt.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpReimTranspoMaps.InsertOnSubmit(rt);
                _DataContext.SubmitChanges();
            }
            RowInsert((ASPxGridView)sender, 0, e, "ReimTranspo_ID");
        }

        protected void reimTranGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 0, e, "ReimTranspo_ID");

            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpReimTranspoMap WHERE ReimTranspo_ID = {0}", Convert.ToInt32(e.Values["ReimTranspo_ID"]));
            }
        }

        protected void fixedAllowGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpFixedAllowMap fa = new ACCEDE_T_TraExpFixedAllowMap();
                {
                    fa.FixedAllow_ForP = Convert.ToString(e.NewValues["FixedAllow_ForP"]);
                    fa.FixedAllow_Amount = Convert.ToDecimal(e.NewValues["FixedAllow_Amount"]);
                    fa.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    fa.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpFixedAllowMaps.InsertOnSubmit(fa);
                _DataContext.SubmitChanges();
            }

            RowInsert((ASPxGridView)sender, 1, e, "FixedAllow_ID");
        }

        protected void fixedAllowGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 1, e, "FixedAllow_ID"); 
            
            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpFixedAllowMap WHERE FixedAllow_ID = {0}", Convert.ToInt32(e.Values["FixedAllow_ID"]));
            }
        }

        protected void miscTravelGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpMiscTravelMap mt = new ACCEDE_T_TraExpMiscTravelMap();
                {
                    mt.MiscTravelExp_Type = Convert.ToString(e.NewValues["MiscTravelExp_Type"]);
                    mt.MiscTravelExp_Specify = Convert.ToString(e.NewValues["MiscTravelExp_Specify"]);
                    mt.MiscTravelExp_Amount = Convert.ToDecimal(e.NewValues["MiscTravelExp_Amount"]);
                    mt.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    mt.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpMiscTravelMaps.InsertOnSubmit(mt);
                _DataContext.SubmitChanges();
            }

            RowInsert((ASPxGridView)sender, 2, e, "MiscTravelExp_ID");
        }

        protected void miscTravelGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 2, e, "MiscTravelExp_ID");
            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpMiscTravelMap WHERE MiscTravelExp_ID = {0}", Convert.ToInt32(e.Values["MiscTravelExp_ID"]));
            }
        }

        protected void otherBusGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpOtherBusMap ob = new ACCEDE_T_TraExpOtherBusMap();
                {
                    ob.OtherBusinessExp_Type = Convert.ToString(e.NewValues["OtherBusinessExp_Type"]);
                    ob.OtherBusinessExp_Specify = Convert.ToString(e.NewValues["OtherBusinessExp_Specify"]);
                    ob.OtherBusinessExp_Amount = Convert.ToDecimal(e.NewValues["OtherBusinessExp_Amount"]);
                    ob.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    ob.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpOtherBusMaps.InsertOnSubmit(ob);
                _DataContext.SubmitChanges();
            }

            RowInsert((ASPxGridView)sender, 3, e, "OtherBusinessExp_ID");
        }

        protected void otherBusGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 3, e, "OtherBusinessExp_ID");
            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpOtherBusMap WHERE OtherBusinessExp_ID = {0}", Convert.ToInt32(e.Values["OtherBusinessExp_ID"]));
            }
        }

        protected void entertainmentGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpEntertainmentMap em = new ACCEDE_T_TraExpEntertainmentMap();
                {
                    em.Entertainment_Explain = Convert.ToString(e.NewValues["Entertainment_Explain"]);
                    em.Entertainment_Amount = Convert.ToDecimal(e.NewValues["Entertainment_Amount"]);
                    em.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    em.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpEntertainmentMaps.InsertOnSubmit(em);
                _DataContext.SubmitChanges();
            }

            RowInsert((ASPxGridView)sender, 4, e, "Entertainment_ID");
        }

        protected void entertainmentGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 4, e, "Entertainment_ID");
            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpEntertainmentMap WHERE Entertainment_ID = {0}", Convert.ToInt32(e.Values["Entertainment_ID"]));
            }
        }

        protected void busMealsGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                ACCEDE_T_TraExpBusinessMealMap bm = new ACCEDE_T_TraExpBusinessMealMap();
                {
                    bm.BusinessMeal_Explain = Convert.ToString(e.NewValues["BusinessMeal_Explain"]);
                    bm.BusinessMeal_Amount = Convert.ToDecimal(e.NewValues["BusinessMeal_Amount"]);
                    bm.TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    bm.User_ID = Convert.ToInt32(Session["userID"]);
                }
                _DataContext.ACCEDE_T_TraExpBusinessMealMaps.InsertOnSubmit(bm);
                _DataContext.SubmitChanges();
            }

            RowInsert((ASPxGridView)sender, 5, e, "BusinessMeal_ID");
        }

        protected void busMealsGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            RowDelete((ASPxGridView)sender, 5, e, "BusinessMeal_ID");
            if (Session["expAction"].ToString() == "edit")
            {

                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TraExpBusinessMealMap WHERE BusinessMeal_ID = {0}", Convert.ToInt32(e.Values["BusinessMeal_ID"]));
            }
        }

        public void InsertAttachments(int id)
        {
            try
            {
                string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;

                // Retrieve the DataTable from the session
                DataTable uploadedFilesTable = Session["UploadedFilesTable"] as DataTable;

                if (uploadedFilesTable != null)
                {
                    using (SqlConnection connection = new SqlConnection(connectionString1))
                    {
                        connection.Open();

                        foreach (DataRow row in uploadedFilesTable.Rows)
                        {
                            string fileName = row["FileName"].ToString();
                            byte[] fileAttachment = (byte[])row["FileAttachment"];
                            string fileExtension = row["FileExtension"].ToString();
                            string fileSize = row["FileSize"].ToString();
                            string description = row["Description"].ToString();

                            string query = @"INSERT INTO ITP_T_FileAttachment 
                            (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) 
                            OUTPUT INSERTED.ID 
                            VALUES 
                            (@FileAttachment, @FileName, @Description, @DateUploaded, @App_ID, @Company_ID, @Doc_ID, @Doc_No, @User_ID, @FileExtension, @FileSize, @DocType_Id)";

                            var doctype_id = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE Expense Travel")
                                .Select(x => x.DCT_Id)
                                .FirstOrDefault();

                            using (SqlCommand command = new SqlCommand(query, connection))
                            {
                                command.Parameters.AddWithValue("@FileName", fileName);
                                command.Parameters.AddWithValue("@FileAttachment", fileAttachment);
                                command.Parameters.AddWithValue("@FileExtension", fileExtension);
                                command.Parameters.AddWithValue("@FileSize", fileSize);
                                command.Parameters.AddWithValue("@Description", description);
                                command.Parameters.AddWithValue("@DateUploaded", DateTime.Now);
                                command.Parameters.AddWithValue("@App_ID", 1032);
                                command.Parameters.AddWithValue(
                                    "@Company_ID",
                                    _DataContext.ACCEDE_T_TravelExpenseMains
                                        .Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"]))
                                        .Select(x => x.Company_Id)
                                        .FirstOrDefault()
                                );
                                command.Parameters.AddWithValue("@Doc_ID", id);
                                command.Parameters.AddWithValue("@Doc_No", Session["DocNo"].ToString());
                                command.Parameters.AddWithValue(
                                    "@User_ID",
                                    Session["userID"] != null ? Session["userID"].ToString() : "0"
                                );
                                command.Parameters.AddWithValue("@DocType_Id", doctype_id);

                                int insertedId = (int)command.ExecuteScalar();

                                ACCEDE_T_TravelExpenseDetailsFileAttach docs = new ACCEDE_T_TravelExpenseDetailsFileAttach
                                {
                                    FileAttachment_ID = insertedId,
                                    ExpenseDetails_ID = id
                                };
                                _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(docs);
                            }
                        }

                        // Submit changes to the database context
                        _DataContext.SubmitChanges();
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }

            //string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
            //using (SqlConnection connection = new SqlConnection(connectionString1))
            //{
            //    connection.Open();

            //    // Iterate through rows of the DevExpress GridView
            //    for (int i = 0; i < TraDocuGrid.VisibleRowCount; i++)
            //    {
            //        // Get the values of the current row
            //        string fileName = TraDocuGrid.GetRowValues(i, "FileName")?.ToString();
            //        byte[] fileAttachment = (byte[])TraDocuGrid.GetRowValues(i, "FileAttachment");
            //        string fileExtension = TraDocuGrid.GetRowValues(i, "FileExtension")?.ToString();
            //        string fileSize = TraDocuGrid.GetRowValues(i, "FileSize")?.ToString();
            //        string description = TraDocuGrid.GetRowValues(i, "Description")?.ToString();

            //        // Prepare the SQL query
            //        string query = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) OUTPUT INSERTED.ID VALUES (@FileAttachment, @FileName, @Description, @DateUploaded, @App_ID, @Company_ID, @Doc_ID, @Doc_No, @User_ID, @FileExtension, @FileSize, @DocType_Id)";

            //        var doctype_id = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Select(x => x.DCT_Id).FirstOrDefault();

            //        using (SqlCommand command = new SqlCommand(query, connection))
            //        {
            //            // Add parameters
            //            command.Parameters.AddWithValue("@FileName", fileName);
            //            command.Parameters.AddWithValue("@FileAttachment", fileAttachment);
            //            command.Parameters.AddWithValue("@FileExtension", fileExtension);
            //            command.Parameters.AddWithValue("@FileSize", fileSize);
            //            command.Parameters.AddWithValue("@Description", description);
            //            command.Parameters.AddWithValue("@DateUploaded", DateTime.Now);
            //            command.Parameters.AddWithValue("@App_ID", 1032);
            //            command.Parameters.AddWithValue("@Company_ID", _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).Select(x => x.Company_Id).FirstOrDefault());
            //            command.Parameters.AddWithValue("@Doc_ID", id);
            //            command.Parameters.AddWithValue("@Doc_No", Session["DocNo"].ToString());
            //            command.Parameters.AddWithValue("@User_ID", Session["userID"] != null ? Session["userID"].ToString() : "0");
            //            command.Parameters.AddWithValue("@DocType_Id", doctype_id);

            //            int insertedId = (int)command.ExecuteScalar();

            //            ACCEDE_T_TravelExpenseDetailsFileAttach docs = new ACCEDE_T_TravelExpenseDetailsFileAttach();
            //            {
            //                docs.FileAttachment_ID = insertedId;
            //                docs.ExpenseDetails_ID = id;
            //            };
            //            _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(docs);

            //            // Execute the query
            //            command.ExecuteNonQuery();
            //        }
            //    }
            //}
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

                    InsertAttachments(travExpDetailId);

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
                    InsertMappedData<ACCEDE_T_TravelExpenseDetailsMap>(dataSet.Tables[0], (map, row) =>
                    {
                        map.ReimTranspo_Type1 = row.IsNull("ReimTranspo_Type1") ? string.Empty : Convert.ToString(row["ReimTranspo_Type1"]);
                        map.ReimTranspo_Amount1 = row.IsNull("ReimTranspo_Amount1") ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount1"]);
                        map.ReimTranspo_Type2 = row.IsNull("ReimTranspo_Type2") ? string.Empty : Convert.ToString(row["ReimTranspo_Type2"]);
                        map.ReimTranspo_Amount2 = row.IsNull("ReimTranspo_Amount2") ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount2"]);
                        map.ReimTranspo_Type3 = row.IsNull("ReimTranspo_Type3") ? string.Empty : Convert.ToString(row["ReimTranspo_Type3"]);
                        map.ReimTranspo_Amount3 = row.IsNull("ReimTranspo_Amount3") ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount3"]);
                        map.FixedAllow_ForP = row.IsNull("FixedAllow_ForP") ? string.Empty : Convert.ToString(row["FixedAllow_ForP"]);
                        map.FixedAllow_Amount = row.IsNull("FixedAllow_Amount") ? 0 : Convert.ToDecimal(row["FixedAllow_Amount"]);
                        map.MiscTravel_Type = row.IsNull("MiscTravel_Type") ? string.Empty : Convert.ToString(row["MiscTravel_Type"]);
                        map.MiscTravel_Specify = row.IsNull("MiscTravel_Specify") ? string.Empty : Convert.ToString(row["MiscTravel_Specify"]);
                        map.MiscTravel_Amount = row.IsNull("MiscTravel_Amount") ? 0 : Convert.ToDecimal(row["MiscTravel_Amount"]);
                        map.Entertainment_Explain = row.IsNull("Entertainment_Explain") ? string.Empty : Convert.ToString(row["Entertainment_Explain"]);
                        map.Entertainment_Amount = row.IsNull("Entertainment_Amount") ? 0 : Convert.ToDecimal(row["Entertainment_Amount"]);
                        map.BusMeals_Explain = row.IsNull("BusMeals_Explain") ? string.Empty : Convert.ToString(row["BusMeals_Explain"]);
                        map.BusMeals_Amount = row.IsNull("BusMeals_Amount") ? 0 : Convert.ToDecimal(row["BusMeals_Amount"]);
                        map.OtherBus_Type = row.IsNull("OtherBus_Type") ? string.Empty : Convert.ToString(row["OtherBus_Type"]);
                        map.OtherBus_Specify = row.IsNull("OtherBus_Specify") ? string.Empty : Convert.ToString(row["OtherBus_Specify"]);
                        map.OtherBus_Amount = row.IsNull("OtherBus_Amount") ? 0 : Convert.ToDecimal(row["OtherBus_Amount"]);
                        map.TravelExpenseDetail_ID = travExpDetailId;
                    });

                    //InsertMappedData<ACCEDE_T_TraExpReimTranspoMap>(dataSet.Tables[0], (map, row) =>
                    //{
                    //    map.ReimTranspo_Type = Convert.ToInt32(row["ReimTranspo_Type"]);
                    //    map.ReimTranspo_Amount = Convert.ToDecimal(row["ReimTranspo_Amount"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

                    //InsertMappedData<ACCEDE_T_TraExpFixedAllowMap>(dataSet.Tables[1], (map, row) =>
                    //{
                    //    map.FixedAllow_ForP = Convert.ToString(row["FixedAllow_ForP"]);
                    //    map.FixedAllow_Amount = Convert.ToDecimal(row["FixedAllow_Amount"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

                    //InsertMappedData<ACCEDE_T_TraExpMiscTravelMap>(dataSet.Tables[2], (map, row) =>
                    //{
                    //    map.MiscTravelExp_Type = Convert.ToInt32(row["MiscTravelExp_Type"]);
                    //    map.MiscTravelExp_Amount = Convert.ToDecimal(row["MiscTravelExp_Amount"]);
                    //    map.MiscTravelExp_Specify = Convert.ToString(row["MiscTravelExp_Specify"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

                    //InsertMappedData<ACCEDE_T_TraExpOtherBusMap>(dataSet.Tables[3], (map, row) =>
                    //{
                    //    map.OtherBusinessExp_Type = Convert.ToInt32(row["OtherBusinessExp_Type"]);
                    //    map.OtherBusinessExp_Amount = Convert.ToDecimal(row["OtherBusinessExp_Amount"]);
                    //    map.OtherBusinessExp_Specify = Convert.ToString(row["OtherBusinessExp_Specify"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

                    //InsertMappedData<ACCEDE_T_TraExpEntertainmentMap>(dataSet.Tables[4], (map, row) =>
                    //{
                    //    map.Entertainment_Explain = Convert.ToString(row["Entertainment_Explain"]);
                    //    map.Entertainment_Amount = Convert.ToDecimal(row["Entertainment_Amount"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

                    //InsertMappedData<ACCEDE_T_TraExpBusinessMealMap>(dataSet.Tables[5], (map, row) =>
                    //{
                    //    map.BusinessMeal_Explain = Convert.ToString(row["BusinessMeal_Explain"]);
                    //    map.BusinessMeal_Amount = Convert.ToDecimal(row["BusinessMeal_Amount"]);
                    //    map.TravelExpenseDetail_ID = travExpDetailId;
                    //});

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
                throw;
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
            dsDoc = (DataSet)Session["DataSetDoc"];
            foreach (DataTable table in ds.Tables)
            {
                table.Clear();
            }
            foreach (DataTable table in dsDoc.Tables)
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
                ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlExpDetailsMap));

                //ds.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlRTMap));
                //ds.Tables[1].Merge(GetDataTableFromSqlDataSource(SqlFAMap));
                //ds.Tables[2].Merge(GetDataTableFromSqlDataSource(SqlMTMap));
                //ds.Tables[3].Merge(GetDataTableFromSqlDataSource(SqlOBMap));
                //ds.Tables[4].Merge(GetDataTableFromSqlDataSource(SqlEMap));
                //ds.Tables[5].Merge(GetDataTableFromSqlDataSource(SqlBMMap));

                dsDoc.Tables[0].Merge(GetDataTableFromSqlDataSource(SqlDocs2));
            }

            // Bind the tables to the grids
            ASPxGridView22.DataSource = ds.Tables[0];
            ASPxGridView22.DataBind();

            //reimTranGrid.DataSource = ds.Tables[0];
            //fixedAllowGrid.DataSource = ds.Tables[1];
            //miscTravelGrid.DataSource = ds.Tables[2];
            //otherBusGrid.DataSource = ds.Tables[3];
            //entertainmentGrid.DataSource = ds.Tables[4];
            //busMealsGrid.DataSource = ds.Tables[5];
            //TraDocuGrid.DataSource = dsDoc.Tables[0];

            //// Data bind to refresh the grids
            //reimTranGrid.DataBind();
            //fixedAllowGrid.DataBind();
            //miscTravelGrid.DataBind();
            //otherBusGrid.DataBind();
            //entertainmentGrid.DataBind();
            //busMealsGrid.DataBind();
            //TraDocuGrid.DataBind();

            //reimTranGrid.JSProperties["cpSummary"] = reimTranGrid.GetTotalSummaryValue(reimTranGrid.TotalSummary["ReimTranspo_Amount"]);
            //fixedAllowGrid.JSProperties["cpSummary"] = fixedAllowGrid.GetTotalSummaryValue(fixedAllowGrid.TotalSummary["FixedAllow_Amount"]);
            //miscTravelGrid.JSProperties["cpSummary"] = miscTravelGrid.GetTotalSummaryValue(miscTravelGrid.TotalSummary["MiscTravelExp_Amount"]);
            //otherBusGrid.JSProperties["cpSummary"] = otherBusGrid.GetTotalSummaryValue(otherBusGrid.TotalSummary["OtherBusinessExp_Amount"]);
            //entertainmentGrid.JSProperties["cpSummary"] = entertainmentGrid.GetTotalSummaryValue(entertainmentGrid.TotalSummary["Entertainment_Amount"]);
            //busMealsGrid.JSProperties["cpSummary"] = busMealsGrid.GetTotalSummaryValue(busMealsGrid.TotalSummary["BusinessMeal_Amount"]);
        }

        protected void wfCallback_Callback(object sender, CallbackEventArgsBase e)
        {
            var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();

            Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == mainExp.Company_Id && x.App_Id == 1032 && x.IsRA == null && Convert.ToDecimal(e.Parameter) >= x.Minimum && Convert.ToDecimal(e.Parameter) <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault()) ?? null ;

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
                var rfp_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.isTravel == true);
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
                    var rfpReim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.Status != 4).Where(x => x.IsExpenseReim == true).Where(x => x.isTravel == true);
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

        protected void TraDocuGrid_RowDeleting(object sender, ASPxDataDeletingEventArgs e)
        {
            int i = TraDocuGrid.FindVisibleIndexByKeyValue(e.Keys[TraDocuGrid.KeyFieldName]);
            //Control c = DocuGrid.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            dsDoc = (DataSet)Session["DataSetDoc"];
            dsDoc.Tables[0].Rows.Remove(dsDoc.Tables[0].Rows.Find(e.Keys[TraDocuGrid.KeyFieldName]));

            if (Session["expAction"].ToString() == "edit")
            {
                _DataContext.ExecuteCommand("DELETE FROM ITP_T_FileAttachment WHERE ID = {0}", Convert.ToInt32(e.Values["ID"]));
                _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TravelExpenseDetailsFileAttach WHERE FileAttachment_ID = {0}", Convert.ToInt32(e.Values["ID"]));
            }
        }

        protected void TraDocuGrid_RowUpdating(object sender, ASPxDataUpdatingEventArgs e)
        {
            if (Convert.ToString(Session["expAction"]) == "edit")
            {
                _DataContext.ExecuteCommand("UPDATE ITP_T_FileAttachment SET Description = {0} WHERE ID = {1}", Convert.ToString(e.NewValues["Description"]), Convert.ToInt32(e.Keys["ID"]));
            }

            dsDoc = (DataSet)Session["DataSetDoc"];
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

        protected void ASPxGridView22_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "ReimTranspo_Amount1" || e.Column.FieldName == "ReimTranspo_Amount2" || e.Column.FieldName == "ReimTranspo_Amount3" || e.Column.FieldName == "FixedAllow_Amount" || e.Column.FieldName == "MiscTravel_Amount" || e.Column.FieldName == "Entertainment_Amount" || e.Column.FieldName == "BusMeals_Amount" || e.Column.FieldName == "OtherBus_Amount")
            {
                if (Convert.ToString(e.Value) == "0" || Convert.ToString(e.Value) == "0.00" )
                    e.DisplayText = string.Empty;
            }
        }

        protected void CAGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            CAGrid.DataBind();
        }

        protected void ExpenseGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            ExpenseGrid.DataBind();
        }
    }
}