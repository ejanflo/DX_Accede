using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;

namespace DX_WebTemplate
{
    /// <summary>
    /// Summary description for FileHandler
    /// </summary>
    public class FileHandler : IHttpHandler
    {

        ITPORTALDataContext dbContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
        public void ProcessRequest(HttpContext context)
        {


            string id = context.Request["id"];
            //Path.GetFileNameWithoutExtension(fileName)

            try
            {
                var queryFile =
                from file in dbContext.ITP_T_FileAttachments
                where file.ID == Convert.ToInt32(id)
                select file;
                foreach (var fileInfo in queryFile)
                {
                    ExportToResponse(context, fileInfo.FileAttachment.ToArray(), Path.GetFileNameWithoutExtension(fileInfo.FileName), fileInfo.FileName.Split('.').Last(), false);
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(ex.Message);
            }


        }


        /// <summary>
        /// Process the downloading of files
        /// </summary>
        /// <param name="context">URL sent</param>
        /// <param name="content">File</param>
        /// <param name="fileName">Filename</param>
        /// <param name="fileType">File Extension</param>
        /// <param name="inline"></param>
        public void ExportToResponse(HttpContext context, byte[] content, string fileName, string fileType, bool inline)
        {
            context.Response.Clear();
            context.Response.ContentType = "application/" + fileType;
            context.Response.AddHeader("Content-Disposition", string.Format("{0}; filename={1}.{2}", inline ? "Inline" : "Attachment", fileName, fileType));
            context.Response.AddHeader("Content-Length", content.Length.ToString());
            //Response.ContentEncoding = System.Text.Encoding.Default;
            context.Response.BinaryWrite(content);
            context.Response.Flush();
            context.Response.Close();
            context.Response.End();
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}