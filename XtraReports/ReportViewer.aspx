<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="ReportViewer.aspx.cs" Inherits="DX_WebTemplate.XtraReports.ReportViewer" %>

<%@ Register Assembly="DevExpress.XtraReports.v22.2.Web.WebForms, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.XtraReports.Web" TagPrefix="dx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <dx:ASPxWebDocumentViewer ID="ASPxWebDocumentViewer1" runat="server" OnLoad="Page_Load"></dx:ASPxWebDocumentViewer>
</asp:Content>
