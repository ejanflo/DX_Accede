<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseView.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
    </style>
    <script>
        function RecallDoc() {
            LoadingPanel.Show();
            var remarks = recallRemarks.GetText();

            $.ajax({
                type: "POST",
                url: "TravelExpenseView.aspx/AJAXRecallDocument",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    remarks: remarks
                }),
                success: function (response) {
                    RecallPopup.Hide();
                    window.open('TravelExpenseMain.aspx', '_self');
                },
                failure: function (response) {
                    alert(response);
                }
            });
        }

        function calcExpenses(s, e) {
            var totalSum = 0;

            // Access each grid view by its ClientInstanceName and get the total summary for the specified column
            var grid1 = reimTranGrid.cpSummary;
            var grid2 = fixedAllowGrid.cpSummary;
            var grid3 = miscTravelGrid.cpSummary;
            var grid4 = otherBusGrid.cpSummary;
            var grid5 = entertainmentGrid.cpSummary;
            var grid6 = busMealsGrid.cpSummary;

            // Convert summary values to numbers (if needed) and calculate the total sum
            totalSum += parseFloat(grid1 || 0);
            totalSum += parseFloat(grid2 || 0);
            totalSum += parseFloat(grid3 || 0);
            totalSum += parseFloat(grid4 || 0);
            totalSum += parseFloat(grid5 || 0);
            totalSum += parseFloat(grid6 || 0);

            totalExpTB.SetText(totalSum);
        }

        function linkToRFP(rfpDoc) {

            $.ajax({
                type: "POST",
                url: "TravelExpenseView.aspx/RedirectToRFPDetailsAJAX",
                data: JSON.stringify({
                    rfpDoc: rfpDoc
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    window.open('RFPViewPage.aspx', '_blank');
                    LoadingPanel.Hide();
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function viewRFP(rfpDoc) {
            $.ajax({
                type: "POST",
                url: "TravelExpenseReview.aspx/RedirectToRFPDetailsAJAX",
                data: JSON.stringify({
                    rfpDoc: rfpDoc
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    rfpCompany.SetValue(response.d.rfpCompany);
                    rfpPayMethod.SetValue(response.d.rfpPayMethod);
                    rfpTypeTransact.SetValue(response.d.rfpTypeTransact);
                    rfpSAPDoc.SetValue(response.d.rfpSAPDoc);
                    rfpDepartment.SetValue(response.d.rfpDepartment);
                    rfpCostCenter.SetValue(response.d.rfpCostCenter);
                    rfpIO.SetValue(response.d.rfpIO);
                    rfpPayee.SetValue(response.d.rfpPayee);
                    rfpAmount.SetValue(response.d.rfpAmount);
                    if (response.d.rfpLastDayTransact == null || response.d.rfpLastDayTransact == "01/01/01") {
                        rfpLastDayTransact.SetText("");
                    } else {
                        rfpLastDayTransact.SetText(response.d.rfpLastDayTransact);
                    }
                    rfpPurpose.SetText(response.d.rfpPurpose);
                    rfpDocNo.SetText(response.d.rfpDocNo);
                    if (response.d.rfpChargeToComp == "" || response.d.rfpChargeToComp == null) {
                        if (response.d.rfpChargeToDept == "" || response.d.rfpChargeToDept == null) {
                            rfpChargeTo.SetText("");
                        } else {
                            rfpChargeTo.SetText(response.d.rfpChargeToDept);
                        }
                    } else {
                        rfpChargeTo.SetText(response.d.rfpChargeToComp + "-" + response.d.rfpChargeToDept);
                    }

                    LoadingPanel.Hide();
                    rfpPopup.Show();
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function onCustomButtonClick(s, e) {
            if (e.buttonID == 'btnDownload') {
                LoadingPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";
                isTraDoc = false;
                ViewDocument(fileId, appId);
            } else if (e.buttonID == 'btnTraDownload') {
                LoadingPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";
                isTraDoc = true;
                ViewDocument(fileId, appId);
                travelExpensePopup.Hide();
            } else if (e.buttonID == 'btnEditExpDet') {
                loadPanel.Show();
                var item_id = s.GetRowKey(e.visibleIndex);
                travelDateCalendar.SetDate(null);
                totalExpTB.SetValue('');
                viewExpDetailModal(item_id);
            } else if (e.buttonID == 'btnViewCA') {
                LoadingPanel.Show();
                CAGrid.GetRowValues(e.visibleIndex, 'RFP_DocNum', viewRFP);
                rfpPopup.SetHeaderText("Cash Advance Details");
            } else if (e.buttonID == 'btnViewReim') {
                LoadingPanel.Show();
                ReimburseGrid.GetRowValues(e.visibleIndex, 'RFP_DocNum', viewRFP);
                rfpPopup.SetHeaderText("Reimbursement Details");
            }
        }

        $("#modalClose").on("click", function () {
            $("#viewModal").modal("hide");
            if (isTraDoc == true) {
                travelExpensePopup.Show();
            }
        });

        function viewExpDetailModal(expDetailID) {
            $.ajax({
                type: "POST",
                url: "TravelExpenseReview.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expDetailID: expDetailID
                }),
                success: function (response) {
                    /*ASPxGridView22.PerformCallback("edit");*/
                    totalExpTB.SetValue(response.d.totalExp);
                    travelDateCalendar.SetDate(new Date(response.d.travelDate));
                    //TraDocuGrid.Refresh();
                    //loadPanel.Hide();
                    //travelExpensePopup.Show();

                    if (response.d.status == "Pending at Finance") {
                        window.open("TravelExpenseAddDetails.aspx?action=edit", "_self");
                    } else {
                        window.open("TravelExpenseAddDetails.aspx?action=view", "_self");
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }
    </script>  
    <div class="conta" id="demoFabContent">

        <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>
        <div class="position-fixed bottom-0 right-0 p-3" style="z-index: 5; right: 0; bottom: 0;">
            <div id="liveToast" class="toast hide" data-bs-animation="true" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
                <div class="toast-header">
                    <strong id="toast-header" class="me-auto">Success</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div id="toast-body" class="toast-body">
                </div>
            </div>
        </div>
        <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>

        <dx:ASPxFormLayout ID="ExpenseEditForm" runat="server" Font-Bold="False" Height="144px" Width="100%" Style="margin-bottom: 0px" DataSourceID="SqlMain" ClientInstanceName="ExpenseEditForm" EnableTheming="True" OnInit="ExpenseEditForm_Init">
            <Items>
                <dx:LayoutGroup Caption="New Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2" Name="EditFormName">
                    <Items>
                        <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" ColCount="4" ColumnCount="4" ColumnSpan="2">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1" Name="printItem">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="printButton" runat="server" BackColor="#006838" ClientInstanceName="printButton" Font-Bold="True" Font-Size="Small" Text="Print" AutoPostBack="False" UseSubmitBehavior="False" ValidationGroup="submitValid">
                                                <ClientSideEvents Click="function(s, e) {
	window.open('TravelExpensePrint.aspx', '_blank');
}" />
                                                <Border BorderColor="#006838" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" Name="editItem">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="editButton" runat="server" BackColor="#006DD6" Font-Bold="True" Font-Size="Small" Text="Edit" ClientInstanceName="editButton" AutoPostBack="False" UseSubmitBehavior="False" ForeColor="White">
                                                <ClientSideEvents Click="function(s, e) {
                        LoadingPanel.Show();
                        window.location.href = &quot;TravelExpenseNew.aspx&quot;;
        }
" />
                                                <Border BorderColor="#006DD6" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Bold="False">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem ColSpan="1" Name="recallItem" ShowCaption="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="recallButton" runat="server" AutoPostBack="False" BackColor="#E67C0E" ClientInstanceName="recallButton" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Recall" UseSubmitBehavior="False">
                                                <ClientSideEvents Click="function(s, e) {
                        RecallPopup.Show();
}
" />
                                                <Border BorderColor="#E67C0E" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="cancelBtn" runat="server" BackColor="White" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" AutoPostBack="False" ClientInstanceName="cancelBtn" UseSubmitBehavior="False">
                                                <ClientSideEvents Click="function(s, e) {
                        LoadingPanel.Show();
                        history.back();
        }" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                        </dx:EmptyLayoutItem>
                        <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" ColumnSpan="2" Width="100%">
                            <Paddings PaddingBottom="35px" PaddingTop="35px" />
                            <Items>
                                <dx:LayoutGroup Caption="For Accounting Department Use Only" ColSpan="1" GroupBoxDecoration="HeadingLine" Name="forAccounting" Visible="False">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="forAccountingGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="forAccountingGrid" CssClass="shadow-sm" DataSourceID="SqlTravelForAccounting" Font-Italic="False" KeyFieldName="ID" OnRowInserting="forAccountingGrid_RowInserting" Width="100%">
                                                        <SettingsPager Visible="False">
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="Inline">
                                                            <BatchEditSettings EnableMultipleCellSelection="True" StartEditAction="Click" />
                                                        </SettingsEditing>
                                                        <SettingsCommandButton>
                                                            <UpdateButton Text="Save">
                                                            </UpdateButton>
                                                            <DeleteButton Text="Remove">
                                                            </DeleteButton>
                                                        </SettingsCommandButton>
                                                        <SettingsDataSecurity AllowReadUnlistedFieldsFromClientApi="True" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Code" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="TravelExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataSpinEditColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                </PropertiesSpinEdit>
                                                            </dx:GridViewDataSpinEditColumn>
                                                        </Columns>
                                                        <TotalSummary>
                                                            <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount" SummaryType="Sum" />
                                                        </TotalSummary>
                                                        <Styles>
                                                            <Table>
                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                            </Table>
                                                            <Header>
                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                            </Header>
                                                            <Cell>
                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                            </Cell>
                                                        </Styles>
                                                        <Border BorderColor="#006838" />
                                                    </dx:ASPxGridView>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                    <ParentContainerStyle Font-Bold="True" Font-Size="Medium">
                                    </ParentContainerStyle>
                                </dx:LayoutGroup>
                                <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top" Width="65%">
                                    <Items>
                                        <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" RowSpan="2">
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Employee Name" ColSpan="2" ColumnSpan="2" FieldName="Employee_Id">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="empnameCB" runat="server" AllowMouseWheel="False" ClientEnabled="False" ClientInstanceName="empnameCB" DataSourceID="SqlEmpName" Font-Bold="True" TextField="FullName" ValueField="EmpCode" Width="55%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="Company_Id">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="companyCB" runat="server" ClientEnabled="False" ClientInstanceName="companyCB" DataSourceID="SqlCompany" EnableTheming="True" Font-Bold="True" TextField="CompanyShortName" ValueField="WASSId" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <ValidationSettings>
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Workflow Department" ColSpan="1" FieldName="Dep_Code">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="departmentCB" runat="server" ClientEnabled="False" ClientInstanceName="departmentCB" DataSourceID="SqlDepartment" Font-Bold="True" TextField="DepDesc" ValueField="ID" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="Travel" ColSpan="1" FieldName="ForeignDomestic">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="fordCB" runat="server" ClientEnabled="False" ClientInstanceName="fordCB" Font-Bold="True" Width="100%">
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Italic="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Transaction Type" ColSpan="1" FieldName="ExpenseType_ID">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_expenseType" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_expenseType" DataSourceID="SqlTranType" Font-Bold="True" HorizontalAlign="Left" ReadOnly="True" TextField="Description" ValueField="ExpenseType_ID" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <ValidationSettings>
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Charged To" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="chargedCB" runat="server" ClientEnabled="False" ClientInstanceName="chargedCB" Font-Bold="True" Width="100%">
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Italic="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="Date_Created">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="reportdateDE" runat="server" ClientEnabled="False" ClientInstanceName="reportdateDE" DisplayFormatString="MMMM dd, yyyy" Enabled="False" Font-Bold="True" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <ValidationSettings ValidationGroup="ExpenseEdit">
                                                                </ValidationSettings>
                                                                <BorderLeft BorderStyle="None" />
                                                                <BorderTop BorderStyle="None" />
                                                                <BorderRight BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" Font-Overline="False" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Date From" ColSpan="1" FieldName="Date_From">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="datefromDE" runat="server" ClientEnabled="False" ClientInstanceName="datefromDE" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Date To" ColSpan="1" FieldName="Date_To">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="datetoDE" runat="server" ClientEnabled="False" ClientInstanceName="datetoDE" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Width="100%">
                                                                <DropDownButton Visible="False">
                                                                </DropDownButton>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Time Departed" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTimeEdit ID="timedepartTE" runat="server" ClientEnabled="False" ClientInstanceName="timedepartTE" Font-Bold="True" Width="100%">
                                                                <SpinButtons ClientVisible="False">
                                                                </SpinButtons>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxTimeEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Time Arrived" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTimeEdit ID="timearriveTE" runat="server" ClientEnabled="False" ClientInstanceName="timearriveTE" Font-Bold="True" Width="100%">
                                                                <SpinButtons ClientVisible="False">
                                                                </SpinButtons>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxTimeEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Trip To" ColSpan="1" FieldName="Trip_To">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxMemo ID="tripMemo" runat="server" ClientEnabled="False" ClientInstanceName="tripMemo" Font-Bold="True" Width="100%">
                                                                <ValidationSettings>
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxMemo>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <Paddings PaddingBottom="15px" />
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxMemo ID="purposeMemo" runat="server" ClientEnabled="False" ClientInstanceName="purposeMemo" Font-Bold="True" HorizontalAlign="Left" Width="100%">
                                                                <ValidationSettings>
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxMemo>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <Paddings PaddingBottom="15px" />
                                                    <CaptionStyle Font-Bold="False" Font-Size="Small">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True" Font-Size="Medium">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                                <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top" Width="35%">
                                    <Items>
                                        <dx:LayoutGroup Caption="CASH ADVANCE DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Cash Advance" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxCallbackPanel ID="caTotalCallback" runat="server" ClientInstanceName="caTotalCallback" Width="100%">
                                                                <SettingsLoadingPanel Delay="0" Enabled="False" />
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server">
                                                                        <dx:ASPxTextBox ID="lbl_caTotal" runat="server" ClientEnabled="False" ClientInstanceName="lbl_caTotal" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Large" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                            <Border BorderStyle="None" />
                                                                            <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                            </DisabledStyle>
                                                                        </dx:ASPxTextBox>
                                                                    </dx:PanelContent>
                                                                </PanelCollection>
                                                            </dx:ASPxCallbackPanel>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Size="Medium">
                                                    </CaptionStyle>
                                                    <ParentContainerStyle Font-Bold="True">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxCallbackPanel ID="expTotalCallback" runat="server" ClientInstanceName="expTotalCallback" Width="100%">
                                                                <SettingsLoadingPanel Delay="0" Enabled="False" />
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server">
                                                                        <dx:ASPxTextBox ID="lbl_expenseTotal" runat="server" ClientEnabled="False" ClientInstanceName="lbl_expenseTotal" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Large" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                            <Border BorderStyle="None" />
                                                                            <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="2px" />
                                                                            <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                            </DisabledStyle>
                                                                        </dx:ASPxTextBox>
                                                                    </dx:PanelContent>
                                                                </PanelCollection>
                                                            </dx:ASPxCallbackPanel>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Size="Medium">
                                                    </CaptionStyle>
                                                    <ParentContainerStyle Font-Bold="True">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1" Name="due_lbl">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxCallbackPanel ID="dueTotalCallback" runat="server" ClientInstanceName="dueTotalCallback" Width="100%">
                                                                <SettingsLoadingPanel Delay="0" Text="Please Wait: Summing Up&amp;hellip;" />
                                                                <Styles>
                                                                    <LoadingPanel CssClass="position-relative">
                                                                    </LoadingPanel>
                                                                </Styles>
                                                                <LoadingPanelStyle CssClass="position-relative">
                                                                </LoadingPanelStyle>
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server">
                                                                        <dx:ASPxTextBox ID="lbl_dueTotal" runat="server" ClientEnabled="False" ClientInstanceName="lbl_dueTotal" Font-Bold="True" Font-Size="Large" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                            <Border BorderStyle="None" />
                                                                            <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                            </DisabledStyle>
                                                                        </dx:ASPxTextBox>
                                                                    </dx:PanelContent>
                                                                </PanelCollection>
                                                            </dx:ASPxCallbackPanel>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Size="Medium">
                                                    </CaptionStyle>
                                                    <ParentContainerStyle Font-Bold="True">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                    <BorderBottom BorderColor="#878787" BorderStyle="Solid" BorderWidth="1px" />
                                                    <ParentContainerStyle>
                                                        <Paddings PaddingBottom="15px" />
                                                    </ParentContainerStyle>
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="Reimbursement Details" ClientVisible="False" ColSpan="1" Name="reimDetails" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxButtonEdit ID="reimTB" runat="server" ClientInstanceName="reimTB" Font-Bold="True" ReadOnly="True" Width="100%">
                                                                <ClientSideEvents ButtonClick="function(s, e) {
               LoadingPanel.Show();
               var rfpDoc = reimTB.GetText();
	linkToRFP(rfpDoc);
}" />
                                                                <Buttons>
                                                                    <dx:EditButton ToolTip="View RFP Details" Width="60px">
                                                                        <Image IconID="actions_open2_svg_white_16x16">
                                                                        </Image>
                                                                    </dx:EditButton>
                                                                </Buttons>
                                                                <ButtonStyle BackColor="#006838">
                                                                </ButtonStyle>
                                                                <DisabledStyle Font-Bold="True" Font-Size="Small" ForeColor="#222222">
                                                                </DisabledStyle>
                                                            </dx:ASPxButtonEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                    <Paddings PaddingBottom="15px" PaddingTop="15px" />
                                                    <CaptionCellStyle>
                                                        <Paddings PaddingBottom="10px" />
                                                    </CaptionCellStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="AR Reference No." ClientVisible="False" ColSpan="1" Name="remItem" FieldName="ARRefNo">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="arNoTB" runat="server" ClientEnabled="False" ClientInstanceName="arNoTB" Font-Bold="True" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True">
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                <DisabledStyle ForeColor="#333333">
                                                                </DisabledStyle>
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                    <Paddings PaddingBottom="20px" />
                                                </dx:LayoutItem>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True" Font-Size="Medium">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                            <Paddings PaddingBottom="25px" />
                            <Items>
                                <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="EXPENSES" ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ExpenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpenseGrid" DataSourceID="SqlExpDetails" KeyFieldName="TravelExpenseDetail_ID" Width="100%" OnCustomColumnDisplayText="ExpenseGrid_CustomColumnDisplayText" Theme="MaterialCompact">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                                <SettingsContextMenu Enabled="True">
                                                                </SettingsContextMenu>
                                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                    <AdaptiveDetailLayoutProperties>
                                                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                                        </SettingsAdaptivity>
                                                                    </AdaptiveDetailLayoutProperties>
                                                                </SettingsAdaptivity>
                                                                <Templates>
                                                                    <DetailRow>
                                                                        <dx:ASPxPageControl ID="ASPxPageControl2" runat="server" ActiveTabIndex="0" Visible="False" Width="100%">
                                                                            <TabPages>
                                                                                <dx:TabPage Text="REIMBURSABLE TRANSPORTATION">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="ASPxGridView17" runat="server" AutoGenerateColumns="False" Width="50%">
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                                <dx:TabPage Text="FIXED ALLOWANCES &amp; MISCELLANEOUS TRAVEL EXPENSES">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="ASPxGridView18" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewBandColumn Caption="FIXED ALLOWANCE" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                        <Columns>
                                                                                                            <dx:GridViewDataTextColumn Caption="F or P" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                            </dx:GridViewDataTextColumn>
                                                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                            </dx:GridViewDataTextColumn>
                                                                                                        </Columns>
                                                                                                    </dx:GridViewBandColumn>
                                                                                                    <dx:GridViewBandColumn Caption="MISCELLANEOUS TRAVEL EXPENSE" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                        <Columns>
                                                                                                            <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                            </dx:GridViewDataTextColumn>
                                                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                            </dx:GridViewDataTextColumn>
                                                                                                        </Columns>
                                                                                                    </dx:GridViewBandColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                                <dx:TabPage Text="ENTERTAINMENT">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="ASPxGridView19" runat="server" AutoGenerateColumns="False" Width="50%">
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn Caption="Explanation" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                                <dx:TabPage Text="BUSINESS MEALS">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="ASPxGridView20" runat="server" AutoGenerateColumns="False" Width="50%">
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn Caption="Explanation" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                                <dx:TabPage Text="OTHER BUSINESS EXPENSES">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="ASPxGridView21" runat="server" AutoGenerateColumns="False" Width="50%">
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                            </TabPages>
                                                                        </dx:ASPxPageControl>
                                                                    </DetailRow>
                                                                </Templates>
                                                                <SettingsPager Visible="False">
                                                                </SettingsPager>
                                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="ShowOnStatusBar" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnEditExpDet" Text="View">
                                                                                <Image IconID="actions_open2_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                        <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="ID" FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn Caption="Date" FieldName="TravelExpenseDetail_Date" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn Caption="ENTERTAINMENT" FieldName="VAT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                        </PropertiesTextEdit>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="BUSINESS MEALS" FieldName="EWT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                        </PropertiesTextEdit>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Account to be Charged" FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                        <PropertiesComboBox DataSourceID="sqlAccountCharged" TextField="GLAccount" ValueField="AccCharged_ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="CostCenter/IO/WBS" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                        <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="CostCenter" ValueField="CostCenter_ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewBandColumn Caption="FIXED ALLOW. &amp; MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                        <Columns>
                                                                            <dx:GridViewBandColumn Caption="Fixed Allowance" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                <Columns>
                                                                                    <dx:GridViewDataTextColumn Caption="F or P" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="Misc. Travel Expense" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                <Columns>
                                                                                    <dx:GridViewDataTextColumn Caption="Type " ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewBandColumn Caption="OTHER BUSINESS EXPENSES" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="TIN" FieldName="TravelExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataSpinEditColumn Caption="Total Expenses" FieldName="Total_Expenses" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataSpinEditColumn>
                                                                    <dx:GridViewDataSpinEditColumn Caption="Fixed Allowances" FieldName="TravelExpenseDetail_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                    </dx:GridViewDataSpinEditColumn>
                                                                    <dx:GridViewDataSpinEditColumn Caption="Other Travel Expenses" FieldName="TravelExpenseDetail_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                    </dx:GridViewDataSpinEditColumn>
                                                                    <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                        <CellStyle HorizontalAlign="Center">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataTextColumn>
                                                                </Columns>
                                                                <Toolbars>
                                                                    <dx:GridViewToolbar Visible="False">
                                                                        <Items>
                                                                            <dx:GridViewToolbarItem Alignment="Left" Name="addExpense" Text="Add">
                                                                                <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                                </Image>
                                                                            </dx:GridViewToolbarItem>
                                                                        </Items>
                                                                    </dx:GridViewToolbar>
                                                                </Toolbars>
                                                                <TotalSummary>
                                                                    <dx:ASPxSummaryItem FieldName="Total_Expenses" SummaryType="Sum" />
                                                                </TotalSummary>
                                                                <Styles>
                                                                    <Disabled ForeColor="#222222">
                                                                    </Disabled>
                                                                    <Header>
                                                                        <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                    </Header>
                                                                    <Cell>
                                                                        <Paddings Padding="5px" />
                                                                    </Cell>
                                                                </Styles>
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                        <dx:LayoutGroup Caption="CASH ADVANCES" ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CAGrid" DataSourceID="sqlExpenseCA" KeyFieldName="ID" Width="100%" Theme="MaterialCompact" OnCustomColumnDisplayText="ExpenseGrid_CustomColumnDisplayText">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                                <SettingsContextMenu Enabled="True">
                                                                </SettingsContextMenu>
                                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                    <AdaptiveDetailLayoutProperties>
                                                                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                                        </SettingsAdaptivity>
                                                                    </AdaptiveDetailLayoutProperties>
                                                                </SettingsAdaptivity>
                                                                <SettingsPager Visible="False">
                                                                </SettingsPager>
                                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                                <SettingsBehavior ConfirmDelete="True" EnableCustomizationWindow="True" />
                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="ShowOnStatusBar" />
                                                                <SettingsText CommandDelete="Remove" ConfirmDelete="Are you sure you want to remove this CA from your expense report?" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnViewCA" Text="View">
                                                                                <Image IconID="actions_open2_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
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
                                                                    <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="10">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="12">
                                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                        </PropertiesTextEdit>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
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
                                                                    <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                        <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                        <PropertiesComboBox DataSourceID="SqlEmpName" TextField="FullName" ValueField="EmpCode">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                        <CellStyle HorizontalAlign="Center">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataTextColumn>
                                                                </Columns>
                                                                <Toolbars>
                                                                    <dx:GridViewToolbar Visible="False">
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
                                                                <Styles>
                                                                    <Disabled ForeColor="#222222">
                                                                    </Disabled>
                                                                    <Header>
                                                                        <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                    </Header>
                                                                    <Cell>
                                                                        <Paddings Padding="7px" />
                                                                    </Cell>
                                                                </Styles>
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                        <dx:LayoutGroup Caption="REIMBURSEMENT" ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ReimburseGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlReim" KeyFieldName="ID" Width="100%" Theme="MaterialCompact" OnCustomColumnDisplayText="ExpenseGrid_CustomColumnDisplayText" ClientInstanceName="ReimburseGrid">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                                <SettingsContextMenu Enabled="True">
                                                                </SettingsContextMenu>
                                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                </SettingsAdaptivity>
                                                                <SettingsPager Visible="False">
                                                                </SettingsPager>
                                                                <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="ShowOnStatusBar" />
                                                                <Columns>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Cost Center" FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="IO" FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                        <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepCode" ValueField="ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <PropertiesComboBox DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataSpinEditColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataSpinEditColumn>
                                                                    <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                        <CellStyle HorizontalAlign="Center">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnViewReim" Text="View">
                                                                                <Image IconID="actions_open2_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
                                                                </Columns>
                                                                <Styles>
                                                                    <Header>
                                                                        <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                    </Header>
                                                                    <Cell>
                                                                        <Paddings Padding="7px" />
                                                                    </Cell>
                                                                </Styles>
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Name="caGroup">
                            <Paddings PaddingBottom="25px" />
                            <Items>
                                <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                    <Paddings PaddingBottom="15px" />
                                    <Items>
                                        <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Visible="False" Width="100%">
                                                                <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocumentGrid.Refresh();
}
" />
                                                                <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                </AdvancedModeSettings>
                                                                <Paddings PaddingBottom="10px" />
                                                                <TextBoxStyle Font-Size="Small" />
                                                            </dx:ASPxUploadControl>
                                                            <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" DataSourceID="SqlDocs" KeyFieldName="ID" Width="100%" Theme="MaterialCompact">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                <SettingsPager Mode="ShowAllRecords">
                                                                </SettingsPager>
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="ShowOnStatusBar" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="View">
                                                                                <Image IconID="actions_open2_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                        <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="URL" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="DateUploaded" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="App_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Doc_No" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Doc_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="12">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                </Columns>
                                                                <Styles>
                                                                    <Header>
                                                                        <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                    </Header>
                                                                    <Cell>
                                                                        <Paddings Padding="5px" />
                                                                    </Cell>
                                                                </Styles>
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None">
                            <Items>
                                <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                    <Paddings PaddingBottom="15px" />
                                    <Items>
                                        <dx:LayoutGroup Caption="WORKFLOW ACTIVITY &amp; DETAILS" ColCount="2" ColSpan="1" ColumnCount="2">
                                            <Paddings PaddingBottom="15px" />
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxPanel ID="wfPanel" runat="server" ClientInstanceName="wfPanel" Collapsible="True" Width="100%">
                                                                <ClientSideEvents Collapsed="function(s, e) {
	toggleLabel.SetText('Show');
}" Expanded="function(s, e) {
	toggleLabel.SetText('Hide');
}" />
                                                                <Images>
                                                                    <ExpandButton Width="16px">
                                                                    </ExpandButton>
                                                                    <CollapseButton Width="16px">
                                                                    </CollapseButton>
                                                                </Images>
                                                                <SettingsCollapsing AnimationType="Slide" ExpandEffect="Slide">
                                                                    <ExpandButton Position="Far" />
                                                                </SettingsCollapsing>
                                                                <ExpandBarTemplate>
                                                                    <div style="padding-right: 8px; padding-top: 4px;">
                                                                        <dx:ASPxLabel ID="toggleLabel" runat="server" ClientInstanceName="toggleLabel" Font-Bold="True" Font-Size="Small" Text="Show">
                                                                        </dx:ASPxLabel>
                                                                    </div>
                                                                </ExpandBarTemplate>
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server">
                                                                        <dx:ASPxCallbackPanel ID="wfCallback" runat="server" ClientInstanceName="wfCallback" Width="100%">
                                                                            <SettingsLoadingPanel Enabled="False" />
                                                                            <PanelCollection>
                                                                                <dx:PanelContent runat="server">
                                                                                    <dx:ASPxFormLayout ID="ASPxFormLayout8" runat="server" ColCount="2" ColumnCount="2" Width="100%">
                                                                                        <Items>
                                                                                            <dx:LayoutGroup Caption="WORKFLOW ACTIVITY" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="Box">
                                                                                                <Items>
                                                                                                    <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxGridView ID="WFSequenceGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid0" DataSourceID="SqlWFA" Theme="MaterialCompact" Width="100%">
                                                                                                                    <SettingsPopup>
                                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                                        </FilterControl>
                                                                                                                    </SettingsPopup>
                                                                                                                    <Columns>
                                                                                                                        <dx:GridViewDataTextColumn FieldName="WFA_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0" ReadOnly="True">
                                                                                                                            <EditFormSettings Visible="False" />
                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                        <dx:GridViewDataDateColumn Caption="Date Received" FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                            <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy hh:mm tt" EditFormat="DateTime">
                                                                                                                            </PropertiesDateEdit>
                                                                                                                        </dx:GridViewDataDateColumn>
                                                                                                                        <dx:GridViewDataDateColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                                            <PropertiesDateEdit DisplayFormatString="MMM. dd, yyyy hh:mm tt" EditFormat="DateTime">
                                                                                                                            </PropertiesDateEdit>
                                                                                                                        </dx:GridViewDataDateColumn>
                                                                                                                        <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                        <dx:GridViewDataTextColumn FieldName="Document_Id" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                                                                            <EditFormSettings Visible="False" />
                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                                                                            <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Description" ValueField="STS_Id">
                                                                                                                            </PropertiesComboBox>
                                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                                        <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="ActedBy_User_Id" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                            <PropertiesComboBox DataSourceID="SqlEmpName" TextField="FullName" ValueField="EmpCode">
                                                                                                                            </PropertiesComboBox>
                                                                                                                            <CellStyle Font-Bold="False">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                                    </Columns>
                                                                                                                    <FormatConditions>
                                                                                                                        <dx:GridViewFormatConditionHighlight Expression="[Status] = 7 Or [Status] = 40 Or [Status] = 28" FieldName="Status" Format="Custom">
                                                                                                                            <CellStyle Font-Bold="True" ForeColor="#006838">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewFormatConditionHighlight>
                                                                                                                        <dx:GridViewFormatConditionHighlight Expression="[Status] = 2 Or [Status] = 3 Or [Status] = 15 Or [Status] = 29 Or [Status] = 35 Or [Status] = 37 Or [Status] = 39" FieldName="Status" Format="Custom">
                                                                                                                            <CellStyle Font-Bold="True" ForeColor="#E67C0E">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewFormatConditionHighlight>
                                                                                                                        <dx:GridViewFormatConditionHighlight Expression="[Status] = 8" FieldName="Status" Format="Custom">
                                                                                                                            <CellStyle Font-Bold="True" ForeColor="#CC2A17">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewFormatConditionHighlight>
                                                                                                                        <dx:GridViewFormatConditionHighlight Expression="[Status] = 1 Or [Status] = 30 Or [Status] = 34 Or [Status] = 36 Or [Status] = 38" FieldName="Status" Format="Custom">
                                                                                                                            <CellStyle Font-Bold="True" ForeColor="#006DD6">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewFormatConditionHighlight>
                                                                                                                        <dx:GridViewFormatConditionHighlight Expression="[Status] = 41" FieldName="Status" Format="Custom">
                                                                                                                            <CellStyle Font-Bold="True" ForeColor="#878787">
                                                                                                                            </CellStyle>
                                                                                                                        </dx:GridViewFormatConditionHighlight>
                                                                                                                    </FormatConditions>
                                                                                                                    <Styles>
                                                                                                                        <Header>
                                                                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                                                                        </Header>
                                                                                                                        <Cell>
                                                                                                                            <Paddings Padding="7px" />
                                                                                                                        </Cell>
                                                                                                                    </Styles>
                                                                                                                </dx:ASPxGridView>
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                    </dx:LayoutItem>
                                                                                                </Items>
                                                                                            </dx:LayoutGroup>
                                                                                            <dx:LayoutGroup Caption="LINE MANAGER WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="Box">
                                                                                                <Items>
                                                                                                    <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxComboBox ID="drpdown_WF" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_WF" DataSourceID="SqlWF" Font-Bold="True" Height="39px" SelectedIndex="0" TextField="Name" ValueField="WF_Id" Width="100%">
                                                                                                                    <DropDownButton Visible="False">
                                                                                                                    </DropDownButton>
                                                                                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                                                                        <RequiredField ErrorText="*Required" />
                                                                                                                    </ValidationSettings>
                                                                                                                    <Border BorderStyle="None" />
                                                                                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                                                                    <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                                                                    </DisabledStyle>
                                                                                                                </dx:ASPxComboBox>
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <Paddings PaddingBottom="20px" />
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutGroup Caption="Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                                                                                                        <Items>
                                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                                <LayoutItemNestedControlCollection>
                                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                        <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" Theme="MaterialCompact" Width="100%">
                                                                                                                            <SettingsPopup>
                                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                                </FilterControl>
                                                                                                                            </SettingsPopup>
                                                                                                                            <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                            <Columns>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="OrgRole_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                                    <PropertiesComboBox DataSourceID="SqlUserOrgRole" TextField="FullName" ValueField="OrgRole_Id">
                                                                                                                                    </PropertiesComboBox>
                                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                                            </Columns>
                                                                                                                            <Styles>
                                                                                                                                <Header>
                                                                                                                                    <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                                                                                </Header>
                                                                                                                                <Cell>
                                                                                                                                    <Paddings Padding="7px" />
                                                                                                                                </Cell>
                                                                                                                            </Styles>
                                                                                                                        </dx:ASPxGridView>
                                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                                </LayoutItemNestedControlCollection>
                                                                                                            </dx:LayoutItem>
                                                                                                        </Items>
                                                                                                    </dx:LayoutGroup>
                                                                                                </Items>
                                                                                            </dx:LayoutGroup>
                                                                                            <dx:LayoutGroup Caption="FAP WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="Box">
                                                                                                <Items>
                                                                                                    <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxComboBox ID="drpdown_FAPWF" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_FAPWF" DataSourceID="SqlFAPWF2" Font-Bold="True" Height="39px" SelectedIndex="0" TextField="Name" ValueField="WF_Id" Width="100%">
                                                                                                                    <SettingsLoadingPanel Enabled="False" />
                                                                                                                    <DropDownButton Visible="False">
                                                                                                                    </DropDownButton>
                                                                                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                                                                        <RequiredField ErrorText="*Required" />
                                                                                                                    </ValidationSettings>
                                                                                                                    <Border BorderStyle="None" />
                                                                                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                                                                    <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                                                                                                    </DisabledStyle>
                                                                                                                </dx:ASPxComboBox>
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <Paddings PaddingBottom="20px" />
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutGroup Caption="FAP Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                                                                                                        <Items>
                                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                                <LayoutItemNestedControlCollection>
                                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                        <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" Width="100%" Theme="MaterialCompact">
                                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                            </SettingsEditing>
                                                                                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                                                                            <SettingsPopup>
                                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                                </FilterControl>
                                                                                                                            </SettingsPopup>
                                                                                                                            <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                            <Columns>
                                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                                                    <PropertiesComboBox ValueField="OrgRole_Id" DataSourceID="SqlUserOrgRole" TextField="FullName">
                                                                                                                                    </PropertiesComboBox>
                                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                            </Columns>
                                                                                                                            <Styles>
                                                                                                                                <Header>
                                                                                                                                    <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                                                                                </Header>
                                                                                                                                <Cell>
                                                                                                                                    <Paddings Padding="7px" />
                                                                                                                                </Cell>
                                                                                                                            </Styles>
                                                                                                                        </dx:ASPxGridView>
                                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                                </LayoutItemNestedControlCollection>
                                                                                                            </dx:LayoutItem>
                                                                                                        </Items>
                                                                                                    </dx:LayoutGroup>
                                                                                                </Items>
                                                                                            </dx:LayoutGroup>
                                                                                        </Items>
                                                                                    </dx:ASPxFormLayout>
                                                                                </dx:PanelContent>
                                                                            </PanelCollection>
                                                                        </dx:ASPxCallbackPanel>
                                                                    </dx:PanelContent>
                                                                </PanelCollection>
                                                            </dx:ASPxPanel>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                    <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
                    </ParentContainerStyle>
                </dx:LayoutGroup>
            </Items>
        </dx:ASPxFormLayout>

        <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>

        <%-- ADD EXPENSE POPUP--%>

        <%--ADD REIMBURSEMENT--%>
    </div>

    <dx:ASPxPopupControl ID="travelExpensePopup" runat="server" FooterText="" HeaderText="View Expense Item" ClientInstanceName="travelExpensePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton" CssClass="rounded" ScrollBars="Both" Maximized="True" PopupAnimationType="Fade">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>
                    <dx:ASPxFormLayout ID="ASPxFormLayout13" runat="server" Height="450px" Width="100%">
                        <Items>
                            <dx:LayoutGroup BackColor="WhiteSmoke" Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                                <BorderBottom BorderStyle="Solid" />
                                <Items>
                                    <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Left" Width="1px">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="totalExpTB0" runat="server" ClientEnabled="False" ClientInstanceName="totalExpTB" DisplayFormatString="{0:0,0.00}" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Theme="MaterialCompact" Width="300px">
                                                    <Border BorderStyle="None" />
                                                    <DisabledStyle ForeColor="#333333">
                                                    </DisabledStyle>
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionStyle Font-Bold="True">
                                        </CaptionStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" HorizontalAlign="Right">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="popupCancelBtn0" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Close" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	travelExpensePopup.Hide();
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
                            <dx:LayoutGroup Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="Box" VerticalAlign="Middle" Width="100%">
                                <Paddings PaddingLeft="0px" PaddingRight="0px" />
                                <GroupBoxStyle>
                                    <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Date" ColSpan="1" VerticalAlign="Middle" Width="20%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxDateEdit ID="travelDateCalendar" runat="server" ClientEnabled="False" ClientInstanceName="travelDateCalendar" EditFormat="Custom" EditFormatString="MMMM dd, yyyy" Height="40px" Theme="MaterialCompact" Width="260px">
                                                    <DisabledStyle ForeColor="#333333">
                                                    </DisabledStyle>
                                                </dx:ASPxDateEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings Location="Left" />
                                        <CaptionStyle Font-Bold="True">
                                        </CaptionStyle>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Right" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox7" runat="server" Width="50%">
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <BorderTop BorderStyle="Solid" />
                            </dx:LayoutItem>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Items>
                                    <dx:LayoutGroup Caption="Expense Items" ColCount="5" ColSpan="1" ColumnCount="5" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                        <Paddings PaddingLeft="0px" PaddingRight="0px" />
                                        <Items>
                                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" RowSpan="2" VerticalAlign="Top" Visible="False">
                                                <Items>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="fixedAllowGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="fixedAllowGrid" CssClass="shadow-sm" KeyFieldName="FixedAllow_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="FIXED ALLOWANCE/S" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="F or P" FieldName="FixedAllow_ForP" ShowInCustomizationForm="True" VisibleIndex="3" Width="230px">
                                                                                    <PropertiesComboBox>
                                                                                        <Items>
                                                                                            <dx:ListEditItem Text="Full" Value="F" />
                                                                                            <dx:ListEditItem Text="Partial" Value="P" />
                                                                                        </Items>
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesComboBox>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Center">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="4" Width="350px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="FixedAllow_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="FixedAllow_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="20px" />
                                                    </dx:LayoutItem>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="reimTranGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="reimTranGrid" CssClass="shadow-sm" Font-Italic="False" KeyFieldName="ReimTranspo_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings EnableMultipleCellSelection="True" StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsDataSecurity AllowReadUnlistedFieldsFromClientApi="True" />
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="ReimTranspo_Type" Name="ReimTranspo_Type" ShowInCustomizationForm="True" VisibleIndex="3" Width="230px">
                                                                                    <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                        <Columns>
                                                                                            <dx:ListBoxColumn Caption="Type" FieldName="Type" Name="Type" Width="50px">
                                                                                            </dx:ListBoxColumn>
                                                                                            <dx:ListBoxColumn Caption="Description" FieldName="Description" Name="Description" Width="180px">
                                                                                            </dx:ListBoxColumn>
                                                                                        </Columns>
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesComboBox>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Center">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="ReimTranspo_Amount" Name="ReimTranspo_Amount" ShowInCustomizationForm="True" VisibleIndex="4" Width="350px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="ReimTranspo_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Table>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Table>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="20px" />
                                                    </dx:LayoutItem>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="otherBusGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="otherBusGrid" CssClass="shadow-sm" KeyFieldName="OtherBusinessExp_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="OTHER BUSINESS EXPENSE/S" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="OtherBusinessExp_Type" ShowInCustomizationForm="True" VisibleIndex="2" Width="350px">
                                                                                    <PropertiesComboBox ClientInstanceName="otherBusType" DataSourceID="SqlOtherBusExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                        <Columns>
                                                                                            <dx:ListBoxColumn Caption="Type" FieldName="Type" Name="Type" Width="50px">
                                                                                            </dx:ListBoxColumn>
                                                                                            <dx:ListBoxColumn Caption="Description" FieldName="Description" Name="Description" Width="180px">
                                                                                            </dx:ListBoxColumn>
                                                                                        </Columns>
                                                                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetValue(); // Get the selected value from ComboBox 
               if (selectedValue == 5) { 
                        OtherBusinessExpSpecify.SetVisible(true);
                        //otherBusExpPopup.Show();
               }else{
                        OtherBusinessExpSpecify.SetVisible(false);
               }
}" />
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesComboBox>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Center">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="OtherBusinessExp_Amount" ShowInCustomizationForm="True" VisibleIndex="4" Width="230px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="OtherBusinessExp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="If Others, specify:" FieldName="OtherBusinessExp_Specify" ShowInCustomizationForm="True" VisibleIndex="3" Width="350px">
                                                                                    <PropertiesTextEdit ClientInstanceName="OtherBusinessExpSpecify">
                                                                                        <ClientSideEvents Init="function(s, e) {
	OtherBusinessExpSpecify.SetVisible(false);
}" />
                                                                                    </PropertiesTextEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Left">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="OtherBusinessExp_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="20px" />
                                                    </dx:LayoutItem>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="miscTravelGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="miscTravelGrid" CssClass="shadow-sm" KeyFieldName="MiscTravelExp_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="MISCELLANEOUS TRAVEL EXPENSE/S" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravelExp_Type" ShowInCustomizationForm="True" VisibleIndex="2" Width="350px">
                                                                                    <PropertiesComboBox ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                        <Columns>
                                                                                            <dx:ListBoxColumn Caption="Type" FieldName="Type" Name="Type" Width="50px">
                                                                                            </dx:ListBoxColumn>
                                                                                            <dx:ListBoxColumn Caption="Description" FieldName="Description" Name="Description" Width="270px">
                                                                                            </dx:ListBoxColumn>
                                                                                        </Columns>
                                                                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetValue(); // Get the selected value from ComboBox 
               if (selectedValue == 5) { 
                      MiscTravelExpSpecify.SetVisible(true);  
                      //miscTravelExpPopup.Show();
               }else{
                      MiscTravelExpSpecify.SetVisible(false);  
               }
}" />
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesComboBox>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Center">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MiscTravelExp_Amount" ShowInCustomizationForm="True" VisibleIndex="4" Width="230px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="MiscTravelExp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="If Others, specify:" FieldName="MiscTravelExp_Specify" ShowInCustomizationForm="True" VisibleIndex="3" Width="350px">
                                                                                    <PropertiesTextEdit ClientInstanceName="MiscTravelExpSpecify">
                                                                                        <ClientSideEvents Init="function(s, e) {
	MiscTravelExpSpecify.SetVisible(false);
}" />
                                                                                    </PropertiesTextEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Left">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="MiscTravelExp_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="20px" />
                                                    </dx:LayoutItem>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="busMealsGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="busMealsGrid" CssClass="shadow-sm" KeyFieldName="BusinessMeal_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="BUSINESS MEAL/S" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="BusinessMeal_Amount" ShowInCustomizationForm="True" VisibleIndex="3" Width="230px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="BusinessMeal_Explain" ShowInCustomizationForm="True" VisibleIndex="2" Width="350px">
                                                                                    <PropertiesMemoEdit>
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesMemoEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Justify">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataMemoColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="BusinessMeal_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="BusinessMeal_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="10px" />
                                                    </dx:LayoutItem>
                                                    <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="entertainmentGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="entertainmentGrid" CssClass="shadow-sm" KeyFieldName="Entertainment_ID">
                                                                    <ClientSideEvents EndCallback="calcExpenses" />
                                                                    <SettingsPager Visible="False">
                                                                    </SettingsPager>
                                                                    <SettingsEditing Mode="Inline">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsCommandButton>
                                                                        <NewButton>
                                                                            <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                </Style>
                                                                            </Styles>
                                                                        </NewButton>
                                                                        <UpdateButton Text="Save">
                                                                        </UpdateButton>
                                                                        <DeleteButton Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                </Style>
                                                                            </Styles>
                                                                        </DeleteButton>
                                                                    </SettingsCommandButton>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewBandColumn Caption="ENTERTAINMENT/S" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="150px">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="Entertainment_Explain" ShowInCustomizationForm="True" VisibleIndex="2" Width="350px">
                                                                                    <PropertiesMemoEdit>
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesMemoEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Justify">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataMemoColumn>
                                                                                <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="Entertainment_Amount" ShowInCustomizationForm="True" VisibleIndex="3" Width="230px">
                                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                        </ValidationSettings>
                                                                                    </PropertiesSpinEdit>
                                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                                    <CellStyle HorizontalAlign="Right">
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataSpinEditColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Entertainment_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                    </Columns>
                                                                    <TotalSummary>
                                                                        <dx:ASPxSummaryItem FieldName="Entertainment_Amount" SummaryType="Sum" />
                                                                    </TotalSummary>
                                                                    <Styles>
                                                                        <Header>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Header>
                                                                        <Cell>
                                                                            <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                        </Cell>
                                                                    </Styles>
                                                                    <Border BorderColor="#006838" />
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                        <Paddings PaddingBottom="10px" />
                                                    </dx:LayoutItem>
                                                </Items>
                                            </dx:LayoutGroup>
                                            <dx:LayoutItem Caption="" ColSpan="5" ColumnSpan="5" RowSpan="2" VerticalAlign="Top" Width="100%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="ASPxGridView22" runat="server" AutoGenerateColumns="False" ClientInstanceName="ASPxGridView22" EnableTheming="True" Font-Size="Small" KeyFieldName="TravelExpenseDetailMap_ID" OnCustomCallback="ASPxGridView22_CustomCallback" OnCustomColumnDisplayText="ASPxGridView22_CustomColumnDisplayText" Theme="MaterialCompact" Width="100%">
                                                            <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                            </SettingsAdaptivity>
                                                            <SettingsPager Mode="ShowAllRecords">
                                                            </SettingsPager>
                                                            <SettingsEditing Mode="Batch">
                                                                <BatchEditSettings StartEditAction="Click" />
                                                            </SettingsEditing>
                                                            <SettingsBehavior AllowDragDrop="False" />
                                                            <SettingsCommandButton>
                                                                <NewButton>
                                                                    <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style Font-Bold="False" ForeColor="#006838">
                                                                        </Style>
                                                                    </Styles>
                                                                </NewButton>
                                                                <EditButton>
                                                                    <Styles>
                                                                        <Style Font-Bold="True" ForeColor="#E67C0E">
                                                                        </Style>
                                                                    </Styles>
                                                                </EditButton>
                                                                <DeleteButton Text="Remove">
                                                                    <Styles>
                                                                        <Style Font-Bold="False" ForeColor="#CC2A17">
                                                                        </Style>
                                                                    </Styles>
                                                                </DeleteButton>
                                                            </SettingsCommandButton>
                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewCommandColumn Caption=" " ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                    <CellStyle>
                                                                        <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                        <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                    </CellStyle>
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewBandColumn Caption="FIXED ALLOWANCES" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                    <Columns>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="3" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="F or P" FieldName="FixedAllow_ForP" ShowInCustomizationForm="True" VisibleIndex="2" Width="110px">
                                                                            <PropertiesComboBox>
                                                                                <Items>
                                                                                    <dx:ListEditItem Text="Full" Value="F" />
                                                                                    <dx:ListEditItem Text="Partial" Value="P" />
                                                                                </Items>
                                                                            </PropertiesComboBox>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn Caption="Remarks" FieldName="FixedAllow_Remarks" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                    <Columns>
                                                                        <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="3" FieldName="ReimTranspo_Type1" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                            <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                            </PropertiesComboBox>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderLeft BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption=" Amount" CellRowSpan="3" FieldName="ReimTranspo_Amount1" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="  Type" FieldName="ReimTranspo_Type2" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" Width="140px">
                                                                            <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                            </PropertiesComboBox>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption=" Amount" FieldName="ReimTranspo_Amount2" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="2" FieldName="ReimTranspo_Type3" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4" Width="140px">
                                                                            <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                            </PropertiesComboBox>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" CellRowSpan="2" FieldName="ReimTranspo_Amount3" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <EditFormCaptionStyle HorizontalAlign="Center">
                                                                            </EditFormCaptionStyle>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewBandColumn Caption="ENTERTAINMENT" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                    <Columns>
                                                                        <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="Entertainment_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataMemoColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="Entertainment_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewBandColumn Caption="BUSINESS MEALS" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                    <Columns>
                                                                        <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="BusMeals_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataMemoColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="BusMeals_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewBandColumn Caption="OTHER BUS. EXPENSES" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                    <Columns>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="OtherBus_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                            <PropertiesComboBox ClientInstanceName="otherBusType" DataSourceID="SqlOtherBusExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetValue(); // Get the selected value from ComboBox 
               if (selectedValue == 5) { 
                        OtherBusinessExpSpecify.SetVisible(true);
                        //otherBusExpPopup.Show();
               }else{
                        OtherBusinessExpSpecify.SetVisible(false);
               }
}
" />
                                                                            </PropertiesComboBox>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                            <Columns>
                                                                                <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="OtherBus_Specify" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                    <PropertiesMemoEdit ClientInstanceName="OtherBusinessExpSpecify">
                                                                                        <ClientSideEvents Init="function(s, e) {
	OtherBusinessExpSpecify.SetVisible(false);
}
" />
                                                                                    </PropertiesMemoEdit>
                                                                                    <HeaderStyle>
                                                                                    <Border BorderStyle="Solid" />
                                                                                    </HeaderStyle>
                                                                                    <CellStyle>
                                                                                        <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                    </CellStyle>
                                                                                </dx:GridViewDataMemoColumn>
                                                                            </Columns>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="OtherBus_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewBandColumn Caption="MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                    <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                    <Columns>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravel_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                            <PropertiesComboBox ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="240px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetText(); // Get the selected value from ComboBox 
               if (selectedValue.includes(&quot;Others&quot;)) { 
                      MiscTravelExpSpecify.SetVisible(true);  
                      //miscTravelExpPopup.Show();
               }else{
                      MiscTravelExpSpecify.SetVisible(false);  
               }
}
" />
                                                                            </PropertiesComboBox>
                                                                            <HeaderStyle HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <Columns>
                                                                                <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="MiscTravel_Specify" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                    <PropertiesMemoEdit ClientInstanceName="MiscTravelExpSpecify">
                                                                                        <ClientSideEvents Init="function(s, e) {
	MiscTravelExpSpecify.SetVisible(false);
}
" />
                                                                                    </PropertiesMemoEdit>
                                                                                    <HeaderStyle>
                                                                                    <Border BorderStyle="Solid" />
                                                                                    </HeaderStyle>
                                                                                </dx:GridViewDataMemoColumn>
                                                                            </Columns>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MiscTravel_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                            <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                            </PropertiesSpinEdit>
                                                                            <HeaderStyle Font-Bold="False" HorizontalAlign="Center">
                                                                            <Border BorderStyle="Solid" />
                                                                            </HeaderStyle>
                                                                            <CellStyle>
                                                                                <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                            </CellStyle>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                    </Columns>
                                                                </dx:GridViewBandColumn>
                                                                <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                    <CellStyle HorizontalAlign="Center">
                                                                        <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                        <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                    </CellStyle>
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="LOCATION/PARTICULARS" FieldName="LocParticulars" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <CellStyle>
                                                                        <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                        <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                    </CellStyle>
                                                                </dx:GridViewDataTextColumn>
                                                            </Columns>
                                                            <TotalSummary>
                                                                <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount1" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount2" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount3" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="FixedAllow_Amount" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="MiscTravel_Amount" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="Entertainment_Amount" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="BusMeals_Amount" SummaryType="Sum" />
                                                                <dx:ASPxSummaryItem FieldName="OtherBus_Amount" SummaryType="Sum" />
                                                            </TotalSummary>
                                                            <Styles>
                                                                <Header>
                                                                    <Paddings PaddingBottom="2px" PaddingTop="2px" />
                                                                </Header>
                                                                <AlternatingRow BackColor="#ECECEC">
                                                                </AlternatingRow>
                                                            </Styles>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" Visible="False">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxPageControl ID="ASPxPageControl3" runat="server" ActiveTabIndex="2">
                                                            <TabPages>
                                                                <dx:TabPage Text="REIMBURSABLE TRANSPORTATION">
                                                                    <ContentCollection>
                                                                        <dx:ContentControl runat="server">
                                                                            <dx:ASPxGridView ID="ASPxGridView23" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                <SettingsPager Visible="False">
                                                                                </SettingsPager>
                                                                                <SettingsEditing Mode="Batch">
                                                                                    <BatchEditSettings StartEditAction="Click" />
                                                                                </SettingsEditing>
                                                                                <SettingsPopup>
                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                    </FilterControl>
                                                                                </SettingsPopup>
                                                                                <Columns>
                                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                    </dx:GridViewCommandColumn>
                                                                                    <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                    </dx:GridViewDataTextColumn>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                </Columns>
                                                                                <Styles>
                                                                                    <Header>
                                                                                        <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                    </Header>
                                                                                    <Cell>
                                                                                        <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                    </Cell>
                                                                                </Styles>
                                                                            </dx:ASPxGridView>
                                                                        </dx:ContentControl>
                                                                    </ContentCollection>
                                                                </dx:TabPage>
                                                                <dx:TabPage Text="FIXED ALLOW. &amp; MISC. TRAVEL EXPENSES">
                                                                    <ContentCollection>
                                                                        <dx:ContentControl runat="server">
                                                                            <dx:ASPxFormLayout ID="ASPxFormLayout9" runat="server" ColCount="2" ColumnCount="2" Width="100%">
                                                                                <Items>
                                                                                    <dx:LayoutGroup Caption="Fixed Allowance" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                                                                        <Items>
                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                <LayoutItemNestedControlCollection>
                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                        <dx:ASPxGridView ID="ASPxGridView24" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                            <SettingsPager Visible="False">
                                                                                                            </SettingsPager>
                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                <BatchEditSettings StartEditAction="Click" />
                                                                                                            </SettingsEditing>
                                                                                                            <SettingsPopup>
                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                </FilterControl>
                                                                                                            </SettingsPopup>
                                                                                                            <Columns>
                                                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                </dx:GridViewCommandColumn>
                                                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                            </Columns>
                                                                                                            <Styles>
                                                                                                                <Header>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Header>
                                                                                                                <Cell>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Cell>
                                                                                                            </Styles>
                                                                                                        </dx:ASPxGridView>
                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                </LayoutItemNestedControlCollection>
                                                                                            </dx:LayoutItem>
                                                                                        </Items>
                                                                                    </dx:LayoutGroup>
                                                                                    <dx:LayoutGroup Caption="Misc. Travel Expense" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                                                                        <Items>
                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                <LayoutItemNestedControlCollection>
                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                        <dx:ASPxGridView ID="ASPxGridView25" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                            <SettingsPager Visible="False">
                                                                                                            </SettingsPager>
                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                <BatchEditSettings StartEditAction="Click" />
                                                                                                            </SettingsEditing>
                                                                                                            <SettingsPopup>
                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                </FilterControl>
                                                                                                            </SettingsPopup>
                                                                                                            <Columns>
                                                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                </dx:GridViewCommandColumn>
                                                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                            </Columns>
                                                                                                            <Styles>
                                                                                                                <Header>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Header>
                                                                                                                <Cell>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Cell>
                                                                                                            </Styles>
                                                                                                        </dx:ASPxGridView>
                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                </LayoutItemNestedControlCollection>
                                                                                            </dx:LayoutItem>
                                                                                        </Items>
                                                                                    </dx:LayoutGroup>
                                                                                </Items>
                                                                            </dx:ASPxFormLayout>
                                                                        </dx:ContentControl>
                                                                    </ContentCollection>
                                                                </dx:TabPage>
                                                                <dx:TabPage Text="OTHER BUSINESS EXPENSES">
                                                                    <ContentCollection>
                                                                        <dx:ContentControl runat="server">
                                                                            <dx:ASPxFormLayout ID="ASPxFormLayout10" runat="server" ColCount="2" ColumnCount="2" Width="100%">
                                                                                <Items>
                                                                                    <dx:LayoutGroup Caption="Entertainment" ColSpan="1">
                                                                                        <Items>
                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                <LayoutItemNestedControlCollection>
                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                        <dx:ASPxGridView ID="ASPxGridView26" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                            <SettingsPager Visible="False">
                                                                                                            </SettingsPager>
                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                <BatchEditSettings StartEditAction="Click" />
                                                                                                            </SettingsEditing>
                                                                                                            <SettingsPopup>
                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                </FilterControl>
                                                                                                            </SettingsPopup>
                                                                                                            <Columns>
                                                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                </dx:GridViewCommandColumn>
                                                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Explanation" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                            </Columns>
                                                                                                            <Styles>
                                                                                                                <Header>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Header>
                                                                                                                <Cell>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Cell>
                                                                                                            </Styles>
                                                                                                        </dx:ASPxGridView>
                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                </LayoutItemNestedControlCollection>
                                                                                            </dx:LayoutItem>
                                                                                        </Items>
                                                                                    </dx:LayoutGroup>
                                                                                    <dx:LayoutGroup Caption="Business Meals" ColSpan="1">
                                                                                        <Items>
                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                <LayoutItemNestedControlCollection>
                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                        <dx:ASPxGridView ID="ASPxGridView27" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                            <SettingsPager Visible="False">
                                                                                                            </SettingsPager>
                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                <BatchEditSettings StartEditAction="Click" />
                                                                                                            </SettingsEditing>
                                                                                                            <SettingsPopup>
                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                </FilterControl>
                                                                                                            </SettingsPopup>
                                                                                                            <Columns>
                                                                                                                <dx:GridViewCommandColumn Caption="Explanation" ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                </dx:GridViewCommandColumn>
                                                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                            </Columns>
                                                                                                            <Styles>
                                                                                                                <Header>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Header>
                                                                                                                <Cell>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Cell>
                                                                                                            </Styles>
                                                                                                        </dx:ASPxGridView>
                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                </LayoutItemNestedControlCollection>
                                                                                            </dx:LayoutItem>
                                                                                        </Items>
                                                                                    </dx:LayoutGroup>
                                                                                    <dx:LayoutGroup Caption="Other Business Expense" ColSpan="2" ColumnSpan="2">
                                                                                        <Items>
                                                                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                <LayoutItemNestedControlCollection>
                                                                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                        <dx:ASPxGridView ID="ASPxGridView28" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                                                            <SettingsPager Visible="False">
                                                                                                            </SettingsPager>
                                                                                                            <SettingsEditing Mode="Batch">
                                                                                                                <BatchEditSettings StartEditAction="Click" />
                                                                                                            </SettingsEditing>
                                                                                                            <SettingsPopup>
                                                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                                                </FilterControl>
                                                                                                            </SettingsPopup>
                                                                                                            <Columns>
                                                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                </dx:GridViewCommandColumn>
                                                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                            </Columns>
                                                                                                            <Styles>
                                                                                                                <Header>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Header>
                                                                                                                <Cell>
                                                                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                                                                </Cell>
                                                                                                            </Styles>
                                                                                                        </dx:ASPxGridView>
                                                                                                    </dx:LayoutItemNestedControlContainer>
                                                                                                </LayoutItemNestedControlCollection>
                                                                                            </dx:LayoutItem>
                                                                                        </Items>
                                                                                    </dx:LayoutGroup>
                                                                                </Items>
                                                                            </dx:ASPxFormLayout>
                                                                        </dx:ContentControl>
                                                                    </ContentCollection>
                                                                </dx:TabPage>
                                                            </TabPages>
                                                        </dx:ASPxPageControl>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Visible="False">
                                                <Items>
                                                    <dx:LayoutItem Caption="" ColSpan="1">
                                                        <LayoutItemNestedControlCollection>
                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                <dx:ASPxGridView ID="ASPxGridView29" runat="server" AutoGenerateColumns="False" Width="100%">
                                                                    <SettingsEditing Mode="Batch">
                                                                        <BatchEditSettings StartEditAction="Click" />
                                                                    </SettingsEditing>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn Caption="Date" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="ENTERTAINMENT" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn Caption="BUSINESS MEALS" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                        <dx:GridViewBandColumn Caption="FIXED ALLOW. &amp; MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                            <Columns>
                                                                                <dx:GridViewBandColumn Caption="Fixed Allowance" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                    <Columns>
                                                                                        <dx:GridViewDataTextColumn Caption="F or P" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                        </dx:GridViewDataTextColumn>
                                                                                        <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                        </dx:GridViewDataTextColumn>
                                                                                    </Columns>
                                                                                </dx:GridViewBandColumn>
                                                                                <dx:GridViewBandColumn Caption="Misc. Travel Expense" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                    <Columns>
                                                                                        <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                        </dx:GridViewDataTextColumn>
                                                                                        <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                        </dx:GridViewDataTextColumn>
                                                                                    </Columns>
                                                                                </dx:GridViewBandColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                        <dx:GridViewBandColumn Caption="OTHER BUS. EXPENSES" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                            <Columns>
                                                                                <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                </dx:GridViewDataTextColumn>
                                                                            </Columns>
                                                                        </dx:GridViewBandColumn>
                                                                        <dx:GridViewDataTextColumn Caption="LOCATION/PARTICULARS" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:LayoutItemNestedControlContainer>
                                                        </LayoutItemNestedControlCollection>
                                                    </dx:LayoutItem>
                                                </Items>
                                            </dx:LayoutGroup>
                                        </Items>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Paddings PaddingTop="20px" />
                                <Items>
                                    <dx:LayoutGroup Caption="Supporting Documents" ColSpan="1" Width="100%">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxUploadControl ID="TraUploadController" runat="server" AutoStartUpload="True" ClientInstanceName="TraUploadController" Font-Size="Small" ShowProgressPanel="True" UploadMode="Auto" Visible="False" Width="100%">
                                                            <ClientSideEvents FilesUploadComplete="function(s, e) {
	TraDocuGrid.Refresh();
}
" />
                                                            <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                            </AdvancedModeSettings>
                                                            <Paddings PaddingBottom="10px" />
                                                            <TextBoxStyle Font-Size="Small" />
                                                        </dx:ASPxUploadControl>
                                                        <dx:ASPxGridView ID="TraDocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="TraDocuGrid" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%" DataSourceID="SqlDocs2">
                                                            <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                            <SettingsCommandButton>
                                                                <EditButton>
                                                                    <Image IconID="richedit_trackingchanges_trackchanges_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </EditButton>
                                                                <DeleteButton Text="Remove">
                                                                    <Image IconID="iconbuilder_actions_removecircled_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#CC2A17" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </DeleteButton>
                                                            </SettingsCommandButton>
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                    <CustomButtons>
                                                                        <dx:GridViewCommandColumnCustomButton ID="btnTraDownload" Text="View">
                                                                            <Image IconID="actions_open2_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style ForeColor="#006838">
                                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                                </Style>
                                                                            </Styles>
                                                                        </dx:GridViewCommandColumnCustomButton>
                                                                    </CustomButtons>
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                            </Columns>
                                                            <Styles>
                                                                <Header>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                </Header>
                                                                <Cell>
                                                                    <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                </Cell>
                                                            </Styles>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="True">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                        </Items>
                        <Paddings PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxPopupControl ID="rfpPopup" runat="server" Modal="True" ClientInstanceName="rfpPopup" PopupAnimationType="Fade" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" HeaderText="Request For Payment (View)" Width="95%">
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="formRFP" runat="server" ClientInstanceName="formRFP" ColCount="2" ColumnCount="2" Theme="Default" Width="1100px" EnableTheming="True">
        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit" SwitchToSingleColumnAtWindowInnerWidth="900">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="None" Name="PageTitle" Width="100%">
                <GroupBoxStyle>
                    <Caption BackColor="#FEFEFE" Font-Size="X-Large">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="Document No." ColSpan="1" VerticalAlign="Middle">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="rfpDocNo" runat="server" ClientInstanceName="rfpDocNo" Width="50%" ClientEnabled="False" Font-Bold="True">
                                    <Border BorderStyle="None" />
                                    <BorderLeft BorderStyle="None" />
                                    <BorderTop BorderStyle="None" />
                                    <BorderRight BorderStyle="None" />
                                    <BorderBottom BorderStyle="None" />
                                    <DisabledStyle Font-Bold="True" ForeColor="Black">
                                    </DisabledStyle>
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Amount" ColSpan="1" HorizontalAlign="Right" VerticalAlign="Middle" Width="0px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxTextBox ID="rfpAmount" runat="server" ClientEnabled="False" ClientInstanceName="rfpAmount" DisplayFormatString="#,##0.00" Font-Bold="True" HorizontalAlign="Right" Width="120px">
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                    <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                    </DisabledStyle>
                                </dx:ASPxTextBox>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Right" VerticalAlign="Middle" />
                    </dx:LayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%" RowSpan="2">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="rfpCompany" runat="server" ClientInstanceName="rfpCompany" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId" Width="100%" ClientEnabled="False" Font-Bold="True">
                                            <DropDownButton Visible="False">
                                            </DropDownButton>
                                            <Border BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="rfpPayMethod" runat="server" ClientInstanceName="rfpPayMethod" DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID" Width="100%" Font-Bold="True" ClientEnabled="False">
                                            <DropDownButton Visible="False">
                                            </DropDownButton>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                            <DisabledStyle ForeColor="Black">
                                            </DisabledStyle>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Projected Liquidation Date" ColSpan="1" Name="PLD" ShowCaption="True" Visible="False" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="PLD_lbl" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Type of Transaction" ColSpan="1" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="rfpTypeTransact" runat="server" ClientInstanceName="rfpTypeTransact" DataSourceID="SqlTranType" TextField="Description" ValueField="ExpenseType_ID" Width="100%" ClientEnabled="False" Font-Bold="True">
                                            <DropDownButton Visible="False">
                                            </DropDownButton>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Expense Type" ColSpan="1" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxRadioButton ID="rdButton_Trav" runat="server" ClientInstanceName="rdButton_Trav" CssClass="d-inline me-3" Font-Bold="True" ReadOnly="True" RightToLeft="False" Text="Travel" Theme="Moderno">
                                            <RadioButtonFocusedStyle Wrap="True">
                                            </RadioButtonFocusedStyle>
                                            <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_NonTrav.SetValue(false);
onTravelClick();
}" />
                                        </dx:ASPxRadioButton>
                                        <dx:ASPxRadioButton ID="rdButton_NonTrav" runat="server" Checked="True" ClientInstanceName="rdButton_NonTrav" CssClass="d-inline" Font-Bold="True" ReadOnly="True" Text="Non-Travel" Theme="Moderno">
                                            <RadioButtonStyle Font-Size="Smaller" Wrap="True">
                                            </RadioButtonStyle>
                                            <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_Trav.SetValue(false);
onTravelClick();
}" />
                                        </dx:ASPxRadioButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Last day of transaction" ColSpan="1" Name="LDOT" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpLastDayTransact" runat="server" ClientInstanceName="rfpLastDayTransact" Font-Bold="True" Width="100%" ClientEnabled="False">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="None" BorderWidth="1px" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                                <CaptionStyle Font-Italic="False" Font-Size="Small">
                                </CaptionStyle>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ColSpan="1" FieldName="WBS" Name="WBS" Visible="False" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox12" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="1" Width="100%" VerticalAlign="Middle">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="rfpPurpose" runat="server" ClientInstanceName="rfpPurpose" Font-Bold="True" Width="100%" ClientEnabled="False">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Charged To" ColSpan="1" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpChargeTo" runat="server" ClientInstanceName="rfpChargeTo" Width="100%" ClientEnabled="False" Font-Bold="True">
                                            <Border BorderStyle="None" />
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="Black">
                                            </DisabledStyle>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                        </Items>
                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem Caption="SAP Document No." ColSpan="1" Name="lbl_SAPDoc" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpSAPDoc" runat="server" ClientInstanceName="rfpSAPDoc" Font-Bold="True" Width="100%" ClientEnabled="False">
                                            <Border BorderStyle="None" />
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="Black">
                                            </DisabledStyle>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Department" ColSpan="1" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="rfpDepartment" runat="server" ClientInstanceName="rfpDepartment" DataSourceID="SqlDepartment" TextField="DepCode" ValueField="ID" Width="100%" ClientEnabled="False" Font-Bold="True">
                                            <DropDownButton Visible="False">
                                            </DropDownButton>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpCostCenter" runat="server" ClientInstanceName="rfpCostCenter" Font-Bold="True" Width="100%" ClientEnabled="False">
                                            <Border BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ColSpan="1" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpIO" runat="server" ClientInstanceName="rfpIO" Font-Bold="True" Width="100%" ClientEnabled="False">
                                            <Border BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ColSpan="1" FieldName="AcctChargeName" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="rfpAccountCharged" runat="server" Font-Bold="True" Width="100%" ClientEnabled="False" ClientInstanceName="rfpAccountCharged">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderStyle="None" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" Name="Payee" VerticalAlign="Middle" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="rfpPayee" runat="server" ClientInstanceName="rfpPayee" DataSourceID="SqlEmpName" TextField="FullName" ValueField="EmpCode" Width="100%" ClientEnabled="False" Font-Bold="True">
                                            <DropDownButton Visible="False">
                                            </DropDownButton>
                                            <Border BorderStyle="None" />
                                            <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                            </DisabledStyle>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" VerticalAlign="Middle" />
                            </dx:LayoutItem>
                        </Items>
                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Supporting Documents" ColSpan="1" Visible="False" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Name="uploader_cashier">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxUploadControl ID="UploadController0" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                            <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocuGrid.Refresh();
}
" />
                                            <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                            </AdvancedModeSettings>
                                        </dx:ASPxUploadControl>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" KeyFieldName="ID">
                                            <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="1">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile" Text="Open File">
                                                            <Image IconID="pdfviewer_next_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnRemove" Text="Remove">
                                                            <Image IconID="iconbuilder_actions_trash_svg_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style ForeColor="Red">
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="File Name" FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Description" FieldName="FileDesc" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Orig_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="isExist" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="File Ext" FieldName="FileExt" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileByte" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Workflow" ColCount="3" ColSpan="2" ColumnCount="3" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Visible="False" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="WFbtnToggle" runat="server" AutoPostBack="False" ClientInstanceName="WFbtnToggle" HorizontalAlign="Left" RenderMode="Link" Text="Show">
                                            <ClientSideEvents Click="function(s, e) {
	isToggleWF();
}" />
                                            <Image IconID="outlookinspired_expandcollapse_svg_32x32">
                                            </Image>
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutGroup Caption="" ClientVisible="False" ColCount="2" ColSpan="1" ColumnCount="2" Name="WFLayout" Width="100%">
                                <Items>
                                    <dx:LayoutGroup Caption="Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <GroupBoxStyle>
                                            <Caption Font-Bold="True">
                                            </Caption>
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="Name">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox14" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="WFSequenceGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" Width="100%">
                                                            <SettingsEditing Mode="Batch">
                                                            </SettingsEditing>
                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <PropertiesComboBox TextFormatString="{0}" ValueField="TerritoryID">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Territory" FieldName="TerritoryDescription">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn Caption="Region" FieldName="RegionID">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="FAPWorkflow">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox15" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workfow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="FAPWFGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" Width="100%">
                                                            <SettingsEditing Mode="Batch">
                                                            </SettingsEditing>
                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <PropertiesComboBox TextFormatString="{0}" ValueField="TerritoryID">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Territory" FieldName="TerritoryDescription">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn Caption="Region" FieldName="RegionID">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Workflow Activity" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Visible="False" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="WFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFActivityGrid" DataSourceID="SqlActivity" Width="100%">
                                            <SettingsEditing Mode="Batch">
                                            </SettingsEditing>
                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    <PropertiesComboBox DataSourceID="SqlWorkflow" TextField="Description" ValueField="WF_Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Org Role" FieldName="OrgRole_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                                                    <PropertiesComboBox DataSourceID="SqlOrgRole" TextField="Role_Name" ValueField="Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="ActedBy_User_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                    <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxHyperLink ID="formRFP_E1" runat="server" Text="See Full Details..." Width="100px">
                                    <ClientSideEvents Click="function(s, e) {
	LoadingPanel.Show();
               var rfpDoc = rfpDocNo.GetText();
	linkToRFP(rfpDoc);
}" />
                                </dx:ASPxHyperLink>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
                <SettingsItemCaptions HorizontalAlign="Right" />
            </dx:LayoutGroup>
        </Items>
        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
        <BackgroundImage HorizontalPosition="center" Repeat="NoRepeat" />
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="RecallPopup" runat="server" HeaderText="Recall Expense Report" Modal="True" AutoUpdatePosition="True" ClientInstanceName="RecallPopup" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None">
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout14" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxImage ID="ASPxFormLayout1_E5" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                                        </dx:ASPxImage>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                                </TabImage>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxLabel ID="ASPxFormLayout1_E6" runat="server" Text="Are you sure to recall document?" Font-Size="Medium">
                                        </dx:ASPxLabel>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="recallRemarks" runat="server" ClientInstanceName="recallRemarks" Height="71px" NullText="Remarks (Required)" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="recallValid">
                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="recallPopBtn" runat="server" Text="Recall" BackColor="#E67C0E" ClientInstanceName="recallPopBtn" AutoPostBack="False" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
               if(ASPxClientEdit.ValidateGroup('recallValid')){
	          RecallDoc();
               }
}" />
                                                    <Border BorderColor="#E67C0E" />
                                                </dx:ASPxButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="ASPxFormLayout1_E7" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
               returnRemarks.SetText('');
	ReturnPopup.Hide();
}" />
                                                    <Border BorderColor="Gray" />
                                                </dx:ASPxButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                        <SettingsItems HorizontalAlign="Center" />
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>

    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" ClientInstanceName="loadPanel" Modal="True" Theme="MaterialCompact">
    </dx:ASPxLoadingPanel>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseMain] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlEmpName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflowSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowDetails] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowDetails] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlExpenseCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([Exp_ID] = @Exp_ID) AND ([TranType] = 1)  AND ([isTravel] = 1)) ">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
            <asp:SessionParameter DefaultValue="" Name="Exp_ID" SessionField="TravelExp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([User_ID] = @User_ID) AND ([IsExpenseCA] = @IsExpenseCA) AND ([TranType] = @TranType) AND ([Status] = @Status) AND ([Exp_ID] IS NULL) AND ([isTravel] = 1))">
        <SelectParameters>
            <asp:SessionParameter Name="User_ID" SessionField="userID" Type="String" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" />
            <asp:Parameter DefaultValue="1" Name="TranType" />
            <asp:Parameter DefaultValue="7" Name="Status" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReim" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([TranType] = @TranType) AND ([Exp_ID] = @Exp_ID) AND ([isTravel] = 1) AND ([Status] != 4))">
        <SelectParameters>
            <asp:Parameter DefaultValue="2" Name="TranType" Type="Int32" />
            <asp:SessionParameter DefaultValue="TravelExp_Id" Name="Exp_ID" SessionField="TravelExp_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPMainReim" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseReim] = @IsExpenseReim) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([DepCode] IS NOT NULL)">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseDetails] WHERE ([TravelExpenseMain_ID] = @TravelExpenseMain_ID) ORDER BY [TravelExpenseDetail_Date] ASC">
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseMain_ID" SessionField="TravelExp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetailsMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE ([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID" InsertCommand="INSERT INTO [ACCEDE_T_TravelExpenseDetailsMap] ([TravelExpenseDetail_ID], [ReimTranspo_Type1], [ReimTranspo_Amount1], [ReimTranspo_Type2], [ReimTranspo_Amount2], [ReimTranspo_Type3], [ReimTranspo_Amount3], [FixedAllow_ForP], [FixedAllow_Amount], [MiscTravel_Type], [MiscTravel_Specify], [MiscTravel_Amount], [Entertainment_Explain], [Entertainment_Amount], [BusMeals_Explain], [BusMeals_Amount], [OtherBus_Type], [OtherBus_Specify], [OtherBus_Amount]) VALUES (@TravelExpenseDetail_ID, @ReimTranspo_Type1, @ReimTranspo_Amount1, @ReimTranspo_Type2, @ReimTranspo_Amount2, @ReimTranspo_Type3, @ReimTranspo_Amount3, @FixedAllow_ForP, @FixedAllow_Amount, @MiscTravel_Type, @MiscTravel_Specify, @MiscTravel_Amount, @Entertainment_Explain, @Entertainment_Amount, @BusMeals_Explain, @BusMeals_Amount, @OtherBus_Type, @OtherBus_Specify, @OtherBus_Amount)" UpdateCommand="UPDATE [ACCEDE_T_TravelExpenseDetailsMap] SET [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [ReimTranspo_Type1] = @ReimTranspo_Type1, [ReimTranspo_Amount1] = @ReimTranspo_Amount1, [ReimTranspo_Type2] = @ReimTranspo_Type2, [ReimTranspo_Amount2] = @ReimTranspo_Amount2, [ReimTranspo_Type3] = @ReimTranspo_Type3, [ReimTranspo_Amount3] = @ReimTranspo_Amount3, [FixedAllow_ForP] = @FixedAllow_ForP, [FixedAllow_Amount] = @FixedAllow_Amount, [MiscTravel_Type] = @MiscTravel_Type, [MiscTravel_Specify] = @MiscTravel_Specify, [MiscTravel_Amount] = @MiscTravel_Amount, [Entertainment_Explain] = @Entertainment_Explain, [Entertainment_Amount] = @Entertainment_Amount, [BusMeals_Explain] = @BusMeals_Explain, [BusMeals_Amount] = @BusMeals_Amount, [OtherBus_Type] = @OtherBus_Type, [OtherBus_Specify] = @OtherBus_Specify, [OtherBus_Amount] = @OtherBus_Amount WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID">
        <DeleteParameters>
            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="ReimTranspo_Type1" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount1" Type="Decimal" />
            <asp:Parameter Name="ReimTranspo_Type2" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount2" Type="Decimal" />
            <asp:Parameter Name="ReimTranspo_Type3" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount3" Type="Decimal" />
            <asp:Parameter Name="FixedAllow_ForP" Type="String" />
            <asp:Parameter Name="FixedAllow_Amount" Type="Decimal" />
            <asp:Parameter Name="MiscTravel_Type" Type="String" />
            <asp:Parameter Name="MiscTravel_Specify" Type="String" />
            <asp:Parameter Name="MiscTravel_Amount" Type="Decimal" />
            <asp:Parameter Name="Entertainment_Explain" Type="String" />
            <asp:Parameter Name="Entertainment_Amount" Type="Decimal" />
            <asp:Parameter Name="BusMeals_Explain" Type="String" />
            <asp:Parameter Name="BusMeals_Amount" Type="Decimal" />
            <asp:Parameter Name="OtherBus_Type" Type="String" />
            <asp:Parameter Name="OtherBus_Specify" Type="String" />
            <asp:Parameter Name="OtherBus_Amount" Type="Decimal" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="ReimTranspo_Type1" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount1" Type="Decimal" />
            <asp:Parameter Name="ReimTranspo_Type2" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount2" Type="Decimal" />
            <asp:Parameter Name="ReimTranspo_Type3" Type="String" />
            <asp:Parameter Name="ReimTranspo_Amount3" Type="Decimal" />
            <asp:Parameter Name="FixedAllow_ForP" Type="String" />
            <asp:Parameter Name="FixedAllow_Amount" Type="Decimal" />
            <asp:Parameter Name="MiscTravel_Type" Type="String" />
            <asp:Parameter Name="MiscTravel_Specify" Type="String" />
            <asp:Parameter Name="MiscTravel_Amount" Type="Decimal" />
            <asp:Parameter Name="Entertainment_Explain" Type="String" />
            <asp:Parameter Name="Entertainment_Amount" Type="Decimal" />
            <asp:Parameter Name="BusMeals_Explain" Type="String" />
            <asp:Parameter Name="BusMeals_Amount" Type="Decimal" />
            <asp:Parameter Name="OtherBus_Type" Type="String" />
            <asp:Parameter Name="OtherBus_Specify" Type="String" />
            <asp:Parameter Name="OtherBus_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT ITP_T_FileAttachment.ID, ITP_T_FileAttachment.FileName, ITP_T_FileAttachment.Description, ITP_T_FileAttachment.DateUploaded, ITP_T_FileAttachment.FileSize, ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType FROM ITP_T_FileAttachment INNER JOIN ACCEDE_T_TravelExpenseDetailsFileAttach ON ITP_T_FileAttachment.ID = ACCEDE_T_TravelExpenseDetailsFileAttach.FileAttachment_ID WHERE (ITP_T_FileAttachment.App_ID = @App_ID) AND (ITP_T_FileAttachment.Doc_ID = @Doc_ID) AND (ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType = @DocumentType)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
            <asp:SessionParameter DefaultValue="" Name="Doc_ID" SessionField="TravelExp_Id" Type="Int32" />
            <asp:Parameter DefaultValue="main" Name="DocumentType" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="original_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT ITP_T_FileAttachment.ID, ITP_T_FileAttachment.FileName, ITP_T_FileAttachment.Description, ITP_T_FileAttachment.DateUploaded, ITP_T_FileAttachment.FileSize, ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType, ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID, ITP_T_FileAttachment.FileExtension FROM ITP_T_FileAttachment INNER JOIN ACCEDE_T_TravelExpenseDetailsFileAttach ON ITP_T_FileAttachment.ID = ACCEDE_T_TravelExpenseDetailsFileAttach.FileAttachment_ID WHERE (ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType = @DocumentType) AND (ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID = @ExpenseDetails_ID)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter Name="DocumentType" DefaultValue="sub" />
            <asp:SessionParameter DefaultValue="" Name="ExpenseDetails_ID" SessionField="ExpDetailsID" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="original_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRTMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpReimTranspoMap] WHERE [ReimTranspo_ID] = @ReimTranspo_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpReimTranspoMap] ([ReimTranspo_Type], [ReimTranspo_Amount], [TravelExpenseDetail_ID], [User_ID]) VALUES (@ReimTranspo_Type, @ReimTranspo_Amount, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpReimTranspoMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [ReimTranspo_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpReimTranspoMap] SET [ReimTranspo_Type] = @ReimTranspo_Type, [ReimTranspo_Amount] = @ReimTranspo_Amount, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [ReimTranspo_ID] = @ReimTranspo_ID">
        <DeleteParameters>
            <asp:Parameter Name="ReimTranspo_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="ReimTranspo_Type" Type="Int32" />
            <asp:Parameter Name="ReimTranspo_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="ReimTranspo_Type" Type="Int32" />
            <asp:Parameter Name="ReimTranspo_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
            <asp:Parameter Name="ReimTranspo_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpFixedAllowMap] WHERE [FixedAllow_ID] = @FixedAllow_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpFixedAllowMap] ([FixedAllow_ForP], [FixedAllow_Amount], [TravelExpenseDetail_ID], [User_ID]) VALUES (@FixedAllow_ForP, @FixedAllow_Amount, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpFixedAllowMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [FixedAllow_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpFixedAllowMap] SET [FixedAllow_ForP] = @FixedAllow_ForP, [FixedAllow_Amount] = @FixedAllow_Amount, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [FixedAllow_ID] = @FixedAllow_ID">
        <DeleteParameters>
            <asp:Parameter Name="FixedAllow_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="FixedAllow_ForP" Type="String" />
            <asp:Parameter Name="FixedAllow_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FixedAllow_ForP" Type="String" />
            <asp:Parameter Name="FixedAllow_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
            <asp:Parameter Name="FixedAllow_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlMTMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpMiscTravelMap] WHERE [MiscTravelExp_ID] = @MiscTravelExp_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpMiscTravelMap] ([MiscTravelExp_Type], [MiscTravelExp_Amount], [MiscTravelExp_Specify], [TravelExpenseDetail_ID], [User_ID]) VALUES (@MiscTravelExp_Type, @MiscTravelExp_Amount, @MiscTravelExp_Specify, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpMiscTravelMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [MiscTravelExp_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpMiscTravelMap] SET [MiscTravelExp_Type] = @MiscTravelExp_Type, [MiscTravelExp_Amount] = @MiscTravelExp_Amount, [MiscTravelExp_Specify] = @MiscTravelExp_Specify, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [MiscTravelExp_ID] = @MiscTravelExp_ID">
        <DeleteParameters>
            <asp:Parameter Name="MiscTravelExp_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="MiscTravelExp_Type" Type="Int32" />
            <asp:Parameter Name="MiscTravelExp_Amount" Type="Decimal" />
            <asp:Parameter Name="MiscTravelExp_Specify" Type="String" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="MiscTravelExp_Type" Type="Int32" />
            <asp:Parameter Name="MiscTravelExp_Amount" Type="Decimal" />
            <asp:Parameter Name="MiscTravelExp_Specify" Type="String" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
            <asp:Parameter Name="MiscTravelExp_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOBMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpOtherBusMap] WHERE [OtherBusinessExp_ID] = @OtherBusinessExp_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpOtherBusMap] ([OtherBusinessExp_Type], [OtherBusinessExp_Amount], [OtherBusinessExp_Specify], [TravelExpenseDetail_ID], [User_ID]) VALUES (@OtherBusinessExp_Type, @OtherBusinessExp_Amount, @OtherBusinessExp_Specify, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpOtherBusMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [OtherBusinessExp_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpOtherBusMap] SET [OtherBusinessExp_Type] = @OtherBusinessExp_Type, [OtherBusinessExp_Amount] = @OtherBusinessExp_Amount, [OtherBusinessExp_Specify] = @OtherBusinessExp_Specify, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [OtherBusinessExp_ID] = @OtherBusinessExp_ID">
        <DeleteParameters>
            <asp:Parameter Name="OtherBusinessExp_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="OtherBusinessExp_Type" Type="Int32" />
            <asp:Parameter Name="OtherBusinessExp_Amount" Type="Decimal" />
            <asp:Parameter Name="OtherBusinessExp_Specify" Type="String" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="OtherBusinessExp_Type" Type="Int32" />
            <asp:Parameter Name="OtherBusinessExp_Amount" Type="Decimal" />
            <asp:Parameter Name="OtherBusinessExp_Specify" Type="String" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" />
            <asp:Parameter Name="OtherBusinessExp_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlEMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpEntertainmentMap] WHERE [Entertainment_ID] = @Entertainment_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpEntertainmentMap] ([Entertainment_Explain], [Entertainment_Amount], [TravelExpenseDetail_ID], [User_ID]) VALUES (@Entertainment_Explain, @Entertainment_Amount, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpEntertainmentMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [TravelExpenseDetail_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpEntertainmentMap] SET [Entertainment_Explain] = @Entertainment_Explain, [Entertainment_Amount] = @Entertainment_Amount, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [Entertainment_ID] = @Entertainment_ID">
        <DeleteParameters>
            <asp:Parameter Name="Entertainment_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Entertainment_Explain" Type="String" />
            <asp:Parameter Name="Entertainment_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="Entertainment_Explain" Type="String" />
            <asp:Parameter Name="Entertainment_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
            <asp:Parameter Name="Entertainment_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlBMMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ACCEDE_T_TraExpBusinessMealMap] WHERE [BusinessMeal_ID] = @BusinessMeal_ID" InsertCommand="INSERT INTO [ACCEDE_T_TraExpBusinessMealMap] ([BusinessMeal_Explain], [BusinessMeal_Amount], [TravelExpenseDetail_ID], [User_ID]) VALUES (@BusinessMeal_Explain, @BusinessMeal_Amount, @TravelExpenseDetail_ID, @User_ID)" SelectCommand="SELECT * FROM [ACCEDE_T_TraExpBusinessMealMap] WHERE (([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)) ORDER BY [BusinessMeal_ID]" UpdateCommand="UPDATE [ACCEDE_T_TraExpBusinessMealMap] SET [BusinessMeal_Explain] = @BusinessMeal_Explain, [BusinessMeal_Amount] = @BusinessMeal_Amount, [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [User_ID] = @User_ID WHERE [BusinessMeal_ID] = @BusinessMeal_ID">
        <DeleteParameters>
            <asp:Parameter Name="BusinessMeal_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="BusinessMeal_Explain" Type="String" />
            <asp:Parameter Name="BusinessMeal_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="BusinessMeal_Explain" Type="String" />
            <asp:Parameter Name="BusinessMeal_Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
            <asp:Parameter Name="User_ID" Type="Int32" />
            <asp:Parameter Name="BusinessMeal_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlAccountCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_AccountCharged]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE ([CompanyId] = @CompanyId)">
        <SelectParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReimTranspo" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ReimTranspo] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOtherBusExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_OtherBusExp] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlMiscTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_MiscTravelExp] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetailsMap] WHERE ([ExpenseReportDetail_ID] = @ExpenseReportDetail_ID)">
        <SelectParameters>
            <asp:SessionParameter Name="ExpenseReportDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT ITP_T_WorkflowActivity.WFA_Id, ITP_T_WorkflowActivity.OrgRole_Id, ITP_S_WorkflowDetails.Description, ITP_T_WorkflowActivity.DateAssigned, ITP_T_WorkflowActivity.DateAction, ITP_T_WorkflowActivity.Remarks, 
                  ITP_T_WorkflowActivity.Document_Id, ACCEDE_T_TravelExpenseMain.ID, ITP_T_WorkflowActivity.WF_Id, ITP_T_WorkflowActivity.WFD_Id, ITP_T_WorkflowActivity.ActedBy_User_Id, ITP_T_WorkflowActivity.Status, 
                  ITP_S_Status.STS_Description
FROM     ITP_T_WorkflowActivity INNER JOIN
                  ITP_S_WorkflowDetails ON ITP_T_WorkflowActivity.WFD_Id = ITP_S_WorkflowDetails.WFD_Id AND ITP_T_WorkflowActivity.WF_Id = ITP_S_WorkflowDetails.WF_Id AND 
                  ITP_T_WorkflowActivity.OrgRole_Id = ITP_S_WorkflowDetails.OrgRole_Id INNER JOIN
                  ACCEDE_T_TravelExpenseMain ON ITP_T_WorkflowActivity.Document_Id = ACCEDE_T_TravelExpenseMain.ID INNER JOIN
                  ITP_S_Status ON ITP_T_WorkflowActivity.Status = ITP_S_Status.STS_Id
WHERE  (ITP_T_WorkflowActivity.Document_Id = @Document_Id) AND (ITP_T_WorkflowActivity.AppId = 1032) AND (ITP_T_WorkflowActivity.AppDocTypeId = @AppDocTypeId) AND (ITP_S_Status.STS_Description NOT LIKE '%Pending%')
ORDER BY ITP_T_WorkflowActivity.WFA_Id">
        <SelectParameters>
            <asp:SessionParameter Name="Document_Id" SessionField="TravelExp_Id" />
            <asp:SessionParameter Name="AppDocTypeId" SessionField="appdoctype" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUserOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT TOP (100) PERCENT wd.OrgRole_Id, wd.Sequence, uor.UserId, um.FullName FROM ITP_S_WorkflowDetails AS wd INNER JOIN ITP_S_SecurityUserOrgRoles AS uor ON wd.OrgRole_Id = uor.OrgRoleId INNER JOIN ITP_S_UserMaster AS um ON uor.UserId = um.EmpCode">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTotalFA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT TravelExpenseDetail_ID AS detail, SUM(FixedAllow_Amount) AS tot FROM ACCEDE_T_TraExpFixedAllowMap">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTotalOE" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT TOP (100) PERCENT wd.OrgRole_Id, wd.Sequence, uor.UserId, um.FullName FROM ITP_S_WorkflowDetails AS wd INNER JOIN ITP_S_SecurityUserOrgRoles AS uor ON wd.OrgRole_Id = uor.OrgRoleId INNER JOIN ITP_S_UserMaster AS um ON uor.UserId = um.EmpCode">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTravelForAccounting" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelForAccounting] WHERE ([TravelExpenseMain_ID] = @TravelExpenseMain_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_TravelForAccounting] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACCEDE_T_TravelForAccounting] ([Code], [Amount], [TravelExpenseMain_ID]) VALUES (@Code, @Amount, @TravelExpenseMain_ID)" UpdateCommand="UPDATE [ACCEDE_T_TravelForAccounting] SET [Code] = @Code, [Amount] = @Amount, [TravelExpenseMain_ID] = @TravelExpenseMain_ID WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Code" Type="String" />
            <asp:Parameter Name="Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseMain_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseMain_ID" SessionField="TravelExp_Id" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="Code" Type="String" />
            <asp:Parameter Name="Amount" Type="Decimal" />
            <asp:Parameter Name="TravelExpenseMain_ID" Type="Int32" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
</asp:Content>
