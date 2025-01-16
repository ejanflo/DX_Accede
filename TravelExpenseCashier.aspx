<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseCashier.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseCashier" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }

        .custom .dxMonthGridWithWeekNumbers {
            display: none;
        }
    </style>
    <script>
        function OnCustomButtonClick(s, e) {
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            if (e.buttonID != "btnPrint") {
                loadPanel.Show();
            }
        }

        function onToolbarItemClick(s, e) {
            if (e.item.name === "approvalHistoryButton") {
                loadPanel.Show();
                window.open("TravelExpenseApprovalHistory.aspx", "_self");
            }
        }

    </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="Travel Expense Cashier Page" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Paddings Padding="0px" />
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" Width="100%" DataSourceID="sqlTravelExp" KeyFieldName="ID" OnCustomCallback="expenseGrid_CustomCallback" OnCustomColumnDisplayText="expenseGrid_CustomColumnDisplayText">
                                            <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="onToolbarItemClick" />
                                            <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                            </SettingsAdaptivity>
                                            <Templates>
                                                <DetailRow>
                                                    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="3" Width="100%">
                                                        <TabPages>
                                                            <dx:TabPage Text="WORKFLOW ACTIVITY">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="detailGrid" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                            <SettingsContextMenu Enabled="True">
                                                                            </SettingsContextMenu>
                                                                            <SettingsPager SEOFriendly="Enabled">
                                                                            </SettingsPager>
                                                                            <Settings GridLines="Horizontal" />
                                                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                            <Styles>
                                                                                <Header Font-Bold="False">
                                                                                </Header>
                                                                            </Styles>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                            <dx:TabPage Text="CASH ADVANCE">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                            <dx:TabPage Text="EXPENSES">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="ExpGrid" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                            <dx:TabPage Text="REIMBURSEMENTS">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="ReimburseGrid" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                        </TabPages>
                                                    </dx:ASPxPageControl>
                                                </DetailRow>
                                            </Templates>
                                            <SettingsPager AlwaysShowPager="True">
                                                <PageSizeItemSettings Visible="True" Items="5, 10, 20, 50, 100, 200">
                                                </PageSizeItemSettings>
                                            </SettingsPager>
                                            <Settings ShowHeaderFilterButton="True" />
                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                            <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowClearButton="True" Visible="True" />
                                            <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                            </SettingsExport>
                                            <SettingsLoadingPanel Text="Loading..." Mode="ShowOnStatusBar" />
                                            <Columns>
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
                                                        <dx:GridViewCommandColumnCustomButton ID="btnEdit" Text="Edit" Visibility="Invisible">
                                                            <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style BackColor="#006DD6" Font-Bold="True" Font-Italic="False" Font-Size="Smaller" ForeColor="White">
                                                                    <Paddings Padding="5px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="1" FieldName="ID" ReadOnly="True" Visible="False">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Doc_No" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Document No.">
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Employee Name" FieldName="Employee_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="Date_From" ShowInCustomizationForm="True" VisibleIndex="5" Caption="Date From">
                                                    <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataDateColumn Caption="Date To" FieldName="Date_To" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn Caption="Time Departed" FieldName="Time_Departed" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Time Arrived" FieldName="Time_Arrived" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Dep_Code" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepCode" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="4" FieldName="Trip_To" Caption="Trip To">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn Caption="Date Created" FieldName="Date_Created" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Prepared By" FieldName="Preparer_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="False">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="11">
                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ActRemarks" ShowInCustomizationForm="True" VisibleIndex="0" Caption="Remarks">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn FieldName="ExpenseType_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="WFA_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn FieldName="TraRemarks" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                            <Toolbars>
                                                <dx:GridViewToolbar ItemAlign="Right" Visible="False">
                                                </dx:GridViewToolbar>
                                                <dx:GridViewToolbar>
                                                    <Items>
                                                        <dx:GridViewToolbarItem Alignment="Left" Name="newReport" Text="New" Visible="False">
                                                            <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Left" BeginGroup="True" Text="">
                                                            <Template>
                                                                <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." ShowClearButton="True" Theme="iOS" Width="400px">
                                                                    <Buttons>
                                                                        <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                        </dx:SpinButtonExtended>
                                                                    </Buttons>
                                                                </dx:ASPxButtonEdit>
                                                            </Template>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="View Approval History" Name="approvalHistoryButton">
                                                            <Image IconID="businessobjects_bo_audit_changehistory_svg_dark_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
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
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 30" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 38" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 34" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 36" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 29" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 39" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 35" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 37" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 40" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006838">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                            </FormatConditions>
                                            <Styles>
                                                <Header Font-Bold="True" HorizontalAlign="Center" BackColor="#E9ECEF">
                                                </Header>
                                                <AlternatingRow BackColor="#F5F3F4">
                                                </AlternatingRow>
                                            </Styles>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <Paddings Padding="0px" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
                <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
                </ParentContainerStyle>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>

    <dx:ASPxLoadingPanel ID="loadPanel" ClientInstanceName="loadPanel" Modal="true" runat="server" Theme="MaterialCompact" Text=""></dx:ASPxLoadingPanel>

    <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_TravelPendingApproval] WHERE (([UserId] = @UserId) AND ([Status] = 34)) ORDER BY [WFA_Id] DESC">
        <SelectParameters>
            <asp:SessionParameter Name="UserId" SessionField="userID" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([DepCode] IS NOT NULL)"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]">
    </asp:SqlDataSource>
</asp:Content>
