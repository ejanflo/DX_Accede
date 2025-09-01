<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeNonPO_CashierView.aspx.cs" Inherits="DX_WebTemplate.AccedeNonPO_CashierView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <%--End of View Line item PopupLayout--%>
    <%-- This is where the document is rendered and viewed --%>
    <div class="modal fade" id="viewModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-fullscreen modal-dialog-scrollable" id="modalDialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="vmodalTit"><i class="bi bi-file-earmark-pdf text-danger" style="margin-right: 0.5rem;"></i><strong id="modalTitle">Preview File</strong></h5>
                    <a id="modalDownload" href="" class="btn btn-secondary btn-sm">
                        <i class="bi bi-download text-white" style="margin-right: 0.5rem;"></i>
                        Download
                    </a>
                </div>
                <div class="modal-body container-fluid mx-auto text-center bg-secondary" id="pdf_container">
                </div>
                <div class="modal-footer" id="wmodalFooter">
                    <button type="button" id="modalClose" class="btn btn-light btn-outline-secondary btn-sm">Close</button>
                </div>
            </div>
        </div>
    </div> 
    
    <style>
        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
        .scrollablecontainer{
            overflow: auto;
            height: 80vh; /* full viewport height */
            width: 70vw;  /* full viewport width */
            border: 1px solid #ccc;
            padding: 10px;
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

        function redirectToEditPage() {
            loadPanel.Show();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            $.ajax({
                type: "POST",
                url: "AccedeInvoiceNonPOViewPage.aspx/RedirectToEditAJAX",
                data: JSON.stringify({
                    secureToken: secureToken

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Handle success
                    if (response.d == "success") {
                        window.location.href = "AccedeNonPOEditPage.aspx";
                    } else {
                        alert(response.d);
                        loadPanel.Hide();
                    }

                },
                failure: function (response) {
                    // Handle failure
                }
            });


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

        function viewCADetailModal(item_id) {
            $.ajax({
                type: "POST",
                url: "AccedeExpenseViewPage.aspx/DisplayCADetailsAJAX",
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
                    RAWF_lbl.SetValue(response.d.RAWF);
                    FAPWF_lbl.SetValue(response.d.FAPWF);
                    CAWFActivityGrid.PerformCallback(item_id);
                    CADocuGrid.PerformCallback(item_id);
                    CAPopup.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function viewExpDetailModal(expDetailID) {
            console.log(expDetailID);
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
                    console.log(response.d.dateAdded);
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
                    var layoutControl = window["FormReim1"];
                    if (layoutControl) {
                        var layoutItem = layoutControl.GetItemByName("ReimDocNum1");
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
                    Reim_RAWF_lbl.SetValue(response.d.RAWF);
                    Reim_FAPWF_lbl.SetValue(response.d.FAPWF);
                    ReimPopup.Show();

                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function RecallClick() {
            LoadingPanel.Show();
            var remarks = txtBox_recallRemarks.GetValue();
            $.ajax({
                type: "POST",
                url: "AccedeExpenseViewPage.aspx/RecallExpMainAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    remarks: remarks
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response.d == "success") {
                        LoadingPanel.SetText('Expense Successfully recalled. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AccedeExpenseReportDashboard.aspx';

                    } else {
                        alert(response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function Disburse() {
            LoadingPanel.SetText("Processing&hellip;");
            LoadingPanel.Show();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            $.ajax({
                type: "POST",
                url: "AccedeNonPO_CashierView.aspx/DisburseAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    secureToken: secureToken
                }),
                success: function (response) {

                    var funcResult = response.d;
                    // Update the description text box with the response value
                    if (funcResult == "success") {
                        LoadingPanel.SetText('Payment to vendor successfully disbursed. Redirecting&hellip;');
                        LoadingPanel.Show();

                        setTimeout(function () {
                            window.open('RFPPrintPage.aspx', '_blank');
                        }, 3000); // Adjust the time (in milliseconds) as needed

                        // Delay the redirection by, for example, 3 seconds (3000 milliseconds)
                        LoadingPanel.SetText('Printing report&hellip;');
                        LoadingPanel.Show();
                        setTimeout(function () {
                            window.location.href = 'AllAccedeCashierPage.aspx';
                        }, 3000); // Adjust the time (in milliseconds) as needed

                    

                    } else {
                        alert(response.d);
                        LoadingPanel.SetText('Disbursement failed!&hellip;');
                        LoadingPanel.Hide();

                        //window.location.href = 'AccedeCashierExpenseViewPage.aspx';
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        //PDF/IMAGE VIEWER
        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.

        function onViewAttachment(s, e) {

            if (e.buttonID == 'btnDownloadFile' || e.buttonID == 'btnDownloadFile1' || e.buttonID == 'btnDownloadFile2') {

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
                    if (e.buttonID == 'btnDownloadFile1') {
                        ExpItemMapPopup.Show();
                    }

                    if (e.buttonID == 'btnDownloadFile2') {
                        CAPopup.Show();
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
    </script>

    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="FormExpApprovalView" runat="server" DataSourceID="sqlMain" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" style="margin-right: 0px">
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

                            <dx:LayoutItem Caption="" ColSpan="1" Name="PrintBtn" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnPrint" runat="server" BackColor="#E67C03" ClientInstanceName="btnPrint" EnableTheming="True" Font-Bold="False" Text="Print" Theme="iOS" OnClick="btnPrint_Click">
                                            <ClientSideEvents Click="function(s, e) {
	loadPanel.Show();
}" />
                                            <Image IconID="dashboards_print_svg_white_16x16">
                                            </Image>
                                            <Border BorderColor="#E67C03" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" ClientVisible="False" Name="disburseBtn">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnDisburse" runat="server" BackColor="#006838" Text="Disburse" AutoPostBack="False" ClientInstanceName="btnDisburse">
                                            <ClientSideEvents Click="function(s, e) {
	DisbursePopup.Show();
}" />
                                            <Border BorderColor="#006838" />
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

                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                        </Items>
                    </dx:LayoutGroup>


                    <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top">
                        <Items>
                            <dx:LayoutGroup Caption="CHARGED TO DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="ReportDate">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Company" ColSpan="1" FieldName="CTCompName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox12" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="CompLocation">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox16" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="CTDeptName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox13" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="CostCenter">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox14" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Transaction Type" ClientVisible="False" ColSpan="1" FieldName="ExpTypeName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox4" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                                                <dx:ASPxTextBox ID="ASPxTextBox6" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Purpose" ColSpan="1" FieldName="Purpose">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="ASPxMemo1" runat="server" Font-Bold="True" Font-Size="Small" Height="71px" ReadOnly="True" Width="100%">
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
                    <dx:TabbedLayoutGroup ColSpan="1" VerticalAlign="Top">
                        <Items>
                            <dx:LayoutGroup Caption="VENDOR DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Due To Vendor" ColSpan="1" HorizontalAlign="Right">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expenseTotal" runat="server" ClientInstanceName="expenseTotal" Font-Bold="True" Font-Size="Small" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                        <ParentContainerStyle>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" />
                                        </ParentContainerStyle>
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Vendor Code" ColSpan="1" FieldName="VendorCode">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_Vendor" runat="server" ClientInstanceName="txt_Vendor" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                                                <dx:ASPxTextBox ID="txt_vendorName" runat="server" ClientInstanceName="txt_vendorName" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
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
                                    <dx:LayoutItem Caption="SAP Doc. No." ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_SAPDoc" runat="server" ClientInstanceName="txt_SAPDoc" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Invoice No." ClientVisible="False" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_InvoiceNo" runat="server" ClientInstanceName="txt_InvoiceNo" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Exp_Currency" Name="ARNo">
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
                                    <dx:LayoutItem Caption="Payment Type" ColSpan="1" FieldName="PayTypeName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txt_CTDepartment1" runat="server" ClientInstanceName="txt_CTDepartment" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
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
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="INVOICE LINE ITEMS" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ExpGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ID">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
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
                                                        <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" VisibleIndex="10">
                                                            <PropertiesTextEdit DisplayFormatString="N">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="InvMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
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
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Line Description" FieldName="LineDescription" ShowInCustomizationForm="True" VisibleIndex="2">
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
                            <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
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
                            <dx:LayoutGroup Caption="WORKFLOW" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="CompanyShortName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox3" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                                                <dx:ASPxTextBox ID="ASPxTextBox15" runat="server" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
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
                            <dx:LayoutGroup Caption="WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="WFName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox10" runat="server" Font-Bold="True" Font-Size="Smaller" ReadOnly="True" Width="100%">
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
                                                <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlWFSequence" Width="100%">
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
                                                        <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
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
                            <dx:LayoutGroup Caption="FAP WORKFLOW DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <Items>
                                    <dx:LayoutItem Caption="FAP Workflow" ColSpan="1" FieldName="FAPWF_Name">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox11" runat="server" Font-Bold="True" Font-Size="Smaller" ReadOnly="True" Width="100%">
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
                                                <dx:ASPxGridView ID="ASPxGridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlFAPWFSequence" Width="100%">
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
                                                        <dx:GridViewDataTextColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
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
                            <dx:LayoutGroup Caption="WORKFLOW ACTIVITY" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ASPxGridView3" runat="server" AutoGenerateColumns="False" DataSourceID="SqlWFActivity" KeyFieldName="WFA_Id" Width="100%">
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataDateColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlWorkflow" TextField="Name" ValueField="WF_Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Org Role" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesComboBox DataSourceID="SqlOrgRole" TextField="Description" ValueField="Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="ActedBy_User_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="5">
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
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                </Items>
                <SettingsItemCaptions HorizontalAlign="Right" />
            </dx:LayoutGroup>
        </Items>
        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
        <BackgroundImage HorizontalPosition="center" ImageUrl="../Content/Images/flat-mountains.svg'" Repeat="NoRepeat" />
    </dx:ASPxFormLayout>
        <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" ContainerElementID="demoFabContent" EnableTheming="True" Theme="MaterialCompact" Visible="False">
            <ClientSideEvents Init="OnInit" ActionItemClick="OnActionItemClick" />
            <Items>
                <dx:FABAction ActionName="Cancel" ContextName="CancelContext" Text="Cancel">
                    <Image IconID="scheduling_delete_svg_white_16x16">
                    </Image>
                </dx:FABAction>
            </Items>
        </dx:ASPxFloatingActionButton>

        <dx:ASPxPopupControl ID="DisbursePopup" runat="server" HeaderText="Disburse Payment?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="DisbursePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
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
                        <dx:ASPxLabel ID="ASPxFormLayout1_E12" runat="server" Text="Are you sure you want to disburse payment to vendor?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="mdlBtnReject" runat="server" Text="Confirm Disburse" BackColor="#006838" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	Disburse();
}" />
                                    <Border BorderColor="#006838" />
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
                <%--<dx:ASPxPopupControl ID="ExpItemMapPopup2" runat="server" FooterText="" HeaderText="Line Item Details" Width="1200px" ClientInstanceName="ExpItemMapPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div class="scrollableContainer">
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
                                                    <CaptionSettings HorizontalAlign="Right" />
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
                                                    <CaptionSettings HorizontalAlign="Right" />
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
                                                            <dx:ASPxTextBox ID="gross_lbl" runat="server" ClientInstanceName="gross_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%" DisplayFormatString="#,##0.00" HorizontalAlign="Right">
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
                                                            <dx:ASPxTextBox ID="vat_lbl" runat="server" ClientInstanceName="vat_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right" DisplayFormatString="#,##0.00">
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
                                                            <dx:ASPxTextBox ID="ewt_lbl" runat="server" ClientInstanceName="ewt_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right" DisplayFormatString="#,##0.00">
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
                                                            <dx:ASPxTextBox ID="net_lbl" runat="server" ClientInstanceName="net_lbl" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" HorizontalAlign="Right" DisplayFormatString="#,##0.00">
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
                                <dx:LayoutGroup ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                    <Items>
                                        <dx:LayoutItem Caption="Remarks" ColSpan="1" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxMemo ID="memo_expItemRemarks" runat="server" ClientInstanceName="memo_expItemRemarks" Font-Bold="True" Font-Size="Small" HorizontalAlign="Left" ReadOnly="True" Width="100%">
                                                        <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="ExpenseEdit">
                                                            <RequiredField ErrorText="*Required" />
                                                        </ValidationSettings>
                                                        <Border BorderStyle="None" />
                                                        <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxMemo>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                                <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Height="20px" Width="100%">
                                </dx:EmptyLayoutItem>
                                <dx:LayoutGroup Caption="Cost Allocation" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%">
                                    <Items>
                                        <dx:LayoutItem ColSpan="1" ShowCaption="False" Width="100%">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ExpAllocGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="ExpAllocGrid" DataSourceID="SqlExpMap" KeyFieldName="ExpenseDetailMap_ID" Width="100%" OnCustomCallback="ExpAllocGrid_CustomCallback">
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
                                                    <dx:ASPxGridView ID="DocuGrid1" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid1" DataSourceID="SqlExpDetailAttach" KeyFieldName="ID" Width="100%" OnCustomCallback="DocuGrid1_CustomCallback">
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
        </dx:ASPxPopupControl>--%>

        <%--Start of View Line item PopupLayout--%>
        <dx:ASPxPopupControl ID="ExpItemMapPopup" runat="server" FooterText="" HeaderText="Line Item Details" Width="1500px" ClientInstanceName="ExpItemMapPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded" PopupAnimationType="None" Font-Size="Small" MaxWidth="80%">
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
                        <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="None" HorizontalAlign="Right" ClientVisible="False">
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
                                        <dx:LayoutItem ColSpan="1" Name="Unallocated_amnt" Caption="Unallocated Amount" Width="30%" ClientVisible="False">
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
        <%--End of View Line item PopupLayout--%>

        <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <dx:ASPxLoadingPanel ID="LoadingPanel" runat="server" Text="Loading&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="LoadingPanel" Modal="True">
    </dx:ASPxLoadingPanel>
    </div>
    <asp:SqlDataSource ID="sqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InvApprovalView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlCA" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([TranType] = @TranType) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1" Name="TranType" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlReimDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseReim] = @IsExpenseReim) AND ([Status] &lt;&gt; @Status))">
    <SelectParameters>
        <asp:Parameter Name="Exp_ID" Type="Int32" />
        <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
        <asp:Parameter DefaultValue="4" Name="Status" Type="Int32" />
    </SelectParameters>
 </asp:SqlDataSource>
    <%--<asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpWFActivity] WHERE (([AppId] = @AppId) AND ([Document_Id] = @Document_Id) AND ([isTravel] &lt;&gt; @isTravel) AND ([DCT_Name] = @DCT_Name)) ORDER BY [DateAssigned]">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="Document_Id" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="isTravel" Type="Boolean" />
            <asp:Parameter DefaultValue="ACDE Expense" Name="DCT_Name" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>--%>
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
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_InvoiceLineDetailsMap] WHERE ([InvoiceReportDetail_ID] = @InvoiceReportDetail_ID)">
        <SelectParameters>
            <asp:Parameter Name="InvoiceReportDetail_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetailAttach" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpDetailsFileAttach] WHERE ([ExpDetail_Id] = @ExpDetail_Id)">
        <SelectParameters>
            <asp:Parameter Name="ExpDetail_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([SAP_CostCenter] IS NOT NULL) ORDER BY [SAP_CostCenter]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityOrgRoles]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPaymethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
</asp:Content>
