using DevExpress.DocumentServices.ServiceModel.DataContracts;
using DevExpress.Web;
using DevExpress.Web.Internal.XmlProcessor;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class RFPViewPage : System.Web.UI.Page
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
                    var rfp_id = Convert.ToInt32(Session["passRFPID"]);
                    var rfp_details = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == rfp_id).FirstOrDefault();
                    if (rfp_details.isTravel == true)
                    {
                        var travelExp = _DataContext.ACCEDE_T_TravelExpenseMains
                                       .FirstOrDefault(x => x.ID == rfp_details.Exp_ID);
                        // Do something with travelExp

                        if(travelExp != null)
                            lbl_expLink.Text = travelExp.Doc_No.ToString();
                        else
                            ExpBtn.Visible = false;
                    }
                    else
                    {
                        if(rfp_details.TranType == 3)
                        {
                            var invoice = _DataContext.ACCEDE_T_InvoiceMains.FirstOrDefault(x => x.ID == Convert.ToInt32(rfp_details.Exp_ID));
                            if (invoice != null)
                                lbl_expLink.Text = invoice.DocNo.ToString();
                            else
                                ExpBtn.Visible = false;
                        }
                        else
                        {
                            var regularExp = _DataContext.ACCEDE_T_ExpenseMains
                                             .FirstOrDefault(x => x.ID == rfp_details.Exp_ID);
                            // Do something with regularExp
                            if (regularExp != null)
                                lbl_expLink.Text = regularExp.DocNo.ToString();
                            else
                                ExpBtn.Visible = false;
                        }
                            
                    }

                    if(rfp_details.TranType == 3)
                    {
                        string raw = rfp_details.Payee.ToString();
                        string cleaned = raw.Replace("\r", "").Replace("\n", "");
                        var vendors = SAPVendor.GetVendorData("")
                                .GroupBy(x => new { x.VENDCODE, x.VENDNAME })
                                .Select(g => g.First())
                                .ToList();
                        var payee = vendors.Where(x => x.VENDCODE == cleaned).FirstOrDefault();
                        txt_Payee.Text = payee.VENDNAME.ToString();
                    }
                    else
                    {
                        var payee = _DataContext.ITP_S_UserMasters.Where(x=>x.EmpCode == rfp_details.Payee).FirstOrDefault();
                        txt_Payee.Text = payee.FullName.ToString();
                    }

                    var btnSub = formRFP.FindItemOrGroupByName("btnSubmit") as LayoutItem;
                    var btnEdit = formRFP.FindItemOrGroupByName("btnEditRFP") as LayoutItem;
                    var btnRecall = formRFP.FindItemOrGroupByName("recallBtn") as LayoutItem;
                    var myLayoutGroup = formRFP.FindItemOrGroupByName("PageTitle") as LayoutGroup;

                    var pld = formRFP.FindItemOrGroupByName("PLD") as LayoutItem;
                    var wbs = formRFP.FindItemOrGroupByName("WBS") as LayoutItem;
                    var cType = formRFP.FindItemOrGroupByName("ClassType") as LayoutItem;
                    var tType = formRFP.FindItemOrGroupByName("TravType") as LayoutItem;
                    var expDoc = formRFP.FindItemOrGroupByName("ExpDoc") as LayoutItem;

                    myLayoutGroup.Caption = "Request For Payment (View) - "+rfp_details.RFP_DocNum;

                    if (rfp_details != null)
                    {
                        if(rfp_details.Exp_ID != null)
                        {
                            expDoc.ClientVisible = true;
                        }
                        if(rfp_details.isTravel == true)
                        {
                            rdButton_Trav.Checked = true;
                            rdButton_NonTrav.Checked = false;
                            cType.ClientVisible = false;
                        }
                        else
                        {
                            if(rfp_details.TranType == 3)
                            {
                                expDoc.Caption = "Link to Invoice Details";
                            }
                            rdButton_Trav.Checked = false;
                            rdButton_NonTrav.Checked = true;
                            tType.ClientVisible = false;
                        }
                        var test = rfp_details.IsExpenseReim;
                        var CA_tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x=>x.RFPTranType_Name == "Cash Advance").FirstOrDefault();
                        if((rfp_details.Status == 3 || rfp_details.Status == 13 || rfp_details.Status == 15) && rfp_details.User_ID == empCode && rfp_details.IsExpenseReim != true && rfp_details.IsExpenseCA == true)
                        {
                            btnEdit.Visible = true;
                            btnSub.Visible = true;
                        }

                        if (rfp_details.TranType == CA_tranType.ID)
                        {
                            pld.ClientVisible = true;
                            if (rfp_details.PLDate != null)
                            {
                                DateTime date = Convert.ToDateTime(rfp_details.PLDate.ToString());
                                PLD_lbl.Text = date.ToString("MMMM dd, yyyy");
                            }
                        }

                        if (rfp_details.isForeignTravel != null && rfp_details.isForeignTravel == true)
                        {
                            txtbox_TravType.Value = "Foreign";
                        }
                        else
                        {
                            txtbox_TravType.Value = "Domestic";
                        }

                        if(rfp_details.Status == 1 && rfp_details.User_ID == empCode && rfp_details.TranType.ToString() == CA_tranType.ID.ToString())
                        {
                            btnRecall.ClientVisible = true;
                        }

                        if(rfp_details.User_ID != empCode && rfp_details.Payee != empCode)
                        {
                            BtnSaveDetailsUser.Visible = false;
                            ExpBtn.Visible = false;
                        }

                        amount_lbl.Text = rfp_details.Currency + " " + Convert.ToDecimal(rfp_details.Amount).ToString("#,##0.00");
                    }
                    var release_cash_status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disbursed").FirstOrDefault();

                    var CashierVerify = _DataContext.vw_ACCEDE_FinApproverVerifies.Where(x => x.UserId == empCode)
                        .Where(x => x.Role_Name == "Accede Cashier").FirstOrDefault();

                    var CashierStatus = _DataContext.ITP_S_Status
                                        .Where(x => x.STS_Name == "Pending at Cashier")
                                        .FirstOrDefault();

                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

                    var pending_SAPDoc_status = _DataContext.ITP_S_Status
                                        .Where(x => x.STS_Description == "Pending SAP Doc No.")
                                        .FirstOrDefault();

                    var pendingSAPDocAct = _DataContext.ITP_T_WorkflowActivities.Where(x => x.Document_Id == Convert.ToInt32(rfp_details.ID))
                                        .Where(x => x.AppId == 1032)
                                        .Where(x => x.AppDocTypeId == app_docType.DCT_Id)
                                        .Where(x=>x.Status == Convert.ToInt32(pending_SAPDoc_status.STS_Id))
                                        .FirstOrDefault();

                    var edit_SAPDoc = formRFP.FindItemOrGroupByName("edit_SAPDoc") as LayoutItem;
                    var lbl_SAPDoc = formRFP.FindItemOrGroupByName("lbl_SAPDoc") as LayoutItem;
                    var edit_IO = formRFP.FindItemOrGroupByName("IO_edit") as LayoutItem;
                    var lbl_IO = formRFP.FindItemOrGroupByName("IO_lbl") as LayoutItem;
                    var upload = formRFP.FindItemOrGroupByName("uploader_cashier") as LayoutItem;
                    var btnCash = formRFP.FindItemOrGroupByName("btnCash") as LayoutItem;
                    var btnPrint = formRFP.FindItemOrGroupByName("btnPrintRFP") as LayoutItem;
                    var BtnSave = formRFP.FindItemOrGroupByName("BtnSaveDetails") as LayoutItem;

                    if (CashierVerify != null && (rfp_details.Status == CashierStatus.STS_Id || pendingSAPDocAct != null) /*&& rfp_details.User_ID != empCode*/)
                    //if (CashierVerify != null && rfp_details.Status == 7)
                    {
                        

                        edit_SAPDoc.ClientVisible = true;
                        lbl_SAPDoc.ClientVisible = false;
                        edit_IO.ClientVisible = true;
                        lbl_IO.ClientVisible = false;
                        upload.ClientVisible = true;
                        btnCash.ClientVisible = true;
                        if (pendingSAPDocAct!=null)
                        {
                            btnCash.ClientVisible = false;
                            BtnSave.ClientVisible = true;
                        }
                        
                        BtnSave.ClientVisible = true;

                    }
                    if (rfp_details.Status == release_cash_status.STS_Id)
                    {
                        btnPrint.ClientVisible = true;
                        btnCash.ClientVisible = false;

                    }

                    SqlMain.SelectParameters["ID"].DefaultValue = rfp_id.ToString();
                    SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = rfp_details.WF_Id.ToString();
                    SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = rfp_details.FAPWF_Id.ToString();
                    SqlActivity.SelectParameters["Document_Id"].DefaultValue = rfp_id.ToString();
                    SqlRFPDocs.SelectParameters["Doc_ID"].DefaultValue = rfp_id.ToString();
                    SqlRFPDocs.SelectParameters["DocType_Id"].DefaultValue = app_docType != null ? app_docType.DCT_Id.ToString() : "";
                    SqlIO.SelectParameters["CompanyId"].DefaultValue = rfp_details.ChargedTo_CompanyId.ToString();

                    if (rfp_details.Status == 1 && rfp_details.User_ID != empCode)
                    {
                        var BtnSaveUser = formRFP.FindItemOrGroupByName("BtnSaveDetailsUser") as LayoutItem;

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
            
            //try
            //{
            //    var rfp_id = Convert.ToInt32(Session["passRFPID"]);
            //    var rfp_details = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == rfp_id).FirstOrDefault();

            //    if (Session["DataSetDoc"] == null)
            //    {
            //        dsDoc = new DataSet();
            //        DataTable masterTable = new DataTable();
            //        masterTable.Columns.Add("ID", typeof(int));
            //        masterTable.Columns.Add("Orig_ID", typeof(int));
            //        masterTable.Columns.Add("FileName", typeof(string));
            //        masterTable.Columns.Add("FileByte", typeof(byte[]));
            //        masterTable.Columns.Add("FileExt", typeof(string));
            //        masterTable.Columns.Add("FileSize", typeof(string));
            //        masterTable.Columns.Add("FileDesc", typeof(string));
            //        masterTable.Columns.Add("User_ID", typeof(string));
            //        masterTable.Columns.Add("isExist", typeof(bool));
            //        masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

            //        dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
            //        Session["DataSetDoc"] = dsDoc;

            //    }
            //    else
            //        dsDoc = (DataSet)Session["DataSetDoc"];

            //    var docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").FirstOrDefault();
            //    var RFPDocs = _DataContext.ITP_T_FileAttachments.Where(x => x.Doc_ID == rfp_details.ID).Where(x => x.DocType_Id == docType.DCT_Id).ToList();

            //    if (!IsPostBack || (Session["DataSetDoc"] == null))
            //    {
                    
            //        foreach (var rfpDoc in RFPDocs)
            //        {
            //            // Add a new row to the data table with the uploaded file data
            //            DataRow row = dsDoc.Tables[0].NewRow();
            //            row["ID"] = GetNewId();
            //            row["Orig_ID"] = rfpDoc.ID;
            //            row["FileName"] = rfpDoc.FileName;
            //            row["FileByte"] = rfpDoc.FileAttachment.ToArray();
            //            row["FileExt"] = rfpDoc.FileExtension;
            //            row["FileSize"] = rfpDoc.FileSize;
            //            row["FileDesc"] = rfpDoc.Description;
            //            row["User_ID"] = rfpDoc.User_ID;
            //            row["isExist"] = true;
            //            dsDoc.Tables[0].Rows.Add(row);

            //        }
            //    }


            //    DocuGrid.DataSource = dsDoc.Tables[0];
            //    DocuGrid.DataBind();
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
            Session["EditRFPID"] = Convert.ToInt32(Session["passRFPID"]);
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
            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

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

        private string Encrypt(string plainText)
        {
            // Example: Use a proper encryption library like AES or RSA for actual implementations
            // This is just a placeholder for encryption logic
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(plainText));
        }


        [WebMethod]
        public static object redirectExpAJAX()
        {
            RFPViewPage rfp = new RFPViewPage();

            return rfp.redirectExp();
        }

        public object redirectExp()
        {
            var result = new
            {
                status = "error",
                link = "RFPViewPage.aspx"
            };

            try
            {
                if (Session["passRFPID"] == null)
                    throw new Exception("Session 'passRFPID' is null.");

                int rfpId = Convert.ToInt32(Session["passRFPID"]);
                var rfpDetails = _DataContext.ACCEDE_T_RFPMains.FirstOrDefault(x => x.ID == rfpId);

                if (rfpDetails == null)
                    throw new Exception("RFP details not found.");

                Session["ExpenseId"] = rfpDetails.Exp_ID;
                Session["TravelExp_Id"] = rfpDetails.Exp_ID;
                string encryptedID = Encrypt(rfpDetails.Exp_ID.ToString()); // Implement the Encrypt method securely
                string redirectUrl = $"AccedeInvoiceNonPOViewPage.aspx?secureToken={encryptedID}";

                if (rfpDetails.isTravel == true)
                {
                    result = new
                    {
                        status = "success",
                        link = "TravelExpenseView.aspx"
                    };
                }
                else
                {
                    if(rfpDetails.TranType == 3)
                    {
                        result = new
                        {
                            status = "success",
                            link = redirectUrl
                        };
                    }
                    else
                    {
                        result = new
                        {
                            status = "success",
                            link = "AccedeExpenseViewPage.aspx"
                        };
                    }
                    
                }
            }
            catch (Exception ex)
            {
                // Log exception (optional)
                // Logger.Log(ex);
            }

            return result;
        }

        [WebMethod]
        public static string SaveCashierChangesAJAX(string SAPDoc, int stats)
        {
            RFPViewPage rfp = new RFPViewPage();

            return rfp.SaveCashierChanges(SAPDoc, stats);
        }

        public string SaveCashierChanges(string SAPDoc, int stats)
        {
            try
            {
                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();
                var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();
                var release_cash_status = _DataContext.ITP_S_Status.Where(x => x.STS_Description == "Disbursed").FirstOrDefault();
                var cashierWF = _DataContext.ITP_S_WorkflowHeaders.Where(x=>x.Name == "ACDE CASHIER").Where(x=>x.Company_Id == Convert.ToInt32(rfp_main.Company_ID)).FirstOrDefault();
                var cashierWFDetail = _DataContext.ITP_S_WorkflowDetails.Where(x=>x.WF_Id == Convert.ToInt32(cashierWF.WF_Id)).FirstOrDefault();
                var orgRole = _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == Convert.ToInt32(cashierWFDetail.OrgRole_Id)).Where(x=>x.UserId == Session["userID"].ToString()).FirstOrDefault();
                var pending_SAPDoc_status = _DataContext.ITP_S_Status
                            .Where(x => x.STS_Description == "Pending SAP Doc No.")
                            .FirstOrDefault();

                rfp_main.SAPDocNo = SAPDoc;

                var wfDetails = _DataContext.ITP_T_WorkflowActivities.Where(x => x.WFA_Id == Convert.ToInt32(Session["wfa"])).FirstOrDefault();
                var pre_wfDetStatus = wfDetails.Status.ToString();
                if(stats == 1)
                {
                    //if (release_cash_status != null && cashierWF != null && cashierWFDetail != null && orgRole != null)
                    //{

                    //    //ITP_T_WorkflowActivity new_activity = new ITP_T_WorkflowActivity();
                    //    //{
                    //    //    new_activity.Status = release_cash_status.STS_Id;
                    //    //    new_activity.AppId = 1032;
                    //    //    new_activity.CompanyId = rfp_main.Company_ID;
                    //    //    new_activity.Document_Id = rfp_main.ID;
                    //    //    new_activity.WF_Id = cashierWFDetail.WF_Id;
                    //    //    new_activity.DateAssigned = DateTime.Now;
                    //    //    new_activity.DateCreated = DateTime.Now;
                    //    //    new_activity.IsActive = true;
                    //    //    new_activity.OrgRole_Id = cashierWFDetail.OrgRole_Id;
                    //    //    new_activity.WFD_Id = cashierWFDetail.WFD_Id;
                    //    //    new_activity.AppDocTypeId = app_docType.DCT_Id;
                    //    //    new_activity.ActedBy_User_Id = Session["userID"].ToString();
                    //    //    new_activity.DateAction = DateTime.Now;
                    //    //}
                    //    //_DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(new_activity);


                    //}
                    //else
                    //{
                    //    //error in setup
                    //    return "There is an error in setup. Please contact admin regarding this issue.";
                    //}

                    //UPDATE ACTIVITY RFP
                    if (SAPDoc != "" && SAPDoc != null)
                        wfDetails.Status = release_cash_status.STS_Id;
                    else
                        wfDetails.Status = pending_SAPDoc_status.STS_Id;
                    
                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();

                    rfp_main.Status = release_cash_status.STS_Id;
                }

                if(pre_wfDetStatus == pending_SAPDoc_status.STS_Id.ToString())
                {
                    if (SAPDoc != "" && SAPDoc != null)
                        wfDetails.Status = release_cash_status.STS_Id;
                    else
                        wfDetails.Status = pending_SAPDoc_status.STS_Id;
                    wfDetails.DateAction = DateTime.Now;
                    wfDetails.Remarks = Session["AuthUser"].ToString() + ": ;";
                    wfDetails.ActedBy_User_Id = Session["userID"].ToString();
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

                return "success";

            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            //DataSet ImgDS = (DataSet)Session["DataSetDoc"];

            //foreach (var file in UploadController.UploadedFiles)
            //{
            //    var filesize = 0.00;
            //    var filesizeStr = "";
            //    if (Convert.ToInt32(file.ContentLength) > 999999)
            //    {
            //        filesize = Convert.ToInt32(file.ContentLength) / 1000000;
            //        filesizeStr = filesize.ToString() + " MB";
            //    }
            //    else if (Convert.ToInt32(file.ContentLength) > 999)
            //    {
            //        filesize = Convert.ToInt32(file.ContentLength) / 1000;
            //        filesizeStr = filesize.ToString() + " KB";
            //    }
            //    else
            //    {
            //        filesize = Convert.ToInt32(file.ContentLength);
            //        filesizeStr = filesize.ToString() + " Bytes";
            //    }

            //    // Add a new row to the data table with the uploaded file data
            //    DataRow row = ImgDS.Tables[0].NewRow();
            //    row["ID"] = GetNewId();
            //    row["FileName"] = file.FileName;
            //    row["FileByte"] = file.FileBytes;
            //    row["FileExt"] = file.FileName.Split('.').Last();
            //    row["FileSize"] = filesizeStr;
            //    row["FileDesc"] = file.FileName.Split('.').First();
            //    row["User_ID"] = Session["userID"].ToString();
            //    row["isExist"] = false;
            //    ImgDS.Tables[0].Rows.Add(row);
            //}
            //_DataContext.SubmitChanges();
            //SqlRFPDocs.DataBind();

            var rfp_main = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();

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
                var rfp_details = _DataContext.ACCEDE_T_RFPMains.Where(x=>x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();
                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").Where(x => x.App_Id == 1032).FirstOrDefault();

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
                            if(Convert.ToBoolean(row["isExist"]) == false)
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

        [WebMethod]
        public static string RecallRFPMainAJAX(string remarks)
        {
            RFPViewPage rfp = new RFPViewPage();
            return rfp.RecallRFPMain(remarks);
        }

        public string RecallRFPMain(string remarks)
        {
            try
            {
                string remarksInput = remarks.Trim();
                var doc_id = Convert.ToInt32(Session["passRFPID"]);
                var approver_org_id = 0;
                var rfpDoctype = _DataContext.ITP_S_DocumentTypes.Where(x=>x.DCT_Name == "ACDE RFP").FirstOrDefault();

                if (!string.IsNullOrEmpty(remarksInput))
                {
                    foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.Document_Id == doc_id)
                        .Where(x=>x.AppDocTypeId == rfpDoctype.DCT_Id)
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Status == 1))
                    {
                        rs.Status = 15;
                        rs.DateAction = DateTime.Now;
                        rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                        approver_org_id = Convert.ToInt32(rs.OrgRole_Id.ToString());
                    }

                    var comp_id = 0;
                    var doc_no = "";
                    var date_created = "";
                    var document_purpose = "";
                    var creator_email = "";
                    var creator_fullname = "";
                    var approver_id = "";
                    var payMethod = "";
                    var tranType = "";

                    foreach (var item in _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == doc_id))
                    {
                        item.Status = 15;

                        comp_id = Convert.ToInt32(item.Company_ID);
                        doc_no = item.RFP_DocNum.ToString();
                        date_created = item.DateCreated.ToString();
                        document_purpose = item.Purpose;

                        approver_id = _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == approver_org_id).FirstOrDefault().UserId;
                        creator_fullname = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.User_ID).FirstOrDefault().FullName;
                        creator_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.User_ID).FirstOrDefault().Email;

                        if(item.PayMethod != null)
                        {
                            payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == item.PayMethod).FirstOrDefault().PMethod_name;
                        }

                        if(item.TranType != null)
                        {
                            tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x => x.ID == item.TranType).FirstOrDefault().RFPTranType_Name;
                        }
                    }
                    _DataContext.SubmitChanges();

                    

                    ///////---START EMAIL PROCESS-----////////

                    var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == Session["UserID"].ToString())
                              .FirstOrDefault();

                    foreach (var item in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == approver_org_id))
                    {
                        var receiver_detail = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == item.UserId)
                              .FirstOrDefault();

                        SendEmailToApprover(approver_id.ToString(), comp_id, creator_fullname, creator_email, doc_no, date_created, document_purpose, payMethod, tranType, remarks, "Recalled");
                        
                    }

                }

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public bool SendEmailToApprover(string approver_id, int Comp_id, string creator_fullname, string creator_email, string doc_no, string date_created, string document_purpose, string payMethod, string tranType, string remarks, string status)
        {
            try
            {
                ///////---START EMAIL PROCESS-----////////
                //foreach (var user in _DataContext.ITP_S_SecurityUserOrgRoles.Where(x => x.OrgRoleId == org_id))
                //{
                var user_email = _DataContext.ITP_S_UserMasters.Where(x => x.EmpCode == approver_id)
                                    .FirstOrDefault();

                var comp_name = _DataContext.CompanyMasters.Where(x => x.WASSId == Comp_id)
                            .FirstOrDefault();

                //Start--   Get Text info
                var queryText =
                        from texts in _DataContext.ITP_S_Texts
                        where texts.Type == "Email" && texts.Name == status
                        select texts;

                var emailMessage = "";
                var emailSubMessage = "";
                var emailColor = "";
                var emailSubjectText3 = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = text.Text2.ToString();
                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                    if(text.Text3 != null)
                    {
                        emailSubjectText3 = text.Text3.ToString();
                    }
                }
                //End--     Get Text info

                string appName = "Request For Payment (RFP)";
                string recipientName = user_email.FName;
                string senderName = creator_fullname;
                string emailSender = creator_email;
                string emailSite = "https://apps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": "+ emailSubjectText3;


                ANFLO anflo = new ANFLO();

                //Body Details Sample
                string emailDetails = "";

                emailDetails = "<table border='1' cellpadding='2' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";
                emailDetails += "<tr><td>Company</td><td><strong>" + comp_name.CompanyShortName + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Date</td><td><strong>" + date_created + "</strong></td></tr>";
                emailDetails += "<tr><td>Document No.</td><td><strong>" + doc_no + "</strong></td></tr>";
                emailDetails += "<tr><td>Requestor</td><td><strong>" + senderName + "</strong></td></tr>";
                emailDetails += "<tr><td>Pay Method</td><td><strong>" + payMethod + "</strong></td></tr>";
                emailDetails += "<tr><td>Transaction Type</td><td><strong>" + tranType + "</strong></td></tr>";
                emailDetails += "<tr><td>Status</td><td><strong>" + "Pending" + "</strong></td></tr>";
                emailDetails += "<tr><td>Document Purpose</td><td><strong>" + document_purpose + "</strong></td></tr>";
                emailDetails += "</table>";
                emailDetails += "<br>";

                emailDetails += "</table>";
                //End of Body Details Sample

                //}
                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, remarks, emailSite, emailColor);

                if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }
            catch (Exception e)
            {
                return false;
            }
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
        public static string CheckSAPVAlidAJAX(string SAPDoc)
        {
            RFPViewPage page = new RFPViewPage();
            return page.CheckSAPVAlid(SAPDoc);
        }

        public string CheckSAPVAlid(string SAPDoc)
        {
            var rfpMain = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == Convert.ToInt32(Session["passRFPID"])).FirstOrDefault();
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
    }
}