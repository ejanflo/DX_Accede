<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityApplication.aspx.cs" Inherits="DX_WebTemplate.Security.SecurityApplication" %>
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
    <dx:ASPxFormLayout ID="formApp" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Application Security" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridApp" runat="server" AutoGenerateColumns="False" DataSourceID="sqlApp" KeyFieldName="App_Id" ClientInstanceName="gridApp">
                                    <ClientSideEvents ToolbarItemClick="OnToolbarItemClick" />
                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="1">
                                                <TabPages>
                                                    <dx:TabPage Text="Roles">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridRoles" runat="server" AutoGenerateColumns="False" DataSourceID="sqlRoles" KeyFieldName="Role_Id" OnBeforePerformDataSelect="gridRoles_BeforePerformDataSelect" OnRowInserting="gridRoles_RowInserting">
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <Settings ShowHeaderFilterButton="True" />
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <SettingsSearchPanel Visible="True" />
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" ShowDeleteButton="True">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Role_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Role_Name" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Role">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn Caption="Create" FieldName="CreateAccess" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataCheckColumn Caption="Read" FieldName="ReadAccess" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataCheckColumn Caption="Update" FieldName="UpdateAccess" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataCheckColumn Caption="Delete" FieldName="DeleteAccess" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                        </dx:GridViewDataCheckColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                    <dx:TabPage Text="Users">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridUsers" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUsers" KeyFieldName="UserApp_Id" OnBeforePerformDataSelect="gridUsers_BeforePerformDataSelect" OnRowInserting="gridUsers_RowInserting">
                                                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                                    <Templates>
                                                                        <DetailRow>
                                                                            <dx:ASPxPageControl ID="ASPxPageControl3" runat="server" ActiveTabIndex="0">
                                                                                <TabPages>
                                                                                    <dx:TabPage Text="Company Access">
                                                                                        <ContentCollection>
                                                                                            <dx:ContentControl runat="server">
                                                                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" ForeColor="Red" Text="Note: Please select one (1) Default Company">
                                                                                                </dx:ASPxLabel>
                                                                                                <dx:ASPxGridView ID="gridUserCompany" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserCompany" KeyFieldName="UserCompany_Id" OnBeforePerformDataSelect="gridUserCompany_BeforePerformDataSelect" OnRowInserting="gridUserCompany_RowInserting">
                                                                                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                                                                    <SettingsContextMenu Enabled="True">
                                                                                                    </SettingsContextMenu>
                                                                                                    <SettingsCustomizationDialog Enabled="True" />
                                                                                                    <Templates>
                                                                                                        <DetailRow>
                                                                                                            <dx:ASPxPageControl ID="ASPxPageControl2" runat="server" ActiveTabIndex="0">
                                                                                                                <TabPages>
                                                                                                                    <dx:TabPage Text="Application/Company/Role">
                                                                                                                        <ContentCollection>
                                                                                                                            <dx:ContentControl runat="server">
                                                                                                                                <dx:ASPxGridView ID="gridUserRole" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserRole" KeyFieldName="UserAppRoles_Id" OnBeforePerformDataSelect="gridUserRole_BeforePerformDataSelect" OnRowInserting="gridUserRole_RowInserting" OnHtmlDataCellPrepared="gridUserRole_HtmlDataCellPrepared">
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
                                                                                                                                    <SettingsPopup>
                                                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                                                        </FilterControl>
                                                                                                                                    </SettingsPopup>
                                                                                                                                    <SettingsSearchPanel Visible="True" />
                                                                                                                                    <Columns>
                                                                                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                                        </dx:GridViewCommandColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="UserAppRoles_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                                            <EditFormSettings Visible="False" />
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="SecurityApp_Id" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="16" Visible="False">
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="15" Visible="False">
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataComboBoxColumn Caption="Role" FieldName="SecurityRole_Id" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                                                                            <PropertiesComboBox DataSourceID="sqlRoles" TextField="Role_Name" TextFormatString="{0}" ValueField="Role_Id">
                                                                                                                                                <Columns>
                                                                                                                                                    <dx:ListBoxColumn FieldName="Role_Name">
                                                                                                                                                    </dx:ListBoxColumn>
                                                                                                                                                    <dx:ListBoxColumn FieldName="Description" Width="500px">
                                                                                                                                                    </dx:ListBoxColumn>
                                                                                                                                                </Columns>
                                                                                                                                            </PropertiesComboBox>
                                                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                                                        <dx:GridViewBandColumn Caption="Data Access" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                                                                                            <HeaderStyle HorizontalAlign="Center" />
                                                                                                                                            <Columns>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Create" FieldName="CR" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Read" FieldName="RD" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Update" FieldName="UPD" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Delete" FieldName="DEL" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                            </Columns>
                                                                                                                                        </dx:GridViewBandColumn>
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
                                                                                                    <SettingsPopup>
                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                        </FilterControl>
                                                                                                    </SettingsPopup>
                                                                                                    <SettingsSearchPanel Visible="True" />
                                                                                                    <Columns>
                                                                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" ShowDeleteButton="True" ShowNewButtonInHeader="True">
                                                                                                        </dx:GridViewCommandColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="UserCompany_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                            <EditFormSettings Visible="False" />
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                            <PropertiesComboBox DataSourceID="sqlCompanyMaster" TextFormatString="{0} - {1}" ValueField="WASSId">
                                                                                                                <Columns>
                                                                                                                    <dx:ListBoxColumn Caption="Company" FieldName="CompanyShortName">
                                                                                                                    </dx:ListBoxColumn>
                                                                                                                    <dx:ListBoxColumn Caption=" " FieldName="CompanyDesc" Width="400px">
                                                                                                                    </dx:ListBoxColumn>
                                                                                                                </Columns>
                                                                                                            </PropertiesComboBox>
                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                        <dx:GridViewDataCheckColumn Caption="Default Company" FieldName="IsDefault" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                    </Columns>
                                                                                                </dx:ASPxGridView>
                                                                                            </dx:ContentControl>
                                                                                        </ContentCollection>
                                                                                    </dx:TabPage>
                                                                                </TabPages>
                                                                            </dx:ASPxPageControl>
                                                                        </DetailRow>
                                                                    </Templates>
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsAdaptivity AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" HideDataCellsAtWindowInnerWidth="900" AdaptiveDetailColumnCount="2" AllowOnlyOneAdaptiveDetailExpanded="True">
                                    </SettingsAdaptivity>
                                    <SettingsCustomizationDialog Enabled="True" />
                                                                    <SettingsPager Position="TopAndBottom" PageSize="32">
                                                                        <FirstPageButton Visible="True">
                                                                        </FirstPageButton>
                                                                        <LastPageButton Visible="True">
                                                                        </LastPageButton>
                                                                        <PageSizeItemSettings Visible="True">
                                                                        </PageSizeItemSettings>
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <SettingsSearchPanel Visible="True" />
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowClearFilterButton="True" ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="UserApp_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Username" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="SecurityApp_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="WASPUserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataComboBoxColumn FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="7" Caption="User">
                                                                            <PropertiesComboBox DataSourceID="sqlUserMaster" TextField="FullName" TextFormatString="{0} - {1}" ValueField="EmpCode">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn FieldName="EmpCode">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="FullName" Width="250px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Dept." FieldName="DepDesc" Width="300px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                            </PropertiesComboBox>
                                                                            <Settings AllowAutoFilter="False" />
                                                                        </dx:GridViewDataComboBoxColumn>
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
                                        <dx:GridViewDataTextColumn FieldName="App_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="App Name" FieldName="App_Name" ShowInCustomizationForm="True" VisibleIndex="2" Width="200px">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="App Description" FieldName="App_Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn Caption="Date Created" FieldName="App_DateCreated" ShowInCustomizationForm="True" VisibleIndex="4" Visible="False" Width="150px">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataDateColumn FieldName="App_DateModified" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataTextColumn FieldName="App_CreatedBy" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="App_ModifiedBy" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="8" Width="150px">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="Old_AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="App Type" FieldName="AppType_Id" ShowInCustomizationForm="True" VisibleIndex="10" Width="180px">
                                            <PropertiesComboBox DataSourceID="sqlAppType" TextField="AppType_Name" ValueField="AppType_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                    </Columns>
                                    <Toolbars>
                                        <dx:GridViewToolbar>
                                            <Items>
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
                                        <dx:GridViewToolbar>
                                            <Items>
                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Command="New">
                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="Refresh" Alignment="Right">
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
                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Export">
                                                    <Items>
                                                        <dx:GridViewToolbarItem Command="ExportToXlsx">
                                                        </dx:GridViewToolbarItem>
                                                        <dx:GridViewToolbarItem Command="ExportToPdf">
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlAppType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [AppType_Id], [AppType_Name], [AppType_Desc] FROM [ITP_S_SecurityAppTypes]"></asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT App_Id, App_Name, App_Description, App_DateCreated, App_DateModified, App_CreatedBy, App_ModifiedBy, IsActive, IsDelete, AppType_Id, Old_AppId FROM ITP_S_SecurityApp ORDER BY App_Name" ConflictDetection="CompareAllValues" DeleteCommand="DELETE FROM [ITP_S_SecurityApp] WHERE [App_Id] = @original_App_Id AND (([App_Name] = @original_App_Name) OR ([App_Name] IS NULL AND @original_App_Name IS NULL)) AND (([App_Description] = @original_App_Description) OR ([App_Description] IS NULL AND @original_App_Description IS NULL)) AND (([App_DateCreated] = @original_App_DateCreated) OR ([App_DateCreated] IS NULL AND @original_App_DateCreated IS NULL)) AND (([App_DateModified] = @original_App_DateModified) OR ([App_DateModified] IS NULL AND @original_App_DateModified IS NULL)) AND (([App_CreatedBy] = @original_App_CreatedBy) OR ([App_CreatedBy] IS NULL AND @original_App_CreatedBy IS NULL)) AND (([App_ModifiedBy] = @original_App_ModifiedBy) OR ([App_ModifiedBy] IS NULL AND @original_App_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([AppType_Id] = @original_AppType_Id) OR ([AppType_Id] IS NULL AND @original_AppType_Id IS NULL)) AND (([Old_AppId] = @original_Old_AppId) OR ([Old_AppId] IS NULL AND @original_Old_AppId IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityApp] ([App_Name], [App_Description], [App_DateCreated], [App_DateModified], [App_CreatedBy], [App_ModifiedBy], [IsActive], [IsDelete], [AppType_Id], [Old_AppId]) VALUES (@App_Name, @App_Description, @App_DateCreated, @App_DateModified, @App_CreatedBy, @App_ModifiedBy, @IsActive, @IsDelete, @AppType_Id, @Old_AppId)" OldValuesParameterFormatString="original_{0}" UpdateCommand="UPDATE [ITP_S_SecurityApp] SET [App_Name] = @App_Name, [App_Description] = @App_Description, [App_DateCreated] = @App_DateCreated, [App_DateModified] = @App_DateModified, [App_CreatedBy] = @App_CreatedBy, [App_ModifiedBy] = @App_ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [AppType_Id] = @AppType_Id, [Old_AppId] = @Old_AppId WHERE [App_Id] = @original_App_Id AND (([App_Name] = @original_App_Name) OR ([App_Name] IS NULL AND @original_App_Name IS NULL)) AND (([App_Description] = @original_App_Description) OR ([App_Description] IS NULL AND @original_App_Description IS NULL)) AND (([App_DateCreated] = @original_App_DateCreated) OR ([App_DateCreated] IS NULL AND @original_App_DateCreated IS NULL)) AND (([App_DateModified] = @original_App_DateModified) OR ([App_DateModified] IS NULL AND @original_App_DateModified IS NULL)) AND (([App_CreatedBy] = @original_App_CreatedBy) OR ([App_CreatedBy] IS NULL AND @original_App_CreatedBy IS NULL)) AND (([App_ModifiedBy] = @original_App_ModifiedBy) OR ([App_ModifiedBy] IS NULL AND @original_App_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([AppType_Id] = @original_AppType_Id) OR ([AppType_Id] IS NULL AND @original_AppType_Id IS NULL)) AND (([Old_AppId] = @original_Old_AppId) OR ([Old_AppId] IS NULL AND @original_Old_AppId IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_App_Id" Type="Int32" />
                                        <asp:Parameter Name="original_App_Name" Type="String" />
                                        <asp:Parameter Name="original_App_Description" Type="String" />
                                        <asp:Parameter Name="original_App_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_App_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_App_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_App_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_AppType_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Old_AppId" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="App_Name" Type="String" />
                                        <asp:Parameter Name="App_Description" Type="String" />
                                        <asp:Parameter Name="App_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="App_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="App_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="App_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="AppType_Id" Type="Int32" />
                                        <asp:Parameter Name="Old_AppId" Type="Int32" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="App_Name" Type="String" />
                                        <asp:Parameter Name="App_Description" Type="String" />
                                        <asp:Parameter Name="App_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="App_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="App_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="App_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="AppType_Id" Type="Int32" />
                                        <asp:Parameter Name="Old_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_App_Id" Type="Int32" />
                                        <asp:Parameter Name="original_App_Name" Type="String" />
                                        <asp:Parameter Name="original_App_Description" Type="String" />
                                        <asp:Parameter Name="original_App_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_App_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_App_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_App_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_AppType_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Old_AppId" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityRoles] WHERE ([AppId] = @AppId)" DeleteCommand="DELETE FROM [ITP_S_SecurityRoles] WHERE [Role_Id] = @original_Role_Id AND (([Role_Name] = @original_Role_Name) OR ([Role_Name] IS NULL AND @original_Role_Name IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([Role_DateCreated] = @original_Role_DateCreated) OR ([Role_DateCreated] IS NULL AND @original_Role_DateCreated IS NULL)) AND (([Role_DateMod] = @original_Role_DateMod) OR ([Role_DateMod] IS NULL AND @original_Role_DateMod IS NULL)) AND (([Role_CreatedBy] = @original_Role_CreatedBy) OR ([Role_CreatedBy] IS NULL AND @original_Role_CreatedBy IS NULL)) AND (([Role_ModBy] = @original_Role_ModBy) OR ([Role_ModBy] IS NULL AND @original_Role_ModBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([CreateAccess] = @original_CreateAccess) OR ([CreateAccess] IS NULL AND @original_CreateAccess IS NULL)) AND (([ReadAccess] = @original_ReadAccess) OR ([ReadAccess] IS NULL AND @original_ReadAccess IS NULL)) AND (([UpdateAccess] = @original_UpdateAccess) OR ([UpdateAccess] IS NULL AND @original_UpdateAccess IS NULL)) AND (([DeleteAccess] = @original_DeleteAccess) OR ([DeleteAccess] IS NULL AND @original_DeleteAccess IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityRoles] ([Role_Name], [AppId], [Role_DateCreated], [Role_DateMod], [Role_CreatedBy], [Role_ModBy], [IsActive], [IsDelete], [Description], [CreateAccess], [ReadAccess], [UpdateAccess], [DeleteAccess]) VALUES (@Role_Name, @AppId, @Role_DateCreated, @Role_DateMod, @Role_CreatedBy, @Role_ModBy, @IsActive, @IsDelete, @Description, @CreateAccess, @ReadAccess, @UpdateAccess, @DeleteAccess)" UpdateCommand="UPDATE [ITP_S_SecurityRoles] SET [Role_Name] = @Role_Name, [AppId] = @AppId, [Role_DateCreated] = @Role_DateCreated, [Role_DateMod] = @Role_DateMod, [Role_CreatedBy] = @Role_CreatedBy, [Role_ModBy] = @Role_ModBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [Description] = @Description, [CreateAccess] = @CreateAccess, [ReadAccess] = @ReadAccess, [UpdateAccess] = @UpdateAccess, [DeleteAccess] = @DeleteAccess WHERE [Role_Id] = @original_Role_Id AND (([Role_Name] = @original_Role_Name) OR ([Role_Name] IS NULL AND @original_Role_Name IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([Role_DateCreated] = @original_Role_DateCreated) OR ([Role_DateCreated] IS NULL AND @original_Role_DateCreated IS NULL)) AND (([Role_DateMod] = @original_Role_DateMod) OR ([Role_DateMod] IS NULL AND @original_Role_DateMod IS NULL)) AND (([Role_CreatedBy] = @original_Role_CreatedBy) OR ([Role_CreatedBy] IS NULL AND @original_Role_CreatedBy IS NULL)) AND (([Role_ModBy] = @original_Role_ModBy) OR ([Role_ModBy] IS NULL AND @original_Role_ModBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([CreateAccess] = @original_CreateAccess) OR ([CreateAccess] IS NULL AND @original_CreateAccess IS NULL)) AND (([ReadAccess] = @original_ReadAccess) OR ([ReadAccess] IS NULL AND @original_ReadAccess IS NULL)) AND (([UpdateAccess] = @original_UpdateAccess) OR ([UpdateAccess] IS NULL AND @original_UpdateAccess IS NULL)) AND (([DeleteAccess] = @original_DeleteAccess) OR ([DeleteAccess] IS NULL AND @original_DeleteAccess IS NULL))" ConflictDetection="CompareAllValues" OldValuesParameterFormatString="original_{0}">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_Role_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Role_Name" Type="String" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_Role_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_Role_DateMod" Type="DateTime" />
                                        <asp:Parameter Name="original_Role_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_Role_ModBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_Description" Type="String" />
                                        <asp:Parameter Name="original_CreateAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_ReadAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_UpdateAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_DeleteAccess" Type="Boolean" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Role_Name" Type="String" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="Role_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="Role_DateMod" Type="DateTime" />
                                        <asp:Parameter Name="Role_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="Role_ModBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="CreateAccess" Type="Boolean" />
                                        <asp:Parameter Name="ReadAccess" Type="Boolean" />
                                        <asp:Parameter Name="UpdateAccess" Type="Boolean" />
                                        <asp:Parameter Name="DeleteAccess" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="AppId" SessionField="MasterAppID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Role_Name" Type="String" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="Role_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="Role_DateMod" Type="DateTime" />
                                        <asp:Parameter Name="Role_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="Role_ModBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="CreateAccess" Type="Boolean" />
                                        <asp:Parameter Name="ReadAccess" Type="Boolean" />
                                        <asp:Parameter Name="UpdateAccess" Type="Boolean" />
                                        <asp:Parameter Name="DeleteAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_Role_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Role_Name" Type="String" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_Role_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_Role_DateMod" Type="DateTime" />
                                        <asp:Parameter Name="original_Role_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_Role_ModBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_Description" Type="String" />
                                        <asp:Parameter Name="original_CreateAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_ReadAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_UpdateAccess" Type="Boolean" />
                                        <asp:Parameter Name="original_DeleteAccess" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUsers" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityUserApp] WHERE ([SecurityApp_Id] = @SecurityApp_Id)" DeleteCommand="DELETE FROM [ITP_S_SecurityUserApp] WHERE [UserApp_Id] = @UserApp_Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserApp] ([Username], [UserApp_DateCreated], [UserApp_DateModified], [UserApp_CreatedBy], [UserApp_ModifiedBy], [UserId], [SecurityApp_Id], [IsActive], [IsDelete], [WASPUserId]) VALUES (@Username, @UserApp_DateCreated, @UserApp_DateModified, @UserApp_CreatedBy, @UserApp_ModifiedBy, @UserId, @SecurityApp_Id, @IsActive, @IsDelete, @WASPUserId)" UpdateCommand="UPDATE [ITP_S_SecurityUserApp] SET [Username] = @Username, [UserApp_DateCreated] = @UserApp_DateCreated, [UserApp_DateModified] = @UserApp_DateModified, [UserApp_CreatedBy] = @UserApp_CreatedBy, [UserApp_ModifiedBy] = @UserApp_ModifiedBy, [UserId] = @UserId, [SecurityApp_Id] = @SecurityApp_Id, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [WASPUserId] = @WASPUserId WHERE [UserApp_Id] = @UserApp_Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="UserApp_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Username" Type="String" />
                                        <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="UserId" Type="Int32" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="WASPUserId" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="SecurityApp_Id" SessionField="MasterAppID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Username" Type="String" />
                                        <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="UserId" Type="Int32" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="WASPUserId" Type="Int32" />
                                        <asp:Parameter Name="UserApp_Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserMaster" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [EmpCode], [FullName], [DepDesc], [UserName], [IsActive] FROM [ITP_S_UserMaster] WHERE ([IsActive] = @IsActive)">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompany] WHERE [UserCompany_Id] = @original_UserCompany_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([UserCompany_DateCreated] = @original_UserCompany_DateCreated) OR ([UserCompany_DateCreated] IS NULL AND @original_UserCompany_DateCreated IS NULL)) AND (([UserCompany_DateModified] = @original_UserCompany_DateModified) OR ([UserCompany_DateModified] IS NULL AND @original_UserCompany_DateModified IS NULL)) AND (([UserCompany_CreatedBy] = @original_UserCompany_CreatedBy) OR ([UserCompany_CreatedBy] IS NULL AND @original_UserCompany_CreatedBy IS NULL)) AND (([UserCompany_ModifiedBy] = @original_UserCompany_ModifiedBy) OR ([UserCompany_ModifiedBy] IS NULL AND @original_UserCompany_ModifiedBy IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompany] ([UserId], [CompanyId], [UserCompany_DateCreated], [UserCompany_DateModified], [UserCompany_CreatedBy], [UserCompany_ModifiedBy], [AppId], [IsDelete], [IsActive], [IsDefault]) VALUES (@UserId, @CompanyId, @UserCompany_DateCreated, @UserCompany_DateModified, @UserCompany_CreatedBy, @UserCompany_ModifiedBy, @AppId, @IsDelete, @IsActive, @IsDefault)" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompany] WHERE (([UserId] = @UserId) AND ([AppId] = @AppId))" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompany] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [UserCompany_DateCreated] = @UserCompany_DateCreated, [UserCompany_DateModified] = @UserCompany_DateModified, [UserCompany_CreatedBy] = @UserCompany_CreatedBy, [UserCompany_ModifiedBy] = @UserCompany_ModifiedBy, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive, [IsDefault] = @IsDefault WHERE [UserCompany_Id] = @original_UserCompany_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([UserCompany_DateCreated] = @original_UserCompany_DateCreated) OR ([UserCompany_DateCreated] IS NULL AND @original_UserCompany_DateCreated IS NULL)) AND (([UserCompany_DateModified] = @original_UserCompany_DateModified) OR ([UserCompany_DateModified] IS NULL AND @original_UserCompany_DateModified IS NULL)) AND (([UserCompany_CreatedBy] = @original_UserCompany_CreatedBy) OR ([UserCompany_CreatedBy] IS NULL AND @original_UserCompany_CreatedBy IS NULL)) AND (([UserCompany_ModifiedBy] = @original_UserCompany_ModifiedBy) OR ([UserCompany_ModifiedBy] IS NULL AND @original_UserCompany_ModifiedBy IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))" ConflictDetection="CompareAllValues" OldValuesParameterFormatString="original_{0}">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_UserCompany_Id" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDefault" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
                                        <asp:SessionParameter Name="AppId" SessionField="MasterSecurityAppID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDefault" Type="Boolean" />
                                        <asp:Parameter Name="original_UserCompany_Id" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserCompanyRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompany] WHERE [UserCompany_Id] = @UserCompany_Id" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompany] ([UserId], [CompanyId], [UserCompany_DateCreated], [UserCompany_DateModified], [UserCompany_CreatedBy], [UserCompany_ModifiedBy], [AppId], [IsDelete], [IsActive]) VALUES (@UserId, @CompanyId, @UserCompany_DateCreated, @UserCompany_DateModified, @UserCompany_CreatedBy, @UserCompany_ModifiedBy, @AppId, @IsDelete, @IsActive)" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompany] WHERE (([AppId] = @AppId) AND ([UserId] = @UserId))" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompany] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [UserCompany_DateCreated] = @UserCompany_DateCreated, [UserCompany_DateModified] = @UserCompany_DateModified, [UserCompany_CreatedBy] = @UserCompany_CreatedBy, [UserCompany_ModifiedBy] = @UserCompany_ModifiedBy, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive WHERE [UserCompany_Id] = @UserCompany_Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="UserCompany_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="AppId" SessionField="MasterAppID" Type="Int32" />
                                        <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="UserCompany_Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlCompanyMaster" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [IsActive], [WASSId] FROM [CompanyMaster] WHERE (([WASSId] IS NOT NULL) AND ([IsActive] = @IsActive)) ORDER BY [CompanyDesc]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserAppRoles] WHERE [UserAppRoles_Id] = @UserAppRoles_Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserAppRoles] ([SecurityRole_Id], [SecurityApp_Id], [Username], [UserId], [UserAppRoles_DateCreated], [UserAppRoles_DateModifed], [UserAppRoles_CreatedBy], [UserAppRoles_ModifiedBy], [IsActive], [IsDelete], [CompanyId], [CR], [RD], [UPD], [DEL]) VALUES (@SecurityRole_Id, @SecurityApp_Id, @Username, @UserId, @UserAppRoles_DateCreated, @UserAppRoles_DateModifed, @UserAppRoles_CreatedBy, @UserAppRoles_ModifiedBy, @IsActive, @IsDelete, @CompanyId, @CR, @RD, @UPD, @DEL)" SelectCommand="SELECT * FROM [ITP_S_SecurityUserAppRoles] WHERE (([CompanyId] = @CompanyId) AND ([SecurityApp_Id] = @SecurityApp_Id) AND ([UserId] = @UserId)) ORDER BY [SecurityRole_Id]" UpdateCommand="UPDATE [ITP_S_SecurityUserAppRoles] SET [SecurityRole_Id] = @SecurityRole_Id, [SecurityApp_Id] = @SecurityApp_Id, [Username] = @Username, [UserId] = @UserId, [UserAppRoles_DateCreated] = @UserAppRoles_DateCreated, [UserAppRoles_DateModifed] = @UserAppRoles_DateModifed, [UserAppRoles_CreatedBy] = @UserAppRoles_CreatedBy, [UserAppRoles_ModifiedBy] = @UserAppRoles_ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [CompanyId] = @CompanyId, [CR] = @CR, [RD] = @RD, [UPD] = @UPD, [DEL] = @DEL WHERE [UserAppRoles_Id] = @UserAppRoles_Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="UserAppRoles_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="SecurityRole_Id" Type="Int32" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="Username" Type="String" />
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="UserAppRoles_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserAppRoles_DateModifed" Type="DateTime" />
                                        <asp:Parameter Name="UserAppRoles_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserAppRoles_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="CR" Type="Boolean" />
                                        <asp:Parameter Name="RD" Type="Boolean" />
                                        <asp:Parameter Name="UPD" Type="Boolean" />
                                        <asp:Parameter Name="DEL" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="CompanyId" SessionField="MasterCompanyID" Type="Int32" />
                                        <asp:SessionParameter Name="SecurityApp_Id" SessionField="MasterAppID" Type="Int32" />
                                        <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="SecurityRole_Id" Type="Int32" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="Username" Type="String" />
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="UserAppRoles_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="UserAppRoles_DateModifed" Type="DateTime" />
                                        <asp:Parameter Name="UserAppRoles_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="UserAppRoles_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="CR" Type="Boolean" />
                                        <asp:Parameter Name="RD" Type="Boolean" />
                                        <asp:Parameter Name="UPD" Type="Boolean" />
                                        <asp:Parameter Name="DEL" Type="Boolean" />
                                        <asp:Parameter Name="UserAppRoles_Id" Type="Int32" />
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
