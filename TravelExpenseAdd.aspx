<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="TravelExpenseAdd.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseAdd" %>

<%@ Register assembly="DevExpress.Web.Bootstrap.v22.2, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.Bootstrap" tagprefix="dx" %>

<%@ Register assembly="DevExpress.XtraReports.v22.2.Web.WebForms, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.XtraReports.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
    </style>

    <script src="Scripts/docviewer.js"></script>
    <script>
        function showQR() {
            LoadingPanel.Show();
            docPanel.EndCallback.AddHandler(function () {
                docPanel.EndCallback.ClearHandlers();
                LoadingPanel.Hide();
                reimbursePopup.Show();
            });
            docPanel.PerformCallback("HELO WORLD - 12345");
        }

        function CheckCurrency(s, e) {
            var currency = s.GetValue();

            $.ajax({
                type: "POST",
                url: "TravelExpenseAdd.aspx/ChangeCurrencyAJAX",
                data: JSON.stringify({ currency: currency }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    wfCallback.EndCallback.ClearHandlers();
                    handleExpCA(
                        response.d.expType,
                        response.d.totalca,
                        response.d.totalexp,
                        response.d.allTot,
                        response.d.totExpCA,
                        response.d.hasReim,
                        response.d.CA,
                        response.d.EXP
                    );
                    wfCallback.PerformCallback(response.d.totExpCA);
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function updateTotal(grid) {
            // Check if cpTotal is available
            if (grid.cpTotal) {
                // Update the TextBox with the total value
                totalExpTB.SetText(grid.cpTotal);
            }
        }

        function linkToRFP() {
            var rfpDoc = reimTB.GetText();

            $.ajax({
                type: "POST",
                url: "TravelExpenseAdd.aspx/RedirectToRFPDetailsAJAX",
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
                var purpose = purposeMemo.GetValue();
                var amount = lbl_dueTotal.GetValue();
                var chargedComp = chargedCB.GetValue();
                var chargedDept = chargedCB0.GetValue();
                var locbranch = locBranch.GetValue();
                var ford = fordCB.GetValue();
                var wf = drpdown_WF.GetValue();
                var fapwf = drpdown_FAPWF.GetValue();

                $.ajax({
                    type: "POST",
                    url: "TravelExpenseAdd.aspx/AddRFPReimburseAJAX",
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
                            window.location.href = 'TravelExpenseAdd.aspx';
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
                url: "TravelExpenseAdd.aspx/CheckReimburseValidationAJAX",
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
                url: "TravelExpenseAdd.aspx/CheckReimburseValidationAJAX",
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
            //LoadingPanel.Show();
            //var totexp = totalExpTB.GetText();
            //$.ajax({
            //    type: "POST",
            //    url: "TravelExpenseAdd.aspx/SaveTotExpAJAX",
            //    data: JSON.stringify({ totexp: totexp }),
            //    contentType: "application/json; charset=utf-8",
            //    dataType: "json",
            //    success: function (response) {
            //        // Handle success
            //        ExpenseGrid.PerformCallback();

            //        wfCallback.EndCallback.ClearHandlers();
            //        wfCallback.EndCallback.AddHandler(function () {
            //            handleExpCA(response.d.expType, response.d.totalca, response.d.totalexp, response.d.allTot, response.d.totExpCA, response.d.hasReim);

            //            locParticularsMemo.SetText('');
            //            travelDateCalendar.SetDate(null);
            //            totalExpTB.SetValue('');
            //            LoadingPanel.Hide();
            //            travelExpensePopup.Hide();
            //            //ExpenseGrid.Refresh();
            //        });
            //        wfCallback.PerformCallback(totexp);
                    
            //    },
            //    failure: function (response) {
            //        // Handle failure
            //    }
            //});
        }

        function handleExpCA(expType, totalca, totalexp, allTot, totExpCA, hasReim, CA, EXP) {
            var reimItem = ExpenseEditForm.GetItemByName('reimItem');
            var remItem = ExpenseEditForm.GetItemByName('remItem');
            var reimDetails = ExpenseEditForm.GetItemByName('reimDetails');
            var due_lbl = ExpenseEditForm.GetItemByName('due_lbl');

            if (hasReim) {
                reimItem.SetVisible(false);
                remItem.SetVisible(false);
                reimDetails.SetVisible(true);
            } else {
                reimDetails.SetVisible(false);

                if (EXP > CA) {
                    remItem.SetVisible(false);
                    reimItem.SetVisible(true);
                    due_lbl.SetCaption("Due To Employee");
                } else if (CA > EXP) {
                    reimItem.SetVisible(false);
                    remItem.SetVisible(true);
                    due_lbl.SetCaption("Due To Company");
                } else {
                    remItem.SetVisible(false);
                    reimItem.SetVisible(false);
                    due_lbl.SetCaption("Due To Company");
                }
            }

            lbl_caTotal.SetText(totalca);
            lbl_expenseTotal.SetText(totalexp);
            lbl_dueTotal.SetText(allTot);
            drpdown_expenseType.SetValue(expType);
        }

        async function ExpPopupClick(s, e) {
            if (!ASPxClientEdit.ValidateGroup("expAdd")) return;

            const locParticulars = locParticularsMemo.GetText();
            const travelDate = travelDateCalendar.GetDate();
            let totalExp = totalExpTB.GetValue();

            try {
                if (ASPxGridView22.batchEditApi.HasChanges()) {
                    // Await grid update before proceeding
                    await new Promise((resolve) => {
                        ASPxGridView22.UpdateEdit();
                        ASPxGridView22.EndCallback.AddHandler(function () {
                            ASPxGridView22.EndCallback.ClearHandlers();
                            totalExp = totalExpTB.GetValue();
                            resolve();
                        });
                    });
                }

                LoadingPanel.Show();

                const response = await $.ajax({
                    type: "POST",
                    url: "TravelExpenseAdd.aspx/AddTravelExpenseDetailsAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        locParticulars: locParticulars,
                        travelDate: travelDate,
                        totalExp: totalExp
                    })
                });

                if (response) {
                    ExpenseGrid.PerformCallback();

                    await new Promise((resolve) => {
                        wfCallback.EndCallback.ClearHandlers();
                        wfCallback.EndCallback.AddHandler(function () {
                            handleExpCA(
                                response.d.expType,
                                response.d.totalca,
                                response.d.totalexp,
                                response.d.allTot,
                                response.d.totExpCA,
                                response.d.hasReim,
                                response.d.CA,
                                response.d.EXP
                            );

                            locParticularsMemo.SetText('');
                            travelDateCalendar.SetDate(null);
                            totalExpTB.SetValue('');
                            LoadingPanel.Hide();
                            travelExpensePopup.Hide();

                            $('#toast-header').html('Success!');
                            $('#toast-body').html('Expense item added successfully.');
                            $('.toast').toast('show');
                            resolve();
                        });
                        wfCallback.PerformCallback(response.d.totExpCA);
                    });
                } else {
                    showToast("Failed!", "There's an error in adding the expense item.");
                }
            } catch (error) {
                console.error("Error:", error);
                LoadingPanel.Hide();
                showToast("Error!", "An unexpected error occurred.");
            }
        }

        function showToast(header, body) {
            $('#toast-header').html(header);
            $('#toast-body').html(body);
            $('.toast').toast('show');
        }

        //function ExpPopupClick(s, e) {
        //    if (ASPxClientEdit.ValidateGroup("expAdd")) {

        //        if (ASPxGridView22.batchEditApi.HasChanges()) {
        //            ASPxGridView22.UpdateEdit()

        //            // Handle the completion of the update
        //            ASPxGridView22.EndCallback.AddHandler(function () {
        //                ASPxGridView22.EndCallback.ClearHandlers();

        //                LoadingPanel.Show();
        //                var locParticulars = locParticularsMemo.GetText();
        //                var travelDate = travelDateCalendar.GetDate()
        //                var totalExp = totalExpTB.GetValue()

        //                $.ajax({
        //                    type: "POST",
        //                    url: "TravelExpenseAdd.aspx/AddTravelExpenseDetailsAJAX",
        //                    contentType: "application/json; charset=utf-8",
        //                    dataType: "json",
        //                    data: JSON.stringify({
        //                        locParticulars: locParticulars,
        //                        travelDate: travelDate,
        //                        totalExp: totalExp
        //                    }),
        //                    success: function (response) {
        //                        //Handle success
        //                        if (response) {
        //                            ExpenseGrid.PerformCallback();

        //                            wfCallback.EndCallback.ClearHandlers();
        //                            wfCallback.EndCallback.AddHandler(function () {
        //                                handleExpCA(response.d.expType, response.d.totalca, response.d.totalexp, response.d.allTot, response.d.totExpCA, response.d.hasReim);

        //                                locParticularsMemo.SetText('');
        //                                travelDateCalendar.SetDate(null);
        //                                totalExpTB.SetValue('');
        //                                LoadingPanel.Hide();
        //                                travelExpensePopup.Hide();
        //                                //ExpenseGrid.Refresh();

        //                                $('#toast-header').html('Success!');
        //                                $('#toast-body').html('Expense item added successfully.');
        //                                $('.toast').toast('show');
        //                            });
        //                            wfCallback.PerformCallback(response.d.totExpCA);
        //                        } else {
        //                            $('#toast-header').html('Failed!');
        //                            $('#toast-body').html("There's an error in adding the expense item.");
        //                            $('.toast').toast('show');
        //                        }
        //                    },
        //                    error: function (xhr, status, error) {
        //                        console.log("Error:", error);
        //                    }
        //                });
        //            });
        //        } else {
        //            LoadingPanel.Show();
        //            var locParticulars = locParticularsMemo.GetText();
        //            var travelDate = travelDateCalendar.GetDate()
        //            var totalExp = totalExpTB.GetValue()

        //            $.ajax({
        //                type: "POST",
        //                url: "TravelExpenseAdd.aspx/AddTravelExpenseDetailsAJAX",
        //                contentType: "application/json; charset=utf-8",
        //                dataType: "json",
        //                data: JSON.stringify({
        //                    locParticulars: locParticulars,
        //                    travelDate: travelDate,
        //                    totalExp: totalExp
        //                }),
        //                success: function (response) {
        //                    //Handle success
        //                    if (response) {
        //                        ExpenseGrid.PerformCallback();

        //                        wfCallback.EndCallback.ClearHandlers();
        //                        wfCallback.EndCallback.AddHandler(function () {
        //                            handleExpCA(response.d.expType, response.d.totalca, response.d.totalexp, response.d.allTot, response.d.totExpCA, response.d.hasReim);

        //                            locParticularsMemo.SetText('');
        //                            travelDateCalendar.SetDate(null);
        //                            totalExpTB.SetValue('');
        //                            LoadingPanel.Hide();
        //                            travelExpensePopup.Hide();
        //                            //ExpenseGrid.Refresh();

        //                            $('#toast-header').html('Success!');
        //                            $('#toast-body').html('Expense item added successfully.');
        //                            $('.toast').toast('show');
        //                        });
        //                        wfCallback.PerformCallback(response.d.totExpCA);
        //                    } else {
        //                        $('#toast-header').html('Failed!');
        //                        $('#toast-body').html("There's an error in adding the expense item.");
        //                        $('.toast').toast('show');
        //                    }
        //                },
        //                error: function (xhr, status, error) {
        //                    console.log("Error:", error);
        //                }
        //            });
        //        }
        //    }
        //}

        function calcExpenses(s, e) {
            CalculateTotal(s);
        }

        function CalculateTotal(grid) {
            var total = 0;

            // Loop through visible rows
            for (var i = 0; i < grid.GetVisibleRowsOnPage(); i++) {

                // Loop through all columns
                for (var j = 0; j < grid.GetColumnCount(); j++) {
                    var column = grid.GetColumn(j);

                    // Check for columns containing "Amount"
                    if (column.fieldName && column.fieldName.includes("Amount")) {
                        var cellValue = grid.batchEditApi.GetCellValue(i, column.fieldName);
                        if (cellValue) {
                            total += parseFloat(cellValue) || 0;
                        }
                    }
                }
            }

            // Update total in the TextBox
            totalExpTB.SetValue(total.toFixed(2));
        }

        function onToolbarItemClick(s, e) {
            if (e.item.name === "addCA") {
                loadPanel.Show();
                capopGrid.EndCallback.AddHandler(function () {
                    loadPanel.Hide();
                    caPopup.Show();
                });
                capopGrid.PerformCallback();
            }

            if (e.item.name === "addExpense") {
                loadPanel.Show();
                addExpCallback.EndCallback.AddHandler(function () {
                    locParticularsMemo.SetText('');
                    //travelDateCalendar.ClearSelection();
                    //travelDateCalendar.SetVisibleDate(new Date());
                    travelDateCalendar.SetDate(null);
                    totalExpTB.SetValue('00.00');

                    loadPanel.Hide();
                    travelExpensePopup.Show();
                });
                addExpCallback.PerformCallback("add");
            }

            if (e.item.name === "createCA") {
                window.open('RFPCreationPage.aspx', '_blank');
            }
        }

        function onCustomButtonClick(s, e) {
            if (e.buttonID == 'btnDownload') {
                LoadingPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";
                ViewDocument(fileId, appId)
            } else if (e.buttonID == 'btnEditExpDet') {
                var item_id = s.GetRowKey(e.visibleIndex);
                locParticularsMemo.SetValue('');
                travelDateCalendar.SetDate(null);
                totalExpTB.SetValue('');
                loadPanel.Show();
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
                url: "TravelExpenseAdd.aspx/RemoveFromExp_AJAX",
                data: JSON.stringify({
                    item_id: item_id,
                    btnCommand: btnCommand
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    //if (btnCommand == "btnRemoveCA") {
                    //    CAGrid.DeleteRow(CAGrid.GetFocusedRowIndex());
                    //    CAGrid.Refresh();
                    //} else if (btnCommand == "btnRemoveExp") {
                    //    ExpenseGrid.DeleteRow(ExpenseGrid.GetFocusedRowIndex());
                    //    ExpenseGrid.Refresh();
                    //}

                    //LoadingPanel.Hide();
                    //handleExpCA(response.d.expType, response.d.totalca, response.d.totalexp, response.d.allTot, response.d.totExpCA, response.d.hasReim);

                    //const toastMessages = {
                    //    btnRemoveCA: 'CA item has been removed successfully.',
                    //    btnRemoveExp: 'Expense item has been removed successfully.',
                    //    btnRemoveReim: 'Reimbursement item has been removed successfully.'
                    //};

                    //// Display toast for relevant commands
                    //if (toastMessages[btnCommand]) {
                    //    $('#toast-header').html('Success!');
                    //    $('#toast-body').html(toastMessages[btnCommand]);
                    //    $('.toast').toast('show'); // Show toast immediately (no setTimeout needed)
                    //}

                    if (btnCommand == "btnRemoveCA") {
                        CAGrid.PerformCallback();
                    } else if (btnCommand == "btnRemoveExp") {
                        ExpenseGrid.PerformCallback();
                    }

                    wfCallback.EndCallback.ClearHandlers();
                    wfCallback.EndCallback.AddHandler(function () {
                        LoadingPanel.Hide();
                        handleExpCA(
                            response.d.expType,
                            response.d.totalca,
                            response.d.totalexp,
                            response.d.allTot,
                            response.d.totExpCA,
                            response.d.hasReim,
                            response.d.CA,
                            response.d.EXP
                        );;

                        // Map button commands to their respective actions
                        const toastMessages = {
                            btnRemoveCA: 'CA item has been removed successfully.',
                            btnRemoveExp: 'Expense item has been removed successfully.',
                            btnRemoveReim: 'Reimbursement item has been removed successfully.'
                        };

                        // Display toast for relevant commands
                        if (toastMessages[btnCommand]) {
                            $('#toast-header').html('Success!');
                            $('#toast-body').html(toastMessages[btnCommand]);
                            $('.toast').toast('show'); // Show toast immediately (no setTimeout needed)
                        }
                    });

                    // Perform the callback
                    wfCallback.PerformCallback(response.d.totExpCA);
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
                            url: "TravelExpenseAdd.aspx/AddCA_AJAX",
                            data: JSON.stringify({ selectedValues: selectedValues }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                // Handle success
                                CAGrid.PerformCallback();

                                wfCallback.EndCallback.ClearHandlers();
                                wfCallback.EndCallback.AddHandler(function () {
                                    caPopup.Hide();
                                    LoadingPanel.Hide();
                                    handleExpCA(
                                        response.d.expType,
                                        response.d.totalca,
                                        response.d.totalexp,
                                        response.d.allTot,
                                        response.d.totExpCA,
                                        response.d.hasReim,
                                        response.d.CA,
                                        response.d.EXP
                                    );

                                    $('#toast-header').html('Success!');
                                    $('#toast-body').html('CA item(s) have been added successfully.');
                                    $('.toast').toast('show');
                                });
                                wfCallback.PerformCallback(response.d.totExpCA);
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

        function onDeptChanged() {
            var dept_id = dept_reim.GetValue();
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/CostCenterUpdateField",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ dept_id: dept_id }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response) {
                        costCenter_reim.SetValue(response.d);
                        costCenter_reim.Validate();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function onTravelClick() {
            var layoutControl = window["formRFP"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("LDOT");
                if (layoutItem) {
                    if (rdButton_Trav.GetValue() == true)
                        layoutItem.SetVisible(true);
                    else
                        layoutItem.SetVisible(false);
                }
            }
        }

        function ifComp_is_DLI() {
            var layoutControl = window["formRFP"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("WBS");
                if (layoutItem) {
                    if (drpdown_Company.GetValue() == "5")
                        layoutItem.SetVisible(true);
                    else
                        layoutItem.SetVisible(false);
                }
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
                url: "TravelExpenseAdd.aspx/SaveSubmitTravelExpenseAJAX",
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

        function onAmountChanged(pay) {
            var amount = rfpAmount_reim.GetValue();
            var comp_id = company_reim.GetValue();
            var payMethod = pay != null ? pay : 0;
            var payMethodTxt = reim_PayMethod.GetText();

            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/CheckMinAmountAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    comp_id: comp_id,
                    payMethod: payMethod
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response.d != 0 && amount > response.d) {
                        warning_txt.SetText("Amount entered is beyond " + payMethodTxt + " limit. Please choose different payment method.");
                        PetCashPopup.Show();
                        reim_PayMethod.SetValue("");
                        reim_PayMethod.Validate();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function onPayMethodChanged(pay) {
            onAmountChanged(pay);
        }

        async function viewExpDetailModal(expDetailID) {
            try {
                const response = await $.ajax({
                    type: "POST",
                    url: "TravelExpenseAdd.aspx/DisplayExpDetailsAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    cache: true,
                    data: JSON.stringify({ expDetailID: expDetailID })
                });

                const data = response.d;

                // Set up callback before updating UI
                addExpCallback.EndCallback.ClearHandlers();
                addExpCallback.EndCallback.AddHandler(function () {
                    locParticularsMemo.SetValue(data.locParticulars);
                    totalExpTB.SetValue(data.totalExp);
                    travelDateCalendar.SetDate(new Date(data.travelDate));

                    loadPanel.Hide();
                    travelExpensePopup.Show();
                });

                // Trigger the callback (acts as the "edit" event)
                addExpCallback.PerformCallback("edit");
            } catch (error) {
                console.error("Error:", error);
                loadPanel.Hide(); // Hide loader even if there's an error
            }
        }
        //function viewExpDetailModal(expDetailID) {
        //    $.ajax({
        //        type: "POST",
        //        url: "TravelExpenseAdd.aspx/DisplayExpDetailsAJAX",
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        data: JSON.stringify({
        //            expDetailID: expDetailID
        //        }),
        //        success: function (response) {
        //            addExpCallback.EndCallback.ClearHandlers();
        //            addExpCallback.EndCallback.AddHandler(function () {
        //                /*travelDateCalendar.ClearSelection();*/
        //                locParticularsMemo.SetValue(response.d.locParticulars);
        //                totalExpTB.SetValue(response.d.totalExp);
        //                //travelDateCalendar.SetVisibleDate(new Date(response.d.travelDate));
        //                //travelDateCalendar.SelectDate(new Date(response.d.travelDate));
        //                travelDateCalendar.SetDate(new Date(response.d.travelDate));

        //                loadPanel.Hide();
        //                travelExpensePopup.Show();
        //            });
        //            addExpCallback.PerformCallback("edit");
        //        },
        //        error: function (xhr, status, error) {
        //            console.log("Error:", error);
        //        }
        //    });
        //}

        function onGridRendered(s, e) {
            var footerRow = s.GetMainElement().querySelector('.dxgvFooterRow');

            if (footerRow)
                footerRow.style.color = 'red';
        }
    </script>
    <div class="conta" id="demoFabContent">

        <%--ADD REIMBURSEMENT--%>
        <div class="position-fixed bottom-0 right-0 p-3" style="z-index: 5; right: 0; bottom: 0;">
            <div id="liveToast" class="toast hide" data-bs-animation="true" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="2000">
                <div class="toast-header">
                    <strong id="toast-header" class="me-auto">Success</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div id="toast-body" class="toast-body">
                </div>
            </div>
        </div>
        <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>

        <dx:ASPxFormLayout ID="ExpenseEditForm" runat="server" Font-Bold="False" Height="144px" Width="100%" Style="margin-bottom: 0px" DataSourceID="SqlMain" ClientInstanceName="ExpenseEditForm" OnInit="ExpenseEditForm_Init" EnableTheming="True">
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
                        <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" ColumnSpan="2">
                            <Paddings PaddingBottom="25px" PaddingTop="25px" />
                            <Items>
                                <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top">
                                    <Items>
                                        <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" RowSpan="2">
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Employee Name" ColSpan="2" ColumnSpan="2" FieldName="Employee_Id">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="empnameCB" runat="server" AllowMouseWheel="False" ClientEnabled="False" ClientInstanceName="empnameCB" DataSourceID="SqlEmpName" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="FullName" ValueField="EmpCode" Width="55%">
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
                                                <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="Company_Id">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="companyCB" runat="server" ClientEnabled="False" ClientInstanceName="companyCB" DataSourceID="SqlCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="CompanyShortName" ValueField="WASSId" Width="100%">
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
                                                <dx:LayoutItem Caption="Workflow Department" ColSpan="1" FieldName="Dep_Code">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="departmentCB" runat="server" ClientEnabled="False" ClientInstanceName="departmentCB" DataSourceID="SqlDepartment" Font-Bold="True" Font-Size="Small" ReadOnly="True" TextField="DepCode" ValueField="ID" Width="100%">
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
                                                <dx:LayoutItem Caption="Charged To Company" ColSpan="1" FieldName="ChargedToComp">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="chargedCB" runat="server" ClientInstanceName="chargedCB" DataSourceID="SqlCompany" Font-Bold="True" Font-Size="Small" NullValueItemDisplayText="{0}" OnDataBound="chargedCB_DataBound" TextField="CompanyShortName" TextFormatString="{0}" ValueField="WASSId" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	locBranch.PerformCallback(s.GetValue());
               chargedCB0.PerformCallback(s.GetValue());
}" />
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Company" FieldName="CompanyShortName" Width="120px">
                                                                    </dx:ListBoxColumn>
                                                                    <dx:ListBoxColumn Caption="Company Description" FieldName="CompanyDesc" Width="280px">
                                                                    </dx:ListBoxColumn>
                                                                </Columns>
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
                                                <dx:LayoutItem Caption="Location/Branch" ColSpan="1" FieldName="LocBranch">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="locBranch" runat="server" ClientInstanceName="locBranch" DataSourceID="SqlLocBranch" Font-Bold="True" Font-Size="Small" OnCallback="locBranch_Callback" OnDataBound="locBranch_DataBound" TextField="Name" ValueField="ID" Width="100%">
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
                                                <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="ChargedToDept">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="chargedCB0" runat="server" ClientInstanceName="chargedCB0" DataSourceID="SqlDepartment" Font-Bold="True" Font-Size="Small" NullValueItemDisplayText="{0}" OnDataBound="chargedCB0_DataBound" TextField="DepDesc" TextFormatString="{1}" ValueField="ID" Width="100%" OnCallback="chargedCB0_Callback">
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Company" FieldName="Company_Code" Width="110px">
                                                                    </dx:ListBoxColumn>
                                                                    <dx:ListBoxColumn Caption="Dept Code" FieldName="DepCode" Width="100px">
                                                                    </dx:ListBoxColumn>
                                                                    <dx:ListBoxColumn Caption="Dept Description" FieldName="DepDesc" Width="280px">
                                                                    </dx:ListBoxColumn>
                                                                </Columns>
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
                                                                <ClientSideEvents SelectedIndexChanged="CheckCurrency" />
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
                                </dx:TabbedLayoutGroup>
                                <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top">
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
                                                            <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CAGrid" DataSourceID="sqlExpenseCA" Font-Size="Small" KeyFieldName="ID" OnCustomCallback="CAGrid_CustomCallback" OnRowDeleting="CAGrid_RowDeleting" Theme="MaterialCompact" Width="100%">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" ToolbarItemClick="onToolbarItemClick" />
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
                                                            <dx:ASPxGridView ID="ExpenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpenseGrid" DataSourceID="SqlExpDetails" Font-Size="Small" KeyFieldName="TravelExpenseDetail_ID" OnCustomCallback="ExpenseGrid_CustomCallback" Theme="MaterialCompact" Width="100%">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" ToolbarItemClick="onToolbarItemClick" />
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
                                                                <SettingsPager AlwaysShowPager="True">
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
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="ID" FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn Caption="Date" FieldName="TravelExpenseDetail_Date" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Location/Particulars" FieldName="LocParticulars" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="ENTERTAINMENT" FieldName="VAT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                        </PropertiesTextEdit>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="BUSINESS MEALS" FieldName="EWT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                        <PropertiesTextEdit DisplayFormatString="#,##0.00">
                                                                        </PropertiesTextEdit>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Account to be Charged" FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                        <PropertiesComboBox DataSourceID="sqlAccountCharged" TextField="GLAccount" ValueField="AccCharged_ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="CostCenter/IO/WBS" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                        <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="CostCenter" ValueField="CostCenter_ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewBandColumn Caption="FIXED ALLOW. &amp; MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
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
                                                                    <dx:GridViewBandColumn Caption="OTHER BUSINESS EXPENSES" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn Caption="Type" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Amount" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="TIN" FieldName="TravelExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataSpinEditColumn Caption="Total Expenses" FieldName="Total_Expenses" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="N" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataSpinEditColumn>
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
                                                            <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" Font-Size="Small" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="100%">
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
                                                                <SettingsLoadingPanel Mode="ShowOnStatusBar" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                        <EditFormSettings Visible="True" />
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
                                                                    <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="Open File">
                                                                                <Image IconID="pdfviewer_next_svg_16x16">
                                                                                </Image>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
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
                                        <dx:LayoutGroup Caption="WORKFLOW DETAILS" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None">
                                            <Paddings PaddingBottom="25px" />
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" />
                                            </GroupBoxStyle>
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
                                                                </SettingsCollapsing>
                                                                <ExpandBarTemplate>
                                                                    <div style="padding-right: 8px; padding-top: 4px;">
                                                                        <dx:ASPxLabel ID="toggleLabel" runat="server" ClientInstanceName="toggleLabel" Font-Bold="True" Font-Size="Small" Text="Show">
                                                                        </dx:ASPxLabel>
                                                                    </div>
                                                                </ExpandBarTemplate>
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server">
                                                                        <dx:ASPxCallbackPanel ID="wfCallback" runat="server" ClientInstanceName="wfCallback" OnCallback="wfCallback_Callback" Width="100%">
                                                                            <SettingsLoadingPanel Enabled="False" />
                                                                            <PanelCollection>
                                                                                <dx:PanelContent runat="server">
                                                                                    <dx:ASPxFormLayout ID="ASPxFormLayout8" runat="server" ColCount="2" ColumnCount="2" Width="100%">
                                                                                        <Items>
                                                                                            <dx:LayoutGroup Caption="LINE MANAGER WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="Box" ColCount="2" ColumnCount="2">
                                                                                                <Items>
                                                                                                    <dx:LayoutItem Caption="Workflow Compnany" ColSpan="1" Visible="False">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <CaptionSettings Location="Top" />
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutItem Caption="Workflow Department" ColSpan="1" Visible="False">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <CaptionSettings Location="Top" />
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutItem Caption="Workflow" ColSpan="2" ColumnSpan="2">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxComboBox ID="drpdown_WF" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_WF" DataSourceID="SqlWF" Font-Bold="True" Font-Size="Small" Height="39px" SelectedIndex="0" TextField="Name" ValueField="WF_Id" Width="100%">
                                                                                                                    <ClientSideEvents Init="function(s, e) {
	WFSequenceGrid.PerformCallback();
}" SelectedIndexChanged="function(s, e) {
	        OnWFChanged();
        }" />
                                                                                                                    <DropDownButton Visible="False">
                                                                                                                    </DropDownButton>
                                                                                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                                                    </ValidationSettings>
                                                                                                                    <DisabledStyle Font-Bold="True" ForeColor="#222222">
                                                                                                                    </DisabledStyle>
                                                                                                                </dx:ASPxComboBox>
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <Paddings PaddingBottom="20px" />
                                                                                                        <ParentContainerStyle Font-Size="Small">
                                                                                                        </ParentContainerStyle>
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" Theme="MaterialCompact" Width="100%">
                                                                                                                    <SettingsPopup>
                                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                                        </FilterControl>
                                                                                                                    </SettingsPopup>
                                                                                                                    <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                    <Columns>
                                                                                                                        <dx:GridViewBandColumn Caption="WORKFLOW SEQUENCE" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                                                            <HeaderStyle BackColor="White">
                                                                                                                            <Border BorderStyle="None" />
                                                                                                                            </HeaderStyle>
                                                                                                                            <Columns>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="OrgRole_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                                <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                            </Columns>
                                                                                                                        </dx:GridViewBandColumn>
                                                                                                                    </Columns>
                                                                                                                    <Styles>
                                                                                                                        <Header>
                                                                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                                                                        </Header>
                                                                                                                        <Cell>
                                                                                                                            <Paddings Padding="3px" />
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
                                                                                            <dx:LayoutGroup Caption="FAP WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="Box">
                                                                                                <Items>
                                                                                                    <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxComboBox ID="drpdown_FAPWF" runat="server" ClientEnabled="False" ClientInstanceName="drpdown_FAPWF" DataSourceID="SqlFAPWF2" Font-Bold="True" Font-Size="Small" Height="39px" SelectedIndex="0" TextField="Name" ValueField="WF_Id" Width="100%">
                                                                                                                    <ClientSideEvents Init="function(s, e) {
	WFSequenceGrid.PerformCallback();
}" SelectedIndexChanged="function(s, e) {
	        OnWFChanged();
        }" />
                                                                                                                    <SettingsLoadingPanel Enabled="False" />
                                                                                                                    <DropDownButton Visible="False">
                                                                                                                    </DropDownButton>
                                                                                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                                                    </ValidationSettings>
                                                                                                                    <DisabledStyle Font-Bold="True" ForeColor="#333333">
                                                                                                                    </DisabledStyle>
                                                                                                                </dx:ASPxComboBox>
                                                                                                            </dx:LayoutItemNestedControlContainer>
                                                                                                        </LayoutItemNestedControlCollection>
                                                                                                        <Paddings PaddingBottom="20px" />
                                                                                                        <ParentContainerStyle Font-Size="Small">
                                                                                                        </ParentContainerStyle>
                                                                                                    </dx:LayoutItem>
                                                                                                    <dx:LayoutItem Caption="" ColSpan="1">
                                                                                                        <LayoutItemNestedControlCollection>
                                                                                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                                                                                <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" Theme="MaterialCompact" Width="100%">
                                                                                                                    <SettingsEditing Mode="Batch">
                                                                                                                    </SettingsEditing>
                                                                                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                                                                    <SettingsPopup>
                                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                                        </FilterControl>
                                                                                                                    </SettingsPopup>
                                                                                                                    <SettingsLoadingPanel Mode="Disabled" />
                                                                                                                    <Columns>
                                                                                                                        <dx:GridViewBandColumn Caption="FAP WORKFLOW SEQUENCE" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                            <HeaderStyle BackColor="White">
                                                                                                                            <Border BorderStyle="None" />
                                                                                                                            </HeaderStyle>
                                                                                                                            <Columns>
                                                                                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                                                    <PropertiesComboBox TextFormatString="{0}" ValueField="TerritoryID">
                                                                                                                                        <Columns>
                                                                                                                                            <dx:ListBoxColumn Caption="Territory" FieldName="TerritoryDescription">
                                                                                                                                            </dx:ListBoxColumn>
                                                                                                                                            <dx:ListBoxColumn Caption="Region" FieldName="RegionID">
                                                                                                                                            </dx:ListBoxColumn>
                                                                                                                                        </Columns>
                                                                                                                                    </PropertiesComboBox>
                                                                                                                                </dx:GridViewDataComboBoxColumn>
                                                                                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                                </dx:GridViewDataTextColumn>
                                                                                                                            </Columns>
                                                                                                                        </dx:GridViewBandColumn>
                                                                                                                    </Columns>
                                                                                                                    <Styles>
                                                                                                                        <Header>
                                                                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                                                                        </Header>
                                                                                                                        <Cell>
                                                                                                                            <Paddings Padding="3px" />
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
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
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
                                                <dx:ASPxGridView ID="capopGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="capopGrid" DataSourceID="sqlRFPMainCA" Font-Size="Smaller" KeyFieldName="ID" OnCustomCallback="capopGrid_CustomCallback" Width="100%" EnableTheming="True" Theme="MaterialCompact">
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
                                                        <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="IO No." FieldName="IO_Num" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn Caption="Last Day of Transaction" FieldName="LastDayTransact" ShowInCustomizationForm="True" VisibleIndex="13" Visible="False">
                                                            <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
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
                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                                            <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="4" Visible="False">
                                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="5" Visible="False">
                                                            <PropertiesComboBox DataSourceID="sqlDept" TextField="DepCode" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="10">
                                                            <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
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
                                                        <dx:GridViewDataComboBoxColumn Caption="Classification" FieldName="Classification_Type_Id" ShowInCustomizationForm="True" VisibleIndex="6">
                                                            <PropertiesComboBox DataSourceID="SqlExpenseClassification" TextField="ClassificationName" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
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

        <%-- ADD EXPENSE POPUP--%>

        <%--ADD REIMBURSEMENT--%>
        <dx:ASPxPopupControl ID="reimbursePopup" runat="server" FooterText="" HeaderText="View QR Code" Width="1146px" ClientInstanceName="reimbursePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="Fade" Maximized="True" ScrollBars="Vertical">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('reimDiv')
            }" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxCallbackPanel ID="docPanel" runat="server" ClientInstanceName="docPanel" Width="100%" OnCallback="docPanel_Callback">
                        <PanelCollection>
                            <dx:PanelContent runat="server">
                                <dx:ASPxWebDocumentViewer ID="ASPxWebDocumentViewer1" runat="server" ClientInstanceName="ASPxWebDocumentViewer1" DisableHttpHandlerValidation="False">
                                </dx:ASPxWebDocumentViewer>
                            </dx:PanelContent>
                        </PanelCollection>
                    </dx:ASPxCallbackPanel>
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
                    <dx:ASPxCallbackPanel ID="addExpCallback" runat="server" ClientInstanceName="addExpCallback" OnCallback="addExpCallback_Callback">
                        <Paddings Padding="0px" />
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
                                                            <dx:ASPxButton ID="popupSubmitBtn" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                        <dx:LayoutGroup Caption="" ColCount="5" ColSpan="1" ColumnCount="5" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                            <Paddings PaddingTop="20px" PaddingLeft="0px" PaddingRight="0px" />
                                            <Items>
                                                <dx:LayoutItem Caption="Date" ColSpan="1" VerticalAlign="Top" Width="20%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="travelDateCalendar" runat="server" ClientInstanceName="travelDateCalendar" Width="100%" Font-Bold="True" Height="40px" Theme="MaterialCompact">
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
                                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                    <ErrorImage IconID="outlookinspired_highimportance_svg_16x16">
                                                                    </ErrorImage>
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                    <Paddings PaddingBottom="20px" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Location/Particulars" ColSpan="2" VerticalAlign="Top" Width="20%" ColumnSpan="2">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxMemo ID="locParticularsMemo" runat="server" ClientInstanceName="locParticularsMemo" Width="100%" Font-Bold="True" Theme="MaterialCompact">
                                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="expAdd">
                                                                    <ErrorImage IconID="outlookinspired_highimportance_svg_16x16">
                                                                    </ErrorImage>
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                            </dx:ASPxMemo>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                    <Paddings PaddingBottom="20px" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" RowSpan="2" VerticalAlign="Top" Visible="False">
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxGridView ID="reimTranGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="reimTranGrid" CssClass="shadow-sm" Font-Italic="False" KeyFieldName="ReimTranspo_ID" OnRowDeleting="reimTranGrid_RowDeleting" OnRowInserting="reimTranGrid_RowInserting">
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
                                                                                    <dx:GridViewDataTextColumn FieldName="ReimTranspo_ID" ShowInCustomizationForm="True" VisibleIndex="2" Visible="False">
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
                                                                    <dx:ASPxGridView ID="fixedAllowGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="fixedAllowGrid" CssClass="shadow-sm" KeyFieldName="FixedAllow_ID" OnRowDeleting="fixedAllowGrid_RowDeleting" OnRowInserting="fixedAllowGrid_RowInserting">
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
                                                                    <dx:ASPxGridView ID="miscTravelGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="miscTravelGrid" CssClass="shadow-sm" KeyFieldName="MiscTravelExp_ID" OnRowDeleting="miscTravelGrid_RowDeleting" OnRowInserting="miscTravelGrid_RowInserting">
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
                                                                    <dx:ASPxGridView ID="otherBusGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="otherBusGrid" CssClass="shadow-sm" KeyFieldName="OtherBusinessExp_ID" OnRowDeleting="otherBusGrid_RowDeleting" OnRowInserting="otherBusGrid_RowInserting">
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
                                                                    <dx:ASPxGridView ID="entertainmentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="entertainmentGrid" CssClass="shadow-sm" KeyFieldName="Entertainment_ID" OnRowDeleting="entertainmentGrid_RowDeleting" OnRowInserting="entertainmentGrid_RowInserting">
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
                                                        <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Top">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxGridView ID="busMealsGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="busMealsGrid" CssClass="shadow-sm" KeyFieldName="BusinessMeal_ID" OnRowDeleting="busMealsGrid_RowDeleting" OnRowInserting="busMealsGrid_RowInserting">
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
                                                    </Items>
                                                </dx:LayoutGroup>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                </dx:EmptyLayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="" ColSpan="5" VerticalAlign="Top" Width="80%" ColumnSpan="5">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ASPxGridView22" runat="server" AutoGenerateColumns="False" EnableTheming="True" Font-Size="Small" OnRowDeleting="ASPxGridView22_RowDeleting" OnRowInserting="ASPxGridView22_RowInserting" Theme="MaterialCompact" Width="100%" KeyFieldName="TravelExpenseDetailMap_ID" OnRowUpdating="ASPxGridView22_RowUpdating" ClientInstanceName="ASPxGridView22" OnCustomColumnDisplayText="ASPxGridView22_CustomColumnDisplayText">
                                                                <ClientSideEvents BatchEditEndEditing="calcExpenses" BatchEditRowValidating="calcExpenses" BatchEditStartEditing="calcExpenses" KeyPress="calcExpenses" BatchEditChangesSaving="calcExpenses
" BatchEditRowInserting="calcExpenses
" EndCallback="calcExpenses

" />
                                                                <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                </SettingsAdaptivity>
                                                                <SettingsEditing Mode="Batch" NewItemRowPosition="Bottom">
                                                                    <BatchEditSettings StartEditAction="Click" />
                                                                </SettingsEditing>
                                                                <Settings ShowStatusBar="Hidden" />
                                                                <SettingsBehavior AllowDragDrop="False" />
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
                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="35px">
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                        <CellStyle HorizontalAlign="Center">
                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                        </CellStyle>
                                                                        <FooterCellStyle HorizontalAlign="Center">
                                                                        </FooterCellStyle>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                        <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                        <Columns>
                                                                            <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="3" FieldName="ReimTranspo_Type1" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID" AllowNull="True">
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
                                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom" ClientInstanceName="ReimTranspo_Amount1">
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
                                                                            <dx:GridViewDataComboBoxColumn Caption="  Type" FieldName="ReimTranspo_Type2" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" Width="140px">
                                                                                <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID" AllowNull="True">
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
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                            <dx:GridViewDataSpinEditColumn Caption=" Amount" FieldName="ReimTranspo_Amount2" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3" Width="90px">
                                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
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
                                                                            <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="2" FieldName="ReimTranspo_Type3" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4" Width="140px">
                                                                                <PropertiesComboBox DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID" AllowNull="True">
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
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                            <dx:GridViewDataSpinEditColumn Caption="Amount" CellRowSpan="2" FieldName="ReimTranspo_Amount3" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5" Width="90px">
                                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
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
                                                                    <dx:GridViewBandColumn Caption="FIXED ALLOWANCES" ShowInCustomizationForm="True" VisibleIndex="2">
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
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                            <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
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
                                                                    <dx:GridViewBandColumn Caption="ENTERTAINMENT" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="4">
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
                                                                    <dx:GridViewBandColumn Caption="BUSINESS MEALS" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="5">
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
                                                                    <dx:GridViewBandColumn Caption="OTHER BUS. EXPENSES" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                                        <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                        <Columns>
                                                                            <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="OtherBus_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                <PropertiesComboBox ClientInstanceName="otherBusType" DataSourceID="SqlOtherBusExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID" AllowNull="True">
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
                                                                                    <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="OtherBus_Specify" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesMemoEdit ClientInstanceName="OtherBusinessExpSpecify">
                                                                                            <ClientSideEvents Init="function(s, e) {
	OtherBusinessExpSpecify.SetVisible(false);
}
" />
                                                                                        </PropertiesMemoEdit>
                                                                                        <HeaderStyle>
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
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
                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                </HeaderStyle>
                                                                                <CellStyle>
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                    <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataSpinEditColumn>
                                                                        </Columns>
                                                                    </dx:GridViewBandColumn>
                                                                    <dx:GridViewBandColumn Caption="MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                        <Columns>
                                                                            <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravel_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                <PropertiesComboBox ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID" AllowNull="True" DropDownRows="9">
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
                                                                <Paddings PaddingBottom="25px" />
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Supporting Documents" ColSpan="5" ColumnSpan="5" RowSpan="2" VerticalAlign="Top">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxUploadControl ID="TraUploadController" runat="server" AutoStartUpload="True" ClientInstanceName="TraUploadController" Font-Size="Small" OnFilesUploadComplete="TraUploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="100%">
                                                                <ClientSideEvents FilesUploadComplete="function(s, e) {
	TraDocuGrid.Refresh();
}
" />
                                                                <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                </AdvancedModeSettings>
                                                                <Paddings PaddingBottom="10px" />
                                                                <TextBoxStyle Font-Size="Small" />
                                                            </dx:ASPxUploadControl>
                                                            <dx:ASPxGridView ID="TraDocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="TraDocuGrid" Font-Size="Small" KeyFieldName="ID" OnRowDeleting="TraDocuGrid_RowDeleting" OnRowUpdating="TraDocuGrid_RowUpdating" Width="100%" Theme="MaterialCompact" OnCellEditorInitialize="TraDocuGrid_CellEditorInitialize">
                                                                <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                <SettingsEditing Mode="Inline">
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
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <EditFormSettings Visible="True" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" VisibleIndex="5" ReadOnly="True">
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
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Top" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" Visible="False">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="2">
                                                                <TabPages>
                                                                    <dx:TabPage Text="REIMBURSABLE TRANSPORTATION">
                                                                        <ContentCollection>
                                                                            <dx:ContentControl runat="server">
                                                                                <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="ASPxGridView8" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="ASPxGridView13" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="ASPxGridView14" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="ASPxGridView15" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                                                            <dx:ASPxGridView ID="ASPxGridView16" runat="server" AutoGenerateColumns="False" Width="100%">
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
                                                                    <dx:ASPxGridView ID="ASPxGridView7" runat="server" AutoGenerateColumns="False" Width="100%">
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

        <dx:ASPxPopupControl ID="expensePopup_edit" runat="server" FooterText="" HeaderText="Edit Expense Item" Width="1200px" ClientInstanceName="expensePopup_edit" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('expDiv')
            }" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <div id="expDiv">
                        <dx:ASPxFormLayout ID="ASPxFormLayout7" runat="server" Width="100%">
                            <Items>
                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxButton ID="ASPxButton5" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                                    <dx:ASPxButton ID="ASPxButton6" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                        <ClientSideEvents Click="function(s, e) {
                     ASPxClientEdit.ClearEditorsInContainerById('expDiv');
                     expensePopup_edit.Hide();
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
                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="None" Width="60%" HorizontalAlign="Center">
                                            <Items>
                                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                                    <Items>
                                                        <dx:LayoutItem Caption="Particulars" ColSpan="1" Width="50%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxTextBox ID="particulars_edit" runat="server" ClientInstanceName="particulars_edit" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Supplier" ColSpan="1" Width="50%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxTextBox ID="supplier_edit" runat="server" ClientInstanceName="supplier_edit" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Vendor TIN" ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxTextBox ID="tin_edit" runat="server" ClientInstanceName="tin_edit" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxTextBox ID="invoiceOR_edit" runat="server" ClientInstanceName="invoiceOR_edit" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Gross Amount" ColSpan="1" Width="50%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxSpinEdit ID="grossAmount_edit" runat="server" AllowNull="False" ClientInstanceName="grossAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%">
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
                                                    </Items>
                                                </dx:LayoutGroup>
                                                <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                                    <Items>
                                                        <dx:LayoutItem Caption="Date" ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxDateEdit ID="dateAdded_edit" runat="server" ClientInstanceName="dateAdded_edit" DisplayFormatString="MMMM dd, yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Account to be Charged" ClientVisible="False" ColSpan="1" Width="50%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxComboBox ID="accountCharged_edit" runat="server" ClientInstanceName="accountCharged_edit" DataSourceID="sqlAccountCharged" Font-Bold="True" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="GLAccount" TextFormatString="{1}" ValueField="AccCharged_ID" Width="100%">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn FieldName="GLAccount" Width="90px">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn FieldName="TransactionType" Width="500px">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Cost Center/IO/WBS" ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxComboBox ID="costCenter_edit" runat="server" ClientInstanceName="costCenter_edit" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" OnCallback="costCenter_Callback" TextField="CostCenter" ValueField="CostCenter_ID" Width="100%">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn FieldName="CostCenter" Width="100px">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn FieldName="Department" Width="220px">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                                        <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxSpinEdit ID="netAmount_edit" runat="server" ClientInstanceName="netAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Number="0.00" ReadOnly="True" Width="100%">
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
                                                        <dx:LayoutItem Caption="VAT" ColSpan="1">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxSpinEdit ID="vat_edit" runat="server" ClientInstanceName="vat_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Number="0.00" ReadOnly="True" Width="100%">
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
                                                        <dx:LayoutItem Caption="EWT" ColSpan="1" HorizontalAlign="Left" Width="55%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxSpinEdit ID="ewt_edit" runat="server" ClientInstanceName="ewt_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Number="0.00" ReadOnly="True" Width="100%">
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
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:LayoutGroup>
                                        <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                        </dx:EmptyLayoutItem>
                                        <dx:LayoutItem ColSpan="2" ColumnSpan="2" ShowCaption="False" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ExpAllocGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid_edit" DataSourceID="SqlExpMap" KeyFieldName="ExpenseDetailMap_ID" Width="100%">
                                                        <SettingsPager Mode="EndlessPaging">
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="Inline">
                                                        </SettingsEditing>
                                                        <Settings GridLines="None" ShowFooter="True" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsText CommandDelete="Remove" />
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="160px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="CostCenter" ValueField="CostCenter_ID">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Cost Center" FieldName="CostCenter">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Department" FieldName="Department" Width="300px">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                </PropertiesSpinEdit>
                                                            </dx:GridViewDataSpinEditColumn>
                                                        </Columns>
                                                        <TotalSummary>
                                                            <dx:ASPxSummaryItem DisplayFormat="Total: #,#00.00" FieldName="NetAmount" ShowInColumn="Allocated Amount" ShowInGroupFooterColumn="Allocated Amount" SummaryType="Sum" Tag="Total" />
                                                        </TotalSummary>
                                                        <Styles>
                                                            <Footer BackColor="#66FFCC" Font-Bold="True" Font-Overline="False" Font-Size="Medium">
                                                            </Footer>
                                                        </Styles>
                                                    </dx:ASPxGridView>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                        </dx:EmptyLayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                            </Items>
                        </dx:ASPxFormLayout>
                    </div>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>
    </div>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact" Text=""></dx:ASPxLoadingPanel>

    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseMain] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlEmpName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL) ORDER BY CompanyDesc ASC"></asp:SqlDataSource>
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
    <asp:SqlDataSource ID="sqlExpenseCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([Exp_ID] = @Exp_ID) AND ([Status] = @Status) AND ([isTravel] = @isTravel)) ">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
            <asp:SessionParameter DefaultValue="" Name="Exp_ID" SessionField="TravelExp_Id" Type="Int32" />
            <asp:SessionParameter DefaultValue="" Name="Status" SessionField="statusid" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="isTravel" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([User_ID] = @User_ID) AND ([IsExpenseCA] = @IsExpenseCA) AND ([TranType] = @TranType) AND ([Status] = @Status) AND ([Exp_ID] IS NULL) AND ([Payee] = @Payee) AND ([isForeignTravel] = @isForeignTravel))">
        <SelectParameters>
            <asp:SessionParameter Name="User_ID" SessionField="userID" Type="String" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" />
            <asp:Parameter DefaultValue="1" Name="TranType" />
            <asp:SessionParameter DefaultValue="" Name="Status" SessionField="statusid" />
            <asp:SessionParameter Name="Payee" SessionField="Employee_Id" />
            <asp:SessionParameter Name="isForeignTravel" SessionField="isForeignTravel" />
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
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [ID], [FileName], [FileAttachment], [Description], [DateUploaded], [FileSize] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID) AND ([User_ID] = @User_ID) AND ([DocType_Id] = @DocType_Id))" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
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
            <asp:Parameter DefaultValue="1018" Name="DocType_Id" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="original_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [vw_ACCEDE_I_TravelDocsPerDate] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID))">
        <SelectParameters>
            <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
            <asp:SessionParameter Name="Doc_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
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
    <asp:SqlDataSource ID="SqlExpenseClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification]">
    </asp:SqlDataSource>
     
    <asp:SqlDataSource ID="SqlLocBranch" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" />
        </SelectParameters>
    </asp:SqlDataSource>
     
     <asp:SqlDataSource ID="SqlDepartmentEdit" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId) AND ([CompanyId] = @CompanyId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
            <asp:Parameter DefaultValue="" Name="CompanyId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
     
     <asp:SqlDataSource ID="SqlSupDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_DocumentType] ORDER BY [Document_Type]">
    </asp:SqlDataSource>
    </asp:Content>
