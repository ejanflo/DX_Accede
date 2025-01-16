using DevExpress.Web;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate
{
    public partial class TestPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ASPxGridView1_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
        {
            if (e.DataColumn.FieldName == "TravelTime" && e.CellValue != null)
            {
                // Customize the display format as needed
                e.Cell.Text = Convert.ToDateTime(e.CellValue).ToString("HH:mm:ss");
            }
        }

        protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            //// Assuming "YourTimeColumnName" is the name of the time column in your data source
            //string userInput = e.NewValues["TravelTime"] as string;

            //if (TimeSpan.TryParse(userInput, out TimeSpan timeValue))
            //{
            //    // Update the data source with the parsed time value
            //    e.NewValues["TravelTime"] = timeValue;
            //}
            //else
            //{
            //    // Cancel the insertion and display an error message
            //    e.Cancel = true;
            //    // Display an error message or take appropriate action
            //}
            //string test = e.NewValues["TravelTime"].ToString();

            //string dateTime = "1/2/1991 " + Convert.ToDateTime(test).ToString("HH:mm:ss tt");

            //DateTime finalDatetime = Convert.(dateTime);
            //e.NewValues["TravelTime"] = finalDatetime;

            // Sample TimeSpan representing 2 hours and 30 minutes
            TimeSpan travelTime = TimeSpan.FromHours(2).Add(TimeSpan.FromMinutes(30));

            // Reference date for smalldatetime in SQL Server is January 1, 1900
            DateTime baseDate = new DateTime(1900, 1, 1);

            // Combine the base date with the TimeSpan to create a DateTime object
            DateTime dateTimeValue = baseDate.Add(travelTime);

            e.NewValues["TravelTime"] = dateTimeValue;
        }
    }
}