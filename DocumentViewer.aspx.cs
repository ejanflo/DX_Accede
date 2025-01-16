using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class DocumentViewer : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {

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

                var app_docType = _DataContext.ITP_S_DocumentTypes.Where(x => x.DCT_Name == "ACDE Expense").Where(x => x.App_Id == 1032).FirstOrDefault();

                ITP_T_FileAttachment docs = new ITP_T_FileAttachment();
                {
                    docs.FileAttachment = file.FileBytes;
                    docs.FileName = file.FileName;
                    docs.Doc_ID = Convert.ToInt32(Session["ExpenseId"]);
                    docs.App_ID = 1032;
                    docs.DocType_Id = 1016;
                    docs.User_ID = Session["userID"].ToString();
                    docs.FileExtension = file.FileName.Split('.').Last();
                    docs.Description = file.FileName.Split('.').First();
                    docs.FileSize = filesizeStr;
                    docs.Doc_No = Session["DocNo"].ToString();
                    docs.Company_ID = Convert.ToInt32(Session["userCompanyID"]);
                    docs.DateUploaded = DateTime.Now;
                    docs.DocType_Id = app_docType != null ? app_docType.DCT_Id : 0;
                };
                _DataContext.ITP_T_FileAttachments.InsertOnSubmit(docs);
            }
            _DataContext.SubmitChanges();
            SqlDocs.DataBind();
        }

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

            if (contentType.Equals("png", StringComparison.OrdinalIgnoreCase) || contentType.Equals("jpg", StringComparison.OrdinalIgnoreCase) || contentType.Equals("jpeg", StringComparison.OrdinalIgnoreCase) || contentType.Equals("gif", StringComparison.OrdinalIgnoreCase))
            {
                string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            else
                return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }

        [WebMethod]
        public static object AJAXGetTempDocument(string fileId, string appId)
        {
            DocumentViewer doc = new DocumentViewer();

            return doc.GetTempDocument(fileId, appId);
        }

        public object GetTempDocument(string fileId, string appId)
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

            if (contentType.Equals("png", StringComparison.OrdinalIgnoreCase) || contentType.Equals("jpg", StringComparison.OrdinalIgnoreCase) || contentType.Equals("jpeg", StringComparison.OrdinalIgnoreCase) || contentType.Equals("gif", StringComparison.OrdinalIgnoreCase))
            {
                string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                return new { FileName = fileName, ContentType = contentType, Data = base64String };
            }
            else
                return new { FileName = fileName, ContentType = contentType, Data = bytes };
        }
    }
}