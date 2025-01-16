<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccedeExpenseReportPrinting.aspx.cs" Inherits="DX_WebTemplate.AccedeExpenseReportPrinting" %>

<%@ Register assembly="DevExpress.XtraReports.v22.2.Web.WebForms, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.XtraReports.Web" tagprefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ANFLOVERSE - ACCEDE Printing</title>
    <link rel="icon" type="image/x-icon" href="/Content/Images/favicon.ico" />
</head>
<body style="overflow-x:auto">
    <form id="form1" runat="server">
        <div>
            <dx:ASPxWebDocumentViewer ID="ASPxWebDocumentViewer1" runat="server" ClientInstanceName="ASPxWebDocumentViewer1">
            </dx:ASPxWebDocumentViewer>
        </div>
    </form>
</body>
</html>
