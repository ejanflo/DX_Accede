<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeExpenseReportEdit1.aspx.cs" Inherits="DX_WebTemplate.AccedeExpenseReportEdit1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
   
    
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
        #scrollablecontainer1, #scrollablecontainer3, #scrollablecontainer2 {
            overflow: auto;
            height: 600px;
            border: 1px solid #ccc; 
            padding: 10px; 
        }
        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
        .exp-link-container {
            display: flex;
            align-items: center; /* Vertically aligns items in the middle */
        }

        .exp-link-textbox {
            flex-grow: 1; /* Allows the textbox to grow and take available space */
            margin-right: 10px; /* Space between the textbox and button */
            display: inline-block;
        }

        .edit-button div.dxb{
            display: inline-block;
            padding: 5px 10px; /* Adjust to desired size */
            background-color: #006838; /* Example background color */
            border: 1px #006838; /* Example border */
            border-radius: 4px; /* Rounded corners */
            vertical-align: middle;
        }

        .fin-edit-btn div.dxb{
            
            padding: 5px 10px;
        }
    </style>
    <script>
       function onToolbarItemClick(s, e) {
           if (e.item.name === "addCA") {
               caPopup.Show();
               capopGrid.PerformCallback();
           } 

           if (e.item.name === "addExpense") {

               costCenter.SetValue(drpdown_CostCenter.GetValue());
               expensePopup1.Show();

           } 
        }

        function onCustomButtonClick(s, e) {
            
            if (e.buttonID == 'btnEditExpDet') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewExpDetailModal(item_id);
            } else {
                var confirmText = "";
                if (e.buttonID == 'btnRemoveCA') {
                    confirmText = "Are you sure you want to remove this CA from your expense report?";
                }

                if (e.buttonID == 'btnRemoveExp') {
                    confirmText = "Are you sure you want to remove this Expense from your expense report?";
                }

                if (e.buttonID == 'btnRemoveReim') {
                    confirmText = "Are you sure you want to remove this Reimbursement from your expense report?";
                }

                var confirmRmv = confirm(confirmText);
                if (confirmRmv) {
                    LoadingPanel.Show();

                    var item_id = s.GetRowKey(e.visibleIndex);
                    var btnCommand = e.buttonID;

                    removeFromExp(item_id, btnCommand);

                }
            }
        }

        function OnCTDeptChanged(dept_id) {
            drpdown_CostCenter.PerformCallback(exp_CTCompany.GetValue() + "|" + dept_id);
            costCenter.PerformCallback(exp_CTCompany.GetValue());
            costCenter_edit.PerformCallback(exp_CTCompany.GetValue());
        }

        function OnDeptChanged(dept_id) {
            drpdown_WF.PerformCallback(dept_id);
            WFSequenceGrid.PerformCallback(dept_id);
            //exp_costCenter.PerformCallback();
            //$.ajax({
            //    type: "POST",
            //    url: "AccedeExpenseReportDashboard.aspx/GetCosCenterFrmDeptAJAX",
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
            //drpdown_CostCenter.PerformCallback(dept_id);
        }

        function removeFromExp(item_id, btnCommand) {
            SaveExpenseReport("Save2");
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/RemoveFromExp_AJAX",
                data: JSON.stringify({
                    item_id: item_id,
                    btnCommand: btnCommand
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    LoadingPanel.SetText("Updating document&hellip;");
                    LoadingPanel.Show();
                    window.location.href = 'AccedeExpenseReportEdit1.aspx';
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

       function AddExpCA() {
           if (capopGrid.GetSelectedRowCount() > 0) {
               LoadingPanel.Show();
               var selectedIds = capopGrid.GetSelectedFieldValues("ID", function (selectedValues) {
                   console.log("Selected IDs: ", selectedValues);
                   if (selectedValues.length > 0) {
                       caPopup.Hide();
                       $.ajax({
                           type: "POST",
                           url: "AccedeExpenseReportEdit1.aspx/AddCA_AJAX",
                           data: JSON.stringify({ selectedValues: selectedValues }),
                           contentType: "application/json; charset=utf-8",
                           dataType: "json",
                           success: function (response) {
                               // Handle success
                               LoadingPanel.SetText("Updating document&hellip;");
                               LoadingPanel.Show();
                               window.location.href = 'AccedeExpenseReportEdit1.aspx';
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

       function AddExpDetails() {
           if (ASPxClientEdit.ValidateGroup('PopupSubmit')) {
              
               var dateAdd = dateAdded.GetValue();
               var tin_no = tin.GetValue() != null ? tin.GetValue() : "";
               var invoice_no = invoiceOR.GetValue() != null ? invoiceOR.GetValue() : "";
               var cost_center = costCenter.GetValue() != null ? costCenter.GetValue() : "";
               var gross_amount = grossAmount.GetValue() != 0.00 ? grossAmount.GetValue() : "0";
               var net_amount = netAmount.GetValue() != 0.00 ? netAmount.GetValue() : "0";
               var supp = supplier.GetValue() != null ? supplier.GetValue() : "";
               var particu = particulars.GetValue() != null ? particulars.GetValue() : "0";
               var acctCharge = accountCharged.GetValue() != null ? accountCharged.GetValue() : "0";
               var vat_amnt = vat.GetValue() != 0.00 ? vat.GetValue() : "0";
               var ewt_amnt = ewt.GetValue() != 0.00 ? ewt.GetValue() : "0";
               var currency = exp_Currency.GetValue() != null ? exp_Currency.GetValue() : "";
               var io = IO.GetValue() != null ? IO.GetValue() : "";
               var wbs = WBS.GetValue() != null ? WBS.GetValue() : "";
               SaveExpenseReport("Save2");
               LoadingPanel.Show();

               $.ajax({
                   type: "POST",
                   url: "AccedeExpenseReportEdit1.aspx/AddExpDetailsAJAX",
                   data: JSON.stringify({
                       dateAdd: dateAdd,
                       tin_no: tin_no,
                       invoice_no: invoice_no,
                       cost_center: cost_center,
                       gross_amount: gross_amount,
                       net_amount: net_amount,
                       supp: supp,
                       particu: particu,
                       acctCharge: acctCharge,
                       vat_amnt: vat_amnt,
                       ewt_amnt: ewt_amnt,
                       currency: currency,
                       io: io,
                       wbs: wbs

                   }),
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (response) {
                       // Handle success
                       if (response.d == "success") {
                           LoadingPanel.SetText("Updating document&hellip;");
                           LoadingPanel.Show();
                           window.location.href = 'AccedeExpenseReportEdit1.aspx';
                       } else {
                           alert(response.d);
                           LoadingPanel.Hide();
                       }
                       
                   },
                   failure: function (response) {
                       // Handle failure
                   }
               });
           }
       }

       function onTravelClick() {
           var layoutControl = window["formRFP"];
           if (layoutControl) {
               var layoutItem = layoutControl.GetItemByName("LDOT");
               if (layoutItem) {

                   if (rdButton_Trav.GetValue() == true) {
                       layoutItem.SetVisible(true);
                   } else {
                       layoutItem.SetVisible(false);
                   }


               }
           }
       }

       function ifComp_is_DLI() {
           var layoutControl = window["formRFP"];
           if (layoutControl) {
               var layoutItem = layoutControl.GetItemByName("WBS");
               if (layoutItem) {

                   if (drpdown_Company.GetValue() == "5") {
                       layoutItem.SetVisible(true);
                   } else {
                       layoutItem.SetVisible(false);
                   }


               }
           }

           exp_Department.PerformCallback();
        }

        function AddReimbursement(stat) {

            if (ASPxClientEdit.ValidateGroup('submitValid')) {
                var comp_id = exp_Company.GetValue();
                var payMethod = drpdown_payType.GetValue();
                var purpose = memo_Purpose.GetValue();
                var dept_id = exp_Department.GetValue();
                var cCenter = drpdown_CostCenter.GetValue();
                var io = io_reim.GetValue() != null ? io_reim.GetValue() : "";
                var payee = exp_EmpId.GetValue();
                var acctCharge = drpdown_ExpCategory.GetValue();
                var amount = rfpAmount_reim.GetValue();
                var remarks = remarks_reim.GetValue() != null ? remarks_reim.GetValue() : "";
                var isTravelrfp = rdButton_Trav_exp.GetValue();
                var wbs = wbs_reim.GetValue() != null ? wbs_reim.GetValue() : "";
                var currency = exp_Currency.GetValue();
                var classification = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";
                var CTComp_id = exp_CTCompany.GetValue();
                var CTDept_id = exp_CTDepartment.GetValue();

                SaveExpenseReport("Save2");
                console.log(dept_id);

                $.ajax({
                    type: "POST",
                    url: "AccedeExpenseReportEdit1.aspx/AddRFPReimburseAJAX",
                    data: JSON.stringify({
                        comp_id: comp_id,
                        payMethod: payMethod,
                        purpose: purpose,
                        dept_id: dept_id,
                        cCenter: cCenter,
                        io: io,
                        payee: payee,
                        acctCharge: acctCharge,
                        amount: amount,
                        remarks: remarks,
                        isTravelrfp: isTravelrfp,
                        wbs: wbs,
                        currency: currency,
                        classification: classification,
                        CTComp_id: CTComp_id,
                        CTDept_id: CTDept_id

                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        // Handle success
                        if (response.d == true) {
                            if (stat == 0) {
                                LoadingPanel.SetText("Updating document&hellip;");
                                LoadingPanel.Show();
                                SaveExpenseReport("SaveReimburse");
                            } else {
                                console.log("success add reim")
                            }
                            
                            //window.location.href = 'AccedeExpenseReportEdit1.aspx';
                        } else {
                            LoadingPanel.SetText("Error adding reimbursement!");
                            LoadingPanel.Show();
                            window.location.href = 'AccedeExpenseReportEdit1.aspx';
                        }
                    },
                    failure: function (response) {
                        // Handle failure
                        console.log("Error yawa:" + response);
                    }
                });

            }

        }

        function SaveExpenseReport(btn) {
            var dateFile = date_dateFiled.GetValue();
            var repName = exp_EmpId.GetValue();
            var comp_id = exp_Company.GetValue();
            var expType = drpdown_expenseType.GetValue();
            var expCat = drpdown_ExpCategory.GetValue();
            var purpose = memo_Purpose.GetValue();
            var trav = rdButton_Trav_exp.GetValue();
            var wf = drpdown_WF.GetValue();
            var fapwf = drpdwn_FAPWF.GetValue();
            //var remarks = memo_remarks.GetValue();
            var currency = exp_Currency.GetValue();
            var department = exp_Department.GetValue();
            var payType = drpdown_payType.GetValue();
            var classification = drpdown_classification.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var CTCompany_id = exp_CTCompany.GetValue();
            var CTDept_id = exp_CTDepartment.GetValue();
            var AR = txt_AR.GetValue() != null ? txt_AR.GetValue() : "";
            var compLoc = exp_CompLocation.GetValue() != null ? exp_CompLocation.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/UpdateExpenseAJAX",
                data: JSON.stringify({
                    dateFile: dateFile,
                    repName: repName,
                    comp_id: comp_id,
                    expType: expType,
                    expCat: expCat,
                    purpose: purpose,
                    trav: trav,
                    wf: wf,
                    fapwf: fapwf,
                    //remarks: remarks,
                    currency: currency,
                    department: department,
                    payType: payType,
                    btn: btn,
                    classification: classification,
                    costCenter: costCenter,
                    CTCompany_id: CTCompany_id,
                    CTDept_id: CTDept_id,
                    AR: AR,
                    compLoc: compLoc

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    if (response.d == "success") {
                        if (btn == "SaveReimburse") {
                            window.location.href = 'AccedeExpenseReportEdit1.aspx';
                        } else if (btn == "CreateSubmit") {
                            AddReimbursement(1);
                            LoadingPanel.SetText("Expense report successfully submitted. Redirecting&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'AccedeExpenseReportDashboard.aspx';
                        } else if (btn == "Save") {
                            LoadingPanel.SetText("Expense report successfully saved. Redirecting&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'AccedeExpenseReportDashboard.aspx';
                        } else if (btn == "Submit") {
                            LoadingPanel.SetText("Expense report successfully submitted. Redirecting&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'AccedeExpenseReportDashboard.aspx';
                        } else {
                        
                            
                        }
                        
                    } else if (response.d == "require CA") {
                        alert("Please attach corresponding CA to this transaction otherwise, change transaction type to Reimbursement.");
                        LoadingPanel.Hide();
                    } else {
                        alert(response.d);
                        window.location.href = 'AccedeExpenseReportEdit1.aspx';
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
            console.log(pay);
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

        function viewExpDetailModal(expDetailID) {
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expDetailID: expDetailID
                    
                }),
                success: function (response) {
                    console.log("ok");
                    ExpAllocGrid_edit.PerformCallback();

                    particulars_edit.SetValue(response.d.particulars);
                    supplier_edit.SetValue(response.d.supplier);
                    tin_edit.SetValue(response.d.tin);
                    invoiceOR_edit.SetValue(response.d.invoice);
                    grossAmount_edit.SetValue(response.d.grossAmnt);
                    dateAdded_edit.SetDate(new Date(response.d.dateAdded));
                    console.log(response.d.dateAdded);
                    accountCharged_edit.SetValue(response.d.acctCharge);
                    costCenter_edit.SetValue(response.d.costCenter);
                    netAmount_edit.SetValue(response.d.netAmnt);
                    vat_edit.SetValue(response.d.vat);
                    ewt_edit.SetValue(response.d.ewt);
                    io_edit.SetValue(response.d.io);

                    expensePopup_edit.Show();
                    ExpAllocGrid_edit.Refresh();
                    DocuGrid_edit.Refresh();
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function onEndCallback(s, e) {
            
            if (s.cpAllocationExceeded) {
                alert("Allocation Exceeded!");
                s.cpAllocationExceeded = null;  // Clear the custom property
            }


            if (s.cpComputeUnalloc) {
                
                var gross = grossAmount.GetValue();
                console.log(s.cpComputeUnalloc);
                var alloc_amnt = s.cpComputeUnalloc;
                var curr = exp_Currency.GetValue();
                
                var total_unalloc = (gross - alloc_amnt).toFixed(2);
                
                Unalloc_amnt.SetValue(curr + " " + total_unalloc);
                if (total_unalloc < 0) {
                    var layoutControl = window["Unalloc_amnt"];
                    var labelElement = layoutControl.GetMainElement();
                    if (labelElement) {
                        console.log(labelElement.innerHTML);
                        // Look for the label inside the layout item — this finds any <span> or <td> with the value
                        var label = labelElement.querySelector("input"); // Adjust class if needed

                        if (label) {
                            label.style.setProperty("color", "red", "important");
                        } else {
                            console.log("Label not found inside layout item.");
                        }
                    }
                } else {
                    var layoutControl = window["Unalloc_amnt"];
                    var labelElement = layoutControl.GetMainElement();
                    if (labelElement) {
                        console.log(labelElement.innerHTML);
                        // Look for the label inside the layout item — this finds any <span> or <td> with the value
                        var label = labelElement.querySelector("input"); // Adjust class if needed

                        if (label) {
                            label.style.setProperty("color", "black", "important");
                        } else {
                            console.log("Label not found inside layout item.");
                        }
                    }
                }
                
                s.cpComputeUnalloc = null;  // Clear the custom property
            }

            if (s.cpComputeUnalloc == 0) {
                var gross = grossAmount.GetValue();
                var curr = exp_Currency.GetValue();
                Unalloc_amnt.SetValue(curr + " " + gross.toFixed(2));
            }

            if (s.cpComputeUnalloc_edit) {

                var gross = grossAmount_edit.GetValue();
                var alloc_amnt = s.cpComputeUnalloc_edit;
                var curr = exp_Currency.GetValue();

                var total_unalloc = (gross - alloc_amnt).toFixed(2);
                Unalloc_amnt_edit.SetValue(curr + " " + total_unalloc);

                s.cpComputeUnalloc = null;  // Clear the custom property
            }

            if (s.cpComputeUnalloc_edit == 0) {
                var gross = grossAmount_edit.GetValue();
                var curr = exp_Currency.GetValue();
                Unalloc_amnt_edit.SetValue(curr + " " + gross.toFixed(2));
            }
        }

        function EditExpDetails() {
            if (ASPxClientEdit.ValidateGroup('PopupSubmit')) {
                var dateAdd = dateAdded_edit.GetValue();
                var tin_no = tin_edit.GetValue() != null ? tin_edit.GetValue() : "";
                var invoice_no = invoiceOR_edit.GetValue() != null ? invoiceOR_edit.GetValue() : "";
                var cost_center = costCenter_edit.GetValue() != null ? costCenter_edit.GetValue() : "";
                var gross_amount = grossAmount_edit.GetValue() != 0.00 ? grossAmount_edit.GetValue() : "0";
                var net_amount = netAmount_edit.GetValue() != 0.00 ? netAmount_edit.GetValue() : "0";
                var supp = supplier_edit.GetValue() != null ? supplier_edit.GetValue() : "";
                var particu = particulars_edit.GetValue() != null ? particulars_edit.GetValue() : "";
                var acctCharge = accountCharged_edit.GetValue() != null ? accountCharged_edit.GetValue() : "";
                var vat_amnt = vat_edit.GetValue() != 0.00 ? vat_edit.GetValue() : "0";
                var ewt_amnt = ewt_edit.GetValue() != 0.00 ? ewt_edit.GetValue() : "0";
                var currency = exp_Currency.GetValue() != null ? exp_Currency.GetValue() : "";
                var io = io_edit.GetValue() != null ? io_edit.GetValue() : "";
                var wbs = wbs_edit.GetValue() != null ? wbs_edit.GetValue() : "";
                SaveExpenseReport("Save2");
                LoadingPanel.Show();

                $.ajax({
                    type: "POST",
                    url: "AccedeExpenseReportEdit1.aspx/SaveExpDetailsAJAX",
                    data: JSON.stringify({
                        dateAdd: dateAdd,
                        tin_no: tin_no,
                        invoice_no: invoice_no,
                        cost_center: cost_center,
                        gross_amount: gross_amount,
                        net_amount: net_amount,
                        supp: supp,
                        particu: particu,
                        acctCharge: acctCharge,
                        vat_amnt: vat_amnt,
                        ewt_amnt: ewt_amnt,
                        currency: currency,
                        io: io,
                        wbs: wbs

                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        // Handle success
                        if (response.d == "success") {
                            LoadingPanel.SetText("Updating document&hellip;");
                            LoadingPanel.Show();
                            window.location.href = 'AccedeExpenseReportEdit1.aspx';
                        } else {
                            alert(response.d);
                            LoadingPanel.Hide();
                        }
                        
                    },
                    failure: function (response) {
                        // Handle failure
                    }
                });
            }
        }
        
        function onCurrencyChanged() {
            LoadingPanel.Show();

            var currency = exp_Currency.GetValue();
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/UpdateCurrencyAJAX",
                data: JSON.stringify({
                    currency: currency

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    LoadingPanel.SetText("Updating document&hellip;");
                    LoadingPanel.Show();
                    window.location.href = 'AccedeExpenseReportEdit1.aspx';
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }
        var WFisExpanded = false;
        function isToggleWF() {

            WFisExpanded = !WFisExpanded;
            var layoutControl = window["AddExpDetailForm"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("WFLayout");
                if (layoutItem) {
                    console.log(WFisExpanded);
                    layoutItem.SetVisible(WFisExpanded);
                    WFbtnToggle.SetText(WFisExpanded ? 'Hide' : 'Show');

                }
            }

            // You can also change icons here dynamically if needed

        }

        var EditisExpanded = false;
        function isToggleEdit() {

            EditisExpanded = !EditisExpanded;
            var layoutControl = window["EditExpForm"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("EditAllocGrid");
                if (layoutItem) {
                    console.log(EditisExpanded);
                    layoutItem.SetVisible(EditisExpanded);
                    EditbtnToggle.SetText(EditisExpanded ? 'Hide' : 'Show');

                }
            }

            // You can also change icons here dynamically if needed

        }

        var ExpWFisExpanded = false;
        function isToggleWFExp() {

            ExpWFisExpanded = !ExpWFisExpanded;
            var layoutControl = window["ExpenseEditForm"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("ExpWFLayout");
                if (layoutItem) {
                    console.log(ExpWFisExpanded);
                    layoutItem.SetVisible(ExpWFisExpanded);
                    ExpWFbtnToggle.SetText(ExpWFisExpanded ? 'Hide' : 'Show');

                }
            }

            // You can also change icons here dynamically if needed

        }

        function linkToRFP() {
            var rfpDoc = link_rfp.GetValue();

            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/RedirectToRFPDetailsAJAX",
                data: JSON.stringify({
                    rfpDoc: rfpDoc

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    LoadingPanel.SetText("Loading RFP Document&hellip;");
                    LoadingPanel.Show();
                    window.location.href = 'RFPViewPage.aspx';
                },
                failure: function (response) {
                    // Handle failure
                }
            });
        }

        function ReimbursementTrap() {
            var t_amount = "10";
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/CheckReimburseValidationAJAX",
                data: JSON.stringify({
                    t_amount: t_amount
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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
            var t_amount = "100";
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/CheckReimburseValidationAJAX",
                data: JSON.stringify({
                    t_amount: t_amount
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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

        function computeNetAmount(stat) {
            if (stat == "add") {
                var gross = grossAmount.GetValue() != null ? grossAmount.GetValue() : 0;
                var ewt_amnt = ewt.GetValue() != null ? ewt.GetValue() : 0;
                var vat_amnt = vat.GetValue() != null ? vat.GetValue() : 0;

                var net_amnt = ((gross) - ewt_amnt).toFixed(2);

                netAmount.SetValue(net_amnt);
            } else {
                var gross = grossAmount_edit.GetValue() != null ? grossAmount_edit.GetValue() : 0;
                var ewt_amnt = ewt_edit.GetValue() != null ? ewt_edit.GetValue() : 0;
                var vat_amnt = vat_edit.GetValue() != null ? vat_edit.GetValue() : 0;

                var net_amnt = ((gross) - ewt_amnt).toFixed(2);

                netAmount_edit.SetValue(net_amnt);
            }
            
        }

        function onPopupClosing() {
            DocuGrid_edit.PerformCallback();
            console.log("closing");
        }

        function DownloadCostAllocTemp() {
            $.ajax({
                type: "POST",
                url: "AccedeExpenseReportEdit1.aspx/GenerateTempCostAllocAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var downloadUrl = response.d;
                    window.location.href = downloadUrl;
                },
                error: function (xhr, status, error) {
                    alert("Error generating Excel file.");
                }
            });
        }

        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.
        function onViewAttachment(s, e) {
            if (e.buttonID == 'btnDownloadFile') {

                var fileId = s.GetRowKey(e.visibleIndex);
                var filename;
                var fileext;
                var filebyte;
                expensePopup1.Hide();
                LoadingPanel.SetText("Loading attachment&hellip;");
                LoadingPanel.Show();
                s.GetRowValues(fileId, 'FileName;FileByte;FileExt', onCallbackMultVal);

                function onCallbackMultVal(values) {
                    filename = values[0];
                    filebyte = values[1];
                    fileext = values[2];

                    $("#modalDownload").hide();
                    if (fileext.toLowerCase() === "pdf") {
                        $("#vmodalTit").html("<i class='bi bi-file-earmark-pdf text-danger' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + filename + "</strong>");
                        LoadPdfFromBlob(filebyte);
                    } else if (fileext.toLowerCase() === "docx") {
                        $("#vmodalTit").html("<i class='bi bi-file-earmark-word text-primary' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + filename + "</strong>");
                        //Convert BLOB to File object.
                        var doc = new File([new Uint8Array(filebyte)], fileext);
                        LoadDocxFromBlob(doc);
                    }
                    else if (fileext.toLowerCase() === "png" || fileext.toLowerCase() === "jpeg" || fileext.toLowerCase() === "jpg" || fileext.toLowerCase() === "gif") {
                        $("#vmodalTit").html("<i class='bi bi-file-earmark-image text-success' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + filename + "</strong>");
                        $("#pdf_container").html("<img class='img-fluid' src='data:image/;base64," + bytesToBase64(filebyte) + "'/> ");
                    } else {
                        $("#vmodalTit").html("<i class='bi bi-file-earmark-x text-warning' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + filename + "</strong>");
                        $("#modalDownload").hide();
                        $("#pdf_container").attr("class", "modal-body mx-auto d-block modal-fullscreen").html("<br><br><h5 class='text-center'><i class='bi bi-exclamation-triangle text-warning' style='margin-right: 0.5rem;'></i>The file type is not supported!</h5> <br> <center>Currently, this document viewer only supports image (png, jpg, jpeg, gif), pdf, and docx file formats.</center><br><br>");
                        $("#viewModal").modal("show");
                    }
                    LoadingPanel.Hide();
                    $("#viewModal").modal("show");
                }

                function bytesToBase64(bytes) {
                    let binary = '';
                    bytes.forEach(byte => binary += String.fromCharCode(byte));
                    return btoa(binary);
                }

                $("#modalClose").on("click", function () {
                    $("#viewModal").modal("hide");
                    expensePopup1.Show();
                    
                });

                function LoadDocxFromBlob(blob) {
                    //If Document not NULL, render it.
                    if (blob != null) {
                        //Set the Document options.
                        var docxOptions = Object.assign(docx.defaultOptions, {
                            useMathMLPolyfill: true
                        });
                        //Reference the Container DIV.
                        var container = document.querySelector("#pdf_container");

                        //Render the Word Document.
                        docx.renderAsync(blob, container, null, docxOptions);
                    }
                }

                function LoadPdfFromBlob(blob) {
                    //Read PDF from BLOB.
                    pdfjsLib.getDocument({ data: blob }).promise.then(function (pdfDoc_) {
                        pdfDoc = pdfDoc_;

                        //Reference the Container DIV.
                        var pdf_container = document.getElementById("pdf_container");
                        pdf_container.innerHTML = "";
                        pdf_container.style.display = "block";

                        //Loop and render all pages.
                        for (var i = 1; i <= pdfDoc.numPages; i++) {
                            RenderPage(pdf_container, i);
                        }
                    });
                };

                function RenderPage(pdf_container, num) {
                    pdfDoc.getPage(num).then(function (page) {
                        //Create Canvas element and append to the Container DIV.
                        var canvas = document.createElement('canvas');
                        canvas.id = 'pdf-' + num;
                        ctx = canvas.getContext('2d');
                        pdf_container.appendChild(canvas);

                        //Create and add empty DIV to add SPACE between pages.
                        var spacer = document.createElement("div");
                        spacer.style.height = "20px";
                        pdf_container.appendChild(spacer);

                        //Set the Canvas dimensions using ViewPort and Scale.
                        var viewport = page.getViewport({ scale: scale });
                        canvas.height = resolution * viewport.height;
                        canvas.width = resolution * viewport.width;

                        //Render the PDF page.
                        var renderContext = {
                            canvasContext: ctx,
                            viewport: viewport,
                            transform: [resolution, 0, 0, resolution, 0, 0]
                        };

                        page.render(renderContext);
                    });
                };
            }
        }

    </script>
    <div class="conta" id="demoFabContent">
        <dx:ASPxFormLayout ID="ExpenseEditForm" runat="server" Font-Bold="False" Height="144px" Width="100%" style="margin-bottom: 0px" DataSourceID="SqlMain" ClientInstanceName="ExpenseEditForm">
            <Items>
                <dx:LayoutGroup Caption="New Expense Report" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2" Name="EditFormName">
                    <Items>
                        <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" ColCount="3" ColumnCount="3" ColumnSpan="2">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="submitBtn" runat="server" BackColor="#006838" Font-Bold="True" Font-Size="Small" Text="Submit" ClientInstanceName="submitBtn" ValidationGroup="submitValid" AutoPostBack="False" UseSubmitBehavior="False">
                                                <ClientSideEvents Click="function(s, e) {
	       
if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	ReimbursementTrap();
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
                                            <dx:ASPxButton ID="saveBtn" runat="server" BackColor="#006DD6" ClientInstanceName="saveBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" AutoPostBack="False">
                                                <ClientSideEvents Click="function(s, e) {

if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	SavePopup.Show();
}
	
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
                        <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" ColCount="2" ColumnCount="2" ColumnSpan="2" Width="100%">
                            <Items>
                                <dx:TabbedLayoutGroup ColSpan="1" Width="60%">
                                    <Items>
                                        <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="ReportDate">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="date_dateFiled" runat="server" ClientInstanceName="date_dateFiled" DisplayFormatString="MMMM dd,yyyy" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                <ValidationSettings ValidationGroup="ExpenseEdit">
                                                                </ValidationSettings>
                                                                <BorderLeft BorderStyle="None" />
                                                                <BorderTop BorderStyle="None" />
                                                                <BorderRight BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Charged To Company" ColSpan="1" FieldName="ExpChargedTo_CompanyId">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="exp_CTCompany" runat="server" ClientInstanceName="exp_CTCompany" DataSourceID="SqlCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" OnCallback="exp_Company_Callback" TextField="CompanyDesc" ValueField="CompanyId" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
//exp_Company.SetValue(s.GetValue());
	//costCenter.PerformCallback(s.GetValue()+&quot;|&quot;+exp_CTDepartment.GetValue());
exp_CTDepartment.PerformCallback(s.GetValue());
drpdown_CostCenter.PerformCallback(s.GetValue()+&quot;|&quot;+exp_CTDepartment.GetValue());
//exp_EmpId.PerformCallback(s.GetValue());
var classType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : &quot;&quot;;
drpdwn_FAPWF.PerformCallback(s.GetValue()+&quot;|&quot;+classType );
exp_CompLocation.PerformCallback(s.GetValue());
}" />
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="ExpComp_Location_Id">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="exp_CompLocation" runat="server" ClientInstanceName="exp_CompLocation" DataSourceID="SqlCompLocation" EnableTheming="True" Font-Bold="True" Font-Size="Small" OnCallback="exp_CompLocation_Callback" TextField="Name" ValueField="ID" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
//exp_Company.SetValue(s.GetValue());
	//costCenter.PerformCallback();
//exp_CTDepartment.PerformCallback(s.GetValue());
//drpdown_CostCenter.SetValue(&quot;&quot;);
//exp_EmpId.PerformCallback(s.GetValue());
//drpdwn_FAPWF.PerformCallback(s.GetValue());
}" />
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Employee Name" ColSpan="1" FieldName="ExpenseName">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="exp_EmpId" runat="server" ClientInstanceName="exp_EmpId" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="FullName" ValueField="DelegateFor_UserID" Width="100%" OnCallback="exp_EmpId_Callback">
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="ExpChargedTo_DeptId">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="exp_CTDepartment" runat="server" ClientInstanceName="exp_CTDepartment" DataSourceID="SqlCTDepartment" EnableTheming="True" Font-Bold="True" Font-Size="Small" NullValueItemDisplayText="{0} - {1}" OnCallback="exp_CTDepartment_Callback" TextField="DepDesc" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnCTDeptChanged(s.GetValue());
}" />
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Code" FieldName="DepCode">
                                                                    </dx:ListBoxColumn>
                                                                    <dx:ListBoxColumn Caption="Description" FieldName="DepDesc">
                                                                    </dx:ListBoxColumn>
                                                                </Columns>
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="CostCenter">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_CostCenter" runat="server" ClientInstanceName="drpdown_CostCenter" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" OnCallback="drpdown_CostCenter_Callback" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%">
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Transaction Type" ColSpan="1" FieldName="ExpenseType_ID">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_expenseType" runat="server" ClientInstanceName="drpdown_expenseType" DataSourceID="SqlTranType" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" TextField="Description" ValueField="ExpenseType_ID" Width="100%">
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Expense Category" ColSpan="1" FieldName="ExpenseCat">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_ExpCategory" runat="server" ClientInstanceName="drpdown_ExpCategory" DataSourceID="SqlExpCat" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="Description" ValueField="ID" Width="100%">
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                    <CaptionStyle Font-Bold="False">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Classification" ColSpan="1" FieldName="ExpenseClassification">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_classification" runat="server" ClientInstanceName="drpdown_classification" DataSourceID="SqlClassification" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="ClassificationName" ValueField="ID" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdwn_FAPWF.PerformCallback(exp_CTCompany.GetValue()+&quot;|&quot;+s.GetValue());
}" />
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxMemo ID="memo_Purpose" runat="server" ClientInstanceName="memo_Purpose" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxMemo>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" FieldName="isTravel">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <asp:Panel ID="pnlRadioButtons" runat="server" CssClass="radio-buttons-container">
                                                                <dx:ASPxRadioButton ID="rdButton_Trav_exp" runat="server" ClientInstanceName="rdButton_Trav_exp" ReadOnly="True" RightToLeft="False" Text="Travel" Width="100px">
                                                                    <RadioButtonFocusedStyle Wrap="True">
                                                                    </RadioButtonFocusedStyle>
                                                                    <ClientSideEvents CheckedChanged="function(s, e) {
                                                            rdButton_NonTrav.SetValue(false);
                                                            onTravelClick();
                                                        }" />
                                                                </dx:ASPxRadioButton>
                                                                <dx:ASPxRadioButton ID="rdButton_NonTrav_exp" runat="server" Checked="True" ClientInstanceName="rdButton_NonTrav_exp" Text="Non-Travel" Width="200px">
                                                                    <RadioButtonStyle Font-Size="Smaller" Wrap="True">
                                                                    </RadioButtonStyle>
                                                                    <ClientSideEvents CheckedChanged="function(s, e) {
                                                            rdButton_Trav.SetValue(false);
                                                            onTravelClick();
                                                        }" />
                                                                </dx:ASPxRadioButton>
                                                            </asp:Panel>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                                <dx:TabbedLayoutGroup ColSpan="1" HorizontalAlign="Right" TabSpacing="40%">
                                    <Items>
                                        <dx:LayoutGroup Caption="CASH ADVANCE DETAILS" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                                            <Items>
                                                <dx:LayoutItem Caption="Cash Advance" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="lbl_caTotal" runat="server" ClientInstanceName="lbl_caTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                <Border BorderStyle="None" />
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="lbl_expenseTotal" runat="server" ClientInstanceName="lbl_expenseTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="2px" />
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1" Name="due_lbl">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="lbl_dueTotal" runat="server" ClientInstanceName="lbl_dueTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                                <Border BorderStyle="None" />
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                    <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                                    </ParentContainerStyle>
                                                </dx:LayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                    <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Exp_Currency">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="exp_Currency" runat="server" ClientInstanceName="exp_Currency" DataSourceID="SqlCurrency" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="CurrDescription" ValueField="CurrDescription" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
onCurrencyChanged();
reim_Currency.SetValue(s.GetValue);
}" />
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="Payment Type" ClientVisible="False" ColSpan="1" Name="PayType">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxComboBox ID="drpdown_payType" runat="server" ClientInstanceName="drpdown_payType" DataSourceID="SqlPayMethod" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="PMethod_name" ValueField="ID" Width="100%">
                                                                <ClearButton DisplayMode="Always">
                                                                </ClearButton>
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxComboBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="AR Reference No." ClientVisible="False" ColSpan="1" Name="ARNo" FieldName="AR_Reference_No">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="txt_AR" runat="server" ClientInstanceName="txt_AR" Font-Bold="True" Font-Size="Small" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" HorizontalAlign="Right" Name="reimItem">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxButton ID="reimBtn" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="reimBtn" Font-Bold="True" Font-Size="Small" Text="Create RFP" UseSubmitBehavior="False" ValidationGroup="submitValid">
                                                                <ClientSideEvents Click="function(s, e) {	 
if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
      
               //reimbursePopup2.Show();
ReimbursementTrap2();
}
}" />
                                                            </dx:ASPxButton>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                    <Paddings PaddingTop="10px" />
                                                </dx:LayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                </dx:EmptyLayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1">
                                                </dx:EmptyLayoutItem>
                                                <dx:LayoutItem Caption="Remarks" ClientVisible="False" ColSpan="1" FieldName="remarks">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxMemo ID="memo_remarks" runat="server" ClientInstanceName="memo_remarks" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxMemo>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings HorizontalAlign="Right" />
                                                </dx:LayoutItem>
                                                <dx:LayoutGroup Caption="REIMBURSEMENT DETAILS" ClientVisible="False" ColSpan="1" Name="ReimLayout">
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="1" FieldName="ExpDocNo">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <asp:Panel ID="pnlExpLink" runat="server" CssClass="exp-link-container">
                                                                        <dx:ASPxTextBox ID="link_rfp" runat="server" ClientInstanceName="link_rfp" CssClass="exp-link-textbox" Font-Bold="True" ReadOnly="True">
                                                                            <Border BorderStyle="None" />
                                                                            <BorderLeft BorderStyle="None" />
                                                                            <BorderTop BorderStyle="None" />
                                                                            <BorderRight BorderStyle="None" />
                                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                                        </dx:ASPxTextBox>
                                                                        <dx:ASPxButton ID="ExpBtn" runat="server" AutoPostBack="False" CssClass="edit-button" ToolTip="Open Details">
                                                                            <ClientSideEvents Click="function(s, e) {
	            linkToRFP();
            }" />
                                                                            <Image IconID="actions_up_svg_white_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </asp:Panel>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                            <ParentContainerStyle Font-Bold="True" Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:TabbedLayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="CASH ADVANCES" ColSpan="2" ColumnSpan="2" Width="100%">
                                            <Paddings PaddingBottom="15px" />
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CAGrid" DataSourceID="sqlExpenseCA" EnableCallBacks="False" Font-Size="Small" KeyFieldName="ID" OnRowDeleting="CAGrid_RowDeleting" Width="100%">
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
                                                                <SettingsLoadingPanel Mode="Disabled" />
                                                                <SettingsText CommandDelete="Remove" ConfirmDelete="Are you sure you want to remove this CA from your expense report?" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnRemoveCA" Text="Remove">
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                        <CellStyle Font-Bold="True">
                                                                        </CellStyle>
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
                                    </Items>
                                </dx:TabbedLayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="EXPENSES" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                            <Paddings PaddingBottom="15px" />
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ExpenseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpenseGrid" DataSourceID="SqlExpDetails" EnableCallBacks="False" Font-Size="Small" KeyFieldName="ExpenseReportDetail_ID" Width="100%">
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
                                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="Disabled" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnEditExpDet" Text="Edit">
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnRemoveExp" Text="Remove">
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="ID" FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn Caption="Date" FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        <PropertiesDateEdit DisplayFormatString="MMMM dd, yyyy">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Supplier" FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="TIN" FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Invoice/OR No." FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
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
                                                                    <dx:GridViewDataComboBoxColumn Caption="Account to be Charged" FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                        <PropertiesComboBox DataSourceID="sqlAccountCharged" TextField="GLAccount" ValueField="AccCharged_ID">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="CostCenter/IO/WBS" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                        <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="SAP_CostCenter" ValueField="SAP_CostCenter">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Particulars" FieldName="Particulars" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <PropertiesComboBox DataSourceID="SqlParticulars" TextField="P_Name" ValueField="ID">
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
                                </dx:TabbedLayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="REIMBURSEMENTS" ClientVisible="False" ColSpan="2" ColumnSpan="2" HorizontalAlign="Center" Name="rr" Width="100%">
                                            <Paddings PaddingBottom="15px" />
                                            <Items>
                                                <dx:LayoutItem ColSpan="1" ShowCaption="False">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ReimburseGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ReimburseGrid" DataSourceID="SqlRFPMainReim" Font-Size="Small" KeyFieldName="ID" Width="100%">
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
                                                                <SettingsBehavior EnableCustomizationWindow="True" />
                                                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsLoadingPanel Mode="Disabled" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnRemoveReim" Text="Remove">
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
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
                                                                        <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="CompanyId">
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
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" VerticalAlign="Middle" Width="0px">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxImage ID="errImg" runat="server" Caption="No data found" ClientInstanceName="errImg" Font-Size="X-Small" Height="121px" ImageUrl="~/Resources/nodata.png" ShowLoadingImage="True" Visible="False" Width="171px">
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
                                </dx:TabbedLayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="2" ColumnSpan="2" Width="100%">
                                            <Paddings PaddingBottom="15px" />
                                            <Items>
                                                <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                                                <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocumentGrid.Refresh();
}
" />
                                                                <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                </AdvancedModeSettings>
                                                            </dx:ASPxUploadControl>
                                                            <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" DataSourceID="SqlDocs" KeyFieldName="ID" Width="100%">
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
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="URL" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="DateUploaded" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="6">
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
                                                                    <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                        <CustomButtons>
                                                                            <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="Open File">
                                                                                <Image IconID="pdfviewer_next_svg_16x16">
                                                                                </Image>
                                                                            </dx:GridViewCommandColumnCustomButton>
                                                                        </CustomButtons>
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="12">
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
                                </dx:TabbedLayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup Caption="WORKFLOW" ColSpan="2" ColumnSpan="2" Width="100%">
                                            <GroupBoxStyle>
                                                <Caption Font-Size="Small">
                                                </Caption>
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None">
                                                    <Items>
                                                        <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="CompanyId">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxComboBox ID="exp_Company" runat="server" ClientInstanceName="exp_Company" DataSourceID="SqlCompany" EnableTheming="True" Font-Bold="True" Font-Size="Small" OnCallback="exp_Company_Callback" ReadOnly="True" TextField="CompanyDesc" ValueField="CompanyId" Width="100%">
                                                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
exp_Department.PerformCallback(s.GetValue());
//drpdown_CostCenter.SetValue(&quot;&quot;);
exp_EmpId.PerformCallback(s.GetValue());
}" />
                                                                        <ClearButton DisplayMode="Always">
                                                                        </ClearButton>
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                        </ValidationSettings>
                                                                        <Border BorderStyle="None" />
                                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                    </dx:ASPxComboBox>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <CaptionSettings HorizontalAlign="Right" />
                                                        </dx:LayoutItem>
                                                        <dx:LayoutItem Caption="Workflow Department" ColSpan="1" FieldName="Dept_Id">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxComboBox ID="exp_Department" runat="server" ClientInstanceName="exp_Department" DataSourceID="sqlDept" EnableTheming="True" Font-Bold="True" Font-Size="Small" NullValueItemDisplayText="{0} - {1}" OnCallback="exp_Department_Callback" TextField="DepDesc" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnDeptChanged(s.GetValue());
}" />
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Code" FieldName="DepCode">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn Caption="Description" FieldName="DepDesc">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                        <ClearButton DisplayMode="Always">
                                                                        </ClearButton>
                                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                        </ValidationSettings>
                                                                        <Border BorderStyle="None" />
                                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                    </dx:ASPxComboBox>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <CaptionSettings HorizontalAlign="Right" />
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                                <dx:LayoutItem Caption="" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxButton ID="ExpWFbtnToggle" runat="server" AutoPostBack="False" ClientInstanceName="ExpWFbtnToggle" HorizontalAlign="Left" RenderMode="Link" Text="Show">
                                                                <ClientSideEvents Click="function(s, e) {
	isToggleWFExp();
}" />
                                                                <Image IconID="outlookinspired_expandcollapse_svg_32x32">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                                <dx:LayoutGroup Caption="" ClientVisible="False" ColCount="2" ColSpan="1" ColumnCount="2" Name="ExpWFLayout">
                                                    <Items>
                                                        <dx:LayoutGroup Caption="WORKFLOW DETAILS" ColSpan="1" Width="50%">
                                                            <Items>
                                                                <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                                                    <LayoutItemNestedControlCollection>
                                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                                            <dx:ASPxComboBox ID="drpdown_WF" runat="server" ClientInstanceName="drpdown_WF" Height="39px" OnCallback="drpdown_WF_Callback" TextField="Name" ValueField="WF_Id" Width="100%">
                                                                                <ClientSideEvents Init="function(s, e) {
	//WFSequenceGrid.PerformCallback();
}" SelectedIndexChanged="function(s, e) {
	        //OnWFChanged();
        }" />
                                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                                </ValidationSettings>
                                                                            </dx:ASPxComboBox>
                                                                        </dx:LayoutItemNestedControlContainer>
                                                                    </LayoutItemNestedControlCollection>
                                                                    <CaptionSettings HorizontalAlign="Right" />
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
                                                                            <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" OnCustomCallback="WFSequenceGrid_CustomCallback" Theme="iOS" Width="100%">
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
                                                                <dx:LayoutItem Caption="FAP Workflow" ColSpan="1" FieldName="FAPWF_Id">
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
                                                                    <CaptionSettings HorizontalAlign="Right" />
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
        </div>
        <dx:ASPxLoadingPanel ID="LoadingPanel" runat="server" Theme="MaterialCompact" ClientInstanceName="LoadingPanel" ShowImage="true" ShowText="true" Text="     Processing..." Modal="True">
        </dx:ASPxLoadingPanel>

        <%-- This is where the document is rendered and viewed --%>
        <dx:ASPxPopupControl ID="caPopup" runat="server" FooterText="" HeaderText="Select Cash Advance/s" Width="100%" ClientInstanceName="caPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
            </CloseButtonImage>
            <HeaderStyle BackColor="#006838" ForeColor="White" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <div id="scrollablecontainer2">
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
                                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="CompanyId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            <PropertiesComboBox DataSourceID="SqlDepartmentAll" TextField="DepDesc" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Payment Method" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <PropertiesComboBox DataSourceID="sqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Doc No.">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                             </div>
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
                                      AddExpCA();                               
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
                        </Items>
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

       <%-- ADD EXPENSE POPUP--%>

        <%--ADD REIMBURSEMENT--%>
        <dx:ASPxPopupControl ID="reimbursePopup" runat="server" FooterText="" HeaderText="Request for Payment Details" Width="1146px" ClientInstanceName="reimbursePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
            </CloseButtonImage>
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('reimDiv')
            }" />
                        <HeaderStyle BackColor="#006838" ForeColor="White" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="reimDiv">
                        <dx:ASPxFormLayout ID="FormReimburse" runat="server" Width="100%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ClientInstanceName="FormReimburse">
<SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit"></SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="company_reim" runat="server" ClientInstanceName="company_reim" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId" Width="100%" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="reim_PayMethod" runat="server" ClientInstanceName="reim_PayMethod" DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID" Width="100%" SelectedIndex="1">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onPayMethodChanged(s.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Type of Transaction" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox5" runat="server" Text="Reimbursement" Width="100%" ReadOnly="True">
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ClientVisible="False" ColSpan="1" Name="wbs">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="wbs_reim" runat="server" ClientInstanceName="wbs_reim" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Department" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="dept_reim" runat="server" DataSourceID="SqlDepartment" TextField="DepDesc" ValueField="ID" Width="100%" ClientInstanceName="dept_reim" OnCallback="dept_reim_Callback" SelectedIndex="0">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onDeptChanged();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="costCenter_reim" runat="server" Width="100%" ClientInstanceName="costCenter_reim">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ColSpan="1" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="io_reim" runat="server" Width="100%" ClientInstanceName="io_reim">
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payee_reim" runat="server" Width="100%" ClientInstanceName="payee_reim">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ColSpan="1" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="acctCharge_reim" runat="server" DataSourceID="SqlExpCat" TextField="Description" ValueField="ID" Width="100%" ClientInstanceName="acctCharge_reim" ReadOnly="True">
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" ColumnSpan="2" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="purpose_reim" runat="server" ClientInstanceName="purpose_reim" Height="71px" ReadOnly="True" Width="100%">
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="2" ColumnCount="2">
                        <Items>
                            <dx:LayoutItem Caption="Amount" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="rfpAmount_reim" runat="server" ClientInstanceName="rfpAmount_reim" DecimalPlaces="2" DisplayFormatString="N" Number="0" ReadOnly="True">
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="reim_Currency" runat="server" ClientInstanceName="reim_Currency" DataSourceID="SqlCurrency" EnableTheming="True" Font-Bold="False" Font-Size="Small" ReadOnly="True" TextField="CurrDescription" ValueField="CurrDescription" Width="100%">
                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Remarks" ClientVisible="False" ColSpan="2" ColumnSpan="2" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="remarks_reim" runat="server" ClientInstanceName="remarks_reim" Height="71px" Width="100%">
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup ColCount="3" ColSpan="2" ColumnCount="3" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="popupSubmitBtn1" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" HorizontalAlign="Right" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                            <ClientSideEvents Click="function(s, e) {
	AddReimbursement();
}" />
                                            <Border BorderColor="#006838" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="popupCancelBtn1" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" UseSubmitBehavior="False">
                                            <ClientSideEvents Click="function(s, e) {
                     ASPxClientEdit.ClearEditorsInContainerById('reimDiv');
                     reimbursePopup.Hide();
            }" />
                                            <Border BorderColor="#878787" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
                <SettingsItemCaptions HorizontalAlign="Right" />
            </dx:LayoutGroup>
        </Items>
        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
        <BackgroundImage HorizontalPosition="center" ImageUrl="../Content/Images/flat-mountains.svg'" Repeat="NoRepeat" />
    </dx:ASPxFormLayout>

                  


                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

          <dx:ASPxPopupControl ID="SubmitPopup" runat="server" HeaderText="Submit Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server">
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
                                <dx:ASPxButton ID="btnSubmitFinal" runat="server" Text="Submit" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SubmitPopup.Hide();
	SaveExpenseReport(&quot;Submit&quot;);
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

        <dx:ASPxPopupControl ID="SubmitPopup2" runat="server" HeaderText="Submit Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup2" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None" CssClass="rounded-bottom" Width="700px">
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout6" runat="server" ColCount="3" ColumnCount="3" Width="100%">
        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutItem ColSpan="3" ShowCaption="False" HorizontalAlign="Center" ColumnSpan="3" Width="100%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxImage4" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                </TabImage>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="3" HorizontalAlign="Center" ColumnSpan="3" Width="100%">
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
                        <dx:ASPxButton ID="btnCreateSubmitFinal" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="btnCreateSubmitFinal" HorizontalAlign="Right" Text="Create RFP &amp; Submit">
                            <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SubmitPopup2.Hide();
	SaveExpenseReport(&quot;CreateSubmit&quot;);
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
                        <dx:ASPxButton ID="ASPxButton1" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" HorizontalAlign="Right" Text="Submit">
                            <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SubmitPopup.Hide();
	SaveExpenseReport(&quot;Submit&quot;);
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
                        <dx:ASPxButton ID="ASPxButton7" runat="server" AutoPostBack="False" BackColor="White" ForeColor="Gray" HorizontalAlign="Right" Text="Cancel">
                            <ClientSideEvents Click="function(s, e) {
	SubmitPopup.Hide();
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

        <dx:ASPxPopupControl ID="reimbursePopup2" runat="server" HeaderText="Create RFP" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="reimbursePopup2" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None">
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
                                <dx:ASPxButton ID="CreateReim" runat="server" AutoPostBack="False" BackColor="#0D6943" ClientInstanceName="CreateReim" Text="Create">
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
                                <dx:ASPxButton ID="ASPxButton4" runat="server" AutoPostBack="False" BackColor="White" ForeColor="Gray" Text="Cancel">
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

                    <dx:ASPxPopupControl ID="SavePopup" runat="server" HeaderText="Save Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SavePopup" CloseAction="CloseButton" CloseOnEscape="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" PopupAnimationType="None">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout5" runat="server">
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
                                <dx:ASPxButton ID="btnSaveExp" runat="server" Text="Save" BackColor="#006DD6" ClientInstanceName="btnSaveExp" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	LoadingPanel.Show();
               SavePopup.Hide();
	SaveExpenseReport(&quot;Save&quot;);
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
                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
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
                                <dx:ASPxButton ID="ASPxButton3" runat="server" AutoPostBack="False" Text="OK">
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

        <dx:ASPxPopupControl ID="expensePopup1" runat="server" FooterText="" HeaderText="Add Expense Item" Width="1200px" ClientInstanceName="expensePopup1" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None">
            <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
            </CloseButtonImage>
            <ClientSideEvents CloseButtonClick="function(s, e) {
	            //ASPxClientEdit.ClearEditorsInContainerById('scrollableContainer')
            }
" />
                        <HeaderStyle BackColor="#006838" ForeColor="White" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollablecontainer1">
                        <dx:ASPxFormLayout ID="AddExpDetailForm" runat="server" Width="100%" ClientInstanceName="AddExpDetailForm">
                    <Items>
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="popupSubmitBtn" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                            <dx:ASPxButton ID="popupCancelBtn" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                <ClientSideEvents Click="function(s, e) {
                     //ASPxClientEdit.ClearEditorsInContainerById('scrollableContainer');
                     expensePopup1.Hide();
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
                                        <dx:LayoutItem Caption="Date" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxDateEdit ID="dateAdded" runat="server" ClientInstanceName="dateAdded" DisplayFormatString="MMMM dd, yyyy" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                        <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="costCenter" runat="server" ClientInstanceName="costCenter" DataSourceID="sqlCostCenter" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{0} - {1}" OnCallback="costCenter_Callback" TextField="SAP_CostCenter" TextFormatString="{0}" ValueField="SAP_CostCenter" Width="100%" DropDownWidth="300px">
                                                        <ClearButton DisplayMode="Always">
                                                        </ClearButton>
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxComboBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Expense Type" ColSpan="1" Width="60%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="particulars" runat="server" ClientInstanceName="particulars" DataSourceID="SqlParticulars" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="P_Name" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Expense Description" FieldName="P_Description" Width="250px">
                                                            </dx:ListBoxColumn>
                                                            <dx:ListBoxColumn Caption="Common Text" FieldName="P_Name" Width="250px">
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
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="IO" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="IO" runat="server" ClientInstanceName="IO" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Supplier" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="supplier" runat="server" ClientInstanceName="supplier" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Gross Amount" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="grossAmount" runat="server" AllowNull="False" ClientInstanceName="grossAmount" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	netAmount.SetValue(s.GetValue());
	ExpAllocGrid.PerformCallback();
	computeNetAmount(&quot;add&quot;);
}" />
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Vendor TIN" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="tin" runat="server" ClientInstanceName="tin" Font-Size="Small" NumberType="Integer" Width="100%">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="VAT" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="vat" runat="server" ClientInstanceName="vat" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	computeNetAmount(&quot;add&quot;);
}" />
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="invoiceOR" runat="server" ClientInstanceName="invoiceOR" Font-Bold="False" Font-Size="Small" Width="50%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="EWT" ColSpan="1" HorizontalAlign="Left">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="ewt" runat="server" ClientInstanceName="ewt" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	computeNetAmount(&quot;add&quot;);
}" />
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="WBS" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="WBS" runat="server" ClientInstanceName="WBS" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="netAmount" runat="server" ClientInstanceName="netAmount" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right" ReadOnly="True">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Account to be Charged" ClientVisible="False" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="accountCharged" runat="server" ClientInstanceName="accountCharged" DataSourceID="sqlAccountCharged" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="GLAccount" TextFormatString="{1}" ValueField="AccCharged_ID" Width="100%">
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
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1" Width="70%">
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
                                        <dx:LayoutItem ColSpan="1" Name="Unallocated_amnt" Caption="Unallocated Amount" Width="30%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="Unalloc_amnt" runat="server" ClientInstanceName="Unalloc_amnt" HorizontalAlign="Right" Width="100%" Font-Bold="True" ReadOnly="True">
                                                        <Border BorderStyle="None" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ClientVisible="False" Name="WFLayout">
                                            <Items>
                                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" Width="100%">
                                                    <Items>
                                                        <dx:LayoutItem Caption="Upload Template" ColSpan="1" Width="70%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxUploadControl ID="UploadControllerExpD0" runat="server" AutoStartUpload="True" ShowProgressPanel="True" UploadMode="Auto" Width="100%" OnFileUploadComplete="UploadControllerExpD0_FileUploadComplete">
                                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	ExpAllocGrid.Refresh();
ExpAllocGrid.PerformCallback();
}
" />
                                                                        <AdvancedModeSettings EnableFileList="True" EnableMultiSelect="True">
                                                                        </AdvancedModeSettings>
                                                                    </dx:ASPxUploadControl>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                                        </dx:LayoutItem>
                                                        <dx:LayoutItem Caption="" ColSpan="1" Width="30%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxButton ID="submitBtn0" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="submitBtn" Font-Bold="True" Font-Size="Small" Text="Download Template" UseSubmitBehavior="False">
                                                                        <ClientSideEvents Click="function(s, e) {
	DownloadCostAllocTemp();
        }" />
                                                                        <Image IconID="pdfviewer_next_svg_white_16x16">
                                                                        </Image>
                                                                        <HoverStyle BackColor="Black">
                                                                        </HoverStyle>
                                                                    </dx:ASPxButton>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                                <dx:LayoutItem ColSpan="1" Width="100%" ShowCaption="False">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxGridView ID="ExpAllocGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid" KeyFieldName="ID" OnCustomCallback="ExpAllocGrid_CustomCallback" OnRowDeleting="ExpAllocGrid_RowDeleting" OnRowInserting="ExpAllocGrid_RowInserting" Width="100%">
                                                                <ClientSideEvents EndCallback="onEndCallback" />
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
                                                                    <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenter" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        <PropertiesComboBox DataSourceID="SqlCostCenterAll" TextField="SAP_CostCenter" TextFormatString="{0}" ValueField="SAP_CostCenter">
                                                                            <ItemStyle Font-Size="Smaller" />
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                        </PropertiesSpinEdit>
                                                                    </dx:GridViewDataSpinEditColumn>
                                                                    <dx:GridViewDataMemoColumn FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                    </dx:GridViewDataMemoColumn>
                                                                </Columns>
                                                                <TotalSummary>
                                                                    <dx:ASPxSummaryItem DisplayFormat="Total: #,#00.00" FieldName="NetAmount" ShowInColumn="NetAmount" ShowInGroupFooterColumn="NetAmount" SummaryType="Sum" />
                                                                </TotalSummary>
                                                                <Styles>
                                                                    <Footer Font-Bold="True" Font-Size="Medium">
                                                                    </Footer>
                                                                </Styles>
                                                            </dx:ASPxGridView>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2" Width="100%">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxUploadControl ID="UploadControllerExpD" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadControllerExpD_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocuGrid.Refresh();
}
" />
                                                        <AdvancedModeSettings EnableFileList="True" EnableMultiSelect="True">
                                                        </AdvancedModeSettings>
                                                    </dx:ASPxUploadControl>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" KeyFieldName="ID" OnRowDeleting="DocuGrid_RowDeleting1" OnRowUpdating="DocuGrid_RowUpdating1" Width="100%">
                                                        <ClientSideEvents CustomButtonClick="onViewAttachment" />
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
                                                            <dx:GridViewDataTextColumn FieldName="FileDesc" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileExt" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <CustomButtons>
                                                                    <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile" Text="Open File">
                                                                    </dx:GridViewCommandColumnCustomButton>
                                                                </CustomButtons>
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileByte" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                </dx:EmptyLayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="expensePopup_edit" runat="server" FooterText="" HeaderText="Edit Expense Item" Width="1200px" ClientInstanceName="expensePopup_edit" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None">
                        <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
                        </CloseButtonImage>
                        <ClientSideEvents Closing="onPopupClosing" />
                        <HeaderStyle BackColor="#006838" ForeColor="White" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollablecontainer3">
                        <dx:ASPxFormLayout ID="EditExpForm" runat="server" Width="100%" ClientInstanceName="EditExpForm">
                    <Items>
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                            <Items>
                                <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer runat="server">
                                            <dx:ASPxButton ID="ASPxButton5" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                <ClientSideEvents Click="function(s, e) {
	EditExpDetails();
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
                                <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="60%" HorizontalAlign="Center" Name="ErrorLabel">
                                    <Items>
                                        <dx:LayoutItem Caption="Date" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxDateEdit ID="dateAdded_edit" runat="server" ClientInstanceName="dateAdded_edit" DisplayFormatString="MMMM dd, yyyy" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                        <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="costCenter_edit" runat="server" ClientInstanceName="costCenter_edit" DataSourceID="sqlCostCenter" Font-Bold="False" Font-Size="Small" OnCallback="costCenter_edit_Callback" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%" NullValueItemDisplayText="{0} - {1}" TextFormatString="{0}" DropDownWidth="200px">
                                                        <ClearButton DisplayMode="Always">
                                                        </ClearButton>
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxComboBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Expense Type" ColSpan="1" Width="60%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="particulars_edit" runat="server" ClientInstanceName="particulars_edit" DataSourceID="SqlParticulars" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="P_Name" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Expense Description" FieldName="P_Description" Width="250px">
                                                            </dx:ListBoxColumn>
                                                            <dx:ListBoxColumn Caption="Common Text" FieldName="P_Name" Width="250px">
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
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="IO" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="io_edit" runat="server" ClientInstanceName="io_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Supplier" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="supplier_edit" runat="server" ClientInstanceName="supplier_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Gross Amount" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="grossAmount_edit" runat="server" AllowNull="False" ClientInstanceName="grossAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	netAmount_edit.SetValue(s.GetValue());
	ExpAllocGrid_edit.PerformCallback();
computeNetAmount(&quot;edit&quot;);
}" />
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" IsRequired="True" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Vendor TIN" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="tin_edit" runat="server" ClientInstanceName="tin_edit" Font-Size="Small" NumberType="Integer" Width="100%">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="VAT" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="vat_edit" runat="server" ClientInstanceName="vat_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	computeNetAmount(&quot;edit&quot;);

}" />
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="invoiceOR_edit" runat="server" ClientInstanceName="invoiceOR_edit" Font-Bold="False" Font-Size="Small" Width="50%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="EWT" ColSpan="1" HorizontalAlign="Left" Width="55%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="ewt_edit" runat="server" ClientInstanceName="ewt_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	computeNetAmount(&quot;edit&quot;);

}" />
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="WBS" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="wbs_edit" runat="server" ClientInstanceName="wbs_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="netAmount_edit" runat="server" ClientInstanceName="netAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right" ReadOnly="True">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxSpinEdit>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                        <dx:EmptyLayoutItem ColSpan="1">
                                        </dx:EmptyLayoutItem>
                                        <dx:EmptyLayoutItem ColSpan="1">
                                        </dx:EmptyLayoutItem>
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
                                            <CaptionSettings HorizontalAlign="Right" />
                                            <ParentContainerStyle Font-Size="Small">
                                            </ParentContainerStyle>
                                        </dx:LayoutItem>
                                    </Items>
                                    <ParentContainerStyle ForeColor="Red">
                                    </ParentContainerStyle>
                                </dx:LayoutGroup>
                                <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="2" ColumnCount="2">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1" Width="70%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxButton ID="EditbtnToggle" runat="server" AutoPostBack="False" ClientInstanceName="EditbtnToggle" HorizontalAlign="Left" RenderMode="Link" Text="Show">
                                                        <ClientSideEvents Click="function(s, e) {
	isToggleEdit();
}" />
                                                        <Image IconID="outlookinspired_expandcollapse_svg_32x32">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="Unallocated Amount" ColSpan="1" Name="Unalloc_amnt_edit" Width="30%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="Unalloc_amnt_edit" runat="server" ClientInstanceName="Unalloc_amnt_edit" Font-Bold="True" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                        <Border BorderStyle="None" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="2" ColumnSpan="2" Name="EditAllocGrid" ShowCaption="False" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ExpAllocGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid_edit" DataSourceID="SqlExpMap" KeyFieldName="ExpenseDetailMap_ID" OnCustomCallback="ExpAllocGrid_edit_CustomCallback" OnRowDeleting="ExpAllocGrid_edit_RowDeleting" OnRowInserting="ExpAllocGrid_edit_RowInserting" Width="100%">
                                                        <ClientSideEvents EndCallback="onEndCallback" />
                                                        <SettingsPager Mode="EndlessPaging">
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="Inline">
                                                        </SettingsEditing>
                                                        <Settings GridLines="None" ShowFooter="True" ShowTitlePanel="True" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsText CommandDelete="Remove" />
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="160px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                <PropertiesComboBox DataSourceID="SqlCostCenterAll" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" TextFormatString="{0}">
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                </PropertiesSpinEdit>
                                                            </dx:GridViewDataSpinEditColumn>
                                                            <dx:GridViewDataTextColumn FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ExpenseDetailMap_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Remarks" FieldName="EDM_Remarks" ShowInCustomizationForm="True" VisibleIndex="9">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                        <TotalSummary>
                                                            <dx:ASPxSummaryItem DisplayFormat="Total: #,#0.00" FieldName="NetAmount" ShowInColumn="Allocated Amount" ShowInGroupFooterColumn="Allocated Amount" SummaryType="Sum" Tag="Total" />
                                                        </TotalSummary>
                                                        <Styles>
                                                            <Footer BackColor="#66FFCC" Font-Bold="True" Font-Overline="False" Font-Size="Medium">
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
                                <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxUploadControl ID="UploadControllerExpD_edit" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadControllerExpD_edit_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocuGrid_edit.Refresh();
}
" />
                                                        <AdvancedModeSettings EnableFileList="True" EnableMultiSelect="True">
                                                        </AdvancedModeSettings>
                                                    </dx:ASPxUploadControl>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="DocuGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid_edit" KeyFieldName="File_Id" OnRowUpdating="DocuGrid_edit_RowUpdating" Width="100%" DataSourceID="SqlExpDetailAttach" OnRowDeleting="DocuGrid_edit_RowDeleting" OnCustomCallback="DocuGrid_edit_CustomCallback">
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
                                                            <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3" Caption="File Desc">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileExtension" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="File_Id" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                </dx:EmptyLayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

                      <%-- Bootstrap Modal --%>
    <%-- This is where the document is rendered and viewed --%>
    <div class="modal fade" id="viewModal" style="z-index: 1050; float: inherit" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-fullscreen modal-dialog-scrollable" id="modalDialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="vmodalTit"><i class="bi bi-file-earmark-pdf text-danger" style="margin-right: 0.5rem;"></i><strong id="modalTitle">Preview File</strong></h5>
                <a id="modalDownload" href="" class="btn btn-secondary btn-sm">
                    <i class="bi bi-download text-white" style="margin-right: 0.5rem;"></i>
                    Download
                </a>
            </div>
            <div class="modal-body modal-fullscreen container-fluid mx-auto text-center bg-secondary" id="pdf_container">
            </div>
            <div class="modal-footer" id="wmodalFooter">
                <button type="button" id="modalClose" class="btn btn-light btn-outline-secondary btn-sm">Close</button>
            </div>
        </div>
    </div>
</div>
    
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserComp] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
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
    <asp:SqlDataSource ID="sqlExpenseCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlRFPMainCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([isTravel] &lt;&gt; @isTravel) AND ([Status] = @Status) AND ([Payee] = @Payee) AND ([Exp_ID] IS NULL))">
            <SelectParameters>
                <asp:Parameter DefaultValue="true" Name="IsExpenseCA" Type="Boolean" />
                <asp:Parameter DefaultValue="true" Name="isTravel" Type="Boolean" />
                <asp:Parameter Name="Status" Type="Int32" />
                <asp:Parameter Name="Payee" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPMainReim" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseReim] = @IsExpenseReim) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([CompanyId] = @CompanyId) AND ([UserId] = @UserId) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [DepDesc]">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetails] WHERE ([ExpenseMain_ID] = @ExpenseMain_ID)">
        <SelectParameters>
            <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [ID], [FileName], [Description], [DateUploaded], [FileSize] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID) AND ([DocType_Id] = @DocType_Id))" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
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
                <asp:Parameter DefaultValue="" Name="Doc_ID" Type="Int32" />
                <asp:Parameter Name="DocType_Id" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="DateUploaded" Type="DateTime" />
                <asp:Parameter Name="FileSize" Type="String" />
                <asp:Parameter Name="original_ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlAccountCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_AccountCharged]"></asp:SqlDataSource>
       <%-- <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE (([CompanyId] = @CompanyId) AND ([DepartmentId] = @DepartmentId))">
            <SelectParameters>
                <asp:Parameter Name="CompanyId" Type="Int32" />
                <asp:Parameter Name="DepartmentId" Type="Int32" />
            </SelectParameters>
    </asp:SqlDataSource>--%>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT ID, DepCode, DepDesc FROM [vw_ACCEDE_I_SecurityUserDept] WHERE ([CompanyId] = @CompanyId) AND ([UserId] = @UserId) GROUP BY ID, DepDesc, DepCode">
        <SelectParameters>
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetailsMap] WHERE ([ExpenseReportDetail_ID] = @ExpenseReportDetail_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_ExpenseDetailsMap] WHERE [ExpenseDetailMap_ID] = @ExpenseDetailMap_ID" InsertCommand="INSERT INTO [ACCEDE_T_ExpenseDetailsMap] ([AccountToCharged], [CostCenterIOWBS], [VAT], [EWT], [NetAmount], [ExpenseReportDetail_ID], [Preparer_ID], [EDM_Remarks]) VALUES (@AccountToCharged, @CostCenterIOWBS, @VAT, @EWT, @NetAmount, @ExpenseReportDetail_ID, @Preparer_ID, @EDM_Remarks)" UpdateCommand="UPDATE [ACCEDE_T_ExpenseDetailsMap] SET [AccountToCharged] = @AccountToCharged, [CostCenterIOWBS] = @CostCenterIOWBS, [VAT] = @VAT, [EWT] = @EWT, [NetAmount] = @NetAmount, [ExpenseReportDetail_ID] = @ExpenseReportDetail_ID, [Preparer_ID] = @Preparer_ID, [EDM_Remarks] = @EDM_Remarks WHERE [ExpenseDetailMap_ID] = @ExpenseDetailMap_ID">
        <DeleteParameters>
            <asp:Parameter Name="ExpenseDetailMap_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="AccountToCharged" Type="Int32" />
            <asp:Parameter Name="CostCenterIOWBS" Type="String" />
            <asp:Parameter Name="VAT" Type="Decimal" />
            <asp:Parameter Name="EWT" Type="Decimal" />
            <asp:Parameter Name="NetAmount" Type="Decimal" />
            <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
            <asp:Parameter Name="Preparer_ID" Type="String" />
            <asp:Parameter Name="EDM_Remarks" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="ExpenseReportDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="AccountToCharged" Type="Int32" />
            <asp:Parameter Name="CostCenterIOWBS" Type="String" />
            <asp:Parameter Name="VAT" Type="Decimal" />
            <asp:Parameter Name="EWT" Type="Decimal" />
            <asp:Parameter Name="NetAmount" Type="Decimal" />
            <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
            <asp:Parameter Name="Preparer_ID" Type="String" />
            <asp:Parameter Name="EDM_Remarks" Type="String" />
            <asp:Parameter Name="ExpenseDetailMap_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlParticulars" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_Particulars]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Currency]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetailAttach" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpDetailsFileAttach] WHERE ([ExpDetail_Id] = @ExpDetail_Id)">
        <SelectParameters>
            <asp:SessionParameter Name="ExpDetail_Id" SessionField="ExpDetailsID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenterAll" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL)">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserDelegationUMaster] WHERE (([DelegateTo_UserID] = @DelegateTo_UserID) AND ([Company_ID] = @Company_ID) AND ([DateFrom] &lt;= @DateFrom) AND ([DateTo] &gt;= @DateTo) AND ([IsActive] = @IsActive)) ORDER BY [FullName]">
        <SelectParameters>
            <asp:Parameter Name="DelegateTo_UserID" Type="String" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="DateFrom" Type="DateTime" />
            <asp:Parameter Name="DateTo" Type="DateTime" />
            <asp:Parameter DefaultValue="1" Name="IsActive" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification] WHERE ([isActive] = @isActive) ORDER BY [ClassificationName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlUserSelf" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT EmpCode, FullName FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
        <SelectParameters>
            <asp:Parameter Name="EmpCode" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <%--<asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] ORDER BY [CostCenter]">
    </asp:SqlDataSource>--%>
    <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
</asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlCompLocation" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDepartmentAll" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
</asp:Content>

