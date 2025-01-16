using DevExpress.Web;
using DevExpress.XtraCharts;
using DevExpress.XtraReports.Design.ParameterEditor;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
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
                    var expDetails = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(expID)).FirstOrDefault();
                    sqlMain.SelectParameters["ID"].DefaultValue = expDetails.ID.ToString();
                    SqlDocs.SelectParameters["Doc_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlCA.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlReim.SelectParameters["Exp_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlExpDetails.SelectParameters["ExpenseMain_ID"].DefaultValue = expDetails.ID.ToString();
                    SqlWFActivity.SelectParameters["Document_Id"].DefaultValue = expDetails.ID.ToString();

                    var exp = _DataContext.ACCEDE_T_ExpenseMains.Where(x => x.ID == Convert.ToInt32(Session["ExpenseId"])).FirstOrDefault();
                    SqlWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.WF_Id).ToString();
                    SqlFAPWFSequence.SelectParameters["WF_Id"].DefaultValue = Convert.ToInt32(exp.FAPWF_Id).ToString();

                    var status_id = exp.Status.ToString();
                    var user_id = exp.UserId.ToString();

                    var myLayoutGroup = FormExpApprovalView.FindItemOrGroupByName("ExpTitle") as LayoutGroup;

                    if (myLayoutGroup != null)
                    {
                        myLayoutGroup.Caption = exp.DocNo.ToString() + " (View)";
                    }

                    var RFPCA = _DataContext.ACCEDE_T_RFPMains.Where(x => x.Exp_ID == Convert.ToInt32(Session["ExpenseId"])).Where(x => x.IsExpenseCA == true);
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
                    }

                    dueTotal.Text = FormatDecimal(dueComp) + "  PHP ";
                    var returnAuditStats = _DataContext.ITP_S_Status.Where(x=>x.STS_Name == "Returned by Audit").FirstOrDefault();
                    var returnP2PStats = _DataContext.ITP_S_Status.Where(x => x.STS_Name == "Returned by P2P").FirstOrDefault();

                    if (status_id == "3" || status_id == "13" || status_id == "15" || status_id == returnAuditStats.STS_Id.ToString() || status_id == returnP2PStats.STS_Id.ToString() && user_id == Session["userID"].ToString())
                    {
                        btnEdit.ClientVisible = true;
                    }

                    if (status_id == "7")
                    {
                        var print = FormExpApprovalView.FindItemOrGroupByName("PrintBtn") as LayoutItem;
                        print.ClientVisible = true;
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
    }
}