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

        function OnFileUploadComplete(s, e) {
            if (e.callbackData) {
                LoadingPanel.Hide();
                UploadIOPopup.Hide();
                Grid_IO.Refresh();
                alert(e.callbackData);
            }
        }

        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                //case 'dataSelectAll':
                //    gridMain.SelectRows();
                //    break;
                //case 'dataUnselectAll':
                //    gridMain.UnselectRows();
                //    break;
                //case 'dataSelectAllOnPage':
                //    gridMain.SelectAllRowsOnPage();
                //    break;
                //case 'dataUnselectAllOnPage':
                //    gridMain.UnselectAllRowsOnPage();
                //    break;
                case 'New':
                    NewIOPopup.Show();
                    break;
                case 'upload':
                    UploadIOPopup.Show();
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

        function AddNewIO() {
            NewIOPopup.Hide();
            LoadingPanel.SetText("Saving IO&hellip;")
            LoadingPanel.Show();
            var io_num = IO_Num.GetValue() != null ? IO_Num.GetValue() : "";
            var io_desc = IO_Desc.GetValue() != null ? IO_Desc.GetValue() : "";
            var io_comp = IO_Comp.GetValue() != null ? IO_Comp.GetValue() : "";
            var isActive = IO_isActive.GetValue() != null ? IO_isActive.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "AccedeSetupPage.aspx/SaveIOAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    io_num: io_num,
                    io_desc: io_desc,
                    io_comp: io_comp,
                    isActive: isActive
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;

                    if (funcResult == "success") {
                        LoadingPanel.SetText("IO Saved successfully!");
                        LoadingPanel.Show();
                        setTimeout(function () {
                            LoadingPanel.Hide();
                            Grid_IO.Refresh();
                        }, 3000); // Adjust the time (in milliseconds) as needed

                        

                    } else {
                        alert(response.d);
                        LoadingPanel1.SetText('Saving failed!&hellip;');
                        LoadingPanel1.Hide();

                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });

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
                    <dx:TabbedLayoutGroup ColSpan="1" ActiveTabIndex="3">
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
                            <dx:LayoutGroup Caption="IO List" ColSpan="1" ShowCaption="False">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="Grid_IO" runat="server" AutoGenerateColumns="False" ClientInstanceName="Grid_IO" DataSourceID="SqlIO" EnableTheming="True" KeyFieldName="CustomerID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%">
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
                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" />
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
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="90px" Visible="False">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Description" FieldName="IO_Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="IO Number" FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1" Width="250px">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEditTranType0" Text="Edit">
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
                                                        <dx:GridViewDataCheckColumn AdaptivePriority="1" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
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
                                                                <dx:GridViewToolbarItem Name="New" Text="New">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="upload" Text="Upload via template">
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
    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal ="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
        
    <dx:ASPxPopupControl ID="NewIOPopup" runat="server" FooterText="" HeaderText="Add New IO" Width="500px" ClientInstanceName="NewIOPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None">
        <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
        </CloseButtonImage>
        <HeaderStyle BackColor="#006838" ForeColor="White" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollablecontainer3">
                        <dx:ASPxFormLayout ID="EditExpForm" runat="server" Width="100%" ClientInstanceName="EditExpForm">
                    <Items>
                        <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="HeadingLine">
                            <Items>
                                <dx:LayoutItem Caption="IO Number" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="IO_Num" runat="server" Width="100%" ClientInstanceName="IO_Num">
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxTextBox>

                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Description" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="IO_Desc" runat="server" Width="100%" ClientInstanceName="IO_Desc">
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxTextBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Company" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="IO_Comp" runat="server" ClientInstanceName="IO_Comp" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId" Width="100%">
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="is Active" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxCheckBox ID="IO_isActive" runat="server" CheckState="Unchecked" ClientInstanceName="IO_isActive">
                                            </dx:ASPxCheckBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="ASPxButton5" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                <ClientSideEvents Click="function(s, e) {
	AddNewIO();
}" />
                                                <Border BorderColor="#006838" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="ASPxButton6" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                <ClientSideEvents Click="function(s, e) {
                     //ASPxClientEdit.ClearEditorsInContainerById('expDiv');
        	NewIOPopup.Hide();
            }" />
                                                <Border BorderColor="#878787" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="UploadIOPopup" runat="server" FooterText="" HeaderText="Upload IO List" Width="800px" ClientInstanceName="UploadIOPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None">
        <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
        </CloseButtonImage>
        <HeaderStyle BackColor="#006838" ForeColor="White" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollablecontainer3">
                        <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="100%" ClientInstanceName="EditExpForm">
                    <Items>
                        <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="HeadingLine">
                            <Items>
                                <dx:LayoutItem Caption="Upload Template" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxUploadControl ID="UploadControllerIO" runat="server" AutoStartUpload="True" OnFileUploadComplete="UploadControllerIO_FileUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="100%">
                                                <ClientSideEvents FilesUploadComplete="OnFileUploadComplete" FilesUploadStart="function(s, e) {
	LoadingPanel.SetText(&quot;Uploading&amp;hellip;&quot;);
LoadingPanel.Show();
}" FileUploadComplete="OnFileUploadComplete" />
                                                <AdvancedModeSettings EnableFileList="True" EnableMultiSelect="True">
                                                </AdvancedModeSettings>
                                            </dx:ASPxUploadControl>

                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>
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
    <asp:SqlDataSource ID="SqlIO" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_IO]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)"></asp:SqlDataSource>
</asp:Content>
