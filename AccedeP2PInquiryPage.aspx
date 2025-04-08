<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeP2PInquiryPage.aspx.cs" Inherits="DX_WebTemplate.AccedeP2PInquiryPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <%-- DXCOMMENT: Configure ASPxGridView's columns in accordance with datasource fields --%>
    <style>
    .centerPane {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    #scrollableContainer {
            overflow: auto;
            height: 600px;
            border: 1px solid #ccc; 
            padding: 10px; 
        }
</style>
    <script>
        function OnCustomButtonClick(s, e) {
            
            if (e.buttonID == 'btnPrint') {
                gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                LoadingPanel.Show();
            }

            if (e.buttonID == 'btnView') {
                
                //displayRFPDetails(s.GetRowKey(e.visibleIndex));
                //gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                //LoadingPanel.Show();

                LoadingPanel.SetText('Loading Document&hellip;');
                LoadingPanel.Show();
                var rowKey = s.GetRowKey(e.visibleIndex);
                s.GetRowValues(e.visibleIndex, 'SourceTable', function (value) {
                    console.log(value);
                    console.log(rowKey);
                    gridMain.PerformCallback(rowKey + "|" + value + "|" + e.buttonID);
                });
            }

            if (e.buttonID == 'btnViewDisbursed') {

                //displayRFPDetails(s.GetRowKey(e.visibleIndex));
                gridMainDisbursed.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                LoadingPanel.Show();

            }
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
                case 'New':
                    window.location.href = 'RFPCreationPage.aspx';
                    break;
            }
        }
    </script>
<div class="centerPane conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="90%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="Procure to Payment Inquiry Page" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="For Disbursement" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="SqlRFP" EnableTheming="True" KeyFieldName="ID" OnCustomButtonInitialize="gridMain_CustomButtonInitialize" OnCustomCallback="gridMain_CustomCallback" OnHtmlDataCellPrepared="gridMain_HtmlDataCellPrepared" Theme="iOS" Width="100%">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
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
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
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
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="Open">
                                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
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
                                                            <CellStyle HorizontalAlign="Left" VerticalAlign="Middle">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="TranTypeName" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Doc No." FieldName="DocNo" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="7">
                                                            <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="SourceTable" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Requestor" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
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
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
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
                            <dx:LayoutGroup Caption="Disbursed RFP" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMainDisbursed" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMainDisbursed" DataSourceID="SqlRFPDisbursed" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMainDisbursed_CustomCallback" OnHtmlDataCellPrepared="gridMainDisbursed_HtmlDataCellPrepared" Theme="iOS" Width="95%">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
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
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
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
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnViewDisbursed" Text="Open">
                                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint0" Text="Print" Visibility="Invisible">
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
                                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="RFPTranType_Name" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="3" Caption="Payment Method" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Document No." FieldName="RFP_DocNum" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Creator" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                    <Template>
                                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch0" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
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
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
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
                            <dx:LayoutGroup Caption="Disbursed Expense" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMainDisburseExp" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMainDisburseExp" DataSourceID="SqlExpDisbursed" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMainDisburseExp_CustomCallback" OnHtmlDataCellPrepared="gridMainDisburseExp_HtmlDataCellPrepared" Theme="iOS" Width="95%">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
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
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
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
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnViewDisbursedExp" Text="Open">
                                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint1" Text="Print" Visibility="Invisible">
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
                                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="ExpType_Name" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="3" Caption="Payment Method" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Document No." FieldName="DocNo" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Creator" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                    <Template>
                                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch1" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
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
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
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
                        </Items>
                    </dx:TabbedLayoutGroup>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
</div>
    <asp:SqlDataSource ID="SqlExpReport" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpApprovalView] WHERE ([Status] = @Status)">
        <SelectParameters>
            <asp:Parameter Name="Status" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFP" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InquiryCashP2P_2] WHERE (([Status] = @Status) AND ([RoleUserId] = @RoleUserId) AND ([Role_Name] = @Role_Name)) ORDER BY [DateCreated] DESC">
        <SelectParameters>
            <asp:Parameter Name="Status" Type="Int32" />
            <asp:Parameter Name="RoleUserId" Type="String" />
            <asp:Parameter Name="Role_Name" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPDisbursed" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_CashierDisbursedView] WHERE (([ActedBy_User_Id] = @ActedBy_User_Id) AND ([STS_Name] = @STS_Name)) ORDER BY [DateAction] DESC">
    <SelectParameters>
        <asp:Parameter Name="ActedBy_User_Id" Type="String" />
        <asp:Parameter Name="STS_Name" Type="String" />
    </SelectParameters>
 </asp:SqlDataSource>
       <asp:SqlDataSource ID="SqlExpDisbursed" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ApprovalHistory] WHERE (([ActedBy_User_Id] = @ActedBy_User_Id) AND ([STS_Name] = @STS_Name))">
   <SelectParameters>
       <asp:Parameter Name="ActedBy_User_Id" Type="String" />
       <asp:Parameter Name="STS_Name" Type="String" DefaultValue="Disbursed" />
   </SelectParameters>
</asp:SqlDataSource>
</asp:Content>
