<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeExpenseReportSaves.aspx.cs" Inherits="DX_WebTemplate.AccedeExpenseReportSaves" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
            function onToolbarItemClick(s, e) {
                if (e.item.name === "addExpense") {
                    ASPxClientEdit.ClearEditorsInContainerById('expDiv');
                    expensePopup.Show();
                } else if (e.item.name === "addCA") {
                    caPopup.Show();
                    capopGrid.PerformCallback();
                } else if (e.item.name === "addReimbursement") {
                    if (ASPxClientEdit.ValidateGroup('submitValid')) {
                        rfpPopup.Show();
                    }
                } else if (e.item.name === "print") {
                    /*window.location.href = "WebClearPrintingSample.aspx";*/
                    /*window.location.href = "WebClearPrintingSample.aspx";*/
                    window.open('WebClearPrintingSample.aspx', '_blank');
                }
            }

            function onTaxComputation(s, e) {
                const vaTax = 1.12;
                const ewTax = 0.01;

                if (s.name == "ASPxSplitter1_Content_ContentSplitter_MainContent_expensePopup_ASPxFormLayout2_ASPxImage3") {
                    vatTB.SetValue(vaTax);
                } else if (s.name == "ASPxSplitter1_Content_ContentSplitter_MainContent_expensePopup_ASPxFormLayout2_ASPxImage5") {
                    ewtTB.SetValue(ewTax);
                }

                let grAmount = grossAmount.GetText();

                if (grAmount.toString() != "") {
                    vat.SetValue((parseFloat(grossAmount.GetValue()) - (parseFloat(grossAmount.GetValue()) / parseFloat(vatTB.GetValue()))));
                    ewt.SetValue(((parseFloat(grossAmount.GetValue()) / parseFloat(vatTB.GetValue())) * parseFloat(ewtTB.GetValue())));
                    netAmount.SetValue(((parseFloat(grossAmount.GetValue()) - parseFloat(ewt.GetValue()))));
                }
                vatPopup.Hide();
                ewtPopup.Hide();
            }

            function onCancelClick(s, e) {
                caPopup.Hide();
                rfpPopup.Hide();
            }
    </script>
        <dx:ASPxCallback ID="amountCallback" runat="server" ClientInstanceName="amountCallback" OnCallback="amountCallback_Callback">
            <ClientSideEvents CallbackComplete="function(s, e) {
	rfpPaymethod.SetValue(e.result);
}" />
        </dx:ASPxCallback>
        <dx:ASPxCallback ID="submitCallback" runat="server" ClientInstanceName="submitCallback" OnCallback="submitCallback_Callback">
        </dx:ASPxCallback>
        <dx:ASPxCallback ID="rfpCallback" runat="server" ClientInstanceName="rfpCallback" OnCallback="rfpCallback_Callback">
        </dx:ASPxCallback>
<dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%" style="margin-bottom: 0px" DataSourceID="sqlExpenseMain">
    <Items>
        <dx:LayoutGroup Caption="New Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
            <Items>
                <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" ColCount="3" ColumnCount="3" ColumnSpan="2">
                    <Items>
                        <dx:LayoutItem Caption="" ColSpan="1">
                            <LayoutItemNestedControlCollection>
                                <dx:LayoutItemNestedControlContainer runat="server">
                                    <dx:ASPxButton ID="saveBtn" runat="server" BackColor="#006DD6" ClientInstanceName="saveBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" OnClick="saveBtn_Click">
                                        <ClientSideEvents Click="function(s, e) {
	loadPanel.SetText(&quot;Saving...&quot;);
	loadPanel.Show();
}" />
                                        <HoverStyle BackColor="#3333FF">
                                        </HoverStyle>
                                        <Border BorderColor="#006DD6" />
                                    </dx:ASPxButton>
                                </dx:LayoutItemNestedControlContainer>
                            </LayoutItemNestedControlCollection>
                        </dx:LayoutItem>
                        <dx:LayoutItem Caption="" ColSpan="1">
                            <LayoutItemNestedControlCollection>
                                <dx:LayoutItemNestedControlContainer runat="server">
                                    <dx:ASPxButton ID="submitBtn" runat="server" BackColor="#006838" Font-Bold="True" Font-Size="Small" Text="Submit" ClientInstanceName="submitBtn" ValidationGroup="submitValid" AutoPostBack="False" UseSubmitBehavior="False">
                                        <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('submitValid')){
	       submitPopup.Show();
                      
               }
}" />
                                    </dx:ASPxButton>
                                </dx:LayoutItemNestedControlContainer>
                            </LayoutItemNestedControlCollection>
                            <ParentContainerStyle Font-Bold="False">
                            </ParentContainerStyle>
                        </dx:LayoutItem>
                        <dx:LayoutItem Caption="" ColSpan="1">
                            <LayoutItemNestedControlCollection>
                                <dx:LayoutItemNestedControlContainer runat="server">
                                    <dx:ASPxButton ID="cancelBtn" runat="server" BackColor="White" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" AutoPostBack="False" ClientInstanceName="cancelBtn" UseSubmitBehavior="False">
                                        <ClientSideEvents Click="function(s, e) {
	DocuGrid1.PerformCallback();
}" />
                                    </dx:ASPxButton>
                                </dx:LayoutItemNestedControlContainer>
                            </LayoutItemNestedControlCollection>
                        </dx:LayoutItem>
                    </Items>
                </dx:LayoutGroup>
                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                </dx:EmptyLayoutItem>
                <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" ColumnSpan="2">
                    <Items>
                        <dx:LayoutGroup Caption="REPORT DETAILS" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="60%">
                            <Items>
                                <dx:LayoutItem Caption="Date" ColSpan="1" FieldName="DateCreated" HorizontalAlign="Right">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxDateEdit ID="dateFiled" runat="server" ClientEnabled="False" ClientInstanceName="dateFiled" DisplayFormatString="MMMM dd, yyyy" EditFormat="Custom" EditFormatString="MMMM dd, yyyy" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                <DropDownButton Visible="False">
                                                </DropDownButton>
                                                <ReadOnlyStyle ForeColor="Black">
                                                </ReadOnlyStyle>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxDateEdit>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionSettings VerticalAlign="Bottom" />
                                    <ParentContainerStyle Font-Bold="False" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Name" ColSpan="1" HorizontalAlign="Left" Width="55%" FieldName="User_ID">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="name" runat="server" ClientInstanceName="name" DataSourceID="sqlName" Font-Bold="True" Font-Size="Small" TextField="FullName" ValueField="EmpCode" Width="100%">
                                                <DropDownButton Visible="False">
                                                </DropDownButton>
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="submitValid">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionSettings HorizontalAlign="Left" VerticalAlign="Bottom" />
                                    <ParentContainerStyle Font-Bold="False" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Company" ColSpan="1" HorizontalAlign="Left" Width="55%" FieldName="Company_ID">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="company" runat="server" DataSourceID="sqlCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="CompanyDesc" ValueField="WASSId" Width="100%" ClientInstanceName="company">
                                                <ClientSideEvents ValueChanged="function(s, e) {
	rfpCompany.SetValue(company.GetValue());
}" />
                                                <ValidationSettings Display="Dynamic" ValidationGroup="submitValid" SetFocusOnError="True">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionSettings HorizontalAlign="Left" VerticalAlign="Bottom" />
                                    <ParentContainerStyle Font-Bold="False" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Expense Report for" ColSpan="1" Height="20px" HorizontalAlign="Left" VerticalAlign="Bottom" FieldName="ExpenseType_ID">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="expenseType" runat="server" ClientInstanceName="expenseType" DataSourceID="sqlExpenseType" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" TextField="Description" ValueField="ExpenseType_ID" Width="100%" ClientReadOnly="True">
                                                <DropDownButton Visible="False">
                                                </DropDownButton>
                                                <ValidationSettings Display="Dynamic" ValidationGroup="submitValid" SetFocusOnError="True">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                                    <ParentContainerStyle Font-Bold="False" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Purpose" ColSpan="1" HorizontalAlign="Right" FieldName="Purpose">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxMemo ID="purpose" runat="server" ClientInstanceName="purpose" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="submitValid">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxMemo>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionSettings HorizontalAlign="Left" VerticalAlign="Bottom" />
                                    <ParentContainerStyle Font-Bold="False" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup ColSpan="1" Caption="CASH ADVANCE DETAILS" GroupBoxDecoration="HeadingLine">
                            <Items>
                                <dx:LayoutItem Caption="Cash Advance" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="caTotal" runat="server" ClientInstanceName="caTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                <Border BorderStyle="None" />
                                            </dx:ASPxTextBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="expenseTotal" runat="server" ClientInstanceName="expenseTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="2px" />
                                            </dx:ASPxTextBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="dueTotal" runat="server" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" Width="100%" ClientInstanceName="dueTotal" ReadOnly="True">
                                                <Border BorderStyle="None" />
                                            </dx:ASPxTextBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:EmptyLayoutItem ColSpan="1">
                                    <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:EmptyLayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Name="reimItem">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="reimBtn" runat="server" AutoPostBack="False" BackColor="#006838" Font-Bold="True" Font-Size="Small" Text="Create Reimbursement" Visible="False" UseSubmitBehavior="False" ClientInstanceName="reimBtn" ValidationGroup="submitValid">
                                                <ClientSideEvents Click="function(s, e) {	               
                 if (ASPxClientEdit.ValidateGroup('submitValid')) {
	          rfpPopup.Show();
                 }
}" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <Paddings PaddingTop="10px" />
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                    </Items>
                </dx:LayoutGroup>
                <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" Name="caGroup" ColumnSpan="2">
                    <Items>
                        <dx:LayoutGroup Caption="CASH ADVANCES" ColSpan="1" Width="50%">
                            <Paddings PaddingBottom="15px" />
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="DocuGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid1" DataSourceID="sqlExpenseCA" Font-Size="Smaller" KeyFieldName="ExpCA_ID" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" OnDataBound="DocuGrid1_DataBound" OnRowDeleting="DocuGrid1_RowDeleting" EnableCallBacks="False" OnCustomCallback="DocuGrid1_CustomCallback">
                                                <ClientSideEvents ToolbarItemClick="onToolbarItemClick" />
                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                <SettingsContextMenu Enabled="True">
                                                </SettingsContextMenu>
                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                    <AdaptiveDetailLayoutProperties>
                                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                        </SettingsAdaptivity>
                                                    </AdaptiveDetailLayoutProperties>
                                                </SettingsAdaptivity>
                                                <SettingsPager AlwaysShowPager="True">
                                                </SettingsPager>
                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <SettingsLoadingPanel Mode="Disabled" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Department_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                    </dx:GridViewDataCheckColumn>
                                                    <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="9">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="10">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="11">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Expr1" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                    </dx:GridViewDataCheckColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="12">
                                                        <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                </Columns>
                                                <Toolbars>
                                                    <dx:GridViewToolbar>
                                                        <Items>
                                                            <dx:GridViewToolbarItem Alignment="Left" Name="addCA" Text="Add">
                                                                <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                </Image>
                                                            </dx:GridViewToolbarItem>
                                                        </Items>
                                                    </dx:GridViewToolbar>
                                                </Toolbars>
                                                <TotalSummary>
                                                    <dx:ASPxSummaryItem FieldName="Amount" SummaryType="Sum" />
                                                </TotalSummary>
                                            </dx:ASPxGridView>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup Caption="EXPENSES" ColSpan="1" GroupBoxDecoration="Box">
                            <Paddings PaddingBottom="15px" />
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" DataSourceID="sqlExpenseDetails" Font-Size="Smaller" KeyFieldName="ExpenseReportDetail_ID" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" OnDataBound="DocuGrid_DataBound" OnRowDeleting="DocuGrid_RowDeleting" EnableCallBacks="False">
                                                <ClientSideEvents ToolbarItemClick="onToolbarItemClick" />
                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                <SettingsContextMenu Enabled="True">
                                                </SettingsContextMenu>
                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                    <AdaptiveDetailLayoutProperties>
                                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                        </SettingsAdaptivity>
                                                    </AdaptiveDetailLayoutProperties>
                                                </SettingsAdaptivity>
                                                <SettingsPager AlwaysShowPager="True">
                                                </SettingsPager>
                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <SettingsLoadingPanel Mode="Disabled" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn Caption="ID" FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn Caption="Date" FieldName="DateAdded" ShowInCustomizationForm="True" VisibleIndex="2" Visible="False">
                                                        <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                        </PropertiesDateEdit>
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataTextColumn Caption="Supplier" FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="TIN" FieldName="TIN" ShowInCustomizationForm="True" VisibleIndex="11" Visible="False">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Invoice/OR No." FieldName="InvoiceOR" ShowInCustomizationForm="True" VisibleIndex="12" Visible="False">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Particulars" FieldName="Particulars" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Gross Amount" FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="VAT" FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="EWT" FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="9">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Net Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="10">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Doc No." FieldName="DocNo" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Account to be Charged" FieldName="AccountToCharged" ShowInCustomizationForm="True" VisibleIndex="5" Visible="False">
                                                        <PropertiesComboBox DataSourceID="sqlAccountCharged" TextField="GLAccount" ValueField="AccCharged_ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="CostCenter/IO/WBS" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                        <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="CostCenter" ValueField="CostCenter_ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                </Columns>
                                                <Toolbars>
                                                    <dx:GridViewToolbar>
                                                        <Items>
                                                            <dx:GridViewToolbarItem Alignment="Left" Name="addExpense" Text="Add">
                                                                <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                </Image>
                                                            </dx:GridViewToolbarItem>
                                                        </Items>
                                                    </dx:GridViewToolbar>
                                                </Toolbars>
                                                <TotalSummary>
                                                    <dx:ASPxSummaryItem FieldName="NetAmount" SummaryType="Sum" />
                                                </TotalSummary>
                                            </dx:ASPxGridView>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                    </Items>
                </dx:LayoutGroup>
                <dx:LayoutGroup ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="None" ColumnSpan="2" Name="reimGroup">
                    <Items>
                        <dx:LayoutGroup Caption="REIMBURSEMENTS" ColSpan="2" ColumnSpan="2" Name="rr" HorizontalAlign="Center" Width="100%">
                            <Paddings PaddingBottom="15px" />
                            <Items>
                                <dx:LayoutItem ColSpan="1" ShowCaption="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="DocuGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid0" DataSourceID="sqlRFPMain" Font-Size="Smaller" KeyFieldName="ID" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" Visible="False">
                                                <ClientSideEvents ToolbarItemClick="onToolbarItemClick" />
                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                <SettingsContextMenu Enabled="True">
                                                </SettingsContextMenu>
                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                    <AdaptiveDetailLayoutProperties>
                                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                        </SettingsAdaptivity>
                                                    </AdaptiveDetailLayoutProperties>
                                                </SettingsAdaptivity>
                                                <SettingsPager AlwaysShowPager="True">
                                                </SettingsPager>
                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <SettingsLoadingPanel Mode="Disabled" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    </dx:GridViewDataCheckColumn>
                                                    <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                        </PropertiesTextEdit>
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="10">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="11">
                                                        <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                        </PropertiesDateEdit>
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                    </dx:GridViewDataCheckColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        <PropertiesComboBox DataSourceID="sqlDept" TextField="DepCode" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="9">
                                                        <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                </Columns>
                                                <Toolbars>
                                                    <dx:GridViewToolbar>
                                                        <Items>
                                                            <dx:GridViewToolbarItem Alignment="Left" Name="addReimbursement" Text="Create Reimbursement">
                                                                <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                </Image>
                                                            </dx:GridViewToolbarItem>
                                                        </Items>
                                                    </dx:GridViewToolbar>
                                                </Toolbars>
                                            </dx:ASPxGridView>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="0px" VerticalAlign="Middle">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxImage ID="errImg" runat="server" ClientInstanceName="errImg" Height="121px" ImageUrl="~/Resources/nodata.png" ShowLoadingImage="True" Width="171px" Caption="No data found" Font-Size="X-Small">
                                                <CaptionSettings HorizontalAlign="Center" Position="Bottom" ShowColon="False" />
                                            </dx:ASPxImage>
                                         
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                    </Items>
                </dx:LayoutGroup>
                <dx:LayoutGroup ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
    <Items>
        <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="2" ColumnSpan="2" Width="100%">
            <Paddings PaddingBottom="15px" />
            <Items>
                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                    <LayoutItemNestedControlCollection>
                        <dx:LayoutItemNestedControlContainer runat="server">
                            <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" Font-Size="Small" NullText="Click Here to Upload Files" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowClearFileSelectionButton="False" ShowProgressPanel="True" ShowUploadButton="True" UploadMode="Auto" Width="100%">
                                <ClientSideEvents FilesUploadComplete="function(s, e) { DocuGrid2.Refresh(); }" />
                                <AdvancedModeSettings EnableMultiSelect="True">
                                </AdvancedModeSettings>
                                <Paddings PaddingBottom="10px" />
                                <NullTextStyle Font-Size="Small">
                                </NullTextStyle>
                                <TextBoxStyle>
                                <DisabledStyle>
                                    <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                </DisabledStyle>
                                <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                </TextBoxStyle>
                                <BrowseButtonStyle BackColor="#006838" ForeColor="White">
                                </BrowseButtonStyle>
                                <ButtonStyle ForeColor="#006838">
                                </ButtonStyle>
                            </dx:ASPxUploadControl>
                            <dx:ASPxGridView ID="DocuGrid2" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid2" Font-Size="Small" KeyFieldName="ID" OnRowDeleting="DocuGrid_RowDeleting" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" DataSourceID="sqlFileAttachment">
                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                    <AdaptiveDetailLayoutProperties>
                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                        </SettingsAdaptivity>
                                    </AdaptiveDetailLayoutProperties>
                                </SettingsAdaptivity>
                                <SettingsPopup>
                                    <FilterControl AutoUpdatePosition="False">
                                    </FilterControl>
                                </SettingsPopup>
                                <Columns>
                                    <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="File Description" FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                    </dx:GridViewDataTextColumn>
                                </Columns>
                            </dx:ASPxGridView>
                        </dx:LayoutItemNestedControlContainer>
                    </LayoutItemNestedControlCollection>
                </dx:LayoutItem>
            </Items>
            <ParentContainerStyle Font-Size="Small">
            </ParentContainerStyle>
        </dx:LayoutGroup>
    </Items>
</dx:LayoutGroup>
            </Items>
            <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
            </ParentContainerStyle>
        </dx:LayoutGroup>
    </Items>
</dx:ASPxFormLayout>
    

        
        <asp:SqlDataSource ID="sqlExpenseType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetails] WHERE ([ID] = @ID) AND ([Preparer_ID] = @Preparer_ID) ORDER BY [ExpenseReportDetail_ID] DESC" DeleteCommand="DELETE FROM [ACCEDE_T_ExpenseDetails] WHERE [ExpenseReportDetail_ID] = @ExpenseReportDetail_ID" InsertCommand="INSERT INTO [ACCEDE_T_ExpenseDetails] ([DateAdded], [Supplier], [TIN], [InvoiceOR], [Particulars], [AccountToCharged], [CostCenterIOWBS], [GrossAmount], [VAT], [EWT], [NetAmount], [IsUploaded], [ID], [Preparer_ID]) VALUES (@DateAdded, @Supplier, @TIN, @InvoiceOR, @Particulars, @AccountToCharged, @CostCenterIOWBS, @GrossAmount, @VAT, @EWT, @NetAmount, @IsUploaded, @ID, @Preparer_ID)" UpdateCommand="UPDATE [ACCEDE_T_ExpenseDetails] SET [DateAdded] = @DateAdded, [Supplier] = @Supplier, [TIN] = @TIN, [InvoiceOR] = @InvoiceOR, [Particulars] = @Particulars, [AccountToCharged] = @AccountToCharged, [CostCenterIOWBS] = @CostCenterIOWBS, [GrossAmount] = @GrossAmount, [VAT] = @VAT, [EWT] = @EWT, [NetAmount] = @NetAmount, [IsUploaded] = @IsUploaded, [ID] = @ID, [Preparer_ID] = @Preparer_ID WHERE [ExpenseReportDetail_ID] = @ExpenseReportDetail_ID">
            <DeleteParameters>
                <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter DbType="Date" Name="DateAdded" />
                <asp:Parameter Name="Supplier" Type="String" />
                <asp:Parameter Name="TIN" Type="String" />
                <asp:Parameter Name="InvoiceOR" Type="String" />
                <asp:Parameter Name="Particulars" Type="String" />
                <asp:Parameter Name="AccountToCharged" Type="String" />
                <asp:Parameter Name="CostCenterIOWBS" Type="String" />
                <asp:Parameter Name="GrossAmount" Type="Decimal" />
                <asp:Parameter Name="VAT" Type="Decimal" />
                <asp:Parameter Name="EWT" Type="Decimal" />
                <asp:Parameter Name="NetAmount" Type="Decimal" />
                <asp:Parameter Name="IsUploaded" Type="Boolean" />
                <asp:Parameter Name="ID" Type="Int32" />
                <asp:Parameter Name="Preparer_ID" Type="Int32" />
            </InsertParameters>
            <SelectParameters>
                <asp:SessionParameter Name="ID" SessionField="cID" />
                <asp:SessionParameter Name="Preparer_ID" SessionField="prep" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter DbType="Date" Name="DateAdded" />
                <asp:Parameter Name="Supplier" Type="String" />
                <asp:Parameter Name="TIN" Type="String" />
                <asp:Parameter Name="InvoiceOR" Type="String" />
                <asp:Parameter Name="Particulars" Type="String" />
                <asp:Parameter Name="AccountToCharged" Type="String" />
                <asp:Parameter Name="CostCenterIOWBS" Type="String" />
                <asp:Parameter Name="GrossAmount" Type="Decimal" />
                <asp:Parameter Name="VAT" Type="Decimal" />
                <asp:Parameter Name="EWT" Type="Decimal" />
                <asp:Parameter Name="NetAmount" Type="Decimal" />
                <asp:Parameter Name="IsUploaded" Type="Boolean" />
                <asp:Parameter Name="ID" Type="Int32" />
                <asp:Parameter Name="Preparer_ID" Type="Int32" />
                <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [WASSId] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)">
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlAccountCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_AccountCharged]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlFileAttachment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_FileAttachment] WHERE (([Doc_ID] = @Doc_ID) AND ([App_ID] = @App_ID))" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileAttachment], [FileName], [Description], [FileExtension], [URL], [DateUploaded], [App_ID], [Company_ID], [Doc_ID], [Doc_No], [User_ID], [FileSize], [DocType_Id]) VALUES (@FileAttachment, @FileName, @Description, @FileExtension, @URL, @DateUploaded, @App_ID, @Company_ID, @Doc_ID, @Doc_No, @User_ID, @FileSize, @DocType_Id)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileAttachment] = @FileAttachment, [FileName] = @FileName, [Description] = @Description, [FileExtension] = @FileExtension, [URL] = @URL, [DateUploaded] = @DateUploaded, [App_ID] = @App_ID, [Company_ID] = @Company_ID, [Doc_ID] = @Doc_ID, [Doc_No] = @Doc_No, [User_ID] = @User_ID, [FileSize] = @FileSize, [DocType_Id] = @DocType_Id WHERE [ID] = @ID">
            <DeleteParameters>
                <asp:Parameter Name="ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="FileAttachment" Type="Object" />
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="FileExtension" Type="String" />
                <asp:Parameter Name="URL" Type="String" />
                <asp:Parameter Name="DateUploaded" Type="DateTime" />
                <asp:Parameter Name="App_ID" Type="Int32" />
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Doc_ID" Type="Int32" />
                <asp:Parameter Name="Doc_No" Type="String" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="FileSize" Type="String" />
                <asp:Parameter Name="DocType_Id" Type="Int32" />
            </InsertParameters>
            <SelectParameters>
                <asp:SessionParameter Name="Doc_ID" SessionField="cID" Type="Int32" />
                <asp:Parameter DefaultValue="1032" Name="App_ID" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="FileAttachment" Type="Object" />
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="FileExtension" Type="String" />
                <asp:Parameter Name="URL" Type="String" />
                <asp:Parameter Name="DateUploaded" Type="DateTime" />
                <asp:Parameter Name="App_ID" Type="Int32" />
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Doc_ID" Type="Int32" />
                <asp:Parameter Name="Doc_No" Type="String" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="FileSize" Type="String" />
                <asp:Parameter Name="DocType_Id" Type="Int32" />
                <asp:Parameter Name="ID" Type="Int32" />
            </UpdateParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
            <SelectParameters>
                <asp:SessionParameter Name="EmpCode" SessionField="userID" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([User_ID] = @User_ID) AND ([Exp_ID] = @ExpID))">
            <SelectParameters>
                <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
                <asp:SessionParameter Name="User_ID" SessionField="userID" Type="String" />
                <asp:SessionParameter DefaultValue="" Name="ExpID" SessionField="cID" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([ID] = @ID)">
            <SelectParameters>
                <asp:SessionParameter Name="ID" SessionField="cID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlRFPMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseReim] = @IsExpenseReim) AND ([Exp_ID] = @Exp_ID))">
            <SelectParameters>
                <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
                <asp:SessionParameter Name="Exp_ID" SessionField="cID" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([User_ID] = @User_ID) AND ([IsExpenseCA] = @IsExpenseCA) AND ([TranType] = @TranType) AND ([Status] = @Status) AND ([Exp_ID] IS NULL))">
            <SelectParameters>
                <asp:SessionParameter Name="User_ID" SessionField="userID" Type="String" />
                <asp:Parameter DefaultValue="False" Name="IsExpenseCA" />
                <asp:Parameter DefaultValue="1" Name="TranType" />
                <asp:Parameter DefaultValue="7" Name="Status" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT ID, DepCode, UPPER(DepDesc) as DepDesc, Company_Code FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL) AND ([Company_Code] IS NOT NULL) ORDER BY DepDesc"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_RFPTranType]"></asp:SqlDataSource>
        <dx:ASPxPopupControl ID="expensePopup" runat="server" FooterText="" HeaderText="New Expense Item" Width="1146px" ClientInstanceName="expensePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	ASPxClientEdit.ClearEditorsInContainerById('expDiv')
}" />
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <div id="expDiv">
            <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="" ColCount="4" ColSpan="1" ColumnCount="4">
                <Items>
                    <dx:LayoutItem Caption="Date" ColSpan="4" ColumnSpan="4" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="dateAdded" runat="server" ClientInstanceName="dateAdded" Font-Size="Small" Width="192px" Font-Bold="True" DisplayFormatString="MMMM dd, yyyy">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Right" />
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Supplier" ColSpan="2" Width="55%" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="supplier" runat="server" Width="100%" ClientInstanceName="supplier" Font-Size="Small" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="TIN" ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="tin" runat="server" Width="100%" ClientInstanceName="tin" Font-Size="Small" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Particulars" ColSpan="2" Width="55%" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="particulars" runat="server" Width="100%" ClientInstanceName="particulars" Font-Size="Small" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Invoice/OR No." ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="invoiceOR" runat="server" Width="100%" ClientInstanceName="invoiceOR" Font-Size="Small" Font-Bold="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Account to be Charged" ColSpan="2" Width="55%" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="accountCharged" runat="server" ClientInstanceName="accountCharged" DataSourceID="sqlAccountCharged" Font-Bold="True" Font-Size="Small" TextField="GLAccount" ValueField="AccCharged_ID" Width="100%">
                                    <Columns>
                                        <dx:ListBoxColumn FieldName="GLAccount" Width="90px">
                                        </dx:ListBoxColumn>
                                        <dx:ListBoxColumn FieldName="TransactionType" Width="500px">
                                        </dx:ListBoxColumn>
                                    </Columns>
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Cost Center/IO/WBS" ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="costCenter" runat="server" ClientInstanceName="costCenter" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" TextField="CostCenter" ValueField="CostCenter_ID" Width="100%">
                                    <Columns>
                                        <dx:ListBoxColumn FieldName="CostCenter" Width="100px">
                                        </dx:ListBoxColumn>
                                        <dx:ListBoxColumn FieldName="Department" Width="220px">
                                        </dx:ListBoxColumn>
                                    </Columns>
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Gross Amount" ColSpan="2" Width="55%" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="grossAmount" runat="server" ClientInstanceName="grossAmount" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Width="100%" DisplayFormatString="N" AllowNull="False" Increment="100">
                                    <ClientSideEvents NumberChanged="onTaxComputation" />
                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="VAT" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="vat" runat="server" ClientInstanceName="vat" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Width="100%" DecimalPlaces="2" ClientReadOnly="True">
                                    <SpinButtons ClientVisible="False">
                                    </SpinButtons>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" VerticalAlign="Bottom" Width="10%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxImage ID="ASPxImage2" runat="server" Cursor="pointer" Height="30px" ImageAlign="Middle" ImageUrl="~/Resources/price_change_20dp.png" ShowLoadingImage="True" ToolTip="Change VAT" Width="30px">
                                    <ClientSideEvents Click="function(s, e) {
	vatPopup.Show();
}" />
                                </dx:ASPxImage>
                                <dx:ASPxImage ID="ASPxImage3" runat="server" Cursor="pointer" Height="25px" ImageAlign="Middle" ImageUrl="~/Resources/restore.png" ShowLoadingImage="True" ToolTip="Reset" Width="25px">
                                    <ClientSideEvents Click="onTaxComputation" />
                                </dx:ASPxImage>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <Paddings Padding="0px" />
                        <NestedControlCellStyle>
                            <Paddings Padding="0px" />
                        </NestedControlCellStyle>
                        <NestedControlStyle HorizontalAlign="Right" VerticalAlign="Middle">
                        </NestedControlStyle>
                        <ParentContainerStyle>
                            <Paddings Padding="0px" />
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="EWT" ColSpan="1" Width="45%">
                        <LayoutItemNestedControlCollection>
<dx:LayoutItemNestedControlContainer runat="server">
    <dx:ASPxSpinEdit ID="ewt" runat="server" ClientInstanceName="ewt" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Width="100%" ClientReadOnly="True" DecimalPlaces="2">
        <SpinButtons ClientVisible="False">
        </SpinButtons>
        <Border BorderStyle="None" />
        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
    </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
</LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" VerticalAlign="Bottom" Width="10%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxImage ID="ASPxImage4" runat="server" Cursor="pointer" Height="30px" ImageAlign="Middle" ImageUrl="~/Resources/price_change_20dp.png" ShowLoadingImage="True" ToolTip="Change EWT" Width="30px">
                                    <ClientSideEvents Click="function(s, e) {
	ewtPopup.Show();
}" />
                                </dx:ASPxImage>
                                <dx:ASPxImage ID="ASPxImage5" runat="server" Cursor="pointer" Height="25px" ImageAlign="Middle" ImageUrl="~/Resources/restore.png" ShowLoadingImage="True" ToolTip="Reset" Width="25px">
                                    <ClientSideEvents Click="onTaxComputation" />
                                </dx:ASPxImage>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <Paddings Padding="0px" />
                        <ParentContainerStyle>
                            <Paddings Padding="0px" />
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Net Amount" ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="netAmount" runat="server" ClientInstanceName="netAmount" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Width="100%" ClientReadOnly="True" DecimalPlaces="2">
                                    <SpinButtons ClientVisible="False">
                                    </SpinButtons>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:EmptyLayoutItem ColSpan="4" ColumnSpan="4">
                    </dx:EmptyLayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" HorizontalAlign="Right" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="popupSubmitBtn" runat="server" Text="Add" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Size="Small" ForeColor="White" Font-Bold="True" OnClick="popupSubmitBtn_Click" ValidationGroup="PopupSubmit" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('PopupSubmit')){
                      loadPanel.Show();
               }
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
                                <dx:ASPxButton ID="popupCancelBtn" runat="server" Text="Cancel" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Size="Small" ForeColor="#878787" Font-Bold="True" AutoPostBack="False" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="function(s, e) {
         ASPxClientEdit.ClearEditorsInContainerById('expDiv');
         expensePopup.Hide();
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
        <dx:ASPxPopupControl ID="rfpPopup" runat="server" FooterText="" HeaderText="Request for Payment Details" Width="1146px" ClientInstanceName="rfpPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	ASPxClientEdit.ClearEditorsInContainerById('expDiv')
}" />
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <div id="expDiv0">
            <dx:ASPxFormLayout ID="rfpLayout" runat="server" Width="100%" ClientInstanceName="rfpLayout">
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="Box">
                <Items>
                    <dx:LayoutItem Caption="Payment Method" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="rfpPaymethod" runat="server" ClientInstanceName="rfpPaymethod" DataSourceID="sqlPayMethod" Font-Bold="True" Font-Size="Small" TextField="PMethod_name" ValueField="ID" Width="100%">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Department" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="rfpDept" runat="server" ClientInstanceName="rfpDept" DataSourceID="sqlDept" Font-Bold="True" Font-Size="Small" TextField="DepDesc" ValueField="ID" Width="100%">
                                    <Columns>
                                        <dx:ListBoxColumn FieldName="DepCode">
                                        </dx:ListBoxColumn>
                                        <dx:ListBoxColumn Caption="Department" FieldName="DepDesc" Width="370px">
                                        </dx:ListBoxColumn>
                                        <dx:ListBoxColumn Caption="Company" FieldName="Company_Code">
                                        </dx:ListBoxColumn>
                                    </Columns>
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Transaction Type" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="rfpTrantype" runat="server" ClientInstanceName="rfpTrantype" DataSourceID="sqlTranType" Font-Bold="True" Font-Size="Small" TextField="RFPTranType_Name" ValueField="ID" Width="100%" SelectedIndex="1" ReadOnly="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxComboBox ID="rfpcostCenter" runat="server" ClientInstanceName="rfpcostCenter" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" TextField="CostCenter" ValueField="CostCenter" Width="100%">
                                    <Columns>
                                        <dx:ListBoxColumn FieldName="CostCenter" Width="100px">
                                        </dx:ListBoxColumn>
                                        <dx:ListBoxColumn FieldName="Department" Width="220px">
                                        </dx:ListBoxColumn>
                                    </Columns>
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxComboBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Payee" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="rfpPayee" runat="server" ClientInstanceName="rfpPayee" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="IO" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="rfpIO" runat="server" ClientInstanceName="rfpIO" Font-Bold="True" Font-Size="Small" Width="100%">
                                    <ValidationSettings>
                                        <RequiredField ErrorText="" />
                                    </ValidationSettings>
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Is Travel?" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxCheckBox ID="rfpTravel" runat="server" CheckState="Unchecked" ClientInstanceName="rfpTravel">
                                    <ClientSideEvents CheckedChanged="function(s, e) {
	if(rfpTravel.GetChecked()){
                                                      
                           rfpLayout.GetItemByName(&quot;lastday&quot;).SetVisible(true);
               }else{
                            rfpLayout.GetItemByName(&quot;lastday&quot;).SetVisible(false);
               }
}" />
                                </dx:ASPxCheckBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutItem Caption="Last Day of Transaction" ColSpan="1" Name="lastday" ClientVisible="False">
                        <LayoutItemNestedControlCollection>
<dx:LayoutItemNestedControlContainer runat="server">
    <dx:ASPxDateEdit ID="rfpLastday" runat="server" ClientInstanceName="rfpLastday" Font-Bold="True" Font-Size="Small" Width="100%">
        <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
            <RequiredField ErrorText="*Required" IsRequired="True" />
        </ValidationSettings>
    </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
</LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                    </dx:EmptyLayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="Note: Payment to vendors and non-employee transactions should reflect at gross amount" ColSpan="1">
                <GroupBoxStyle>
                    <Caption Font-Italic="True">
                    </Caption>
                </GroupBoxStyle>
                <CellStyle Font-Size="Smaller" Font-Underline="False">
                </CellStyle>
                <Items>
                    <dx:LayoutItem Caption="Amount" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="rfpAmount" runat="server" ClientInstanceName="rfpAmount" Font-Bold="True" Font-Size="Small" Width="40%" DisplayFormatString="N" Increment="100" DecimalPlaces="2">
                                    <ClientSideEvents ValueChanged="function(s, e) {
	if(company.GetText() != &quot;&quot; &amp;&amp; rfpAmount.GetValue() != &quot;&quot;){
                       amountCallback.PerformCallback();
               }
}

" />
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Purpose" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="rfpPurpose" runat="server" ClientInstanceName="rfpPurpose" Height="10%" Width="100%" Font-Bold="True" Font-Size="Small">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="rfpValid">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                </Items>
                <ParentContainerStyle Font-Italic="False" Font-Size="Small">
                </ParentContainerStyle>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" HorizontalAlign="Right" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="rfppopupSubmitBtn" runat="server" Text="Add" BackColor="#006838" ClientInstanceName="rfppopupSubmitBtn" Font-Size="Small" ForeColor="White" Font-Bold="True" ValidationGroup="rfpValid" UseSubmitBehavior="False" OnClick="rfppopupSubmitBtn_Click">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('rfpValid')){
                      loadPanel.Show();
               }
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
                                <dx:ASPxButton ID="popupCancelBtn1" runat="server" Text="Cancel" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Size="Small" ForeColor="#878787" Font-Bold="True" AutoPostBack="False" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="onCancelClick" />
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
        <dx:ASPxPopupControl ID="caPopup" runat="server" FooterText="" HeaderText="Select Cash Advance/s" Width="100%" ClientInstanceName="caPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%">
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="capopGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="capopGrid" DataSourceID="sqlRFPMainCA" Font-Size="Smaller" KeyFieldName="ID" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" OnCustomCallback="capopGrid_CustomCallback">
                                    <ClientSideEvents ToolbarItemClick="onToolbarItemClick" />
                                    <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                        <AdaptiveDetailLayoutProperties>
                                            <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                            </SettingsAdaptivity>
                                        </AdaptiveDetailLayoutProperties>
                                    </SettingsAdaptivity>
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <Columns>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Visible="False">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" VisibleIndex="12" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" VisibleIndex="13" Visible="False">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="6">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="7" Caption="IO No.">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" VisibleIndex="10" Caption="Last Day of Transaction">
                                            <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                            </PropertiesDateEdit>
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="8">
                                            <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                            </PropertiesTextEdit>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="9">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" VisibleIndex="15" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="16" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" VisibleIndex="17" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="11">
                                            <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                            </PropertiesDateEdit>
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" VisibleIndex="18" Visible="False">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" VisibleIndex="19" Visible="False">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                            <PropertiesComboBox DataSourceID="sqlDept" TextField="DepCode" ValueField="ID">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="5">
                                            <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                    </Columns>
                                </dx:ASPxGridView>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" HorizontalAlign="Right" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="popupSubmitBtn0" runat="server" Text="Add" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Size="Small" ForeColor="White" Font-Bold="True" OnClick="popupSubmitBtn0_Click" ValidationGroup="PopupSubmit" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(capopGrid.GetSelectedRowCount() &gt; 0){
                      loadPanel.Show();
               }else{
	        alert('No rows selected');
               }
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
                                <dx:ASPxButton ID="popupCancelBtn0" runat="server" Text="Cancel" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Size="Small" ForeColor="#878787" Font-Bold="True" AutoPostBack="False" UseSubmitBehavior="False">
                                    <ClientSideEvents Click="onCancelClick" />
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
                </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>
        <dx:ASPxPopupControl ID="submitPopup" runat="server" ClientInstanceName="submitPopup" HeaderText="Submit?" Height="182px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="383px">
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server" Width="100%">
        <Items>
            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton1" runat="server" BackColor="#006838" Font-Bold="True" Font-Size="Small" Text="Yes">
                                    <ClientSideEvents Click="function(s, e) {
	submitCallback.PerformCallback();
               submitPopup.Hide();
               loadPanel.Show();
}" />
                                    <Border BorderColor="#006838" />
                                </dx:ASPxButton>
                                <dx:ASPxButton ID="ASPxButton2" runat="server" AutoPostBack="False" BackColor="White" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel">
                                    <ClientSideEvents Click="function(s, e) {
	submitPopup.Hide();
}" />
                                    <Border BorderColor="#878787" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>
        <dx:ASPxPopupControl ID="vatPopup" runat="server" ClientInstanceName="vatPopup" HeaderText="VAT" Height="162px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="299px" CloseAction="None" Font-Size="X-Small" ShowCloseButton="False" Modal="True">
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout5" runat="server" Width="60%">
        <Items>
            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="VAT" ColSpan="1" HorizontalAlign="Center" Width="0px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="vatTB" runat="server" ClientInstanceName="vatTB" Increment="0.01" MaxValue="9999999999999999999999">
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Bold="True" Font-Size="X-Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton4" runat="server" AutoPostBack="False" BackColor="White" Font-Bold="True" Font-Size="X-Small" ForeColor="#878787" Text="Close">
                                    <ClientSideEvents Click="onTaxComputation" />
                                    <Border BorderColor="#878787" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>
        <dx:ASPxPopupControl ID="ewtPopup" runat="server" ClientInstanceName="ewtPopup" HeaderText="EWT" Height="162px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="299px" CloseAction="None" Font-Size="X-Small" ShowCloseButton="False" Modal="True">
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout6" runat="server" Width="60%">
        <Items>
            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="None">
                <Items>
                    <dx:LayoutItem Caption="EWT" ColSpan="1" HorizontalAlign="Center" Width="0px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxSpinEdit ID="ewtTB" runat="server" ClientInstanceName="ewtTB" Increment="0.01" MaxValue="999999999999999999999">
                                </dx:ASPxSpinEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Bold="True" Font-Size="X-Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton6" runat="server" AutoPostBack="False" BackColor="White" Font-Bold="True" Font-Size="X-Small" ForeColor="#878787" Text="Close">
                                    <ClientSideEvents Click="onTaxComputation" />
                                    <Border BorderColor="#878787" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>
<dx:ASPxLoadingPanel ID="loadPanel" runat="server" Theme="MaterialCompact" ClientInstanceName="loadPanel" ShowImage="true" ShowText="true" Text="     Processing..." Modal="True">
</dx:ASPxLoadingPanel>
</asp:Content>
