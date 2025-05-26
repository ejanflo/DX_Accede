using DevExpress.Web;
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

namespace DX_WebTemplate
{
    public partial class AccedeP2P_RFPViewPage : System.Web.UI.Page
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
                    var rfp_id = Convert.ToInt32(Session["passP2PRFPID"]);
                    var rfp_details = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == rfp_id)
                        .FirstOrDefault();

                    var exp_details = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == rfp_details.Exp_ID)
                        .FirstOrDefault();

                    var btnSub = formRFP.FindItemOrGroupByName("btnSubmit") as LayoutItem;
                    var btnEdit = formRFP.FindItemOrGroupByName("btnEditRFP") as LayoutItem;
                    var myLayoutGroup = formRFP.FindItemOrGroupByName("PageTitle") as LayoutGroup;

                    var pld = formRFP.FindItemOrGroupByName("PLD") as LayoutItem;
                    var wbs = formRFP.FindItemOrGroupByName("WBS") as LayoutItem;
                    var cType = formRFP.FindItemOrGroupByName("ClassType") as LayoutItem;
                    var tType = formRFP.FindItemOrGroupByName("TravType") as LayoutItem;

                    myLayoutGroup.Caption = "Request For Payment (View) - " + rfp_details.RFP_DocNum;

                    if (rfp_details != null)
                    {
                        if (rfp_details.isTravel == true)
                        {
                            rdButton_Trav.Checked = true;
                            rdButton_NonTrav.Checked = false;
                            cType.ClientVisible = false;
                        }
                        else
                        {
                            rdButton_Trav.Checked = false;
                            rdButton_NonTrav.Checked = true;
                            tType.ClientVisible = false;
                        }
                        var test = rfp_details.IsExpenseReim;
                        if ((rfp_details.Status == 3 || rfp_details.Status == 13 || rfp_details.Status == 15) && rfp_details.User_ID == empCode && rfp_details.IsExpenseReim != true)
                        {
                            btnEdit.Visible = true;
                            btnSub.Visible = true;
                        }

                        if (rfp_details.TranType == 1)
                        {
                            pld.Visible = true;
                            if (rfp_details.PLDate != null)
                            {
                                DateTime date = Convert.ToDateTime(rfp_details.PLDate.ToString());
                                PLD_lbl.Text = date.ToString("MM/dd/yyyy");
                            }
                        }

                        if (rfp_details.Company_ID == 5)
                        {
                            wbs.Visible = true;
                        }

                        if (exp_details != null)
                        {
                            lbl_expLink.Text = exp_details.DocNo.ToString();
                        }
                        else
                        {
                            ExpBtn.Visible = false;
                        }

                        if (rfp_details.isForeignTravel != null && rfp_details.isForeignTravel == true)
                        {
                            txtbox_TravType.Value = "Foreign";
                        }
                        else
                        {
                            txtbox_TravType.Value = "Domestic";
                        }

                        amount_lbl.Text = rfp_details.Currency + " " + Convert.ToDecimal(rfp_details.Amount).ToString("#,##0.00");
                    }
                    var release_cash_status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disbursed").FirstOrDefault();

                    var P2PVerify = _DataContext.vw_ACCEDE_FinApproverVerifies
                        .Where(x => x.UserId == empCode)
                        .Where(x => x.Role_Name == "Accede P2P")
                        .FirstOrDefault();

                    var P2PStatus = _DataContext.ITP_S_Status
                                        .Where(x => x.STS_Name == "Pending at P2P")
                                        .FirstOrDefault();

                    if (P2PVerify != null && rfp_details.Status == P2PStatus.STS_Id /*&& rfp_details.User_ID != empCode*/)
                    //if (CashierVerify != null && rfp_details.Status == 7)
                    {
                        var edit_SAPDoc = formRFP.FindItemOrGroupByName("edit_SAPDoc") as LayoutItem;
                        var lbl_SAPDoc = formRFP.FindItemOrGroupByName("lbl_SAPDoc") as LayoutItem;
                        var upload = formRFP.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
                        var btnCash = formRFP.FindItemOrGroupByName("btnCash") as LayoutItem;
                        var btnPrint = formRFP.FindItemOrGroupByName("btnPrintRFP") as LayoutItem;
                        var BtnSave = formRFP.FindItemOrGroupByName("BtnSaveDetails") as LayoutItem;

                        edit_SAPDoc.ClientVisible = true;
                        lbl_SAPDoc.ClientVisible = false;
                        upload.ClientVisible = true;
                        btnCash.ClientVisible = true;
                        BtnSave.ClientVisible = true;

                        if (rfp_details.Status == release_cash_status.STS_Id)
                        {
                            btnPrint.ClientVisible = true;
                        }
                    }

                    var app_docType = _DataContext.ITP_S_DocumentTypes
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    SqlMain.SelectParameters["ID"].DefaultValue = rfp_id.ToString();
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp_details.WF_Id.ToString();
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                    SqlActivity.SelectParameters["Document_Id"].DefaultValue = rfp_id.ToString();
                    SqlRFPDocs.SelectParameters["Doc_ID"].DefaultValue = rfp_id.ToString();
                    SqlRFPDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";
                    SqlCompany.SelectParameters["UserId"].DefaultValue = rfp_details.User_ID.ToString();
                    SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();
                    SqlCostCenter.SelectParameters["DepartmentId"].DefaultValue = rfp_details.ChargedTo_DeptId.ToString();
                    SqlCostCenterCT.SelectParameters["Company_ID"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();

                    

                    if (rfp_details.Status == 1 && rfp_details.User_ID != empCode)
                    {
                        var BtnSaveUser = formRFP.FindItemOrGroupByName("BtnSaveDetailsUser") as LayoutItem;
                        var upload = formRFP.FindItemOrGroupByName("uploader_cashier") as LayoutItem;

                        if (BtnSaveUser != null)
                        {
                            BtnSaveUser.ClientVisible = true;
                            upload.ClientVisible = true;
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

        DataSet dsDoc = null;
        protected void formRFP_Init(object sender, EventArgs e)
        {
            try
            {
                var rfp_id = Convert.ToInt32(Session["passP2PRFPID"]);
                var rfp_details = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.ID == rfp_id)
                    .FirstOrDefault();

                if (!IsPostBack || (Session["DataSetDoc"] == null))
                {
                    dsDoc = new DataSet();
                    DataTable masterTable = new DataTable();
                    masterTable.Columns.Add("ID", typeof(int));
                    masterTable.Columns.Add("Orig_ID", typeof(int));
                    masterTable.Columns.Add("FileName", typeof(string));
                    masterTable.Columns.Add("FileByte", typeof(byte[]));
                    masterTable.Columns.Add("FileExt", typeof(string));
                    masterTable.Columns.Add("FileSize", typeof(string));
                    masterTable.Columns.Add("FileDesc", typeof(string));
                    masterTable.Columns.Add("isExist", typeof(bool));
                    masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                    dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                    Session["DataSetDoc"] = dsDoc;

                }
                else
                    dsDoc = (DataSet)Session["DataSetDoc"];

                var docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .FirstOrDefault();

                var RFPDocs = _DataContext.ITP_T_FileAttachments
                    .Where(x => x.Doc_ID == rfp_details.ID)
                    .Where(x => x.DocType_Id == docType.DCT_Id)
                    .ToList();

                if (!IsPostBack || (Session["DataSetDoc"] == null))
                {
                    foreach (var rfpDoc in RFPDocs)
                    {
                        // Add a new row to the data table with the uploaded file data
                        DataRow row = dsDoc.Tables[0].NewRow();
                        row["ID"] = GetNewId();
                        row["Orig_ID"] = rfpDoc.ID;
                        row["FileName"] = rfpDoc.FileName;
                        row["FileByte"] = rfpDoc.FileAttachment.ToArray();
                        row["FileExt"] = rfpDoc.FileExtension;
                        row["FileSize"] = rfpDoc.FileSize;
                        row["FileDesc"] = rfpDoc.Description;
                        row["isExist"] = true;
                        dsDoc.Tables[0].Rows.Add(row);

                    }
                }

                DocuGrid.DataSource = dsDoc.Tables[0];
                DocuGrid.DataBind();
            }
            catch (Exception ex)
            {
                Response.Redirect("~/Logon.aspx");
            }

        }
        private int GetNewId()
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

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Session["EditRFPID"] = Convert.ToInt32(Session["passP2PRFPID"]);
            Response.Redirect("RFPEditPage.aspx");
        }

        [WebMethod]
        public static int UpdateRFPMainAjax(int status)
        {
            try
            {
                RFPViewPage rfp = new RFPViewPage();

                return rfp.UpdateRFPMain(status);
            }
            catch (Exception ex)
            {
                return 0;
            }


        }

        public int UpdateRFPMain(int status)
        {
            var rfp_main = _DataContext.ACCEDE_T_RFPMains
                .Where(x => x.ID == Convert.ToInt32(Session["passP2PRFPID"]))
                .FirstOrDefault();

            if (status == 1)
            {
                RFPCreationPage rfpCreatePage = new RFPCreationPage();
                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                               where app.WF_Id == Convert.ToInt32(rfp_main.WF_Id)
                               where app.Sequence == 1
                               select app;

                bool ins_wf = rfpCreatePage.InsertWorkflowAct(rfp_main.ID);

                if (!ins_wf)
                {
                    return 0;
                }

            }

            rfp_main.Status = status;

            _DataContext.SubmitChanges();

            return rfp_main.ID;
        }

        [WebMethod]
        public static bool redirectExpAJAX()
        {
            AccedeP2P_RFPViewPage rfp = new AccedeP2P_RFPViewPage();

            return rfp.redirectExp();
        }

        public bool redirectExp()
        {
            try
            {
                var rfp_details = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.ID == Convert.ToInt32(Session["passP2PRFPID"]))
                    .FirstOrDefault();

                Session["ExpenseId"] = rfp_details.Exp_ID;
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static string SaveP2PChangesAJAX(string SAPDoc, int stats, string CTComp_id, string CTDept_id, string CostCenter, string ClassType, string payMethod, string io, string acctCharged)
        {
            AccedeP2P_RFPViewPage rfp = new AccedeP2P_RFPViewPage();

            return rfp.SaveP2PChanges(SAPDoc, stats, CTComp_id, CTDept_id, CostCenter, ClassType, payMethod, io, acctCharged);
        }

        public string SaveP2PChanges(string SAPDoc, int stats, string CTComp_id, string CTDept_id, string CostCenter, string ClassType, string payMethod, string io, string acctCharged)
        {
            try
            {
                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                var rfp_main = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.ID == Convert.ToInt32(Session["passP2PRFPID"]))
                    .FirstOrDefault();

                var Cashier_status = _DataContext.ITP_S_Status
                    .Where(x => x.STS_Description == "Pending at Cashier")
                    .FirstOrDefault();

                var P2PWF = _DataContext.ITP_S_WorkflowHeaders
                    .Where(x => x.Name.Contains("ACDE P2P"))
                    .Where(x => x.Company_Id == Convert.ToInt32(rfp_main.ChargedTo_CompanyId))
                    .FirstOrDefault();

                var P2PWFDetail = _DataContext.ITP_S_WorkflowDetails
                    .Where(x => x.WF_Id == Convert.ToInt32(P2PWF.WF_Id))
                    .FirstOrDefault();

                var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles
                    .Where(x => x.OrgRoleId == Convert.ToInt32(P2PWFDetail.OrgRole_Id))
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .FirstOrDefault();
                
                rfp_main.SAPDocNo = SAPDoc;
                rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                rfp_main.SAPCostCenter = CostCenter;
                rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                rfp_main.PayMethod = Convert.ToInt32(payMethod);
                rfp_main.IO_Num = io;
                rfp_main.AcctCharged = Convert.ToInt32(acctCharged);

                Session["passRFPID"] = Session["passP2PRFPID"];

                if (stats == 1)
                {
                    if (Cashier_status != null && P2PWF != null && P2PWFDetail != null && orgRole != null)
                    {

                        ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                        {
                            new_activity.Status = 7;
                            new_activity.AppId = 1032;
                            new_activity.CompanyId = rfp_main.Company_ID;
                            new_activity.Document_Id = rfp_main.ID;
                            new_activity.WF_Id = P2PWFDetail.WF_Id;
                            new_activity.DateAssigned = DateTime.Now;
                            new_activity.DateCreated = DateTime.Now;
                            new_activity.IsActive = true;
                            new_activity.OrgRole_Id = P2PWFDetail.OrgRole_Id;
                            new_activity.WFD_Id = P2PWFDetail.WFD_Id;
                            new_activity.AppDocTypeId = app_docType.DCT_Id;
                            new_activity.ActedBy_User_Id = Session["userID"].ToString();
                            new_activity.DateAction = DateTime.Now;
                        }
                        _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);
                        rfp_main.Status = Cashier_status.STS_Id;
                    }
                    else
                    {
                        //error in setup
                        return "There is an error in setup. Please contact admin regarding this issue.";
                    }
                }

                _DataContext.SubmitChanges();

                //var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                //Insert Attachments
                DataSet dsFile = (DataSet)Session["DataSetDoc"];
                DataTable dataTable = dsFile.Tables[0];

                if (dataTable.Rows.Count > 0)
                {
                    string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                    string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                    using (SqlConnection connection = new SqlConnection(connectionString1))
                    using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                    {
                        // Define the parameters for the SQL query
                        command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                        command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                        command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                        command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                        command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                        command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@docType", SqlDbType.Int, 10);

                        // Open the connection to the database
                        connection.Open();

                        // Loop through the rows in the DataTable and insert them into the database
                        foreach (DataRow row in dataTable.Rows)
                        {
                            if (Convert.ToBoolean(row["isExist"]) == false)
                            {
                                command.Parameters["@filename"].Value = row["FileName"];
                                command.Parameters["@file_byte"].Value = row["FileByte"];
                                command.Parameters["@desc"].Value = row["FileDesc"];
                                command.Parameters["@date_upload"].Value = DateTime.Now;
                                command.Parameters["@app_id"].Value = 1032;
                                command.Parameters["@comp_id"].Value = rfp_main.Company_ID;
                                command.Parameters["@doc_id"].Value = rfp_main.ID;
                                command.Parameters["@doc_no"].Value = rfp_main.RFP_DocNum;
                                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                                command.Parameters["@fileExt"].Value = row["FileExt"];
                                command.Parameters["@filesize"].Value = row["FileSize"];
                                command.Parameters["@docType"].Value = app_docType != null ? app_docType.DCT_Id : 0;
                                command.ExecuteNonQuery();
                            }

                        }

                        // Close the connection to the database
                        connection.Close();


                    }
                }

                return "success";

            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            DataSet ImgDS = (DataSet)Session["DataSetDoc"];

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

                // Add a new row to the data table with the uploaded file data
                DataRow row = ImgDS.Tables[0].NewRow();
                row["ID"] = GetNewId();
                row["FileName"] = file.FileName;
                row["FileByte"] = file.FileBytes;
                row["FileExt"] = file.FileName.Split('.').Last();
                row["FileSize"] = filesizeStr;
                row["FileDesc"] = file.FileName.Split('.').First();
                row["isExist"] = false;
                ImgDS.Tables[0].Rows.Add(row);
            }
            _DataContext.SubmitChanges();
            SqlRFPDocs.DataBind();
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/RFPPrintPage.aspx");
        }

        protected void DocuGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.VisibleIndex >= 0 && e.ButtonID == "btnRemove") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "isExist");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (Convert.ToBoolean(statusValue) != true))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }

            if (e.VisibleIndex >= 0 && e.ButtonID == "btnDownload") // Ensure it's a data row and the button is the desired one
            {
                //Get the value of the "Status" column for the current row
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "isExist");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && (Convert.ToBoolean(statusValue) != false))
                    e.Visible = DevExpress.Utils.DefaultBoolean.True;
                else
                    e.Visible = DevExpress.Utils.DefaultBoolean.False;
            }
        }

        protected void DocuGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            string[] args = e.Parameters.Split('|');
            string rowKey = args[0];
            string buttonId = args[1];

            if (buttonId == "btnRemove")
            {
                int i = DocuGrid.FindVisibleIndexByKeyValue(rowKey);

                // Access the dataset from the session
                DataSet dsDoc = (DataSet)Session["DataSetDoc"];

                // Ensure that the rowKey exists in the table before trying to remove it
                DataRow rowToRemove = dsDoc.Tables[0].Rows.Find(rowKey);
                if (rowToRemove != null)
                {
                    dsDoc.Tables[0].Rows.Remove(rowToRemove);
                }

                // Optionally rebind the grid after removing the row
                DocuGrid.DataBind();
            }

        }

        [WebMethod]
        public static string SaveCreatorChangesAJAX()
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.SaveCreatorChanges();

        }

        public string SaveCreatorChanges()
        {
            try
            {
                var rfp_details = _DataContext.ACCEDE_T_RFPMains
                    .Where(x => x.ID == Convert.ToInt32(Session["passP2PRF PID"]))
                    .FirstOrDefault();

                var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                //Insert Attachments
                DataSet dsFile = (DataSet)Session["DataSetDoc"];
                DataTable dataTable = dsFile.Tables[0];

                if (dataTable.Rows.Count > 0)
                {
                    string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                    string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                    using (SqlConnection connection = new SqlConnection(connectionString1))
                    using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                    {
                        // Define the parameters for the SQL query
                        command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                        command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                        command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                        command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                        command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                        command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                        command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);
                        command.Parameters.Add("@docType", SqlDbType.Int, 10);

                        // Open the connection to the database
                        connection.Open();

                        // Loop through the rows in the DataTable and insert them into the database
                        foreach (DataRow row in dataTable.Rows)
                        {
                            if (Convert.ToBoolean(row["isExist"]) == false)
                            {
                                command.Parameters["@filename"].Value = row["FileName"];
                                command.Parameters["@file_byte"].Value = row["FileByte"];
                                command.Parameters["@desc"].Value = row["FileDesc"];
                                command.Parameters["@date_upload"].Value = DateTime.Now;
                                command.Parameters["@app_id"].Value = 1032;
                                command.Parameters["@comp_id"].Value = rfp_details.Company_ID;
                                command.Parameters["@doc_id"].Value = rfp_details.ID;
                                command.Parameters["@doc_no"].Value = rfp_details.RFP_DocNum;
                                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                                command.Parameters["@fileExt"].Value = row["FileExt"];
                                command.Parameters["@filesize"].Value = row["FileSize"];
                                command.Parameters["@docType"].Value = app_docType != null ? app_docType.DCT_Id : 0;
                                command.ExecuteNonQuery();
                            }

                        }

                        // Close the connection to the database
                        connection.Close();


                    }
                }

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }


        //PDF/IMAGE VIEWER
        [WebMethod]
        public static object AJAXGetDocument(string fileId, string appId)
        {
            DocumentViewer doc = new DocumentViewer();

            return doc.GetDocument(fileId, appId);
        }

        public object GetDocument(string fileId, string appId)
        {
            byte[] bytes;
            string fileName, contentType;
            string constr = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT FileName, FileAttachment, FileExtension FROM ITP_T_FileAttachment WHERE ID = @fileId AND App_ID = @appId";
                    cmd.Parameters.AddWithValue("@fileId", Convert.ToInt32(fileId));
                    cmd.Parameters.AddWithValue("@appId", Convert.ToInt32(appId));
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        sdr.Read();
                        bytes = (byte[])sdr["FileAttachment"];
                        contentType = sdr["FileExtension"].ToString();
                        fileName = sdr["FileName"].ToString();
                    }
                    con.Close();
                }
            }

            if (contentType == "png" || contentType == "jpg" || contentType == "jpeg" || contentType == "gif" || contentType == "JPEG" || contentType == "JPG" || contentType == "PNG" || contentType == "GIF")
            {
                string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            else
                return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }

        protected void edit_Department_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            edit_Department.DataSourceID = null;
            edit_Department.DataSource = SqlCTDepartment;
            edit_Department.DataBind();

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
    }

}