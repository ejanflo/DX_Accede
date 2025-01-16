<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TestPage.aspx.cs" Inherits="DX_WebTemplate.TestPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" KeyFieldName="ID" OnRowInserting="ASPxGridView1_RowInserting" OnHtmlDataCellPrepared="ASPxGridView1_HtmlDataCellPrepared">
<SettingsPopup>
<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>
        <Columns>
            <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
            </dx:GridViewCommandColumn>
            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                <EditFormSettings Visible="False" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Location" ShowInCustomizationForm="True" VisibleIndex="2">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="3">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataDateColumn FieldName="TravelDate" ShowInCustomizationForm="True" VisibleIndex="4">
            </dx:GridViewDataDateColumn>
            <dx:GridViewDataTextColumn FieldName="ACDE_Main_ID" ShowInCustomizationForm="True" VisibleIndex="5">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="ItineraryName" ShowInCustomizationForm="True" VisibleIndex="6">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="TravelType_ID" ShowInCustomizationForm="True" VisibleIndex="7">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTimeEditColumn FieldName="TravelTime" ShowInCustomizationForm="True" VisibleIndex="8">
                <PropertiesTimeEdit DisplayFormatString="" EditFormat="DateTime">
                </PropertiesTimeEdit>
            </dx:GridViewDataTimeEditColumn>
        </Columns>
    </dx:ASPxGridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACDE_T_Travel] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACDE_T_Travel] ([Location], [Sequence], [TravelDate], [TravelTime], [ACDE_Main_ID], [ItineraryName], [TravelType_ID]) VALUES (@Location, @Sequence, @TravelDate, @TravelTime, @ACDE_Main_ID, @ItineraryName, @TravelType_ID)" SelectCommand="SELECT * FROM [ACDE_T_Travel]" UpdateCommand="UPDATE [ACDE_T_Travel] SET [Location] = @Location, [Sequence] = @Sequence, [TravelDate] = @TravelDate, [TravelTime] = @TravelTime, [ACDE_Main_ID] = @ACDE_Main_ID, [ItineraryName] = @ItineraryName, [TravelType_ID] = @TravelType_ID WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Location" Type="String" />
            <asp:Parameter Name="Sequence" Type="String" />
            <asp:Parameter DbType="Date" Name="TravelDate" />
            <asp:Parameter Name="TravelTime" Type="DateTime" />
            <asp:Parameter Name="ACDE_Main_ID" Type="Int32" />
            <asp:Parameter Name="ItineraryName" Type="String" />
            <asp:Parameter Name="TravelType_ID" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Location" Type="String" />
            <asp:Parameter Name="Sequence" Type="String" />
            <asp:Parameter DbType="Date" Name="TravelDate" />
            <asp:Parameter Name="TravelTime" Type="Object" />
            <asp:Parameter Name="ACDE_Main_ID" Type="Int32" />
            <asp:Parameter Name="ItineraryName" Type="String" />
            <asp:Parameter Name="TravelType_ID" Type="Int32" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
</asp:Content>
