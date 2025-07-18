using DevExpress.Web;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DevExpress.XtraPrinting.Native.ExportOptionsPropertiesNames;

namespace DX_WebTemplate
{
    public partial class TravelExpenseNew : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    var mainExp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["TravelExp_Id"])).FirstOrDefault();
                    Session["statusid"] = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").Select(x => x.STS_Id).FirstOrDefault();
                    Session["appdoctype"] = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).Select(x => x.DCT_Id).FirstOrDefault();

                    if (mainExp != null)
                    {
                        Session["isForeignTravel"] = mainExp.ForeignDomestic == "Foreign" ? 1 : 0;
                        Session["ford"] = mainExp.ForeignDomestic;
                        Session["currency"] = mainExp.ForeignDomestic == "Domestic" ? '₱' : mainExp.ForeignDomestic == "Foreign" ? '$' : ' ';
                        var status = _DataContext.ITP_S_Status.Where(x => x.STS_Id == Convert.ToInt32(mainExp.Status)).Select(x => x.STS_Description).FirstOrDefault() ?? string.Empty;

                        if (Convert.ToString(Session["main_action"]) == "edit")
                            ExpenseEditForm.Items[0].Caption = "Update Travel Expense Document No.: " + mainExp.Doc_No;
                        else
                            ExpenseEditForm.Items[0].Caption = "New Travel Expense";

                        Session["DocNo"] = mainExp.Doc_No.ToString();
                        Session["Employee_Id"] = mainExp.Employee_Id.ToString();

                        timedepartTE.DateTime = DateTime.Parse(mainExp.Time_Departed.ToString());
                        timearriveTE.DateTime = DateTime.Parse(mainExp.Time_Arrived.ToString());

                        SqlMain.SelectParameters["ID"].DefaultValue = mainExp.ID.ToString();
                        SqlEmpName.SelectParameters["EmpCode"].DefaultValue = mainExp.Employee_Id.ToString();
                        SqlWFCompany.SelectParameters["WASSId"].DefaultValue = mainExp.Company_Id.ToString();
                        SqlWFDepartment.SelectParameters["ID"].DefaultValue = mainExp.Dep_Code.ToString();
                        SqlLocBranch.SelectParameters["Comp_Id"].DefaultValue = mainExp.ChargedToComp.ToString();
                        SqlAllCompany.SelectParameters["WASSId"].DefaultValue = Convert.ToString(mainExp.ChargedToComp);
                        SqlAllDepartment.SelectParameters["Company_ID"].DefaultValue = Convert.ToString(mainExp.ChargedToComp);

                        SqlEmpName.DataBind();
                        SqlWFCompany.DataBind();
                        SqlWFDepartment.DataBind();
                        SqlLocBranch.DataBind();
                        SqlAllCompany.DataBind();
                        SqlAllDepartment.DataBind();

                        ASPxGridView22.DataSource = ds.Tables[0];
                        ASPxGridView22.DataBind();

                        TraDocuGrid.DataSource = dsDoc.Tables[0];
                        TraDocuGrid.DataBind();

                        InitializeExpCA(mainExp);
                    }
                    else
                        Response.Redirect("~/Logon.aspx");
                }
            }
            catch (Exception ex)
            {
                Response.Write("An error occurred: " + ex.Message);
                Response.Redirect("~/Logon.aspx");
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
                    var remItem = ExpenseEditForm.FindItemOrGroupByName("remItem") as LayoutItem;
                    var reimDetails = ExpenseEditForm.FindItemOrGroupByName("reimDetails") as LayoutItem;

                    var reim = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"]) && x.isTravel == true && x.IsExpenseReim == true).FirstOrDefault();

                    if (reim != null)
                    {
                        reimDetails.ClientVisible = true;
                        reimTB.Text = Convert.ToString(reim.RFP_DocNum);
                    }

                    var travelExpId = Convert.ToInt32(Session["TravelExp_Id"]);
                    var userId = Convert.ToString(Session["userID"]);

                    var totalca = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == travelExpId && x.isTravel == true && x.TranType == 1 && x.User_ID == userId)
                        .Sum(x => (decimal?)x.Amount) ?? 0;

                    var totalexp = _DataContext.ACCEDE_T_TravelExpenseDetails
                        .Where(x => x.TravelExpenseMain_ID == travelExpId)
                        .Sum(x => (decimal?)x.Total_Expenses) ?? 0;

                    var countCA = _DataContext.ACCEDE_T_RFPMains
                        .Count(x => x.Exp_ID == travelExpId && x.isTravel == true && x.TranType == 1 && x.User_ID == userId);

                    var countExp = _DataContext.ACCEDE_T_TravelExpenseDetails
                        .Count(x => x.TravelExpenseMain_ID == travelExpId);

                    var expType = countCA > 0 ? "1" : countCA == 0 && countExp > 0 ? "2" : "1";

                    if (totalexp > totalca)
                    {
                        remItem.ClientVisible = false;
                        due_lbl.Caption = "Due To Employee";
                        if (reim != null)
                            reimItem.ClientVisible = false;
                        else
                            reimItem.ClientVisible = true;
                    }
                    else if (totalca > totalexp)
                    {
                        due_lbl.Caption = "Due To Company";
                        reimItem.ClientVisible = false;
                        remItem.ClientVisible = true;
                    }
                    else
                    {
                        due_lbl.Caption = "Due To Company";
                        reimItem.ClientVisible = false;
                        remItem.ClientVisible = false;
                    }

                    drpdown_expenseType.Value = expType;
                    lbl_caTotal.Text = Convert.ToString(Session["currency"]) + totalca.ToString("N2");
                    lbl_expenseTotal.Text = Convert.ToString(Session["currency"]) + totalexp.ToString("N2");
                    lbl_dueTotal.Text = totalexp > totalca ? "(" + Convert.ToString(Session["currency"]) + "" + (totalexp - totalca).ToString("N2") + ")" : Convert.ToString(Session["currency"]) + (totalca - totalexp).ToString("N2");

                    var totExpCA = totalexp > totalca ? Convert.ToDecimal(totalexp - totalca) : Convert.ToDecimal(totalca - totalexp);

                    //// - - Setting Line Manager Workflow - - ////

                    var wfmapping = _DataContext.vw_ACCEDE_I_WFMappings.Where(x => x.UserId == Convert.ToString(mainExp.Employee_Id) && x.Company_Id == Convert.ToInt32(mainExp.Company_Id)).FirstOrDefault();

                    if (wfmapping != null)
                    {
                        Session["mainwfid"] = Convert.ToString(wfmapping.WF_ID);
                    }
                    else
                    {
                        Session["mainwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.Company_Id && x.IsRA == true && totExpCA >= x.Minimum && totExpCA <= x.Maximum).Select(x => x.WF_Id).FirstOrDefault());
                    }


                    //// - - Setting FAP workflow - - ////
                    if (Convert.ToString(Session["ford"]) == "Foreign")
                    {
                        Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.ChargedToComp && x.Description.Contains("Travel Foreign FAP>Manager>VP>CFO/PRES") && (x.IsRA == false || x.IsRA == null)).Select(x => x.WF_Id).FirstOrDefault());
                    }
                    else
                    {
                        Session["fapwfid"] = Convert.ToString(_DataContext.ITP_S_WorkflowHeaders.Where(x => x.App_Id == 1032 && x.Company_Id == mainExp.ChargedToComp && x.Description.Contains("Travel Domestic FAP>Manager>VP") && (x.IsRA == false || x.IsRA == null)).Select(x => x.WF_Id).FirstOrDefault());
                    }

                    Debug.WriteLine("Main Workflow ID: " + Session["mainwfid"]);
                    Debug.WriteLine("FAP Workflow ID: " + Session["fapwfid"]);

                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();
                    SqlFAPWFDetails.SelectParameters["WF_Id"].DefaultValue = Session["fapwfid"].ToString();

                    SqlWF.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();
                    SqlWFDetails.SelectParameters["WF_Id"].DefaultValue = Session["mainwfid"].ToString();

                    SqlWFDetails.DataBind();
                    SqlFAPWFDetails.DataBind();
                }
            }
            catch (Exception)
            {
                Response.Redirect("~/Logon.aspx");
            }
        }


        DataSet ds = null;
        DataSet dsDoc = null;

        protected void ExpenseEditForm_Init(object sender, EventArgs e)
        {
            if (!IsPostBack || (Session["DataSet"] == null))
            {
                ds = new DataSet();
                ds.Tables.AddRange(new[]
                {
                    CreateDataTable("TravelExpenseDetailMap_ID", "LocParticulars", "ReimTranspo_Type1", "ReimTranspo_Amount1", "FixedAllow_ForP", "FixedAllow_Remarks", "FixedAllow_Amount", "MiscTravel_Type", "MiscTravel_Specify", "MiscTravel_Amount", "Entertainment_Explain", "Entertainment_Amount", "BusMeals_Explain", "BusMeals_Amount")
                });
                Session["DataSet"] = ds;
            }
            else
                ds = (DataSet)Session["DataSet"];


            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                dsDoc.Tables.AddRange(new[]
                {
                    CreateDataTable("ID", "FileName", "FileAttachment", "FileExtension", "FileSize", "Description")
                });
                Session["DataSetDoc"] = dsDoc;
            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
        }

        private DataTable CreateDataTable(string idColumnName, params string[] columnNames)
        {
            var table = new DataTable();
            table.Columns.Add(idColumnName, typeof(int));
            foreach (var columnName in columnNames)
            {
                Type columnType = columnName.Contains("Amount") ? typeof(decimal) : columnName.Contains("Attachment") ? typeof(byte[]) : typeof(string);
                table.Columns.Add(columnName, columnType);
            }
            table.PrimaryKey = new[] { table.Columns[idColumnName] };
            return table;
        }


        [WebMethod]
        public static bool AddCA_AJAX(List<int> selectedValues)
        {
            try
            {
                TravelExpenseNew accede = new TravelExpenseNew();
                return accede.AddCA(selectedValues);
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public bool AddCA(List<int> selectedIds)
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

                return true;
            }
            catch (Exception ex)
            {
                return false;
                throw;
            }
        }


        [WebMethod]
        public static bool RemoveFromExp_AJAX(int item_id, string btnCommand)
        {
            TravelExpenseNew exp = new TravelExpenseNew();

            return exp.RemoveFromExp(item_id, btnCommand);
        }

        public bool RemoveFromExp(int item_id, string btnCommand)
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

                return true;
            }
            catch (Exception ex)
            {
                return false;
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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense Travel").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                    docs.App_ID = 1032;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(chargedCB.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                }
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                _DataContext.SubmitChanges();

                ACCEDE_T_TravelExpenseDetailsFileAttach fileattach = new ACCEDE_T_TravelExpenseDetailsFileAttach();
                {
                    fileattach.FileAttachment_ID = docs.ID;
                    fileattach.DocumentType = "main";
                }
                _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(fileattach);
                _DataContext.SubmitChanges();
            }
        }


        [WebMethod]
        public static object DisplayExpDetailsAJAX(int expDetailID)
        {
            TravelExpenseAdd exp = new TravelExpenseAdd();
            return exp.DisplayExpDetails(expDetailID);
        }

        public object DisplayExpDetails(int expDetailID)
        {
            var exp_details = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == expDetailID).FirstOrDefault();

            var travelDate = Convert.ToDateTime(exp_details.TravelExpenseDetail_Date).ToString("MM/dd/yyyy hh:mm:ss");
            var totalExp = exp_details.Total_Expenses.Value.ToString("N2");

            Session["ExpDetailsID"] = expDetailID.ToString();

            return new { travelDate, totalExp };
        }


        [WebMethod]
        public static void AddTravelExpenseDetailsAJAX(DateTime travelDate, string totalExp)
        {
            TravelExpenseNew exp = new TravelExpenseNew();
            exp.AddTravelExpenseDetails(travelDate, totalExp);
        }

        public void AddTravelExpenseDetails(DateTime travelDate, string totalExp)
        {
            try
            {
                var trav = new ACCEDE_T_TravelExpenseDetail
                {
                    TravelExpenseDetail_Date = travelDate,
                    TravelExpenseMain_ID = Convert.ToInt32(Session["TravelExp_Id"]),
                    Total_Expenses = Convert.ToDecimal(totalExp)
                };
                _DataContext.ACCEDE_T_TravelExpenseDetails.InsertOnSubmit(trav);
                _DataContext.SubmitChanges();

                var travExpDetailId = trav.TravelExpenseDetail_ID;
                var dataSet = (DataSet)Session["DataSet"];
                var dataSetDoc = (DataSet)Session["DataSetDoc"];

                // Define a helper method for adding mapped data
                void InsertMappedData<T>(DataTable table, Action<T, DataRow> mapAction) where T : class, new()
                {
                    foreach (DataRow row in table.Rows)
                    {
                        // Check if the row is empty (all relevant fields are either null, empty, or zero)
                        bool isEmptyRow = true;
                        foreach (DataColumn column in table.Columns)
                        {
                            object value = row[column];
                            if (value != DBNull.Value || !string.IsNullOrWhiteSpace(value.ToString()) || Convert.ToDecimal(value) != 0)
                            {
                                isEmptyRow = false;
                                break;
                            }
                        }

                        // Skip inserting the empty row
                        if (isEmptyRow)
                            continue;

                        var map = new T();
                        mapAction(map, row);
                        _DataContext.GetTable<T>().InsertOnSubmit(map);
                    }
                }

                // Insert all mapped allocations using the helper method
                InsertMappedData<ACCEDE_T_TravelExpenseDetailsMap>(dataSet.Tables[0], (map, row) =>
                {
                    map.LocParticulars = row.IsNull("LocParticulars") ? string.Empty : Convert.ToString(row["LocParticulars"]);
                    map.ReimTranspo_Type1 = row.IsNull("ReimTranspo_Type1") ? string.Empty : Convert.ToString(row["ReimTranspo_Type1"]);
                    map.ReimTranspo_Amount1 = row.IsNull("ReimTranspo_Amount1") ? 0 : Convert.ToDecimal(row["ReimTranspo_Amount1"]);
                    map.FixedAllow_ForP = row.IsNull("FixedAllow_ForP") ? string.Empty : Convert.ToString(row["FixedAllow_ForP"]);
                    map.FixedAllow_Amount = row.IsNull("FixedAllow_Amount") ? 0 : Convert.ToDecimal(row["FixedAllow_Amount"]);
                    map.FixedAllow_Remarks = row.IsNull("FixedAllow_Remarks") ? string.Empty : Convert.ToString(row["FixedAllow_Remarks"]);
                    map.MiscTravel_Type = row.IsNull("MiscTravel_Type") ? string.Empty : Convert.ToString(row["MiscTravel_Type"]);
                    map.MiscTravel_Specify = row.IsNull("MiscTravel_Specify") ? string.Empty : Convert.ToString(row["MiscTravel_Specify"]);
                    map.MiscTravel_Amount = row.IsNull("MiscTravel_Amount") ? 0 : Convert.ToDecimal(row["MiscTravel_Amount"]);
                    map.Entertainment_Explain = row.IsNull("Entertainment_Explain") ? string.Empty : Convert.ToString(row["Entertainment_Explain"]);
                    map.Entertainment_Amount = row.IsNull("Entertainment_Amount") ? 0 : Convert.ToDecimal(row["Entertainment_Amount"]);
                    map.BusMeals_Explain = row.IsNull("BusMeals_Explain") ? string.Empty : Convert.ToString(row["BusMeals_Explain"]);
                    map.BusMeals_Amount = row.IsNull("BusMeals_Amount") ? 0 : Convert.ToDecimal(row["BusMeals_Amount"]);
                    map.TravelExpenseDetail_ID = travExpDetailId;
                });

                List<ITP_T_FileAttachment> insertedAttachments = new List<ITP_T_FileAttachment>();

                InsertMappedData<ITP_T_FileAttachment>(dataSetDoc.Tables[0], (map, row) =>
                {
                    map.FileName = row.IsNull("FileName") ? string.Empty : Convert.ToString(row["FileName"]);
                    map.FileAttachment = row.IsNull("FileAttachment") ? null : new System.Data.Linq.Binary((byte[])row["FileAttachment"]);
                    map.FileExtension = row.IsNull("FileExtension") ? string.Empty : Convert.ToString(row["FileExtension"]);
                    map.FileSize = row.IsNull("FileSize") ? string.Empty : Convert.ToString(row["FileSize"]);
                    map.Description = row.IsNull("Description") ? string.Empty : Convert.ToString(row["Description"]);
                    map.App_ID = 1032;

                    insertedAttachments.Add(map); // Track the inserted object
                });

                _DataContext.SubmitChanges(); // IDs are now generated

                foreach (var item in insertedAttachments)
                {
                    Console.WriteLine("Inserted ID: " + item.ID); // Replace ID with your actual PK name

                    var file = new ACCEDE_T_TravelExpenseDetailsFileAttach
                    {
                        FileAttachment_ID = item.ID,
                        ExpenseDetails_ID = travExpDetailId,
                        DocumentType = "sub"
                    };
                    _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(file);
                    _DataContext.SubmitChanges();
                }
            }
            catch (Exception)
            {

                throw;
            }
        }

        [WebMethod]
        public static void UpdateTravelExpenseDetailsAJAX(DateTime travelDate, string totalExp)
        {
            TravelExpenseNew exp = new TravelExpenseNew();
            exp.UpdateTravelExpenseDetails(travelDate, totalExp);
        }

        public void UpdateTravelExpenseDetails(DateTime travelDate, string totalExp)
        {
            try
            {
                var updateExpDetail = _DataContext.ACCEDE_T_TravelExpenseDetails
                     .Where(x => x.TravelExpenseDetail_ID == Convert.ToInt32(Session["ExpDetailsID"]));

                foreach (ACCEDE_T_TravelExpenseDetail ex in updateExpDetail)
                {
                    //.IsExpenseCA = false;
                    ex.Total_Expenses = Convert.ToDecimal(totalExp);
                    ex.TravelExpenseDetail_Date = travelDate;
                    ex.TravelExpenseMain_ID = Convert.ToInt32(Session["TravelExp_Id"]);
                }
                _DataContext.SubmitChanges();
            }
            catch (Exception)
            {

                throw;
            }
        }

        protected void TraUploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {

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
            Session["DataSetDoc"] = ImgDS;
            TraDocuGrid.DataSource = ImgDS.Tables[0];
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

        protected void ASPxGridView22_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            bool isEmptyRow = true;

            foreach (var key in e.NewValues.Keys)
            {
                if (e.NewValues[key] != null && !string.IsNullOrWhiteSpace(e.NewValues[key].ToString()))
                {
                    isEmptyRow = false;
                    break;
                }
            }

            if (isEmptyRow)
            {
                e.Cancel = true;
                return;
            }

            ds = (DataSet)Session["DataSet"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? ds.Tables[0] : ds.Tables[0];
            DataRow row = dataTable.NewRow();
            e.NewValues["TravelExpenseDetailMap_ID"] = GetNewId1();

            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
            {
                if (enumerator.Key.ToString() != "Count")
                {
                    row[enumerator.Key.ToString()] = enumerator.Value ?? DBNull.Value;
                }
            }

            gridView.CancelEdit();
            e.Cancel = true;
            dataTable.Rows.Add(row);
        }

        protected void ASPxGridView22_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            ds = (DataSet)Session["DataSet"];
            ASPxGridView gridView = (ASPxGridView)sender;
            DataTable dataTable = gridView.GetMasterRowKeyValue() != null ? ds.Tables[0] : ds.Tables[0];
            DataRow row = dataTable.Rows.Find(e.Keys[0]);

            // Check if all new values are empty or null
            bool hasValidData = false;
            foreach (var key in e.NewValues.Keys)
            {
                var value = e.NewValues[key];
                if (value != null && !string.IsNullOrWhiteSpace(value.ToString()))
                {
                    hasValidData = true;
                    break;
                }
            }

            // If all values are empty, cancel the update
            if (!hasValidData)
            {
                e.Cancel = true;
                gridView.CancelEdit();
                return;
            }

            // Update the row in the DataTable
            IDictionaryEnumerator enumerator = e.NewValues.GetEnumerator();
            enumerator.Reset();
            while (enumerator.MoveNext())
                row[enumerator.Key.ToString()] = enumerator.Value ?? DBNull.Value;

            gridView.CancelEdit();
            e.Cancel = true;
        }

        protected void ASPxGridView22_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            int i = ASPxGridView22.FindVisibleIndexByKeyValue(e.Keys[ASPxGridView22.KeyFieldName]);
            Control c = ASPxGridView22.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            ds = (DataSet)Session["DataSet"];
            ds.Tables[0].Rows.Remove(ds.Tables[0].Rows.Find(e.Keys[ASPxGridView22.KeyFieldName]));
        }

        protected void TraUploadController1_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            foreach (var file in TraUploadController1.UploadedFiles)
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
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(chargedCB.Value);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                }
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                _DataContext.SubmitChanges();

                ACCEDE_T_TravelExpenseDetailsFileAttach docs2 = new ACCEDE_T_TravelExpenseDetailsFileAttach();
                {
                    docs2.FileAttachment_ID = docs.ID;
                    docs2.ExpenseDetails_ID = Convert.ToInt32(Session["ExpDetailsID"]);
                    docs2.DocumentType = "sub";
                }
                _DataContext.ACCEDE_T_TravelExpenseDetailsFileAttaches.InsertOnSubmit(docs2);
            }
            _DataContext.SubmitChanges();
        }

        protected void ASPxGridView23_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            _DataContext.ExecuteCommand("DELETE FROM ACCEDE_T_TravelExpenseDetailsMap WHERE TravelExpenseDetailMap_ID = {0}", Convert.ToInt32(e.Values["TravelExpenseDetailMap_ID"]));
        }

        protected void ASPxGridView23_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            ACCEDE_T_TravelExpenseDetailsMap td = new ACCEDE_T_TravelExpenseDetailsMap
            {
                LocParticulars = Convert.ToString(e.NewValues["LocParticulars"]),
                ReimTranspo_Type1 = Convert.ToString(e.NewValues["ReimTranspo_Type1"]),
                ReimTranspo_Amount1 = Convert.ToDecimal(e.NewValues["ReimTranspo_Amount1"]),
                FixedAllow_ForP = Convert.ToString(e.NewValues["FixedAllow_ForP"]),
                FixedAllow_Remarks = Convert.ToString(e.NewValues["FixedAllow_Remarks"]),
                FixedAllow_Amount = Convert.ToDecimal(e.NewValues["FixedAllow_Amount"]),
                MiscTravel_Type = Convert.ToString(e.NewValues["MiscTravel_Type"]),
                MiscTravel_Specify = Convert.ToString(e.NewValues["MiscTravel_Specify"]),
                MiscTravel_Amount = Convert.ToDecimal(e.NewValues["MiscTravel_Amount"]),
                Entertainment_Explain = Convert.ToString(e.NewValues["Entertainment_Explain"]),
                Entertainment_Amount = Convert.ToDecimal(e.NewValues["Entertainment_Amount"]),
                BusMeals_Explain = Convert.ToString(e.NewValues["BusMeals_Explain"]),
                BusMeals_Amount = Convert.ToDecimal(e.NewValues["BusMeals_Amount"]),
                TravelExpenseDetail_ID = Convert.ToInt32(Session["ExpDetailsID"])
            };

            _DataContext.ACCEDE_T_TravelExpenseDetailsMaps.InsertOnSubmit(td);
            _DataContext.SubmitChanges();
        }

        protected void ASPxGridView23_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            e.NewValues["TravelExpenseDetail_ID"] = Convert.ToInt32(Session["ExpDetailsID"]);
        }

        protected void ExpenseGrid_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
        {
            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Fixed Allowances")
            {
                var amount = Convert.ToDecimal(_DataContext.ACCEDE_T_TravelExpenseDetailsMaps.Where(or => or.TravelExpenseDetail_ID == Convert.ToInt32(e.Value)).Sum(or => or.FixedAllow_Amount));

                if (amount.ToString() == "0.00" || string.IsNullOrEmpty(amount.ToString()))
                    e.DisplayText = "0.00";
                else
                {
                    e.DisplayText = amount.ToString("N");
                }
            }

            if (e.Column.FieldName == "TravelExpenseDetail_ID" && e.Column.Caption == "Other Travel Expenses")
            {
                var travelExpenseDetailId = Convert.ToInt32(e.Value);
                var total = _DataContext.ACCEDE_T_TravelExpenseDetailsMaps
                .Where(or => or.TravelExpenseDetail_ID == travelExpenseDetailId)
                .DefaultIfEmpty()
                .Select(or =>
                    (or.ReimTranspo_Amount1 ?? 0) +
                    (or.ReimTranspo_Amount2 ?? 0) +
                    (or.ReimTranspo_Amount3 ?? 0) +
                    (or.MiscTravel_Amount ?? 0) +
                    (or.Entertainment_Amount ?? 0) +
                    (or.BusMeals_Amount ?? 0) +
                    (or.OtherBus_Amount ?? 0)
                )// this avoids the null issue
                .Sum();

                e.DisplayText = total == 0 ? "0.00" : total.ToString("N");
            }

            if (e.Column.Caption == "#")
            {
                e.DisplayText = (e.VisibleIndex + 1).ToString();
            }
        }

        [WebMethod]
        public static bool RedirectToRFPDetailsAJAX(string rfpDoc)
        {
            TravelExpenseNew exp = new TravelExpenseNew();
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

        [WebMethod]
        public static bool AddRFPReimburseAJAX(string empname, DateTime reportdate, string company, string department, string purpose, string amount, string chargedComp, string chargedDept, string locbranch, string ford, string wf, string fapwf)
        {
            TravelExpenseAdd exp = new TravelExpenseAdd();

            return exp.AddRFPReimburse(empname, reportdate, company, department, purpose, amount, chargedComp, chargedDept, locbranch, ford, wf, fapwf);
        }

        public bool AddRFPReimburse(string empname, DateTime reportdate, string company, string department, string purpose, string amount, string chargedComp, string chargedDept, string locbranch, string ford, string wf, string fapwf)
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
                    rfp.SAPCostCenter = Convert.ToString(_DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.Company_ID == Convert.ToInt32(chargedComp) && x.ID == Convert.ToInt32(chargedDept)).Select(x => x.SAP_CostCenter).FirstOrDefault());
                    rfp.Payee = empname;
                    rfp.Amount = Convert.ToDecimal(Math.Abs(totalReim));
                    rfp.Exp_ID = expMain.ID;
                    rfp.TranType = 2;
                    rfp.IsExpenseReim = true;
                    rfp.isTravel = true;
                    rfp.DateCreated = DateTime.Now;
                    rfp.RFP_DocNum = docNum.ToString();
                    rfp.User_ID = Session["userID"].ToString();
                    rfp.Status = expMain.Status;
                    rfp.ChargedTo_CompanyId = Convert.ToInt32(chargedComp);
                    rfp.ChargedTo_DeptId = Convert.ToInt32(chargedDept);
                    rfp.Comp_Location_Id = Convert.ToInt32(locbranch);
                    rfp.isForeignTravel = ford == "Foreign" ? true : false;
                    rfp.WF_Id = Convert.ToInt32(wf);
                    rfp.FAPWF_Id = Convert.ToInt32(fapwf);
                    rfp.Currency = Convert.ToString(Session["ford"]) == "Domestic" ? "PHP" : "USD";
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
        public static object SaveSubmitTravelExpenseAJAX(string empname, DateTime reportdate, string company, string department, string chargedComp, string chargedDept, DateTime datefrom, DateTime dateto, DateTime timedepart, DateTime timearrive, string trip, string ford, string purpose, string expenseType, string locbranch, string arNo, string btnaction)
        {
            TravelExpenseNew tra = new TravelExpenseNew();
            return tra.SaveSubmitTravelExpense(empname, reportdate, company, department, chargedComp, chargedDept, datefrom, dateto, timedepart, timearrive, trip, ford, purpose, expenseType, locbranch, arNo, btnaction);
        }

        public object SaveSubmitTravelExpense(string empname, DateTime reportdate, string company, string department, string chargedComp, string chargedDept, DateTime datefrom, DateTime dateto, DateTime timedepart, DateTime timearrive, string trip, string ford, string purpose, string expenseType, string locbranch, string arNo, string btnaction)
        {
            try
            {
                var expCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["TravelExp_Id"])).Where(x => x.IsExpenseCA == true).Where(x => x.isTravel == true).FirstOrDefault();

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
                exp.ForeignDomestic = ford;
                exp.ChargedToComp = Convert.ToInt32(chargedComp);
                exp.ChargedToDept = Convert.ToInt32(chargedDept);
                exp.Purpose = purpose;
                exp.LocBranch = Convert.ToInt32(locbranch);
                exp.ARRefNo = arNo;
                exp.ExpenseType_ID = Convert.ToInt32(tranType.ExpenseType_ID);
                exp.WF_Id = Convert.ToInt32(Session["mainwfid"]);
                exp.FAPWF_Id = Convert.ToInt32(Session["fapwfid"]);
                exp.Preparer_Id = Convert.ToInt32(Session["userID"]);

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

                    exp.Remarks = string.Empty;

                    if (doc_desc == "Returned by Audit")
                    {
                        new_stat = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Pending at Audit").Select(x => x.STS_Id).FirstOrDefault();
                        wfID = _DataContext.ITP_S_WorkflowHeaders.Where(w => w.Name == "ACDE AUDIT" && w.App_Id == 1032 && w.Company_Id == Convert.ToInt32(company)).Select(x => x.WF_Id).FirstOrDefault();
                        wfdID = _DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.WFD_Id).FirstOrDefault();
                        orID = (int)_DataContext.ITP_S_WorkflowDetails.Where(w => w.WF_Id == wfID && w.Sequence == 1).Select(w => w.OrgRole_Id).FirstOrDefault();
                    }
                    else if (doc_desc == "Returned by Finance")
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
            string currentDate = DateTime.Now.ToShortDateString();

            var docno = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).Select(x => x.Doc_No).FirstOrDefault();

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
                .Where(um => um.EmpCode == Convert.ToString(Session["userID"]))
                .Select(um => um.FullName)
                .FirstOrDefault();
            var requestor_email = _DataContext.ITP_S_UserMasters
                .Where(um => um.EmpCode == Convert.ToString(Session["userID"]))
                .Select(um => um.Email)
                .FirstOrDefault();

            string appName = "ACCEDE EXPENSE REPORT";
            string recipientName = user_email.FullName;
            string senderName = requestor_fullname;
            string emailSender = requestor_email;
            string senderRemarks = "";
            string emailSite = "https://devapps.anflocor.com/AccedeExpenseReportApproval.aspx";
            string sendEmailTo = user_email.Email;
            string emailSubject = "Document No. " + docno + " (" + status + ")";

            ANFLO anflo = new ANFLO();

            //Body Details Sample
            string emailDetails = "";

            var queryER = from er in _DataContext.ACCEDE_T_TravelExpenseDetails
                          where er.TravelExpenseMain_ID == doc_id
                          select er;

            emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Date</td><td><strong>" + currentDate + "</strong></td></tr>";
            emailDetails += "<tr><td>Document No.</td><td><strong>" + docno + "</strong></td></tr>";
            emailDetails += "<tr><td>Preparer</td><td><strong>" + senderName + "</strong></td></tr>";
            emailDetails += "<tr><td>Status</td><td><strong>" + status + "</strong></td></tr>";
            emailDetails += "<tr><td>Document Purpose</td><td><strong>" + "Expense Report" + "</strong></td></tr>";
            emailDetails += "</table>";
            emailDetails += "<br>";

            emailDetails += "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
            emailDetails += "<tr><th colspan='6'> Document Details </th> </tr>";
            emailDetails += "<tr><th>Expense Type</th><th>Date</th><th>Location</th><th>Total Expenses</th></tr>";

            foreach (var item in queryER)
            {
                var exp = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ExpenseType_ID).FirstOrDefault();
                var travel = _DataContext.ACCEDE_T_TravelExpenseMains.Where(x => x.ID == doc_id).Select(x => x.ForeignDomestic).FirstOrDefault();
                var expType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == exp).Select(x => x.Description).FirstOrDefault();
                emailDetails +=
                            "<tr>" +
                            "<td style='text-align: center;'>" + expType + "</td>" +
                            "<td style='text-align: center;'>" + item.TravelExpenseDetail_Date.Value.ToShortDateString() + "</td>" +
                            "<td style='text-align: center;'>" + (travel == "Domestic" ? "₱" : "$") + Convert.ToDecimal(item.Total_Expenses).ToString("N2") + "</td>" +
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
    }
}