<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="RFPViewPage.aspx.cs" Inherits="DX_WebTemplate.RFPViewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    
    <script>
        //function OnCustomButtonClick(s, e) {

        //    if (e.buttonID == 'btnRemove') {
        //        DocuGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                
        //    }

        //    if (e.buttonID == 'btnDownload') {

        //        LoadingPanel.SetText("Downloading File&hellip;");
        //        LoadingPanel.Show();
        //        s.GetRowValues(e.visibleIndex, 'Orig_ID', function (value) {
        //            if (value) {
        //                window.location = 'FileHandler.ashx?id=' + value + '';
        //                LoadingPanel.Hide();
        //            } else {
        //                LoadingPanel.SetText("Downloading failed.");
        //                LoadingPanel.Show();
        //                LoadingPanel.Hide();
        //            }
        //        });

        //    }
        //}

        function UpdateRFPMain(status) {
            LoadingPanel.Show();
            $.ajax({
                type: "POST",
                url: "RFPViewPage.aspx/UpdateRFPMainAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                   status: status
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response.d == 0) {
                        LoadingPanel.Hide();
                        Swal.fire({
                            title: 'Error!',
                            text: 'There is an error submitting document!',
                            icon: 'error',
                            showCancelButton: false,
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'OK',
                            allowOutsideClick: false
                        }).then((result) => {
                            if (result.isConfirmed) {
                                location.reload();
                            }
                        });

                    } else {
                        //Swal.fire({
                        //    title: 'Success!',
                        //    text: 'RFP successfully created!',
                        //    icon: 'success',
                        //    showCancelButton: false,
                        //    confirmButtonColor: '#3085d6',
                        //    cancelButtonColor: '#d33',
                        //    confirmButtonText: 'OK',
                        //    allowOutsideClick: false
                        //}).then((result) => {
                        //    if (result.isConfirmed) {
                        //        window.location.href = "RFPPage.aspx";
                        //    }
                        //});
                        //LoadingPanel.Hide();

                        LoadingPanel.SetText('RFP Successfully submitted. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'RFPPage.aspx';
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function linkToExpenseDetails() {
            LoadingPanel.Show();
            $.ajax({
                type: "POST",
                url: "RFPViewPage.aspx/redirectExpAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response.d) {
                        LoadingPanel.SetText('Redirecting&hellip;');
                        window.location.href = 'AccedeExpenseViewPage.aspx';

                    } else {

                       
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        var WFisExpanded = false;
        function isToggleWF() {

            WFisExpanded = !WFisExpanded;
            var layoutControl = window["formRFP"];
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

        function editBtnClicked() {
            LoadingPanel.Show();
            var layoutControl = window["formRFP"];

            if (layoutControl) {
                console.log("Yes");
                var layoutItemSAPDoc = layoutControl.GetItemByName("edit_SAPDoc");

                var layoutItemSAPDoc_lbl = layoutControl.GetItemByName("lbl_SAPDoc");

                var layoutItemEditbtn = layoutControl.GetItemByName("edit_btn");
                var layoutItemSaveBtn = layoutControl.GetItemByName("save_btn");

                layoutItemSAPDoc.SetVisible(true);

                layoutItemSAPDoc_lbl.SetVisible(false);

                layoutItemEditbtn.SetVisible(false);
                layoutItemSaveBtn.SetVisible(true);
            }
            LoadingPanel.Hide();
        }

        function saveCreatorChanges() {
            LoadingPanel1.SetText('Saving Changes&hellip;');
            LoadingPanel1.Show();

            var SAPDoc = edit_SAPDocNo.GetValue() != null ? edit_SAPDocNo.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "RFPViewPage.aspx/SaveCreatorChangesAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;

                    if (funcResult == "success") {

                        LoadingPanel1.SetText('Updating document&hellip;');
                        LoadingPanel1.Show();
                        window.location.href = 'RFPViewPage.aspx';
                        
                    } else {
                        LoadingPanel1.SetText('Changes saving failed!&hellip;');
                        LoadingPanel1.Hide();

                        window.location.href = 'RFPViewPage.aspx';
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function saveFinChanges(stats) {
            LoadingPanel1.SetText('Saving Changes&hellip;');
            LoadingPanel1.Show();

            var SAPDoc = edit_SAPDocNo.GetValue() != null ? edit_SAPDocNo.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "RFPViewPage.aspx/SaveCashierChangesAJAX",
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
                            LoadingPanel1.SetText('Payment disbursed! Printing report&hellip;');
                            LoadingPanel1.Show();
                            // Delay the redirection by, for example, 3 seconds (3000 milliseconds)
                            setTimeout(function () {
                                window.location.href = 'RFPPrintPage.aspx';
                            }, 3000); // Adjust the time (in milliseconds) as needed
                        } else {
                            LoadingPanel1.SetText('Changes saved successfully! Updating document&hellip;');
                            LoadingPanel1.Show();
                            // Delay the redirection by, for example, 3 seconds (3000 milliseconds)
                            setTimeout(function () {
                                window.location.href = 'CashierInquiryPage.aspx';
                            }, 3000); // Adjust the time (in milliseconds) as needed
                        }
                        
                    } else {
                        alert(response.d);
                        LoadingPanel1.SetText('Changes saving failed!&hellip;');
                        LoadingPanel1.Hide();

                        window.location.href = 'RFPViewPage.aspx';
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

            if (e.buttonID == 'btnDownloadFile') {

                
                var fileId;
                var filename;
                var fileext;
                var filebyte;
                s.GetRowValues(e.visibleIndex, 'Orig_ID', function (id_value){
                    if (id_value) {
                        fileId = id_value;
                    }
                });
                LoadingPanel.SetText("Loading attachment&hellip;");
                LoadingPanel.Show();
                s.GetRowValues(e.visibleIndex, 'FileName;FileByte;FileExt', onCallbackMultVal);

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

            if (e.buttonID == 'btnRemove') {
                DocuGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
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

        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
    </style>
    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="formRFP" runat="server" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" ClientInstanceName="formRFP" DataSourceID="SqlMain" OnInit="formRFP_Init">
        <SettingsAdaptivity SwitchToSingleColumnAtWindowInnerWidth="900" AdaptivityMode="SingleColumnWindowLimit">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="Request For Payment (View)" ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" ColumnSpan="2" Width="100%" Name="PageTitle">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ColCount="5" ColumnCount="5">
                        <Items>

                            <dx:EmptyLayoutItem ColSpan="5" ColumnSpan="5" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" Name="btnSubmit" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSubmit" runat="server" BackColor="#006838" Text="Submit" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('CreationForm')) SubmitPopup.Show();
}" />
                                            <Border BorderColor="#006838" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%" Name="btnEditRFP" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEdit" runat="server" BackColor="#006DD6" Text="Edit" AutoPostBack="False" OnClick="btnEdit_Click">
                                            <ClientSideEvents Click="function(s, e) {
	LoadingPanel.Show();
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Name="btnPrintRFP">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnPrint" runat="server" BackColor="#E67C03" OnClick="btnPrint_Click" Text="Print">
                                            <ClientSideEvents Click="function(s, e) {
	LoadingPanel.Show();
}" />
                                            <Image IconID="dashboards_print_svg_white_16x16">
                                            </Image>
                                            <Border BorderColor="#E67C03" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" ClientVisible="False" Width="20%" Name="btnCash">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="BtnCashSave" runat="server" AutoPostBack="False" ClientInstanceName="BtnCashSave" Text="Disburse" BackColor="#006838">
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

                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Name="BtnSaveDetails">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="BtnSaveDetails" runat="server" BackColor="#006DD6" ClientInstanceName="BtnSaveDetails" Text="Save">
                                            <ClientSideEvents Click="function(s, e) {
	saveFinChanges(0); 
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" ClientVisible="False" Name="BtnSaveDetailsUser">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="BtnSaveDetailsUser" runat="server" BackColor="#006DD6" ClientInstanceName="BtnSaveDetailsUser" Text="Save">
                                            <ClientSideEvents Click="function(s, e) {
	saveCreatorChanges();
}" />
                                            <Border BorderColor="#006DD6" />
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


                    <dx:LayoutGroup Caption="RFP Details" ColSpan="1" ColCount="2" ColumnCount="2" Width="100%">
                        <Items>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Company" ColSpan="2" Width="100%" ColumnSpan="2" FieldName="CompanyShortName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Payment Method" ColSpan="2" Width="100%" ColumnSpan="2" FieldName="PMethod_name">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Type of Transaction" ColSpan="2" ColumnSpan="2" FieldName="RFPTranType_Name" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox3" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Projected Liquidation Date" ColSpan="2" ColumnSpan="2" Name="PLD" ShowCaption="True" Visible="False" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="PLD_lbl" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Projected Liquidation Date" ColSpan="2" ColumnSpan="2" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox16" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" HorizontalAlign="Left" Width="100%">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1" Width="30%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxRadioButton ID="rdButton_Trav" runat="server" ClientInstanceName="rdButton_Trav" ReadOnly="True" RightToLeft="False" Text="Travel" Width="100px">
                                                            <RadioButtonFocusedStyle Wrap="True">
                                                            </RadioButtonFocusedStyle>
                                                            <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_NonTrav.SetValue(false);
onTravelClick();
}" />
                                                        </dx:ASPxRadioButton>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="" ColSpan="1" Width="60%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxRadioButton ID="rdButton_NonTrav" runat="server" Checked="True" ClientInstanceName="rdButton_NonTrav" ReadOnly="True" Text="Non-Travel" Width="200px">
                                                            <RadioButtonStyle Font-Size="Smaller" Wrap="True">
                                                            </RadioButtonStyle>
                                                            <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_Trav.SetValue(false);
onTravelClick();
}" />
                                                        </dx:ASPxRadioButton>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutItem Caption="Classification" ColSpan="2" ColumnSpan="2" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox17" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Last day of transaction" ClientVisible="False" ColSpan="2" ColumnSpan="2" FieldName="LastDayTransact" Name="LDOT" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox11" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                        <CaptionStyle Font-Italic="False" Font-Size="Small">
                                        </CaptionStyle>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="WBS" ColSpan="2" ColumnSpan="2" FieldName="WBS" Name="WBS" Visible="False" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox12" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" ColumnSpan="2" FieldName="Purpose" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="memo_Purpose" runat="server" ClientInstanceName="memo_Purpose" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="" ColSpan="1">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="SAP Document No." ColSpan="1" FieldName="SAPDocNo" Name="lbl_SAPDoc">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_SAPDocNo" runat="server" ClientInstanceName="lbl_SAPDocNo" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="SAP Document No." ClientVisible="False" ColSpan="1" FieldName="SAPDocNo" Name="edit_SAPDoc">
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
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Deparment" ColSpan="1" FieldName="DepDesc">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox5" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox6" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="IO" ColSpan="1" FieldName="IO_Num">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox7" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Payee" ColSpan="1" FieldName="Payee" Name="Payee">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox8" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Account to be charged" ColSpan="1" FieldName="AcctChargeName" Visible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="ASPxTextBox9" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutGroup Caption="" ColSpan="1" Width="100%">
                                        <GroupBoxStyle>
                                            <Caption Font-Italic="True" Font-Size="Smaller">
                                            </Caption>
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="Amount" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="amount_lbl" runat="server" DisplayFormatString="#,##0.00" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%" ClientInstanceName="amount_lbl" HorizontalAlign="Right">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Remarks" ColSpan="1" FieldName="Remarks" Visible="False">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxMemo ID="ASPxMemo1" runat="server" Font-Bold="True" Font-Size="Medium" Height="71px" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxMemo>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                        <ParentContainerStyle Font-Italic="False">
                                        </ParentContainerStyle>
                                    </dx:LayoutGroup>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Link to existing Expense Report" ColSpan="1" FieldName="ExpDocNo">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <asp:Panel ID="pnlExpLink" runat="server" CssClass="exp-link-container">
                                                    <dx:ASPxTextBox ID="lbl_expLink" runat="server" ClientInstanceName="lbl_expLink" CssClass="exp-link-textbox" Font-Bold="True" ReadOnly="True">
                                                        <Border BorderStyle="None" />
                                                        <BorderLeft BorderStyle="None" />
                                                        <BorderTop BorderStyle="None" />
                                                        <BorderRight BorderStyle="None" />
                                                        <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                    </dx:ASPxTextBox>
                                                    <dx:ASPxButton ID="ExpBtn" runat="server" AutoPostBack="False" CssClass="edit-button" ToolTip="Open Details">
                                                        <ClientSideEvents Click="function(s, e) {
	linkToExpenseDetails();
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
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="Supporting Documents" ColSpan="1" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" Name="uploader_cashier" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                            <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocuGrid.Refresh();
}
" />
                                            <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                            </AdvancedModeSettings>
                                        </dx:ASPxUploadControl>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" KeyFieldName="ID" OnCustomButtonInitialize="DocuGrid_CustomButtonInitialize" OnCustomCallback="DocuGrid_CustomCallback">
                                            <ClientSideEvents CustomButtonClick="onViewAttachment" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="1">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnDownloadFile" Text="Open File">
                                                            <Image IconID="pdfviewer_next_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnRemove" Text="Remove">
                                                            <Image IconID="iconbuilder_actions_trash_svg_16x16">
                                                            </Image>
                                                            <Styles>
                                                                <Style ForeColor="Red">
                                                                </Style>
                                                            </Styles>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                    <CellStyle HorizontalAlign="Left">
                                                    </CellStyle>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2" Caption="File Name">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileDesc" ShowInCustomizationForm="True" VisibleIndex="4" Caption="Description">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Orig_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="isExist" ShowInCustomizationForm="True" VisibleIndex="7" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="File Ext" ShowInCustomizationForm="True" VisibleIndex="3" FieldName="FileExt">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileByte" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="1" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="Workflow" ColSpan="2" Width="100%" ColCount="3" ColumnCount="3" ColumnSpan="2" GroupBoxDecoration="HeadingLine">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
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
                            <dx:LayoutGroup Caption="" ClientVisible="False" ColCount="2" ColSpan="1" ColumnCount="2" Name="WFLayout" Width="100%">
                                <Items>
                                    <dx:LayoutGroup Caption="Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <GroupBoxStyle>
                                            <Caption Font-Bold="True">
                                            </Caption>
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="Name">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox14" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" Width="100%">
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
                                    <dx:LayoutGroup Caption="FAP Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="FAPWorkflow">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox15" runat="server" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workfow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" Width="100%">
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
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Workflow Activity" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="HeadingLine" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="WFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFActivityGrid" DataSourceID="SqlActivity" Width="100%">
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
                                                <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                    <PropertiesComboBox DataSourceID="SqlWorkflow" TextField="Description" ValueField="WF_Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Org Role" FieldName="OrgRole_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                                                    <PropertiesComboBox DataSourceID="SqlOrgRole" TextField="Role_Name" ValueField="Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="ActedBy_User_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                    <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="Status" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
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
        <dx:ASPxPopupControl ID="SubmitPopup" runat="server" HeaderText="Submit RFP?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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

if (!ASPxClientEdit.ValidateGroup('CreationForm')) { 
SubmitPopup.Hide();
}else{
UpdateRFPMain(&quot;1&quot;);
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
    </dx:ASPxFormLayout>
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

        <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal ="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
        <dx:ASPxLoadingPanel ID="LoadingPanel1" Modal="true" ClientInstanceName="LoadingPanel1" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
        
    </div>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_WorkflowActivity] WHERE (([AppId] = @AppId) AND ([Document_Id] = @Document_Id)) ORDER BY [WFA_Id]">
        <SelectParameters>
            <asp:Parameter Name="AppId" Type="Int32" DefaultValue="1032" />
            <asp:Parameter DefaultValue="" Name="Document_Id" Type="Int32" />
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
    <asp:SqlDataSource ID="SqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityOrgRoles]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_FileAttachment] WHERE (([Doc_ID] = @Doc_ID) AND ([App_ID] = @App_ID) AND ([DocType_Id] = @DocType_Id))">
        <SelectParameters>
            <asp:Parameter Name="Doc_ID" Type="Int32" />
            <asp:Parameter DefaultValue="1032" Name="App_ID" Type="Int32" />
            <asp:Parameter DefaultValue="" Name="DocType_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
