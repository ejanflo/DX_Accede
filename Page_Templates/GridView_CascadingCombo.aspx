<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="GridView_CascadingCombo.aspx.cs" Inherits="DX_WebTemplate.Page_Templates.GridView_CascadingCombo" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        function AppTypeCombo_SelectedIndexChanged(s, e) {
            gridTest.GetEditor("cboApp").PerformCallback(s.GetValue());
            //gridTest.PerformCallback(s.GetValue());
        }  
    </script>
    <dx:ASPxGridView ID="gridTest" runat="server" AutoGenerateColumns="False" DataSourceID="sqlTestTable" KeyFieldName="ID" OnCellEditorInitialize="gridTest_CellEditorInitialize" OnCustomCallback="gridTest_CustomCallback">
        <SettingsEditing Mode="Inline">
        </SettingsEditing>
        <SettingsPopup>
            <FilterControl AutoUpdatePosition="False">
            </FilterControl>
        </SettingsPopup>
        <Columns>
            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowNewButtonInHeader="True" VisibleIndex="0">
            </dx:GridViewCommandColumn>
            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" VisibleIndex="1">
                <EditFormSettings Visible="False" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataComboBoxColumn FieldName="AppType_ID" VisibleIndex="2">
                <PropertiesComboBox ClientInstanceName="cboAppType" DataSourceID="sqlSecAppType" TextField="AppType_Name" ValueField="AppType_Id">
                    <ClientSideEvents SelectedIndexChanged="AppTypeCombo_SelectedIndexChanged" />
                </PropertiesComboBox>
            </dx:GridViewDataComboBoxColumn>
            <dx:GridViewDataComboBoxColumn FieldName="App_ID" VisibleIndex="3">
                <PropertiesComboBox ClientInstanceName="cboApp" DataSourceID="sqlSecApp" TextField="App_Name" ValueField="App_Id">
                </PropertiesComboBox>
            </dx:GridViewDataComboBoxColumn>
        </Columns>
    </dx:ASPxGridView>
    <asp:SqlDataSource ID="sqlSecAppType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityAppTypes]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlTestTable" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_TestTable] WHERE [ID] = @original_ID AND (([AppType_ID] = @original_AppType_ID) OR ([AppType_ID] IS NULL AND @original_AppType_ID IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL))" InsertCommand="INSERT INTO [ITP_T_TestTable] ([AppType_ID], [App_ID]) VALUES (@AppType_ID, @App_ID)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_T_TestTable]" UpdateCommand="UPDATE [ITP_T_TestTable] SET [AppType_ID] = @AppType_ID, [App_ID] = @App_ID WHERE [ID] = @original_ID AND (([AppType_ID] = @original_AppType_ID) OR ([AppType_ID] IS NULL AND @original_AppType_ID IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_AppType_ID" Type="Int32" />
            <asp:Parameter Name="original_App_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="AppType_ID" Type="Int32" />
            <asp:Parameter Name="App_ID" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="AppType_ID" Type="Int32" />
            <asp:Parameter Name="App_ID" Type="Int32" />
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_AppType_ID" Type="Int32" />
            <asp:Parameter Name="original_App_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlSecApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityApp] WHERE ([AppType_Id] = @AppType_Id)">
        <SelectParameters>
            <asp:Parameter Name="AppType_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
