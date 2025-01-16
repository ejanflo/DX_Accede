<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Main.master" CodeBehind="GridView_ReadOnly.aspx.cs" Inherits="DX_WebTemplate._Default" %>


<asp:Content ID="Content" ContentPlaceHolderID="MainContent" runat="server">
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
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="80%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="Your Page Name Here" ColSpan="1" GroupBoxDecoration="HeadingLine">
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
                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="sqlMain" EnableTheming="True" KeyFieldName="CustomerID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%">
                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                    <SettingsDetail ShowDetailRow="True" />
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
                                    <EditFormLayoutProperties>
                                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
                                    </EditFormLayoutProperties>
                                    <Columns>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="90px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="ContactName" ShowInCustomizationForm="True" VisibleIndex="3" AdaptivePriority="0">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="CompanyName" ShowInCustomizationForm="True" VisibleIndex="2" AdaptivePriority="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="ContactTitle" ShowInCustomizationForm="True" VisibleIndex="4" AdaptivePriority="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="City" ShowInCustomizationForm="True" VisibleIndex="5" AdaptivePriority="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Phone" ShowInCustomizationForm="True" VisibleIndex="9" AdaptivePriority="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="1" Caption="Action" Width="250px">
                                            <CustomButtons>

                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="View">
                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                    </Image>
                                                    <Styles>
                                                        <Style Font-Bold="True" BackColor="#0D6943" CssClass="commandButton" Font-Size="Smaller" ForeColor="White">
                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                        </Style>
                                                    </Styles>
                                                </dx:GridViewCommandColumnCustomButton>

                                                <dx:GridViewCommandColumnCustomButton ID="btnEdit" Text="Edit">
                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                    </Image>
                                                    <Styles>
                                                        <Style Font-Bold="True" BackColor="#006DD6" CssClass="commandButton" Font-Size="Smaller" ForeColor="White">
                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                        </Style>
                                                    </Styles>
                                                </dx:GridViewCommandColumnCustomButton>

                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint" Text="Print">
                                                    <Image IconID="print_print_svg_white_16x16">
                                                    </Image>
                                                    <Styles>
                                                        <Style BackColor="#0D6943" CssClass="commandButton" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                        </Style>
                                                    </Styles>
                                                </dx:GridViewCommandColumnCustomButton>

                                            </CustomButtons>
                                        </dx:GridViewCommandColumn>
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
                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New">
                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="Refresh" Alignment="Right">
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Text="Selection" Alignment="Right">
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
                                <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" EnableTheming="True" Theme="MaterialCompact">
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
</div>


<%-- DXCOMMENT: Configure your datasource for ASPxGridView --%>
<asp:SqlDataSource ID="sqlMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:NWindConnectionString %>" 
        SelectCommand="SELECT * FROM [Customers]">
</asp:SqlDataSource>

</asp:Content>