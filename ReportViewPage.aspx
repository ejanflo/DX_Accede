<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="ReportViewPage.aspx.cs" Inherits="DX_WebTemplate.ReportViewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        .custom-ok-button {
            background-color: #006838;
            color: white;
            /* Add more styles as needed */
        }
    </style>
    <script>
        function OnInit(s, e) {
            fab.SetActionContext("CancelContext", true);
            //AttachEvents();
        }
        function OnActionItemClick(s, e) {
            if (e.actionName === "Cancel") {
                history.back()
            }
        }
        function ShowTravPopup() {
            TravPopup.Show();
        }

        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                case 'AddExp':
                    AddExpensePopup.Show();
                    break;
                case 'TravAllowance':
                    ShowTravPopup();
                    break;

            }
        }

        function OnCustomButtonClick(s, e) {
            
            var exp_id = s.GetRowKey(e.visibleIndex);
            DocumentGrid.PerformCallback(exp_id);
            console.log(exp_id);
            $.ajax({
                type: "POST",
                url: "ReportViewPage.aspx/VerifyExpenseType",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ exp_id: exp_id }),
                success: function (response) {
                    // Update the description text box with the response value

                    // Assuming "dateEdit" is the ClientInstanceName of your ASPxDateEdit control
                    var dateEdit = ASPxClientControl.GetControlCollection().GetByName("date_TransactDateEdit");

                    if (dateEdit) {
                        var dateString = response.d.TransactionDate; // Replace with the date string you received from AJAX

                        // Convert the date string to a Date object
                        var dateObject = new Date(dateString);

                        // Check if the dateObject is a valid date
                        if (!isNaN(dateObject.getTime())) {
                            // Set the Date object to the ASPxDateEdit control
                            dateEdit.SetDate(dateObject);
                        } else {
                            console.error("Invalid date string:", dateString);
                        }
                    }

                    drpdwn_ExpTypeEdit.SetValue(response.d.ExpenseType_ID);
                    drpdown_ExpCatEdit.SetValue(response.d.ExpenseCategory);
                    txtbox_BusinessPurposeEdit.SetValue(response.d.BusinessPurpose);
                    txtbox_VendorNameEdit.SetValue(response.d.VendorName);
                    txtbox_VendorTINEdit.SetValue(response.d.VendorTIN);
                    txtbox_VendorAddressEdit.SetValue(response.d.VendorAddress);
                    drpdown_CityPurchEdit.SetValue(response.d.CityOfPurchase);
                    txtbox_InvoiceOREdit.SetValue(response.d.InvoiceORNum);
                    drpdown_PayTypeEdit.SetValue(response.d.PaymentType);
                    drpdown_RecStatusEdit.SetValue(response.d.ReceiptStatus);
                    spnEdit_AmountEdit.SetValue(response.d.Requested_Amount);
                    drpdown_CurrencyEdit.SetValue(response.d.Currency_ID);
                    spnEdit_WTAXAmntEdit.SetValue(response.d.WithholdingTaxAmnt);
                    drpdown_WTAXATC_Edit.SetValue(response.d.WithholdingTaxATC);
                    drpdown_InternalOrderEdit.SetValue(response.d.InternalOrder);
                    txtbox_WBS_Edit.SetValue(response.d.WBSElement);
                    txtbox_Asset_Edit.SetValue(response.d.AssetNum);
                    txtbox_SubAssetEdit.SetValue(response.d.SubAssetNum);
                    spnEdit_GST_Edit.SetValue(response.d.GSTAmnt);
                    spnEdit_AmntTaxExempt_Edit.SetValue(response.d.VATExempt);
                    memo_CommentEdit.SetValue(response.d.Comment);

                    EditExpensePopup.Show();
                    DocumentGrid.Refresh();
                  
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });

        }

        function OnAmountChanged() {
            var amnt = spnEdit_AmountAdd.GetValue();
            var gst = 0.00;
            if (amnt != null) {
                gst = amnt * 0.107145;
            }
            var formattedValue = truncateDecimals(gst, 2);
            
            
            spnEdit_GST_Add.SetValue(formattedValue);

        }

        function truncateDecimals(num, decimals) {
            var regEx = new RegExp("\\d+\\.\\d{" + decimals + "}");
            var match = num.toString().match(regEx);
            return match ? parseFloat(match[0]) : num;
        }

        function InsertExpenseClientSide() {

            var expType = drpdwn_ExpTypeAdd.GetValue();
            var expCat = drpdown_ExpCatAdd.GetValue();
            var dateTransact = date_TransactDateAdd.GetValue();
            var businessPurpose = txtbox_BusinessPurposeAdd.GetValue() != null ? txtbox_BusinessPurposeAdd.GetValue() : "";
            var vendorName = txtbox_VendorNameAdd.GetValue() != null ? txtbox_VendorNameAdd.GetValue() : "";
            var vendorTIN = txtbox_VendorTINAdd.GetValue() != null ? txtbox_VendorTINAdd.GetValue() : "";
            var vendorAdd = txtbox_VendorAddressAdd.GetValue() != null ? txtbox_VendorAddressAdd.GetValue() : "";
            var cityPurch = drpdown_CityPurchAdd.GetValue();
            var invoiceOR = txtbox_InvoiceORAdd.GetValue() != null ? txtbox_InvoiceORAdd.GetValue() : "";
            var recStatus = drpdown_RecStatusAdd.GetValue();
            var amount = spnEdit_AmountAdd.GetValue();
            var currency = drpdown_CurrencyAdd.GetValue();
            var  WTAXamnt = spnEdit_WTAXAmntAdd.GetValue() != null ? spnEdit_WTAXAmntAdd.GetValue() : 0.00;
            var WTAX_atc = drpdown_WTAXATC_Add.GetValue() != null ? drpdown_WTAXATC_Add.GetValue() : "";
            var interOrder = drpdown_InternalOrderAdd.GetValue() != null ? drpdown_InternalOrderAdd.GetValue() : "";
            var WBS = txtbox_WBS_Add.GetValue() != null ? txtbox_WBS_Add.GetValue() : "";
            var asset = txtbox_Asset_Add.GetValue() != null ? txtbox_Asset_Add.GetValue() : "";
            var subAsset = txtbox_SubAssetAdd.GetValue() != null ? txtbox_SubAssetAdd.GetValue() : "";
            var GST = spnEdit_GST_Add.GetValue() != null ? spnEdit_GST_Add.GetValue() : 0.00;
            var amntTaxExempt = spnEdit_AmntTaxExempt_Add.GetValue() != null ? spnEdit_AmntTaxExempt_Add.GetValue() : 0.00;
            var comment = memo_CommentAdd.GetValue() != null ? memo_CommentAdd.GetValue() : "";
            var payType = drpdown_PayTypeAdd.GetValue();

            $.ajax({
                type: "POST",
                url: "ReportViewPage.aspx/InsertExpenseServerSide",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expType: expType,
                    expCat: expCat,
                    dateTransact: dateTransact,
                    businessPurpose: businessPurpose,
                    vendorName: vendorName,
                    vendorTIN: vendorTIN,
                    vendorAdd: vendorAdd,
                    cityPurch: cityPurch,
                    invoiceOR: invoiceOR,
                    payType: payType,
                    recStatus: recStatus,
                    amount: amount,
                    currency: currency,
                    WTAXamnt: WTAXamnt,
                    WTAX_atc: WTAX_atc,
                    interOrder: interOrder,
                    WBS: WBS,
                    asset: asset,
                    subAsset: subAsset,
                    GST: GST,
                    amntTaxExempt: amntTaxExempt,
                    comment: comment
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcMssg = response.d;
                    if (funcMssg == "Valid") {
                        AddExpensePopup.Hide();
                        ExpenseGrid.Refresh();
                        location.reload(true);
                    } else {
                        alert(funcMssg);
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

    </script>
    <div class="conta" id="demoFabContent">
        <dx:ASPxFormLayout ID="formAccede" runat="server" DataSourceID="sqlMain" Width="95%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" OnInit="formAccede_Init" ClientInstanceName="formAccede">
            <SettingsAdaptivity SwitchToSingleColumnAtWindowInnerWidth="900" AdaptivityMode="SingleColumnWindowLimit">
            </SettingsAdaptivity>
            <Items>
                <dx:LayoutGroup Caption="Your Page Name Here" ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" ColumnSpan="2" Width="100%" Name="PageTitle">
                    <GroupBoxStyle>
                        <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                            <%--<Paddings PaddingLeft="40%" />--%>
                        </Caption>
                    </GroupBoxStyle>
                    <Items>


                        <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ColCount="3" ColumnCount="3">
                            <Items>

                                <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="btnSubmit" runat="server" BackColor="#006838" Text="Submit" AutoPostBack="False">
                                                <ClientSideEvents Click="function(s, e) {
	    SubmitReport();
    }" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>

                                <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="btnCancel" runat="server" Text="Cancel" Theme="iOS" ClientInstanceName="btnCancel" AutoPostBack="False" EnableTheming="True" BackColor="White" Font-Bold="False" ForeColor="Gray">
                                                <ClientSideEvents Click="function(s, e) {
	    history.back()
    }" />
                                                <Border BorderColor="Gray" />
                                            </dx:ASPxButton>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>

                                <dx:EmptyLayoutItem ColSpan="1" Width="100%">
                                </dx:EmptyLayoutItem>
                            </Items>
                        </dx:LayoutGroup>


                        <dx:LayoutGroup Caption="Report Header Details" ColSpan="2" ColCount="3" ColumnCount="3" ColumnSpan="2" Width="100%">
                            <Items>
                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                    <Items>
                                        <dx:LayoutItem ColSpan="1" FieldName="ReportName">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E4" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyShortName">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E1" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Mode of Payment" ColSpan="1" FieldName="ModPay">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E7" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                    <SettingsItemCaptions HorizontalAlign="Right" />
                                </dx:LayoutGroup>
                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                    <Items>
                                        <dx:LayoutItem Caption="Cost Object Type" ColSpan="1" FieldName="CostObj">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E5" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Cost Center ID" ColSpan="1" FieldName="CostCenter_ID">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E6" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Comment" ColSpan="1" FieldName="Comment">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formAccede_E1" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                    <SettingsItemCaptions HorizontalAlign="Right" />
                                </dx:LayoutGroup>
                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                    <Items>
                                        <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="FormattedReportDate" Name="ReportDate">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="lbl_ReportDate" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Expense Category" ColSpan="1" FieldName="ExpCat">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxLabel ID="formEmployee_E3" runat="server" Font-Bold="True">
                                                    </dx:ASPxLabel>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                    <SettingsItemCaptions HorizontalAlign="Right" />
                                </dx:LayoutGroup>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup Caption="Expenses" ColSpan="1" Width="100%">
                            <Items>
                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" HorizontalAlign="Right">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1" Visible="False">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxButton ID="formAccede_E3" runat="server" Text="Edit Travel Allowance" AutoPostBack="False">
                                                        <ClientSideEvents Click="function(s, e) {
	    ShowTravPopup();
    }" />
                                                    </dx:ASPxButton>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="ExpenseGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlExpense" Font-Overline="False" KeyFieldName="ID" Width="95%" ClientInstanceName="ExpenseGrid" OnHtmlDataCellPrepared="ExpenseGrid_HtmlDataCellPrepared" OnRowUpdating="ExpenseGrid_RowUpdating" OnCustomCallback="ExpenseGrid_CustomCallback" OnRowInserting="ExpenseGrid_RowInserting">
                                                <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                                <SettingsEditing Mode="PopupEditForm">
                                                </SettingsEditing>
                                                <Settings ShowFooter="True" />
                                                <SettingsPopup>
                                                    <EditForm AllowResize="True" Height="500px" HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" Width="1000px">
                                                    </EditForm>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <EditFormLayoutProperties>
                                                    <Items>
                                                        <dx:GridViewLayoutGroup Caption="Details" ColCount="2" ColSpan="1" ColumnCount="2" Width="100%">
                                                            <Items>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Expense Type">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Transaction Date">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Expense Category">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Business Purpose">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Vendor Name">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Vendor TIN">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Vendor Address">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="City Of Purchase">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Invoice No. / OR No.">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Payment Type">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Receipt Status">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Requested">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Currency">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Withholding Tax Amnt">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Withholding Tax ATC">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="WBS Element">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Internal Order">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Asset Num">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Sub Asset Num">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Tax Posted Amnt">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="VAT Exempt">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="Comment">
                                                                </dx:GridViewColumnLayoutItem>
                                                            </Items>
                                                        </dx:GridViewLayoutGroup>
                                                        <dx:GridViewLayoutGroup Caption="" ColSpan="1" HorizontalAlign="Right">
                                                            <Items>
                                                                <dx:EditModeCommandLayoutItem ColSpan="1">
                                                                </dx:EditModeCommandLayoutItem>
                                                            </Items>
                                                        </dx:GridViewLayoutGroup>
                                                    </Items>
                                                </EditFormLayoutProperties>
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Caption="Action">
                                                        <CustomButtons>
                                                            <dx:GridViewCommandColumnCustomButton ID="EditBtn" Text="Edit">
                                                            </dx:GridViewCommandColumnCustomButton>
                                                        </CustomButtons>
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="PaymentType" ShowInCustomizationForm="True" VisibleIndex="2">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="VendorDetails" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="TransactionDate" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ACDE_Main_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="BusinessPurpose" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="VendorName" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10" Name="VendorName">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="VendorTIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11" Name="VendorTIN">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="VendorAddress" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12" Name="VendorAddress">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="CityOfPurchase" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Invoice No. / OR No." FieldName="InvoiceORNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="WBSElement" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="AssetNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="SubAssetNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataMemoColumn FieldName="Comment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="25">
                                                    </dx:GridViewDataMemoColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="ExpenseCategory" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                        <PropertiesComboBox DataSourceID="SqlExpCat" TextField="Description" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="ReceiptStatus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        <PropertiesComboBox DataSourceID="SqlReceiptStat" TextField="Description" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="Currency" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataSpinEditColumn FieldName="WithholdingTaxAmnt" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        <PropertiesSpinEdit DisplayFormatString="g">
                                                        </PropertiesSpinEdit>
                                                    </dx:GridViewDataSpinEditColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="WithholdingTaxATC" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="InternalOrder" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataSpinEditColumn FieldName="TaxPostedAmnt" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                        <PropertiesSpinEdit DisplayFormatString="g">
                                                        </PropertiesSpinEdit>
                                                    </dx:GridViewDataSpinEditColumn>
                                                    <dx:GridViewDataSpinEditColumn FieldName="VATExempt" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                                        <PropertiesSpinEdit DisplayFormatString="g">
                                                        </PropertiesSpinEdit>
                                                    </dx:GridViewDataSpinEditColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="ExpenseType_ID" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Expense Type">
                                                        <PropertiesComboBox DataSourceID="SqlExpType" TextField="ExpenseTypeName" ValueField="ID">
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataSpinEditColumn Caption="Requested" FieldName="Requested_Amount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        <PropertiesSpinEdit DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                        </PropertiesSpinEdit>
                                                    </dx:GridViewDataSpinEditColumn>
                                                </Columns>
                                                <Toolbars>
                                                    <dx:GridViewToolbar>
                                                        <Items>
                                                            <dx:GridViewToolbarItem BeginGroup="True" Name="AddExp" Text="Add Expense">
                                                                <Image IconID="iconbuilder_actions_add_svg_white_16x16">
                                                                </Image>
                                                                <SubMenuPopOutImage IconID="iconbuilder_actions_add_svg_white_16x16">
                                                                </SubMenuPopOutImage>
                                                                <ItemStyle HorizontalAlign="Right" BackColor="#006838" ForeColor="White" />
                                                            </dx:GridViewToolbarItem>
                                                            <dx:GridViewToolbarItem Name="TravAllowance" Text="Edit Travel Details" BeginGroup="True" Visible="False">
                                                                <Image IconID="iconbuilder_actions_edit_svg_dark_16x16">
                                                                </Image>
                                                                <ItemStyle HorizontalAlign="Right" />
                                                                <ScrollButtonStyle HorizontalAlign="Right">
                                                                </ScrollButtonStyle>
                                                            </dx:GridViewToolbarItem>
                                                        </Items>
                                                    </dx:GridViewToolbar>
                                                </Toolbars>
                                                <TotalSummary>
                                                    <dx:ASPxSummaryItem DisplayFormat="Total: #,##0.00" FieldName="Requested_Amount" SummaryType="Sum" ValueDisplayFormat="#,##0.00" />
                                                </TotalSummary>
                                                <Styles>
                                                    <Footer Font-Bold="True" Font-Size="Small">
                                                    </Footer>
                                                </Styles>
                                            </dx:ASPxGridView>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                        <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                        </dx:EmptyLayoutItem>
                        <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                        </dx:EmptyLayoutItem>
                    </Items>
                    <SettingsItemCaptions HorizontalAlign="Right" />
                </dx:LayoutGroup>
            </Items>
            <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
            <BackgroundImage HorizontalPosition="center" ImageUrl="../Content/Images/flat-mountains.svg'" Repeat="NoRepeat" />
        </dx:ASPxFormLayout>
    </div>


    <%--Popup Layouts Here--%>
    <dx:ASPxPopupControl ID="AddExpensePopup" runat="server" HeaderText="Add Expense" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="AddExpensePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity MaxWidth="90%" Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">

    <dx:ASPxFormLayout ID="ExpenseFormAdd" runat="server" Width="100%" ClientInstanceName="ExpenseFormAdd" ColCount="2" ColumnCount="2">
        <Items>
            <dx:TabbedLayoutGroup ColSpan="1" HorizontalAlign="Left" Width="50%">
                <Items>
                    <dx:LayoutGroup Caption="Expense Details" ColCount="2" ColSpan="1" ColumnCount="2" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="Expense Type" ColSpan="2" FieldName="ExpType" Name="ExpType" ColumnSpan="2" VerticalAlign="Top" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdwn_ExpTypeAdd" runat="server" DataSourceID="SqlExpType" TextField="ExpenseTypeDescription" ValueField="ID" Width="100%" ClientInstanceName="drpdwn_ExpTypeAdd" EnableClientSideAPI="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" EnableCustomValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Expense Category" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_ExpCatAdd" runat="server" DataSourceID="SqlExpCat" TextField="Description" ValueField="ID" Width="100%" ClientInstanceName="drpdown_ExpCatAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Transaction Date" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_TransactDateAdd" runat="server" Width="100%" ClientInstanceName="date_TransactDateAdd" DisplayFormatString="mm/dd/yyyy">
                                            <ClientSideEvents Init="function(s, e) {
	s.SetDate(new Date());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Business Purpose" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_BusinessPurposeAdd" runat="server" Width="100%" ClientInstanceName="txtbox_BusinessPurposeAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor Name" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorNameAdd" runat="server" Width="100%" ClientInstanceName="txtbox_VendorNameAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor TIN" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorTINAdd" runat="server" Width="100%" ClientInstanceName="txtbox_VendorTINAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor Address" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorAddressAdd" runat="server" Width="100%" ClientInstanceName="txtbox_VendorAddressAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="City of Purchase" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CityPurchAdd" runat="server" Width="100%" DataSourceID="SqlTravLocation" TextField="LocDescription" ValueField="LocDescription" ClientInstanceName="drpdown_CityPurchAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Invoice No. / OR No." ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_InvoiceORAdd" runat="server" Width="100%" ClientInstanceName="txtbox_InvoiceORAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Type" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_PayTypeAdd" runat="server" Width="100%" DataSourceID="SqlPayType" TextField="Description" ValueField="Description" ClientInstanceName="drpdown_PayTypeAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Receipt Status" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_RecStatusAdd" runat="server" Width="100%" DataSourceID="SqlReceiptStat" TextField="Description" ValueField="ID" ClientInstanceName="drpdown_RecStatusAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_AmountAdd" runat="server" Width="100%" ClientInstanceName="spnEdit_AmountAdd" DisplayFormatString="#,#0.00">
                                            <ClientSideEvents NumberChanged="OnAmountChanged" ValueChanged="OnAmountChanged" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CurrencyAdd" runat="server" Width="100%" DataSourceID="SqlCurrency" TextField="CurrDescription" ValueField="ID" ClientInstanceName="drpdown_CurrencyAdd" SelectedIndex="0">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="W/Tax Amount" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_WTAXAmntAdd" runat="server" Width="100%" ClientInstanceName="spnEdit_WTAXAmntAdd" DecimalPlaces="2" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="W/Tax ATC" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_WTAXATC_Add" runat="server" Width="100%" DataSourceID="SqlWtax" TextField="Description" ValueField="ID" ClientInstanceName="drpdown_WTAXATC_Add" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Internal Order" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_InternalOrderAdd" runat="server" Width="100%" ClientInstanceName="drpdown_InternalOrderAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS Element" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_WBS_Add" runat="server" Width="100%" ClientInstanceName="txtbox_WBS_Add">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Asset Number" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_Asset_Add" runat="server" Width="100%" ClientInstanceName="txtbox_Asset_Add">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Sub Asset Number" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_SubAssetAdd" runat="server" Width="100%" ClientInstanceName="txtbox_SubAssetAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="GST Amount in PHP" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_GST_Add" runat="server" ReadOnly="True" ClientInstanceName="spnEdit_GST_Add" DecimalPlaces="3" DisplayFormatString="#,##0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Amount VAT Exempt" ColSpan="1" VerticalAlign="Top" Width="50%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_AmntTaxExempt_Add" runat="server" Width="100%" ClientInstanceName="spnEdit_AmntTaxExempt_Add" DecimalPlaces="2" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Comment" ColSpan="2" ColumnSpan="2" RowSpan="2" VerticalAlign="Top" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="memo_CommentAdd" runat="server" Width="100%" ClientInstanceName="memo_CommentAdd">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:TabbedLayoutGroup>
            <dx:LayoutGroup Caption="Receipt" ColSpan="1" Width="50%">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxUploadControl ID="UploadController" runat="server" ShowUploadButton="True" Width="100%" OnFilesUploadComplete="UploadController_FilesUploadComplete">
                                    <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocuGrid.Refresh();
}" />
                                </dx:ASPxUploadControl>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" KeyFieldName="ID" Width="100%" OnRowDeleting="DocuGrid_RowDeleting" OnRowUpdating="DocuGrid_RowUpdating">
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <EditFormLayoutProperties>
                                        <Items>
                                            <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="File Name">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColSpan="1" ColumnName="File Desc">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:EditModeCommandLayoutItem ColSpan="1">
                                            </dx:EditModeCommandLayoutItem>
                                        </Items>
                                    </EditFormLayoutProperties>
                                    <Columns>
                                        <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="FileDesc" ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesTextEdit>
                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                                </ValidationSettings>
                                            </PropertiesTextEdit>
                                        </dx:GridViewDataTextColumn>
                                    </Columns>
                                </dx:ASPxGridView>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" HorizontalAlign="Right" ColumnSpan="2">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ExpenseFormEdit_E14" runat="server" AutoPostBack="False" Text="Save" ValidationGroup="AddExpense">
                                    <ClientSideEvents Click="function(s, e) {
	InsertExpenseClientSide();
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ExpenseFormEdit_E15" runat="server" AutoPostBack="False" BackColor="Gray" Text="Cancel">
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
        <SettingsItemCaptions HorizontalAlign="Center" />
        <SettingsItemHelpTexts HorizontalAlign="Center" />
        <SettingsItems HorizontalAlign="Center" />
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

    <dx:ASPxPopupControl ID="EditExpensePopup" runat="server" HeaderText="Edit Expense" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="EditExpensePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity MaxWidth="90%" Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">

    <dx:ASPxFormLayout ID="ExpenseFormEdit" runat="server" Width="100%" ClientInstanceName="ExpenseFormEdit" ColCount="2" ColumnCount="2" DataSourceID="SqlExpenseDetails">
        <Items>
            <dx:TabbedLayoutGroup ColSpan="1" HorizontalAlign="Left" Width="50%">
                <Items>
                    <dx:LayoutGroup Caption="Expense Details" ColCount="2" ColSpan="1" ColumnCount="2" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="Expense Type" ColSpan="2" FieldName="ExpenseType_ID" Name="ExpType" ColumnSpan="2" VerticalAlign="Top" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdwn_ExpTypeEdit" runat="server" DataSourceID="SqlExpType" TextField="ExpenseTypeDescription" ValueField="ID" Width="100%" ClientInstanceName="drpdwn_ExpTypeEdit" EnableClientSideAPI="True" EnableCallbackMode="True" OnCallback="drpdwn_ExpTypeEdit_Callback">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" EnableCustomValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Expense Category" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="ExpenseCategory">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_ExpCatEdit" runat="server" DataSourceID="SqlExpCat" TextField="Description" ValueField="ID" Width="100%" ClientInstanceName="drpdown_ExpCatEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Transaction Date" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="TransactionDate">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_TransactDateEdit" runat="server" Width="100%" ClientInstanceName="date_TransactDateEdit">
                                            <ClientSideEvents Init="function(s, e) {
	s.SetDate(new Date());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Business Purpose" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="BusinessPurpose">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_BusinessPurposeEdit" runat="server" Width="100%" ClientInstanceName="txtbox_BusinessPurposeEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor Name" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="VendorName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorNameEdit" runat="server" Width="100%" ClientInstanceName="txtbox_VendorNameEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor TIN" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="VendorTIN">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorTINEdit" runat="server" Width="100%" ClientInstanceName="txtbox_VendorTINEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Vendor Address" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="VendorAddress">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_VendorAddressEdit" runat="server" Width="100%" ClientInstanceName="txtbox_VendorAddressEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="City of Purchase" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="CityOfPurchase">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CityPurchEdit" runat="server" Width="100%" DataSourceID="SqlTravLocation" TextField="LocDescription" ValueField="LocDescription" ClientInstanceName="drpdown_CityPurchEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Invoice No. / OR No." ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="InvoiceORNum">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_InvoiceOREdit" runat="server" Width="100%" ClientInstanceName="txtbox_InvoiceOREdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Type" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="PaymentType">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_PayTypeEdit" runat="server" Width="100%" DataSourceID="SqlPayType" TextField="Description" ValueField="Description" ClientInstanceName="drpdown_PayTypeEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Receipt Status" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="ReceiptStatus">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_RecStatusEdit" runat="server" Width="100%" DataSourceID="SqlReceiptStat" TextField="Description" ValueField="ID" ClientInstanceName="drpdown_RecStatusEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="Requested_Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_AmountEdit" runat="server" Width="100%" ClientInstanceName="spnEdit_AmountEdit" DisplayFormatString="#,#0.00">
                                            <ClientSideEvents NumberChanged="OnAmountChanged" ValueChanged="OnAmountChanged" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="Currency_ID">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CurrencyEdit" runat="server" Width="100%" DataSourceID="SqlCurrency" TextField="CurrDescription" ValueField="ID" ClientInstanceName="drpdown_CurrencyEdit" SelectedIndex="0">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" CausesValidation="True" ValidationGroup="AddExpense">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="W/Tax Amount" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="WithholdingTaxAmnt">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_WTAXAmntEdit" runat="server" Width="100%" ClientInstanceName="spnEdit_WTAXAmntEdit" DecimalPlaces="2" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="W/Tax ATC" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="WithholdingTaxATC">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_WTAXATC_Edit" runat="server" Width="100%" DataSourceID="SqlWtax" TextField="Description" ValueField="ID" ClientInstanceName="drpdown_WTAXATC_Edit" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Internal Order" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="InternalOrder">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_InternalOrderEdit" runat="server" Width="100%" ClientInstanceName="drpdown_InternalOrderEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS Element" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="WBSElement">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_WBS_Edit" runat="server" Width="100%" ClientInstanceName="txtbox_WBS_Edit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Asset Number" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="AssetNum">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_Asset_Edit" runat="server" Width="100%" ClientInstanceName="txtbox_Asset_Edit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Sub Asset Number" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="SubAssetNum">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_SubAssetEdit" runat="server" Width="100%" ClientInstanceName="txtbox_SubAssetEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="GST Amount in PHP" ColSpan="1" FieldName="GSTAmnt">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_GST_Edit" runat="server" ReadOnly="True" ClientInstanceName="spnEdit_GST_Edit" DecimalPlaces="3" DisplayFormatString="#,##0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Amount VAT Exempt" ColSpan="1" VerticalAlign="Top" Width="50%" FieldName="VATExempt">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spnEdit_AmntTaxExempt_Edit" runat="server" Width="100%" ClientInstanceName="spnEdit_AmntTaxExempt_Edit" DecimalPlaces="2" DisplayFormatString="#,#0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Comment" ColSpan="2" ColumnSpan="2" RowSpan="2" VerticalAlign="Top" Width="100%" FieldName="Comment">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="memo_CommentEdit" runat="server" Width="100%" ClientInstanceName="memo_CommentEdit">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom">
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:TabbedLayoutGroup>
            <dx:LayoutGroup Caption="Receipt" ColSpan="1" Width="50%">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxUploadControl ID="EditUploadController" runat="server" ShowUploadButton="True" Width="100%" OnFilesUploadComplete="EditUploadController_FilesUploadComplete">
                                    <ClientSideEvents FilesUploadComplete="function(s, e) {
DocumentGrid.PerformCallback(&quot;1&quot;);
	DocumentGrid.Refresh();
}" />
                                </dx:ASPxUploadControl>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" KeyFieldName="ID" DataSourceID="SqlExpenseAttach" OnCustomCallback="DocumentGrid_CustomCallback">
                                            <ClientSideEvents CustomButtonClick="function(s, e) {
	window.location = 'FileHandler.ashx?id=' + s.GetRowKey(e.visibleIndex) + '';
}" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1" ReadOnly="True">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="2" ReadOnly="True">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="URL" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateUploaded" ShowInCustomizationForm="True" VisibleIndex="6" ReadOnly="True" Visible="False">
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
                                                <dx:GridViewCommandColumn Caption="Download" ShowInCustomizationForm="True" VisibleIndex="13">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="Download">
                                                            <Image IconID="pdfviewer_next_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                            <Toolbars>
                                                <dx:GridViewToolbar>
                                                    <Items>
                                                        <dx:GridViewToolbarItem Command="Refresh">
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbar>
                                            </Toolbars>
                                        </dx:ASPxGridView>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" HorizontalAlign="Right" ColumnSpan="2">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="EditSubmit_btn" runat="server" AutoPostBack="False" Text="Save" ValidationGroup="AddExpense">
                                    <ClientSideEvents Click="function(s, e) {
	InsertExpenseClientSide();
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="CancelEdit_btn" runat="server" AutoPostBack="False" BackColor="Gray" Text="Cancel">
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
        <SettingsItemCaptions HorizontalAlign="Center" />
        <SettingsItemHelpTexts HorizontalAlign="Center" />
        <SettingsItems HorizontalAlign="Center" />
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

   <%-- Data Source Here--%>
    <asp:SqlDataSource ID="sqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACDE_MainView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code) ORDER BY [Description]">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReceiptStat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code) ORDER BY [ID]">
        <SelectParameters>
            <asp:Parameter DefaultValue="RecStat" Name="Code" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_ExpenseType]"></asp:SqlDataSource>
     <asp:SqlDataSource ID="SqlTravLocation" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_TravelLocation]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="PayType" Name="Code" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWtax" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="WTax" Name="Code" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Currency]"></asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Expense] WHERE ([ACDE_Main_ID] = @ACDE_Main_ID) ORDER BY [TransactionDate]" DeleteCommand="DELETE FROM [ACDE_T_Expense] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACDE_T_Expense] ([PaymentType], [ExpenseType_ID], [VendorDetails], [TransactionDate], [Requested_Amount], [ACDE_Main_ID], [ExpenseCategory], [BusinessPurpose], [VendorName], [VendorTIN], [VendorAddress], [CityOfPurchase], [InvoiceORNum], [ReceiptStatus], [Currency_ID], [WithholdingTaxAmnt], [WithholdingTaxATC], [WBSElement], [InternalOrder], [AssetNum], [SubAssetNum], [TaxPostedAmnt], [VATExempt], [Comment], [DailyAllowanceDetail]) VALUES (@PaymentType, @ExpenseType_ID, @VendorDetails, @TransactionDate, @Requested_Amount, @ACDE_Main_ID, @ExpenseCategory, @BusinessPurpose, @VendorName, @VendorTIN, @VendorAddress, @CityOfPurchase, @InvoiceORNum, @ReceiptStatus, @Currency_ID, @WithholdingTaxAmnt, @WithholdingTaxATC, @WBSElement, @InternalOrder, @AssetNum, @SubAssetNum, @TaxPostedAmnt, @VATExempt, @Comment, @DailyAllowanceDetail)" UpdateCommand="UPDATE [ACDE_T_Expense] SET [PaymentType] = @PaymentType, [ExpenseType_ID] = @ExpenseType_ID, [VendorDetails] = @VendorDetails, [TransactionDate] = @TransactionDate, [Requested_Amount] = @Requested_Amount, [ACDE_Main_ID] = @ACDE_Main_ID, [ExpenseCategory] = @ExpenseCategory, [BusinessPurpose] = @BusinessPurpose, [VendorName] = @VendorName, [VendorTIN] = @VendorTIN, [VendorAddress] = @VendorAddress, [CityOfPurchase] = @CityOfPurchase, [InvoiceORNum] = @InvoiceORNum, [ReceiptStatus] = @ReceiptStatus, [Currency_ID] = @Currency_ID, [WithholdingTaxAmnt] = @WithholdingTaxAmnt, [WithholdingTaxATC] = @WithholdingTaxATC, [WBSElement] = @WBSElement, [InternalOrder] = @InternalOrder, [AssetNum] = @AssetNum, [SubAssetNum] = @SubAssetNum, [TaxPostedAmnt] = @TaxPostedAmnt, [VATExempt] = @VATExempt, [Comment] = @Comment, [DailyAllowanceDetail] = @DailyAllowanceDetail WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int64" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="PaymentType" Type="String" />
            <asp:Parameter Name="ExpenseType_ID" Type="Int32" />
            <asp:Parameter Name="VendorDetails" Type="String" />
            <asp:Parameter DbType="Date" Name="TransactionDate" />
            <asp:Parameter Name="Requested_Amount" Type="Decimal" />
            <asp:Parameter Name="ACDE_Main_ID" Type="Int32" />
            <asp:Parameter Name="ExpenseCategory" Type="Int32" />
            <asp:Parameter Name="BusinessPurpose" Type="String" />
            <asp:Parameter Name="VendorName" Type="String" />
            <asp:Parameter Name="VendorTIN" Type="String" />
            <asp:Parameter Name="VendorAddress" Type="String" />
            <asp:Parameter Name="CityOfPurchase" Type="String" />
            <asp:Parameter Name="InvoiceORNum" Type="String" />
            <asp:Parameter Name="ReceiptStatus" Type="Int32" />
            <asp:Parameter Name="Currency_ID" Type="Int32" />
            <asp:Parameter Name="WithholdingTaxAmnt" Type="Decimal" />
            <asp:Parameter Name="WithholdingTaxATC" Type="String" />
            <asp:Parameter Name="WBSElement" Type="String" />
            <asp:Parameter Name="InternalOrder" Type="String" />
            <asp:Parameter Name="AssetNum" Type="String" />
            <asp:Parameter Name="SubAssetNum" Type="String" />
            <asp:Parameter Name="TaxPostedAmnt" Type="Decimal" />
            <asp:Parameter Name="VATExempt" Type="Decimal" />
            <asp:Parameter Name="Comment" Type="String" />
            <asp:Parameter Name="DailyAllowanceDetail" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter Name="ACDE_Main_ID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="PaymentType" Type="String" />
            <asp:Parameter Name="ExpenseType_ID" Type="Int32" />
            <asp:Parameter Name="VendorDetails" Type="String" />
            <asp:Parameter DbType="Date" Name="TransactionDate" />
            <asp:Parameter Name="Requested_Amount" Type="Decimal" />
            <asp:Parameter Name="ACDE_Main_ID" Type="Int32" />
            <asp:Parameter Name="ExpenseCategory" Type="Int32" />
            <asp:Parameter Name="BusinessPurpose" Type="String" />
            <asp:Parameter Name="VendorName" Type="String" />
            <asp:Parameter Name="VendorTIN" Type="String" />
            <asp:Parameter Name="VendorAddress" Type="String" />
            <asp:Parameter Name="CityOfPurchase" Type="String" />
            <asp:Parameter Name="InvoiceORNum" Type="String" />
            <asp:Parameter Name="ReceiptStatus" Type="Int32" />
            <asp:Parameter Name="Currency_ID" Type="Int32" />
            <asp:Parameter Name="WithholdingTaxAmnt" Type="Decimal" />
            <asp:Parameter Name="WithholdingTaxATC" Type="String" />
            <asp:Parameter Name="WBSElement" Type="String" />
            <asp:Parameter Name="InternalOrder" Type="String" />
            <asp:Parameter Name="AssetNum" Type="String" />
            <asp:Parameter Name="SubAssetNum" Type="String" />
            <asp:Parameter Name="TaxPostedAmnt" Type="Decimal" />
            <asp:Parameter Name="VATExempt" Type="Decimal" />
            <asp:Parameter Name="Comment" Type="String" />
            <asp:Parameter Name="DailyAllowanceDetail" Type="String" />
            <asp:Parameter Name="ID" Type="Int64" />
        </UpdateParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpenseDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Expense] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int64" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpenseAttach" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [ID], [FileName], [Description], [FileExtension], [URL], [DateUploaded], [App_ID], [Company_ID], [DocType_Id], [FileSize], [User_ID], [Doc_No], [Doc_ID] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID))" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [FileExtension], [URL], [DateUploaded], [App_ID], [Company_ID], [DocType_Id], [FileSize], [User_ID], [Doc_No], [Doc_ID]) VALUES (@FileName, @Description, @FileExtension, @URL, @DateUploaded, @App_ID, @Company_ID, @DocType_Id, @FileSize, @User_ID, @Doc_No, @Doc_ID)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [FileExtension] = @FileExtension, [URL] = @URL, [DateUploaded] = @DateUploaded, [App_ID] = @App_ID, [Company_ID] = @Company_ID, [DocType_Id] = @DocType_Id, [FileSize] = @FileSize, [User_ID] = @User_ID, [Doc_No] = @Doc_No, [Doc_ID] = @Doc_ID WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="FileExtension" Type="String" />
            <asp:Parameter Name="URL" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="App_ID" Type="Int32" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="DocType_Id" Type="Int32" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="User_ID" Type="String" />
            <asp:Parameter Name="Doc_No" Type="String" />
            <asp:Parameter Name="Doc_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
            <asp:Parameter Name="Doc_ID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="FileExtension" Type="String" />
            <asp:Parameter Name="URL" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="App_ID" Type="Int32" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="DocType_Id" Type="Int32" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="User_ID" Type="String" />
            <asp:Parameter Name="Doc_No" Type="String" />
            <asp:Parameter Name="Doc_ID" Type="Int32" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>

</asp:Content>
