<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseNew.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseNew" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
    </style>
    <script>
        var calcTotalTimeout;

        function calcTotal(s, e) {
            clearTimeout(calcTotalTimeout);

            calcTotalTimeout = setTimeout(function () {
                ASPxGridView22.batchEditApi.EndEdit();

                // Safely retrieve and sanitize each summary value
                var totReimTranspo = parseFloat(ASPxGridView22.batchEditApi.GetTotalSummaryValue('ReimTranspo_Amount1')) || 0;
                var totFixedAllow = parseFloat(ASPxGridView22.batchEditApi.GetTotalSummaryValue('FixedAllow_Amount')) || 0;
                var totMiscTravel = parseFloat(ASPxGridView22.batchEditApi.GetTotalSummaryValue('MiscTravel_Amount')) || 0;
                var totEntertainment = parseFloat(ASPxGridView22.batchEditApi.GetTotalSummaryValue('Entertainment_Amount')) || 0;
                var totBusMeals = parseFloat(ASPxGridView22.batchEditApi.GetTotalSummaryValue('BusMeals_Amount')) || 0;

                var total = totReimTranspo + totFixedAllow + totMiscTravel + totEntertainment + totBusMeals;

                totalExpTB.SetText(total.toFixed(2));
            }, 1000); // 1-second delay
        }

        function calcTotal1(s, e) {
            clearTimeout(calcTotalTimeout);

            calcTotalTimeout = setTimeout(function () {
                ASPxGridView23.batchEditApi.EndEdit();

                // Safely retrieve and sanitize each summary value
                var totReimTranspo = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('ReimTranspo_Amount1')) || 0;
                var totFixedAllow = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('FixedAllow_Amount')) || 0;
                var totMiscTravel = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('MiscTravel_Amount')) || 0;
                var totEntertainment = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('Entertainment_Amount')) || 0;
                var totBusMeals = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('BusMeals_Amount')) || 0;

                var total = totReimTranspo + totFixedAllow + totMiscTravel + totEntertainment + totBusMeals;

                totalExpTB1.SetText(total.toFixed(2));
            }, 1000); // 1-second delay
        }

        function linkToRFP() {
            var rfpDoc = reimTB.GetText();

            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/RedirectToRFPDetailsAJAX",
                data: JSON.stringify({
                    rfpDoc: rfpDoc
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    LoadingPanel.SetText("Loading RFP Document&hellip;");
                    LoadingPanel.Show();
                    window.open('RFPViewPage.aspx', '_blank');
                    LoadingPanel.Hide();
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function AddReimbursement(stat) {
            reimbursePopup2.Hide();
            if (ASPxClientEdit.ValidateGroup('submitValid')) {
                var empname = empnameCB.GetValue();
                var reportdate = reportdateDE.GetValue();
                var company = companyCB.GetValue();
                var department = departmentCB.GetValue();
                var purpose = purposeMemo.GetText();
                var amount = lbl_dueTotal.GetValue();
                var chargedComp = chargedCB.GetValue();
                var chargedDept = chargedCB0.GetValue();
                var locbranch = locBranch.GetValue();
                var ford = fordCB.GetValue();
                var wf = drpdown_WF.GetValue();
                var fapwf = drpdown_FAPWF.GetValue();

                $.ajax({
                    type: "POST",
                    url: "TravelExpenseNew.aspx/AddRFPReimburseAJAX",
                    data: JSON.stringify({
                        empname: empname,
                        reportdate: reportdate,
                        company: company,
                        department: department,
                        purpose: purpose,
                        amount: amount,
                        chargedComp: chargedComp,
                        chargedDept: chargedDept,
                        locbranch: locbranch,
                        ford: ford,
                        wf: wf,
                        fapwf: fapwf
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        // Handle success
                        if (response.d == true) {
                            if (stat == 0) {
                                LoadingPanel.SetText("Updating document&hellip;");
                                LoadingPanel.Show();
                                SaveTravelExpenseReport("SaveReimburse");
                            } else {
                                console.log("success add reim")
                            }
                        } else {
                            LoadingPanel.SetText("Error adding reimbursement!");
                            LoadingPanel.Show();
                            window.location.href = 'TravelExpenseNew.aspx';
                        }
                    },
                    failure: function (response) {
                        // Handle failure
                        console.log("Error yawa:" + response);
                    }
                });
            }
        }

        function ReimbursementTrap() {
            LoadingPanel.Show();
            var t_amount = "10";
            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/CheckReimburseValidationAJAX",
                data: JSON.stringify({
                    t_amount: t_amount
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    LoadingPanel.Hide();
                    // Handle success
                    if (response.d == true)
                        SubmitPopup2.Show();
                    else
                        SubmitPopup.Show();
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function ReimbursementTrap2() {
            LoadingPanel.Show();
            var t_amount = "100";
            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/CheckReimburseValidationAJAX",
                data: JSON.stringify({
                    t_amount: t_amount
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    LoadingPanel.Hide();
                    // Handle success
                    if (response.d == true)
                        AddReimbursement(0);
                    else
                        reimbursePopup2.Show();
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function ExpCancelClick(s, e) {
            ASPxGridView22.CancelEdit();

            travelExpensePopup.Hide();
        }

        async function ExpPopupClick1(s, e) {
            if (!ASPxClientEdit.ValidateGroup("PopupSubmit")) return;

            LoadingPanel.Show();
            const travelDate = travelDateCalendar1.GetDate();
            let totalExp = totalExpTB1.GetValue();

            try {
                if (ASPxGridView23.batchEditApi.HasChanges()) {
                    // Commit all edited cells first
                    ASPxGridView23.batchEditApi.EndEdit();

                    // Update grid and wait for EndCallback once
                    await new Promise((resolve) => {
                        // Ensure handler is added BEFORE UpdateEdit
                        var handler = function () {
                            ASPxGridView23.EndCallback.RemoveHandler(handler); // faster than ClearHandlers
                            totalExp = totalExpTB1.GetValue(); // safely get total after update
                            resolve();
                        };

                        ASPxGridView23.EndCallback.AddHandler(handler);
                        ASPxGridView23.UpdateEdit();
                    });
                }

                const response = await $.ajax({
                    type: "POST",
                    url: "TravelExpenseNew.aspx/UpdateTravelExpenseDetailsAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        travelDate: travelDate,
                        totalExp: totalExp
                    })
                });

                if (response) {
                    window.open("TravelExpenseNew.aspx", "_self");
                } else {
                    /*alert("error");*/
                }
            } catch (error) {
                console.error("Error:", error);
                LoadingPanel.Hide();
            }
        }

        async function ExpPopupClick(s, e) {
            if (!ASPxClientEdit.ValidateGroup("PopupSubmit")) return;

            LoadingPanel.Show();
            const travelDate = travelDateCalendar.GetDate();
            let totalExp = totalExpTB.GetValue();

            try {
                if (ASPxGridView22.batchEditApi.HasChanges()) {
                    // Commit all edited cells first
                    ASPxGridView22.batchEditApi.EndEdit();

                    // Update grid and wait for EndCallback once
                    await new Promise((resolve) => {
                        // Ensure handler is added BEFORE UpdateEdit
                        var handler = function () {
                            ASPxGridView22.EndCallback.RemoveHandler(handler); // faster than ClearHandlers
                            totalExp = totalExpTB.GetValue(); // safely get total after update
                            resolve();
                        };

                        ASPxGridView22.EndCallback.AddHandler(handler);
                        ASPxGridView22.UpdateEdit();
                    });
                }

                const response = await $.ajax({
                    type: "POST",
                    url: "TravelExpenseNew.aspx/AddTravelExpenseDetailsAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        travelDate: travelDate,
                        totalExp: totalExp
                    })
                });

                if (response) {
                    window.open("TravelExpenseNew.aspx", "_self");
                } else {
                    /*alert("error");*/
                }
            } catch (error) {
                console.error("Error:", error);
                LoadingPanel.Hide();
            }
        }

        function onToolbarItemClick(s, e) {
            if (e.item.name === "addCA") {
                caPopup.Show();
            }

            if (e.item.name === "addExpense") {
                travelExpensePopup.Show();
            }

            if (e.item.name === "createCA") {
                window.open('RFPCreationPage.aspx', '_blank');
            }
        }

        function onCustomButtonClick(s, e) {
            if (e.buttonID == 'btnDownload') {
                loadPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";
                ViewDocument(fileId, appId)
            } else if (e.buttonID == 'btnEditExpDet') {
                loadPanel.Show();
                var item_id = s.GetRowKey(e.visibleIndex);
                travelDateCalendar.SetDate(null);
                totalExpTB.SetValue('');

                viewExpDetailModal(item_id);
            } else {
                var confirmText = "";
                if (e.buttonID == 'btnRemoveCA')
                    confirmText = "Are you sure you want to remove this CA from your expense report?";

                if (e.buttonID == 'btnRemoveExp')
                    confirmText = "Are you sure you want to remove this Expense from your expense report?";

                if (e.buttonID == 'btnRemoveReim')
                    confirmText = "Are you sure you want to remove this Reimbursement from your expense report?";

                var confirmRmv = confirm(confirmText);
                if (confirmRmv) {
                    LoadingPanel.Show();

                    var item_id = s.GetRowKey(e.visibleIndex);
                    var btnCommand = e.buttonID;

                    removeFromExp(item_id, btnCommand);
                }
            }
        }

        function removeFromExp(item_id, btnCommand) {
            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/RemoveFromExp_AJAX",
                data: JSON.stringify({
                    item_id: item_id,
                    btnCommand: btnCommand
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    window.open("TravelExpenseNew.aspx", "_self");
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function AddExpCA() {
            if (capopGrid.GetSelectedRowCount() > 0) {
                LoadingPanel.Show();
                capopGrid.GetSelectedFieldValues("ID", function (selectedValues) {
                    console.log("Selected IDs: ", selectedValues);
                    if (selectedValues.length > 0) {
                        $.ajax({
                            type: "POST",
                            url: "TravelExpenseNew.aspx/AddCA_AJAX",
                            data: JSON.stringify({ selectedValues: selectedValues }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                // Handle success
                                if (response.d) {
                                    window.open("TravelExpenseNew.aspx", "_self");
                                }
                            },
                            failure: function (response) {
                                // Handle failure
                            }
                        });
                    } else {
                        alert("No items selected.");
                    }
                });
            } else {
                alert('No rows selected');
            }
        }

        function SaveTravelExpenseReport(btn) {
            var empname = empnameCB.GetValue();
            var reportdate = reportdateDE.GetValue();
            var company = companyCB.GetValue();
            var department = departmentCB.GetValue();
            var chargedComp = chargedCB.GetValue();
            var chargedDept = chargedCB0.GetValue();
            var datefrom = datefromDE.GetValue();
            var dateto = datetoDE.GetValue();
            var timedepart = timedepartTE.GetValue();
            var timearrive = timearriveTE.GetValue();
            var trip = tripMemo.GetValue();
            var ford = fordCB.GetValue();
            var purpose = purposeMemo.GetValue();
            var expenseType = drpdown_expenseType.GetValue();
            var locbranch = locBranch.GetValue();
            var arNo = arNoTB.GetValue();

            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/SaveSubmitTravelExpenseAJAX",
                data: JSON.stringify({
                    empname: empname,
                    reportdate: reportdate,
                    company: company,
                    department: department,
                    chargedComp: chargedComp,
                    chargedDept: chargedDept,
                    datefrom: datefrom,
                    dateto: dateto,
                    timedepart: timedepart,
                    timearrive: timearrive,
                    trip: trip,
                    ford: ford,
                    purpose: purpose,
                    expenseType: expenseType,
                    locbranch: locbranch,
                    arNo: arNo,
                    btnaction: btn
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    if (response.d.message == "success") {
                        if (btn == "SaveReimburse") {
                            LoadingPanel.Hide();
                            var reimDetails = ExpenseEditForm.GetItemByName('reimDetails');
                            var reimItem = ExpenseEditForm.GetItemByName('reimItem');
                            reimItem.SetVisible(false);
                            reimDetails.SetVisible(true);
                            reimTB.SetText(response.d.rfp_doc);
                            reimTB.SetReadOnly(true);
                        } else if (btn == "CreateSubmit") {
                            AddReimbursement(1);
                            LoadingPanel.SetText("Expense report successfully submitted. Redirecting&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'TravelExpenseMain.aspx';
                        }
                        else {
                            LoadingPanel.SetText("Expense report successfully saved. Redirecting&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'TravelExpenseMain.aspx';
                        }
                    } else if (response.d.message == "require CA") {
                        alert("Please attach corresponding CA to this transaction otherwise, change transaction type to Reimbursement.");
                        LoadingPanel.Hide();
                    } else {
                        alert(response.d);
                        window.location.href = 'TravelExpenseMain.aspx';
                    }
                },
                failure: function (response) {
                    // Handle failure
                    console.log("Error yawa:" + response);
                }
            });
        }

        function viewExpDetailModal(expDetailID) {
            $.ajax({
                type: "POST",
                url: "TravelExpenseNew.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expDetailID: expDetailID
                }),
                success: function (response) {
                    totalExpTB1.SetValue(response.d.totalExp);
                    travelDateCalendar1.SetDate(new Date(response.d.travelDate));

                    //loadPanel.Hide();
                    //travelExpensePopup1.Show();

                    //ASPxGridView23.Refresh();
                    //TraDocuGrid1.Refresh();

                    window.open("TravelExpenseAddDetails.aspx?action=edit", "_self");
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }
    </script>
    <dx:ASPxFormLayout ID="ExpenseEditForm" runat="server" Font-Bold="False" Height="144px" Width="100%" Style="margin-bottom: 0px" DataSourceID="SqlMain" ClientInstanceName="ExpenseEditForm" EnableTheming="True" OnInit="ExpenseEditForm_Init">
        <Items>
            <dx:LayoutGroup Caption="New Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2" Name="EditFormName">
                <Items>
                    <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" ColCount="3" ColumnCount="3" ColumnSpan="2">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="saveBtn" runat="server" BackColor="#006DD6" ClientInstanceName="saveBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" AutoPostBack="False" UseSubmitBehavior="False">
                                            <ClientSideEvents Click="function(s, e) {
	SavePopup.Show();
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
	if(ASPxClientEdit.ValidateGroup('ExpenseEdit')){
                       var reimItem = ExpenseEditForm.GetItemByName('reimItem');
                       if(reimItem .GetVisible() == true){
                              SubmitPopup2.Show();
                       }else{
                              SubmitPopup.Show();
                       }
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
               LoadingPanel.Show();
               window.location.href = &quot;TravelExpenseMain.aspx&quot;;
        }" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="5" ColumnCount="5" ColumnSpan="2" Width="100%">
                        <Paddings PaddingBottom="25px" PaddingTop="25px" />
                        <Items>
                            <dx:TabbedLayoutGroup ColSpan="3" VerticalAlign="Top" ColumnSpan="3" Width="70%">
                                <Items>
                                    <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" RowSpan="2" Width="100%">
                                        <GroupBoxStyle>
                                            <Border BorderColor="#006838" />
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="Employee Name" ColSpan="2" ColumnSpan="2">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="empnameCB" runat="server" AllowMouseWheel="False" ClientEnabled="False" ClientInstanceName="empnameCB" DataSourceID="SqlEmpName" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="FullName" ValueField="EmpCode" Width="55%" SelectedIndex="0">
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Workflow Company" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="companyCB" runat="server" ClientEnabled="False" ClientInstanceName="companyCB" DataSourceID="SqlWFCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="CompanyShortName" ValueField="WASSId" Width="100%" SelectedIndex="0">
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Workflow Department" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="departmentCB" runat="server" ClientEnabled="False" ClientInstanceName="departmentCB" DataSourceID="SqlWFDepartment" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="DepDesc" ValueField="ID" Width="100%" SelectedIndex="0">
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2">
                                            </dx:EmptyLayoutItem>
                                            <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="Date_Created">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxDateEdit ID="reportdateDE" runat="server" ClientInstanceName="reportdateDE" DisplayFormatString="MMMM dd, yyyy" Enabled="False" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <BorderLeft BorderStyle="None" />
                                                            <BorderTop BorderStyle="None" />
                                                            <BorderRight BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxDateEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Transaction Type" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="drpdown_expenseType" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_expenseType" DataSourceID="SqlTranType" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" TextField="Description" ValueField="ExpenseType_ID" Width="100%">
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Charged To Company" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="chargedCB" runat="server" ClientInstanceName="chargedCB" DataSourceID="SqlAllCompany" Font-Bold="True" Font-Size="Small" TextField="CompanyShortName" ValueField="WASSId" Width="100%" SelectedIndex="0">
                                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	locBranch.PerformCallback(s.GetValue());
               chargedCB0.PerformCallback(s.GetValue());
}" />
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False" Font-Italic="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Date From" ColSpan="1" FieldName="Date_From">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxDateEdit ID="datefromDE" runat="server" ClientInstanceName="datefromDE" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxDateEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Location/Branch" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="locBranch" runat="server" ClientInstanceName="locBranch" DataSourceID="SqlLocBranch" Font-Bold="True" Font-Size="Small" TextField="Name" ValueField="ID" Width="100%" SelectedIndex="0">
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required field" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Date To" ColSpan="1" FieldName="Date_To">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxDateEdit ID="datetoDE" runat="server" ClientInstanceName="datetoDE" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxDateEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Charged To Department" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="chargedCB0" runat="server" ClientInstanceName="chargedCB0" DataSourceID="SqlAllDepartment" Font-Bold="True" Font-Size="Small" TextField="DepDesc" ValueField="ID" Width="100%" SelectedIndex="0">
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False" Font-Italic="False">
                                                </CaptionStyle>
                                                <ParentContainerStyle Font-Bold="False" Font-Italic="False">
                                                </ParentContainerStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Time Departed" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTimeEdit ID="timedepartTE" runat="server" ClientInstanceName="timedepartTE" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <SpinButtons ClientVisible="False">
                                                            </SpinButtons>
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxTimeEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Travel" ColSpan="1" FieldName="ForeignDomestic">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="fordCB" runat="server" ClientEnabled="False" ClientInstanceName="fordCB" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                            <Items>
                                                                <dx:ListEditItem Text="Domestic" Value="Domestic" />
                                                                <dx:ListEditItem Text="Foreign" Value="Foreign" />
                                                            </Items>
                                                            <DropDownButton Visible="False">
                                                            </DropDownButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False" Font-Italic="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Time Arrived" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTimeEdit ID="timearriveTE" runat="server" ClientInstanceName="timearriveTE" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <SpinButtons ClientVisible="False">
                                                            </SpinButtons>
                                                            <ClearButton DisplayMode="Always">
                                                            </ClearButton>
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxTimeEdit>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Trip To" ColSpan="1" FieldName="Trip_To">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxMemo ID="tripMemo" runat="server" ClientInstanceName="tripMemo" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxMemo>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <Paddings PaddingBottom="15px" />
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxMemo ID="purposeMemo" runat="server" ClientInstanceName="purposeMemo" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                                            </ValidationSettings>
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            <DisabledStyle ForeColor="#333333">
                                                            </DisabledStyle>
                                                        </dx:ASPxMemo>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <Paddings PaddingBottom="15px" />
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                </Items>
                                <SpanRules>
                                    <dx:SpanRule ColumnSpan="1" RowSpan="1" />
                                </SpanRules>
                            </dx:TabbedLayoutGroup>
                            <dx:TabbedLayoutGroup ColSpan="2" VerticalAlign="Top" ColumnSpan="2" Width="30%">
                                <Items>
                                    <dx:LayoutGroup Caption="CASH ADVANCE DETAILS" ColSpan="1" GroupBoxDecoration="None" Width="100%">
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
                                                                    <dx:ASPxTextBox ID="lbl_caTotal" runat="server" ClientInstanceName="lbl_caTotal" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                        <Border BorderStyle="None" />
                                                                    </dx:ASPxTextBox>
                                                                </dx:PanelContent>
                                                            </PanelCollection>
                                                        </dx:ASPxCallbackPanel>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                                </ParentContainerStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Total Expenses" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxCallbackPanel ID="expTotalCallback" runat="server" ClientInstanceName="expTotalCallback" Width="100%">
                                                            <SettingsLoadingPanel Delay="0" Enabled="False" />
                                                            <PanelCollection>
                                                                <dx:PanelContent runat="server">
                                                                    <dx:ASPxTextBox ID="lbl_expenseTotal" runat="server" ClientInstanceName="lbl_expenseTotal" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                        <Border BorderStyle="None" />
                                                                        <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="2px" />
                                                                    </dx:ASPxTextBox>
                                                                </dx:PanelContent>
                                                            </PanelCollection>
                                                        </dx:ASPxCallbackPanel>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <ParentContainerStyle Font-Bold="True" Font-Size="Small">
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
                                                                    <dx:ASPxTextBox ID="lbl_dueTotal" runat="server" ClientInstanceName="lbl_dueTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                        <Border BorderStyle="None" />
                                                                    </dx:ASPxTextBox>
                                                                </dx:PanelContent>
                                                            </PanelCollection>
                                                        </dx:ASPxCallbackPanel>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                                </ParentContainerStyle>
                                            </dx:LayoutItem>
                                            <dx:EmptyLayoutItem ColSpan="1">
                                                <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" />
                                            </dx:EmptyLayoutItem>
                                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" HorizontalAlign="Right" Name="reimItem">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxButton ID="reimBtn" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="reimBtn" Font-Bold="True" Font-Size="Small" Text="Create RFP" UseSubmitBehavior="False" ValidationGroup="submitValid">
                                                            <ClientSideEvents Click="ReimbursementTrap2" />
                                                        </dx:ASPxButton>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <Paddings PaddingBottom="15px" PaddingTop="10px" />
                                            </dx:LayoutItem>
                                            <dx:EmptyLayoutItem ColSpan="1">
                                                <ParentContainerStyle>
                                                    <Paddings PaddingBottom="15px" />
                                                </ParentContainerStyle>
                                            </dx:EmptyLayoutItem>
                                            <dx:LayoutItem Caption="Reimbursement Details" ClientVisible="False" ColSpan="1" Name="reimDetails" Width="100%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxButtonEdit ID="reimTB" runat="server" ClientInstanceName="reimTB" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                            <ClientSideEvents ButtonClick="linkToRFP" />
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
                                                <Paddings PaddingBottom="15px" />
                                                <ParentContainerStyle Font-Size="Small">
                                                </ParentContainerStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="AR Reference No." ClientVisible="False" ColSpan="1" Name="remItem" FieldName="ARRefNo">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="arNoTB" runat="server" ClientInstanceName="arNoTB" Font-Bold="True" Font-Size="Small" Width="100%">
                                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
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
                                                <CaptionStyle Font-Bold="False">
                                                </CaptionStyle>
                                                <ParentContainerStyle Font-Size="Small">
                                                </ParentContainerStyle>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Name="caGroup" Width="100%">
                        <Items>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Paddings PaddingBottom="25px" />
                                <Items>
                                    <dx:LayoutGroup Caption="CASH ADVANCES" ColSpan="1" GroupBoxDecoration="None">
                                        <GroupBoxStyle>
                                            <Border BorderColor="#006838" />
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CAGrid" DataSourceID="SqlCA" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%">
                                                            <ClientSideEvents CustomButtonClick="onCustomButtonClick" ToolbarItemClick="onToolbarItemClick" />
                                                            <SettingsContextMenu Enabled="True">
                                                            </SettingsContextMenu>
                                                            <SettingsAdaptivity>
                                                                <AdaptiveDetailLayoutProperties>
                                                                    <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                                                                    </SettingsAdaptivity>
                                                                </AdaptiveDetailLayoutProperties>
                                                            </SettingsAdaptivity>
                                                            <SettingsPager Mode="ShowAllRecords" Visible="False">
                                                            </SettingsPager>
                                                            <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                            <SettingsBehavior ConfirmDelete="True" EnableCustomizationWindow="True" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <SettingsLoadingPanel Delay="0" Mode="ShowOnStatusBar" />
                                                            <SettingsText CommandDelete="Remove" ConfirmDelete="Are you sure you want to remove this CA from your expense report?" />
                                                            <Columns>
                                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                    <CustomButtons>
                                                                        <dx:GridViewCommandColumnCustomButton ID="btnRemoveCA" Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                    <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
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
                                                                <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="10">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="12">
                                                                    <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                    </PropertiesTextEdit>
                                                                    <CellStyle Font-Bold="True">
                                                                    </CellStyle>
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="11">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                    <PropertiesComboBox DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                                <dx:GridViewDataComboBoxColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                    <PropertiesComboBox DataSourceID="SqlEmpName" TextField="FullName" ValueField="EmpCode">
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
                                                            <Styles>
                                                                <Disabled ForeColor="#222222">
                                                                </Disabled>
                                                                <Header>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                </Header>
                                                                <Cell>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="5px" PaddingRight="5px" PaddingTop="5px" />
                                                                </Cell>
                                                            </Styles>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Paddings PaddingBottom="25px" PaddingTop="25px" />
                                <Items>
                                    <dx:LayoutGroup Caption="EXPENSES" ColSpan="1" GroupBoxDecoration="None">
                                        <GroupBoxStyle>
                                            <Border BorderColor="#006838" />
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="ExpenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpenseGrid" DataSourceID="SqlExpense" Font-Size="Small" KeyFieldName="TravelExpenseDetail_ID" Theme="MaterialCompact" Width="100%" OnCustomColumnDisplayText="ExpenseGrid_CustomColumnDisplayText">
                                                            <ClientSideEvents CustomButtonClick="onCustomButtonClick" ToolbarItemClick="onToolbarItemClick" />
                                                            <SettingsContextMenu Enabled="True">
                                                            </SettingsContextMenu>
                                                            <SettingsAdaptivity>
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
                                                            <SettingsPager Mode="ShowAllRecords">
                                                            </SettingsPager>
                                                            <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" />
                                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <SettingsLoadingPanel Delay="0" Mode="ShowOnStatusBar" ShowImage="False" />
                                                            <Columns>
                                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                    <CustomButtons>
                                                                        <dx:GridViewCommandColumnCustomButton ID="btnEditExpDet" Text="Edit">
                                                                            <Image IconID="richedit_trackingchanges_trackchanges_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006DD6">
                                                                                    <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                </Style>
                                                                            </Styles>
                                                                        </dx:GridViewCommandColumnCustomButton>
                                                                        <dx:GridViewCommandColumnCustomButton ID="btnRemoveExp" Text="Remove">
                                                                            <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                            </Image>
                                                                            <Styles>
                                                                                <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                    <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                </Style>
                                                                            </Styles>
                                                                        </dx:GridViewCommandColumnCustomButton>
                                                                    </CustomButtons>
                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataTextColumn Caption="ID" FieldName="TravelExpenseDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataDateColumn Caption="Date" FieldName="TravelExpenseDetail_Date" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                                    </PropertiesDateEdit>
                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                </dx:GridViewDataDateColumn>
                                                                <dx:GridViewDataSpinEditColumn Caption="Total Expenses" FieldName="Total_Expenses" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                    </PropertiesSpinEdit>
                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                    <CellStyle Font-Bold="True" HorizontalAlign="Right">
                                                                    </CellStyle>
                                                                </dx:GridViewDataSpinEditColumn>
                                                                <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                    <HeaderStyle HorizontalAlign="Center" />
                                                                    <CellStyle HorizontalAlign="Center">
                                                                    </CellStyle>
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Fixed Allowances" FieldName="TravelExpenseDetail_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Other Travel Expenses" FieldName="TravelExpenseDetail_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                </dx:GridViewDataTextColumn>
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
                                                                <dx:ASPxSummaryItem FieldName="Total_Expenses" SummaryType="Sum" />
                                                            </TotalSummary>
                                                            <Styles>
                                                                <Disabled ForeColor="#222222">
                                                                </Disabled>
                                                                <Header>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                </Header>
                                                                <Cell>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="5px" PaddingRight="5px" PaddingTop="5px" />
                                                                </Cell>
                                                            </Styles>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Paddings PaddingBottom="25px" PaddingTop="25px" />
                                <Items>
                                    <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="1" GroupBoxDecoration="None">
                                        <GroupBoxStyle>
                                            <Border BorderColor="#006838" />
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" Font-Size="Small" ShowProgressPanel="True" UploadMode="Auto" Width="100%" OnFilesUploadComplete="UploadController_FilesUploadComplete">
                                                            <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocumentGrid.Refresh();
}
" />
                                                            <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                            </AdvancedModeSettings>
                                                            <Paddings PaddingBottom="10px" />
                                                            <TextBoxStyle Font-Size="Small" />
                                                        </dx:ASPxUploadControl>
                                                        <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" DataSourceID="SqlDocs" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%">
                                                            <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                            <SettingsPager Mode="ShowAllRecords">
                                                            </SettingsPager>
                                                            <SettingsEditing Mode="Batch">
                                                                <BatchEditSettings StartEditAction="Click" />
                                                            </SettingsEditing>
                                                            <SettingsCommandButton>
                                                                <EditButton>
                                                                    <Image IconID="richedit_trackingchanges_trackchanges_svg_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006DD6">
                                                                            <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </EditButton>
                                                                <DeleteButton Text="Remove">
                                                                    <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                            <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </DeleteButton>
                                                            </SettingsCommandButton>
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <EditFormSettings Visible="True" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataDateColumn FieldName="DateUploaded" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataDateColumn>
                                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="12">
                                                                    <EditFormSettings Visible="False" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    <PropertiesComboBox DataSourceID="SqlSupDocType" TextField="Document_Type" ValueField="Document_Type">
                                                                        <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                        </ValidationSettings>
                                                                    </PropertiesComboBox>
                                                                    <EditFormSettings Visible="True" />
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                            <Styles>
                                                                <Header>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                </Header>
                                                                <Cell>
                                                                    <Paddings PaddingBottom="5px" PaddingLeft="5px" PaddingRight="5px" PaddingTop="5px" />
                                                                </Cell>
                                                            </Styles>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:TabbedLayoutGroup>
                            <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                <Paddings PaddingTop="25px" />
                                <Items>
                                    <dx:LayoutItem Caption="WORKFLOW ACTIVITY &amp; DETAILS" ColSpan="2" ColumnSpan="2" HorizontalAlign="Center">
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
                                                    <SettingsCollapsing AnimationType="Slide" ExpandEffect="Slide" ExpandOnPageLoad="True">
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
                                                                                                    <dx:ASPxGridView ID="WFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFActivityGrid" DataSourceID="SqlWFA" Theme="MaterialCompact" Width="100%">
                                                                                                        <SettingsPager Mode="ShowAllRecords">
                                                                                                        </SettingsPager>
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
                                                                                                            <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWFDetails" Theme="MaterialCompact" Width="100%">
                                                                                                                <SettingsPopup>
                                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                                    </FilterControl>
                                                                                                                </SettingsPopup>
                                                                                                                <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                <Columns>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="3">
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
                                                                                                    <dx:ASPxComboBox ID="drpdown_FAPWF" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_FAPWF" DataSourceID="SqlFAPWF" Font-Bold="True" Height="39px" SelectedIndex="0" TextField="Name" ValueField="WF_Id" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWFDetails" Width="100%" Theme="MaterialCompact">
                                                                                                                <SettingsEditing Mode="Batch">
                                                                                                                </SettingsEditing>
                                                                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                                                                <SettingsPopup>
                                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                                    </FilterControl>
                                                                                                                </SettingsPopup>
                                                                                                                <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                <Columns>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                        <PropertiesComboBox ValueField="OrgRole_Id" DataSourceID="SqlUserOrgRole" TextField="FullName">
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
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
                                        <Paddings Padding="15px" />
                                    </dx:LayoutItem>
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
        <dx:ASPxPopupControl ID="caPopup" runat="server" FooterText="" HeaderText="Select Cash Advance/s" ClientInstanceName="caPopup" Modal="True" PopupVerticalAlign="WindowCenter" CloseAction="None" CssClass="rounded" Maximized="True" ShowCloseButton="False" PopupAnimationType="Fade" PopupHorizontalAlign="WindowCenter">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" Width="100%" BackColor="WhiteSmoke" GroupBoxDecoration="None" HorizontalAlign="Right">
                                <BorderBottom BorderStyle="Solid" />
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" HorizontalAlign="Right" Width="0px">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="popupSubmitBtn0" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Add" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                    <ClientSideEvents Click="AddExpCA" />
                                                    <Border BorderColor="#006838" />
                                                </dx:ASPxButton>
                                                <dx:ASPxButton ID="popupCancelBtn0" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	caPopup.Hide();
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
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="capopGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="capopGrid" DataSourceID="SqlRFPMainCA" Font-Size="Smaller" KeyFieldName="ID" Width="100%" EnableTheming="True" Theme="MaterialCompact">
                                                    <ClientSideEvents ToolbarItemClick="onToolbarItemClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="12">
                                                            <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="10">
                                                            <PropertiesComboBox DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesComboBox DataSourceID="SqlEmpName" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Currency" ShowInCustomizationForm="True" VisibleIndex="11">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="WBS" ShowInCustomizationForm="True" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem Alignment="Left" Name="createCA" Text="Create Cash Advance">
                                                                    <Image IconID="iconbuilder_actions_add_svg_dark_16x16">
                                                                    </Image>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" Command="Refresh">
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
                        </Items>
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="reimbursePopup2" runat="server" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="reimbursePopup2" CloseAction="CloseButton" CloseOnEscape="True" HeaderText="Create RFP" Modal="True" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                <Items>
                                    <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxImage ID="ASPxImage3" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                                                </dx:ASPxImage>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                                        </TabImage>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="ASPxFormLayout2_E4" runat="server" Font-Size="Medium" Height="73px" HorizontalAlign="Center" ReadOnly="True" Text="Generate an RFP for reimbursement?" Width="100%">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="CreateReim" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="CreateReim" Text="Create" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	AddReimbursement(0);
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
                                                <dx:ASPxButton ID="ASPxButton4" runat="server" AutoPostBack="False" BackColor="White" ForeColor="Gray" Text="Cancel" UseSubmitBehavior="False">
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

        <dx:ASPxPopupControl ID="SubmitPopup" runat="server" HeaderText="Submit Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None" Width="400px">
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server" Width="100%">
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
                                        <dx:ASPxLabel ID="ASPxFormLayout1_E2" runat="server" Text="Are you sure you want to submit document?" Font-Size="Medium">
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
                                                <dx:ASPxButton ID="btnSubmitFinal" runat="server" Text="Submit" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" AutoPostBack="False" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEditForm')) { 
	LoadingPanel.Show();
               SubmitPopup.Hide();
	SaveTravelExpenseReport(&quot;Submit&quot;);
}else{
	SubmitPopup.Hide();
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
                                                <dx:ASPxButton ID="ASPxFormLayout1_E4" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray" UseSubmitBehavior="False">
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

        <dx:ASPxPopupControl ID="SubmitPopup2" runat="server" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup2" CloseAction="CloseButton" CloseOnEscape="True" CssClass="rounded-bottom" HeaderText="Submit Expense Report?" Modal="True" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="700px">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout11" runat="server" ColCount="3" ColumnCount="3" Width="100%">
                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
                        </SettingsAdaptivity>
                        <Items>
                            <dx:LayoutItem ColSpan="3" ColumnSpan="3" HorizontalAlign="Center" ShowCaption="False" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxImage ID="ASPxImage4" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                                        </dx:ASPxImage>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                                </TabImage>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="3" ColumnSpan="3" HorizontalAlign="Center" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="ASPxFormLayout6_E4" runat="server" Font-Size="Medium" HorizontalAlign="Center" Text="You haven't created any RFP for the reimbursable amount. Are you sure you want to submit the document without it?" Width="100%">
                                            <Border BorderStyle="None" />
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="30%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnCreateSubmitFinal" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="btnCreateSubmitFinal" HorizontalAlign="Right" Text="Create RFP &amp; Submit" UseSubmitBehavior="False">
                                            <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SubmitPopup2.Hide();
	SaveTravelExpenseReport(&quot;CreateSubmit&quot;);
}else{
	SubmitPopup2.Hide();
}
}
" />
                                            <Border BorderColor="#0D6943" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="30%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton1" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" HorizontalAlign="Right" Text="Submit" UseSubmitBehavior="False">
                                            <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SubmitPopup.Hide();
	SaveTravelExpenseReport(&quot;Submit&quot;);
}else{
	SubmitPopup.Hide();
}
}
" />
                                            <Border BorderColor="#0D6943" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="30%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton7" runat="server" AutoPostBack="False" BackColor="White" ForeColor="Gray" HorizontalAlign="Right" Text="Cancel" UseSubmitBehavior="False">
                                            <ClientSideEvents Click="function(s, e) {
	SubmitPopup2.Hide();
}" />
                                            <Border BorderColor="Gray" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                        </Items>
                        <SettingsItems HorizontalAlign="Center" />
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="SavePopup" runat="server" HeaderText="Save Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SavePopup" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None" Width="400px">
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout5" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxImage ID="ASPxImage1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                                        </dx:ASPxImage>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                                </TabImage>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Are you sure you want to save document?" Font-Size="Medium">
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
                                                <dx:ASPxButton ID="btnSaveExp" runat="server" Text="Save" BackColor="#006DD6" ClientInstanceName="btnSaveExp" AutoPostBack="False" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEditForm')) { 
	LoadingPanel.Show();
               SavePopup.Hide();
	SaveTravelExpenseReport(&quot;Save&quot;);
}else{
	SavePopup.Hide();
}
}
" />
                                                    <Border BorderColor="#006DD6" />
                                                </dx:ASPxButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	SavePopup.Hide();
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

        <dx:ASPxPopupControl ID="ASPxPopupControl1" runat="server" HeaderText="Warning!" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="PetCashPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxImage ID="ASPxImage2" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                                        </dx:ASPxImage>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                                </TabImage>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="ASPxFormLayout3_E2" runat="server" Font-Size="Medium" Height="83px" ReadOnly="True" Width="100%" HorizontalAlign="Center" ClientInstanceName="warning_txt" Font-Bold="False">
                                            <Border BorderStyle="None" />
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" HorizontalAlign="Center" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="ASPxButton3" runat="server" AutoPostBack="False" Text="OK" UseSubmitBehavior="False">
                                                    <ClientSideEvents Click="function(s, e) {
	PetCashPopup.Hide();
}" />
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

        <dx:ASPxPopupControl ID="travelExpensePopup" runat="server" FooterText="" HeaderText="Add Expense Item" ClientInstanceName="travelExpensePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="None" CssClass="rounded" ScrollBars="Both" Maximized="True" ShowCloseButton="False" PopupAnimationType="Fade">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>
                    <dx:ASPxCallbackPanel ID="addExpCallback" runat="server" ClientInstanceName="addExpCallback" Width="100%">
                        <PanelCollection>
                            <dx:PanelContent runat="server">
                                <dx:ASPxFormLayout ID="ASPxFormLayout6" runat="server" Height="450px" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup BackColor="WhiteSmoke" Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                                            <BorderBottom BorderStyle="Solid" />
                                            <Items>
                                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Left" Width="1px">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="totalExpTB" runat="server" ClientEnabled="False" ClientInstanceName="totalExpTB" DisplayFormatString="{0:0,0.00}" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Theme="MaterialCompact" Width="300px">
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
                                                            <dx:ASPxButton ID="viewBtn1" runat="server" AutoPostBack="False" BackColor="#006DD6" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="View Allowance Matrix" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                                <ClientSideEvents Click="function(s, e) {
	window.open('https://devapps.anflocor.com/Inquiry/AllowanceRateBundle.aspx', '_blank')
}" />
                                                                <Border BorderColor="#006DD6" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupSubmitBtn" runat="server" BackColor="#006838" ClientInstanceName="viewBtn1" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit" AutoPostBack="False">
                                                                <ClientSideEvents Click="ExpPopupClick" />
                                                                <Border BorderColor="#006838" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupCancelBtn" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                                <ClientSideEvents Click="ExpCancelClick" />
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
                                            <Paddings PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Date" ColSpan="1" VerticalAlign="Middle" Width="20%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="travelDateCalendar" runat="server" ClientInstanceName="travelDateCalendar" Font-Bold="True" Height="40px" Theme="MaterialCompact" Width="260px">
                                                                <CalendarProperties ShowWeekNumbers="False">
                                                                    <DaySelectedStyle BackColor="#0D6943">
                                                                    </DaySelectedStyle>
                                                                    <TodayStyle ForeColor="#0D6943">
                                                                    </TodayStyle>
                                                                    <ButtonStyle>
                                                                        <PressedStyle BackColor="#0D6943">
                                                                        </PressedStyle>
                                                                    </ButtonStyle>
                                                                    <HeaderStyle BackColor="#0D6943" />
                                                                </CalendarProperties>
                                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                                    <ErrorImage IconID="outlookinspired_highimportance_svg_16x16">
                                                                    </ErrorImage>
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Left" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutGroup Caption="Expense Items" ColSpan="1" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Middle" Width="80%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxGridView ID="ASPxGridView22" runat="server" AutoGenerateColumns="False" ClientInstanceName="ASPxGridView22" EnableTheming="True" Font-Size="Small" KeyFieldName="TravelExpenseDetailMap_ID" Theme="MaterialCompact" Width="100%" OnRowDeleting="ASPxGridView22_RowDeleting" OnRowInserting="ASPxGridView22_RowInserting" OnRowUpdating="ASPxGridView22_RowUpdating">
                                                                        <ClientSideEvents BatchEditRowDeleting="calcTotal" BatchEditRowRecovering="calcTotal" />
                                                                        <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                        </SettingsAdaptivity>
                                                                        <SettingsPager Mode="ShowAllRecords">
                                                                        </SettingsPager>
                                                                        <SettingsEditing Mode="Batch" NewItemRowPosition="Bottom">
                                                                            <BatchEditSettings StartEditAction="Click" />
                                                                        </SettingsEditing>
                                                                        <Settings ShowStatusBar="Hidden" ShowFooter="True" />
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" />
                                                                        <SettingsCommandButton>
                                                                            <NewButton Text=" ">
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
                                                                            <DeleteButton Text=" ">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16" ToolTip="Remove">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="False" ForeColor="#CC2A17">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <SettingsLoadingPanel Mode="Disabled" />
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption=" " ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="35px">
                                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                                <FooterCellStyle HorizontalAlign="Center">
                                                                                </FooterCellStyle>
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="3" FieldName="ReimTranspo_Type1" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderLeft BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption=" Amount" CellRowSpan="3" FieldName="ReimTranspo_Amount1" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit ClientInstanceName="ReimTranspo_Amount1" DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="FIXED ALLOWANCES" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="F or P" FieldName="FixedAllow_ForP" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                        <PropertiesComboBox AllowNull="True">
                                                                                            <Items>
                                                                                                <dx:ListEditItem Text="Full" Value="F" />
                                                                                                <dx:ListEditItem Text="Partial" Value="P" />
                                                                                            </Items>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption=" Remarks" FieldName="FixedAllow_Remarks" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                                <HeaderStyle HorizontalAlign="Center">
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="ENTERTAINMENT" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="Entertainment_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="Entertainment_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="BUSINESS MEALS" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="BusMeals_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="BusMeals_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravel_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" DropDownRows="9" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="240px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetText(); // Get the selected value from ComboBox 
              
               if (selectedValue.includes(&quot;Others&quot;)) { 
                      //ASPxGridView22.GetColumn(15).SetVisible(true);
                      MiscTravelExpSpecify.SetVisible(true);  
                      //miscTravelExpPopup.Show();
               }else{
                      //ASPxGridView22.GetColumn(15).SetVisible(false);
                      MiscTravelExpSpecify.SetVisible(false); 
               }
}
" />
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="MiscTravel_Specify" Name="miscTrav" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                                <PropertiesMemoEdit ClientInstanceName="MiscTravelExpSpecify">
                                                                                                    <ClientSideEvents Init="function(s, e) {
	MiscTravelExpSpecify.SetVisible(false);
}
" />
                                                                                                </PropertiesMemoEdit>
                                                                                                <HeaderStyle>
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MiscTravel_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewDataTextColumn Caption="LOCATION/PARTICULARS" FieldName="LocParticulars" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                                <HeaderStyle HorizontalAlign="Center">
                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                </HeaderStyle>
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                    <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                        <TotalSummary>
                                                                            <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount1" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="FixedAllow_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="MiscTravel_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="Entertainment_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="BusMeals_Amount" SummaryType="Sum" />
                                                                        </TotalSummary>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="2px" PaddingTop="2px" />
                                                                            </Header>
                                                                            <AlternatingRow BackColor="#ECECEC">
                                                                            </AlternatingRow>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" PaddingTop="20px" />
                                                                    </dx:ASPxGridView>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Paddings PaddingTop="20px" />
                                            <Items>
                                                <dx:LayoutGroup Caption="Supporting Documents" ColCount="5" ColSpan="1" ColumnCount="5" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="5" ColumnSpan="5" RowSpan="2" VerticalAlign="Middle">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxUploadControl ID="TraUploadController" runat="server" AutoStartUpload="True" ClientInstanceName="TraUploadController" Font-Size="Small" ShowProgressPanel="True" UploadMode="Auto" Width="100%" OnFilesUploadComplete="TraUploadController_FilesUploadComplete">
                                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	TraDocuGrid.Refresh();
}
" />
                                                                        <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                        </AdvancedModeSettings>
                                                                        <Paddings PaddingBottom="10px" />
                                                                        <TextBoxStyle Font-Size="Small" />
                                                                    </dx:ASPxUploadControl>
                                                                    <dx:ASPxGridView ID="TraDocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="TraDocuGrid" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%">
                                                                        <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                        <SettingsPager Mode="ShowAllRecords">
                                                                        </SettingsPager>
                                                                        <SettingsEditing Mode="Inline">
                                                                        </SettingsEditing>
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" />
                                                                        <SettingsCommandButton>
                                                                            <EditButton>
                                                                                <Image IconID="richedit_trackingchanges_trackchanges_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006DD6">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </EditButton>
                                                                            <DeleteButton Text="Remove">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <EditFormSettings Visible="True" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileExtension" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataComboBoxColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <EditFormSettings Visible="True" />
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                        </Columns>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                            </Header>
                                                                            <Cell>
                                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                            </Cell>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" />
                                                                    </dx:ASPxGridView>
                                                                    <br />
                                                                    <br />
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <Paddings PaddingTop="15px" />
                                                            <CaptionStyle Font-Bold="True">
                                                            </CaptionStyle>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Right" Visible="False">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="ASPxTextBox6" runat="server" Width="50%">
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <BorderTop BorderStyle="Solid" />
                                        </dx:LayoutItem>
                                    </Items>
                                    <Paddings PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                </dx:ASPxFormLayout>
                            </dx:PanelContent>
                        </PanelCollection>
                    </dx:ASPxCallbackPanel>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="travelExpensePopup1" runat="server" FooterText="" HeaderText="Edit Expense Item" ClientInstanceName="travelExpensePopup1" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="None" CssClass="rounded" ScrollBars="Both" Maximized="True" ShowCloseButton="False" PopupAnimationType="Fade">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>
                    <dx:ASPxCallbackPanel ID="addExpCallback0" runat="server" ClientInstanceName="addExpCallback" Width="100%">
                        <PanelCollection>
                            <dx:PanelContent runat="server">
                                <dx:ASPxFormLayout ID="ASPxFormLayout12" runat="server" Height="450px" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup BackColor="WhiteSmoke" Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                                            <BorderBottom BorderStyle="Solid" />
                                            <Items>
                                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Left" Width="1px">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="totalExpTB1" runat="server" ClientEnabled="False" ClientInstanceName="totalExpTB1" DisplayFormatString="{0:0,0.00}" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Theme="MaterialCompact" Width="300px">
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
                                                            <dx:ASPxButton ID="viewBtn2" runat="server" AutoPostBack="False" BackColor="#006DD6" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="View Allowance Matrix" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                                <ClientSideEvents Click="function(s, e) {
	window.open('https://devapps.anflocor.com/Inquiry/AllowanceRateBundle.aspx', '_blank')
}" />
                                                                <Border BorderColor="#006DD6" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupSubmitBtn1" runat="server" BackColor="#006838" ClientInstanceName="viewBtn1" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit" AutoPostBack="False">
                                                                <ClientSideEvents Click="ExpPopupClick1" />
                                                                <Border BorderColor="#006838" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupCancelBtn1" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                                <ClientSideEvents Click="function(s, e) {
	
            ASPxGridView23.CancelEdit();

            travelExpensePopup1.Hide();
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
                                            <Paddings PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Date" ColSpan="1" VerticalAlign="Middle" Width="20%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="travelDateCalendar1" runat="server" ClientInstanceName="travelDateCalendar1" Font-Bold="True" Height="40px" Theme="MaterialCompact" Width="260px">
                                                                <CalendarProperties ShowWeekNumbers="False">
                                                                    <DaySelectedStyle BackColor="#0D6943">
                                                                    </DaySelectedStyle>
                                                                    <TodayStyle ForeColor="#0D6943">
                                                                    </TodayStyle>
                                                                    <ButtonStyle>
                                                                        <PressedStyle BackColor="#0D6943">
                                                                        </PressedStyle>
                                                                    </ButtonStyle>
                                                                    <HeaderStyle BackColor="#0D6943" />
                                                                </CalendarProperties>
                                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                                    <ErrorImage IconID="outlookinspired_highimportance_svg_16x16">
                                                                    </ErrorImage>
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Left" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutGroup Caption="Expense Items" ColSpan="1" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Middle" Width="80%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxGridView ID="ASPxGridView23" runat="server" AutoGenerateColumns="False" ClientInstanceName="ASPxGridView23" EnableTheming="True" Font-Size="Small" KeyFieldName="TravelExpenseDetailMap_ID" Theme="MaterialCompact" Width="100%" OnRowDeleting="ASPxGridView23_RowDeleting" OnRowInserting="ASPxGridView23_RowInserting" OnRowUpdating="ASPxGridView23_RowUpdating" DataSourceID="SqlExpenseDetails">
                                                                        <ClientSideEvents BatchEditRowDeleting="calcTotal1" BatchEditRowRecovering="calcTotal1" />
                                                                        <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                        </SettingsAdaptivity>
                                                                        <SettingsPager Mode="ShowAllRecords">
                                                                        </SettingsPager>
                                                                        <SettingsEditing Mode="Batch" NewItemRowPosition="Bottom">
                                                                            <BatchEditSettings StartEditAction="Click" />
                                                                        </SettingsEditing>
                                                                        <Settings ShowStatusBar="Hidden" ShowFooter="True" />
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" />
                                                                        <SettingsCommandButton>
                                                                            <NewButton Text=" ">
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
                                                                            <DeleteButton Text=" ">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16" ToolTip="Remove">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="False" ForeColor="#CC2A17">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption=" " ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="35px">
                                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                                <FooterCellStyle HorizontalAlign="Center">
                                                                                </FooterCellStyle>
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="3" FieldName="ReimTranspo_Type1" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderLeft BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption=" Amount" CellRowSpan="3" FieldName="ReimTranspo_Amount1" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit ClientInstanceName="ReimTranspo_Amount1" DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="FIXED ALLOWANCES" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="F or P" FieldName="FixedAllow_ForP" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                        <PropertiesComboBox AllowNull="True">
                                                                                            <Items>
                                                                                                <dx:ListEditItem Text="Full" Value="F" />
                                                                                                <dx:ListEditItem Text="Partial" Value="P" />
                                                                                            </Items>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption=" Remarks" FieldName="FixedAllow_Remarks" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                                <HeaderStyle HorizontalAlign="Center">
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="ENTERTAINMENT" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="Entertainment_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="Entertainment_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="BUSINESS MEALS" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="BusMeals_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="BusMeals_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravel_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" DropDownRows="9" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="240px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetText(); // Get the selected value from ComboBox 
              
               if (selectedValue.includes(&quot;Others&quot;)) { 
                      //ASPxGridView22.GetColumn(15).SetVisible(true);
                      MiscTravelExpSpecify.SetVisible(true);  
                      //miscTravelExpPopup.Show();
               }else{
                      //ASPxGridView22.GetColumn(15).SetVisible(false);
                      MiscTravelExpSpecify.SetVisible(false); 
               }
}
" />
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="MiscTravel_Specify" Name="miscTrav" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                                <PropertiesMemoEdit ClientInstanceName="MiscTravelExpSpecify">
                                                                                                    <ClientSideEvents Init="function(s, e) {
	MiscTravelExpSpecify.SetVisible(false);
}
" />
                                                                                                </PropertiesMemoEdit>
                                                                                                <HeaderStyle>
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MiscTravel_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewDataTextColumn Caption="LOCATION/PARTICULARS" FieldName="LocParticulars" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                                <HeaderStyle HorizontalAlign="Center">
                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                </HeaderStyle>
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                    <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                        <TotalSummary>
                                                                            <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount1" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="FixedAllow_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="MiscTravel_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="Entertainment_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="BusMeals_Amount" SummaryType="Sum" />
                                                                        </TotalSummary>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="2px" PaddingTop="2px" />
                                                                            </Header>
                                                                            <AlternatingRow BackColor="#ECECEC">
                                                                            </AlternatingRow>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" PaddingTop="20px" />
                                                                    </dx:ASPxGridView>
                                                                    <asp:SqlDataSource ID="SqlExpenseDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE ([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID" UpdateCommand="UPDATE [ACCEDE_T_TravelExpenseDetailsMap] SET [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [ReimTranspo_Type1] = @ReimTranspo_Type1, [ReimTranspo_Amount1] = @ReimTranspo_Amount1, [ReimTranspo_Type2] = @ReimTranspo_Type2, [ReimTranspo_Amount2] = @ReimTranspo_Amount2, [ReimTranspo_Type3] = @ReimTranspo_Type3, [ReimTranspo_Amount3] = @ReimTranspo_Amount3, [FixedAllow_ForP] = @FixedAllow_ForP, [FixedAllow_Amount] = @FixedAllow_Amount, [MiscTravel_Type] = @MiscTravel_Type, [MiscTravel_Specify] = @MiscTravel_Specify, [MiscTravel_Amount] = @MiscTravel_Amount, [Entertainment_Explain] = @Entertainment_Explain, [Entertainment_Amount] = @Entertainment_Amount, [BusMeals_Explain] = @BusMeals_Explain, [BusMeals_Amount] = @BusMeals_Amount, [OtherBus_Type] = @OtherBus_Type, [OtherBus_Specify] = @OtherBus_Specify, [OtherBus_Amount] = @OtherBus_Amount, [FixedAllow_Remarks] = @FixedAllow_Remarks, [LocParticulars] = @LocParticulars WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID">
                                                                        <DeleteParameters>
                                                                            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
                                                                        </DeleteParameters>
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
                                                                            <asp:Parameter Name="FixedAllow_Remarks" Type="String" />
                                                                            <asp:Parameter Name="LocParticulars" Type="String" />
                                                                            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
                                                                        </UpdateParameters>
                                                                    </asp:SqlDataSource>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Paddings PaddingTop="20px" />
                                            <Items>
                                                <dx:LayoutGroup Caption="Supporting Documents" ColCount="5" ColSpan="1" ColumnCount="5" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="5" ColumnSpan="5" RowSpan="2" VerticalAlign="Middle">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxUploadControl ID="TraUploadController1" runat="server" AutoStartUpload="True" ClientInstanceName="TraUploadController1" Font-Size="Small" ShowProgressPanel="True" UploadMode="Auto" Width="100%" OnFilesUploadComplete="TraUploadController1_FilesUploadComplete">
                                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	TraDocuGrid1.Refresh();
}
" />
                                                                        <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                        </AdvancedModeSettings>
                                                                        <Paddings PaddingBottom="10px" />
                                                                        <TextBoxStyle Font-Size="Small" />
                                                                    </dx:ASPxUploadControl>
                                                                    <dx:ASPxGridView ID="TraDocuGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="TraDocuGrid1" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%" DataSourceID="SqlTraDocs">
                                                                        <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                        <SettingsEditing Mode="Inline">
                                                                        </SettingsEditing>
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" />
                                                                        <SettingsCommandButton>
                                                                            <EditButton>
                                                                                <Image IconID="richedit_trackingchanges_trackchanges_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006DD6">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </EditButton>
                                                                            <DeleteButton Text="Remove">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <EditFormSettings Visible="True" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileExtension" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataComboBoxColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <EditFormSettings Visible="True" />
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                        </Columns>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                            </Header>
                                                                            <Cell>
                                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                            </Cell>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" />
                                                                    </dx:ASPxGridView>
                                                                    <asp:SqlDataSource ID="SqlTraDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT ITP_T_FileAttachment.ID, ITP_T_FileAttachment.FileName, ITP_T_FileAttachment.Description, ITP_T_FileAttachment.DateUploaded, ITP_T_FileAttachment.FileSize, ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType, ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID, ITP_T_FileAttachment.FileExtension FROM ITP_T_FileAttachment INNER JOIN ACCEDE_T_TravelExpenseDetailsFileAttach ON ITP_T_FileAttachment.ID = ACCEDE_T_TravelExpenseDetailsFileAttach.FileAttachment_ID WHERE (ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType = @DocumentType) AND (ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID = @ExpenseDetails_ID)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
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
                                                                            <asp:Parameter DefaultValue="sub" Name="DocumentType" />
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
                                                                    <br />
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <Paddings PaddingTop="15px" />
                                                            <CaptionStyle Font-Bold="True">
                                                            </CaptionStyle>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Right" Visible="False">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="ASPxTextBox7" runat="server" Width="50%">
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <BorderTop BorderStyle="Solid" />
                                        </dx:LayoutItem>
                                    </Items>
                                    <Paddings PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                </dx:ASPxFormLayout>
                            </dx:PanelContent>
                        </PanelCollection>
                    </dx:ASPxCallbackPanel>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact" Text="" CssClass="p-0 m-0"></dx:ASPxLoadingPanel>

    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" ClientInstanceName="loadPanel" Modal="True" Theme="MaterialCompact">
    </dx:ASPxLoadingPanel>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseMain] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlEmpName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] = @WASSId)">
        <SelectParameters>
            <asp:Parameter Name="WASSId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAllCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] = @WASSId) ORDER BY CompanyDesc">
        <SelectParameters>
            <asp:Parameter Name="WASSId" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAllDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([Exp_ID] = @Exp_ID) AND ([Status] = @Status) AND ([isTravel] = @isTravel)) ">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
            <asp:SessionParameter DefaultValue="" Name="Exp_ID" SessionField="TravelExp_Id" Type="Int32" />
            <asp:SessionParameter DefaultValue="" Name="Status" SessionField="statusid" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="isTravel" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseDetails] WHERE ([TravelExpenseMain_ID] = @TravelExpenseMain_ID) ORDER BY [TravelExpenseDetail_Date] ASC">
        <SelectParameters>
            <asp:SessionParameter Name="TravelExpenseMain_ID" SessionField="TravelExp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT ITP_T_FileAttachment.ID, ITP_T_FileAttachment.FileName, ITP_T_FileAttachment.Description, ITP_T_FileAttachment.DateUploaded, ITP_T_FileAttachment.FileSize, ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType FROM ITP_T_FileAttachment INNER JOIN ACCEDE_T_TravelExpenseDetailsFileAttach ON ITP_T_FileAttachment.ID = ACCEDE_T_TravelExpenseDetailsFileAttach.FileAttachment_ID WHERE (ITP_T_FileAttachment.App_ID = @App_ID) AND (ITP_T_FileAttachment.Doc_ID = @Doc_ID) AND (ITP_T_FileAttachment.User_ID = @User_ID) AND (ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType = @DocumentType)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
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
            <asp:SessionParameter DefaultValue="" Name="User_ID" SessionField="userID" />
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
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRAWF" runat="server"
        ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>"
        SelectCommand="sp_sel_ACCEDE_GetWorkflowHeadersByExpenseAndDepartment"
        SelectCommandType="StoredProcedure">

        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="CompanyId" Type="String" />
            <asp:Parameter Name="totalExp" Type="Decimal" />
            <asp:Parameter Name="DepCode" Type="String" />
            <asp:Parameter Name="AppId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT DISTINCT Sequence, WF_Id, 
       (SELECT TOP 1 UM.FullName
        FROM ITP_S_SecurityUserOrgRoles SUOR
        JOIN ITP_S_UserMaster UM ON SUOR.UserId = UM.EmpCode
        WHERE SUOR.OrgRoleId = WD.OrgRole_Id
        ORDER BY UM.FullName) AS FullName
FROM ITP_S_WorkflowDetails WD
WHERE WF_Id = @WF_Id
ORDER BY Sequence">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWFDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT DISTINCT Sequence, WF_Id, 
       (SELECT TOP 1 UM.FullName
        FROM ITP_S_SecurityUserOrgRoles SUOR
        JOIN ITP_S_UserMaster UM ON SUOR.UserId = UM.EmpCode
        WHERE SUOR.OrgRoleId = WD.OrgRole_Id
        ORDER BY UM.FullName) AS FullName
FROM ITP_S_WorkflowDetails WD
WHERE WF_Id = @WF_Id
ORDER BY Sequence">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlLocBranch" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" />
        </SelectParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([User_ID] = @User_ID) AND ([isTravel] = @isTravel) AND ([IsExpenseCA] = @IsExpenseCA) AND ([TranType] = @TranType) AND ([Status] = @Status) AND ([Exp_ID] IS NULL) AND ([Payee] = @Payee) AND ([isForeignTravel] = @isForeignTravel))">
        <SelectParameters>
            <asp:SessionParameter Name="User_ID" SessionField="userID" Type="String" />
            <asp:Parameter DefaultValue="True" Name="isTravel" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" />
            <asp:Parameter DefaultValue="1" Name="TranType" />
            <asp:SessionParameter DefaultValue="" Name="Status" SessionField="statusid" />
            <asp:SessionParameter Name="Payee" SessionField="Employee_Id" />
            <asp:SessionParameter Name="isForeignTravel" SessionField="isForeignTravel" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAccountCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_AccountCharged]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE ([CompanyId] = @CompanyId)">
        <SelectParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlSupDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_DocumentType] ORDER BY [Document_Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlUserOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT TOP (100) PERCENT wd.OrgRole_Id, wd.Sequence, uor.UserId, um.FullName FROM ITP_S_WorkflowDetails AS wd INNER JOIN ITP_S_SecurityUserOrgRoles AS uor ON wd.OrgRole_Id = uor.OrgRoleId INNER JOIN ITP_S_UserMaster AS um ON uor.UserId = um.EmpCode">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpenseClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification]"></asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlReimTranspo" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ReimTranspo] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlMiscTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_MiscTravelExp] ORDER BY [Type]"></asp:SqlDataSource>
    <br />
    <br />
    </asp:Content>
