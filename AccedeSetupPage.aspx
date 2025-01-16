<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeSetupPage.aspx.cs" Inherits="DX_WebTemplate.AccedeSetupPage" %>
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
            <dx:LayoutGroup Caption="ACCEDE Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="1" ActiveTabIndex="2">
                        <Items>
                            <dx:LayoutGroup Caption="Max Pay Method Amnt" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ASPxGridView4" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%" DataSourceID="SqlCompMinCheck">
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
                                                    <SettingsEditing Mode="EditForm">
                                                    </SettingsEditing>
                                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" />
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
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="90px" ShowEditButton="True" ShowNewButtonInHeader="True">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="1" Width="250px" Visible="False">
                                                            
                                                            <CustomButtons>
                                                                
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEditMinCheck" Text="Edit">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" CssClass="commandButton" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                
                                                            </CustomButtons>
                                                            
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataCheckColumn AdaptivePriority="1" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MaxAmount" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            <PropertiesSpinEdit DisplayFormatString="g">
                                                            </PropertiesSpinEdit>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataSpinEditColumn>
                                                        <dx:GridViewDataComboBoxColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="PayMethod_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <PropertiesComboBox DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
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
                                                        <dx:GridViewToolbar Visible="False">
                                                            <Items>
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Command="New" Visible="False">
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
                                                    <Paddings Padding="0px" />
                                                    <Border BorderWidth="0px" />
                                                    <BorderBottom BorderWidth="1px" />
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Payment Method" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%" DataSourceID="SqlPayMethod">
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
                                                    <SettingsEditing Mode="EditForm">
                                                    </SettingsEditing>
                                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" />
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
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="90px" ShowEditButton="True" ShowNewButtonInHeader="True">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="PMethod_desc" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Description">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Payment Method Name">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="1" Width="250px" Visible="False">
                                                            
                                                            <CustomButtons>
                                                                
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEditPay" Text="Edit">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" CssClass="commandButton" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                
                                                            </CustomButtons>
                                                            
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataCheckColumn AdaptivePriority="1" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataCheckColumn>
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
                                                        <dx:GridViewToolbar Visible="False">
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
                                                    <Paddings Padding="0px" />
                                                    <Border BorderWidth="0px" />
                                                    <BorderBottom BorderWidth="1px" />
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Transaction Type" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ASPxGridView2" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" EnableTheming="True" KeyFieldName="CustomerID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%" DataSourceID="SqlTranType">
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
                                                    <SettingsEditing Mode="EditForm">
                                                    </SettingsEditing>
                                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" />
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
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="90px" ShowEditButton="True" ShowNewButtonInHeader="True">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFPTranType_Desc" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Description">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="RFPTranType_Name" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Transaction Name">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="1" Width="250px" Visible="False">
                                                            <CustomButtons>
                                                                
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEditTranType" Text="Edit">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" CssClass="commandButton" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                
                                                            </CustomButtons>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataCheckColumn AdaptivePriority="1" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataCheckColumn>
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
                                                        <dx:GridViewToolbar Visible="False">
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
                                                    <Paddings Padding="0px" />
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
</div>

    <asp:SqlDataSource ID="SqlCompMinCheck" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_M_CheckMinAmount]" DeleteCommand="DELETE FROM [ACCEDE_M_CheckMinAmount] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ACCEDE_M_CheckMinAmount] ([CompanyId], [PayMethod_Id], [MaxAmount], [isActive]) VALUES (@CompanyId, @PayMethod_Id, @MaxAmount, @isActive)" UpdateCommand="UPDATE [ACCEDE_M_CheckMinAmount] SET [CompanyId] = @CompanyId, [PayMethod_Id] = @PayMethod_Id, [MaxAmount] = @MaxAmount, [isActive] = @isActive WHERE [ID] = @original_ID" OldValuesParameterFormatString="original_{0}">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="PayMethod_Id" Type="Int32" />
            <asp:Parameter Name="MaxAmount" Type="Decimal" />
            <asp:Parameter Name="isActive" Type="Boolean" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="PayMethod_Id" Type="Int32" />
            <asp:Parameter Name="MaxAmount" Type="Decimal" />
            <asp:Parameter Name="isActive" Type="Boolean" />
            <asp:Parameter Name="original_ID" Type="Int32" />
        </UpdateParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] ORDER BY [PMethod_name]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_RFPTranType] ORDER BY [RFPTranType_Name]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)"></asp:SqlDataSource>
</asp:Content>
