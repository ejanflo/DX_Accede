using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Security.Principal;
using System.Web;
using System.Web.Security;

using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;

namespace DX_WebTemplate
{
    public class ANFLO
    {
        Dictionary<string, string> dict;

        string conString = ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString;

        private static String[] units = { "Zero", "One", "Two", "Three",
    "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven",
    "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen" };
        private static String[] tens = { "", "", "Twenty", "Thirty", "Forty",
    "Fifty", "Sixty", "Seventy", "Eighty", "Ninety" };

        public static String ConvertAmount(double amount)
        {
            try
            {
                Int64 amount_int = (Int64)amount;
                Int64 amount_dec = (Int64)Math.Round((amount - (double)(amount_int)) * 100);
                if (amount_dec == 0)
                {
                    return Convert(amount_int) + "Only.";
                }
                else
                {
                    return Convert(amount_int) + " Point " + Convert(amount_dec) + "Only.";
                }
            }
            catch (Exception)
            {
                // TODO: handle exception  
            }
            return "";
        }

        public static String Convert(Int64 i)
        {
            if (i < 20)
            {
                return units[i];
            }
            if (i < 100)
            {
                return tens[i / 10] + ((i % 10 > 0) ? " " + Convert(i % 10) : "");
            }
            if (i < 1000)
            {
                return units[i / 100] + " Hundred "
                        + ((i % 100 > 0) ? " And " + Convert(i % 100) : "");
            }
            if (i < 1000000)
            {
                return Convert(i / 1000) + " Thousand "
                        + ((i % 1000 > 0) ? " " + Convert(i % 1000) : "");
            }
            if (i < 1000000000)
            {
                return Convert(i / 1000000) + " Million "
                        + ((i % 1000000 > 0) ? " " + Convert(i % 1000000) : "");
            }
            if (i < 1000000000000)
            {
                return Convert(i / 1000000000) + " Billion "
                        + ((i % 1000000000 > 0) ? " " + Convert(i % 1000000000) : "");
            }
            return Convert(i / 1000000000000) + " Trillion "
                    + ((i % 1000000000000 > 0) ? " " + Convert(i % 1000000000000) : "");
        }


        /// <summary>
        /// Formats email notification's content
        /// </summary>
        /// <param name="AppName">Name of the Application</param>
        /// <param name="RecipientName">Name of Email Receiver</param>
        /// <param name="EmailMessage">Message to the Receiver</param>
        /// <param name="EmailSubMessage">Sub-Message for other info</param>
        /// <param name="SenderName">Name of the Email Sender</param>
        /// <param name="SenderEmail">Email address of the Email Sender</param>
        /// <param name="EmailDetails">Email content details</param>
        /// <param name="REMARKS">Remarks of the Email Sender</param>
        /// <param name="EmailSite">Url on where to redirect once the email button is clicked</param>
        /// <param name="EmailColor">Color theme of the email notification</param>
        /// <param name="DocumentType">Email format type, default is ITPORTAL</param>
        /// <returns></returns>
        public string Email_Content_Formatter(string AppName, string RecipientName, string EmailMessage, string EmailSubMessage, string SenderName, string SenderEmail, string EmailDetails, string REMARKS, string EmailSite, string EmailColor = "#006838", string DocumentType = "ITPORTAL")
        {
            string eTemplate = "";

            try
            {
                var context = new ITPORTALDataContext(conString);

                //START: Email Template
                var queryEmailTemp =
                       from temp in context.ITP_S_EmailTemplates
                       where temp.Type == DocumentType
                       select temp;

                foreach (var emailTemp in queryEmailTemp)
                {
                    eTemplate = emailTemp.Template;

                    eTemplate = eTemplate.Replace("@ApplicationName", AppName);
                    eTemplate = eTemplate.Replace("@FirstName", RecipientName);
                    eTemplate = eTemplate.Replace("@Message", EmailMessage);
                    eTemplate = eTemplate.Replace("@SubMessage", EmailSubMessage);
                    eTemplate = eTemplate.Replace("@BODY", EmailDetails);
                    eTemplate = eTemplate.Replace("@REMARKS", REMARKS);
                    eTemplate = eTemplate.Replace("@SENDER", SenderName);
                    eTemplate = eTemplate.Replace("@SenderEmail", SenderEmail);
                    eTemplate = eTemplate.Replace("@Site", EmailSite);
                    eTemplate = eTemplate.Replace("@Color", EmailColor);

                }
                //END: Email Template


            }
            catch (Exception ex)
            {
                eTemplate = "ERROR: " + ex;
            }

            return eTemplate;
        }


        public bool Send_Email(String emailSubject, String emailBody, String sendTo, String cc)//, String sendTo = "jfpimentera@anflocor.com")
        {
            bool EmailIsSent = false;

            MailMessage m = new MailMessage();
            SmtpClient sc = new SmtpClient();
            try
            {
                m.From = new MailAddress("noreply@anflocor.com");
                m.To.Add(new MailAddress(sendTo));
                m.CC.Add(new MailAddress(cc));
                m.Subject = emailSubject;
                m.IsBodyHtml = true;
                m.Body = emailBody;

                sc.Send(m);

                EmailIsSent = true;
            }
            catch (Exception ex)
            {
                EmailIsSent = false;
                Console.WriteLine(ex.Message);
            }


            return EmailIsSent;
        }

        public bool Send_Email(String emailSubject, String emailBody, String sendTo)//, String sendTo = "jfpimentera@anflocor.com")
        {
            bool EmailIsSent = false;

            MailMessage m = new MailMessage();
            SmtpClient sc = new SmtpClient();
            try
            {
                m.From = new MailAddress("noreply@anflocor.com");
                m.To.Add(new MailAddress(sendTo));
                m.Subject = emailSubject;
                m.IsBodyHtml = true;
                m.Body = emailBody;

                sc.Send(m);

                EmailIsSent = true;
            }
            catch (Exception ex)
            {
                EmailIsSent = false;
                Console.WriteLine(ex.Message);
            }


            return EmailIsSent;
        }

        public bool Send_Email_With_Attachment(String emailSubject, String emailBody, String sendTo, String attachments)//, String sendTo = "jfpimentera@anflocor.com")
        {
            bool EmailIsSent = false;

            MailMessage m = new MailMessage();
            SmtpClient sc = new SmtpClient();
            try
            {
                m.From = new MailAddress("noreply@anflocor.com");
                m.To.Add(new MailAddress(sendTo));
                //m.To.Add(new MailAddress("jfpimentera@anflocor.com"));

                //m.Subject = emailSubject + " | " + sendTo;
                m.Subject = emailSubject;
                m.IsBodyHtml = true;
                m.Body = emailBody;
                //m.Attachments.Add(new Attachment("D:\\sampleAttach.txt"));
                m.Attachments.Add(new Attachment(attachments));

                sc.Send(m);

                EmailIsSent = true;
            }
            catch (Exception ex)
            {
                EmailIsSent = false;
                Console.WriteLine(ex.Message);
            }

            return EmailIsSent;
        }


        public bool Send_Email_TEST(String emailSubject, String emailBody, String sendTo)//, String sendTo = "jfpimentera@anflocor.com")
        {
            bool EmailIsSent = false;

            try
            {
                //try
                //{
                //    string fromEmail = "noreply@anflocor.com";
                //    string toEmail = sendTo;
                //    string subject = emailSubject;
                //    string body = emailBody;

                //    using (SmtpClient smtpClient = new SmtpClient())
                //    {
                //        using (MailMessage mailMessage = new MailMessage(fromEmail, toEmail, subject, body))
                //        {
                //            mailMessage.IsBodyHtml = true;
                //            smtpClient.Send(mailMessage);
                //        }
                //    }

                //    Console.WriteLine("Email sent successfully!");
                //    EmailIsSent = true;
                //}
                //catch (Exception ex)
                //{
                //    Console.WriteLine("An error occurred while sending the email: " + ex.ToString());
                //    EmailIsSent = false;
                //}


                //string smtpHost = "192.168.0.57";
                //int smtpPort = 25;
                //string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                //int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"].ToString());

                string fromEmail = "noreply@anflocor.com";
                string toEmail = sendTo;
                string subject = emailSubject;
                string body = emailBody;

                using (SmtpClient smtpClient = new SmtpClient())
                {
                    //smtpClient.Credentials = new NetworkCredential("noreply@anflocor.com", "");
                    //smtpClient.UseDefaultCredentials = true;
                    //smtpClient.EnableSsl = true;

                    using (MailMessage mailMessage = new MailMessage(fromEmail, toEmail, subject, body))
                    {
                        smtpClient.Send(mailMessage);
                    }
                }

                Console.WriteLine("Email sent successfully!");
                EmailIsSent = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while sending the email: " + ex.ToString());
                EmailIsSent = false;
            }



            ////string smtpHost = "192.168.0.57";
            ////int smtpPort = 25;

            ////MailMessage m = new MailMessage();
            ////SmtpClient sc = new SmtpClient(smtpHost, smtpPort);
            ////try
            ////{

            ////    sc.UseDefaultCredentials = true;
            ////    sc.Credentials = new System.Net.NetworkCredential("noreply@anflocor.com", ""); // Replace with your username and password
            ////    sc.EnableSsl = true;


            ////    m.From = new MailAddress("noreply@anflocor.com");
            ////    m.To.Add(new MailAddress(sendTo));
            ////    m.Subject = emailSubject;
            ////    m.IsBodyHtml = true;
            ////    m.Body = emailBody;

            ////    sc.Send(m);

            ////    EmailIsSent = true;
            ////}
            ////catch (Exception ex)
            ////{
            ////    EmailIsSent = false;
            ////    Console.WriteLine(ex.Message);
            ////}

            return EmailIsSent;
        }
    }

    //public void sampleDictionary()
    //{

    //    var empDict = new Dictionary<string, string>();

    //    empDict.Add("11001267", "Jessy Pimentera");
    //    empDict.Add("12345678", "Juan Dela Cruz");

    //    string empGwapo = empDict["11001267"];

    //    //how to retrieve the data from dictionary
    //    foreach (var emp in empDict)
    //        Console.WriteLine($"dictionary: {emp.Value}");
    //}

    

}