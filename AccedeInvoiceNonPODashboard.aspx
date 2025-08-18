<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeInvoiceNonPODashboard.aspx.cs" Inherits="DX_WebTemplate.AccedeInvoiceNonPODashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }

    </style>
        <script>
        function OnCustomButtonClick(s, e) {
            loadPanel.Show();
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            //if (e.buttonID == "btnPrint") {
                
                
            //}           
        }
        function OnUserChanged(userId,comp) {
            //drpdown_Comp.PerformCallback(userId);
            drpdown_Department.PerformCallback(comp);
        }
        function OnCompanyChanged(comp) {
            //drpdown_CostCenter.PerformCallback();
            drpdown_Department.PerformCallback(comp);
            //drpdown_EmpId.PerformCallback(comp);
        }
        function OnDeptChanged(dept_id) {
            //$.ajax({
            //    type: "POST",
            ////    url: "AccedeExpenseReportDashboard.aspx/GetCosCenterFrmDeptAJAX",
            //    contentType: "application/json; charset=utf-8",
            //    dataType: "json",
            //    data: JSON.stringify({
            //        dept_id: dept_id
            //    }),
            //    success: function (response) {
            //        // Update the description text box with the response value
            //        console.log(response.d);
            //        txtbox_CostCenter.SetValue(response.d);

            //    },
            //    error: function (xhr, status, error) {
            //        console.log("Error:", error);
            //    }
            //});
            drpdown_CostCenter.PerformCallback(drpdown_CTComp.GetValue() +"|"+ dept_id);
        }

        function onToolbarItemClick(s, e) { 
            if (e.item.name === "newReport") {
                //window.location.href = "AccedeExpenseReportAdd.aspx";
                AddExpensePopup.Show();
            }
            //} else if (e.item.name === "print") {
            //    /*window.location.href = "WebClearPrintingSample.aspx";*/
            //    window.open('WebClearPrintingSample.aspx', '_blank');
            //}
        }

        function SaveExpense() {
            loadPanel.Show();
            var expName = drpdown_vendor.GetValue();
            var expDate = date_expDate.GetValue();
            var payType = drpdown_PayType.GetValue();
            var Comp = drpdown_Comp.GetValue() != null ? drpdown_Comp.GetValue() : "";
            var CostCenter = drpdown_CostCenter.GetValue() != null ? drpdown_CostCenter.GetValue() : "";
            var expCat = drpdown_expCat.GetValue();
            var Purpose = memo_Purpose.GetValue();
            var isTrav = rdButton_Trav.GetValue();
            var currency = txt_Currency.GetValue();
            var department = drpdown_Department.GetValue() != null ? drpdown_Department.GetValue() : "";
            var classification = drpdown_classification.GetValue();
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var CompLoc = drpdown_CompLocation.GetValue();

            console.log(payType);

            $.ajax({
                type: "POST",
                url: "AccedeInvoiceNonPODashboard.aspx/AddExpenseReportAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expName: expName,
                    expDate: expDate,
                    Comp: Comp,
                    CostCenter: CostCenter,
                    expCat: expCat,
                    Purpose: Purpose,
                    isTrav: isTrav,
                    currency: currency,
                    department: department,
                    payType: payType,
                    classification: classification,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    CompLoc: CompLoc
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    console.log(response.d);
                    if (response.d == true) {
                        
                        window.location.href = "AccedeNonPOEditPage.aspx";
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
            <dx:LayoutGroup Caption="My Invoices (Non-PO)" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="expenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="expenseGrid" Width="100%" DataSourceID="sqlExpense" KeyFieldName="ID" OnToolbarItemClick="expenseGrid_ToolbarItemClick" OnCustomCallback="expenseGrid_CustomCallback" OnCustomButtonInitialize="expenseGrid_CustomButtonInitialize" OnHtmlDataCellPrepared="expenseGrid_HtmlDataCellPrepared">
                                            <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="onToolbarItemClick" EndCallback="function(s, e) {
	if(s.cp_btnid == &quot;btnView&quot; ||s.cp_btnid == &quot;btnEdit&quot; ){
                       window.open(s.cp_url, '_self');
                       delete(s.cp_btnid);
                       delete(s.cp_url);	
         }else if(s.cp_btnid == &quot;btnPrint&quot;){
                       window.open(s.cp_url, '_blank');
                       delete(s.cp_btnid);
                       delete(s.cp_url);
          }else{
                       delete(s.cp_btnid);
                       delete(s.cp_url);
          } 
}" />
                                            <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                            </SettingsAdaptivity>
                                            <Templates>
                                                <DetailRow>
                                                    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                                                        <TabPages>
                                                            <dx:TabPage Text="WORKFLOW ACTIVITY">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="detailGrid" runat="server" AutoGenerateColumns="False" DataSourceID="sqlActivity" KeyFieldName="WFA_Id" OnBeforePerformDataSelect="ASPxGridView2_BeforePerformDataSelect" Width="100%">
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
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn FieldName="WFA_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                    <EditFormSettings Visible="False" />
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                    <PropertiesDateEdit DisplayFormatString="MMM dd, yyyy">
                                                                                    </PropertiesDateEdit>
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                    <PropertiesDateEdit DisplayFormatString="MMM dd, yyyy">
                                                                                    </PropertiesDateEdit>
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="WFD_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Document No." FieldName="Document_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="OrgRole_Id_Orig" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsDelegated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="ActedBy_User_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    <PropertiesComboBox DataSourceID="sqlWorkflow" TextField="Name" ValueField="WF_Id">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                    <PropertiesComboBox DataSourceID="sqlOrgRoleName" TextField="FullName" ValueField="OrgRole_Id">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                            </Columns>
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
                                                                        <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlCA" KeyFieldName="ID" OnBeforePerformDataSelect="CAGrid_BeforePerformDataSelect" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                    <EditFormSettings Visible="False" />
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Cost Center" FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="IO" FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                    <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepDesc" ValueField="ID">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                    <PropertiesComboBox DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                    <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                            </Columns>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                            <dx:TabPage Text="EXPENSES">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="ExpGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ExpenseReportDetail_ID" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                                    <EditFormSettings Visible="False" />
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Particulars" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsUploaded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="ExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:ASPxGridView>
                                                                    </dx:ContentControl>
                                                                </ContentCollection>
                                                            </dx:TabPage>
                                                            <dx:TabPage Text="REIMBURSEMENTS">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="ReimburseGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlReim" KeyFieldName="ID" Width="100%">
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                                    <EditFormSettings Visible="False" />
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Cost Center" FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="IO" FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                                                </dx:GridViewDataDateColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                    <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepDesc" ValueField="ID">
                                                                                    </PropertiesComboBox>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                    <PropertiesComboBox DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID">
                                                                                    </PropertiesComboBox>
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
                                            <SettingsPager AlwaysShowPager="True">
                                                <PageSizeItemSettings Visible="True" Items="5, 10, 20, 50, 100, 200">
                                                </PageSizeItemSettings>
                                            </SettingsPager>
                                            <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel CustomEditorID="tbToolbarSearch" ShowClearButton="True" Visible="True" />
                                            <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                            </SettingsExport>
                                            <SettingsLoadingPanel Mode="Disabled" />
                                            <Columns>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="1" FieldName="ID" ReadOnly="True" Visible="False">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="6" FieldName="Purpose">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Document No." ShowInCustomizationForm="True" VisibleIndex="3" FieldName="DocNo" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
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
                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="11px" PaddingTop="4px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnPrint" Text="Print">
                                                            <Image IconID="dashboards_print_svg_white_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style BackColor="#E67C03" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="ExpChargedTo_CompanyId" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Document No." FieldName="DocNo" ShowInCustomizationForm="True" VisibleIndex="2">
                                                    <PropertiesComboBox DataSourceID="sqlExpenseType" TextField="Description" ValueField="ExpenseType_ID">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Name" FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    <PropertiesComboBox DataSourceID="sqlName" TextField="FullName" ValueField="EmpCode">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <PropertiesComboBox DataSourceID="sqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                    </PropertiesComboBox>
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
                                            <Styles>
                                                <Header Font-Bold="True" HorizontalAlign="Center">
                                                </Header>
                                            </Styles>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
                <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
                </ParentContainerStyle>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    <dx:ASPxPopupControl ID="AddExpensePopup" runat="server" ClientInstanceName="AddExpensePopup" HeaderText="Add Invoice Non-PO" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="80%" CloseAction="CloseButton" CloseOnEscape="True" Modal="True"><ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="1000px">
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2">
                <Items>
                    <dx:LayoutGroup Caption="Header Details" ColSpan="2" ColCount="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine">
                        <Items>
                            <dx:LayoutItem Caption="Charged To Company" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CTComp" runat="server" Width="100%" DataSourceID="SqlUserCompany" TextField="CompanyShortName" ValueField="CompanyId" ClientInstanceName="drpdown_CTComp" OnCallback="drpdown_Comp_Callback">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdown_CTDepartment.PerformCallback(s.GetValue());
drpdown_CostCenter.SetValue(&quot;&quot;);
drpdown_CompLocation.SetValue(&quot;&quot;);
drpdown_Department.PerformCallback(s.GetValue());
OnCompanyChanged(s.GetValue());
drpdown_Comp.SetValue(s.GetValue());
drpdown_CompLocation.PerformCallback(s.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_vendor" runat="server" ClientInstanceName="drpdown_vendor" TextField="VendorName" ValueField="VendorCode" Width="100%" OnCallback="drpdown_EmpId_Callback" DataSourceID="SqlVendor">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnUserChanged(s.GetValue(), drpdown_Comp.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Location" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CompLocation" runat="server" ClientInstanceName="drpdown_CompLocation" DataSourceID="SqlCompLocation" OnCallback="drpdown_CompLocation_Callback" TextField="Name" ValueField="ID" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Charged To Department" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CTDepartment" runat="server" ClientInstanceName="drpdown_CTDepartment" DataSourceID="SqlCTDepartment" DropDownWidth="500px" NullValueItemDisplayText="{1}" OnCallback="drpdown_CTDepartment_Callback" TextField="DepDesc" TextFormatString="{1}" ValueField="ID" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnDeptChanged(s.GetValue());
}" />
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="DepCode" Width="30%">
                                                </dx:ListBoxColumn>
                                                <dx:ListBoxColumn Caption="Description" FieldName="DepDesc" Width="70%">
                                                </dx:ListBoxColumn>
                                            </Columns>
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Report Date" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_expDate" runat="server" Width="100%" ClientInstanceName="date_expDate">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CostCenter" runat="server" ClientInstanceName="drpdown_CostCenter" DataSourceID="SqlCostCenter" DropDownWidth="500px" OnCallback="drpdown_CostCenter_Callback" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Transaction Type" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_PayType" runat="server" Width="100%" DataSourceID="sqlExpenseType" TextField="Description" ValueField="ExpenseType_ID" ClientInstanceName="drpdown_PayType" SelectedIndex="0">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutItem Caption="Currency" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="txt_Currency" runat="server" Width="100%" ClientInstanceName="txt_Currency" DataSourceID="SqlCurrency" TextField="CurrDescription" ValueField="CurrDescription" SelectedIndex="0">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutItem Caption="Expense Category" ColSpan="1" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_expCat" runat="server" Width="100%" DataSourceID="SqlExpCat" TextField="Description" ValueField="ID" ClientInstanceName="drpdown_expCat" SelectedIndex="0">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutItem Caption="Classification" ColSpan="1" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_classification" runat="server" ClientInstanceName="drpdown_classification" DataSourceID="SqlClassification" TextField="ClassificationName" ValueField="ID" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutItem Caption="" ColSpan="1" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <asp:Panel ID="pnlRadioButtons" runat="server" CssClass="radio-buttons-container">
                                            <dx:ASPxRadioButton ID="rdButton_Trav" runat="server" ClientInstanceName="rdButton_Trav" RightToLeft="False" Text="Travel" Width="100px" ReadOnly="True">
                                                <RadioButtonFocusedStyle Wrap="True" />
                                                <ClientSideEvents CheckedChanged="function(s, e) {
                                                    rdButton_NonTrav.SetValue(false);
                                                    onTravelClick();
                                                }" />
                                            </dx:ASPxRadioButton>
                                            <dx:ASPxRadioButton ID="rdButton_NonTrav" runat="server" Checked="True" ClientInstanceName="rdButton_NonTrav" Text="Non-Travel" Width="200px">
                                                <RadioButtonStyle Font-Size="Smaller" Wrap="True" />
                                                <ClientSideEvents CheckedChanged="function(s, e) {
                                                    rdButton_Trav.SetValue(false);
                                                    onTravelClick();
                                                }" />
                                            </dx:ASPxRadioButton>
                                        </asp:Panel>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutItem Caption="Purpose" ColSpan="2" ColumnSpan="2">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="memo_Purpose" runat="server" Width="100%" ClientInstanceName="memo_Purpose">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                <RequiredField ErrorText="Required field." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>


                            <dx:LayoutGroup Caption="Workflow" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" Width="100%" ClientVisible="False">
                                <Items>
                                    <dx:LayoutItem Caption="Company" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_Comp" runat="server" ClientInstanceName="drpdown_Comp" DataSourceID="SqlUserCompany" OnCallback="drpdown_Comp_Callback" TextField="CompanyShortName" ValueField="CompanyId" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnCompanyChanged(s.GetValue());
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                        <RequiredField ErrorText="Required field." IsRequired="True" />
                                                    </ValidationSettings>
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Department" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_Department" runat="server" ClientInstanceName="drpdown_Department" DataSourceID="sqlDept" DropDownWidth="500px" NullValueItemDisplayText="{1}" OnCallback="drpdown_Department_Callback" TextField="DepDesc" TextFormatString="{1}" ValueField="ID" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	//OnDeptChanged(s.GetValue());
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="DepCode" Width="30%">
                                                        </dx:ListBoxColumn>
                                                        <dx:ListBoxColumn Caption="Description" FieldName="DepDesc" Width="70%">
                                                        </dx:ListBoxColumn>
                                                    </Columns>
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreateForm">
                                                        <RequiredField ErrorText="Required field." IsRequired="True" />
                                                    </ValidationSettings>
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>


                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" HorizontalAlign="Right" GroupBoxDecoration="None">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSaveExpense" runat="server" Text="Save" AutoPostBack="False" ClientInstanceName="btnSaveExpense">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('CreateForm')) SaveExpense();
}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxFormLayout2_E16" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
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
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
        </dx:PopupControlContentControl>
</ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType] WHERE ([ExpenseType_ID] = @ExpenseType_ID)">
            <SelectParameters>
                <asp:Parameter DefaultValue="3" Name="ExpenseType_ID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WASSId], [CompanyDesc], [CompanyShortName] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL) ORDER BY [CompanyDesc]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE (([UserId] = @UserId) AND ([ExpenseType_ID] = @ExpenseType_ID)) ORDER BY [ID] DESC">
            <SelectParameters>
                <asp:Parameter Name="UserId" Type="String" />
                <asp:Parameter DefaultValue="3" Name="ExpenseType_ID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_WorkflowActivity] WHERE (([AppId] = @AppId) AND ([AppDocTypeId] = @AppDocTypeId) AND ([Document_Id] = @Document_Id))">
            <SelectParameters>
                <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
                <asp:Parameter DefaultValue="1016" Name="AppDocTypeId" Type="Int32" />
                <asp:SessionParameter Name="Document_Id" SessionField="AccedeExpenseID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]">
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlOrgRoleName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_WebClear_UserIDNames]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUserCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserComp] WHERE (([AppId] = @AppId) AND ([UserId] = @UserId)) ORDER BY [CompanyShortName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
        </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="MoP" Name="Code" Type="String" />
        </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
        </asp:SqlDataSource>
    <%--<asp:SqlDataSource ID="SqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE (([CompanyId] = @CompanyId) AND ([DepartmentId] = @DepartmentId))">
        <SelectParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="DepartmentId" Type="Int32" />
        </SelectParameters>
        </asp:SqlDataSource>--%>
    <asp:SqlDataSource ID="SqlCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([TranType] = @TranType) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
            <asp:Parameter DefaultValue="1" Name="TranType" Type="Int32" />
            <asp:SessionParameter Name="Exp_ID" SessionField="AccedeExpenseID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetails] WHERE ([ExpenseMain_ID] = @ExpenseMain_ID)">
        <SelectParameters>
            <asp:SessionParameter Name="ExpenseMain_ID" SessionField="AccedeExpenseID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReim" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseReim] = @IsExpenseReim) AND ([TranType] = @TranType) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
            <asp:Parameter DefaultValue="2" Name="TranType" Type="Int32" />
            <asp:SessionParameter Name="Exp_ID" SessionField="AccedeExpenseID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([CompanyId] = @CompanyId) AND ([UserId] = @UserId)) ORDER BY [DepDesc]">
        <SelectParameters>
            <asp:Parameter Name="AppId" Type="Int32" DefaultValue="1032" />
            <asp:Parameter Name="IsActive" Type="Boolean" DefaultValue="true" />
            <asp:Parameter DefaultValue="" Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPaymethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserDelegationUMaster] WHERE (([DelegateTo_UserID] = @DelegateTo_UserID) AND ([Company_ID] = @Company_ID) AND ([DateFrom] &lt;= @DateFrom) AND ([DateTo] &gt;= @DateTo) AND ([IsActive] = @IsActive)) ORDER BY [FullName]">
        <SelectParameters>
            <asp:Parameter Name="DelegateTo_UserID" Type="String" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="DateFrom" Type="DateTime" />
            <asp:Parameter Name="DateTo" Type="DateTime" />
            <asp:Parameter DefaultValue="1" Name="IsActive" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Currency]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUserSelf" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT EmpCode AS DelegateFor_UserID, FullName FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
        <SelectParameters>
            <asp:Parameter Name="EmpCode" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification] WHERE ([isActive] = @isActive) ORDER BY [ClassificationName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL))">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompLocation" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlVendor" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_Vendor] ORDER BY [VendorName]"></asp:SqlDataSource>
</asp:Content>
