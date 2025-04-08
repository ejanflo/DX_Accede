using DevExpress.Web;
using DevExpress.XtraCharts;
using DevExpress.XtraReports.Design.ParameterEditor;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class AccedeExpenseViewPage : System.Web.UI.Page
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

                    var expID = Session["ExpenseId"];
                    var expDetails = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(expID))
                        .FirstOrDefault();

                    sqlMain.SelectParameters["ID"].DefaultValue = expDetails.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlCA.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlReim.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = expDetails.ID.ToString();

                    var exp = _DataContext.ACCEDE_T_ExpenseMains
                        .Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"]))
                        .FirstOrDefault();

                    SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                    SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                    var status_id = exp.Status.ToString();
                    var user_id = exp.UserId.ToString();

                    var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;
                    var btnRecall = FormExpApprovalView.FindItemOrGroupByName("recallBtn") as LayoutItem;
                    var btn_Edit = FormExpApprovalView.FindItemOrGroupByName("edit_btn") as LayoutItem;

                    if (myLayoutGroup != null)
                    {
                        myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";
                    }

                    var RFPCA = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"]))
                        .Where(x => x.IsExpenseCA == true)
                        .Where(x => x.isTravel != true);

                    decimal totalCA = 0;
                    foreach (var item in RFPCA)
                    {
                        totalCA += Convert.ToDecimal(item.Amount);
                    }
                    caTotal.Text = totalCA.ToString("#,##0.00") + "  PHP ";

                    var ExpDetails = _DataContext.ACCEDE_T_ExpenseDetails.Where(x => x.ExpenseMain_ID == Convert.ToInt32(Session["ExpenseId"]));
                    decimal totalExp = 0;
                    foreach (var item in ExpDetails)
                    {
                        totalExp += Convert.ToDecimal(item.NetAmount);
                    }
                    expenseTotal.Text = totalExp.ToString("#,##0.00") + "  PHP ";
                    decimal dueComp = totalCA - totalExp;

                    if(dueComp < 0)
                    {
                        var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Employee";
                    }
                    else
                    {
                        var dueField = FormExpApprovalView.FindItemOrGroupByName("due_lbl") as LayoutItem;
                        dueField.Caption = "Net Due to Company";

                        if (dueComp > 0)
                        {
                            var AR_Reference = FormExpApprovalView.FindItemOrGroupByName("ARNo") as LayoutItem;
                            AR_Reference.ClientVisible = true;
                        }
                    }

                    dueTotal.Text = FormatDecimal(dueComp) + "  PHP ";
                    var returnAuditStats = _DataContext.ITP_S_Status
                        .Where(x=>x.STS_Name == "Returned by Audit")
                        .FirstOrDefault();

                    var returnP2PStats = _DataContext.ITP_S_Status
                        .Where(x => x.STS_Name == "Returned by P2P")
                        .FirstOrDefault();

                    if (status_id == "3" || status_id == "13" || status_id == "15" || status_id == returnAuditStats.STS_Id.ToString() || status_id == returnP2PStats.STS_Id.ToString() && user_id == Session["userID"].ToString())
                    {
                        btn_Edit.ClientVisible = true;
                    }
                    var PendingAuditStat = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Pending at Audit").FirstOrDefault();
                    if (status_id == PendingAuditStat.STS_Id.ToString())
                    {
                        var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                        print.ClientVisible = true;
                    }

                    if (status_id == "1" && expDetails.UserId == empCode)
                    {
                        btnRecall.ClientVisible = true;
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

        public static string FormatDecimal(decimal value)
        {
            if (value < 0)
            {
                return $"({Math.Abs(value).ToString("#,##0.00")})";
            }
            return value.ToString("#,##0.00");
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            Session["cID"] = Session["ExpenseId"];
            Response.Redirect("~/AccedeExpenseReportPrinting.aspx");
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
        public static string RecallExpMainAJAX(string remarks)
        {
            AccedeExpenseViewPage exp = new AccedeExpenseViewPage();

            return exp.RecallExpMain(remarks);
        }

        public string RecallExpMain(string remarks)
        {
            try
            {
                string remarksInput = remarks.Trim();
                var doc_id = Convert.ToInt32(Session["ExpenseId"]);
                var approver_org_id = 0;
                var expDocType = _DataContext.ITP_S_DocumentTypes
                    .Where(x => x.DCT_Name == "ACDE Expense")
                    .FirstOrDefault();

                if (!string.IsNullOrEmpty(remarksInput))
                {
                    foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.Document_Id == doc_id)
                        .Where(x => x.AppDocTypeId == expDocType.DCT_Id)
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Status == 1))
                    {
                        rs.Status = 15;
                        rs.DateAction = DateTime.Now;
                        rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                        approver_org_id = Convert.ToInt32(rs.OrgRole_Id.ToString());
                    }

                    var reimRFP = _DataContext.ACCEDE_T_RFPMains
                        .Where(x => x.IsExpenseReim == true)
                        .Where(x => x.Status != 4)
                        .Where(x => x.Exp_ID == doc_id)
                        .Where(x => x.isTravel != true)
                        .FirstOrDefault();

                    if(reimRFP != null)
                    {
                        var rfpDocType = _DataContext.ITP_S_DocumentTypes
                            .Where(x => x.DCT_Name == "ACDE RFP")
                            .FirstOrDefault();

                        foreach (var rs in _DataContext.ITP_T_WorkflowActivities
                        .Where(x => x.Document_Id == reimRFP.ID)
                        .Where(x => x.AppDocTypeId == rfpDocType.DCT_Id)
                        .Where(x => x.AppId == 1032)
                        .Where(x => x.Status == 1))
                        {
                            rs.Status = 15;
                            rs.DateAction = DateTime.Now;
                            rs.Remarks = Session["AuthUser"].ToString() + ": " + remarksInput;
                        }
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

                    foreach (var item in _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == doc_id))
                    {
                        item.Status = 15;

                        comp_id = Convert.ToInt32(item.CompanyId);
                        doc_no = item.DocNo.ToString();
                        date_created = item.DateCreated.ToString();
                        document_purpose = item.Purpose;

                        approver_id = _DataContext.ITP_S_SecurityUserOrgRoles
                            .Where(x => x.OrgRoleId == approver_org_id)
                            .FirstOrDefault().UserId;

                        creator_fullname = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == item.UserId)
                            .FirstOrDefault().FullName;

                        creator_email = _DataContext.ITP_S_UserMasters
                            .Where(x => x.EmpCode == item.UserId)
                            .FirstOrDefault().Email;

                        if (item.PaymentType != null && item.PaymentType != 0)
                        {
                            payMethod = _DataContext.ACCEDE_S_PayMethods.Where(x => x.ID == item.PaymentType).FirstOrDefault().PMethod_name;
                        }

                        if (item.ExpenseType_ID != null && item.ExpenseType_ID != 0)
                        {
                            tranType = _DataContext.ACCEDE_S_ExpenseTypes.Where(x => x.ExpenseType_ID == item.ExpenseType_ID).FirstOrDefault().Description;
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

                        RFPViewPage exp = new RFPViewPage();
                        
                        exp.SendEmailToApprover(approver_id.ToString(), comp_id, creator_fullname, creator_email, doc_no, date_created, document_purpose, payMethod, tranType, remarks, "Recalled");

                    }

                }

                return "success";


            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
}