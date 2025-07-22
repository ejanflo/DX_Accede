using DevExpress.Utils;
using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DX_WebTemplate
{
    public partial class TravelExpenseAddDetails : System.Web.UI.Page
    {
        ITPORTALDataContext _DataContext = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (AnfloSession.Current.ValidCookieUser())
                {
                    AnfloSession.Current.CreateSession(HttpContext.Current.User.ToString());

                    var expDetails = _DataContext.ACCEDE_T_TravelExpenseDetails.Where(x => x.TravelExpenseDetail_ID == Convert.ToInt32(Session["ExpDetailsID"])).FirstOrDefault();

                    if (expDetails != null)
                    {
                        travelDateCalendar1.Date = Convert.ToDateTime(expDetails.TravelExpenseDetail_Date);
                        totalExpTB1.Text = Convert.ToString(expDetails.Total_Expenses);

                        var action = Request.QueryString["action"];

                        if (action == "edit")
                        {
                            viewBtn2.Visible = true;
                            popupSubmitBtn1.Visible = true;
                            travelDateCalendar1.Enabled = true;
                            ASPxGridView23.Enabled = true;
                            TraUploadController1.Visible = true;
                            TraDocuGrid.Enabled = true;
                            TraDocuGrid.Columns[0].Visible = true;
                        }
                        else if(action == "view")
                        {
                            viewBtn2.Visible = false;
                            popupSubmitBtn1.Visible = false;
                            travelDateCalendar1.Enabled = false;
                            ASPxGridView23.Enabled = false;
                            TraUploadController1.Visible = false;
                            TraDocuGrid.Enabled = false;
                            TraDocuGrid.Columns[0].Visible = false;
                        }
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
                    docs.Company_ID = Convert.ToInt32(Session["userCompanyID"]);
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

        protected void TraDocuGrid_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
        {
            if (e.ButtonID == "btnView" || e.ButtonID == "btnView")
            {
                if (Convert.ToString(Session["doc_stat"]).Contains("Pending"))
                {
                    e.Visible = DefaultBoolean.True;
                }
            }
            else
            {
                e.Visible = DefaultBoolean.False;
            }
        }

        protected void TraDocuGrid_CommandButtonInitialize(object sender, ASPxGridViewCommandButtonEventArgs e)
        {
            if (e.ButtonType == ColumnCommandButtonType.Delete || e.ButtonType == ColumnCommandButtonType.Edit)
            {
                if (Convert.ToString(Session["doc_stat"]) == "Saved" || Convert.ToString(Session["doc_stat"]) == null || Convert.ToString(Session["doc_stat"]) == string.Empty)
                {
                    e.Visible = true;
                }
                else
                {
                    e.Visible = false;
                }
            }
        }
    }
}