using DevExpress.Web.Internal;
using DevExpress.Web.Internal.XmlProcessor;
using DevExpress.Xpo;
using DevExpress.XtraPrinting;
using DevExpress.XtraReports.UI;
using System;
using System.Configuration;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace DX_WebTemplate.XtraReports
{
    public partial class AccedeRFPForm : DevExpress.XtraReports.UI.XtraReport
    {

        public AccedeRFPForm()
        {
            InitializeComponent();

        }

        private void watermark_BeforePrint(object sender, System.ComponentModel.CancelEventArgs e)
        {
            watermark.SendToBack();
        }

        private void XtraReport1_BeforePrint(object sender, System.ComponentModel.CancelEventArgs e)
        {
            watermark.SendToBack();
        }

        private void xrPictureBox3_BeforePrint(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (this.Tag is byte[] imgBytes && imgBytes.Length > 0)
            {
                using (var ms = new MemoryStream(imgBytes))
                {
                    ((XRPictureBox)sender).Image = Image.FromStream(ms);
                }
            }
        }
    }
}
