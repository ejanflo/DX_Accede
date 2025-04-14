<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="ExpenseApprovalView.aspx.cs" Inherits="DX_WebTemplate.ExpenseApprovalView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     
    
    <style>
        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }
        #scrollableContainer,#scrollableContainer2 {
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
    </style><script>
         function OnInit(s, e) {
             fab.SetActionContext("CancelContext", true);
             //AttachEvents();
         }
         function OnActionItemClick(s, e) {
             if (e.actionName === "Cancel") {
                 history.back()
             }
        }

        function OnCTDeptChanged(dept_id) {
            drpdown_CostCenter.PerformCallback(drpdown_CTComp.GetValue()+"|"+dept_id);
        }

        function onCustomButtonClick(s, e) {
            console.log(e.buttonID);
            if (e.buttonID == 'btnView') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewCADetailModal(item_id);
            }

            if (e.buttonID == 'btnViewExpDet') {
                console.log(e.buttonID);
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

        function viewCADetailModal(item_id) {
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/DisplayCADetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    item_id: item_id

                }),
                success: function (response) {
                    console.log("ok");
                    var layoutControl = window["FormCA"];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName("CADocNum");
                        if (layoutItem) {
                            layoutItem.SetCaption(response.d.docNum);
                        }
                    }
                    company_lbl.SetValue(response.d.company);
                    payMethod_lbl.SetValue(response.d.payMethod);
                    tranType_lbl.SetValue(response.d.tranType);
                    department_lbl.SetValue(response.d.department);
                    costCenter_lbl.SetValue(response.d.CostCenter);
                    payee_lbl.SetValue(response.d.payee);
                    purpose_lbl.SetValue(response.d.purpose);
                    amount_lbl.SetValue(response.d.amount);
                    currency_lbl.SetValue(response.d.currency);
                    CAPopup.Show();
                    
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewReimModal(item_id) {
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/DisplayReimDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    item_id: item_id

                }),
                success: function (response) {
                    console.log("ok");
                    var layoutControl = window["FormReim"];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName("ReimDocNum");
                        if (layoutItem) {
                            layoutItem.SetCaption(response.d.docNum);
                        }
                    }
                    company_lbl_reim.SetValue(response.d.company);
                    payMethod_lbl_reim.SetValue(response.d.payMethod);
                    tranType_lbl_reim.SetValue(response.d.tranType);
                    department_lbl_reim.SetValue(response.d.department);
                    costCenter_lbl_reim.SetValue(response.d.CostCenter);
                    payee_lbl_reim.SetValue(response.d.payee);
                    purpose_lbl_reim.SetValue(response.d.purpose);
                    amount_lbl_reim.SetValue(response.d.amount);
                    currency_lbl_reim.SetValue(response.d.currency);
                    ReimPopup.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewReimModal2(item_id) {
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/DisplayReimDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    item_id: item_id

                }),
                success: function (response) {
                    console.log("ok");
                    var layoutControl = window["FormReim"];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName("ReimDocNum");
                        if (layoutItem) {
                            layoutItem.SetCaption(response.d.docNum);
                        }
                    }
                    company_lbl_reim_edit.SetValue(response.d.company);
                    payMethod_drpdown_reim_edit.SetValue(response.d.payMethod_id);
                    console.log(response.d.payMethod_id);
                    tranType_lbl_reim_edit.SetValue(response.d.tranType);
                    department_lbl_reim_edit.SetValue(response.d.department);
                    costCenter_lbl_reim_edit.SetValue(response.d.CostCenter);
                    payee_lbl_reim_edit.SetValue(response.d.payee);
                    purpose_lbl_reim_edit.SetValue(response.d.purpose);
                    amount_lbl_reim_edit.SetValue(response.d.amount);
                    currency_lbl_reim_edit.SetValue(response.d.currency);
                    ReimPopup_edit.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewExpDetailModal(item_id) {
            console.log(item_id);
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    item_id: item_id

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

                    particulars_lbl.SetValue(response.d.particulars);
                    supplier_lbl.SetValue(response.d.supplier);
                    tin_lbl.SetValue(response.d.tin);
                    invoice_lbl.SetValue(response.d.invoice);
                    gross_lbl.SetValue(response.d.gross);
                    dateCreated_lbl.SetValue(response.d.dateCreated);
                    acctChargeExp_lbl.SetValue(response.d.acctCharge);
                    costCenterExp_lbl.SetValue(response.d.costCenter);
                    net_lbl.SetValue(response.d.net);
                    vat_lbl.SetValue(response.d.vat);
                    ewt_lbl.SetValue(response.d.ewt);
                    io_expd_lbl.SetValue(response.d.io);
                    wbs_expd_lbl.SetValue(response.d.wbs);
                    console.log(response.d.costCenter);
                    ExpAllocGrid.Refresh();
                    DocuGrid1.Refresh();
                    ExpItemMapPopup.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewExpDetailModal2(item_id) {
            console.log(item_id);
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/DisplayExpDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    item_id: item_id

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

                    particulars_edit.SetValue(response.d.particulars);
                    supplier_edit.SetValue(response.d.supplier);
                    tin_edit.SetValue(response.d.tin);
                    invoiceOR_edit.SetValue(response.d.invoice);
                    grossAmount_edit.SetValue(response.d.gross);
                    dateAdded_edit.SetValue(response.d.dateCreated);
                    //acctChargeExp_edit.SetValue(response.d.acctCharge);
                    costCenter_edit.SetValue(response.d.costCenter);
                    netAmount_edit.SetValue(response.d.net);
                    vat_edit.SetValue(response.d.vat);
                    ewt_edit.SetValue(response.d.ewt);
                    io_edit.SetValue(response.d.io);
                    wbs_edit.SetValue(response.d.wbs);

                    ExpAllocGrid_edit.Refresh();
                    //DocuGrid1_edit.Refresh();
                    expensePopup_edit.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function approveForwardClick() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var forwardWF = drpdown_ForwardWF.GetValue() != null ? drpdown_ForwardWF.GetValue() : "";
            var remarks = txt_forward_remarks.GetValue() != null ? txt_forward_remarks.GetValue() : "";
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var ClassType = drpdown_classification.GetValue();

            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/btnApproveForwardAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    secureToken: secureToken,
                    forwardWF: forwardWF,
                    remarks: remarks,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    costCenter: costCenter,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You approved this document. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AccedeApprovalPage.aspx';

                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: 'There is an error approving this document.',
                            icon: 'error',
                            showCancelButton: false,
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'OK',
                            allowOutsideClick: false
                        }).then((result) => {
                            if (result.isConfirmed) {
                                // If user clicks OK, call the C# function
                                LoadingPanel.SetText('Redirecting&hellip;');
                                LoadingPanel.Show();
                                window.location.href = 'AccedeApprovalPage.aspx';

                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function approveClick() {
            LoadingPanel.Show();
            var approve_remarks = txt_approve_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var ClassType = drpdown_classification.GetValue();
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/btnApproveClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    approve_remarks: approve_remarks,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    costCenter: costCenter,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    ApprovePopup.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You approved this request. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AccedeApprovalPage.aspx';

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

        function ReturnClick() {
            LoadingPanel.Show();
            var return_remarks = txt_return_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = drpdown_CTComp.GetValue();
            var CTDept_id = drpdown_CTDepartment.GetValue();
            var costCenter = drpdown_CostCenter.GetValue();
            var ClassType = drpdown_classification.GetValue();
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/btnReturnClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    return_remarks: return_remarks,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    costCenter: costCenter,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You returned this request. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AccedeApprovalPage.aspx';

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
            LoadingPanel.Show();
            var disapprove_remarks = txt_disapprove_remarks.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            //var CTComp_id = drpdown_CTComp.GetValue();
            //var CTDept_id = drpdown_CTDepartment.GetValue();
            //var costCenter = drpdown_CostCenter.GetValue();
            //var ClassType = drpdown_classification.GetValue();
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/btnDisapproveClickAjax",
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
                        window.location.href = 'AccedeApprovalPage.aspx';
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

        function EditReimDetails() {

            LoadingPanel.Show();
            var payMethod = payMethod_drpdown_reim_edit.GetValue();
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/SaveReimDetailsAJAX",
                data: JSON.stringify({

                    payMethod : payMethod

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

        function EditExpDetails() {
            if (ASPxClientEdit.ValidateGroup('PopupSubmit')) {
                
                var net_amount = netAmount_edit.GetValue() != 0.00 ? netAmount_edit.GetValue() : "0";
                var vat_amnt = vat_edit.GetValue() != 0.00 ? vat_edit.GetValue() : "0";
                var ewt_amnt = ewt_edit.GetValue() != 0.00 ? ewt_edit.GetValue() : "0";
                var io = io_edit.GetValue() != null ? io_edit.GetValue() : "";
                var wbs = wbs_edit.GetValue() != null ? wbs_edit.GetValue() : "";

                LoadingPanel.Show();

                $.ajax({
                    type: "POST",
                    url: "ExpenseApprovalView.aspx/SaveExpDetailsAJAX",
                    data: JSON.stringify({
                        
                        net_amount: net_amount,
                        vat_amnt: vat_amnt,
                        ewt_amnt: ewt_amnt,
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


        //PDF/IMAGE VIEWER
        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.
        function onViewAttachment(s, e) {

            if (e.buttonID == 'btnDownloadFile' || e.buttonID == 'btnDownloadFile1') {

                var fileId = s.GetRowKey(e.visibleIndex);
                var filename;
                var fileext;
                var filebyte;

                ExpItemMapPopup.Hide();

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
                    ExpItemMapPopup.Show();
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

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
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

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" ClientVisible="False">
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


                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="EXPENSE HEADER DETAILS" ColSpan="1">
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
                                    <dx:LayoutItem Caption="Employee Name" ColSpan="1" FieldName="ReportName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_ExpName" runat="server" ClientInstanceName="name" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
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
                                    <dx:LayoutItem Caption="Charged To Company" ColSpan="1" FieldName="CTCompName" Name="txt_CTComp">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CTCompany" runat="server" ClientInstanceName="txt_CTCompany" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Company" ColSpan="1" Name="edit_CTComp" FieldName="ExpChargedTo_CompanyId">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CTComp" runat="server" ClientInstanceName="drpdown_CTComp" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId" Width="100%" Font-Bold="True">
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
                                    <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="CompLocation">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CompLocation" runat="server" ClientInstanceName="txt_CompLocation" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="CTDeptName" Name="txt_CTDept">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CTDepartment" runat="server" ClientInstanceName="txt_CTDepartment" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" Name="edit_CTDept" FieldName="ExpChargedTo_DeptId">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CTDepartment" runat="server" ClientInstanceName="drpdown_CTDepartment" DataSourceID="SqlCTDepartment" DropDownWidth="500px" NullValueItemDisplayText="{1}" OnCallback="drpdown_CTDepartment_Callback" TextField="DepDesc" TextFormatString="{1}" ValueField="ID" Width="100%" Font-Bold="True">
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
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="CostCenter" Name="txt_CostCenter">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CostCenter" runat="server" ClientInstanceName="txt_CostCenter" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
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
                                    <dx:LayoutItem Caption="Classification" ColSpan="1" FieldName="ClassificationName" Name="txt_ClassType">
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
                                    <dx:LayoutItem Caption="Classification" ColSpan="1" Name="edit_ClassType" FieldName="ExpenseClassification">
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
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="CASH ADVANCE DETAILS" ColSpan="1">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Cash Advance" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="caTotal" runat="server" ClientInstanceName="caTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
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
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1" Name="due_lbl">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="dueTotal" runat="server" ClientInstanceName="dueTotal" Font-Bold="True" Font-Size="Medium" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="AR Reference No." ClientVisible="False" ColSpan="1" FieldName="AR_Reference_No" Name="ARNo">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CTDepartment0" runat="server" ClientInstanceName="txt_CTDepartment" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Remarks" ColSpan="1" FieldName="remarks" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="txt_remarks" runat="server" ClientInstanceName="txt_remarks" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
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
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="Cash Advances" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                             
                                                <dx:ASPxGridView ID="CAGrid" runat="server" AutoGenerateColumns="False" DataSourceID="SqlCADetails" KeyFieldName="ID" Width="100%">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
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
                                                        <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="View">
                                                                    <Image IconID="actions_open2_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006838" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Department" FieldName="DepDesc" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="payeeName" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Payee">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Payment Method" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                             
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Expenses" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ExpGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ExpenseReportDetail_ID" OnCustomButtonInitialize="ExpGrid_CustomButtonInitialize">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="P_Name" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Particulars">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsUploaded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
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
                                                        <dx:GridViewDataTextColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Reimbursements" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ReimburseGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlReimDetails" KeyFieldName="ID">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
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
                                                        <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnViewReim" Text="View">
                                                                    <Image IconID="actions_open2_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006838" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnEditReim" Text="Edit">
                                                                    <Image IconID="iconbuilder_actions_edit_svg_white_16x16">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#006DD6" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Department" FieldName="DepDesc" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="6" Caption="Payment Method">
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
                                                <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" DataSourceID="SqlDocs" KeyFieldName="ID" Width="100%">
                                                    <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile" Text="Open File">
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
                                                        <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
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

        <dx:ASPxPopupControl ID="CAPopup" runat="server" FooterText="" HeaderText="Cash Advance Details" Width="1146px" ClientInstanceName="CAPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('reimDiv')
            }" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="reimDiv">
                        <dx:ASPxFormLayout ID="FormCA" runat="server" Width="100%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ClientInstanceName="FormCA">
<SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit"></SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%" Name="CADocNum">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyShortName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="company_lbl" runat="server" ClientInstanceName="company_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1" FieldName="PMethod_name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payMethod_lbl" runat="server" ClientInstanceName="payMethod_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Type of Transaction" ColSpan="1" FieldName="RFPTranType_Name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="tranType_lbl" runat="server" Width="100%" ReadOnly="True" ClientInstanceName="tranType_lbl" Font-Bold="True" Font-Size="Small">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ClientVisible="False" ColSpan="1" Name="wbs" FieldName="WBS">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="wbs_lbl" runat="server" ClientInstanceName="wbs_lbl" Width="100%" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Department" ColSpan="1" FieldName="DepDesc">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="department_lbl" runat="server" ClientInstanceName="department_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="costCenter_lbl" runat="server" Width="100%" ClientInstanceName="costCenter_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ColSpan="1" ClientVisible="False" FieldName="IO_Num">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="io_lbl" runat="server" Width="100%" ClientInstanceName="io_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" FieldName="payeeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payee_lbl" runat="server" Width="100%" ClientInstanceName="payee_lbl" ReadOnly="True" Font-Bold="True" Font-Size="Small">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ColSpan="1" ClientVisible="False" FieldName="AcctChargeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="acctCharge_lbl" runat="server" ClientInstanceName="acctCharge_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" ColumnSpan="2" Width="100%" FieldName="Purpose">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="purpose_lbl" runat="server" ClientInstanceName="purpose_lbl" Height="71px" ReadOnly="True" Width="100%" Font-Bold="True" Font-Size="Small">
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3">
                        <Items>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" FieldName="Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="amount_lbl" runat="server" ClientInstanceName="amount_lbl" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Currency">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="currency_lbl" runat="server" ClientInstanceName="currency_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
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
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup ColCount="3" ColSpan="2" ColumnCount="3" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ClientVisible="False">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="popupSubmitBtn1" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" HorizontalAlign="Right" Text="Add" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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

        <dx:ASPxPopupControl ID="ReimPopup" runat="server" FooterText="" HeaderText="Reimbursement Details" Width="1146px" ClientInstanceName="ReimPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('reimDiv')
            }" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="reimDiv">
                        <dx:ASPxFormLayout ID="FormReim" runat="server" Width="100%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ClientInstanceName="FormReim">
<SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit"></SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%" Name="ReimDocNum">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyShortName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="company_lbl_reim" runat="server" ClientInstanceName="company_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1" FieldName="PMethod_name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payMethod_lbl_reim" runat="server" ClientInstanceName="payMethod_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Type of Transaction" ColSpan="1" FieldName="RFPTranType_Name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="tranType_lbl_reim" runat="server" Width="100%" ReadOnly="True" ClientInstanceName="tranType_lbl_reim" Font-Bold="True" Font-Size="Small">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ClientVisible="False" ColSpan="1" Name="wbs" FieldName="WBS">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="wbs_lbl_reim" runat="server" ClientInstanceName="wbs_lbl_reim" Width="100%" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Department" ColSpan="1" FieldName="DepDesc">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="department_lbl_reim" runat="server" ClientInstanceName="department_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="costCenter_lbl_reim" runat="server" Width="100%" ClientInstanceName="costCenter_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ColSpan="1" ClientVisible="False" FieldName="IO_Num">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="io_lbl_reim" runat="server" Width="100%" ClientInstanceName="io_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" FieldName="payeeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payee_lbl_reim" runat="server" Width="100%" ClientInstanceName="payee_lbl_reim" ReadOnly="True" Font-Bold="True" Font-Size="Small">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ColSpan="1" ClientVisible="False" FieldName="AcctChargeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="acctCharge_lbl_reim" runat="server" ClientInstanceName="acctCharge_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" ColumnSpan="2" Width="100%" FieldName="Purpose">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="purpose_lbl_reim" runat="server" ClientInstanceName="purpose_lbl_reim" Height="71px" ReadOnly="True" Width="100%" Font-Bold="True" Font-Size="Small">
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3">
                        <Items>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" FieldName="Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="amount_lbl_reim" runat="server" ClientInstanceName="amount_lbl_reim" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Currency">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="currency_lbl_reim" runat="server" ClientInstanceName="currency_lbl_reim" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="Remarks" ClientVisible="False" ColSpan="2" ColumnSpan="2" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="ASPxMemo2" runat="server" ClientInstanceName="remarks_reim" Height="71px" Width="100%">
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup ColCount="3" ColSpan="2" ColumnCount="3" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ClientVisible="False">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton1" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" HorizontalAlign="Right" Text="Add" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                        <dx:ASPxButton ID="ASPxButton2" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" UseSubmitBehavior="False">
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

        <dx:ASPxPopupControl ID="ExpItemMapPopup" runat="server" FooterText="" HeaderText="Expense Item Details" Width="1200px" ClientInstanceName="ExpItemMapPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollableContainer">
                        <dx:ASPxFormLayout ID="ASPxFormLayout6" runat="server" Width="100%">
                    <Items>
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right" ClientVisible="False">
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
                     //ASPxClientEdit.ClearEditorsInContainerById('expDiv');
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
                                        <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                            <Items>
                                                <dx:LayoutItem Caption="Particulars" ColSpan="1" Width="50%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="particulars_lbl" runat="server" ClientInstanceName="particulars_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="Supplier" ColSpan="1" Width="50%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="supplier_lbl" runat="server" ClientInstanceName="supplier_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="Vendor TIN" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="tin_lbl" runat="server" ClientInstanceName="tin_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="invoice_lbl" runat="server" ClientInstanceName="invoice_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="IO" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="io_expd_lbl" runat="server" ClientInstanceName="io_expd_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                                    <RequiredField ErrorText="*Required" />
                                                                </ValidationSettings>
                                                                <Border BorderStyle="None" />
                                                                <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="WBS" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="wbs_expd_lbl" runat="server" ClientInstanceName="wbs_expd_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                                <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="PopupSubmit">
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
                                        <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                            <Items>
                                                <dx:LayoutItem Caption="Date" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="dateCreated_lbl" runat="server" ClientInstanceName="dateCreated_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="costCenterExp_lbl" runat="server" ClientInstanceName="costCenterExp_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                                <dx:LayoutItem Caption="Gross Amount" ColSpan="1" Width="50%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="gross_lbl" runat="server" ClientInstanceName="gross_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%" DisplayFormatString="#,##0.00 PHP" HorizontalAlign="Right">
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
                                                <dx:LayoutItem Caption="VAT" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="vat_lbl" runat="server" ClientInstanceName="vat_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right">
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
                                                            <dx:ASPxTextBox ID="ewt_lbl" runat="server" ClientInstanceName="ewt_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right">
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
                                                <dx:LayoutItem Caption="Net Amount" ColSpan="1">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="net_lbl" runat="server" ClientInstanceName="net_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right">
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
                                                <dx:LayoutItem Caption="Account to be Charged" ClientVisible="False" ColSpan="1" Width="50%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="acctChargeExp_lbl" runat="server" ClientInstanceName="acctChargeExp_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                            </Items>
                                        </dx:LayoutGroup>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%">
                                    <Items>
                                        <dx:LayoutItem ColSpan="1" ShowCaption="False" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ExpAllocGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid" DataSourceID="SqlExpMap" KeyFieldName="ExpenseDetailMap_ID" Width="100%">
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
                                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" Visible="False" VisibleIndex="0" Width="160px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="SAP_CostCenter" ValueField="SAP_CostCenter">
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataSpinEditColumn Caption="Allocated Amount" FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatString="#,##0.00" NumberFormat="Custom">
                                                                </PropertiesSpinEdit>
                                                            </dx:GridViewDataSpinEditColumn>
                                                            <dx:GridViewDataTextColumn Caption="Remarks" FieldName="EDM_Remarks" ShowInCustomizationForm="True" VisibleIndex="7">
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
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%">
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="DocuGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid1" DataSourceID="SqlExpDetailAttach" KeyFieldName="ID" Width="100%">
                                                        <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                <CustomButtons>
                                                                    <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile1" Text="Open File">
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
                                                            <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
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
        <dx:ASPxPopupControl ID="expensePopup_edit" runat="server" FooterText="" HeaderText="Edit Expense Item" Width="1200px" ClientInstanceName="expensePopup_edit" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None">
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="scrollableContainer2">
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
                                                    <dx:ASPxTextBox ID="dateAdded_edit" runat="server" ClientInstanceName="dateAdded_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                                        <dx:LayoutItem Caption="Cost Center" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxComboBox ID="costCenter_edit" runat="server" ClientInstanceName="costCenter_edit" DataSourceID="sqlCostCenter" Font-Bold="True" Font-Size="Small" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%" ReadOnly="True">
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
                                        <dx:LayoutItem Caption="Particulars" ColSpan="1" Width="60%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="particulars_edit" runat="server" ClientInstanceName="particulars_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                                        <dx:LayoutItem Caption="IO" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="io_edit" runat="server" ClientInstanceName="io_edit" Font-Bold="True" Font-Size="Small" Width="100%">
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
                                                    <dx:ASPxTextBox ID="supplier_edit" runat="server" ClientInstanceName="supplier_edit" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                        <dx:LayoutItem Caption="Gross Amount" ColSpan="1" Name="gross_edit">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="grossAmount_edit" runat="server" AllowNull="False" ClientInstanceName="grossAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" Increment="100" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right" ReadOnly="True">
                                                        <SpinButtons ClientVisible="False">
                                                        </SpinButtons>
                                                        <ClientSideEvents ValueChanged="function(s, e) {
	//netAmount_edit.SetValue(s.GetValue());
	//ExpAllocGrid_edit.PerformCallback();
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
                                                    <dx:ASPxTextBox ID="tin_edit" runat="server" ClientInstanceName="tin_edit" Font-Bold="True" Font-Size="Small" Width="50%" ReadOnly="True">
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
                                        <dx:LayoutItem Caption="Net Amount" ColSpan="1" Name="net_edit">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="netAmount_edit" runat="server" ClientInstanceName="netAmount_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="99999999999999" Number="0.00" Width="100%" HorizontalAlign="Right" ReadOnly="True">
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
                                        <dx:LayoutItem Caption="Invoice/OR No." ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="invoiceOR_edit" runat="server" ClientInstanceName="invoiceOR_edit" Font-Bold="True" Font-Size="Small" Width="50%" ReadOnly="True">
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
                                        <dx:LayoutItem Caption="VAT" ColSpan="1" Name="vat_edit">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="vat_edit" runat="server" ClientInstanceName="vat_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
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
                                                    <dx:ASPxTextBox ID="wbs_edit" runat="server" ClientInstanceName="wbs_edit" Font-Bold="True" Font-Size="Small" Width="100%">
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
                                        <dx:LayoutItem Caption="EWT" ColSpan="1" HorizontalAlign="Left" Width="55%" Name="ewt_edit">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxSpinEdit ID="ewt_edit" runat="server" ClientInstanceName="ewt_edit" DecimalPlaces="2" DisplayFormatString="N" Font-Bold="True" Font-Size="Small" MaxValue="999999999" Number="0.00" Width="100%" HorizontalAlign="Right">
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
                                        <dx:EmptyLayoutItem ColSpan="1">
                                        </dx:EmptyLayoutItem>
                                        <dx:EmptyLayoutItem ColSpan="1">
                                        </dx:EmptyLayoutItem>
                                    </Items>
                                    <ParentContainerStyle ForeColor="Red">
                                    </ParentContainerStyle>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                </dx:EmptyLayoutItem>
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
                                        <dx:LayoutItem Caption="Unallocated Amount" ColSpan="1" Name="Unalloc_amnt_edit" Width="30%" ClientVisible="False">
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
                                                    <dx:ASPxGridView ID="ExpAllocGrid_edit" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid_edit" DataSourceID="SqlExpMap" KeyFieldName="ExpenseDetailMap_ID" Width="100%">
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
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="160px" Visible="False">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Cost Center" FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                <PropertiesComboBox DataSourceID="sqlCostCenter" TextField="SAP_CostCenter" ValueField="SAP_CostCenter">
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
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
                </div>
                            </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>
        <dx:ASPxPopupControl ID="ReimPopup_edit" runat="server" FooterText="" HeaderText="Edit Reimbursement Details" Width="1146px" ClientInstanceName="ReimPopup_edit" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
            <ClientSideEvents Closing="function(s, e) {
	            ASPxClientEdit.ClearEditorsInContainerById('reimDiv')
            }" />
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div id="reimDiv">
                        <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ClientInstanceName="FormReim">
<SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit"></SettingsAdaptivity>
        <Items>
<dx:LayoutGroup Caption="" ColCount="4" ColumnCount="4" GroupBoxDecoration="None" ColSpan="1" HorizontalAlign="Right">
<Items>
<dx:LayoutItem Caption="" ColSpan="1" Width="1px" HorizontalAlign="Right"><LayoutItemNestedControlCollection>
<dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton7" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                    <ClientSideEvents Click="function(s, e) {
	EditReimDetails();
}" />
                                    <Border BorderColor="#006838" />
                                </dx:ASPxButton>

                            </dx:LayoutItemNestedControlContainer>
</LayoutItemNestedControlCollection>

</dx:LayoutItem>
    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="1px">
        <LayoutItemNestedControlCollection>
            <dx:LayoutItemNestedControlContainer runat="server">
                <dx:ASPxButton ID="ASPxButton8" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                    <ClientSideEvents Click="function(s, e) {
                     //ASPxClientEdit.ClearEditorsInContainerById('expDiv');
                     ReimPopup_edit.Hide();
            }" />
                    <Border BorderColor="#878787" />
                </dx:ASPxButton>
            </dx:LayoutItemNestedControlContainer>
        </LayoutItemNestedControlCollection>
    </dx:LayoutItem>
</Items>

</dx:LayoutGroup>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%" Name="ReimDocNum">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyShortName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="company_lbl_reim_edit" runat="server" ClientInstanceName="company_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1" FieldName="PMethod_name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="payMethod_drpdown_reim_edit" runat="server" Width="100%" DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID" ClientInstanceName="payMethod_drpdown_reim_edit">
                                            <Border BorderColor="#006838" BorderWidth="1px" />
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Type of Transaction" ColSpan="1" FieldName="RFPTranType_Name">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="tranType_lbl_reim_edit" runat="server" ClientInstanceName="tranType_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ClientVisible="False" ColSpan="1" FieldName="WBS" Name="wbs">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="wbs_lbl_reim_edit" runat="server" ClientInstanceName="wbs_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>


                    <dx:LayoutGroup Caption="" ColSpan="1" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="Department" ColSpan="1" FieldName="DepDesc">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="department_lbl_reim_edit" runat="server" ClientInstanceName="department_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="costCenter_lbl_reim_edit" runat="server" ClientInstanceName="costCenter_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ClientVisible="False" ColSpan="1" FieldName="IO_Num">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="io_lbl_reim_edit" runat="server" ClientInstanceName="io_lbl_reim_edit" Width="100%" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" FieldName="payeeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="payee_lbl_reim_edit" runat="server" Width="100%" ReadOnly="True" ClientInstanceName="payee_lbl_reim_edit" Font-Bold="True" Font-Size="Small">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ClientVisible="False" ColSpan="1" FieldName="AcctChargeName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="acctCharge_lbl_reim_edit" runat="server" ClientInstanceName="acctCharge_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" ColumnSpan="2" Width="100%" FieldName="Purpose">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxMemo ID="purpose_lbl_reim_edit" runat="server" ClientInstanceName="purpose_lbl_reim_edit" Height="71px" ReadOnly="True" Width="100%" Font-Bold="True" Font-Size="Small">
                                    <Border BorderStyle="None" />
                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                </dx:ASPxMemo>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                    </dx:LayoutItem>
                    <dx:LayoutGroup Caption="" ColSpan="2" Width="100%" ColCount="3" ColumnCount="3" ColumnSpan="2">
                        <Items>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" FieldName="Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="amount_lbl_reim_edit" runat="server" ClientInstanceName="amount_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%" DisplayFormatString="#,##0.00">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Currency">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="currency_lbl_reim_edit" runat="server" Width="100%" ClientInstanceName="currency_lbl_reim_edit" Font-Bold="True" Font-Size="Small" ReadOnly="True">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="Remarks" ColSpan="2" ClientVisible="False" ColumnSpan="2" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="remarks_reim_edit" runat="server" ClientInstanceName="remarks_reim_edit" Height="71px" Width="100%">
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3" ClientVisible="False" GroupBoxDecoration="None" HorizontalAlign="Right">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton3" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" HorizontalAlign="Right" Text="Add" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
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
                                        <dx:ASPxButton ID="ASPxButton4" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" UseSubmitBehavior="False">
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

        <dx:ASPxPopupControl ID="ApproveForPopup" runat="server" HeaderText="Approve and Forward this Document?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="ApproveForPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="800px">
        <SettingsAdaptivity VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout5" runat="server" Width="100%">
        <Items>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxImage1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Are you sure you want to approve and forward?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:EmptyLayoutItem ColSpan="1">
            </dx:EmptyLayoutItem>
            <dx:LayoutItem Caption="Forward to" ColSpan="1">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxComboBox ID="drpdown_ForwardWF" runat="server" ClientInstanceName="drpdown_ForwardWF" Width="100%">
                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnFowardWFChanged(s.GetValue());
}" />
                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ApproveForwardGroup">
                                <ErrorImage IconID="iconbuilder_security_warningcircled2_svg_16x16">
                                </ErrorImage>
                                <RequiredField ErrorText="Required" IsRequired="True" />
                            </ValidationSettings>
                        </dx:ASPxComboBox>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:EmptyLayoutItem ColSpan="1">
            </dx:EmptyLayoutItem>
            <dx:LayoutGroup Caption="Workflow Details" ColSpan="1">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="WFSequenceGrid0" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid0" DataSourceID="SqlWFSequenceForward" Width="100%" OnCustomCallback="WFSequenceGrid0_CustomCallback">
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
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False" Width="80%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="txt_forward_remarks" runat="server" Caption="Remarks" Width="100%" ClientInstanceName="txt_forward_remarks">
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="mdlBtnApproveForward" runat="server" Text="Confirm Approve and Forward" BackColor="#006DD6" AutoPostBack="False" ClientInstanceName="mdlBtnApproveForward">
                                    <ClientSideEvents Click="function(s, e) {

if(ASPxClientEdit.ValidateGroup('ApproveForwardGroup')){
ApproveForPopup.Hide();
approveForwardClick();
}
}" />
                                    <Border BorderColor="#006DD6" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton9" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	ApproveForPopup.Hide();
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
    <asp:SqlDataSource ID="sqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpApprovalView] WHERE ([ID] = @ID)">
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
    
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpenseDetails] WHERE ([ExpenseMain_ID] = @ExpenseMain_ID)">
        <SelectParameters>
            <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpWFActivity] WHERE ([Document_Id] = @Document_Id)">
        <SelectParameters>
            <asp:Parameter Name="Document_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_FileAttachment] WHERE (([Doc_ID] = @Doc_ID) AND ([App_ID] = @App_ID) AND ([DocType_Id] = @DocType_Id))">
        <SelectParameters>
            <asp:Parameter Name="Doc_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1032" Name="App_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1016" Name="DocType_Id" Type="Int32" />
        </SelectParameters>
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
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetailsMap] WHERE ([ExpenseReportDetail_ID] = @ExpenseReportDetail_ID)">
        <SelectParameters>
            <asp:SessionParameter Name="ExpenseReportDetail_ID" SessionField="ExpMainId" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL) ORDER BY [SAP_CostCenter]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server"></asp:SqlDataSource>
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
        <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlCostCenterCT" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
</asp:SqlDataSource>
</asp:Content>
