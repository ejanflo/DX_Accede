<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeUtilities.aspx.cs" Inherits="DX_WebTemplate.AccedeUtilities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        function OnCustomButtonClick(s, e) {
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            if (e.buttonID != "btnPrint") {
                loadPanel.Show();
            }    

            if (e.buttonID != "btnEditCC") {
                loadPanel.Show();
            }
        }

        function OnToolbarItemClick(s, e) { 
            if (e.item.name === "NewCC") {
                /*window.location.href = "AccedeExpenseReportAdd.aspx";*/

                NewCCPopup.Show();
            }
            //} else if (e.item.name === "print") {
            //    /*window.location.href = "WebClearPrintingSample.aspx";*/
            //    window.open('WebClearPrintingSample.aspx', '_blank');
            //}
        }
    </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%" OnInit="ASPxFormLayout1_Init">
        <Items>
            <dx:LayoutGroup Caption="ACCEDE Utilities" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="Cost Center" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="SqlCostCenterAccede" EnableTheming="True" KeyFieldName="CostCenter_ID" Theme="iOS" Width="95%" OnRowInserting="gridMain_RowInserting" OnRowUpdating="gridMain_RowUpdating">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" EndCallback="function(s, e) {
	if (s.cpErrorMessage) {
        alert(s.cpErrorMessage);
        s.cpErrorMessage = null; // Clear the message
    }
}" />
                                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                    <SettingsContextMenu Enabled="True">
                                                    </SettingsContextMenu>
                                                    <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCells">
                                                    </SettingsAdaptivity>
                                                    <SettingsCustomizationDialog Enabled="True" />
                                                    <SettingsPager AlwaysShowPager="True">
                                                        <PageSizeItemSettings Visible="True">
                                                        </PageSizeItemSettings>
                                                    </SettingsPager>
                                                    <SettingsEditing Mode="Batch">
                                                    </SettingsEditing>
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                                    <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                                    </SettingsExport>
                                                    <SettingsLoadingPanel Mode="Disabled" />
                                                    <EditFormLayoutProperties>
                                                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
                                                    </EditFormLayoutProperties>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0" ShowEditButton="True" ShowNewButtonInHeader="True">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEdit" Text="Edit" Visibility="Invisible">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint" Text="Print" Visibility="Invisible">
                                                                    <Image IconID="dashboards_print_svg_white_16x16" ToolTip="Print Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#E67C03" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Center" VerticalAlign="Middle">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CostCenter" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Cost Center">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CostCenter_ID" ShowInCustomizationForm="True" VisibleIndex="9" Visible="False">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="8">
                                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataTextColumn Caption="Department" FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="7">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                        </dx:GridViewToolbar>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="NewCC" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Left" BeginGroup="True">
                                                                    <Template>
                                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                                            <Buttons>
                                                                                <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                </dx:SpinButtonExtended>
                                                                            </Buttons>
                                                                        </dx:ASPxButtonEdit>
                                                                    </Template>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Selection" Visible="False">
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
                                                    <Border BorderWidth="0px" />
                                                    <BorderBottom BorderWidth="1px" />
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Misc" ColSpan="1">
                                <Items>
                                    <dx:LayoutGroup ColCount="4" ColSpan="1" ColumnCount="4" GroupBoxDecoration="None" HorizontalAlign="Right">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="0px">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxButton ID="saveBTN" runat="server" BackColor="#006838" ClientInstanceName="saveBTN" OnClick="saveBTN_Click" Text="Save">
                                                            <ClientSideEvents Click="function(s, e) {
	loadPanel.Show();
}" />
                                                        </dx:ASPxButton>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="0px">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxButton ID="ASPxFormLayout1_E6" runat="server" BackColor="White" ForeColor="#878787" Text="Back">
                                                            <ClientSideEvents Click="function(s, e) {
	window.open(&quot;Default.aspx&quot;, &quot;_self&quot;);
}" />
                                                            <Border BorderColor="#878787" />
                                                        </dx:ASPxButton>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="Change VAT &amp; EWT" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="Box" Width="50%">
                                        <Items>
                                            <dx:LayoutItem Caption="VAT" ColSpan="1" Width="0px">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxSpinEdit ID="vatTB" runat="server" ClientInstanceName="vatTB" Increment="0.01">
                                                        </dx:ASPxSpinEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="EWT" ColSpan="1" Width="0px">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxSpinEdit ID="ewtTB" runat="server" ClientInstanceName="ewtTB" Increment="0.01">
                                                        </dx:ASPxSpinEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="Change EWT" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
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
        <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([User_ID] = @User_ID) ORDER BY [ID] DESC">
            <SelectParameters>
                <asp:SessionParameter Name="User_ID" SessionField="userID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenterAccede" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter]" DeleteCommand="DELETE FROM [ACCEDE_S_CostCenter] WHERE [CostCenter_ID] = @CostCenter_ID" InsertCommand="INSERT INTO [ACCEDE_S_CostCenter] ([Description], [CostCenter], [CompanyId]) VALUES (@Description, @CostCenter, @CompanyId)" UpdateCommand="UPDATE [ACCEDE_S_CostCenter] SET [Description] = @Description, [CostCenter] = @CostCenter, [CompanyId] = @CompanyId WHERE [CostCenter_ID] = @CostCenter_ID">
        <DeleteParameters>
            <asp:Parameter Name="CostCenter_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="CostCenter" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="CostCenter" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="CostCenter_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlVAT" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_M_Computation]"></asp:SqlDataSource>
</asp:Content>
