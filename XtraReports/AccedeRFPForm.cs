using DevExpress.Web.Internal;
using DevExpress.XtraReports.UI;
using System.Windows.Forms;
using System;
using DevExpress.XtraPrinting;
using System.Configuration;
using DevExpress.Xpo;
using DevExpress.Web.Internal.XmlProcessor;
using System.Diagnostics;

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
    }
}
