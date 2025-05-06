<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseApprovalHistory.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseApprovalHistory" %>

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
            loadPanel.Show();
        }

        function onToolbarItemClick(s, e) {

        }
    </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="My Accede Approval History" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Paddings Padding="0px" />
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" DataSourceID="sqlTravelExp" KeyFieldName="Document_Id" OnCustomCallback="expenseGrid_CustomCallback" OnCustomColumnDisplayText="expenseGrid_CustomColumnDisplayText" Width="100%">
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
                                                <PageSizeItemSettings Items="5, 10, 20, 50, 100, 200" Visible="True">
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
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="Document_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Document No." ShowInCustomizationForm="True" VisibleIndex="2">
                                                    <CellStyle Font-Bold="False" HorizontalAlign="Left">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Employee Name" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CellStyle Font-Bold="True" HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Department" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                    </PropertiesComboBox>
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Remarks" FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesTextEdit NullDisplayText=" ">
                                                            </PropertiesTextEdit>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn Caption="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Preparer" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataDateColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    <PropertiesComboBox DataSourceID="SqlWF" TextField="Name" ValueField="WF_Id">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Description" FieldName="WFD_Id" ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                                                            <PropertiesComboBox DataSourceID="SqlWFD" TextField="Description" ValueField="WFD_Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Doc. Type" FieldName="AppDocTypeId" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesComboBox DataSourceID="SqlAppDocType" TextField="DCT_Description" ValueField="DCT_Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
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
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="">
                                                            <Template>
                                                                <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." ShowClearButton="True" Theme="iOS" Width="400px">
                                                                    <Buttons>
                                                                        <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                        </dx:SpinButtonExtended>
                                                                    </Buttons>
                                                                </dx:ASPxButtonEdit>
                                                            </Template>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Name="approvalHistoryButton" Text="View Approval History" Visible="False">
                                                            <Image IconID="businessobjects_bo_audit_changehistory_svg_dark_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Export" Visible="False">
                                                            <Items>
                                                                <dx:GridViewToolbarItem Command="ExportToPdf">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Command="ExportToXls">
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                            <Image IconID="diagramicons_exportas_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Name="print" Target="_blank" Text="Print" Visible="False">
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
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 41" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#878787">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                            </FormatConditions>
                                            <Styles>
                                                <Header BackColor="#E9ECEF" Font-Bold="True" HorizontalAlign="Center">
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
    <asp:SqlDataSource ID="sqlTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_TravelApprovalHistory] WHERE ([ActedBy_User_Id] = @ActedBy_User_Id) ORDER BY [DateAction] DESC">
        <SelectParameters>
            <asp:SessionParameter Name="ActedBy_User_Id" SessionField="userID" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([DepCode] IS NOT NULL)"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFD" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowDetails]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAppDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_DocumentType]">
    </asp:SqlDataSource>
</asp:Content>
