<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="OrganizationSetup.aspx.cs" Inherits="DX_WebTemplate.Organization.OrganizationSetup" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                case 'dataSelectAll':
                    gridApp.SelectRows();
                    break;
                case 'dataUnselectAll':
                    gridApp.UnselectRows();
                    break;
                case 'dataSelectAllOnPage':
                    gridApp.SelectAllRowsOnPage();
                    break;
                case 'dataUnselectAllOnPage':
                    gridApp.UnselectAllRowsOnPage();
                    break;
            }
        }

    </script>
<div class="conta" id="form1">
    <dx:ASPxFormLayout ID="formOrgSetup" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Organization Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridCompany" runat="server" AutoGenerateColumns="False" DataSourceID="sqlCompany" KeyFieldName="RowId" Width="100%">
                                    
                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="Division">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridDivision" runat="server" AutoGenerateColumns="False" DataSourceID="sqlDivision" KeyFieldName="ID" OnBeforePerformDataSelect="gridDivision_BeforePerformDataSelect" OnRowInserting="gridDivision_RowInserting">
                                                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                                                    <Templates>
                                                                        <DetailRow>
                                                                            <dx:ASPxGridView ID="gridDepartmentChild" runat="server" AutoGenerateColumns="False" DataSourceID="sqlDepartmentChild" KeyFieldName="ID" OnBeforePerformDataSelect="gridDepartmentChild_BeforePerformDataSelect" OnRowInserting="gridDepartmentChild_RowInserting">
                                                                                <SettingsEditing Mode="Batch">
                                                                                </SettingsEditing>
                                                                                <SettingsPopup>
                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                    </FilterControl>
                                                                                </SettingsPopup>
                                                                                <Columns>
                                                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                    </dx:GridViewCommandColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" Visible="False" VisibleIndex="1">
                                                                                        <EditFormSettings Visible="False" />
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Dept. Code" FieldName="DepCode" VisibleIndex="2">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Dept. Description" FieldName="DepDesc" VisibleIndex="3">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Dept. Head" FieldName="DepHead" VisibleIndex="4">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Div_Code" Visible="False" VisibleIndex="5">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Company_Code" Visible="False" VisibleIndex="6">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Company_ID" Visible="False" VisibleIndex="7">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="SAP Cost Center" FieldName="SAP_CostCenter" VisibleIndex="8">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                </Columns>
                                                                            </dx:ASPxGridView>
                                                                        </DetailRow>
                                                                    </Templates>
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Division Code" FieldName="DivCode" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Division Description" FieldName="DivDesc" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Division Head" FieldName="DivHead" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_Code" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                        </dx:GridViewDataTextColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                    <dx:TabPage Text="Department">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridDepartment" runat="server" AutoGenerateColumns="False" DataSourceID="sqlDepartment" KeyFieldName="ID">
                                                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                                                    <Templates>
                                                                        <DetailRow>
                                                                            <dx:ASPxGridView ID="gridSectionChild" runat="server" AutoGenerateColumns="False" DataSourceID="sqlSectionChild" KeyFieldName="ID" OnBeforePerformDataSelect="gridSectionChild_BeforePerformDataSelect">
                                                                                <SettingsEditing Mode="Batch">
                                                                                </SettingsEditing>
                                                                                <SettingsPopup>
                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                    </FilterControl>
                                                                                </SettingsPopup>
                                                                                <SettingsSearchPanel Visible="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                    </dx:GridViewCommandColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" Visible="False" VisibleIndex="1">
                                                                                        <EditFormSettings Visible="False" />
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="SecCode" VisibleIndex="2">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="SecDesc" VisibleIndex="3">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="SecHead" VisibleIndex="4">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Dep_Code" Visible="False" VisibleIndex="5">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Company_Code" Visible="False" VisibleIndex="6">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn FieldName="Company_ID" Visible="False" VisibleIndex="7">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                </Columns>
                                                                            </dx:ASPxGridView>
                                                                        </DetailRow>
                                                                    </Templates>
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Dept. Code" FieldName="DepCode" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Dept. Description" FieldName="DepDesc" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Dept. Head" FieldName="DepHead" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_Code" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="SAP Cost Center" FieldName="SAP_CostCenter" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Division Code" FieldName="Div_Code" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        </dx:GridViewDataTextColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                    <dx:TabPage Text="Section">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridSection" runat="server" AutoGenerateColumns="False" DataSourceID="sqlSection" KeyFieldName="ID">
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Section Code" FieldName="SecCode" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Section Description" FieldName="SecDesc" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Section Head" FieldName="SecHead" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Dept. Code" FieldName="Dep_Code" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_Code" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                        </dx:GridViewDataTextColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                </TabPages>
                                            </dx:ASPxPageControl>
                                        </DetailRow>
                                    </Templates>
                                    
                                    <SettingsPager PageSize="32">
                                        <FirstPageButton Visible="True">
                                        </FirstPageButton>
                                        <LastPageButton Visible="True">
                                        </LastPageButton>
                                        <PageSizeItemSettings Visible="True">
                                        </PageSizeItemSettings>
                                    </SettingsPager>
                                    <SettingsEditing Mode="Batch">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" />
                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                    <SettingsDataSecurity AllowDelete="False" />

                                    <SettingsPopup>
                                    <FilterControl AutoUpdatePosition="False"></FilterControl>
                                    </SettingsPopup>

                                    <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowApplyButton="True" Visible="True" />
                                    <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG">
                                    </SettingsExport>
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="70px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="RowId" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="CompanyDesc" ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="INTERID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsNorth" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsSouth" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="DynamicsId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="10">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn Caption="WASS ID" FieldName="WASSId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="SAP Code" FieldName="SAP_Id" ShowInCustomizationForm="True" VisibleIndex="18">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataMemoColumn FieldName="FullAddress" ShowInCustomizationForm="True" VisibleIndex="5">
                                        </dx:GridViewDataMemoColumn>
                                    </Columns>
                                    <Toolbars>
                                        <dx:GridViewToolbar>
                                            <Items>
                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Export">
                                                    <Items>
                                                        <dx:GridViewToolbarItem Command="ExportToXlsx">
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Command="ExportToPdf">
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                    <Template>
                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                            <Buttons>
                                                                <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                </dx:SpinButtonExtended>
                                                            </Buttons>
                                                        </dx:ASPxButtonEdit>
                                                    </Template>
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                        <dx:GridViewToolbar Visible="False">
                                            <Items>
                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Command="New" Visible="False">
                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Text="Selection" Alignment="Right" Visible="False">
                                                    <Items>
                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAll" Text="Select All">
                                                            <ScrollUpButtonImage IconID="snap_highlight_svg_16x16">
                                                            </ScrollUpButtonImage>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Name="dataUnselectAll" Text="Unselect All">
                                                            <ScrollUpButtonImage IconID="pdfviewer_selectall_svg_16x16">
                                                            </ScrollUpButtonImage>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAllOnPage" Text="Select all on the page">
                                                            <ScrollUpButtonImage IconID="richedit_selecttable_svg_16x16">
                                                            </ScrollUpButtonImage>
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Name="dataUnselectAllOnPage" Text="Unselect all on the page">
                                                            <ScrollUpButtonImage IconID="richedit_selecttablecolumn_svg_16x16">
                                                            </ScrollUpButtonImage>
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                    <ScrollUpButtonImage IconID="spreadsheet_selectdatamember_svg_16x16">
                                                    </ScrollUpButtonImage>
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlCompany" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [CompanyMaster] WHERE [RowId] = @original_RowId AND (([CompanyDesc] = @original_CompanyDesc) OR ([CompanyDesc] IS NULL AND @original_CompanyDesc IS NULL)) AND (([CompanyShortName] = @original_CompanyShortName) OR ([CompanyShortName] IS NULL AND @original_CompanyShortName IS NULL)) AND (([INTERID] = @original_INTERID) OR ([INTERID] IS NULL AND @original_INTERID IS NULL)) AND (([FullAddress] = @original_FullAddress) OR ([FullAddress] IS NULL AND @original_FullAddress IS NULL)) AND (([IsNorth] = @original_IsNorth) OR ([IsNorth] IS NULL AND @original_IsNorth IS NULL)) AND (([IsSouth] = @original_IsSouth) OR ([IsSouth] IS NULL AND @original_IsSouth IS NULL)) AND (([DynamicsId] = @original_DynamicsId) OR ([DynamicsId] IS NULL AND @original_DynamicsId IS NULL)) AND (([KDS] = @original_KDS) OR ([KDS] IS NULL AND @original_KDS IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([HRId] = @original_HRId) OR ([HRId] IS NULL AND @original_HRId IS NULL)) AND (([WASSId] = @original_WASSId) OR ([WASSId] IS NULL AND @original_WASSId IS NULL)) AND (([SAP_Id] = @original_SAP_Id) OR ([SAP_Id] IS NULL AND @original_SAP_Id IS NULL))" InsertCommand="INSERT INTO [CompanyMaster] ([CompanyDesc], [CompanyShortName], [INTERID], [FullAddress], [IsNorth], [IsSouth], [DynamicsId], [KDS], [IsActive], [IsDelete], [DateCreated], [DateModified], [CreatedBy], [ModifiedBy], [HRId], [WASSId], [SAP_Id]) VALUES (@CompanyDesc, @CompanyShortName, @INTERID, @FullAddress, @IsNorth, @IsSouth, @DynamicsId, @KDS, @IsActive, @IsDelete, @DateCreated, @DateModified, @CreatedBy, @ModifiedBy, @HRId, @WASSId, @SAP_Id)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [CompanyMaster] ORDER BY [CompanyShortName]" UpdateCommand="UPDATE [CompanyMaster] SET [CompanyDesc] = @CompanyDesc, [CompanyShortName] = @CompanyShortName, [INTERID] = @INTERID, [FullAddress] = @FullAddress, [IsNorth] = @IsNorth, [IsSouth] = @IsSouth, [DynamicsId] = @DynamicsId, [KDS] = @KDS, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [DateCreated] = @DateCreated, [DateModified] = @DateModified, [CreatedBy] = @CreatedBy, [ModifiedBy] = @ModifiedBy, [HRId] = @HRId, [WASSId] = @WASSId, [SAP_Id] = @SAP_Id WHERE [RowId] = @original_RowId AND (([CompanyDesc] = @original_CompanyDesc) OR ([CompanyDesc] IS NULL AND @original_CompanyDesc IS NULL)) AND (([CompanyShortName] = @original_CompanyShortName) OR ([CompanyShortName] IS NULL AND @original_CompanyShortName IS NULL)) AND (([INTERID] = @original_INTERID) OR ([INTERID] IS NULL AND @original_INTERID IS NULL)) AND (([FullAddress] = @original_FullAddress) OR ([FullAddress] IS NULL AND @original_FullAddress IS NULL)) AND (([IsNorth] = @original_IsNorth) OR ([IsNorth] IS NULL AND @original_IsNorth IS NULL)) AND (([IsSouth] = @original_IsSouth) OR ([IsSouth] IS NULL AND @original_IsSouth IS NULL)) AND (([DynamicsId] = @original_DynamicsId) OR ([DynamicsId] IS NULL AND @original_DynamicsId IS NULL)) AND (([KDS] = @original_KDS) OR ([KDS] IS NULL AND @original_KDS IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([HRId] = @original_HRId) OR ([HRId] IS NULL AND @original_HRId IS NULL)) AND (([WASSId] = @original_WASSId) OR ([WASSId] IS NULL AND @original_WASSId IS NULL)) AND (([SAP_Id] = @original_SAP_Id) OR ([SAP_Id] IS NULL AND @original_SAP_Id IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_RowId" Type="Int32" />
                                        <asp:Parameter Name="original_CompanyDesc" Type="String" />
                                        <asp:Parameter Name="original_CompanyShortName" Type="String" />
                                        <asp:Parameter Name="original_INTERID" Type="String" />
                                        <asp:Parameter Name="original_FullAddress" Type="String" />
                                        <asp:Parameter Name="original_IsNorth" Type="Boolean" />
                                        <asp:Parameter Name="original_IsSouth" Type="Boolean" />
                                        <asp:Parameter Name="original_DynamicsId" Type="Int32" />
                                        <asp:Parameter Name="original_KDS" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_HRId" Type="Int32" />
                                        <asp:Parameter Name="original_WASSId" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="CompanyDesc" Type="String" />
                                        <asp:Parameter Name="CompanyShortName" Type="String" />
                                        <asp:Parameter Name="INTERID" Type="String" />
                                        <asp:Parameter Name="FullAddress" Type="String" />
                                        <asp:Parameter Name="IsNorth" Type="Boolean" />
                                        <asp:Parameter Name="IsSouth" Type="Boolean" />
                                        <asp:Parameter Name="DynamicsId" Type="Int32" />
                                        <asp:Parameter Name="KDS" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="HRId" Type="Int32" />
                                        <asp:Parameter Name="WASSId" Type="Int32" />
                                        <asp:Parameter Name="SAP_Id" Type="Int32" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="CompanyDesc" Type="String" />
                                        <asp:Parameter Name="CompanyShortName" Type="String" />
                                        <asp:Parameter Name="INTERID" Type="String" />
                                        <asp:Parameter Name="FullAddress" Type="String" />
                                        <asp:Parameter Name="IsNorth" Type="Boolean" />
                                        <asp:Parameter Name="IsSouth" Type="Boolean" />
                                        <asp:Parameter Name="DynamicsId" Type="Int32" />
                                        <asp:Parameter Name="KDS" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="HRId" Type="Int32" />
                                        <asp:Parameter Name="WASSId" Type="Int32" />
                                        <asp:Parameter Name="SAP_Id" Type="Int32" />
                                        <asp:Parameter Name="original_RowId" Type="Int32" />
                                        <asp:Parameter Name="original_CompanyDesc" Type="String" />
                                        <asp:Parameter Name="original_CompanyShortName" Type="String" />
                                        <asp:Parameter Name="original_INTERID" Type="String" />
                                        <asp:Parameter Name="original_FullAddress" Type="String" />
                                        <asp:Parameter Name="original_IsNorth" Type="Boolean" />
                                        <asp:Parameter Name="original_IsSouth" Type="Boolean" />
                                        <asp:Parameter Name="original_DynamicsId" Type="Int32" />
                                        <asp:Parameter Name="original_KDS" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_HRId" Type="Int32" />
                                        <asp:Parameter Name="original_WASSId" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDivision" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_OrgDivisionMaster] WHERE [ID] = @original_ID AND (([DivCode] = @original_DivCode) OR ([DivCode] IS NULL AND @original_DivCode IS NULL)) AND (([DivDesc] = @original_DivDesc) OR ([DivDesc] IS NULL AND @original_DivDesc IS NULL)) AND (([DivHead] = @original_DivHead) OR ([DivHead] IS NULL AND @original_DivHead IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))" InsertCommand="INSERT INTO [ITP_S_OrgDivisionMaster] ([DivCode], [DivDesc], [DivHead], [Company_Code], [Company_ID]) VALUES (@DivCode, @DivDesc, @DivHead, @Company_Code, @Company_ID)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_OrgDivisionMaster] WHERE ([Company_ID] = @Company_ID) ORDER BY [DivDesc]" UpdateCommand="UPDATE [ITP_S_OrgDivisionMaster] SET [DivCode] = @DivCode, [DivDesc] = @DivDesc, [DivHead] = @DivHead, [Company_Code] = @Company_Code, [Company_ID] = @Company_ID WHERE [ID] = @original_ID AND (([DivCode] = @original_DivCode) OR ([DivCode] IS NULL AND @original_DivCode IS NULL)) AND (([DivDesc] = @original_DivDesc) OR ([DivDesc] IS NULL AND @original_DivDesc IS NULL)) AND (([DivHead] = @original_DivHead) OR ([DivHead] IS NULL AND @original_DivHead IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DivCode" Type="String" />
                                        <asp:Parameter Name="original_DivDesc" Type="String" />
                                        <asp:Parameter Name="original_DivHead" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="DivCode" Type="String" />
                                        <asp:Parameter Name="DivDesc" Type="String" />
                                        <asp:Parameter Name="DivHead" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="Company_ID" SessionField="MasterCompanyID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="DivCode" Type="String" />
                                        <asp:Parameter Name="DivDesc" Type="String" />
                                        <asp:Parameter Name="DivHead" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DivCode" Type="String" />
                                        <asp:Parameter Name="original_DivDesc" Type="String" />
                                        <asp:Parameter Name="original_DivHead" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDepartment" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_OrgDepartmentMaster] WHERE [ID] = @original_ID AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([DepDesc] = @original_DepDesc) OR ([DepDesc] IS NULL AND @original_DepDesc IS NULL)) AND (([DepHead] = @original_DepHead) OR ([DepHead] IS NULL AND @original_DepHead IS NULL)) AND (([Div_Code] = @original_Div_Code) OR ([Div_Code] IS NULL AND @original_Div_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([SAP_CostCenter] = @original_SAP_CostCenter) OR ([SAP_CostCenter] IS NULL AND @original_SAP_CostCenter IS NULL))" InsertCommand="INSERT INTO [ITP_S_OrgDepartmentMaster] ([DepCode], [DepDesc], [DepHead], [Div_Code], [Company_Code], [Company_ID], [SAP_CostCenter]) VALUES (@DepCode, @DepDesc, @DepHead, @Div_Code, @Company_Code, @Company_ID, @SAP_CostCenter)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID) ORDER BY [DepDesc]" UpdateCommand="UPDATE [ITP_S_OrgDepartmentMaster] SET [DepCode] = @DepCode, [DepDesc] = @DepDesc, [DepHead] = @DepHead, [Div_Code] = @Div_Code, [Company_Code] = @Company_Code, [Company_ID] = @Company_ID, [SAP_CostCenter] = @SAP_CostCenter WHERE [ID] = @original_ID AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([DepDesc] = @original_DepDesc) OR ([DepDesc] IS NULL AND @original_DepDesc IS NULL)) AND (([DepHead] = @original_DepHead) OR ([DepHead] IS NULL AND @original_DepHead IS NULL)) AND (([Div_Code] = @original_Div_Code) OR ([Div_Code] IS NULL AND @original_Div_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([SAP_CostCenter] = @original_SAP_CostCenter) OR ([SAP_CostCenter] IS NULL AND @original_SAP_CostCenter IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_DepDesc" Type="String" />
                                        <asp:Parameter Name="original_DepHead" Type="String" />
                                        <asp:Parameter Name="original_Div_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_CostCenter" Type="String" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="DepDesc" Type="String" />
                                        <asp:Parameter Name="DepHead" Type="String" />
                                        <asp:Parameter Name="Div_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="SAP_CostCenter" Type="String" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="Company_ID" SessionField="MasterCompanyID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="DepDesc" Type="String" />
                                        <asp:Parameter Name="DepHead" Type="String" />
                                        <asp:Parameter Name="Div_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="SAP_CostCenter" Type="String" />
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_DepDesc" Type="String" />
                                        <asp:Parameter Name="original_DepHead" Type="String" />
                                        <asp:Parameter Name="original_Div_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_CostCenter" Type="String" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDepartmentChild" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_OrgDepartmentMaster] WHERE [ID] = @original_ID AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([DepDesc] = @original_DepDesc) OR ([DepDesc] IS NULL AND @original_DepDesc IS NULL)) AND (([DepHead] = @original_DepHead) OR ([DepHead] IS NULL AND @original_DepHead IS NULL)) AND (([Div_Code] = @original_Div_Code) OR ([Div_Code] IS NULL AND @original_Div_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([SAP_CostCenter] = @original_SAP_CostCenter) OR ([SAP_CostCenter] IS NULL AND @original_SAP_CostCenter IS NULL))" InsertCommand="INSERT INTO [ITP_S_OrgDepartmentMaster] ([DepCode], [DepDesc], [DepHead], [Div_Code], [Company_Code], [Company_ID], [SAP_CostCenter]) VALUES (@DepCode, @DepDesc, @DepHead, @Div_Code, @Company_Code, @Company_ID, @SAP_CostCenter)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Div_Code] = @Div_Code) AND ([Company_ID] = @Company_ID)) ORDER BY [DepDesc]" UpdateCommand="UPDATE [ITP_S_OrgDepartmentMaster] SET [DepCode] = @DepCode, [DepDesc] = @DepDesc, [DepHead] = @DepHead, [Div_Code] = @Div_Code, [Company_Code] = @Company_Code, [Company_ID] = @Company_ID, [SAP_CostCenter] = @SAP_CostCenter WHERE [ID] = @original_ID AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([DepDesc] = @original_DepDesc) OR ([DepDesc] IS NULL AND @original_DepDesc IS NULL)) AND (([DepHead] = @original_DepHead) OR ([DepHead] IS NULL AND @original_DepHead IS NULL)) AND (([Div_Code] = @original_Div_Code) OR ([Div_Code] IS NULL AND @original_Div_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([SAP_CostCenter] = @original_SAP_CostCenter) OR ([SAP_CostCenter] IS NULL AND @original_SAP_CostCenter IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_DepDesc" Type="String" />
                                        <asp:Parameter Name="original_DepHead" Type="String" />
                                        <asp:Parameter Name="original_Div_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_CostCenter" Type="String" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="DepDesc" Type="String" />
                                        <asp:Parameter Name="DepHead" Type="String" />
                                        <asp:Parameter Name="Div_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="SAP_CostCenter" Type="String" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="Div_Code" SessionField="MasterDivCode" Type="String" />
                                        <asp:SessionParameter Name="Company_ID" SessionField="MasterDivCompanyID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="DepDesc" Type="String" />
                                        <asp:Parameter Name="DepHead" Type="String" />
                                        <asp:Parameter Name="Div_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="SAP_CostCenter" Type="String" />
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_DepDesc" Type="String" />
                                        <asp:Parameter Name="original_DepHead" Type="String" />
                                        <asp:Parameter Name="original_Div_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SAP_CostCenter" Type="String" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlSection" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_OrgSectionMaster] WHERE [ID] = @original_ID AND (([SecCode] = @original_SecCode) OR ([SecCode] IS NULL AND @original_SecCode IS NULL)) AND (([SecDesc] = @original_SecDesc) OR ([SecDesc] IS NULL AND @original_SecDesc IS NULL)) AND (([SecHead] = @original_SecHead) OR ([SecHead] IS NULL AND @original_SecHead IS NULL)) AND (([Dep_Code] = @original_Dep_Code) OR ([Dep_Code] IS NULL AND @original_Dep_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))" InsertCommand="INSERT INTO [ITP_S_OrgSectionMaster] ([SecCode], [SecDesc], [SecHead], [Dep_Code], [Company_Code], [Company_ID]) VALUES (@SecCode, @SecDesc, @SecHead, @Dep_Code, @Company_Code, @Company_ID)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_OrgSectionMaster] WHERE ([Company_ID] = @Company_ID) ORDER BY [SecDesc]" UpdateCommand="UPDATE [ITP_S_OrgSectionMaster] SET [SecCode] = @SecCode, [SecDesc] = @SecDesc, [SecHead] = @SecHead, [Dep_Code] = @Dep_Code, [Company_Code] = @Company_Code, [Company_ID] = @Company_ID WHERE [ID] = @original_ID AND (([SecCode] = @original_SecCode) OR ([SecCode] IS NULL AND @original_SecCode IS NULL)) AND (([SecDesc] = @original_SecDesc) OR ([SecDesc] IS NULL AND @original_SecDesc IS NULL)) AND (([SecHead] = @original_SecHead) OR ([SecHead] IS NULL AND @original_SecHead IS NULL)) AND (([Dep_Code] = @original_Dep_Code) OR ([Dep_Code] IS NULL AND @original_Dep_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SecCode" Type="String" />
                                        <asp:Parameter Name="original_SecDesc" Type="String" />
                                        <asp:Parameter Name="original_SecHead" Type="String" />
                                        <asp:Parameter Name="original_Dep_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="SecCode" Type="String" />
                                        <asp:Parameter Name="SecDesc" Type="String" />
                                        <asp:Parameter Name="SecHead" Type="String" />
                                        <asp:Parameter Name="Dep_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="Company_ID" SessionField="MasterCompanyID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="SecCode" Type="String" />
                                        <asp:Parameter Name="SecDesc" Type="String" />
                                        <asp:Parameter Name="SecHead" Type="String" />
                                        <asp:Parameter Name="Dep_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SecCode" Type="String" />
                                        <asp:Parameter Name="original_SecDesc" Type="String" />
                                        <asp:Parameter Name="original_SecHead" Type="String" />
                                        <asp:Parameter Name="original_Dep_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlSectionChild" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_OrgSectionMaster] WHERE [ID] = @original_ID AND (([SecCode] = @original_SecCode) OR ([SecCode] IS NULL AND @original_SecCode IS NULL)) AND (([SecDesc] = @original_SecDesc) OR ([SecDesc] IS NULL AND @original_SecDesc IS NULL)) AND (([SecHead] = @original_SecHead) OR ([SecHead] IS NULL AND @original_SecHead IS NULL)) AND (([Dep_Code] = @original_Dep_Code) OR ([Dep_Code] IS NULL AND @original_Dep_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))" InsertCommand="INSERT INTO [ITP_S_OrgSectionMaster] ([SecCode], [SecDesc], [SecHead], [Dep_Code], [Company_Code], [Company_ID]) VALUES (@SecCode, @SecDesc, @SecHead, @Dep_Code, @Company_Code, @Company_ID)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_OrgSectionMaster] WHERE (([Company_ID] = @Company_ID) AND ([Dep_Code] = @Dep_Code)) ORDER BY [SecDesc]" UpdateCommand="UPDATE [ITP_S_OrgSectionMaster] SET [SecCode] = @SecCode, [SecDesc] = @SecDesc, [SecHead] = @SecHead, [Dep_Code] = @Dep_Code, [Company_Code] = @Company_Code, [Company_ID] = @Company_ID WHERE [ID] = @original_ID AND (([SecCode] = @original_SecCode) OR ([SecCode] IS NULL AND @original_SecCode IS NULL)) AND (([SecDesc] = @original_SecDesc) OR ([SecDesc] IS NULL AND @original_SecDesc IS NULL)) AND (([SecHead] = @original_SecHead) OR ([SecHead] IS NULL AND @original_SecHead IS NULL)) AND (([Dep_Code] = @original_Dep_Code) OR ([Dep_Code] IS NULL AND @original_Dep_Code IS NULL)) AND (([Company_Code] = @original_Company_Code) OR ([Company_Code] IS NULL AND @original_Company_Code IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SecCode" Type="String" />
                                        <asp:Parameter Name="original_SecDesc" Type="String" />
                                        <asp:Parameter Name="original_SecHead" Type="String" />
                                        <asp:Parameter Name="original_Dep_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="SecCode" Type="String" />
                                        <asp:Parameter Name="SecDesc" Type="String" />
                                        <asp:Parameter Name="SecHead" Type="String" />
                                        <asp:Parameter Name="Dep_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="Company_ID" SessionField="MasterDepCompanyID" Type="Int32" />
                                        <asp:SessionParameter Name="Dep_Code" SessionField="MasterDepCode" Type="String" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="SecCode" Type="String" />
                                        <asp:Parameter Name="SecDesc" Type="String" />
                                        <asp:Parameter Name="SecHead" Type="String" />
                                        <asp:Parameter Name="Dep_Code" Type="String" />
                                        <asp:Parameter Name="Company_Code" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="original_ID" Type="Int32" />
                                        <asp:Parameter Name="original_SecCode" Type="String" />
                                        <asp:Parameter Name="original_SecDesc" Type="String" />
                                        <asp:Parameter Name="original_SecHead" Type="String" />
                                        <asp:Parameter Name="original_Dep_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_Code" Type="String" />
                                        <asp:Parameter Name="original_Company_ID" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    </div>
</asp:Content>
