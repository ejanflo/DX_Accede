<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeNonPO_P2PView.aspx.cs" Inherits="DX_WebTemplate.AccedeNonPO_P2PView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     
    
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
        .scrollablecontainer{
            overflow: auto;
            height: 80vh; /* full viewport height */
            width: 70vw;  /* full viewport width */
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

        function OnCTDeptChanged(dept_id) {
            drpdown_CostCenter.PerformCallback(drpdown_CTComp.GetValue() + "|" + dept_id);
        }

        function onCustomButtonClick(s, e) {
            console.log(e.buttonID);
            if (e.buttonID == 'btnView') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewCADetailModal(item_id);
            }

            if (e.buttonID == 'btnViewExpDet') {
                //console.log(e.buttonID);
                var item_id = s.GetRowKey(e.visibleIndex);
                viewExpDetailModal(item_id);
            }

            if (e.buttonID == 'btnViewReim') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewReimModal(item_id);
            }

            if (e.buttonID == 'btnEdit') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewExpDetailModal2(item_id);
            }

            if (e.buttonID == 'btnEditReim') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewReimModal2(item_id);
            }
        }

        function OnFowardWFChanged(wf_id) {
            WFSequenceGrid0.PerformCallback(wf_id);
        }

        function CheckValidDocNo(SAPDoc, callback) {
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            $.ajax({
                type: "POST",
                url: "AccedeNonPO_P2PView.aspx/CheckSAPVAlidAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    SAPDoc: SAPDoc,
                    secureToken: secureToken
                }),
                success: function (response) {
                    console.log(response.d);
                    console.log(callback);
                    if (response.d === "clear") {
                        if (callback == 1) {
                            ApprovePopup.Show();
                        }

                        if (callback == 2) {
                            saveFinChanges(0);
                        }

                    } else {
                        edit_SAPDocNo.SetIsValid(false);
                        edit_SAPDocNo.SetErrorText("SAP Document No. already exists.");

                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewExpDetailModal(expDetailID) {
            console.log(expDetailID);
            //console.log(expDetailID);
            $.ajax({
                type: "POST",
                url: "AccedeInvoiceNonPOViewPage.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expDetailID: expDetailID

                }),
                success: function (response) {
                    console.log("ok");
                    //var layoutControl = window["FormCA"];
                    //if (layoutControl) {
                    //    var layoutItem = layoutControl.GetItemByName("CADocNum");
                    //    if (layoutItem) {
                    //        layoutItem.SetCaption(response.d.docNum);
                    //    }
                    //}

                    expLine_ExpType.SetValue(response.d.particulars);
                    //supplier_edit.SetValue(response.d.supplier);
                    //tin_edit.SetValue(response.d.tin);
                    expLine_Invoice.SetValue(response.d.InvoiceOR);
                    expLine_Total.SetValue(response.d.grossAmnt);
                    //dateAdded_edit.SetDate(new Date(response.d.dateAdded));
                    //console.log(response.d.dateAdded);
                    //accountCharged_edit.SetValue(response.d.acctCharge);
                    //costCenter_edit.SetValue(response.d.costCenter);
                    expLine_NetAmnt.SetValue(response.d.netAmnt);
                    //vat_edit.SetValue(response.d.vat);
                    //ewt_edit.SetValue(response.d.ewt);
                    //io_edit.SetValue(response.d.io);
                    expLine_LineDesc.SetValue(response.d.LineDesc);
                    //wbs_edit.SetValue(response.d.wbs);
                    expLine_ExpCat.SetValue(response.d.acctCharge);
                    //txt_assign_edit.SetValue(response.d.Assignment);
                    //txt_allowance_edit.SetValue(response.d.Allowance);
                    //drpdown_EWTTaxType_edit.SetValue(response.d.EWTTaxType_Id);
                    //spin_EWTTAmount_edit.SetValue(response.d.EWTTaxAmount);
                    //txt_EWTTCode_edit.SetValue(response.d.EWTTaxCode);
                    //txt_InvTCode_edit.SetValue(response.d.InvoiceTaxCode);
                    expLine_Qty.SetValue(response.d.Qty);
                    expLine_UnitPrice.SetValue(response.d.UnitPrice);
                    expLine_UOM.SetValue(response.d.uom);
                    expLine_ewt.SetValue(response.d.ewt);
                    expLine_vat.SetValue(response.d.vat);
                    //txt_Asset_edit.SetValue(response.d.Asset);
                    //txt_SubAsset_edit.SetValue(response.d.SubAssetCode);
                    //txt_AltRecon_edit.SetValue(response.d.AltRecon);
                    //txt_SLCode_edit.SetValue(response.d.SLCode);
                    //txt_SpecialGL_edit.SetValue(response.d.SpecialGL);
                    ExpAllocGrid.PerformCallback(expDetailID);
                    DocuGrid1.PerformCallback(expDetailID);
                    ExpItemMapPopup.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewExpDetailModal2(expDetailID) {
            $.ajax({
                type: "POST",
                url: "AccedeNonPOApprovalView.aspx/DisplayExpDetailsEditAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    expDetailID: expDetailID

                }),
                success: function (response) {
                    console.log("ok");

                    particulars_edit.SetValue(response.d.particulars);
                    //supplier_edit.SetValue(response.d.supplier);
                    //tin_edit.SetValue(response.d.tin);
                    invoice_edit.SetValue(response.d.invoice);
                    total_edit.SetValue(response.d.grossAmnt);
                    dateAdded_edit.SetDate(new Date(response.d.dateAdded));
                    console.log(response.d.dateAdded);
                    //accountCharged_edit.SetValue(response.d.acctCharge);
                    //costCenter_edit.SetValue(response.d.costCenter);
                    net_amount_edit.SetValue(response.d.netAmnt);
                    //vat_edit.SetValue(response.d.vat);
                    //ewt_edit.SetValue(response.d.ewt);
                    //io_edit.SetValue(response.d.io);
                    expItem_desc_edit.SetValue(response.d.LineDesc);
                    //wbs_edit.SetValue(response.d.wbs);
                    exp_category_edit.SetValue(response.d.acctCharge);
                    //txt_assign_edit.SetValue(response.d.Assignment);
                    //txt_allowance_edit.SetValue(response.d.Allowance);
                    //drpdown_EWTTaxType_edit.SetValue(response.d.EWTTaxType_Id);
                    //spin_EWTTAmount_edit.SetValue(response.d.EWTTaxAmount);
                    //txt_EWTTCode_edit.SetValue(response.d.EWTTaxCode);
                    //txt_InvTCode_edit.SetValue(response.d.InvoiceTaxCode);
                    qty_edit.SetValue(response.d.Qty);
                    unit_price_edit.SetValue(response.d.UnitPrice);
                    exp_UOM_edit.SetValue(response.d.uom);
                    ewt_edit.SetValue(response.d.ewt);
                    vat_edit.SetValue(response.d.vat);
                    //txt_Asset_edit.SetValue(response.d.Asset);
                    //txt_SubAsset_edit.SetValue(response.d.SubAssetCode);
                    //txt_AltRecon_edit.SetValue(response.d.AltRecon);
                    //txt_SLCode_edit.SetValue(response.d.SLCode);
                    //txt_SpecialGL_edit.SetValue(response.d.SpecialGL);

                    expensePopup_edit.Show();
                    ExpAllocGrid_edit.Refresh();
                    DocuGrid_edit.Refresh();

                    var curr = drpdown_Currency.GetValue();
                    Unalloc_amnt_edit.SetValue(curr + " " + response.d.totalAllocAmnt.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function approveClick() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var approve_remarks = txt_approve_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var ClassType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";
            var curr = drpdown_Currency.GetValue() != null ? drpdown_Currency.GetValue() : "";
            var payType = drpdown_PayType.GetValue() != null ? drpdown_PayType.GetValue() : "";
            var sapDoc = edit_SAPDocNo.GetValue() != null ? edit_SAPDocNo.GetValue() : "";
            console.log(costCenter);
            $.ajax({
                type: "POST",
                url: "AccedeNonPO_P2PView.aspx/btnApproveClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    approve_remarks: approve_remarks,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    costCenter: costCenter,
                    ClassType: ClassType,
                    curr: curr,
                    payType: payType,
                    sapDoc: sapDoc
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    ApprovePopup.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You approved this request. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeP2PPage.aspx';

                    } else if (funcResult == "SAPDOC error") {
                        alert("SAP Document No. is required in approving this document.");
                        edit_SAPDocNo.SetIsValid(false);
                        edit_SAPDocNo.SetErrorText("SAP Document No. is required.");
                        LoadingPanel.Hide();
                    }
                    else {
                        alert(response.d);
                        LoadingPanel.Hide();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function ReturnClick() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var return_remarks = txt_return_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var ClassType = drpdown_classification.GetValue();
            var curr = drpdown_Currency.GetValue() != null ? drpdown_Currency.GetValue() : "";
            var payType = drpdown_PayType.GetValue() != null ? drpdown_PayType.GetValue() : "";
            var sapDoc = edit_SAPDocNo.GetValue() != null ? edit_SAPDocNo.GetValue() : "";
            $.ajax({
                type: "POST",
                url: "AccedeNonPO_P2PView.aspx/btnReturnClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    return_remarks: return_remarks,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    costCenter: costCenter,
                    ClassType: ClassType,
                    curr: curr,
                    payType: payType,
                    sapDoc: sapDoc
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You returned this request. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';

                    } else {
                        alert(response.d);
                        LoadingPanel.Hide();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function DisapproveClick() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var disapprove_remarks = txt_disapprove_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            //var CTComp_id = drpdown_CTComp.GetValue();
            //var CTDept_id = drpdown_CTDepartment.GetValue();
            //var costCenter = drpdown_CostCenter.GetValue();
            //var ClassType = drpdown_classification.GetValue();
            $.ajax({
                type: "POST",
                url: "AccedeNonPO_P2PView.aspx/btnDisapproveClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    disapprove_remarks: disapprove_remarks,
                    secureToken: secureToken
                    //CTComp_id: CTComp_id,
                    //CTDept_id: CTDept_id,
                    //costCenter: costCenter,
                    //ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You disapproved this request. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';
                    } else {

                        alert(response.d);
                        LoadingPanel.Hide();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function computeNetAmount(stat) {
            if (stat == "add") {
                var qty = qty_add.GetValue() != null ? qty_add.GetValue() : 0;
                var unit_price = unit_price_add.GetValue() != null ? unit_price_add.GetValue() : 0;
                var ewt = ewt_add.GetValue() != null ? ewt_add.GetValue() : 0;
                //var vat_amnt = vat.GetValue() != null ? vat.GetValue() : 0;

                var total = qty * unit_price.toFixed(2);
                var net = total - ewt.toFixed(2);

                total_add.SetValue(total);
                net_amount_add.SetValue(net);
                ExpAllocGrid.PerformCallback();
            } else {
                var gross = total_edit.GetValue() != null ? total_edit.GetValue() : 0;
                var qty = qty_edit.GetValue() != null ? qty_edit.GetValue() : 0;
                var unit = unit_price_edit.GetValue() != null ? unit_price_edit.GetValue() : 0;
                var ewt = ewt_edit.GetValue() != null ? ewt_edit.GetValue() : 0;

                var total = ((qty) * unit).toFixed(2);
                var net = total - ewt.toFixed(2);

                net_amount_edit.SetValue(net);
                total_edit.SetValue(total);
                ExpAllocGrid_edit.PerformCallback();
            }


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

        var ViewisExpanded = false;
        function isToggleView() {

            ViewisExpanded = !ViewisExpanded;
            var layoutControl = window["ViewNonPOExpForm"];
            if (layoutControl) {

                var layoutItem = layoutControl.GetItemByName("ViewAllocGrid");
                if (layoutItem) {
                    //console.log("YAWARDS");
                    //console.log(ViewisExpanded);
                    layoutItem.SetVisible(ViewisExpanded);
                    EditbtnToggle.SetText(ViewisExpanded ? 'Hide' : 'Show');


                }
            }

            // You can also change icons here dynamically if needed

        }

        function EditReimDetails() {

            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var payMethod = payMethod_drpdown_reim_edit.GetValue();
            var io = io_lbl_reim_edit.GetValue() != null ? io_lbl_reim_edit.GetValue() : "";
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/SaveReimDetailsAJAX",
                data: JSON.stringify({

                    payMethod: payMethod,
                    io: io

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    if (response.d == "success") {
                        LoadingPanel.SetText("Updating document&hellip;");
                        LoadingPanel.Show();
                        location.reload();
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

        //function EditExpDetails() {
        //    if (ASPxClientEdit.ValidateGroup('PopupSubmit')) {

        //        var net_amount = netAmount_edit.GetValue() != 0.00 ? netAmount_edit.GetValue() : "0";
        //        var vat_amnt = vat_edit.GetValue() != 0.00 ? vat_edit.GetValue() : "0";
        //        var ewt_amnt = ewt_edit.GetValue() != 0.00 ? ewt_edit.GetValue() : "0";
        //        var io = io_edit.GetValue() != null ? io_edit.GetValue() : "";
        //        var wbs = wbs_edit.GetValue() != null ? wbs_edit.GetValue() : "";
        //        var cc = costCenter_edit.GetValue();
        //        var remarks = memo_expItemRemarks_edit.GetValue() != null ? memo_expItemRemarks_edit.GetValue() : "";
        //        var dateAdd = dateAdded_edit.GetValue() != null ? dateAdded_edit.GetValue() : "";
        //        var particular = particulars_edit.GetValue() != null ? particulars_edit.GetValue() : "";
        //        var supplier = supplier_edit.GetValue() != null ? supplier_edit.GetValue() : "";
        //        var tin = tin_edit.GetValue() != null ? tin_edit.GetValue() : "";
        //        var invoice = invoiceOR_edit.GetValue() != null ? invoiceOR_edit.GetValue() : "";
        //        var gross = grossAmount_edit.GetValue() != null ? grossAmount_edit.GetValue() : "";

        //        LoadingPanel.Show();

        //        $.ajax({
        //            type: "POST",
        //            url: "ExpenseApprovalView.aspx/SaveExpDetailsAJAX",
        //            data: JSON.stringify({

        //                net_amount: net_amount,
        //                vat_amnt: vat_amnt,
        //                ewt_amnt: ewt_amnt,
        //                io: io,
        //                wbs: wbs,
        //                cc: cc,
        //                remarks: remarks,
        //                dateAdd: dateAdd,
        //                particular: particular,
        //                supplier: supplier,
        //                tin: tin,
        //                invoice: invoice,
        //                gross: gross

        //            }),
        //            contentType: "application/json; charset=utf-8",
        //            dataType: "json",
        //            success: function (response) {
        //                // Handle success
        //                if (response.d == "success") {
        //                    LoadingPanel.SetText("Updating document&hellip;");
        //                    LoadingPanel.Show();
        //                    location.reload();
        //                } else {
        //                    alert(response.d);
        //                    LoadingPanel.Hide();
        //                }

        //            },
        //            failure: function (response) {
        //                // Handle failure
        //            }
        //        });
        //    }
        //}

        async function EditExpDetails() {
            if (ASPxClientEdit.ValidateGroup('PopupSubmit')) {
                var dateAdd = dateAdded_edit.GetValue();
                //var tin_no = tin_edit.GetValue() != null ? tin_edit.GetValue() : "";
                var invoice_no = invoice_edit.GetValue() != null ? invoice_edit.GetValue() : "";
                //var cost_center = costCenter_edit.GetValue() != null ? costCenter_edit.GetValue() : "";
                var gross_amount = total_edit.GetValue() != 0.00 ? total_edit.GetValue() : "0";
                var net_amount = net_amount_edit.GetValue() != 0.00 ? net_amount_edit.GetValue() : "0";
                //var supp = supplier_edit.GetValue() != null ? supplier_edit.GetValue() : "";
                var particu = particulars_edit.GetValue() != null ? particulars_edit.GetValue() : "";
                var acctCharge = exp_category_edit.GetValue() != null ? exp_category_edit.GetValue() : "";
                //var vat_amnt = vat_edit.GetValue() != 0.00 ? vat_edit.GetValue() : "0";
                //var ewt_amnt = ewt_edit.GetValue() != 0.00 ? ewt_edit.GetValue() : "0";
                var currency = drpdown_Currency.GetValue() != null ? drpdown_Currency.GetValue() : "";
                //var io = io_edit.GetValue() != null ? io_edit.GetValue() : "";
                //var wbs = wbs_edit.GetValue() != null ? wbs_edit.GetValue() : "";
                var remarks = expItem_desc_edit.GetValue() != null ? expItem_desc_edit.GetValue() : "";
                var EWTTAmount = spin_EWTTAmount_edit.GetValue() != 0.00 ? spin_EWTTAmount_edit.GetValue() : "0";
                var assign = txt_assign_edit.GetValue() != null ? txt_assign_edit.GetValue() : "";
                var allowance = txt_allowance_edit.GetValue() != null ? txt_allowance_edit.GetValue() : "";
                var EWTTType = drpdown_EWTTaxType_edit.GetValue() != null ? drpdown_EWTTaxType_edit.GetValue() : "";
                var EWTTCode = txt_EWTTCode_edit.GetValue() != null ? txt_EWTTCode_edit.GetValue() : "";
                var InvTCode = txt_InvTCode_edit.GetValue() != null ? txt_InvTCode_edit.GetValue() : "";
                var qty = qty_edit.GetValue() != 0.00 ? qty_edit.GetValue() : "0";
                var unit_price = unit_price_edit.GetValue() != 0.00 ? unit_price_edit.GetValue() : "0";
                var asset = txt_Asset_edit.GetValue() != null ? txt_Asset_edit.GetValue() : "";
                var subasset = txt_SubAsset_edit.GetValue() != null ? txt_SubAsset_edit.GetValue() : "";
                var altRecon = txt_AltRecon_edit.GetValue() != null ? txt_AltRecon_edit.GetValue() : "";
                var SLCode = txt_SLCode_edit.GetValue() != null ? txt_SLCode_edit.GetValue() : "";
                var SpecialGL = txt_SpecialGL_edit.GetValue() != null ? txt_SpecialGL_edit.GetValue() : "";
                var uom = exp_UOM_edit.GetValue() != null ? exp_UOM_edit.GetValue() : "";
                var ewt = ewt_edit.GetValue() != null ? ewt_edit.GetValue() : "0";
                var vat = vat_edit.GetValue() != null ? vat_edit.GetValue() : "0";

                //await SaveExpenseReport("Save2");
                LoadingPanel.Show();

                $.ajax({
                    type: "POST",
                    url: "AccedeNonPOEditPage.aspx/SaveExpDetailsAJAX",
                    data: JSON.stringify({
                        dateAdd: dateAdd,
                        //tin_no: tin_no,
                        invoice_no: invoice_no,
                        //cost_center: cost_center,
                        gross_amount: gross_amount,
                        net_amount: net_amount,
                        //supp: supp,
                        particu: particu,
                        acctCharge: acctCharge,
                        //vat_amnt: vat_amnt,
                        //ewt_amnt: ewt_amnt,
                        currency: currency,
                        //io: io,
                        //wbs: wbs,
                        remarks: remarks,
                        EWTTAmount: EWTTAmount,
                        assign: assign,
                        allowance: allowance,
                        EWTTType: EWTTType,
                        EWTTCode: EWTTCode,
                        InvTCode: InvTCode,
                        qty: qty,
                        unit_price: unit_price,
                        asset: asset,
                        subasset: subasset,
                        altRecon: altRecon,
                        SLCode: SLCode,
                        SpecialGL: SpecialGL,
                        uom: uom,
                        ewt: ewt,
                        vat: vat

                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        // Handle success
                        if (response.d == "success") {
                            LoadingPanel.SetText("Updating document&hellip;");
                            LoadingPanel.Show();
                            location.reload();
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

        function onEndCallback(s, e) {

            if (s.cpAllocationExceeded) {
                alert("Allocation Exceeded!");
                s.cpAllocationExceeded = null;  // Clear the custom property
            }


            if (s.cpComputeUnalloc) {

                var total = total_add.GetValue();
                //console.log(s.cpComputeUnalloc);
                var alloc_amnt = s.cpComputeUnalloc;
                var curr = drpdown_Currency.GetValue();

                var total_unalloc = (total - alloc_amnt);

                Unalloc_amnt.SetValue(curr + " " + total_unalloc.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
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
                var gross = total_add.GetValue();
                var curr = drpdown_Currency.GetValue();
                Unalloc_amnt.SetValue(curr + " " + gross.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
            }

            if (s.cpComputeUnalloc_edit) {

                var gross = total_edit.GetValue();
                var alloc_amnt = s.cpComputeUnalloc_edit;
                var curr = drpdown_Currency.GetValue();
                
                var total_unalloc = (gross - alloc_amnt);
                Unalloc_amnt_edit.SetValue(curr + " " + total_unalloc.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                console.log("total unalloc: " + total_unalloc);
                s.cpComputeUnalloc_edit = null;  // Clear the custom property
            }

            if (s.cpComputeUnalloc_edit == 0) {
                var gross = total_edit.GetValue();
                var curr = drpdown_Currency.GetValue();
                console.log("gross: "+ gross)
                Unalloc_amnt_edit.SetValue(curr + " " + gross.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
            }
        }

        var fileBtn = "";
        //PDF/IMAGE VIEWER
        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.
        function onViewAttachment(s, e) {

            if (e.buttonID == 'btnDownloadFile' || e.buttonID == 'btnDownloadFile1' || e.buttonID == 'btnDownloadFile2' || e.buttonID == 'btnDownloadFile3') {
                fileBtn = e.buttonID;
                var fileId = s.GetRowKey(e.visibleIndex);
                var filename;
                var fileext;
                var filebyte;

                if (e.buttonID == 'btnDownloadFile1') {
                    ExpItemMapPopup.Hide();
                }

                if (e.buttonID == 'btnDownloadFile2') {
                    CAPopup.Hide();
                }

                if (e.buttonID == 'btnDownloadFile3') {
                    expensePopup_edit.Hide();
                }

                LoadingPanel.SetText("Loading attachment&hellip;");
                LoadingPanel.Show();
                s.GetRowValues(e.visibleIndex, 'FileName;FileAttachment;FileExtension', onCallbackMultVal);

                function onCallbackMultVal(values) {
                    filename = values[0];
                    filebyte = values[1];
                    fileext = values[2];

                    $("#modalDownload").show();
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
                    $("#modalDownload").attr("href", "FileHandler.ashx?id=" + fileId);
                    $("#viewModal").modal("show");
                }

                function bytesToBase64(bytes) {
                    let binary = '';
                    bytes.forEach(byte => binary += String.fromCharCode(byte));
                    return btoa(binary);
                }

                $("#modalClose").on("click", function () {
                    $("#viewModal").modal("hide");
                    if (fileBtn == 'btnDownloadFile1') {
                        ExpItemMapPopup.Show();
                    }

                    if (fileBtn == 'btnDownloadFile2') {
                        CAPopup.Show();
                    }

                    if (e.buttonID == 'btnDownloadFile3') {
                        expensePopup_edit.Show();
                    }
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

        $("#modalClose").on("click", function () {
            $("#viewModal").modal("hide");
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
    </script><div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="FormExpApprovalView" runat="server" DataSourceID="sqlMain" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" ClientInstanceName="FormExpApprovalView">
        <SettingsAdaptivity SwitchToSingleColumnAtWindowInnerWidth="900" AdaptivityMode="SingleColumnWindowLimit">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="Your Page Name Here" ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" ColumnSpan="2" Width="100%" Name="ExpTitle">
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
                                        <dx:ASPxButton ID="btnApprove" runat="server" BackColor="#006838" Text="Approve" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	
if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	ApprovePopup.Show();
}

}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Name="AAF" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btn_AppForward" runat="server" AutoPostBack="False" BackColor="#006DD6" ClientInstanceName="btn_AppForward" Text="Approve and Forward">
                                            <ClientSideEvents Click="function(s, e) {
	
if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	ApproveForPopup.Show();
}

}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnReturn" runat="server" BackColor="#E67C03" Text="Return" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	
if (ASPxClientEdit.ValidateGroup('ExpenseEdit')) { 
	RejectPopup.Show();
}

}" />
                                            <Border BorderColor="#E67C03" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnDisapprove" runat="server" BackColor="#CC2A17" Text="Disapprove" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	DisapprovePopup.Show();
}" />
                                            <Border BorderColor="#CC2A17" />
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

                        </Items>
                    </dx:LayoutGroup>


                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>


                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>


                    <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top" Width="50%">
                        <Items>
                            <dx:LayoutGroup Caption="CHARGED TO DETAILS" ColSpan="1">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Report Date" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_ReportDate" runat="server" ClientInstanceName="name" DisplayFormatString="MM/dd/yyyy" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Creator" ColSpan="1" FieldName="FullName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CreatorName" runat="server" ClientInstanceName="txt_CreatorName" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Company" ColSpan="1" Name="edit_CTComp" FieldName="InvChargedTo_CompanyId">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CTComp" runat="server" ClientInstanceName="drpdown_CTComp" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId" Width="100%" Font-Bold="True" Font-Size="Small">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdown_CTDepartment.PerformCallback(s.GetValue());
//OnCompanyChanged(s.GetValue());
//drpdown_Comp.SetValue(s.GetValue());
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="Required field." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="InvComp_Location_Id">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="exp_CompLocation" runat="server" ClientInstanceName="exp_CompLocation" DataSourceID="SqlCompLocation" EnableTheming="True" Font-Bold="True" Font-Size="Small" TextField="Name" ValueField="ID" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
//exp_Company.SetValue(s.GetValue());
//costCenter.PerformCallback();
//exp_CTDepartment.PerformCallback(s.GetValue());
//drpdown_CostCenter.SetValue(&quot;&quot;);
//exp_EmpId.PerformCallback(s.GetValue());
//drpdwn_FAPWF.PerformCallback(s.GetValue());
}" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" Name="edit_CTDept" FieldName="InvChargedTo_DeptId">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CTDepartment" runat="server" ClientInstanceName="drpdown_CTDepartment" DataSourceID="SqlCTDepartment" DropDownWidth="500px" NullValueItemDisplayText="{1}" TextField="DepDesc" TextFormatString="{1}" ValueField="ID" Width="100%" Font-Bold="True" Font-Size="Small">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnCTDeptChanged(s.GetValue());
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="DepCode" Width="30%">
                                                        </dx:ListBoxColumn>
                                                        <dx:ListBoxColumn Caption="Description" FieldName="DepDesc" Width="70%">
                                                        </dx:ListBoxColumn>
                                                    </Columns>
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="Required field." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" Name="edit_CostCenter" FieldName="CostCenter">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CostCenter" runat="server" ClientInstanceName="drpdown_CostCenter" DataSourceID="SqlCostCenterCT" Font-Bold="True" Font-Size="Small" OnCallback="drpdown_CostCenter_Callback" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Transaction Type" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_ExpType" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Expense Category" ColSpan="1" FieldName="ExpCatName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_ExpCat" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Classification" ColSpan="1" FieldName="ClassificationName" Name="txt_ClassType" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_ExpName3" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Classification" ColSpan="1" Name="edit_ClassType" FieldName="ExpenseClassification" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_classification" runat="server" ClientInstanceName="drpdown_classification" DataSourceID="SqlClassification" TextField="ClassificationName" ValueField="ID" Width="100%" Font-Bold="True">
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="Required field." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1">
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
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="txt_Purpose" runat="server" ClientInstanceName="purpose" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
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
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top" Width="50%">
                        <Items>
                            <dx:LayoutGroup Caption="VENDOR DETAILS" ColSpan="1">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Due To Vendor" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expenseTotal" runat="server" ClientInstanceName="expenseTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="2px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Vendor Code" ColSpan="1" FieldName="VendorCode">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_vendor" runat="server" ClientInstanceName="txt_vendor" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem ColSpan="1" FieldName="VendorName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_vendorName" runat="server" ClientInstanceName="txt_vendorName" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="TIN" ColSpan="1" FieldName="VendorTIN">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_TIN" runat="server" ClientInstanceName="txt_TIN" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Address" ColSpan="1" FieldName="VendorAddress">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="memo_VendorAddress" runat="server" ClientInstanceName="memo_VendorAddress" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
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
                                    <dx:LayoutItem Caption="Invoice No." ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_InvoiceNo" runat="server" ClientInstanceName="txt_InvoiceNo" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Currency" ColSpan="1" Name="edit_Curr" FieldName="Exp_Currency">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_Currency" runat="server" ClientInstanceName="drpdown_Currency" DataSourceID="SqlCurrency" Font-Bold="True" Font-Size="Small" OnCallback="drpdown_CostCenter_Callback" TextField="CurrDescription" ValueField="CurrDescription" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Payment Type" ColSpan="1" FieldName="PaymentType" Name="edit_PayType">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_PayType" runat="server" ClientInstanceName="drpdown_PayType" DataSourceID="SqlPaymethod" Font-Bold="True" Font-Size="Small" OnCallback="drpdown_CostCenter_Callback" TextField="PMethod_name" ValueField="ID" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="SAP Doc. No." ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="edit_SAPDocNo" runat="server" ClientInstanceName="edit_SAPDocNo" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <ClientSideEvents ValueChanged="function(s, e) {
	CheckValidDocNo(s.GetValue(),0);
}" />
                                                    <ValidationSettings Display="Dynamic" EnableCustomValidation="True" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="This field is required." />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutGroup Caption="RFP DETAILS" ClientVisible="False" ColSpan="1" Name="ReimLayout">
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
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                            
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="INVOICE LINE ITEMS" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ExpGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ID" OnCustomButtonInitialize="ExpGrid_CustomButtonInitialize">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="P_Name" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Particulars">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="AcctToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TotalAmount" ShowInCustomizationForm="True" VisibleIndex="8">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="UnitPrice" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="9">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="InvMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0" Width="120px">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnViewExpDet" Text="View">
                                                                    <Image IconID="actions_open2_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006838" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEdit" Text="Edit">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="LineDescription" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="UOM" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="6">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="7">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="2" ColumnSpan="2" Width="100%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
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
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="WORKFLOW" ColCount="2" ColSpan="1" ColumnCount="2">
                                <Items>
                                    <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="CompanyShortName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_Comp" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Workflow Department" ColSpan="1" FieldName="DepDesc">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_Comp0" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="None" Width="50%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="WFName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_WF" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Workflow Sequence" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="WFGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlWFSequence" Width="100%">
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="FAP WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="None" Width="50%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="FAP Workflow" ColSpan="1" FieldName="FAPWF_Name">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_FAPWF" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="FAP Workflow Sequence" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlFAPWFSequence" Width="100%">
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="Workflow Activity" ColSpan="2" ColumnSpan="2" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="WFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFActivityGrid" DataSourceID="SqlWFActivity" Width="100%">
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
                                                        <dx:GridViewDataTextColumn Caption="Workflow" FieldName="Name" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Org Role" FieldName="Role_Name" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Approver" FieldName="FullName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="STS_Name" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5" Caption="Status">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Remarks" FieldName="Remarks" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                </Items>
                <SettingsItemCaptions HorizontalAlign="Right" />
            </dx:LayoutGroup>
        </Items>
        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
        <BackgroundImage HorizontalPosition="center" ImageUrl="../Content/Images/flat-mountains.svg'" Repeat="NoRepeat" />
    </dx:ASPxFormLayout>

        <%--End of NON PO Line Item Edit--%>
        
        <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" ContainerElementID="demoFabContent" EnableTheming="True" Theme="MaterialCompact" Visible="False">
            <ClientSideEvents Init="OnInit" ActionItemClick="OnActionItemClick" />
            <Items>
                <dx:FABAction ActionName="Cancel" ContextName="CancelContext" Text="Cancel">
                    <Image IconID="scheduling_delete_svg_white_16x16">
                    </Image>
                </dx:FABAction>
            </Items>
        </dx:ASPxFloatingActionButton>
        <dx:ASPxPopupControl ID="ApprovePopup" runat="server" HeaderText="Approve Document?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="ApprovePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxFormLayout1_E6" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxFormLayout1_E7" runat="server" Text="Are you sure you want to approve?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False" Width="80%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="mdlRemarksAppMemo" runat="server" Caption="Remarks" Width="100%" ClientInstanceName="txt_approve_remarks">
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="mdlBtnApprove" runat="server" Text="Confirm Approve" BackColor="#0D6943" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	ApprovePopup.Hide();
approveClick();
}" />
                                    <Border BorderColor="#0D6943" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxFormLayout1_E10" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	ApprovePopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
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

        <dx:ASPxPopupControl ID="RejectPopup" runat="server" HeaderText="Return Document?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="RejectPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxFormLayout1_E11" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxFormLayout1_E12" runat="server" Text="Are you sure you want to return document?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False" Width="80%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="mdlRemarksRejMemo" runat="server" Caption="Remarks" Width="100%" ClientInstanceName="txt_return_remarks">
                            <ValidationSettings EnableCustomValidation="True" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RejectGroup">
                                <RequiredField ErrorText="Remarks is required" IsRequired="True" />
                            </ValidationSettings>
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="mdlBtnReject" runat="server" Text="Confirm Return" BackColor="#E67C03" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RejectGroup')){
ReturnClick(); RejectPopup.Hide();
} 
}" />
                                    <Border BorderColor="#E67C03" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxFormLayout1_E15" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	RejectPopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
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
        <dx:ASPxPopupControl ID="DisapprovePopup" runat="server" HeaderText="Disapprove Document?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="DisapprovePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxFormLayout1_E1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxFormLayout1_E2" runat="server" Text="Are you sure you want to disapprove?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False" Width="80%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="mdlRemarksDisMemo" runat="server" Caption="Remarks" Width="100%" ClientInstanceName="txt_disapprove_remarks">
                            <ValidationSettings EnableCustomValidation="True" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="DisapproveGroup">
                                <RequiredField ErrorText="Remarks Required" IsRequired="True" />
                            </ValidationSettings>
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="mdlBtnDisapprove" runat="server" Text="Confirm Disapprove" BackColor="#CC2A17" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('DisapproveGroup')){
DisapproveClick(); DisapprovePopup.Hide();	
} 
}" />
                                    <Border BorderColor="#CC2A17" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxFormLayout1_E4" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	DisapprovePopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
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
        <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal ="true" runat="server" Text="Processing&amp;hellip;" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
    </div>
    <%--Start of Line Item NON PO View Details--%>
    <dx:ASPxPopupControl ID="ASPxPopupControl1" runat="server" FooterText="" HeaderText="Line Item Details" Width="1500px" ClientInstanceName="ExpItemMapPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None" Font-Size="Small" MaxWidth="80%">
        <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
        </CloseButtonImage>
        <ClientSideEvents CloseButtonClick="function(s, e) {
            //ASPxClientEdit.ClearEditorsInContainerById('scrollableContainer')
        }
    " />
                    <HeaderStyle BackColor="#006838" ForeColor="White" />
                    <ContentCollection>
        <dx:PopupControlContentControl runat="server">
            <div class="scrollablecontainer">
                    <dx:ASPxFormLayout ID="ViewNonPOExpForm" runat="server" Width="100%" ClientInstanceName="ViewNonPOExpForm">
                <Items>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right" ClientVisible="False">
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
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="50%" HorizontalAlign="Left">
                                <Items>
                                    <dx:LayoutItem Caption="Date" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_dateAdd" runat="server" ClientInstanceName="expLine_dateAdd" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Expense Type" ColSpan="1" Width="60%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_ExpType" runat="server" ClientInstanceName="expLine_ExpType" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Invoice" runat="server" ClientInstanceName="expLine_Invoice" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Expense Category" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_ExpCat" runat="server" ClientInstanceName="expLine_ExpCat" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Assignment" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Assign" runat="server" ClientInstanceName="expLine_Assign" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Allowance" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Allowance" runat="server" ClientInstanceName="expLine_Allowance" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Type" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_EWTTCode" runat="server" ClientInstanceName="expLine_EWTTCode" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Amount" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_EWTTaxAmnt" runat="server" ClientInstanceName="expLine_EWTTaxAmnt" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_EWTTaxCode" runat="server" ClientInstanceName="expLine_EWTTaxCode" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Invoice Tax Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_InvTaxCode" runat="server" ClientInstanceName="expLine_InvTaxCode" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Line Description" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="expLine_LineDesc" runat="server" ClientInstanceName="expLine_LineDesc" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="None" Width="50%" HorizontalAlign="Left">
                                <Items>
                                    <dx:LayoutItem Caption="Quantity" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Qty" runat="server" ClientInstanceName="expLine_Qty" Font-Bold="False" Font-Size="Small" Width="100%" DisplayFormatString="#,##0.00" HorizontalAlign="Right" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="UOM" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_UOM" runat="server" ClientInstanceName="expLine_UOM" DisplayFormatString="#,##0.00" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Unit Price" ColSpan="1" HorizontalAlign="Left">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_UnitPrice" runat="server" ClientInstanceName="expLine_UnitPrice" Font-Bold="False" Font-Size="Small" Width="100%" DisplayFormatString="#,##0.00" HorizontalAlign="Right" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Total" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Total" runat="server" ClientInstanceName="expLine_Total" Font-Bold="False" Font-Size="Small" Width="100%" DisplayFormatString="#,##0.00" HorizontalAlign="Right" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_ewt" runat="server" ClientInstanceName="expLine_ewt" DisplayFormatString="#,##0.00" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="VAT" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_vat" runat="server" ClientInstanceName="expLine_vat" DisplayFormatString="#,##0.00" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_NetAmnt" runat="server" ClientInstanceName="expLine_NetAmnt" Font-Bold="False" Font-Size="Small" Width="100%" DisplayFormatString="#,##0.00" HorizontalAlign="Right" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Asset" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_Asset" runat="server" ClientInstanceName="expLine_Asset" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Sub Asset Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_SubAsset" runat="server" ClientInstanceName="expLine_SubAsset" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Alt Recon" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_AltRecon" runat="server" ClientInstanceName="expLine_AltRecon" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="SL Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_SLCode" runat="server" ClientInstanceName="expLine_SLCode" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Special GL" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expLine_SpecialGL" runat="server" ClientInstanceName="expLine_SpecialGL" Font-Bold="False" Font-Size="Small" Width="100%" ReadOnly="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="Box" Width="100%" ClientVisible="False">
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="70%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="ViewbtnToggle" runat="server" AutoPostBack="False" ClientInstanceName="ViewbtnToggle" HorizontalAlign="Left" RenderMode="Link" Text="Show">
                                                    <ClientSideEvents Click="function(s, e) {
    isToggleView();
    }" />
                                                    <Image IconID="outlookinspired_expandcollapse_svg_32x32">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem ColSpan="1" Name="Unallocated_amnt" Caption="Unallocated Amount" Width="30%" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" ClientInstanceName="Unalloc_amnt_edit" HorizontalAlign="Right" Width="100%" Font-Bold="True" ReadOnly="True" DisplayFormatString="#,##0.00">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ClientVisible="False" Name="ViewAllocGrid">
                                        <Items>
                                            <dx:LayoutItem ColSpan="1" Width="100%" ShowCaption="False">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="ExpAllocGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid" KeyFieldName="InvoiceDetailMap_ID" OnCustomCallback="ExpAllocGrid_CustomCallback" Width="100%" DataSourceID="SqlExpMap">
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
                                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="160px" Visible="False">
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                    <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="SAP_CostCenter" ValueField="SAP_CostCenter">
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                                <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                    </PropertiesSpinEdit>
                                                                </dx:GridViewDataSpinEditColumn>
                                                                <dx:GridViewDataTextColumn FieldName="EDM_Remarks" ShowInCustomizationForm="True" VisibleIndex="7" Caption="Remarks">
                                                                </dx:GridViewDataTextColumn>
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
                            <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2" Width="100%" ClientVisible="False">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="DocuGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid1" KeyFieldName="ID" Width="100%" DataSourceID="SqlExpDetailAttach" OnCustomCallback="DocuGrid1_CustomCallback">
                                                    <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile3" Text="Open File">
                                                                    <Image IconID="pdfviewer_next_svg_16x16">
                                                                    </Image>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="4" Caption="File Size">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%" ClientVisible="False">
                            </dx:EmptyLayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:ASPxFormLayout>
            </div>
                        </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    <%--End of Line Item NON PO View Details--%>

    <%--Start of Line item NON PO Edit--%>
    <dx:ASPxPopupControl ID="expensePopup_edit" runat="server" FooterText="" HeaderText="Edit Line Item" Width="1500px" ClientInstanceName="expensePopup_edit" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None" Font-Size="Small" MaxWidth="80%">
        <CloseButtonImage IconID="outlookinspired_close_svg_white_16x16">
        </CloseButtonImage>
        <ClientSideEvents CloseButtonClick="function(s, e) {
	        //ASPxClientEdit.ClearEditorsInContainerById('scrollableContainer')
        }
    " />
                    <HeaderStyle BackColor="#006838" ForeColor="White" />
                    <ContentCollection>
        <dx:PopupControlContentControl runat="server">
            <div class="scrollablecontainer">
                    <dx:ASPxFormLayout ID="EditExpForm" runat="server" Width="100%" ClientInstanceName="EditExpForm">
                <Items>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="1px">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton12" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                        <dx:ASPxButton ID="ASPxButton13" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
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
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="50%" HorizontalAlign="Left">
                                <Items>
                                    <dx:LayoutItem Caption="Date" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxDateEdit ID="dateAdded_edit" runat="server" ClientInstanceName="dateAdded_edit" DisplayFormatString="MMMM dd, yyyy" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxDateEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
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
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="invoice_edit" runat="server" ClientInstanceName="invoice_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Expense Category" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="exp_category_edit" runat="server" ClientInstanceName="exp_category_edit" DataSourceID="SqlExpCat" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="Description" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Assignment" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_assign_edit" runat="server" ClientInstanceName="txt_assign_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Allowance" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_allowance_edit" runat="server" ClientInstanceName="txt_allowance_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Type" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_EWTTaxType_edit" runat="server" ClientInstanceName="drpdown_EWTTaxType_edit" DataSourceID="SqlExpCat" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="Description" TextFormatString="{0} - {1}" ValueField="ID" Width="100%">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Amount" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="spin_EWTTAmount_edit" runat="server" ClientInstanceName="spin_EWTTAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" MaxValue="999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
    computeNetAmount(&quot;add&quot;);
    }" />
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required!" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="EWT Tax Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_EWTTCode_edit" runat="server" ClientInstanceName="txt_EWTTCode_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Invoice Tax Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_InvTCode_edit" runat="server" ClientInstanceName="txt_InvTCode_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Line Description" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="expItem_desc_edit" runat="server" ClientInstanceName="expItem_desc_edit" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="None" Width="50%" HorizontalAlign="Left">
                                <Items>
                                    <dx:LayoutItem Caption="Quantity" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="qty_edit" runat="server" ClientInstanceName="qty_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" MaxValue="999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
    computeNetAmount(&quot;edit&quot;);
    }" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required!" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="UOM" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="exp_UOM_edit" runat="server" ClientInstanceName="exp_UOM_edit" DataSourceID="SqlUOM" Font-Bold="False" Font-Size="Small" NullValueItemDisplayText="{1}" TextField="UOFMCode" TextFormatString="{0} - {1}" ValueField="UOFMCode" Width="100%">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="UOM" FieldName="UOFMCode" Name="UOM">
                                                        </dx:ListBoxColumn>
                                                        <dx:ListBoxColumn Caption="Description" FieldName="UOFMDesc">
                                                        </dx:ListBoxColumn>
                                                    </Columns>
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Unit Price" ColSpan="1" HorizontalAlign="Left">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="unit_price_edit" runat="server" ClientInstanceName="unit_price_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" MaxValue="999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
    computeNetAmount(&quot;edit&quot;);
    }" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Total" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="total_edit" runat="server" AllowNull="False" ClientInstanceName="total_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
    //netAmount.SetValue(s.GetValue());
    ExpAllocGrid.PerformCallback();
    computeNetAmount(&quot;add&quot;);
    }" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                                                        <dx:LayoutItem Caption="EWT" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="ewt_edit" runat="server" AllowNull="False" ClientInstanceName="ewt_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
//netAmount.SetValue(s.GetValue());
	
computeNetAmount(&quot;edit&quot;);
}" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="VAT" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="vat_edit" runat="server" AllowNull="False" ClientInstanceName="vat_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <ClientSideEvents ValueChanged="function(s, e) {
//netAmount.SetValue(s.GetValue());
//ExpAllocGrid.PerformCallback();
//computeNetAmount(&quot;add&quot;);
}" />
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="net_amount_edit" runat="server" ClientInstanceName="net_amount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="False" Font-Size="Small" HorizontalAlign="Right" MaxValue="99999999999999" Number="0.00" ReadOnly="True" Width="100%">
                                                    <SpinButtons ClientVisible="False">
                                                    </SpinButtons>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <ParentContainerStyle Font-Size="Small">
                                        </ParentContainerStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Asset" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_Asset_edit" runat="server" ClientInstanceName="txt_Asset_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Sub Asset Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_SubAsset_edit" runat="server" ClientInstanceName="txt_SubAsset_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Alt Recon" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_AltRecon_edit" runat="server" ClientInstanceName="txt_AltRecon_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="SL Code" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_SLCode_edit" runat="server" ClientInstanceName="txt_SLCode_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Special GL" ColSpan="1" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_SpecialGL_edit" runat="server" ClientInstanceName="txt_SpecialGL_edit" Font-Bold="False" Font-Size="Small" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="Box" Width="100%" ClientVisible="False">
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
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
                                    <dx:LayoutItem ColSpan="1" Name="Unallocated_amnt" Caption="Unallocated Amount" Width="30%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="Unalloc_amnt_edit" runat="server" ClientInstanceName="Unalloc_amnt_edit" HorizontalAlign="Right" Width="100%" Font-Bold="True" ReadOnly="True" DisplayFormatString="#,##0.00">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ClientVisible="False" Name="EditAllocGrid">
                                        <Items>
                                            <dx:LayoutItem ColSpan="1" Width="100%" ShowCaption="False">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="ExpAllocGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid_edit" KeyFieldName="InvoiceDetailMap_ID" OnCustomCallback="ExpAllocGrid_edit_CustomCallback" OnRowDeleting="ExpAllocGrid_edit_RowDeleting" OnRowInserting="ExpAllocGrid_edit_RowInserting" Width="100%" OnRowUpdating="ExpAllocGrid_edit_RowUpdating" DataSourceID="SqlExpMap">
                                                            <ClientSideEvents EndCallback="onEndCallback" />
                                                            <SettingsPager Mode="EndlessPaging">
                                                            </SettingsPager>
                                                            <SettingsEditing Mode="Batch">
                                                            </SettingsEditing>
                                                            <Settings GridLines="None" ShowFooter="True" ShowTitlePanel="True" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <SettingsText CommandDelete="Remove" />
                                                            <Columns>
                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="160px" ShowEditButton="True">
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                    <PropertiesComboBox DataSourceID="SqlCostCenterAll" TextField="SAP_CostCenter" TextFormatString="{0}" ValueField="SAP_CostCenter">
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                                <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                    </PropertiesSpinEdit>
                                                                </dx:GridViewDataSpinEditColumn>
                                                                <dx:GridViewDataTextColumn FieldName="InvoiceDetailMap_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="InvoiceReportDetail_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Remarks" FieldName="EDM_Remarks" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                </dx:GridViewDataTextColumn>
                                                            </Columns>
                                                            <TotalSummary>
                                                                <dx:ASPxSummaryItem DisplayFormat="Total: #,#0.00" FieldName="NetAmount" ShowInColumn="Allocated Amount" ShowInGroupFooterColumn="Allocated Amount" SummaryType="Sum" Tag="Total" />
                                                            </TotalSummary>
                                                            <Styles>
                                                                <Footer Font-Bold="True" Font-Size="Medium" BackColor="#66FFCC" Font-Overline="False">
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
                            <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2" Width="100%" ClientVisible="False">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" ClientVisible="False">
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
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="DocuGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid_edit" KeyFieldName="ID" OnRowDeleting="DocuGrid_edit_RowDeleting" OnRowUpdating="DocuGrid_edit_RowUpdating" Width="100%" DataSourceID="SqlExpDetailAttach" OnCustomCallback="DocuGrid_edit_CustomCallback">
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
                                                        <dx:GridViewDataTextColumn FieldName="File_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%" ClientVisible="False">
                            </dx:EmptyLayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:ASPxFormLayout>
            </div>
                        </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    <%--End of NON PO Line Item Edit--%>

    <asp:SqlDataSource ID="sqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InvApprovalView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE ([WASSId] = @WASSId)">
        <SelectParameters>
            <asp:Parameter Name="WASSId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWFSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InvLineDetails] WHERE ([InvMain_ID] = @InvMain_ID) ORDER BY [LineNum]">
        <SelectParameters>
            <asp:Parameter Name="InvMain_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InvWFActivity] WHERE ([Document_Id] = @Document_Id)">
        <SelectParameters>
            <asp:Parameter Name="Document_Id" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlCADetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseCA] = @IsExpenseCA))">
        <SelectParameters>
            <asp:Parameter Name="Exp_ID" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReimDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseReim] = @IsExpenseReim) AND ([Status] &lt;&gt; @Status))">
        <SelectParameters>
            <asp:Parameter Name="Exp_ID" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
            <asp:Parameter DefaultValue="4" Name="Status" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_InvoiceLineDetailsMap] WHERE ([InvoiceReportDetail_ID] = @InvoiceReportDetail_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_InvoiceLineDetailsMap] WHERE [InvoiceDetailMap_ID] = @InvoiceDetailMap_ID" InsertCommand="INSERT INTO [ACCEDE_T_InvoiceLineDetailsMap] ([AccountToCharged], [CostCenterIOWBS], [VAT], [EWT], [NetAmount], [InvoiceReportDetail_ID], [Preparer_ID], [EDM_Remarks]) VALUES (@AccountToCharged, @CostCenterIOWBS, @VAT, @EWT, @NetAmount, @InvoiceReportDetail_ID, @Preparer_ID, @EDM_Remarks)" UpdateCommand="UPDATE [ACCEDE_T_InvoiceLineDetailsMap] SET [AccountToCharged] = @AccountToCharged, [CostCenterIOWBS] = @CostCenterIOWBS, [VAT] = @VAT, [EWT] = @EWT, [NetAmount] = @NetAmount, [InvoiceReportDetail_ID] = @InvoiceReportDetail_ID, [Preparer_ID] = @Preparer_ID, [EDM_Remarks] = @EDM_Remarks WHERE [InvoiceDetailMap_ID] = @InvoiceDetailMap_ID">
        <DeleteParameters>
            <asp:Parameter Name="InvoiceDetailMap_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="AccountToCharged" Type="Int32" />
            <asp:Parameter Name="CostCenterIOWBS" Type="String" />
            <asp:Parameter Name="VAT" Type="Decimal" />
            <asp:Parameter Name="EWT" Type="Decimal" />
            <asp:Parameter Name="NetAmount" Type="Decimal" />
            <asp:Parameter Name="InvoiceReportDetail_ID" Type="Int32" />
            <asp:Parameter Name="Preparer_ID" Type="String" />
            <asp:Parameter Name="EDM_Remarks" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="InvoiceReportDetail_ID" SessionField="InvDetailsID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="AccountToCharged" Type="Int32" />
            <asp:Parameter Name="CostCenterIOWBS" Type="String" />
            <asp:Parameter Name="VAT" Type="Decimal" />
            <asp:Parameter Name="EWT" Type="Decimal" />
            <asp:Parameter Name="NetAmount" Type="Decimal" />
            <asp:Parameter Name="InvoiceReportDetail_ID" Type="Int32" />
            <asp:Parameter Name="Preparer_ID" Type="String" />
            <asp:Parameter Name="EDM_Remarks" Type="String" />
            <asp:Parameter Name="InvoiceDetailMap_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL) ORDER BY [SAP_CostCenter]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetailAttach" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpDetailsFileAttach] WHERE ([ExpDetail_Id] = @ExpDetail_Id)">
        <SelectParameters>
            <asp:SessionParameter Name="ExpDetail_Id" SessionField="ExpMainId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPaymethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFSequenceForward" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenterCT" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCAWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPWFActivity] WHERE ([Document_Id] = @Document_Id)">
        <SelectParameters>
            <asp:Parameter Name="Document_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCAFileAttach" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPFileAttach] WHERE ([Doc_ID] = @Doc_ID)">
        <SelectParameters>
            <asp:Parameter Name="Doc_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlIO" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_IO] WHERE (([isActive] = @isActive) AND ([CompanyId] = @CompanyId)) ORDER BY [IO_Num]">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenterAll" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL)">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlParticulars" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_Particulars]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Currency]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompLocation" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUOM" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [RS_T_UOFMTemp] WHERE ([isActive] = @isActive) ORDER BY [UOFMCode]">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
