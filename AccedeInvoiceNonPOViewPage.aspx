<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeInvoiceNonPOViewPage.aspx.cs" Inherits="DX_WebTemplate.AccedeInvoiceNonPOViewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <%-- Bootstrap Modal --%>
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
        .scrollableContainer {
            overflow: auto;
            height: 600px;
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
                    memo_expItemRemarks.SetValue(response.d.remarks);
                    console.log(response.d.costCenter);
                    ExpAllocGrid.PerformCallback(item_id);
                    DocuGrid1.PerformCallback(item_id);
                    ExpItemMapPopup.Show();

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


                    <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ColCount="4" ColumnCount="4">
                        <Items>

                            <dx:EmptyLayoutItem ColSpan="4" ColumnSpan="4" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" ClientVisible="False" Name="edit_btn">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEdit" runat="server" BackColor="#006DD6" Text="Edit" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	redirectToEditPage();
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Name="recallBtn" HorizontalAlign="Right" Width="20%" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnRecall" runat="server" AutoPostBack="False" BackColor="#E67C03" ClientInstanceName="btnRecall" EnableTheming="True" Font-Bold="False" ForeColor="White" Text="Recall" Theme="iOS">
                                            <ClientSideEvents Click="function(s, e) {
	RecallPopup.Show();
}" />
                                            <Border BorderColor="#E67C03" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Name="PrintBtn" ClientVisible="False" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnPrint" runat="server" BackColor="#006838" ClientInstanceName="btnPrint" EnableTheming="True" Font-Bold="False" Text="Print" Theme="iOS" OnClick="btnPrint_Click">
                                            <ClientSideEvents Click="function(s, e) {
	loadPanel.Show();
}" />
                                            <Image IconID="dashboards_print_svg_white_16x16">
                                            </Image>
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

                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                        </Items>
                    </dx:LayoutGroup>


                    <dx:LayoutGroup Caption="CHARGED TO DETAILS" ColSpan="1" GroupBoxDecoration="HeadingLine">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem ColSpan="1" FieldName="ReportDate" Caption="Report Date">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" FieldName="CTCompName" Caption="Charged To Company">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox12" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="CompLocation">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox16" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="CTDeptName">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox13" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="CostCenter">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox14" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" FieldName="ExpTypeName" Caption="Transaction Type">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox4" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" FieldName="ExpCatName" Caption="Expense Category">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="ASPxTextBox6" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True">
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
                                        <dx:ASPxMemo ID="ASPxMemo1" runat="server" Font-Bold="True" Font-Size="Small" Height="71px" Width="100%" ReadOnly="True">
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
                    <dx:LayoutGroup Caption="VENDOR DETAILS" ColSpan="1" GroupBoxDecoration="HeadingLine">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem ColSpan="1" Caption="Due To Vendor" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="expenseTotal" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ClientInstanceName="expenseTotal" HorizontalAlign="Right" ReadOnly="True">
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
                            <dx:LayoutItem ColSpan="1" Caption="Vendor">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txt_Vendor" runat="server" Font-Bold="True" Font-Size="Small" Width="100%" ReadOnly="True" ClientInstanceName="txt_Vendor">
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
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
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="Expenses" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ExpGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ExpenseReportDetail_ID">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="P_Name" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Particulars">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsUploaded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
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
                                                        <dx:GridViewDataTextColumn Caption="Remarks" FieldName="ExpDetail_remarks" ShowInCustomizationForm="True" VisibleIndex="6">
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
                                                <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" DataSourceID="SqlDocs" KeyFieldName="ID" OnCustomCallback="CADocuGrid_CustomCallback" Width="100%">
                                                    <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="6">
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
                                                        <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Uploaded By" FieldName="User_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
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

        <dx:ASPxPopupControl ID="RecallPopup" runat="server" HeaderText="Recall Expense Report?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="RecallPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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
                        <dx:ASPxLabel ID="ASPxFormLayout1_E12" runat="server" Text="Are you sure you want to recall this document?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutItem ColSpan="1" HorizontalAlign="Center" ShowCaption="False" Width="80%">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="txtBox_recallRemarks" runat="server" Caption="Remarks" ClientInstanceName="txtBox_recallRemarks" Width="100%">
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
                                <dx:ASPxButton ID="mdlBtnReject" runat="server" Text="Confirm Recall" BackColor="#E67C03" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RejectGroup')){
RecallClick(); RecallPopup.Hide();
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
                <dx:ASPxPopupControl ID="CAPopup" runat="server" FooterText="" HeaderText="Cash Advance Details" Width="1146px" ClientInstanceName="CAPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" AllowDragging="True" CloseAction="CloseButton" CssClass="rounded">
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div class="scrollableContainer">
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
                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3" GroupBoxDecoration="HeadingLine">
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
                    <dx:LayoutGroup Caption="Workflow Details" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" Width="100%" GroupBoxDecoration="HeadingLine">
                        <Items>
                            <dx:LayoutItem Caption="RA Workflow" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="RAWF_lbl" runat="server" ClientInstanceName="RAWF_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="FAP Workflow" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="FAPWF_lbl" runat="server" ClientInstanceName="FAPWF_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="Workflow Activity" ColSpan="2" ColumnSpan="2" Width="100%" GroupBoxDecoration="HeadingLine">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="CAWFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CAWFActivityGrid" DataSourceID="SqlCAWFActivity" OnCustomCallback="CAWFActivityGrid_CustomCallback" Width="100%">
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
                                                <dx:GridViewDataTextColumn Caption="Status" FieldName="STS_Name" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
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
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="Supporting Documents" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="CADocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="CADocuGrid" DataSourceID="SqlCAFileAttach" KeyFieldName="ID" Width="100%" OnCustomCallback="CADocuGrid_CustomCallback">
                                            <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile2" Text="Open File">
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
                        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div class="scrollableContainer">
                        <dx:ASPxFormLayout ID="FormReim1" runat="server" Width="100%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ClientInstanceName="FormReim1">
<SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit"></SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%" Name="ReimDocNum1">
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
                    <dx:LayoutGroup Caption="Workflow Details" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="RA Workflow" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="Reim_RAWF_lbl" runat="server" ClientInstanceName="Reim_RAWF_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="FAP Workflow" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="Reim_FAPWF_lbl" runat="server" ClientInstanceName="Reim_FAPWF_lbl" Font-Bold="True" Font-Size="Small" ReadOnly="True" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="submitValid">
                                                <RequiredField ErrorText="This field is required." />
                                            </ValidationSettings>
                                            <Border BorderStyle="None" />
                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
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
        </dx:ASPxPopupControl>
        <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <dx:ASPxLoadingPanel ID="LoadingPanel" runat="server" Text="Loading&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="LoadingPanel" Modal="True">
    </dx:ASPxLoadingPanel>
    </div>
    <asp:SqlDataSource ID="sqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpApprovalView] WHERE ([ID] = @ID)">
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
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpenseDetails] WHERE ([ExpenseMain_ID] = @ExpenseMain_ID)">
        <SelectParameters>
            <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReimDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseReim] = @IsExpenseReim) AND ([Status] &lt;&gt; @Status))">
    <SelectParameters>
        <asp:Parameter Name="Exp_ID" Type="Int32" />
        <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
        <asp:Parameter DefaultValue="4" Name="Status" Type="Int32" />
    </SelectParameters>
 </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_ExpWFActivity] WHERE (([AppId] = @AppId) AND ([Document_Id] = @Document_Id) AND ([isTravel] &lt;&gt; @isTravel) AND ([DCT_Name] = @DCT_Name)) ORDER BY [DateAssigned]">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="Document_Id" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="isTravel" Type="Boolean" />
            <asp:Parameter DefaultValue="ACDE Expense" Name="DCT_Name" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_FileAttachment] WHERE (([Doc_ID] = @Doc_ID) AND ([App_ID] = @App_ID) AND ([DocType_Id] = @DocType_Id))">
        <SelectParameters>
            <asp:Parameter Name="Doc_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1032" Name="App_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1016" Name="DocType_Id" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlExpMap" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetailsMap] WHERE ([ExpenseReportDetail_ID] = @ExpenseReportDetail_ID)">
        <SelectParameters>
            <asp:Parameter Name="ExpenseReportDetail_ID" Type="Int32" />
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
