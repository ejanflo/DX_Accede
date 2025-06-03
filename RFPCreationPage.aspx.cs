using DevExpress.Internal.WinApi.Windows.UI.Notifications;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using System.Collections;

namespace DX_WebTemplate
{
    public partial class RFPCreationPage : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        string conString = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;
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
                    string pageName = Path.GetFileNameWithoutExtension(url); // Get the filename without 

                    var payMethodCash = _DataContext.ACCEDE_S_PayMethods
                        .Where(x => x.PMethod_name == "Cash")
                        .FirstOrDefault();

                    if (payMethodCash != null)
                    {
                        drpdown_PayMethod.Value = payMethodCash.ID.ToString(); // Automatically shows the name in the dropdown
                        
                    }

                    var rfpTrantype = _DataContext.ACCEDE_S_RFPTranTypes
                        .Where(x => x.RFPTranType_Name == "Cash Advance")
                        .FirstOrDefault();

                    if (rfpTrantype != null)
                    {
                        drpdown_TranType.Value = rfpTrantype.ID.ToString(); // Automatically shows the name in the dropdown

                    }
                    //if (!anflosession.current.haspageaccess(empcode, appid, pagename))
                    //{
                    //    session["appid"] = appid.tostring();
                    //    session["pagename"] = pagename.tostring();

                    //    response.redirect("~/erroraccess.aspx");
                    //}
                    //End ------------------ Page Security

                    SqlCompany.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlDepartment.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlWF.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlExpense.SelectParameters["UserId"].DefaultValue = empCode;
                    SqlCAHistory.SelectParameters["Payee"].DefaultValue = empCode;

                    drpdown_currency.Value = "PHP";
                    drpdown_currency.DataBind();

                    SqlUserSelf.SelectParameters["EmpCode"].DefaultValue = empCode;

                    var disburse_stat = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Disbursed")
                        .FirstOrDefault();

                    var unliquidated_CA = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.Status == Convert.ToInt32(disburse_stat.STS_Id));

                    PLD.MinDate = DateTime.Now;
                    if(unliquidated_CA.Count() > 0)
                    {
                        //CAWarningPopup
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

        protected void formRFP_Init(object sender, EventArgs e)
        {
            if (!IsPostBack || (Session["DataSetDoc"] == null))
            {
                dsDoc = new DataSet();
                DataTable masterTable = new DataTable();
                masterTable.Columns.Add("ID", typeof(int));
                masterTable.Columns.Add("FileName", typeof(string));
                masterTable.Columns.Add("FileByte", typeof(byte[]));
                masterTable.Columns.Add("FileExt", typeof(string));
                masterTable.Columns.Add("FileSize", typeof(string));
                masterTable.Columns.Add("FileDesc", typeof(string));
                masterTable.PrimaryKey = new DataColumn[] { masterTable.Columns["ID"] };

                dsDoc.Tables.AddRange(new DataTable[] { masterTable/*, detailTable*/ });
                Session["DataSetDoc"] = dsDoc;

            }
            else
                dsDoc = (DataSet)Session["DataSetDoc"];
            DocuGrid.DataSource = dsDoc.Tables[0];
            DocuGrid.DataBind();
        }

        protected void formEmployee_DataBound(object sender, EventArgs e)
        {

        }

        protected void formRFP_E2_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            
        }

        protected void formRFP_E4_Callback(object sender, CallbackEventArgsBase e)
        {
            SqlDepartment.SelectParameters["CompanyId"].DefaultValue = e.Parameter.ToString();
            SqlDepartment.DataBind();

            drpdown_Department.DataSourceID = null;
            drpdown_Department.DataSource = SqlDepartment;
            drpdown_Department.DataBind();

            var dept = _DataContext.ITP_S_SecurityAppUserCompanyDepts.Where(x => x.CompanyId == Convert.ToInt32(e.Parameter.ToString()))
                .Where(x => x.UserId == Session["userID"].ToString());

            //if(dept != null)
            //{
            //    drpdown_Department.SelectedIndex = 0;
            //}
            
        }

        [WebMethod]
        public static string CostCenterUpdateField(string dept_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            var cc = rfp.GetCostCenter(dept_id);
            return cc;
        }

        public string GetCostCenter(string dept_id)
        {
            var cc = _DataContext.ITP_S_OrgDepartmentMasters.Where(x=>x.ID == Convert.ToInt32(dept_id)).FirstOrDefault();

            if(cc.SAP_CostCenter != null)
            {
                return cc.SAP_CostCenter.ToString();
            }

            return "";
        }

        protected void btnSubmitFinal_Click(object sender, EventArgs e)
        {

        }

        protected void WFSequenceGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            SqlWorkflowSequence.SelectParameters["WF_Id"].DefaultValue = drpdown_WF.Value != null ? drpdown_WF.Value.ToString() : "";
            SqlWorkflowSequence.DataBind();

            WFSequenceGrid.DataSourceID = null;
            WFSequenceGrid.DataSource = SqlWorkflowSequence;
            WFSequenceGrid.DataBind();
        }

        [WebMethod]
        public static string PayeeDefaultValueAJAX()
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.PayeeDefaultValue();
        }

        public string PayeeDefaultValue()
        {
            var userFullname = _DataContext.ITP_S_UserMasters.Where(x=>x.EmpCode == Session["userID"].ToString()).FirstOrDefault();
            return userFullname.FullName.ToString();
        }

        [WebMethod]
        public static int InsertRFPMainAjax(string Comp_ID, string Dept_ID, string Paymethod, string tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, string amount, string purpose, string wf_id, string status, string exp_id, string fap, string wbs, string pld, string curr, string travType, string classification, string CTCompanyId, string CTDepartmentId, string compLoc)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            return rfp.InsertRFPMain(Convert.ToInt32(Comp_ID), Convert.ToInt32(Dept_ID), Convert.ToInt32(Paymethod), Convert.ToInt32(tranType), isTrav, costCenter, io, payee, lastDay, Convert.ToDecimal(amount), purpose, Convert.ToInt32(wf_id), Convert.ToInt32(status), Convert.ToInt32(exp_id), Convert.ToInt32(fap), wbs, pld, curr, travType, classification, CTCompanyId, CTDepartmentId, compLoc);
        }

        public int InsertRFPMain(int Comp_ID, int Dept_ID, int Paymethod, int tranType, bool isTrav, string costCenter, string io, string payee, string lastDay, decimal amount, string purpose, int wf_id, int status, int exp_id, int fap, string wbs, string pld, string curr, string travType, string classification, string CTCompanyId, string CTDepartmentId, string compLoc)
        {
            ITPORTALDataContext dbContxt = new ITPORTALDataContext(conString);
            SqlConnection conn = null;
            SqlDataReader rdr = null;

            GenerateDocNo generateDocNo = new GenerateDocNo();
            generateDocNo.RunStoredProc_GenerateDocNum(1011, Comp_ID, 1032);
            var docNum = generateDocNo.GetLatest_DocNum(1011, Comp_ID, 1032);

            string sp_name = "sp_ACCEDE_Insert_RFPMain";
            
            try
            {
                // create and open a connection object
                conn = new
                    SqlConnection(conString);
                conn.Open();

                // 1. create a command object identifying
                // the stored procedure
                SqlCommand cmd = new SqlCommand(
                    sp_name, conn);

                // 2. set the command object so it knows
                // to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. add parameter to command, which
                // will be passed to the stored procedure
                cmd.Parameters.Add(
                    new SqlParameter("@Comp_ID", Comp_ID));
                cmd.Parameters.Add(
                    new SqlParameter("@Dept_ID", Dept_ID));
                cmd.Parameters.Add(
                    new SqlParameter("@payMethod", Paymethod));
                cmd.Parameters.Add(
                    new SqlParameter("@tranType", tranType));
                if (tranType == 1)
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@isCA", true));
                    cmd.Parameters.Add(
                    new SqlParameter("@isReim", false));
                }
                if (tranType == 2)
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@isCA", false));
                    cmd.Parameters.Add(
                    new SqlParameter("@isReim", true));
                }
                cmd.Parameters.Add(
                    new SqlParameter("@isTrav", isTrav));
                cmd.Parameters.Add(
                    new SqlParameter("@costCenter", costCenter));
                cmd.Parameters.Add(
                    new SqlParameter("@io", io));
                cmd.Parameters.Add(
                    new SqlParameter("@payee", payee));
                if(lastDay == "")
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@lastDay", null));
                }
                else
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@lastDay", lastDay));
                }
                cmd.Parameters.Add(
                    new SqlParameter("@amount", amount));
                cmd.Parameters.Add(
                    new SqlParameter("@purpose", purpose));
                cmd.Parameters.Add(
                    new SqlParameter("@wf_id", wf_id));
                cmd.Parameters.Add(
                    new SqlParameter("@docNum", docNum));
                cmd.Parameters.Add(
                    new SqlParameter("@user_id", Session["userID"].ToString()));
                cmd.Parameters.Add(
                    new SqlParameter("@status", status));
                cmd.Parameters.Add(
                    new SqlParameter("@date_created", DateTime.Now));
                if(exp_id != 0)
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@exp_id", exp_id));
                }
                cmd.Parameters.Add(
                    new SqlParameter("@fap", fap));
                if (Comp_ID != 5)
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@wbs", null));
                }
                else
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@wbs", wbs));
                }

                if (travType != "")
                {
                    if(travType == "1")
                    {
                        cmd.Parameters.Add(
                        new SqlParameter("@travType", true));
                    }
                    else
                    {
                        cmd.Parameters.Add(
                        new SqlParameter("@travType", false));
                    }
                    
                }
                else
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@travType", false));
                }
                cmd.Parameters.Add(
                    new SqlParameter("@CTCompanyId", Convert.ToInt32(CTCompanyId)));
                cmd.Parameters.Add(
                    new SqlParameter("@CTDepartment", Convert.ToInt32(CTDepartmentId)));

                //if(exp_cat != "")
                //{
                //    cmd.Parameters.Add(
                //    new SqlParameter("@acctCharged", exp_cat));
                //}
                //else
                //{
                //    cmd.Parameters.Add(
                //    new SqlParameter("@acctCharged", null));
                //}

                if (tranType == 1)
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@pld", pld));
                }
                else
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@pld", null));
                }

                if(classification != "")
                {
                    cmd.Parameters.Add(
                    new SqlParameter("@classification", classification));
                }
                
                //if(remarks != "")
                //{
                //    cmd.Parameters.Add(
                //    new SqlParameter("@remarks", remarks));
                //}

                cmd.Parameters.Add(
                new SqlParameter("@curr", curr));

                cmd.Parameters.Add(
                new SqlParameter("@CompLocation", Convert.ToInt32(compLoc)));

                // Add output parameter for generated ID
                SqlParameter outputParam = new SqlParameter("@GeneratedID", SqlDbType.Int);
                outputParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParam);

                // execute the command
                rdr = cmd.ExecuteReader();

                // Retrieve the generated ID from the output parameter
                int generatedID = Convert.ToInt32(outputParam.Value);

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
                            command.Parameters["@filename"].Value = row["FileName"];
                            command.Parameters["@file_byte"].Value = row["FileByte"];
                            command.Parameters["@desc"].Value = row["FileDesc"];
                            command.Parameters["@date_upload"].Value = DateTime.Now;
                            command.Parameters["@app_id"].Value = 1032;
                            command.Parameters["@comp_id"].Value = Comp_ID;
                            command.Parameters["@doc_id"].Value = generatedID;
                            command.Parameters["@doc_no"].Value = docNum;
                            command.Parameters["@user_id"].Value = Session["userID"] != null ? Session["userID"].ToString() : "0";
                            command.Parameters["@fileExt"].Value = row["FileExt"];
                            command.Parameters["@filesize"].Value = row["FileSize"];
                            command.Parameters["@docType"].Value = app_docType != null ? app_docType.DCT_Id : 0;
                            command.ExecuteNonQuery();
                        }

                        // Close the connection to the database
                        connection.Close();

                    }
                }

                if (status == 1)
                {
                    var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                                   where app.WF_Id == generatedID
                                   where app.Sequence == 1
                                   select app;

                    bool ins_wf = InsertWorkflowAct(generatedID);

                    if (!ins_wf)
                    {
                        return 0;
                    }

                }

                return generatedID;

            }
            catch (Exception e)
            {
                var error = e.Message;
                return 0;
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
                if (rdr != null)
                {
                    rdr.Close();
                }
              
            }
        }

        public bool InsertWorkflowAct(int RFP_ID)
        {
            try
            {
                var rfp_main_query = _DataContext.ACCEDE_T_RFPMains.Where(x => x.ID == RFP_ID).FirstOrDefault();
                var payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x=>x.ID == rfp_main_query.PayMethod).FirstOrDefault();
                var tranType = _DataContext.ACCEDE_S_RFPTranTypes.Where(x=>x.ID == rfp_main_query.TranType).FirstOrDefault();
                var sequence = 1;
                var wf_Id = rfp_main_query.WF_Id;

                //IF DOCUMENT WAS RECALLED
                if (rfp_main_query.Status == 15)//15 IS A RECALL STATUS
                {
                    var rfpDoctype = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE RFP").FirstOrDefault();
                    var wfAct = _DataContext.ITP_T_WorkflowActivities.Where(x => x.Document_Id == rfp_main_query.ID)
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.AppDocTypeId == rfpDoctype.DCT_Id)
                        .Where(x => x.Status == 15)//15 IS A RECALL STATUS
                        .FirstOrDefault();

                    var wfDetail = _DataContext.ITP_S_WorkflowDetails.Where(x=>x.WFD_Id == wfAct.WFD_Id).FirstOrDefault();
                    sequence = Convert.ToInt32(wfDetail.Sequence);
                    wf_Id = Convert.ToInt32(wfDetail.WF_Id);
                }
                //END RECALL PROCESS

                var Approver = from app in _DataContext.vw_ACCEDE_I_WFSetups
                               where app.WF_Id == wf_Id
                               where app.Sequence == sequence
                               select app;

                ITP_T_WorkflowActivity activity = new ITP_T_WorkflowActivity();

                foreach (var app in Approver)
                {
                    var org_id = app.OrgRole_Id;
                    var date2day = DateTime.Now;

                    //DELEGATE CHECK
                    foreach (var del in _DataContext.ITP_S_TaskDelegations.Where(x => x.OrgRole_ID_Orig == app.OrgRole_Id).Where(x => x.DateFrom <= date2day).Where(x => x.DateTo >= date2day).Where(x => x.isActive == true))
                    {
                        if (del != null)
                        {
                            org_id = del.OrgRole_ID_Delegate;
                        }

                    }

                    var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x=>x.DCT_Name == "ACDE RFP").Where(x=>x.App_Id == 1032).FirstOrDefault();

                    //INSERTING TO ACTIVITY TABLE
                    {
                        activity.Status = 1;
                        activity.DateAssigned = DateTime.Now;
                        activity.OrgRole_Id = org_id;
                        activity.WF_Id = app.WF_Id;
                        activity.WFD_Id = app.WFD_Id;
                        activity.IsActive = true;
                        activity.IsDelete = false;
                        activity.DateCreated = DateTime.Now;
                        activity.Document_Id = RFP_ID;
                        activity.AppId = app.App_Id;
                        activity.CompanyId = app.Company_Id;
                        activity.AppDocTypeId = app_docType.DCT_Id;
                    }
                    _DataContext.ITP_T_WorkflowActivities.InsertOnSubmit(activity);
                    _DataContext.SubmitChanges();

                    var creator_details = _DataContext.ITP_S_UserMasters.Where(x=>x.EmpCode == rfp_main_query.Payee.ToString()).FirstOrDefault();

                    bool emailApprover = SendEmailToApprover(app.UserId, Convert.ToInt32(app.Company_Id), creator_details.FullName, creator_details.Email, rfp_main_query.RFP_DocNum, rfp_main_query.DateCreated.ToString(), rfp_main_query.Purpose, payMethod.PMethod_name, tranType.RFPTranType_Name);

                    if (!emailApprover)
                    {
                        return false;
                    }
                }

                return true;
            }
            catch (Exception e)
            {
                return false;
            }
            
        }

        public bool SendEmailToApprover(string approver_id, int Comp_id, string creator_fullname, string creator_email, string doc_no, string date_created, string document_purpose, string payMethod, string tranType)
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
                        where texts.Type == "Email" && texts.Name == "Pending"
                        select texts;

                var emailMessage = "";
                var emailSubMessage = "";
                var emailColor = "";

                foreach (var text in queryText)
                {
                    emailSubMessage = text.Text2.ToString();
                    emailColor = text.Color.ToString();
                    emailMessage = text.Text1.ToString();
                }
                //End--     Get Text info

                string appName = "Request For Payment (RFP)";
                string recipientName = user_email.FName;
                string senderName = creator_fullname;
                string emailSender = creator_email;
                string emailSite = "https://devapps.anflocor.com";
                string sendEmailTo = user_email.Email;
                string emailSubject = doc_no + ": Pending for Approval";


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
                string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, "", emailSite, emailColor);

                if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo))
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }catch (Exception e)
            {
                return false;
            }
        }

        [WebMethod]
        public static decimal CheckMinAmountAJAX(int comp_id, int payMethod)
        {
            RFPCreationPage rfp = new RFPCreationPage();

            return rfp.CheckMinAmount(comp_id, payMethod);
        }

        public decimal CheckMinAmount(int comp_id, int payMethod)
        {
            var maxAmount = _DataContext.ACCEDE_M_CheckMinAmounts.Where(x=>x.CompanyId == comp_id).Where(x=>x.PayMethod_Id == payMethod).FirstOrDefault();
            if (maxAmount != null)
            {
                return Convert.ToDecimal(maxAmount.MaxAmount);
            }
            return 0;
        }

        protected void FAPWFGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            //var comp_id = e.Parameters.Split('|').Last();
            //var amount = e.Parameters.Split('|').First();

            //if(comp_id != "null")
            //{
            //    var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032).Where(x => x.Minimum <= Convert.ToDecimal(amount)).Where(x => x.Maximum >= Convert.ToDecimal(amount)).Where(x=>x.IsRA != true).FirstOrDefault();
            //    if (wf != null)
            //    {
            //        SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
            //        SqlFAPWF.DataBind();

            //        FAPWFGrid.DataSourceID = null;
            //        FAPWFGrid.DataSource = SqlFAPWF;
            //        FAPWFGrid.DataBind();

            //    }
            //    else
            //    {
            //        SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = "";
            //        SqlFAPWF.DataBind();

            //        FAPWFGrid.DataSourceID = null;
            //        FAPWFGrid.DataSource = SqlFAPWF;
            //        FAPWFGrid.DataBind();

            //        drpdwn_FAPWF.SelectedIndex = 0;
            //    }
            //}

            SqlFAPWF.SelectParameters["WF_Id"].DefaultValue = drpdwn_FAPWF.Value != null ? drpdwn_FAPWF.Value.ToString() : "";
            SqlFAPWF.DataBind();

            FAPWFGrid.DataSourceID = null;
            FAPWFGrid.DataSource = SqlFAPWF;
            FAPWFGrid.DataBind();

        }

        protected void drpdwn_FAPWF_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = drpdown_CTCompany.Value != null ? drpdown_CTCompany.Value : 0;
            var amount = spinEdit_Amount.Value != null ? spinEdit_Amount.Value : "0.00";
            var classTypeId = drpdown_classification.Value != null ? drpdown_classification.Value : 0;
            var classType = _DataContext.ACCEDE_S_ExpenseClassifications.Where(x => x.ID == Convert.ToInt32(classTypeId)).FirstOrDefault();
            var tripType = drpdown_TravType.Value != null ? drpdown_TravType.Value : "";

            if (Convert.ToInt64(comp_id) != 0)
            {
                if(classType != null)
                {
                    if (Convert.ToBoolean(classType.withFAPLogic) == true)
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == true)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                        else
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                    }
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                        .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                        .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                        .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                        .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                        else
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                    }
                }
                else
                {
                    if(tripType.ToString() == "1")
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == true)
                            .Where(x=>x.Description.Contains("foreign"))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                        else
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                    }
                    else
                    {
                        var wf = _DataContext.ITP_S_WorkflowHeaders.Where(x => x.Company_Id == Convert.ToInt32(comp_id)).Where(x => x.App_Id == 1032)
                            .Where(x => x.With_DivHead == false || x.With_DivHead == null)
                            .Where(x => x.Minimum <= Convert.ToDecimal(amount))
                            .Where(x => x.Maximum >= Convert.ToDecimal(amount))
                            .Where(x => x.IsRA == false || x.IsRA == null).FirstOrDefault();

                        if (wf != null)
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = wf.WF_Id.ToString();
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                        else
                        {
                            SqlFAPWF2.SelectParameters["WF_Id"].DefaultValue = "";
                            SqlFAPWF2.DataBind();

                            drpdwn_FAPWF.DataSourceID = null;
                            drpdwn_FAPWF.DataSource = SqlFAPWF2;
                            drpdwn_FAPWF.DataBindItems();
                            drpdwn_FAPWF.SelectedIndex = 0;
                        }
                    }
                    
                }



            }
            
        }

        protected void drpdown_WF_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter != "" ? e.Parameter.ToString() : "0";
            var depcode = _DataContext.ITP_S_OrgDepartmentMasters.Where(x => x.ID == Convert.ToInt32(param)).FirstOrDefault();
            //var amount = spinEdit_Amount.Value != null ? spinEdit_Amount.Value.ToString() : "0";
            SqlWF.SelectParameters["CompanyId"].DefaultValue = depcode != null ? depcode.Company_ID.ToString() : "0";
            SqlWF.SelectParameters["DepCode"].DefaultValue = depcode != null ? depcode.DepCode.ToString() : "0";
            SqlWF.DataBind();

            drpdown_WF.DataSourceID = null;
            drpdown_WF.DataSource = SqlWF;
            drpdown_WF.DataBind();

            var wf = _DataContext.vw_ACCEDE_I_UserWFAccesses.Where(x => x.CompanyId == Convert.ToInt32(drpdown_Company.Value))
                    .Where(x => x.UserId == Session["userID"].ToString())
                    .Where(x => x.DepCode == (depcode != null ? depcode.DepCode : "0"))
                    .Where(x => x.IsRA == true);

            if(wf != null )
            {
                if(wf.Count() == 1)
                {
                    drpdown_WF.SelectedIndex = 0;
                }
            }
        }

        DataSet dsDoc = null;
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
        protected void UploadController_FilesUploadComplete(object sender, FilesUploadCompleteEventArgs e)
        {
            // Create a new data table if it doesn't exist in the data set
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
                ImgDS.Tables[0].Rows.Add(row);


            }

            // Bind the data set to the grid view
            DocuGrid.DataSource = ImgDS.Tables[0];

            DocuGrid.DataBind();
        }

        protected void DocuGrid_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
        {
            int i = DocuGrid.FindVisibleIndexByKeyValue(e.Keys[DocuGrid.KeyFieldName]);
            //Control c = DocuGrid.FindDetailRowTemplateControl(i, "ASPxGridView2");
            e.Cancel = true;
            dsDoc = (DataSet)Session["DataSetDoc"];
            dsDoc.Tables[0].Rows.Remove(dsDoc.Tables[0].Rows.Find(e.Keys[DocuGrid.KeyFieldName]));
        }

        protected void DocuGrid_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
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

        [WebMethod]
        public static decimal MaxAmountAJAX(string comp_id)
        {
            RFPCreationPage rfp = new RFPCreationPage();
            return rfp.MaxAmountPerComp(Convert.ToInt32(comp_id));
        }

        public decimal MaxAmountPerComp(int comp_id)
        {
            try
            {
                var maxAmnt = _DataContext.ACCEDE_M_MaxAmntComps.Where(x=>x.CompanyId == comp_id).FirstOrDefault();
                if (maxAmnt != null)
                {
                    return Convert.ToDecimal(maxAmnt.MaxAmount);
                }
                else
                {
                    return 0;
                }
            }catch (Exception ex)
            {
                return 0;
            }
        }

        [WebMethod]
        public static bool UnliqCACheckAJAX()
        {
            RFPCreationPage rfp = new RFPCreationPage();
            return rfp.UnliqCACheck();
        }

        public bool UnliqCACheck()
        {
            var disburse_stat = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Disbursed").FirstOrDefault();
            var unliquidated_CA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.IsExpenseCA == true).Where(x => x.Status == Convert.ToInt32(disburse_stat.STS_Id)).Where(x=>x.Payee == Session["userID"].ToString());

            if (unliquidated_CA.Count() > 0)
            {
                return true;
            }
            return false;
        }

        protected void drpdown_Payee_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            if(comp_id != "")
            {
                SqlUser.SelectParameters["Company_ID"].DefaultValue = comp_id.ToString();
                SqlUser.SelectParameters["DelegateTo_UserID"].DefaultValue = Session["userID"].ToString();
                SqlUser.SelectParameters["DateFrom"].DefaultValue = DateTime.Now.ToString();
                SqlUser.SelectParameters["DateTo"].DefaultValue = DateTime.Now.ToString();
            }
            // Get the existing data from SqlDataSource
            DataView dv = SqlUser.Select(DataSourceSelectArguments.Empty) as DataView;

            if (dv != null)
            {
                // Convert DataView to DataTable to modify it
                DataTable dt = dv.ToTable();

                // Add a new row manually
                DataRow newRow = dt.NewRow();
                newRow["DelegateFor_UserID"] = Session["userID"].ToString();
                newRow["FullName"] = Session["userFullName"].ToString();
                dt.Rows.Add(newRow);

                // Rebind the ComboBox with the updated list
                drpdown_Payee.DataSource = dt;
                drpdown_Payee.TextField = "FullName";   // Ensure text field is set correctly
                drpdown_Payee.ValueField = "DelegateFor_UserID"; // Ensure value field is set correctly
                drpdown_Payee.DataBind();

                drpdown_Payee.Value = Session["userID"].ToString();
            }

        }

        protected void drpdown_currency_Callback(object sender, CallbackEventArgsBase e)
        {
            var travType = drpdown_TravType.Value != null ? drpdown_TravType.Value.ToString() : "";
            var USDCurrency = _DataContext.ACDE_T_Currencies.Where(x=>x.CurrDescription == "USD").FirstOrDefault();
            var PHPCurrency = _DataContext.ACDE_T_Currencies.Where(x => x.CurrDescription == "PHP").FirstOrDefault();
            if (travType == "1")
            {
                drpdown_currency.Value = USDCurrency.ID.ToString();
                drpdown_currency.Text = USDCurrency.CurrDescription.ToString();
                drpdown_currency.DataBind();
            }
            else
            {
                drpdown_currency.Value = PHPCurrency.ID.ToString();
                drpdown_currency.Text = PHPCurrency.CurrDescription.ToString();
                drpdown_currency.DataBind();
            }
            
        }

        protected void drpdown_CTDepartment_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();
            SqlCTDepartment.SelectParameters["Company_ID"].DefaultValue = comp_id;
            SqlCTDepartment.DataBind();

            drpdown_CTDepartment.DataSourceID = null;
            drpdown_CTDepartment.DataSource = SqlCTDepartment;
            drpdown_CTDepartment.DataBind();
        }

        protected void drpdown_CostCenter_Callback(object sender, CallbackEventArgsBase e)
        {
            var param = e.Parameter.Split('|');
            var comp_id = param[0];
            var Dept_id = param[1] != "null"? param[1] : "0";

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

        protected void drpdown_CompLocation_Callback(object sender, CallbackEventArgsBase e)
        {
            var comp_id = e.Parameter.ToString();

            SqlCompLocation.SelectParameters["Comp_Id"].DefaultValue = comp_id;
            SqlCompLocation.DataBind();

            drpdown_CompLocation.DataSourceID = null;
            drpdown_CompLocation.DataSource = SqlCompLocation;
            drpdown_CompLocation.DataBind();
        }

        protected void CAHistoryGrid_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var user = e.Parameters.ToString();

            SqlCAHistory.SelectParameters["Payee"].DefaultValue = user;
            CAHistoryGrid.DataSourceID = null;
            CAHistoryGrid.DataSource = SqlCAHistory;
            CAHistoryGrid.DataBind();
        }

        protected void CAHistoryGrid2_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
            var user = e.Parameters.ToString();

            SqlCAHistory.SelectParameters["Payee"].DefaultValue = user;
            SqlCAHistory.DataBind();

            CAHistoryGrid2.DataSourceID = null;
            CAHistoryGrid2.DataSource = SqlCAHistory;
            CAHistoryGrid2.DataBind();
        }
    }
}