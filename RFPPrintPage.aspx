<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RFPPrintPage.aspx.cs" Inherits="DX_WebTemplate.RFPPrintPage" %>

<%@ Register assembly="DevExpress.XtraReports.v22.2.Web.WebForms, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.XtraReports.Web" tagprefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ANFLOVERSE - ACCEDE Printing</title>
    <link rel="icon" type="image/x-icon" href="/Content/Images/favicon.ico" />
</head>
<script>
    function LogWebDocumentViewerCommand(commandName, exportFormat) {
        $.ajax({
            type: "POST",
            url: "RFPPrintPage.aspx/SetRePrintAJAX",
            data: JSON.stringify({ val: true }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                // Handle success
                //alert("success");
            },
            failure: function (response) {
                // Handle failure
            }
        });
    } 

    function WebDocumentViewer_CustomizeMenuActions(s, e) {
        var printAction = e.Actions.filter(function (x) { return x.imageClassName === "dxrd-image-print"; })[0];
        if (printAction) {
            var defaultPrintClickAction = printAction.clickAction;
            printAction.clickAction = function () {
                defaultPrintClickAction();
                LogWebDocumentViewerCommand("Print", "pdf");
            }
        }

        var printPageAction = e.Actions.filter(function (x) { return x.imageClassName === "dxrd-image-print-page"; })[0];
        if (printPageAction) {
            var defaultPrintPageClickAction = printPageAction.clickAction;
            printPageAction.clickAction = function () {
                defaultPrintPageClickAction();
                LogWebDocumentViewerCommand("PrintPage", "pdf");
            }
        }

        var exportAction = e.Actions.filter(function (x) { return x.templateName === "dxrd-preview-export-to"; })[0];
        if (exportAction) {
            var defaultExportClickAction = exportAction.clickAction;
            exportAction.clickAction = function (arg) {
                defaultExportClickAction(arg);
                if (arg.itemData.format) {
                    LogWebDocumentViewerCommand("Export", arg.itemData.format);
                }
            }
        }
    }  

</script>
<body style="overflow-x:auto">
    <form id="form1" runat="server">
        <div>
            <dx:ASPxWebDocumentViewer ID="ASPxWebDocumentViewer1" runat="server" ClientInstanceName="ASPxWebDocumentViewer1" DisableHttpHandlerValidation="False">
                <ClientSideEvents CustomizeMenuActions="WebDocumentViewer_CustomizeMenuActions" />
            </dx:ASPxWebDocumentViewer>
        </div>
    </form>
</body>
</html>
