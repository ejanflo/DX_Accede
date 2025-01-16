<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TaskDelegation.aspx.cs" Inherits="DX_WebTemplate.Setup.TaskDelegation" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    
    <style>
    .centerPane {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
</style>
    <script>
        function OnCustomButtonClick(s, e) {
            gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
        }

        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                case 'dataSelectAll':
                    gridMain.SelectRows();
                    break;
                case 'dataUnselectAll':
                    gridMain.UnselectRows();
                    break;
                case 'dataSelectAllOnPage':
                    gridMain.SelectAllRowsOnPage();
                    break;
                case 'dataUnselectAllOnPage':
                    gridMain.UnselectAllRowsOnPage();
                    break;
            }
        }
        function OnInit(s, e) {
            fab.SetActionContext("ActionContext", true);
        }
        function OnActionItemClick(s, e) {
            if (e.actionName === "Cancel") {
                history.back()
            }
        }
    </script>
<div class="centerPane conta" id="form1">
    <dx:ASPxFormLayout ID="formTaskDelegation" runat="server" Width="80%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="Task Delegation Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="1">
                                    <TabPages>
                                        <dx:TabPage Text="By Date Range">
                                            <ContentCollection>
                                                <dx:ContentControl runat="server">
                                                    <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="sqlMain" EnableTheming="True" KeyFieldName="ID" Theme="iOS" Width="95%">
                                                        <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                                        <SettingsContextMenu Enabled="True">
                                                        </SettingsContextMenu>
                                                        <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" AllowOnlyOneAdaptiveDetailExpanded="True" HideDataCellsAtWindowInnerWidth="900">
                                                        </SettingsAdaptivity>
                                                        <SettingsCustomizationDialog Enabled="True" />
                                                        <SettingsPager PageSize="32">
                                                            <FirstPageButton Visible="True">
                                                            </FirstPageButton>
                                                            <LastPageButton Visible="True">
                                                            </LastPageButton>
                                                            <PageSizeItemSettings Visible="True">
                                                            </PageSizeItemSettings>
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="PopupEditForm">
                                                        </SettingsEditing>
                                                        <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                        <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                        <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                        <SettingsPopup>
                                                            <EditForm HorizontalAlign="WindowCenter" Modal="True" ShowMaximizeButton="True" VerticalAlign="WindowCenter" Width="600px">
                                                                <SettingsAdaptivity Mode="OnWindowInnerWidth" />
                                                            </EditForm>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                                        <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                                        </SettingsExport>
                                                        <EditFormLayoutProperties>
                                                            <Items>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Approver">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Delegate To">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="App">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Date From">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Date To">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Company">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Remarks">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="is Active">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:EditModeCommandLayoutItem ColSpan="1" HorizontalAlign="Right">
                                                                </dx:EditModeCommandLayoutItem>
                                                            </Items>
                                                        </EditFormLayoutProperties>
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="DateFrom" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <PropertiesDateEdit Width="100%">
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" />
                                                                    </ValidationSettings>
                                                                </PropertiesDateEdit>
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataDateColumn FieldName="DateTo" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                <PropertiesDateEdit Width="100%">
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" />
                                                                    </ValidationSettings>
                                                                </PropertiesDateEdit>
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="OrgRole_ID_Orig" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                <PropertiesComboBox DataSourceID="sqlOrgRoleUser" TextFormatString="{0} - {1}" ValueField="Id" Width="100%">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Name" FieldName="FullName" Name="Name" Width="200px">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Org Role" FieldName="Role_Name" Width="250px">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" />
                                                                    </ValidationSettings>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Delegate To" FieldName="OrgRole_ID_Delegate" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                <PropertiesComboBox DataSourceID="sqlOrgRoleUser" TextFormatString="{0} - {1}" ValueField="Id" Width="100%">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Name" FieldName="FullName" Width="200px">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Org Role" FieldName="Role_Name" Width="250px">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" />
                                                                    </ValidationSettings>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Company" FieldName="CompanyDesc">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="App" FieldName="App_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                <PropertiesComboBox DataSourceID="sqlApp" TextField="App_Name" TextFormatString="{0}" ValueField="App_Id" Width="100%">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="App Name" FieldName="App_Name">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Description" FieldName="App_Description">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" />
                                                                    </ValidationSettings>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="9">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataMemoColumn FieldName="Remarks" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                <PropertiesMemoEdit Width="100%">
                                                                </PropertiesMemoEdit>
                                                            </dx:GridViewDataMemoColumn>
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
                                                                    <dx:GridViewToolbarItem BeginGroup="True" Command="New" Name="New" Text="New" Visible="False">
                                                                        <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                        </Image>
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                    </dx:GridViewToolbarItem>
                                                                </Items>
                                                            </dx:GridViewToolbar>
                                                        </Toolbars>
                                                        <Styles>
                                                            <Header Wrap="True">
                                                            </Header>
                                                            <Row Wrap="True">
                                                            </Row>
                                                            <Cell Wrap="False">
                                                            </Cell>
                                                            <SearchPanel HorizontalAlign="Right">
                                                            </SearchPanel>
                                                        </Styles>
                                                        <Paddings Padding="0px" />
                                                        <Border BorderWidth="0px" />
                                                        <BorderBottom BorderWidth="1px" />
                                                    </dx:ASPxGridView>
                                                </dx:ContentControl>
                                            </ContentCollection>
                                        </dx:TabPage>
                                        <dx:TabPage Text="By Pending Approval">
                                            <ContentCollection>
                                                <dx:ContentControl runat="server">
                                                    
                                                    <dx:ASPxComboBox ID="cboDelegateTo" runat="server" DataSourceID="sqlOrgRoleUser" NullValueItemDisplayText="{0} - {1}" SelectedIndex="0" TextFormatString="{0} - {1}" Width="500px" ToolTip="Delegate to Selected Approver" OnSelectedIndexChanged="cboDelegateTo_SelectedIndexChanged">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Name" FieldName="FullName" Width="200px">
                                                            </dx:ListBoxColumn>
                                                            <dx:ListBoxColumn Caption="Org Role" FieldName="Role_Name" Width="250px">
                                                            </dx:ListBoxColumn>
                                                        </Columns>
                                                        <Items>
                                                            <dx:ListEditItem Selected="True" Text="Please select approver to delegate" Value="0" />
                                                        </Items>
                                                        <ValidationSettings>
                                                            <RequiredField IsRequired="True" />
                                                        </ValidationSettings>
                                                    </dx:ASPxComboBox>
                                                    <dx:ASPxButton ID="btnDelegate" runat="server" OnClick="btnDelegate_Click" Text="Delegate">
                                                    </dx:ASPxButton>
                                                    <dx:ASPxGridView ID="gridPendingActivity" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="sqlWorkflowActivity" EnableTheming="True" KeyFieldName="WFA_Id" Theme="iOS" Width="100%" OnToolbarItemClick="gridPendingActivity_ToolbarItemClick">
                                                        <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                                        <SettingsContextMenu Enabled="True">
                                                        </SettingsContextMenu>
                                                        <SettingsAdaptivity AdaptiveDetailColumnCount="2">
                                                        </SettingsAdaptivity>
                                                        <SettingsCustomizationDialog Enabled="True" />
                                                        <SettingsPager PageSize="32">
                                                            <FirstPageButton Visible="True">
                                                            </FirstPageButton>
                                                            <LastPageButton Visible="True">
                                                            </LastPageButton>
                                                            <PageSizeItemSettings Visible="True">
                                                            </PageSizeItemSettings>
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="PopupEditForm">
                                                        </SettingsEditing>
                                                        <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                        <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                        <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                        <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                        <SettingsPopup>
                                                            <EditForm HorizontalAlign="WindowCenter" Modal="True" ShowMaximizeButton="True" VerticalAlign="WindowCenter" Width="600px">
                                                                <SettingsAdaptivity Mode="OnWindowInnerWidth" />
                                                            </EditForm>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearch0" Visible="True" />
                                                        <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                                        </SettingsExport>
                                                        <EditFormLayoutProperties>
                                                            <Items>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Approver">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Delegate To">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="App">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Date From">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Date To">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Company">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Remarks">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="is Active">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:EditModeCommandLayoutItem ColSpan="1" HorizontalAlign="Right">
                                                                </dx:EditModeCommandLayoutItem>
                                                            </Items>
                                                        </EditFormLayoutProperties>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="WFA_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="19">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataTextColumn Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="16">
                                                                <SettingsHeaderFilter Mode="CheckedList">
                                                                </SettingsHeaderFilter>
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="App" FieldName="App_Name" ShowInCustomizationForm="True" VisibleIndex="17">
                                                                <SettingsHeaderFilter Mode="CheckedList">
                                                                </SettingsHeaderFilter>
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Document No" FieldName="Document_No" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="18">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="15">
                                                                <PropertiesComboBox DataSourceID="sqlOrgRoleUser" TextFormatString="{0} ({1})" ValueField="Id">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Name" FieldName="FullName" Width="200px">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Org Role" FieldName="Role_Name" Width="250px">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                        </Columns>
                                                        <Toolbars>
                                                            <dx:GridViewToolbar>
                                                                <Items>
                                                                    <dx:GridViewToolbarItem BeginGroup="True" Alignment="Left">
                                                                        <Template>
                                                                            <dx:ASPxButtonEdit ID="tbToolbarSearch0" runat="server" Height="100%" NullText="Search Approver to be delegated..." Theme="iOS" Width="500px">
                                                                                <Buttons>
                                                                                    <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                    </dx:SpinButtonExtended>
                                                                                </Buttons>
                                                                            </dx:ASPxButtonEdit>
                                                                        </Template>
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Selection">
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
                                                            <dx:GridViewToolbar>
                                                                <Items>
                                                                    <dx:GridViewToolbarItem BeginGroup="True" Command="New" Name="New" Text="New" Visible="False">
                                                                        <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                        </Image>
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Alignment="Left" BeginGroup="True">
                                                                        <Template>
                                                                        </Template>
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Text="Delegate Selected" Alignment="Right" BeginGroup="True" Name="DelegateTo" Command="Refresh">
                                                                        <Image IconID="richedit_reviewers_svg_dark_16x16">
                                                                        </Image>
                                                                    </dx:GridViewToolbarItem>
                                                                </Items>
                                                            </dx:GridViewToolbar>
                                                        </Toolbars>
                                                        <Styles>
                                                            <Header Wrap="True">
                                                            </Header>
                                                            <Row Wrap="True">
                                                            </Row>
                                                            <Cell Wrap="False">
                                                            </Cell>
                                                            <SearchPanel HorizontalAlign="Right">
                                                            </SearchPanel>
                                                        </Styles>
                                                        <Paddings Padding="0px" />
                                                        <Border BorderWidth="0px" />
                                                        <BorderBottom BorderWidth="1px" />
                                                    </dx:ASPxGridView>
                                                </dx:ContentControl>
                                            </ContentCollection>
                                        </dx:TabPage>
                                    </TabPages>
                                </dx:ASPxPageControl>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
</div>


<%-- DXCOMMENT: Configure your datasource for ASPxGridView --%>
<asp:SqlDataSource ID="sqlMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" 
        SelectCommand="SELECT * FROM [ITP_S_TaskDelegation] ORDER BY [DateFrom] DESC, [Company_ID]" ConflictDetection="CompareAllValues" DeleteCommand="DELETE FROM [ITP_S_TaskDelegation] WHERE [ID] = @original_ID AND (([OrgRole_ID_Orig] = @original_OrgRole_ID_Orig) OR ([OrgRole_ID_Orig] IS NULL AND @original_OrgRole_ID_Orig IS NULL)) AND (([OrgRole_ID_Delegate] = @original_OrgRole_ID_Delegate) OR ([OrgRole_ID_Delegate] IS NULL AND @original_OrgRole_ID_Delegate IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL)) AND (([DateFrom] = @original_DateFrom) OR ([DateFrom] IS NULL AND @original_DateFrom IS NULL)) AND (([DateTo] = @original_DateTo) OR ([DateTo] IS NULL AND @original_DateTo IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([Remarks] = @original_Remarks) OR ([Remarks] IS NULL AND @original_Remarks IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL))" InsertCommand="INSERT INTO [ITP_S_TaskDelegation] ([OrgRole_ID_Orig], [OrgRole_ID_Delegate], [App_ID], [DateFrom], [DateTo], [Company_ID], [Remarks], [isActive]) VALUES (@OrgRole_ID_Orig, @OrgRole_ID_Delegate, @App_ID, @DateFrom, @DateTo, @Company_ID, @Remarks, @isActive)" OldValuesParameterFormatString="original_{0}" UpdateCommand="UPDATE [ITP_S_TaskDelegation] SET [OrgRole_ID_Orig] = @OrgRole_ID_Orig, [OrgRole_ID_Delegate] = @OrgRole_ID_Delegate, [App_ID] = @App_ID, [DateFrom] = @DateFrom, [DateTo] = @DateTo, [Company_ID] = @Company_ID, [Remarks] = @Remarks, [isActive] = @isActive WHERE [ID] = @original_ID AND (([OrgRole_ID_Orig] = @original_OrgRole_ID_Orig) OR ([OrgRole_ID_Orig] IS NULL AND @original_OrgRole_ID_Orig IS NULL)) AND (([OrgRole_ID_Delegate] = @original_OrgRole_ID_Delegate) OR ([OrgRole_ID_Delegate] IS NULL AND @original_OrgRole_ID_Delegate IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL)) AND (([DateFrom] = @original_DateFrom) OR ([DateFrom] IS NULL AND @original_DateFrom IS NULL)) AND (([DateTo] = @original_DateTo) OR ([DateTo] IS NULL AND @original_DateTo IS NULL)) AND (([Company_ID] = @original_Company_ID) OR ([Company_ID] IS NULL AND @original_Company_ID IS NULL)) AND (([Remarks] = @original_Remarks) OR ([Remarks] IS NULL AND @original_Remarks IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL))">
    <DeleteParameters>
        <asp:Parameter Name="original_ID" Type="Int32" />
        <asp:Parameter Name="original_OrgRole_ID_Orig" Type="Int32" />
        <asp:Parameter Name="original_OrgRole_ID_Delegate" Type="Int32" />
        <asp:Parameter Name="original_App_ID" Type="Int32" />
        <asp:Parameter Name="original_DateFrom" Type="DateTime" />
        <asp:Parameter Name="original_DateTo" Type="DateTime" />
        <asp:Parameter Name="original_Company_ID" Type="Int32" />
        <asp:Parameter Name="original_Remarks" Type="String" />
        <asp:Parameter Name="original_isActive" Type="Boolean" />
    </DeleteParameters>
    <InsertParameters>
        <asp:Parameter Name="OrgRole_ID_Orig" Type="Int32" />
        <asp:Parameter Name="OrgRole_ID_Delegate" Type="Int32" />
        <asp:Parameter Name="App_ID" Type="Int32" />
        <asp:Parameter Name="DateFrom" Type="DateTime" />
        <asp:Parameter Name="DateTo" Type="DateTime" />
        <asp:Parameter Name="Company_ID" Type="Int32" />
        <asp:Parameter Name="Remarks" Type="String" />
        <asp:Parameter Name="isActive" Type="Boolean" />
    </InsertParameters>
    <UpdateParameters>
        <asp:Parameter Name="OrgRole_ID_Orig" Type="Int32" />
        <asp:Parameter Name="OrgRole_ID_Delegate" Type="Int32" />
        <asp:Parameter Name="App_ID" Type="Int32" />
        <asp:Parameter Name="DateFrom" Type="DateTime" />
        <asp:Parameter Name="DateTo" Type="DateTime" />
        <asp:Parameter Name="Company_ID" Type="Int32" />
        <asp:Parameter Name="Remarks" Type="String" />
        <asp:Parameter Name="isActive" Type="Boolean" />
        <asp:Parameter Name="original_ID" Type="Int32" />
        <asp:Parameter Name="original_OrgRole_ID_Orig" Type="Int32" />
        <asp:Parameter Name="original_OrgRole_ID_Delegate" Type="Int32" />
        <asp:Parameter Name="original_App_ID" Type="Int32" />
        <asp:Parameter Name="original_DateFrom" Type="DateTime" />
        <asp:Parameter Name="original_DateTo" Type="DateTime" />
        <asp:Parameter Name="original_Company_ID" Type="Int32" />
        <asp:Parameter Name="original_Remarks" Type="String" />
        <asp:Parameter Name="original_isActive" Type="Boolean" />
    </UpdateParameters>
</asp:SqlDataSource>


    <asp:SqlDataSource ID="sqlWorkflowActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ITP_I_PendingWorkflowActivities] ORDER BY [OrgRole_Id], [DateAssigned] DESC, [CompanyShortName]"></asp:SqlDataSource>


    <asp:SqlDataSource ID="sqlOrgRoleUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ITP_I_OrgRoleUsers] ORDER BY [FullName]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityApp] WHERE ([IsActive] = @IsActive) ORDER BY [App_Name]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WASSId], [CompanyDesc], [CompanyShortName], [INTERID] FROM [CompanyMaster] WHERE (([WASSId] IS NOT NULL) AND ([IsActive] = @IsActive)) ORDER BY [CompanyShortName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>


</asp:Content>
