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
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ListView;
using DevExpress.Utils.DirectXPaint;

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

                    string encryptedID = Request.QueryString["secureToken"];
                    if (!string.IsNullOrEmpty(encryptedID))
                    {

                        int actID = Convert.ToInt32(Decrypt(encryptedID));
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
                        var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                        var rfp_id = wfDetails.Document_Id;
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

                        SqlIO.SelectParameters["CompanyId"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();

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

        private string Decrypt(string encryptedText)
        {
            // Example: Use the corresponding decryption logic
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encryptedText));
        }

        protected void formRFP_Init(object sender, EventArgs e)
        {
            //try
            //{
            //    string encryptedID = Request.QueryString["secureToken"];
            //    if (!string.IsNullOrEmpty(encryptedID))
            //    {

            //        int actID = Convert.ToInt32(Decrypt(encryptedID));
            //        var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
            //        var rfp_id = wfDetails.Document_Id;
            //        var rfp_details = _DataContext.ACCEDE_T_RFPMains
            //            .Where(x => x.ID == rfp_id)
            //            .FirstOrDefault();

            //        if (!IsPostBack || (Session["DataSetDoc"] == null))
            //        {
            //            dsDoc = new DataSet();
            //            DataTable masterTable = new DataTable();
            //            masterTable.Columns.Add("ID", typeof(int));
            //            masterTable.Columns.Add("Orig_ID", typeof(int));
            //            masterTable.Columns.Add("FileName", typeof(string));
            //            masterTable.Columns.Add("FileByte", typeof(byte[]));
            //            masterTable.Columns.Add("FileExt", typeof(string));
            //            masterTable.Columns.Add("FileSize", typeof(string));
            //            masterTable.Columns.Add("FileDesc", typeof(string));
            //            masterTable.Columns.Add("User_ID", typeof(string));
            //            masterTable.Columns.Add("isExist", typeof(bool));
            //            masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

            //            dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
            //            Session["DataSetDoc"] = dsDoc;

            //        }
            //        else
            //            dsDoc = (DataSet)Session["DataSetDoc"];

            //        var docType = _DataContext.ITP_S_DocumentTypes
            //            .Where(x => x.DCT_Name == "ACDE RFP")
            //            .FirstOrDefault();

            //        var RFPDocs = _DataContext.ITP_T_FileAttachments
            //            .Where(x => x.Doc_ID == rfp_details.ID)
            //            .Where(x => x.DocType_Id == docType.DCT_Id)
            //            .ToList();

            //        if (!IsPostBack || (Session["DataSetDoc"] == null))
            //        {
            //            foreach (var rfpDoc in RFPDocs)
            //            {
            //                // Add a new row to the data table with the uploaded file data
            //                DataRow row = dsDoc.Tables[0].NewRow();
            //                row["ID"] = GetNewId();
            //                row["Orig_ID"] = rfpDoc.ID;
            //                row["FileName"] = rfpDoc.FileName;
            //                row["FileByte"] = rfpDoc.FileAttachment.ToArray();
            //                row["FileExt"] = rfpDoc.FileExtension;
            //                row["FileSize"] = rfpDoc.FileSize;
            //                row["FileDesc"] = rfpDoc.Description;
            //                row["User_ID"] = rfpDoc.User_ID;
            //                row["isExist"] = true;
            //                dsDoc.Tables[0].Rows.Add(row);

            //            }
            //        }

            //        DocuGrid.DataSource = dsDoc.Tables[0];
            //        DocuGrid.DataBind();
            //    }
                
            //}
            //catch (Exception ex)
            //{
            //    Response.Redirect("~/Logon.aspx");
            //}

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
        public static string SaveP2PChangesAJAX(string SAPDoc, int stats, string CTComp_id, string CTDept_id, string CostCenter, string ClassType, string payMethod, string io, string acctCharged, string secureToken)
        {
            AccedeP2P_RFPViewPage rfp = new AccedeP2P_RFPViewPage();

            return rfp.SaveP2PChanges(SAPDoc, stats, CTComp_id, CTDept_id, CostCenter, ClassType, payMethod, io, acctCharged, secureToken);
        }

        public string SaveP2PChanges(string SAPDoc, int stats, string CTComp_id, string CTDept_id, string CostCenter, string ClassType, string payMethod, string io, string acctCharged, string secureToken)
        {
            try
            {
                string encryptedID = secureToken;
                if (!string.IsNullOrEmpty(encryptedID))
                {
                    int actID = Convert.ToInt32(Decrypt(encryptedID));
                    var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == actID).FirstOrDefault();


                    var app_docType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE RFP")
                    .Where(x => x.App_Id == 1032)
                    .FirstOrDefault();

                    var rfp_main = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id))
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

                    //var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles
                    //    .Where(x => x.OrgRoleId == Convert.ToInt32(P2PWFDetail.OrgRole_Id))
                    //    .Where(x => x.UserId == Session["userID"].ToString())
                    //    .FirstOrDefault();

                    rfp_main.SAPDocNo = SAPDoc;
                    rfp_main.ChargedTo_CompanyId = Convert.ToInt32(CTComp_id);
                    rfp_main.ChargedTo_DeptId = Convert.ToInt32(CTDept_id);
                    rfp_main.SAPCostCenter = CostCenter;
                    rfp_main.Classification_Type_Id = Convert.ToInt32(ClassType);
                    rfp_main.PayMethod = Convert.ToInt32(payMethod);
                    rfp_main.IO_Num = io;
                    rfp_main.AcctCharged = Convert.ToInt32(acctCharged);

                    Session["passRFPID"] = wfDetails.Document_Id;

                    if (stats == 1)
                    {
                        var wfID_cash = _DataContext.ITP_S_WorkflowHeaders
                                    .Where(x => x.Company_Id == rfp_main.ChargedTo_CompanyId)
                                    .Where(x => x.Name == "ACDE CASHIER")
                                    .FirstOrDefault();

                        if (wfID_cash != null)
                        {
                            var rfpDocType = _DataContext.ITP_S_DocumentTypes
                                .Where(x => x.DCT_Name == "ACDE RFP" || x.DCT_Description == "Accede Request For Payment")
                                .Select(x => x.DCT_Id)
                                .FirstOrDefault();

                            // GET WORKFLOW DETAILS ID
                            var wfDetails_cash = from wfd in _DataContext.ITP_S_WorkflowDetails
                                                 where wfd.WF_Id == wfID_cash.WF_Id && wfd.Sequence == 1
                                                 select wfd.WFD_Id;
                            int wfdID_cash = wfDetails_cash.FirstOrDefault();

                            // GET ORG ROLE ID
                            var orgRole = from or in _DataContext.ITP_S_WorkflowDetails
                                          where or.WF_Id == wfID_cash.WF_Id && or.Sequence == 1
                                          select or.OrgRole_Id;
                            int orID = (int)orgRole.FirstOrDefault();

                            if (wfID_cash != null && wfDetails_cash != null && orgRole != null)
                            {
                                //INSERT REIMBURSE ACTIVITY TO ITP_T_WorkflowActivity
                                DateTime currentDate = DateTime.Now;
                                ITP_T_WorkflowActivity wfa = new ITP_T_WorkflowActivity()
                                {
                                    Status = Cashier_status.STS_Id,
                                    DateAssigned = currentDate,
                                    DateCreated = currentDate,
                                    WF_Id = wfID_cash.WF_Id,
                                    WFD_Id = wfdID_cash,
                                    OrgRole_Id = orID,
                                    Document_Id = rfp_main.ID,
                                    AppId = 1032,
                                    ActedBy_User_Id = Session["userID"].ToString(),
                                    CompanyId = Convert.ToInt32(rfp_main.ChargedTo_CompanyId),
                                    AppDocTypeId = rfpDocType,
                                    IsActive = true,
                                    Remarks = Session["AuthUser"].ToString() + ":"
                                };
                                _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(wfa);


                                rfp_main.Status = Cashier_status.STS_Id;
                            }

                            //UPDATE ACTIVITY RFP
                            wfDetails.Status = 7;
                            wfDetails.DateAction = DateTime.Now;
                            wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                            wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                            _DataContext.SubmitChanges();
                        }
                        else
                        {
                            return "There is no workflow (ACDE CASHIER) setup for your company. Please contact Admin to setup the workflow.";
                        }
                    }

                    _DataContext.SubmitChanges();

                    //var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                    //Insert Attachments
                    //DataSet dsFile = (DataSet)Session["DataSetDoc"];
                    //DataTable dataTable = dsFile.Tables[0];

                    //if (dataTable.Rows.Count > 0)
                    //{
                    //    string connectionString1 = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
                    //    string insertQuery1 = "INSERT INTO ITP_T_FileAttachment (FileAttachment, FileName, Description, DateUploaded, App_ID, Company_ID, Doc_ID, Doc_No, User_ID, FileExtension, FileSize, DocType_Id) VALUES (@file_byte, @filename, @desc, @date_upload, @app_id, @comp_id, @doc_id, @doc_no, @user_id, @fileExt, @filesize, @docType)";

                    //    using (SqlConnection connection = new SqlConnection(connectionString1))
                    //    using (SqlCommand command = new SqlCommand(insertQuery1, connection))
                    //    {
                    //        // Define the parameters for the SQL query
                    //        command.Parameters.Add("@filename", SqlDbType.NVarChar, 200);
                    //        command.Parameters.Add("@file_byte", SqlDbType.VarBinary);
                    //        command.Parameters.Add("@desc", SqlDbType.NVarChar, 200);
                    //        command.Parameters.Add("@date_upload", SqlDbType.DateTime);
                    //        command.Parameters.Add("@app_id", SqlDbType.Int, 10);
                    //        command.Parameters.Add("@comp_id", SqlDbType.Int, 10);
                    //        command.Parameters.Add("@doc_id", SqlDbType.Int, 10);
                    //        command.Parameters.Add("@doc_no", SqlDbType.NVarChar, 40);
                    //        command.Parameters.Add("@user_id", SqlDbType.NVarChar, 20);
                    //        command.Parameters.Add("@fileExt", SqlDbType.NVarChar, 20);
                    //        command.Parameters.Add("@filesize", SqlDbType.NVarChar, 20);
                    //        command.Parameters.Add("@docType", SqlDbType.Int, 10);

                    //        // Open the connection to the database
                    //        connection.Open();

                    //        // Loop through the rows in the DataTable and insert them into the database
                    //        foreach (DataRow row in dataTable.Rows)
                    //        {
                    //            if (Convert.ToBoolean(row["isExist"]) == false)
                    //            {
                    //                command.Parameters["@filename"].Value = row["FileName"];
                    //                command.Parameters["@file_byte"].Value = row["FileByte"];
                    //                command.Parameters["@desc"].Value = row["FileDesc"];
                    //                command.Parameters["@date_upload"].Value = DateTime.Now;
                    //                command.Parameters["@app_id"].Value = 1032;
                    //                command.Parameters["@comp_id"].Value = rfp_main.Company_ID;
                    //                command.Parameters["@doc_id"].Value = rfp_main.ID;
                    //                command.Parameters["@doc_no"].Value = rfp_main.RFP_DocNum;
                    //                command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                    //                command.Parameters["@fileExt"].Value = row["FileExt"];
                    //                command.Parameters["@filesize"].Value = row["FileSize"];
                    //                command.Parameters["@docType"].Value = app_docType != null ? app_docType.DCT_Id : 0;
                    //                command.ExecuteNonQuery();
                    //            }

                    //        }

                    //        // Close the connection to the database
                    //        connection.Close();


                    //    }
                    //}

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
            string encryptedID = Request.QueryString["secureToken"];
            if (!string.IsNullOrEmpty(encryptedID))
            {
                int actID = Convert.ToInt32(Decrypt(encryptedID));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();

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
                        .Where(x => x.DCT_Name == "ACDE RFP")
                        .Where(x => x.App_Id == 1032)
                        .FirstOrDefault();

                    ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                    {
                        docs.FileAttachment = file.FileBytes;
                        docs.FileName = file.FileName;
                        docs.Doc_ID = rfp_main.ID;
                        docs.App_ID = 1032;
                        docs.DocType_Id = 1016;
                        docs.User_ID = Session["userID"].ToString();
                        docs.FileExtension = file.FileName.Split('.').Last();
                        docs.Description = file.FileName.Split('.').First();
                        docs.FileSize = filesizeStr;
                        docs.Doc_No = rfp_main.RFP_DocNum.ToString();
                        docs.Company_ID = Convert.ToInt32(rfp_main.ChargedTo_CompanyId);
                        docs.DateUploaded = DateTime.Now;
                        docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                    }

                    _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
                }

                _DataContext.SubmitChanges();
                SqlRFPDocs.DataBind();
            }
                
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
                object statusValue = DocuGrid.GetRowValues(e.VisibleIndex, "User_ID");

                //Check if the status is "saved" and make the button visible accordingly
                if (statusValue != null && statusValue.ToString() == Session["userID"].ToString())
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
                int rowIndex = DocuGrid.FindVisibleIndexByKeyValue(rowKey);

                // Get the actual ID value from the grid using the row index
                object idValue = DocuGrid.GetRowValues(rowIndex, "ID");
                if (idValue != null)
                {
                    int id = Convert.ToInt32(idValue);
                    var file = _DataContext.ITP_T_FileAttachments.FirstOrDefault(x => x.ID == id);
                    if (file != null)
                    {
                        _DataContext.ITP_T_FileAttachments.DeleteOnSubmit(file);
                        _DataContext.SubmitChanges();
                    }
                }

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

        protected void DocuGrid_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "User_ID")
            {
                if (e.CellValue != null)
                {
                    var emp = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == e.CellValue.ToString()).FirstOrDefault();

                    e.Cell.Text = emp.FullName;
                }
            }
        }

        [WebMethod]
        public static string CheckSAPVAlidAJAX(string SAPDoc, string secureToken)
        {
            AccedeP2P_RFPViewPage page = new AccedeP2P_RFPViewPage();
            return page.CheckSAPVAlid(SAPDoc, secureToken);
        }

        public string CheckSAPVAlid(string SAPDoc, string secureToken)
        {
            if (!string.IsNullOrEmpty(secureToken))
            {
                int actID = Convert.ToInt32(Decrypt(secureToken));
                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(actID)).FirstOrDefault();
                var rfpMain = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(wfDetails.Document_Id)).FirstOrDefault();
                var rfpCheck = _DataContext.ACCEDE_T_RFPMains.Where(x => x.SAPDocNo == SAPDoc).FirstOrDefault();

                if (rfpCheck != null && SAPDoc != rfpMain.SAPDocNo)
                {
                    return "error";
                }
                else
                {
                    return "clear";
                }
            }
            else
            {
                return "Secure token is null.";
            }
            
        }
    }

}