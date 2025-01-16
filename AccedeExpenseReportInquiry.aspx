<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeExpenseReportInquiry.aspx.cs" Inherits="DX_WebTemplate.AccedeExpenseReportInquiry" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
            <script>
        function OnCustomButtonClick(s, e) {
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            if (e.buttonID != "btnPrint") {
                loadPanel.Show();
            }           
        }

        function onToolbarItemClick(s, e) {
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.item.name);   
            if (e.item.name === "newReport") {
                window.location.href = "AccedeExpenseReportAdd.aspx";
            }
            //} else if (e.item.name === "print") {
            //    /*window.location.href = "WebClearPrintingSample.aspx";*/
            //    window.open('WebClearPrintingSample.aspx', '_blank');
            //}
        }
            </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="Expense Report Inquiry" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" Width="100%" DataSourceID="sqlExpense" KeyFieldName="ID" OnToolbarItemClick="expenseGrid_ToolbarItemClick" OnCustomCallback="expenseGrid_CustomCallback" OnCustomButtonInitialize="expenseGrid_CustomButtonInitialize">
                                            <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="onToolbarItemClick" EndCallback="function(s, e) {
	if(s.cp_btnid == &quot;btnView&quot; ||s.cp_btnid == &quot;btnEdit&quot; ){
                       window.open(s.cp_url, '_self');
                       delete(s.cp_btnid);
                       delete(s.cp_url);	
         }else if(s.cp_btnid == &quot;btnPrint&quot;){
                       window.open(s.cp_url, '_blank');
                       delete(s.cp_btnid);
                       delete(s.cp_url);
          }else{
                       delete(s.cp_btnid);
                       delete(s.cp_url);
          } 
}" />
                                            <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                            </SettingsAdaptivity>
                                            <SettingsPager AlwaysShowPager="True">
                                                <PageSizeItemSettings Visible="True" Items="5, 10, 20, 50, 100, 200">
                                                </PageSizeItemSettings>
                                            </SettingsPager>
                                            <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowClearButton="True" Visible="True" />
                                            <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG">
                                            </SettingsExport>
                                            <SettingsLoadingPanel Mode="Disabled" />
                                            <Columns>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="1" FieldName="ID" ReadOnly="True" Visible="False">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="7" FieldName="Purpose">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Document No." ShowInCustomizationForm="True" VisibleIndex="2" FieldName="DocNo" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnView" Text="View">
                                                            <Image IconID="actions_open_svg_white_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Expense Report for" FieldName="ExpenseType_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <PropertiesComboBox DataSourceID="sqlExpenseType" TextField="Description" ValueField="ExpenseType_ID">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Name" FieldName="User_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                            <Toolbars>
                                                <dx:GridViewToolbar ItemAlign="Right">
                                                    <Items>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                            <Template>
                                                                <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." ShowClearButton="True"  Theme                 ="iOS" Width="400px">
                                                                    <Buttons>
                                                                        <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                        </dx:SpinButtonExtended>
                                                                    </Buttons>
                                                                </dx:ASPxButtonEdit>
                                                            </Template>
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbar>
                                                <dx:GridViewToolbar>
                                                    <Items>
                                                        <dx:GridViewToolbarItem Alignment="Right" Command="Refresh" BeginGroup="True">
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" Text="Export" BeginGroup="True">
                                                            <Items>
                                                                <dx:GridViewToolbarItem Command="ExportToPdf">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Command="ExportToXls">
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                            <Image IconID="diagramicons_exportas_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Name="print" Target="_blank" Text="Print" Alignment="Right" BeginGroup="True" Visible="False">
                                                            <Image IconID="print_print_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbar>
                                            </Toolbars>
                                            <FormatConditions>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 1" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 3" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 7" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006838">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 8" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#CC2A17">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 13" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#666666">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 20" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 21" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 22" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Progress] &lt; 30" FieldName="Progress" Format="GreenText">
                                                </dx:GridViewFormatConditionHighlight>
                                            </FormatConditions>
                                            <Styles>
                                                <Header Font-Bold="True" HorizontalAlign="Center">
                                                </Header>
                                            </Styles>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
                <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
                </ParentContainerStyle>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType] ORDER BY [Description]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WASSId], [CompanyDesc], [CompanyShortName] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL) ORDER BY [CompanyDesc]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([User_ID] = @User_ID) ORDER BY [ID]">
            <SelectParameters>
                <asp:SessionParameter Name="User_ID" SessionField="userID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
</asp:Content>
