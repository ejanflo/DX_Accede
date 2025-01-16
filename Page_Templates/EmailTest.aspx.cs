using DevExpress.XtraRichEdit.Model;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Page_Templates
{
    public partial class EmailTest : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            txtSendTo.Text = "jfpimentera@anflocor.com";
            txtSubject.Text = "CAR Pending for Approval: ANFLOCOR-2022300005";

            double amount = 1234412000000;
            string amountInWords = ANFLO.ConvertAmount(amount);

            //txtMessage.Text = amountInWords;

            txtMessage.Text = GetPesoRate(2).ToString();

            string prevPage = Request.Url.AbsoluteUri;
            txtMessage.Text = prevPage;
        }

        public decimal GetPesoRate(int currencyID)
        {
            var context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);
            decimal pesoRate = 0;

            try
            {
                pesoRate = context.ITP_S_ForeignExches
                    .Where(rate => rate.Currency_Id == currencyID && rate.DateValid <= DateTime.Now)
                    .OrderByDescending(doc => doc.DateValid)
                    .Select(rate => Convert.ToDecimal(rate.PesoRate))
                    .FirstOrDefault();
            }
            catch
            {
                pesoRate = 0;
            }

            return pesoRate;
        }

        protected void btnEmail_Click(object sender, EventArgs e)
        {
            var context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);

            ANFLO anflo = new ANFLO();

            string appName = "Capital Appropriation Request (CAR)";
            string recipientName = "Jessy";
            string senderName = "Jessy Pimentera";
            string emailSender = "jfpimentera@anflocor.com";
            string senderRemarks = txtMessage.Text;
            string emailSite = "http://localhost:61185/";
            string sendEmailTo = txtSendTo.Text;
            string emailSubject = txtSubject.Text;

            string emailMessage = "";
            string emailSubMessage = "";
            string emailColor = "";


            //Start--   Get Text info
            var queryText =
                   from texts in context.ITP_S_Texts
                   where texts.Type == "Email" && texts.Name == "Pending"
                   select texts;

            foreach (var text in queryText)
            {
                emailMessage = text.Text1.ToString();
                emailSubMessage = text.Text2.ToString();
                emailColor = text.Color.ToString();
            }
            //End--     Get Text info

            //Body Details Sample
            string emailDetails = "";
            
            var queryCAR =
                from car in context.ITP_S_SecurityApps
                where car.App_Id <= 15
                select car;

            emailDetails = "<table border='0' cellpadding='0' cellspacing='0' width='100%' class='main' style='border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;background:#fff;border-radius:3px;width:100%;'>";

            foreach ( var item in queryCAR )
            {
                emailDetails +=
                            "<tr>" +
                            "<td>" + item.App_Description + "</td>" +
                            "<td>" + item.App_Name + "</td>" +
                            "<td>" + item.App_Id + "</td>" +
                            "</tr>";
            }

            emailDetails += "</table>";
            //End of Body Details Sample

            
            string emailTemplate = anflo.Email_Content_Formatter(appName, recipientName, emailMessage, emailSubMessage, senderName, emailSender, emailDetails, senderRemarks, emailSite, emailColor);


            if (anflo.Send_Email(emailSubject, emailTemplate, sendEmailTo)){
                //Do something here
                System.Windows.Forms.MessageBox.Show("Email Sent");
            }
            else
            {
                //Do something here
                System.Windows.Forms.MessageBox.Show("Email NOT Sent");
            }
        }
    }
}