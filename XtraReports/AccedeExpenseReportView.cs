using DevExpress.XtraReports.UI;

namespace DX_WebTemplate.XtraReports
{
    public partial class AccedeExpenseReportView : DevExpress.XtraReports.UI.XtraReport
    {
        public AccedeExpenseReportView()
        {
            InitializeComponent();
        }

        private void xrLabel10_PreviewClick(object sender, PreviewMouseEventArgs e)
        {
            if (xrSubreport3.Visible == false)
            {
                xrSubreport3.Visible = true;
                xrSubreport4.Visible = false;
            }
            else
            {
                xrSubreport3.Visible = false;
            }
        }
    }
}
