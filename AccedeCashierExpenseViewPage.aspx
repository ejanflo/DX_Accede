<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeCashierExpenseViewPage.aspx.cs" Inherits="DX_WebTemplate.AccedeCashierExpenseViewPage" %>
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

        function onCustomButtonClick(s, e) {
            if (e.buttonID == 'btnView') {
                var item_id = s.GetRowKey(e.visibleIndex);

                viewCADetailModal(item_id);
            }

            if (e.buttonID == 'btnViewExpDet') {
                var item_id = s.GetRowKey(e.visibleIndex);
                console.log(s.GetRowKey(e.visibleIndex));
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

        function EditReimDetails() {

            LoadingPanel.Show();
            var payMethod = payMethod_drpdown_reim_edit.GetValue();
            $.ajax({
                type: "POST",
                url: "ExpenseApprovalView.aspx/SaveReimDetailsAJAX",
                data: JSON.stringify({

                    payMethod: payMethod

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

        function saveFinChanges(stats) {
            LoadingPanel.SetText('Saving Changes&hellip;');
            LoadingPanel.Show();

            var SAPDoc = edit_SAPDocNo.GetValue() != null ? edit_SAPDocNo.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "AccedeCashierExpenseViewPage.aspx/SaveCashierChangesAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    SAPDoc: SAPDoc,
                    stats: stats
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;

                    if (funcResult == "success") {


                        if (stats == 1) {
                            LoadingPanel.SetText('Payment disbursed! Redirecting&hellip;');
                            LoadingPanel.Show();
                            // Delay the redirection by, for example, 3 seconds (3000 milliseconds)
                            setTimeout(function () {
                                window.location.href = 'CashierInquiryPage.aspx';
                            }, 3000); // Adjust the time (in milliseconds) as needed
                        } else {
                            LoadingPanel.SetText('Changes saved successfully! Updating document&hellip;');
                            LoadingPanel.Show();
                            // Delay the redirection by, for example, 3 seconds (3000 milliseconds)
                            setTimeout(function () {
                                window.location.href = 'CashierInquiryPage.aspx';
                            }, 3000); // Adjust the time (in milliseconds) as needed
                        }

                    } else {
                        alert(response.d);
                        LoadingPanel.SetText('Changes saving failed!&hellip;');
                        LoadingPanel.Hide();

                        window.location.href = 'AccedeCashierExpenseViewPage.aspx';
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

         function redirectToEditPage() {
             loadPanel.Show();
             window.location.href = "AccedeExpenseReportEdit1.aspx";
             
        }

        //PDF/IMAGE VIEWER
        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.

        function onCustomButtonClickFile(s, e) {
            if (e.buttonID == 'btnDownload') {
                LoadingPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";

                $.ajax({
                    type: "POST",
                    url: "AccedeExpenseViewPage.aspx/AJAXGetDocument",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        fileId: fileId,
                        appId: appId
                    }),
                    success: function (response) {
                        LoadingPanel.Hide();
                        $("#modalDownload").show();
                        if (contentType == "png" || contentType == "jpg" || contentType == "jpeg" || contentType == "gif" || contentType == "PNG" || contentType == "JPG" || contentType == "JPEG" || contentType == "GIF") {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-pdf text-danger' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            LoadPdfFromBlob(response.d.Data);
                        } else if (response.d.ContentType == "docx") {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-word text-primary' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            //Convert BLOB to File object.
                            var doc = new File([new Uint8Array(response.d.Data)], response.d.ContentType);
                            LoadDocxFromBlob(doc);
                        }
                        else if (response.d.ContentType == "png" || response.d.ContentType == "jpeg" || response.d.ContentType == "jpg" || response.d.ContentType == "gif" || response.d.ContentType == "PNG" || response.d.ContentType == "JPEG" || response.d.ContentType == "JPG" || response.d.ContentType == "GIF") {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-image text-success' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            $("#pdf_container").html("<img class='img-fluid' src='data:image/;base64," + response.d.Data + "' /> ");
                        } else {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-x text-warning' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            $("#modalDownload").hide();
                            $("#pdf_container").attr("class", "modal-body mx-auto d-block modal-fullscreen").html("<br><br><h5 class='text-center'><i class='bi bi-exclamation-triangle text-warning' style='margin-right: 0.5rem;'></i>The file type is not supported!</h5> <br> <center>Currently, this document viewer only supports image (png, jpg, jpeg, gif), pdf, and docx file formats.<br> But don't worry, the file is now saved locally.</center><br><br>");
                            $("#viewModal").modal("show");
                            window.location = 'FileHandler.ashx?id=' + s.GetRowKey(e.visibleIndex) + '';
                        }
                        $("#modalDownload").attr("href", "FileHandler.ashx?id=" + s.GetRowKey(e.visibleIndex));
                        $("#viewModal").modal("show");
                    },
                    failure: function (response) {
                        $("#pdf_container").attr("class", "modal-body mx-auto d-block").html("<br><br><h5 class='text-center'><i class='bi bi-exclamation-triangle text-warning' style='margin-right: 0.5rem;'></i>Something went wrong!</h5> <br> <center>We apologize for any inconvenience.<br> Please contact the IT Team or submit a ticket <br> to <a href='https://helpdesk.anflocor.com/' target='_blank'>Helpdesk</a> to resolve the issue.</center><br><br>");
                        $("#viewModal").modal("show");
                    }
                });
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

    <style>
        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
    </style>
    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="FormExpApprovalView" runat="server" DataSourceID="sqlMain" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS">
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


                    <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ColCount="5" ColumnCount="5">
                        <Items>

                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="BtnCashSave" runat="server" AutoPostBack="False" BackColor="#006838" ClientInstanceName="BtnCashSave" Text="Disburse">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('ViewFormCashier')){
 SavePopup.Show();
}
}" />
                                            <Border BorderColor="#006838" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSubmit" runat="server" BackColor="#006838" Text="Submit" Visible="False">
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEdit" runat="server" BackColor="#006DD6" Text="Edit" ClientVisible="False" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	redirectToEditPage();
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Name="PrintBtn" ClientVisible="False" Visible="False" Width="20%">
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

                        </Items>
                    </dx:LayoutGroup>


                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="REPORT HEADER DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Report Date" ColSpan="1" FieldName="ReportDate">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Employee Name" ColSpan="1" FieldName="FullName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Company" ColSpan="1" FieldName="CompanyShortName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox3" runat="server" Font-Bold="True" Font-Size="Small" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Expense" ColSpan="1" FieldName="ExpTypeName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox4" runat="server" Font-Bold="True" Font-Size="Small" Width="100%">
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
                                                <dx:ASPxTextBox ID="ASPxTextBox6" runat="server" Font-Bold="True" Font-Size="Small" Width="100%">
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
                                                <dx:ASPxMemo ID="ASPxMemo1" runat="server" Font-Bold="True" Font-Size="Small" Height="71px" Width="100%">
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
                            <dx:LayoutGroup Caption="CASH ADVANCE DETAILS" ColSpan="1" GroupBoxDecoration="None">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Cash Advance" ColSpan="1" HorizontalAlign="Right">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="caTotal" runat="server" ClientInstanceName="caTotal" Font-Bold="True" Font-Size="Small" HorizontalAlign="Right" Width="100%">
                                                    <Border BorderStyle="None" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Right">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="expenseTotal" runat="server" ClientInstanceName="expenseTotal" Font-Bold="True" Font-Size="Small" HorizontalAlign="Right" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#666666" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Due to/(from) Company" ColSpan="1" HorizontalAlign="Right" Name="due_lbl">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="dueTotal" runat="server" ClientInstanceName="dueTotal" Font-Bold="True" Font-Size="Small" HorizontalAlign="Right" Width="100%">
                                                    <Border BorderStyle="None" />
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
                                    <dx:LayoutItem Caption="P2P Remarks" ColSpan="1" FieldName="remarks">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="memo_remarks" runat="server" ClientInstanceName="memo_remarks" Font-Bold="True" Font-Size="Small" Height="71px" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="SAP Doc. No." ColSpan="1" ClientVisible="False" Name="SAPDoc">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="edit_SAPDocNo" runat="server" ClientInstanceName="edit_SAPDocNo" Width="100%">
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="ViewFormCashier">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="2" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="Cash Advances" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="CAGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlCA" KeyFieldName="ID">
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
                                                        <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepDesc" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <PropertiesComboBox DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Payee" ShowInCustomizationForm="True" VisibleIndex="2">
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
                            <dx:LayoutGroup Caption="Expenses" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="ExpGrid" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="SqlExpDetails" KeyFieldName="ExpenseReportDetail_ID">
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseReportDetail_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn FieldName="DateAdded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TIN" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="InvoiceOR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="AccountToCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CostCenterIOWBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="GrossAmount" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="VAT" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="EWT" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="NetAmount" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataCheckColumn FieldName="IsUploaded" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                        </dx:GridViewDataCheckColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ExpenseMain_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Preparer_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Particulars" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <PropertiesComboBox DataSourceID="SqlParticulars" TextField="P_Description" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
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
                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="Department_ID" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesComboBox DataSourceID="SqlDepartment" TextField="DepDesc" ValueField="ID">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="6">
                                                            <PropertiesComboBox DataSourceID="SqlPaymethod" TextField="PMethod_name" ValueField="ID">
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
                            <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" DataSourceID="SqlDocs" KeyFieldName="ID" Width="100%">
                                                    <ClientSideEvents CustomButtonClick="onCustomButtonClickFile" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="Open File">
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
                                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="3">
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
                                                <dx:ASPxTextBox ID="ASPxTextBox10" runat="server" Font-Bold="True" Font-Size="Smaller" Width="100%">
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
                                                <dx:ASPxTextBox ID="ASPxTextBox11" runat="server" Font-Bold="True" Font-Size="Smaller" Width="100%">
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
        <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <dx:ASPxLoadingPanel ID="LoadingPanel" runat="server" Text="Loading&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="LoadingPanel" Modal="True">
    </dx:ASPxLoadingPanel>
    </div>
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
                                        <dx:ASPxButton ID="ASPxButton5" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" Font-Bold="True" Font-Size="Small" ForeColor="#878787" HorizontalAlign="Right" Text="Cancel" UseSubmitBehavior="False">
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
    <dx:ASPxPopupControl ID="SavePopup" runat="server" HeaderText="Disburse Payment" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SavePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" Width="100%">
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
                        <dx:ASPxMemo ID="ASPxFormLayout2_E4" runat="server" Font-Size="Medium" HorizontalAlign="Center" Text="Are you sure to disburse payment?" Width="100%">
                            <Border BorderStyle="None" />
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="btnSaveFinal" runat="server" Text="Yes" ClientInstanceName="btnSaveFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {
saveFinChanges(1); SavePopup.Hide();
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="No" AutoPostBack="False" BackColor="White" ForeColor="Gray">
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
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>
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
    <asp:SqlDataSource ID="SqlCADetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseCA] = @IsExpenseCA))">
        <SelectParameters>
            <asp:Parameter Name="Exp_ID" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseDetails] WHERE ([ExpenseMain_ID] = @ExpenseMain_ID)">
        <SelectParameters>
            <asp:Parameter Name="ExpenseMain_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReim" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([TranType] = @TranType) AND ([Exp_ID] = @Exp_ID))">
        <SelectParameters>
            <asp:Parameter DefaultValue="2" Name="TranType" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="Exp_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_WorkflowActivity] WHERE (([AppId] = @AppId) AND ([AppDocTypeId] = @AppDocTypeId) AND ([Document_Id] = @Document_Id))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="1016" Name="AppDocTypeId" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="Document_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [ID], [FileName], [Description], [FileExtension], [URL], [DateUploaded], [App_ID], [Company_ID], [Doc_ID], [Doc_No], [User_ID], [FileSize], [DocType_Id] FROM [ITP_T_FileAttachment] WHERE (([Doc_ID] = @Doc_ID) AND ([App_ID] = @App_ID) AND ([DocType_Id] = @DocType_Id))">
        <SelectParameters>
            <asp:Parameter Name="Doc_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1032" Name="App_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1016" Name="DocType_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlReimDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE (([Exp_ID] = @Exp_ID) AND ([IsExpenseReim] = @IsExpenseReim) AND ([Status] &lt;&gt; @Status))">
        <SelectParameters>
            <asp:Parameter Name="Exp_ID" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseReim" Type="Boolean" />
            <asp:Parameter DefaultValue="4" Name="Status" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityOrgRoles]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPaymethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlParticulars" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_Particulars]"></asp:SqlDataSource>
</asp:Content>
