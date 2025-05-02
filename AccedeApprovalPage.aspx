<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeApprovalPage.aspx.cs" Inherits="DX_WebTemplate.AccedeApprovalPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <%-- DXCOMMENT: Configure ASPxGridView's columns in accordance with datasource fields --%>
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
            LoadingPanel.SetText('Loading Document&hellip;');
            LoadingPanel.Show();
            var rowKey = s.GetRowKey(e.visibleIndex);
            s.GetRowValues(e.visibleIndex, 'AppDocTypeId', function (value) {
                console.log(value);
                console.log(rowKey);
                gridMain.PerformCallback(rowKey + "|" + value);
            });
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
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="90%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="Accede Approval Page" ColSpan="1" GroupBoxDecoration="HeadingLine">
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
                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="sqlMain" EnableTheming="True" KeyFieldName="WFA_Id" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="100%" OnHtmlDataCellPrepared="gridMain_HtmlDataCellPrepared">
                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsAdaptivity AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" HideDataCellsAtWindowInnerWidth="900" AdaptiveDetailColumnCount="2" AllowOnlyOneAdaptiveDetailExpanded="True">
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
                                    <SettingsEditing Mode="EditForm">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
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
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="90px" Visible="False">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="DocNum" ShowInCustomizationForm="True" VisibleIndex="2" AdaptivePriority="2" Caption="Document No.">
                                            <CellStyle Font-Bold="True">
                                            </CellStyle>
                                            <Columns>
                                                <dx:GridViewDataDateColumn AdaptivePriority="3" FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="1">
                                                    <PropertiesDateEdit DisplayFormatString="M/dd/yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    <CellStyle Font-Bold="True">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="1" Caption="Action">
                                            <CustomButtons>

                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="Open">
                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                    </Image>
                                                    <Styles>
                                                        <Style Font-Bold="True" BackColor="#0D6943" CssClass="commandButton" Font-Size="Smaller" ForeColor="White">
                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                        </Style>
                                                    </Styles>
                                                </dx:GridViewCommandColumnCustomButton>

                                            </CustomButtons>
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn Caption="type" FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="AppDocTypeId" Name="doctype" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="RFP_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                            <Columns>
                                                <dx:GridViewDataTextColumn Caption="Transaction Type" FieldName="DocTranType" ShowInCustomizationForm="True" VisibleIndex="0">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Employee Name" FieldName="EmployeeName" ShowInCustomizationForm="True" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="STS_Name" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Status">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Pay Type" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Currency" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                        </dx:GridViewDataTextColumn>
                                    </Columns>
                                    <Toolbars>
                                        <dx:GridViewToolbar>
                                        </dx:GridViewToolbar>
                                        <dx:GridViewToolbar>
                                            <Items>
                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
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
                                <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" EnableTheming="True" Theme="MaterialCompact" Visible="False">
                                    <ClientSideEvents ActionItemClick="OnActionItemClick" Init="OnInit" />
                                    <Items>
                                        <dx:FABActionGroup ContextName="ActionContext">
                                            <Items>
                                                <dx:FABActionItem ActionName="Cancel" Text="Cancel">
                                                    <Image IconID="scheduling_delete_svg_dark_16x16">
                                                    </Image>
                                                </dx:FABActionItem>
                                                <dx:FABActionItem ActionName="NewPage" Text="New">
                                                    <Image IconID="iconbuilder_actions_add_svg_dark_16x16" Url="~/Page_Templates/FormLayout_View.aspx">
                                                    </Image>
                                                </dx:FABActionItem>
                                            </Items>
                                            <ExpandImage IconID="iconbuilder_actions_arrow3up_svg_white_16x16">
                                            </ExpandImage>
                                        </dx:FABActionGroup>
                                    </Items>
                                </dx:ASPxFloatingActionButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    <dx:ASPxLoadingPanel ID="LoadingPanel" Modal="true" ClientInstanceName="LoadingPanel" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
        
</div>


<%-- DXCOMMENT: Configure your datasource for ASPxGridView --%>
<asp:SqlDataSource ID="sqlMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" 
        SelectCommand="SELECT * FROM [vw_ACCEDE_I_ApproverViewFinal1] WHERE ([UserId] = @UserId) ORDER BY [DateAssigned]">
    <SelectParameters>
        <asp:Parameter Name="UserId" Type="String" />
    </SelectParameters>
</asp:SqlDataSource>
   
</asp:Content>
