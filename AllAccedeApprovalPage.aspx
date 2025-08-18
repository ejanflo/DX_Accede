<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AllAccedeApprovalPage.aspx.cs" Inherits="DX_WebTemplate.AllAccedeApprovalPage" %>
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
                loadPanel.SetText("Loading document&hellip;");
                loadPanel.Show();
            }
        }

        function onToolbarItemClick(s, e) {
            if (e.item.name === "approvalHistoryButton") {
                window.open("TravelExpenseApprovalHistory.aspx", "_blank");
            }
        }
    </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="ACCEDE Approval Page" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Paddings Padding="0px" />
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" Width="100%" DataSourceID="sqlAllApproval" KeyFieldName="WFA_Id" OnCustomCallback="expenseGrid_CustomCallback" OnCustomColumnDisplayText="expenseGrid_CustomColumnDisplayText">
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
                                            <SettingsCookies Enabled="True" />
                                            <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowClearButton="True" Visible="True" />
                                            <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                            </SettingsExport>
                                            <SettingsLoadingPanel Text="Loading..." Mode="Disabled" />
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
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="1" FieldName="Document_Id" ReadOnly="True" Visible="False">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="2" Caption="Document No.">
                                                    <CellStyle Font-Bold="False" HorizontalAlign="Left">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Employee Name/Vendor" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CellStyle Font-Bold="True" HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="9" Visible="False">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" VisibleIndex="10" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="11" FieldName="Remarks" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="CompanyId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Document Type" FieldName="AppDocTypeId" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <PropertiesComboBox DataSourceID="SqlAppDocType" TextField="DCT_Description" ValueField="DCT_Id">
                                                    </PropertiesComboBox>
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Transaction Type" FieldName="TranType" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlTranType" TextField="Description" ValueField="ExpenseType_ID">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="True" HorizontalAlign="Center">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn Caption="Purpose" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Preparer" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="WFA_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Status" FieldName="STS_Description" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Remarks" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesTextEdit NullDisplayText=" ">
                                                            </PropertiesTextEdit>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Department" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Location" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlCompBranch" TextField="Name" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
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
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="View Approval History" Name="approvalHistoryButton" Target="_blank">
                                                            <Image IconID="businessobjects_bo_audit_changehistory_svg_gray_16x16">
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
                                                <dx:GridViewFormatConditionHighlight Expression="[STS_Description] = 'Pending' Or [STS_Description] = 'Pending at Finance' Or [STS_Description] = 'Pending at Audit' Or [STS_Description] = 'Pending at P2P' Or [STS_Description] = 'Pending at Cashier'" FieldName="STS_Description" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[STS_Description] = 'Completed' Or [STS_Description] = 'Approved'" FieldName="STS_Description" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006838">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[STS_Description] = 'Returned' Or [STS_Description] = 'Rejected'" FieldName="STS_Description" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[STS_Description] = 'Disapproved'" FieldName="STS_Description" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#CC2A17">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[STS_Description] = 'Forwarded'" FieldName="STS_Description" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#878787">
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
    <asp:SqlDataSource ID="sqlAllApproval" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT Document_Id, Status, STS_Description, DateAssigned, DateAction, AppDocTypeId, AppId, 
       Remarks, UserId, CompanyId, TranType, WF_Id, WFD_Id, WFA_Id, 
       Travel_Id, NoTravel_Id, RFP_Id, Location
FROM vw_ACCEDE_I_AllAccedeForApproval
WHERE UserId = @UserId
  AND (Document_Id = Travel_Id OR Document_Id = NoTravel_Id OR Document_Id = RFP_Id)
  AND (
        AppDocTypeId &lt;&gt; 1011 
        OR (TranType &lt;&gt; 2 AND TranType &lt;&gt; 3)
      )
ORDER BY DateAssigned;
">
        <SelectParameters>
            <asp:SessionParameter Name="UserId" SessionField="userID" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([DepCode] IS NOT NULL)"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAppDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_DocumentType]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompBranch" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
    </asp:Content>
