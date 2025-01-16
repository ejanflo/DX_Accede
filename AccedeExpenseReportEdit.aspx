<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeExpenseReportEdit.aspx.cs" Inherits="DX_WebTemplate.Accede_ExpenseReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <style>
            .radio-buttons-container {
                display: flex;
                align-items: center; /* Vertically centers the radio buttons */
                gap: 10px; /* Adjust the spacing between the radio buttons */
            }

        </style>
        <script>
            $("form").bind("keypress", function (e) {
                if (e.keyCode == 13) {
                    return false;
                }
            });

            function onToolbarItemClick(s, e) {
                if (e.item.name === "addExpense") {
                    ASPxClientEdit.ClearEditorsInContainerById('expDiv');
                    expensePopup1.Show();
                    console.log("expe1");
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
                const vaTax = parseFloat(vatTB.cpVAT);
                const ewTax = parseFloat(ewtTB.cpEWT);
                var comp_id = company.GetValue();

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

            function createReimburse() {
                
                if (ASPxClientEdit.ValidateGroup('submitValid')) {
                    var amountReim = dueTotal.GetValue().replace(/[₱,()]/g, ''); 
                    var comp_id = company.GetValue();
                    $.ajax({
                        type: "POST",
                        url: "AccedeExpenseReportEdit.aspx/CheckMinAmountAJAX",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        data: JSON.stringify({ comp_id: comp_id }),
                        success: function (response) {
                            // Update the description text box with the response value
                            
                            if (response.d != 0 && amountReim >= response.d) {
                                console.log(response.d);
                                rfpPaymethod.SetValue(3);
                                rfpPaymethod.SetReadOnly(true);
                                rfpAmount.SetValue(amountReim);
                                rfpAmount.SetReadOnly(true);
                                rfpPopup.Show();
                            } else {
                                rfpAmount.SetValue(amountReim);
                                rfpAmount.SetReadOnly(true);
                                rfpPopup.Show();
                            }
                            
                        },
                        error: function (xhr, status, error) {
                            console.log("Error:", error);
                        }
                    });

                }

            }

            function getRowCount() {
                // Replace 'grid' with your ASPxGridView's ClientInstanceName
                var grid = ASPxClientControl.GetControlCollection().GetByName('DocuGrid0');
                if (grid) {
                    var rowCount = grid.GetVisibleRowsOnPage();
                    console.log("Row count: " + rowCount);
                    if (rowCount > 0) {
                        reimBtn.SetVisible(false);
                    }
                }
                //DocuGrid0.Refresh();
            }

            function OnTotalDueChanged() {
                console.log(dueTotal.GetValue());
                var amountReim = 0;
                if (dueTotal.GetValue() != null) {
                    amountReim = dueTotal.GetValue().replace(/[₱,()]/g, '');
                }
                
                var totalAmount = parseFloat(amountReim) + parseFloat(netAmount.GetValue());
                console.log(amountReim);
                $.ajax({
                    type: "POST",
                    url: "AccedeExpenseReportEdit.aspx/UpdateReimbursementAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({ totalAmount: totalAmount }),
                    success: function (response) {
                        // Update the description text box with the response value
                        //DocuGrid0.Refresh();
                    },
                    error: function (xhr, status, error) {
                        console.log("Error:", error);
                    }
                });
            }

            function OnWFChanged() {
                WFSequenceGrid.PerformCallback();
            }

            function onAmountChanged(s, e) {
                var amount = s.GetValue();
                var comp_id = drpdown_Company.GetValue();

                $.ajax({
                    type: "POST",
                    url: "RFPCreationPage.aspx/CheckMinAmountAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({ comp_id: comp_id }),
                    success: function (response) {
                        // Update the description text box with the response value
                        if (response.d != 0 && amount >= response.d) {
                            drpdown_PayMethod.SetValue(3);
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log("Error:", error);
                    }
                });

                FAPWFGrid.PerformCallback(amount + "|" + comp_id);
                drpdwn_FAPWF.PerformCallback(amount + "|" + comp_id);
                drpdwn_FAPWF.SetSelectedIndex(0);

            }
            function showAlert(message) {
                alert(message);
                loadPanel.Hide();
            }

            function addCA_to_Expense() {
                
                var selectedIds = capopGrid.GetSelectedFieldValues("ID", function (selectedValues) {
                    console.log("Selected IDs: ", selectedValues);
                    if (selectedValues.length > 0) {
                        $.ajax({
                            type: "POST",
                            url: "AccedeExpenseReportEdit.aspx/AddCA_AJAX",
                            data: JSON.stringify({ selectedValues: selectedValues }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                // Handle success
                                loadPanel.Hide();
                                caPopup.Hide();
                                DocuGrid1.Refresh()
                            },
                            failure: function (response) {
                                // Handle failure
                            }
                        });
                    } else {
                        alert("No items selected.");
                    }
                });
                
            }
        </script>
        <dx:ASPxCallback ID="amountCallback" runat="server" ClientInstanceName="amountCallback" OnCallback="amountCallback_Callback">
            <ClientSideEvents CallbackComplete="function(s, e) {
	rfpPaymethod.SetValue(e.result);
}" />
        </dx:ASPxCallback>
        <dx:ASPxCallback ID="submitCallback" runat="server" ClientInstanceName="submitCallback" OnCallback="submitCallback_Callback">
            <ClientSideEvents CallbackComplete="function(s, e) {
	var result = e.result;
                showAlert(result);
}" />
        </dx:ASPxCallback>
        <dx:ASPxCallback ID="rfpCallback" runat="server" ClientInstanceName="rfpCallback" OnCallback="rfpCallback_Callback">
        </dx:ASPxCallback>
<dx:ASPxFormLayout ID="ExpenseEditForm" runat="server" Font-Bold="False" Height="144px" Width="100%" style="margin-bottom: 0px" DataSourceID="SqlExpMain" ClientInstanceName="ExpenseEditForm">
    <Items>
        <dx:LayoutGroup Caption="New Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2" Name="EditFormName">
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
                //DocuGrid1.PerformCallback();
                window.location.href = &quot;AccedeExpenseReportDashboard.aspx&quot;;
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
                        <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="60%">
                            <Items>
                                <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="ReportDate">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxDateEdit ID="dateFiled" runat="server" ClientInstanceName="dateFiled" DisplayFormatString="MMMM dd,yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
                                                <ValidationSettings ValidationGroup="ExpenseEdit">
                                                </ValidationSettings>
                                                <BorderLeft BorderStyle="None" />
                                                <BorderTop BorderStyle="None" />
                                                <BorderRight BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxDateEdit>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Name" ColSpan="1" FieldName="ExpenseName">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="name" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxTextBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyId">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="company" runat="server" ClientInstanceName="company" DataSourceID="sqlCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="CompanyDesc" ValueField="WASSId" Width="100%">
                                                <ClientSideEvents ValueChanged="function(s, e) {
	rfpCompany.SetValue(company.GetValue());
}" />
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Expense" ColSpan="1" FieldName="ExpenseType_ID">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="expenseType" runat="server" ClientInstanceName="expenseType" ClientReadOnly="True" DataSourceID="sqlExpenseType" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" TextField="Description" ValueField="ExpenseType_ID" Width="100%">
                                                <DropDownButton Visible="False">
                                                </DropDownButton>
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Expense Category" ColSpan="1" FieldName="ExpenseCat">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="drpdown_ExpCategory" runat="server" ClientInstanceName="drpdown_ExpCategory" DataSourceID="SqlExpCat" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="Description" ValueField="ID" Width="100%">
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionStyle Font-Bold="True">
                                    </CaptionStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxMemo ID="purpose" runat="server" ClientInstanceName="purpose" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxMemo>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                                <dx:EmptyLayoutItem ColSpan="1">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutItem Caption="" ColSpan="1" FieldName="isTravel">
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
                                <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1" Name="due_lbl">
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
                 createReimburse();
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
                        <dx:LayoutGroup Caption="WORKFLOW DETAILS" ColSpan="1" Width="50%">
                            <Items>
                                <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="drpdown_WF" runat="server" ClientInstanceName="drpdown_WF" DataSourceID="SqlWF" Height="39px" SelectedIndex="0" TextField="WorkflowHeader_Name" ValueField="WF_Id" Width="100%">
                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnWFChanged();
}" />
                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <CaptionStyle Font-Size="Small">
                                    </CaptionStyle>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup Caption="WORKFLOW SEQUENCE" ColSpan="1" Width="50%">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" OnCustomCallback="WFSequenceGrid_CustomCallback" Theme="iOS" Width="100%">
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <Columns>
                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="OrgRole_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="3">
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
                        <dx:LayoutGroup Caption="FAP WORKFLOW DETAILS" ColSpan="1">
                            <Items>
                                <dx:LayoutItem Caption="FAP Workflow" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="drpdwn_FAPWF" runat="server" ClientInstanceName="drpdwn_FAPWF" DataSourceID="SqlFAPWF2" OnCallback="drpdwn_FAPWF_Callback" TextField="Name" ValueField="WF_Id" Width="100%">
                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	
	FAPWFGrid.PerformCallback(s.GetValue());
}" />
                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                    <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                </ValidationSettings>
                                            </dx:ASPxComboBox>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                            </Items>
                            <ParentContainerStyle Font-Size="Small">
                            </ParentContainerStyle>
                        </dx:LayoutGroup>
                        <dx:LayoutGroup Caption="FAP WORKFLOW SEQUENCE" ColSpan="1">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" OnCustomCallback="FAPWFGrid_CustomCallback" Width="100%">
                                                <SettingsEditing Mode="Batch">
                                                </SettingsEditing>
                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <Columns>
                                                    <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="2">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="1">
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
                            <ParentContainerStyle Font-Size="Small">
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
                                                <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
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
                                                <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
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
                                                <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <SettingsLoadingPanel Mode="Disabled" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="0" Caption="Action" Visible="False">
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
                                                    <dx:GridViewToolbar Visible="False">
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
                                            <dx:ASPxGridView ID="DocuGrid2" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" Font-Size="Small" KeyFieldName="ID" OnRowDeleting="DocuGrid_RowDeleting" OnRowUpdating="DocuGrid_RowUpdating" Width="100%" DataSourceID="SqlDocs">
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
    <ClientSideEvents Init="function(s, e) {
	getRowCount();
OnWFChanged();
}" />
</dx:ASPxFormLayout>
    

       
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
                    <dx:LayoutItem Caption="Date" ColSpan="2" ColumnSpan="2">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="dateAdded" runat="server" ClientInstanceName="dateAdded" Font-Size="Small" Width="100%" Font-Bold="True" DisplayFormatString="MMMM dd, yyyy">
                                    <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                    </ValidationSettings>
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                </dx:ASPxDateEdit>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="Supplier" ColSpan="2" Width="50%" ColumnSpan="2">
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
                    <dx:LayoutItem Caption="Particulars" ColSpan="2" Width="50%" ColumnSpan="2">
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
                    <dx:LayoutItem Caption="Account to be Charged" ColSpan="2" Width="50%" ColumnSpan="2">
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
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" VerticalAlign="Bottom" Width="10%" ClientVisible="False">
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
                    <dx:LayoutItem Caption="Gross Amount" ColSpan="2" Width="50%" ColumnSpan="2">
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
                    <dx:LayoutItem Caption="EWT" ColSpan="1" Width="55%" HorizontalAlign="Left">
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
                    <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Width="10%">
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
OnTotalDueChanged();
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
        <dx:ASPxPopupControl ID="rfpPopup" runat="server" FooterText="" HeaderText="Request for Payment Details (Reimbursement)" Width="1146px" ClientInstanceName="rfpPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	ASPxClientEdit.ClearEditorsInContainerById('expDiv')
}" />
            <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="rfpLayout" runat="server" ClientInstanceName="rfpLayout" Width="100%">
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
                                <dx:ASPxComboBox ID="rfpTrantype" runat="server" ClientInstanceName="rfpTrantype" DataSourceID="sqlTranType" Font-Bold="True" Font-Size="Small" SelectedIndex="1" TextField="RFPTranType_Name" ValueField="ID" Width="100%">
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
                                <dx:ASPxTextBox ID="rfpPayee" runat="server" ClientInstanceName="rfpPayee" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                    <dx:LayoutItem Caption="Is Travel?" ColSpan="1" Visible="False">
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
                    <dx:LayoutItem Caption="Last Day of Transaction" ClientVisible="False" ColSpan="1" Name="lastday" Visible="False">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxDateEdit ID="rfpLastday" runat="server" ClientInstanceName="rfpLastday" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
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
                                <dx:ASPxSpinEdit ID="rfpAmount" runat="server" ClientInstanceName="rfpAmount" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" Increment="100" Width="40%">
                                    <ClientSideEvents ValueChanged="function(s, e) {
	amountCallback.PerformCallback();
}" />
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
                                <dx:ASPxMemo ID="rfpPurpose" runat="server" ClientInstanceName="rfpPurpose" Font-Bold="True" Font-Size="Small" Height="10%" Width="100%">
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
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="rfppopupSubmitBtn" runat="server" BackColor="#006838" ClientInstanceName="rfppopupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" OnClick="rfppopupSubmitBtn_Click" Text="Add" UseSubmitBehavior="False" ValidationGroup="rfpValid">
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
                                <dx:ASPxButton ID="popupCancelBtn1" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
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
                                <dx:ASPxButton ID="popupSubmitBtn0" runat="server" Text="Add" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Size="Small" ForeColor="White" Font-Bold="True" ValidationGroup="PopupSubmit" UseSubmitBehavior="False" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(capopGrid.GetSelectedRowCount() &gt; 0){
                      loadPanel.Show();
addCA_to_Expense();
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
    <dx:ASPxPopupControl ID="submitPopup" runat="server" HeaderText="Submit Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="submitPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxFormLayout1_E1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                </TabImage>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxFormLayout1_E2" runat="server" Text="Are you sure you want to submit?" Font-Size="Medium">
                        </dx:ASPxLabel>
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
                                <dx:ASPxButton ID="btnSubmitFinal" runat="server" Text="Submit" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	submitCallback.PerformCallback();
               submitPopup.Hide();
               loadPanel.Show();
}else{
submitPopup.Hide();
console.log(&quot;error&quot;);
}
}
" />
                                    <Border BorderColor="#0D6943" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxFormLayout1_E4" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	SubmitPopup.Hide();
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

            <%-- ADD EXPENSE POPUP--%>
        <dx:ASPxPopupControl ID="expensePopup1" runat="server" FooterText="" HeaderText="New Expense Item" Width="1540px" ClientInstanceName="expensePopup1" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('expDiv')
            }" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="expDiv">
                        <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server" Width="100%">
                    <Items>
                        <dx:LayoutGroup Caption="" ColCount="4" ColSpan="1" ColumnCount="4">
                            <Items>
                                <dx:LayoutItem Caption="Date" ColSpan="2" ColumnSpan="2">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxDateEdit ID="ASPxDateEdit1" runat="server" ClientInstanceName="dateAdded" Font-Size="Small" Width="100%" Font-Bold="True" DisplayFormatString="MMMM dd, yyyy">
                                                <ValidationSettings Display="Dynamic" ValidationGroup="PopupSubmit" SetFocusOnError="True">
                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                </ValidationSettings>
                                                <Border BorderStyle="None" />
                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:ASPxDateEdit>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                    <ParentContainerStyle Font-Size="Small">
                                    </ParentContainerStyle>
                                </dx:LayoutItem>
                                <dx:LayoutItem Caption="Supplier" ColSpan="2" Width="50%" ColumnSpan="2">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" Width="100%" ClientInstanceName="supplier" Font-Size="Small" Font-Bold="True">
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
                                            <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" Width="100%" ClientInstanceName="invoiceOR" Font-Size="Small" Font-Bold="True">
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
                                <dx:LayoutItem Caption="Vendor TIN" ColSpan="2" ColumnSpan="2">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="ASPxTextBox3" runat="server" Width="100%" ClientInstanceName="tin" Font-Size="Small" Font-Bold="True">
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
                                <dx:LayoutItem Caption="Particulars" ColSpan="2" Width="50%" ColumnSpan="2" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxTextBox ID="ASPxTextBox4" runat="server" Width="100%" ClientInstanceName="particulars" Font-Size="Small" Font-Bold="True">
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
                                <dx:LayoutItem Caption="Account to be Charged" ColSpan="2" Width="50%" ColumnSpan="2" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="ASPxComboBox1" runat="server" ClientInstanceName="accountCharged" DataSourceID="sqlAccountCharged" Font-Bold="True" Font-Size="Small" TextField="GLAccount" ValueField="AccCharged_ID" Width="100%" NullValueItemDisplayText="{1}" TextFormatString="{1}">
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
                                <dx:LayoutItem Caption="Cost Center/IO/WBS" ColSpan="2" ColumnSpan="2" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxComboBox ID="ASPxComboBox2" runat="server" ClientInstanceName="costCenter" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" TextField="CostCenter" ValueField="CostCenter_ID" Width="100%" OnCallback="costCenter_Callback">
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
                                <dx:LayoutItem Caption="VAT" ColSpan="1" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxSpinEdit ID="ASPxSpinEdit1" runat="server" ClientInstanceName="vat" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Width="100%" DecimalPlaces="2" Number="0.00" ReadOnly="True">
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
                                <dx:LayoutItem Caption="Gross Amount" ColSpan="2" Width="50%" ColumnSpan="2" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxSpinEdit ID="ASPxSpinEdit2" runat="server" ClientInstanceName="grossAmount" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Width="100%" DisplayFormatString="N" AllowNull="False" Increment="100" Number="0.00" DecimalPlaces="2">
                                                <ClientSideEvents ValueChanged="function(s, e) {
	netAmount.SetValue(s.GetValue());
}" />
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
                                <dx:LayoutItem Caption="EWT" ColSpan="1" Width="55%" HorizontalAlign="Left" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
            <dx:LayoutItemNestedControlContainer runat="server">
                <dx:ASPxSpinEdit ID="ASPxSpinEdit3" runat="server" ClientInstanceName="ewt" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Width="100%" DecimalPlaces="2" Number="0.00" ReadOnly="True">
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
                                <dx:LayoutItem Caption="Net Amount" ColSpan="2" ColumnSpan="2" ClientVisible="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxSpinEdit ID="ASPxSpinEdit4" runat="server" ClientInstanceName="netAmount" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Width="100%" DecimalPlaces="2" Number="0.00" ReadOnly="True">
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
                                <dx:EmptyLayoutItem ColSpan="4" ColumnSpan="4" Height="20px">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutItem ColSpan="4" ColumnSpan="4" ShowCaption="False">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxGridView ID="ASPxGridView3" runat="server" AutoGenerateColumns="False" DataSourceID="SqlExpDetails0" KeyFieldName="ExpenseReportDetail_ID" OnRowInserting="ASPxGridView1_RowInserting" Width="100%">
                                                <SettingsPager Mode="EndlessPaging">
                                                </SettingsPager>
                                                <SettingsEditing Mode="Inline">
                                                </SettingsEditing>
                                                <Settings GridLines="None" />
                                                <SettingsPopup>
                                                    <FilterControl AutoUpdatePosition="False">
                                                    </FilterControl>
                                                </SettingsPopup>
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="160px">
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                    </dx:GridViewDataDateColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Particulars" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="9">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="10" Visible="False">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="11" Visible="False">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="12" Visible="False">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataCheckColumn FieldName="IsUploaded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    </dx:GridViewDataCheckColumn>
                                                    <dx:GridViewDataTextColumn FieldName="ExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="Account to be Charged" FieldName="AccountToCharged" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="CostCenter" ValueField="CostCenter_ID">
                                                            <Columns>
                                                                <dx:ListBoxColumn Caption="Cost Center" FieldName="CostCenter">
                                                                </dx:ListBoxColumn>
                                                                <dx:ListBoxColumn Caption="Department" FieldName="Department" Width="300px">
                                                                </dx:ListBoxColumn>
                                                            </Columns>
                                                        </PropertiesComboBox>
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn Caption="CostCenter/IO/WBS" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        <PropertiesComboBox DataSourceID="sqlAccountCharged" TextField="Description" ValueField="AccCharged_ID">
                                                            <Columns>
                                                                <dx:ListBoxColumn FieldName="GLAccount">
                                                                </dx:ListBoxColumn>
                                                                <dx:ListBoxColumn FieldName="TransactionType" Width="360px">
                                                                </dx:ListBoxColumn>
                                                                <dx:ListBoxColumn FieldName="Description" Width="360px">
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
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" HorizontalAlign="Right" GroupBoxDecoration="None">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="ASPxButton1" runat="server" Text="Add" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Size="Small" ForeColor="White" Font-Bold="True" ValidationGroup="PopupSubmit" UseSubmitBehavior="False" AutoPostBack="False">
                                                <ClientSideEvents Click="function(s, e) {
	AddExpDetails();
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
                                            <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Size="Small" ForeColor="#878787" Font-Bold="True" AutoPostBack="False" UseSubmitBehavior="False">
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

    <asp:SqlDataSource ID="SqlExpMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetails] WHERE (([Preparer_ID] = @Preparer_ID) AND ([ExpenseMain_ID] = @ExpenseMain_ID))" DeleteCommand="DELETE FROM [ACCEDE_T_ExpenseDetails] WHERE [ExpenseReportDetail_ID] = @ExpenseReportDetail_ID" InsertCommand="INSERT INTO [ACCEDE_T_ExpenseDetails] ([DateAdded], [Supplier], [TIN], [InvoiceOR], [Particulars], [AccountToCharged], [CostCenterIOWBS], [GrossAmount], [VAT], [EWT], [NetAmount], [IsUploaded], [ExpenseMain_ID], [Preparer_ID]) VALUES (@DateAdded, @Supplier, @TIN, @InvoiceOR, @Particulars, @AccountToCharged, @CostCenterIOWBS, @GrossAmount, @VAT, @EWT, @NetAmount, @IsUploaded, @ExpenseMain_ID, @Preparer_ID)" UpdateCommand="UPDATE [ACCEDE_T_ExpenseDetails] SET [DateAdded] = @DateAdded, [Supplier] = @Supplier, [TIN] = @TIN, [InvoiceOR] = @InvoiceOR, [Particulars] = @Particulars, [AccountToCharged] = @AccountToCharged, [CostCenterIOWBS] = @CostCenterIOWBS, [GrossAmount] = @GrossAmount, [VAT] = @VAT, [EWT] = @EWT, [NetAmount] = @NetAmount, [IsUploaded] = @IsUploaded, [ExpenseMain_ID] = @ExpenseMain_ID, [Preparer_ID] = @Preparer_ID WHERE [ExpenseReportDetail_ID] = @ExpenseReportDetail_ID">
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
                <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
                <asp:Parameter Name="Preparer_ID" Type="Int32" />
            </InsertParameters>
            <SelectParameters>
                <asp:Parameter Name="Preparer_ID" Type="Int32" />
                <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
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
                <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
                <asp:Parameter Name="Preparer_ID" Type="Int32" />
                <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [WASSId] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL)">
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlAccountCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_AccountCharged]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
            <SelectParameters>
                <asp:SessionParameter Name="EmpCode" SessionField="userID" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([Exp_ID] = @Exp_ID))" DeleteCommand="DELETE FROM [ACCEDE_T_RFPMain] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACCEDE_T_RFPMain] ([Company_ID], [Department_ID], [PayMethod], [TranType], [isTravel], [SAPCostCenter], [IO_Num], [Payee], [LastDayTransact], [Amount], [Purpose], [WF_Id], [User_ID], [Status], [RFP_DocNum], [DateCreated], [IsExpenseCA], [Exp_ID], [FAPWF_Id], [IsExpenseReim]) VALUES (@Company_ID, @Department_ID, @PayMethod, @TranType, @isTravel, @SAPCostCenter, @IO_Num, @Payee, @LastDayTransact, @Amount, @Purpose, @WF_Id, @User_ID, @Status, @RFP_DocNum, @DateCreated, @IsExpenseCA, @Exp_ID, @FAPWF_Id, @IsExpenseReim)" UpdateCommand="UPDATE [ACCEDE_T_RFPMain] SET [Company_ID] = @Company_ID, [Department_ID] = @Department_ID, [PayMethod] = @PayMethod, [TranType] = @TranType, [isTravel] = @isTravel, [SAPCostCenter] = @SAPCostCenter, [IO_Num] = @IO_Num, [Payee] = @Payee, [LastDayTransact] = @LastDayTransact, [Amount] = @Amount, [Purpose] = @Purpose, [WF_Id] = @WF_Id, [User_ID] = @User_ID, [Status] = @Status, [RFP_DocNum] = @RFP_DocNum, [DateCreated] = @DateCreated, [IsExpenseCA] = @IsExpenseCA, [Exp_ID] = @Exp_ID, [FAPWF_Id] = @FAPWF_Id, [IsExpenseReim] = @IsExpenseReim WHERE [ID] = @ID">
            <DeleteParameters>
                <asp:Parameter Name="ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Department_ID" Type="Int32" />
                <asp:Parameter Name="PayMethod" Type="Int32" />
                <asp:Parameter Name="TranType" Type="Int32" />
                <asp:Parameter Name="isTravel" Type="Boolean" />
                <asp:Parameter Name="SAPCostCenter" Type="String" />
                <asp:Parameter Name="IO_Num" Type="String" />
                <asp:Parameter Name="Payee" Type="String" />
                <asp:Parameter DbType="Date" Name="LastDayTransact" />
                <asp:Parameter Name="Amount" Type="Decimal" />
                <asp:Parameter Name="Purpose" Type="String" />
                <asp:Parameter Name="WF_Id" Type="Int32" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="Status" Type="Int32" />
                <asp:Parameter Name="RFP_DocNum" Type="String" />
                <asp:Parameter Name="DateCreated" Type="DateTime" />
                <asp:Parameter Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter Name="Exp_ID" Type="Int32" />
                <asp:Parameter Name="FAPWF_Id" Type="Int32" />
                <asp:Parameter Name="IsExpenseReim" Type="Boolean" />
            </InsertParameters>
            <SelectParameters>
                <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Department_ID" Type="Int32" />
                <asp:Parameter Name="PayMethod" Type="Int32" />
                <asp:Parameter Name="TranType" Type="Int32" />
                <asp:Parameter Name="isTravel" Type="Boolean" />
                <asp:Parameter Name="SAPCostCenter" Type="String" />
                <asp:Parameter Name="IO_Num" Type="String" />
                <asp:Parameter Name="Payee" Type="String" />
                <asp:Parameter DbType="Date" Name="LastDayTransact" />
                <asp:Parameter Name="Amount" Type="Decimal" />
                <asp:Parameter Name="Purpose" Type="String" />
                <asp:Parameter Name="WF_Id" Type="Int32" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="Status" Type="Int32" />
                <asp:Parameter Name="RFP_DocNum" Type="String" />
                <asp:Parameter Name="DateCreated" Type="DateTime" />
                <asp:Parameter Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter Name="Exp_ID" Type="Int32" />
                <asp:Parameter Name="FAPWF_Id" Type="Int32" />
                <asp:Parameter Name="IsExpenseReim" Type="Boolean" />
                <asp:Parameter Name="ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlRFPMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([Exp_ID] = @Exp_ID) AND ([TranType] = @TranType))" DeleteCommand="DELETE FROM [ACCEDE_T_RFPMain] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACCEDE_T_RFPMain] ([Company_ID], [Department_ID], [PayMethod], [TranType], [isTravel], [SAPCostCenter], [IO_Num], [Payee], [LastDayTransact], [Amount], [Purpose], [WF_Id], [User_ID], [Status], [RFP_DocNum], [DateCreated], [IsExpenseCA], [Exp_ID], [FAPWF_Id], [IsExpenseReim]) VALUES (@Company_ID, @Department_ID, @PayMethod, @TranType, @isTravel, @SAPCostCenter, @IO_Num, @Payee, @LastDayTransact, @Amount, @Purpose, @WF_Id, @User_ID, @Status, @RFP_DocNum, @DateCreated, @IsExpenseCA, @Exp_ID, @FAPWF_Id, @IsExpenseReim)" UpdateCommand="UPDATE [ACCEDE_T_RFPMain] SET [Company_ID] = @Company_ID, [Department_ID] = @Department_ID, [PayMethod] = @PayMethod, [TranType] = @TranType, [isTravel] = @isTravel, [SAPCostCenter] = @SAPCostCenter, [IO_Num] = @IO_Num, [Payee] = @Payee, [LastDayTransact] = @LastDayTransact, [Amount] = @Amount, [Purpose] = @Purpose, [WF_Id] = @WF_Id, [User_ID] = @User_ID, [Status] = @Status, [RFP_DocNum] = @RFP_DocNum, [DateCreated] = @DateCreated, [IsExpenseCA] = @IsExpenseCA, [Exp_ID] = @Exp_ID, [FAPWF_Id] = @FAPWF_Id, [IsExpenseReim] = @IsExpenseReim WHERE [ID] = @ID">
            <DeleteParameters>
                <asp:Parameter Name="ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Department_ID" Type="Int32" />
                <asp:Parameter Name="PayMethod" Type="Int32" />
                <asp:Parameter Name="TranType" Type="Int32" />
                <asp:Parameter Name="isTravel" Type="Boolean" />
                <asp:Parameter Name="SAPCostCenter" Type="String" />
                <asp:Parameter Name="IO_Num" Type="String" />
                <asp:Parameter Name="Payee" Type="String" />
                <asp:Parameter DbType="Date" Name="LastDayTransact" />
                <asp:Parameter Name="Amount" Type="Decimal" />
                <asp:Parameter Name="Purpose" Type="String" />
                <asp:Parameter Name="WF_Id" Type="Int32" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="Status" Type="Int32" />
                <asp:Parameter Name="RFP_DocNum" Type="String" />
                <asp:Parameter Name="DateCreated" Type="DateTime" />
                <asp:Parameter Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter Name="Exp_ID" Type="Int32" />
                <asp:Parameter Name="FAPWF_Id" Type="Int32" />
                <asp:Parameter Name="IsExpenseReim" Type="Boolean" />
            </InsertParameters>
            <SelectParameters>
                <asp:Parameter Name="Exp_ID" Type="Int32" />
                <asp:Parameter DefaultValue="2" Name="TranType" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="Company_ID" Type="Int32" />
                <asp:Parameter Name="Department_ID" Type="Int32" />
                <asp:Parameter Name="PayMethod" Type="Int32" />
                <asp:Parameter Name="TranType" Type="Int32" />
                <asp:Parameter Name="isTravel" Type="Boolean" />
                <asp:Parameter Name="SAPCostCenter" Type="String" />
                <asp:Parameter Name="IO_Num" Type="String" />
                <asp:Parameter Name="Payee" Type="String" />
                <asp:Parameter DbType="Date" Name="LastDayTransact" />
                <asp:Parameter Name="Amount" Type="Decimal" />
                <asp:Parameter Name="Purpose" Type="String" />
                <asp:Parameter Name="WF_Id" Type="Int32" />
                <asp:Parameter Name="User_ID" Type="String" />
                <asp:Parameter Name="Status" Type="Int32" />
                <asp:Parameter Name="RFP_DocNum" Type="String" />
                <asp:Parameter Name="DateCreated" Type="DateTime" />
                <asp:Parameter Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter Name="Exp_ID" Type="Int32" />
                <asp:Parameter Name="FAPWF_Id" Type="Int32" />
                <asp:Parameter Name="IsExpenseReim" Type="Boolean" />
                <asp:Parameter Name="ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([User_ID] = @User_ID) AND ([TranType] = @TranType) AND ([Status] = @Status) AND ([Exp_ID] IS NULL))">
            <SelectParameters>
                <asp:Parameter DefaultValue="true" Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter DefaultValue="" Name="User_ID" Type="String" />
                <asp:Parameter DefaultValue="1" Name="TranType" Type="Int32" />
                <asp:Parameter DefaultValue="" Name="Status" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT ID, DepCode, UPPER(DepDesc) as DepDesc, Company_Code FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL) AND ([Company_Code] IS NOT NULL) ORDER BY DepDesc"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_RFPTranType]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlModPay" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="MoP" Name="Code" Type="String" />
        </SelectParameters>
        </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description]) VALUES (@FileName, @Description)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [ID], [FileName], [Description] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID) AND ([DocType_Id] = @DocType_Id))" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description WHERE [ID] = @original_ID">
            <DeleteParameters>
                <asp:Parameter Name="original_ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
            </InsertParameters>
            <SelectParameters>
                <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
                <asp:Parameter DefaultValue="" Name="Doc_ID" Type="Int32" />
                <asp:Parameter DefaultValue="1016" Name="DocType_Id" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="original_ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserWFAccess] WHERE ([UserId] = @UserId)">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
     <asp:SqlDataSource ID="SqlWorkflowSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
</asp:Content>
