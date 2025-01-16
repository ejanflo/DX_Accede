<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccedeExpenseReportPrint.aspx.cs" Inherits="DX_WebTemplate.AccedeExpenseReportPrint" %>

<%@ Register assembly="DevExpress.XtraReports.v22.2.Web.WebForms, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.XtraReports.Web" tagprefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title>ANFLOVERSE - ACCEDE Printing</title>
        <link rel="icon" type="image/x-icon" href="/Content/Images/favicon.ico" />
        <style>  
            .dxrd-preview .dxrd-right-panel-collapse, 
            .dxrd-preview .dxrd-right-panel, 
            .dxrd-preview .dxrd-right-tabs {
                display: none
            }  
        </style>
    </head>
    <script type="text/javascript">
        function OnMenuAction(s, e) {
            HideElement('Print', e);
            HideElement('Print Page', e);
            HideElement('Export To', e);
            HideElement('Search', e);
            HideElement('Highlight Editing Fields', e);
        }

        function HideElement(s, e) {
            var actionPrint = e.Actions.filter(function (action) { return action.text === s; })[0]
            var index = e.Actions.indexOf(actionPrint);
            e.Actions.splice(index, 1);
        }
    </script>
    <body style="overflow-x:auto">
        <form id="form1" runat="server">
            <div>
                <dx:ASPxWebDocumentViewer ID="docViewer" runat="server" ClientInstanceName="docViewer" DisableHttpHandlerValidation="False">
                    <ClientSideEvents CustomizeMenuActions="OnMenuAction" />
                </dx:ASPxWebDocumentViewer>
            </div>
        </form>
    </body>
</html>
