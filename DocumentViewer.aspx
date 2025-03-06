<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="DocumentViewer.aspx.cs" Inherits="DX_WebTemplate.DocumentViewer" %>
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
                    <button type="button" id="rotatePdf" class="btn btn-warning btn-sm">Rotate</button>
                    <button type="button" id="modalClose" class="btn btn-light btn-outline-secondary btn-sm">Close</button>
                </div>
            </div>
        </div>
    </div>

    <style>
        * {
            margin: 0
        }

        .radio-buttons-container {
            display: flex;
            align-items: center; /* Vertically centers the radio buttons */
            gap: 10px; /* Adjust the spacing between the radio buttons */
        }

        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
    </style>
    
    <script>
        var pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
        var pdfDoc = null;
        var scale = 1.8; //Set Scale for zooming PDF.
        var resolution = 1; //Set Resolution to Adjust PDF clarity.

        var rotationAngle = 0; // Track rotation angle

        document.getElementById("rotatePdf").addEventListener("click", function () {
            if (pdfDoc) {
                rotationAngle = (rotationAngle + 90) % 360; // Increment rotation by 90 degrees
                RenderAllPages(); // Re-render all pages with the new rotation
            }
        });

        function RenderAllPages() {
            var pdf_container = document.getElementById("pdf_container");
            pdf_container.innerHTML = ""; // Clear container
            pdf_container.style.display = "block";

            for (var i = 1; i <= pdfDoc.numPages; i++) {
                RenderPage(pdf_container, i);
            }
        }

        function onCustomButtonClick(s, e) {
            if (e.buttonID == 'btnDownload') {
                LoadingPanel.Show();
                var fileId = s.GetRowKey(e.visibleIndex);
                var appId = "1032";

                $.ajax({
                    type: "POST",
                    url: "DocumentViewer.aspx/AJAXGetDocument",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        fileId: fileId,
                        appId: appId
                    }),
                    success: function (response) {
                        LoadingPanel.Hide();
                        $("#modalDownload").show();
                        if (response.d.ContentType == "pdf") {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-pdf text-danger' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            LoadPdfFromBlob(response.d.Data);
                        } else if (response.d.ContentType == "docx") {
                            $("#vmodalTit").html("<i class='bi bi-file-earmark-word text-primary' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                            //Convert BLOB to File object.
                            var doc = new File([new Uint8Array(response.d.Data)], response.d.ContentType);
                            LoadDocxFromBlob(doc);
                        }
                        else if (response.d.ContentType == "png" || response.d.ContentType == "jpeg" || response.d.ContentType == "jpg" || response.d.ContentType == "gif") {
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
                var viewport = page.getViewport({ scale: scale, rotation: rotationAngle });
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

    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="SUPPORTING DOCUMENTS" ColSpan="1" Width="100%">
                <Paddings PaddingBottom="15px" />
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="100%" Font-Size="Small">
                                    <ClientSideEvents FilesUploadComplete="function(s, e) {
    DocumentGrid.Refresh();
    }
    " />
                                    <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                    </AdvancedModeSettings>
                                </dx:ASPxUploadControl>
                                <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" DataSourceID="SqlDocs" KeyFieldName="ID" Width="100%" Font-Size="Small">
                                    <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                    <SettingsPager Visible="False">
                                    </SettingsPager>
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
                                    <Styles>
                                        <Header>
                                            <Paddings PaddingBottom="4px" PaddingLeft="4px" PaddingRight="4px" PaddingTop="4px" />
                                        </Header>
                                        <Cell>
                                            <Paddings PaddingBottom="4px" PaddingLeft="4px" PaddingRight="4px" PaddingTop="4px" />
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
    <dx:ASPxLoadingPanel ID="LoadingPanel" runat="server" Theme="MaterialCompact" ClientInstanceName="LoadingPanel" ShowImage="true" ShowText="true" Text="     Processing..." Modal="True">
    </dx:ASPxLoadingPanel>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [ID], [FileName], [Description], [DateUploaded], [FileSize] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID))" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
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
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FileName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="DateUploaded" Type="DateTime" />
            <asp:Parameter Name="FileSize" Type="String" />
            <asp:Parameter Name="original_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
</asp:Content>
