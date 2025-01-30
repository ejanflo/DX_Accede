<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseMain.aspx.cs" Inherits="DX_WebTemplate.TravelExpense" %>
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
            loadPanel.Show();      
        }

        function OnCompanyChanged(comp) {
            drpdown_CostCenter.PerformCallback(comp);
        }

        function onToolbarItemClick(s, e) { 
            if (e.item.name === "newReport") {
                //window.location.href = "AccedeExpenseReportAdd.aspx";
                AddExpensePopup.Show();
            }
            //else if (e.item.name === "print") {
            //    /*window.location.href = "WebClearPrintingSample.aspx";*/
            //    window.open('WebClearPrintingSample.aspx', '_blank');
            //}
        }

        function OnFnameSelected(s, e) {
            var fullname = s.GetText();

            $.ajax({
                type: "POST",
                url: "TravelExpenseMain.aspx/AJAXGetUserInfo",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    fullname: fullname
                }),
                success: function (response) {
                    if (response.d.depcode == 0)
                        depCB.SetValue("");
                    else
                        depCB.SetValue(response.d.depcode);

                    compCB.SetValue(response.d.companyid);
                },
                failure: function (response) {
                    alert(response);
                }
            });
        }

        function SaveExpense() {
            loadPanel.Show();
            var empcode = employeeCB.GetValue();
            var companyid = compCB.GetValue();
            var department_code = depCB.GetValue();
            var tripto = triptoTB.GetValue();
            var datefrom = datefromDE.GetValue();
            var dateto = datetoDE.GetValue();
            var timedepart = timedepartTE.GetText();
            var timearrive = timearriveTE.GetText();
            var purpose = purposeMemo.GetValue();

            $.ajax({
                type: "POST",
                url: "TravelExpenseMain.aspx/AJAXSaveTravelExpense",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    empcode: empcode,
                    companyid: companyid,
                    department_code: department_code,
                    tripto: tripto,
                    datefrom: datefrom,
                    dateto: dateto,
                    timedepart: timedepart,
                    timearrive: timearrive,
                    purpose: purpose
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    console.log(response.d);
                    if (response.d == true) {
                        
                        window.location.href = "TravelExpenseAdd.aspx";
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }
        </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="My Travel Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Paddings Padding="0px" />
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" Width="100%" DataSourceID="sqlTravelExp" KeyFieldName="ID" OnCustomCallback="expenseGrid_CustomCallback" OnCustomColumnDisplayText="expenseGrid_CustomColumnDisplayText" OnCustomButtonInitialize="expenseGrid_CustomButtonInitialize"  >
                                            <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="onToolbarItemClick" EndCallback="function(s, e) {
	if(s.cp_btnid == &quot;btnPrint&quot;){
	         loadPanel.Hide();
                        window.open(s.cp_url, '_blank');
                        delete(s.cp_btnid);
                        delete(s.cp_url);
              }
}" />
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
                                                                        <dx:ASPxGridView ID="detailGrid" runat="server" AutoGenerateColumns="False"  Width="100%">
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
                                                                        <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False"  Width="100%">
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
                                            <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowClearButton="True" Visible="True" />
                                            <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                            </SettingsExport>
                                            <SettingsLoadingPanel Text="Loading..." Mode="ShowOnStatusBar" />
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
                                                        <dx:GridViewCommandColumnCustomButton ID="btnEdit" Text="Edit">
                                                            <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style BackColor="#006DD6" Font-Bold="True" Font-Italic="False" Font-Size="Smaller" ForeColor="White">
                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnPrint" Text="Print">
                                                            <Image IconID="print_print_svg_gray_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style BackColor="White" Font-Bold="True" Font-Size="Smaller" ForeColor="#878787">
                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                    <Border BorderColor="#878787" BorderStyle="Solid" BorderWidth="1px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="1" FieldName="ID" ReadOnly="True" Visible="False">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Doc_No" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Document No.">
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Employee Name" FieldName="Employee_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="Date_From" ShowInCustomizationForm="True" VisibleIndex="5" Caption="Date From">
                                                    <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataDateColumn Caption="Date To" FieldName="Date_To" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn Caption="Time Departed" FieldName="Time_Departed" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Time Arrived" FieldName="Time_Arrived" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Dep_Code" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepCode" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="4" FieldName="Trip_To" Caption="Trip To">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn Caption="Date Created" FieldName="Date_Created" ShowInCustomizationForm="True" VisibleIndex="12">
                                                    <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy">
                                                    </PropertiesDateEdit>
                                                    <Columns>
                                                        <dx:GridViewDataComboBoxColumn Caption="Prepared By" FieldName="Preparer_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                            <CellStyle Font-Bold="False">
                                                            </CellStyle>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="16">
                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                    </PropertiesComboBox>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                            <Toolbars>
                                                <dx:GridViewToolbar ItemAlign="Right">
                                                    <Items>
                                                        <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                            <Template>
                                                                <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." ShowClearButton="True"  Theme                 ="iOS" Width="400px">
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
                                                        <dx:GridViewToolbarItem Alignment="Left" Name="newReport" Text="New">
                                                            <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
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
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 1" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 3" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 7" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006838">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 8" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#CC2A17">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 13" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#666666">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 20" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 21" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 22" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Progress] &lt; 30" FieldName="Progress" Format="GreenText">
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 30" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 38" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 29" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 39" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 34" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 35" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 36" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                    </CellStyle>
                                                </dx:GridViewFormatConditionHighlight>
                                                <dx:GridViewFormatConditionHighlight Expression="[Status] = 37" FieldName="Status" Format="Custom">
                                                    <CellStyle Font-Bold="True" ForeColor="#E67C0E">
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
    <dx:ASPxPopupControl ID="AddExpensePopup" runat="server" ClientInstanceName="AddExpensePopup" HeaderText="Add Travel Expense" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="30%" CloseAction="CloseButton" CloseOnEscape="True" Modal="True" CssClass="rounded-3">
        <ContentStyle>
            <Paddings PaddingLeft="0px" PaddingRight="0px" />
        </ContentStyle>
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="1000px" Font-Bold="False">
        <Items>
            <dx:LayoutGroup Caption="" ColCount="4" ColSpan="1" ColumnCount="4" GroupBoxDecoration="None" CssClass="mb-4">
                <Paddings Padding="0px" />
                <Items>
                    <dx:LayoutItem Caption="Employee Name" ColSpan="2" ColumnSpan="2" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="employeeCB" runat="server" DataSourceID="SqlUsersDelegated" TextField="FullName" ValueField="DelegateTo_UserID" Width="100%" ClientInstanceName="employeeCB" Font-Bold="True">
                                    <ClientSideEvents SelectedIndexChanged="OnFnameSelected" />
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                        <ParentContainerStyle Font-Bold="False">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Trip To" ColSpan="2" ColumnSpan="2" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="triptoTB" runat="server" ClientInstanceName="triptoTB" Width="100%" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Company" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="compCB" runat="server" ClientInstanceName="compCB" TextField="CompanyShortName" ValueField="WASSId" Width="100%" DataSourceID="sqlCompany" Font-Bold="True">
                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnCompanyChanged(s.GetValue());
}" />
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Department" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="depCB" runat="server" ClientInstanceName="depCB" TextField="DepCode" ValueField="ID" Width="100%" DataSourceID="SqlDepartment" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Date From" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="datefromDE" runat="server" ClientInstanceName="datefromDE" Width="100%" Font-Bold="True">
                                    <CalendarProperties ShowWeekNumbers="False">
                                        <DayStyle>
                                        <Paddings Padding="5px" />
                                        </DayStyle>
                                        <CellStyle>
                                            <Paddings Padding="11px" />
                                        </CellStyle>
                                        <FooterStyle>
                                        <Paddings Padding="3px" />
                                        </FooterStyle>
                                    </CalendarProperties>
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Date To" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="datetoDE" runat="server" ClientInstanceName="datetoDE" Width="100%" Font-Bold="True">
                                    <CalendarProperties ShowWeekNumbers="False">
                                        <DayStyle>
                                        <Paddings Padding="5px" />
                                        </DayStyle>
                                        <CellStyle>
                                            <Paddings Padding="11px" />
                                        </CellStyle>
                                        <FooterStyle>
                                        <Paddings Padding="3px" />
                                        </FooterStyle>
                                    </CalendarProperties>
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Purpose" ColSpan="2" ColumnSpan="2" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="purposeMemo" runat="server" ClientInstanceName="purposeMemo" Width="100%" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Time Departed" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="timedepartTE" runat="server" EditFormat="Time" Width="100%" ClientInstanceName="timedepartTE" Font-Bold="True">
                                    <CalendarProperties ShowClearButton="False" ShowHeader="False" ShowTodayButton="False">
                                        <Style CssClass="custom">
                                        </Style>
                                    </CalendarProperties>
                                    <TimeSectionProperties Visible="True">
                                        <ClockCellStyle>
                                            <Paddings PaddingBottom="0px" PaddingTop="15px" />
                                        </ClockCellStyle>
                                    </TimeSectionProperties>
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Time Arrived" ColSpan="1" VerticalAlign="Top">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="timearriveTE" runat="server" ClientInstanceName="timearriveTE" EditFormat="Time" Width="100%" Font-Bold="True">
                                    <CalendarProperties ShowClearButton="False" ShowHeader="False" ShowTodayButton="False">
                                        <Style CssClass="custom">
                                        </Style>
                                    </CalendarProperties>
                                    <TimeSectionProperties Visible="True">
                                        <ClockCellStyle>
                                            <Paddings PaddingBottom="0px" PaddingTop="15px" />
                                        </ClockCellStyle>
                                    </TimeSectionProperties>
                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="CreateForm">
                                        <RequiredField ErrorText="*Required field" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings Location="Top" />
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right" BackColor="WhiteSmoke" Width="100%">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="btnSaveExpense" runat="server" AutoPostBack="False" ClientInstanceName="btnSaveExpense" Text="Save" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('CreateForm')) SaveExpense();
}" />
                                </dx:ASPxButton>
                                <dx:ASPxButton ID="ASPxFormLayout2_E16" runat="server" AutoPostBack="False" BackColor="White" CssClass="ms-4" ForeColor="Gray" Text="Cancel" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="function(s, e) {
	AddExpensePopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
        <Paddings Padding="0px" />
    </dx:ASPxFormLayout>
        </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="loadPanel" ClientInstanceName="loadPanel" Modal="true" runat="server" Theme="MaterialCompact" Text=""></dx:ASPxLoadingPanel>

        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseMain] WHERE ([Preparer_Id] = @Preparer_Id) OR ([Employee_Id] = @Employee_Id)">
            <SelectParameters>
                <asp:Parameter Name="Preparer_Id" />
                <asp:Parameter Name="Employee_Id" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([DepCode] IS NOT NULL)"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlUsersDelegated" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserDelegationUMaster] WHERE ([DelegateTo_UserID] = @DelegateTo_UserID)">
            <SelectParameters>
                <asp:SessionParameter Name="DelegateTo_UserID" SessionField="userID" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]">
        </asp:SqlDataSource>

</asp:Content>
