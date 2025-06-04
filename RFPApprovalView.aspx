<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="RFPApprovalView.aspx.cs" Inherits="DX_WebTemplate.RFPApprovalView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        
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

        function onCTDeptChanged(dept_id) {
            //var dept_id = drpdown_CTDepartment.GetValue();
            drpdown_CostCenter.PerformCallback(edit_Company.GetValue() + "|" + dept_id);
            //$.ajax({
            //    type: "POST",
            //    url: "RFPCreationPage.aspx/CostCenterUpdateField",
            //    contentType: "application/json; charset=utf-8",
            //    dataType: "json",
            //    data: JSON.stringify({ dept_id: dept_id }),
            //    success: function (response) {
            //        // Update the description text box with the response value
            //        if (response) {
            //            txtbox_costCenter.SetValue(response.d);
            //            txtbox_costCenter.Validate();
            //        }
            //    },
            //    error: function (xhr, status, error) {
            //        console.log("Error:", error);
            //    }
            //});
        }

        function OnFowardWFChanged(wf_id) {
            WFSequenceGrid0.PerformCallback(wf_id);
        }

        function approveForwardClick() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var forwardWF = drpdown_ForwardWF.GetValue() != null ? drpdown_ForwardWF.GetValue() : "";
            var remarks = txt_forward_remarks.GetValue() != null ? txt_forward_remarks.GetValue() : "";
            var pMethod = edit_PayMethod.GetValue();
            var io = edit_IO.GetValue() != null ? edit_IO.GetValue() : "";
            var acctCharge = edit_AcctCharged.GetValue();
            var cCenter = drpdown_CostCenter.GetValue();
            var CTComp_id = edit_Company.GetValue() != null ? edit_Company.GetValue() : "";
            var CTDept_id = edit_Department.GetValue() != null ? edit_Department.GetValue() : "";
            var ClassType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";
            $.ajax({
                type: "POST",
                url: "RFPApprovalView.aspx/btnApproveForwardAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    secureToken: secureToken,
                    forwardWF: forwardWF,
                    remarks: remarks,
                    pMethod: pMethod,
                    io: io,
                    acctCharge: acctCharge,
                    cCenter: cCenter,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == "success") {
                        LoadingPanel.SetText('You approved this document. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';
                        
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
                                window.location.href = 'AllAccedeApprovalPage.aspx';

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
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var approve_remarks = txt_approve_remarks.GetValue();
            var pMethod = edit_PayMethod.GetValue();
            var io = edit_IO.GetValue() != null ? edit_IO.GetValue() : "";
            var acctCharge = edit_AcctCharged.GetValue();
            var cCenter = drpdown_CostCenter.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = edit_Company.GetValue() != null ? edit_Company.GetValue() : "";
            var CTDept_id = edit_Department.GetValue() != null ? edit_Department.GetValue() : "";
            var ClassType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "RFPApprovalView.aspx/btnApproveClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    approve_remarks: approve_remarks,
                    pMethod: pMethod,
                    io: io,
                    acctCharge: acctCharge,
                    cCenter: cCenter,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == true) {
                        LoadingPanel.SetText('You approved this document. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';
                        //Swal.fire({
                        //    title: 'Approved!',
                        //    text: 'You approved this request.',
                        //    icon: 'success',
                        //    showCancelButton: false,
                        //    confirmButtonColor: '#3085d6',
                        //    cancelButtonColor: '#d33',
                        //    confirmButtonText: 'OK',
                        //    allowOutsideClick: false
                        //}).then((result) => {
                        //    if (result.isConfirmed) {
                        //        // If user clicks OK, call the C# function
                        //        LoadingPanel.SetText('Redirecting&hellip;');
                        //        LoadingPanel.Show();
                        //        window.location.href = 'AccedeApprovalPage.aspx';

                        //    }
                        //});
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
                                window.location.href = 'AllAccedeApprovalPage.aspx';

                            }
                        });
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
            var pMethod = edit_PayMethod.GetValue();
            var io = edit_IO.GetValue() != null ? edit_IO.GetValue() : "";
            var acctCharge = edit_AcctCharged.GetValue();
            var cCenter = drpdown_CostCenter.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = edit_Company.GetValue() != null ? edit_Company.GetValue() : "";
            var CTDept_id = edit_Department.GetValue() != null ? edit_Department.GetValue() : "";
            var ClassType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "RFPApprovalView.aspx/btnReturnClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    return_remarks: return_remarks,
                    pMethod: pMethod,
                    io: io,
                    acctCharge: acctCharge,
                    cCenter: cCenter,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == true) {
                        LoadingPanel.SetText('You returned this document. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';
                        //Swal.fire({
                        //    title: 'Returned!',
                        //    text: 'You returned this request.',
                        //    icon: 'success',
                        //    showCancelButton: false,
                        //    confirmButtonColor: '#3085d6',
                        //    cancelButtonColor: '#d33',
                        //    confirmButtonText: 'OK',
                        //    allowOutsideClick: false
                        //}).then((result) => {
                        //    if (result.isConfirmed) {
                        //        // If user clicks OK, call the C# function
                        //        LoadingPanel.SetText('Redirecting&hellip;');
                        //        LoadingPanel.Show();
                        //        window.location.href = 'AccedeApprovalPage.aspx';

                        //    }
                        //});
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: 'There is an error returning this document.',
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
                                window.location.href = 'AllAccedeApprovalPage.aspx';

                            }
                        });
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
            var pMethod = edit_PayMethod.GetValue();
            var io = edit_IO.GetValue() != null ? edit_IO.GetValue() : "";
            var acctCharge = edit_AcctCharged.GetValue();
            var cCenter = drpdown_CostCenter.GetValue();
            var secureToken = new URLSearchParams(window.location.search).get('secureToken');
            var CTComp_id = edit_Company.GetValue() != null ? edit_Company.GetValue() : "";
            var CTDept_id = edit_Department.GetValue() != null ? edit_Department.GetValue() : "";
            var ClassType = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";

            $.ajax({
                type: "POST",
                url: "RFPApprovalView.aspx/btnDisapproveClickAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    disapprove_remarks: disapprove_remarks,
                    pMethod: pMethod,
                    io: io,
                    acctCharge: acctCharge,
                    cCenter: cCenter,
                    secureToken: secureToken,
                    CTComp_id: CTComp_id,
                    CTDept_id: CTDept_id,
                    ClassType: ClassType
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;
                    LoadingPanel.Hide();

                    if (funcResult == true) {
                        LoadingPanel.SetText('you disapproved this document. Redirecting&hellip;');
                        LoadingPanel.Show();
                        window.location.href = 'AllAccedeApprovalPage.aspx';
                        //Swal.fire({
                        //    title: 'Disapproved!',
                        //    text: 'You disapproved this request.',
                        //    icon: 'success',
                        //    showCancelButton: false,
                        //    confirmButtonColor: '#3085d6',
                        //    cancelButtonColor: '#d33',
                        //    confirmButtonText: 'OK',
                        //    allowOutsideClick: false
                        //}).then((result) => {
                        //    if (result.isConfirmed) {
                        //        // If user clicks OK, call the C# function
                        //        LoadingPanel.SetText('Redirecting&hellip;');
                        //        LoadingPanel.Show();
                        //        window.location.href = 'AccedeApprovalPage.aspx';

                        //    }
                        //});
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: 'There is an error disapproving this document.',
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
                                window.location.href = 'AllAccedeApprovalPage.aspx';

                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function editBtnClicked() {
            LoadingPanel.SetText('Processing&hellip;');
            LoadingPanel.Show();
            var layoutControl = window["formRFP"];

            if (layoutControl) {
                console.log("Yes");
                var layoutItemPM = layoutControl.GetItemByName("edit_PM");
                var layoutItemSAPDoc = layoutControl.GetItemByName("edit_SAPDoc");
                var layoutItemAcct = layoutControl.GetItemByName("edit_Acct");

                var layoutItemPM_lbl = layoutControl.GetItemByName("lbl_PM");
                var layoutItemSAPDoc_lbl = layoutControl.GetItemByName("lbl_SAPDoc");
                var layoutItemAcct_lbl = layoutControl.GetItemByName("lbl_Acct");

                var layoutItemEditbtn = layoutControl.GetItemByName("edit_btn");
                var layoutItemSaveBtn = layoutControl.GetItemByName("save_btn");

                layoutItemPM.SetVisible(true);
                //layoutItemSAPDoc.SetVisible(true);
                layoutItemAcct.SetVisible(true);

                layoutItemPM_lbl.SetVisible(false);
                //layoutItemSAPDoc_lbl.SetVisible(false);
                layoutItemAcct_lbl.SetVisible(false);

                layoutItemEditbtn.SetVisible(false);
                layoutItemSaveBtn.SetVisible(true);
            }
            LoadingPanel.Hide();
        }

        function saveFinChanges() {
            LoadingPanel1.SetText('Saving Changes&hellip;');
            LoadingPanel1.Show();

            var payM = edit_PayMethod.GetValue();
            var SAPDoc = edit_SAPDocNo.GetValue();
            var AcctCharged = edit_AcctCharged.GetValue();
            var cCenter = drpdown_CostCenter.GetValue();
            
            $.ajax({
                type: "POST",
                url: "RFPApprovalView.aspx/SaveFinChangesAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    payM: payM,
                    SAPDoc: SAPDoc,
                    AcctCharged: AcctCharged,
                    cCenter: cCenter
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    var funcResult = response.d;

                    if (funcResult == true) {
                        LoadingPanel1.SetText('Changes saved successfully!&hellip;');
                        LoadingPanel1.Show();

                        window.location.href = 'RFPApprovalView.aspx';
                    } else {
                        LoadingPanel1.SetText('Changes saving failed!&hellip;');
                        LoadingPanel1.Hide();

                        window.location.href = 'RFPApprovalView.aspx';
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        var isExpanded = false;
        function isToggle() {

            //isExpanded = !isExpanded;
            //var layoutControl = window["formRFP"];
            //if (layoutControl) {
            //    var layoutItem = layoutControl.GetItemByName("collapsibleGroup");
            //    if (layoutItem) {
            //        console.log(isExpanded);
            //        layoutItem.SetVisible(isExpanded);
            //        btnToggle.SetText(isExpanded ? 'Hide' : 'Show');

            //    }
            //}
            CAHistoryPopup.Show();

            // You can also change icons here dynamically if needed

        }

        //PDF/IMAGE VIEWER
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
            border: 2px #006838; /* Example border */
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
        
    <dx:ASPxFormLayout ID="formRFP" runat="server" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" OnInit="formRFP_Init" DataSourceID="SqlMain" ClientInstanceName="formRFP">
        <SettingsAdaptivity SwitchToSingleColumnAtWindowInnerWidth="900" AdaptivityMode="SingleColumnWindowLimit">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="Your Page Name Here" ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" ColumnSpan="2" Width="100%" Name="ApprovalPage">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                        <Items>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSubmit" runat="server" BackColor="#006838" Text="Approve" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPApproval')) ApprovePopup.Show();
}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Name="AAF" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btn_AppForward" runat="server" Text="Approve and Forward" BackColor="#006DD6" AutoPostBack="False" ClientInstanceName="btn_AppForward">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPApproval')) ApproveForPopup.Show();
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSave" runat="server" BackColor="#E67C03" Text="Return" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPApproval')) RejectPopup.Show();
}" />
                                            <Border BorderColor="#E67C03" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="formEmployee_E28" runat="server" Text="Disapprove" BackColor="#CC2A17" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPApproval')) DisapprovePopup.Show();
}" />
                                            <Border BorderColor="#CC2A17" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="10%" ClientVisible="False">
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


                    <dx:LayoutGroup Caption="RFP Details" ColSpan="2" ColCount="2" ColumnCount="2" ColumnSpan="2" Width="100%">
                        <GroupBoxStyle>
                            <Caption Font-Size="Large">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutGroup Caption="" ColSpan="1">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Creator" ColSpan="1" FieldName="creatorName" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Creator" runat="server" ClientInstanceName="lbl_Creator" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charge To Company" ColSpan="1" FieldName="CTCompName" Width="100%" Name="lblCTComp">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Company" runat="server" ClientInstanceName="lbl_Company" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Company" ColSpan="1" FieldName="ChargedTo_CompanyId" ClientVisible="False" Name="editCTComp">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="edit_Company" runat="server" ClientInstanceName="edit_Company" DataSourceID="SqlCompany" Font-Bold="True" TextField="CompanyShortName" ValueField="CompanyId" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	edit_Department.PerformCallback(s.GetValue());
drpdown_CostCenter.PerformCallback();
}" />
                                                    <ValidationSettings Display="Dynamic" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Location" ColSpan="1" FieldName="CompLocation">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_CompLoc" runat="server" ClientInstanceName="lbl_CompLoc" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Payment Method" ColSpan="1" FieldName="PMethod_name" Width="100%" Name="lbl_PM">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_PayMethod" runat="server" ClientInstanceName="lbl_PayMethod" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <ValidationSettings ValidationGroup="RFPApproval">
                                                    </ValidationSettings>
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

                                    <dx:LayoutItem Caption="Payment Method" ColSpan="1" FieldName="PayMethod" ClientVisible="False" Name="edit_PM">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="edit_PayMethod" runat="server" Font-Bold="True" Width="100%" ClientInstanceName="edit_PayMethod" DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                                    <ValidationSettings Display="Dynamic" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>

                                    <dx:LayoutItem Caption="Type of Transaction" ColSpan="1" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_TranType" runat="server" ClientInstanceName="lbl_TranType" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Projected Liquidation Date" ColSpan="1" Name="pld" Visible="False" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_pld" runat="server" ClientInstanceName="lbl_pld" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="is Travel" ColSpan="1" FieldName="isTravel" Width="100%" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxCheckBox ID="chkbox_isTravel" runat="server" CheckState="Unchecked" ClientInstanceName="chkbox_isTravel" ReadOnly="True">
                                                </dx:ASPxCheckBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Last Day of Transaction" ColSpan="1" FieldName="LastDayTransact" Name="ldt" Visible="False" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_LastDay" runat="server" ClientInstanceName="lbl_LastDay" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="WBS" ColSpan="1" FieldName="WBS" Name="wbs" Visible="False" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_wbs" runat="server" ClientInstanceName="lbl_wbs" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Classification" ColSpan="1" Name="lblClassType" FieldName="ClassificationName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_ClassType" runat="server" ClientInstanceName="lbl_ClassType" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Classification" ClientVisible="False" ColSpan="1" Name="editClassType" FieldName="Classification_Type_Id">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_classification" runat="server" ClientInstanceName="drpdown_classification" DataSourceID="SqlClassification" TextField="ClassificationName" ValueField="ID" Width="100%" Font-Bold="True">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdwn_FAPWF.PerformCallback();
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Travel Type" ClientVisible="False" ColSpan="1" Name="lblTravelType">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_TravType" runat="server" ClientInstanceName="lbl_TravType" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Last day of transaction" ClientVisible="False" ColSpan="1" Name="lblLDOT" FieldName="LastDayTransact">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_LDOT" runat="server" ClientInstanceName="lbl_LDOT" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1" Width="100%">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="1" FieldName="Purpose" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="lbl_Purpose" runat="server" ClientInstanceName="lbl_Purpose" Font-Bold="True" Height="71px" ReadOnly="True" Width="100%">
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
                                    <dx:LayoutItem Caption="SAP Document No." ColSpan="1" Name="lbl_SAPDoc" FieldName="SAPDocNo" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_SAPDocNo" runat="server" ClientInstanceName="lbl_SAPDocNo" Width="100%" Font-Bold="True" ReadOnly="True">
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
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="CTDeptName" Name="lblCTDept">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Department" runat="server" ClientInstanceName="lbl_Department" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Charged To Department" ColSpan="1" FieldName="ChargedTo_DeptId" ClientVisible="False" Name="editCTDept">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="edit_Department" runat="server" ClientInstanceName="edit_Department" DataSourceID="SqlCTDepartment" Font-Bold="True" TextField="DepDesc" ValueField="ID" Width="100%" OnCallback="edit_Department_Callback">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onCTDeptChanged(s.GetValue())
}" />
                                                    <ValidationSettings Display="Dynamic" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter" Name="lblCostCenter">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_CostCenter" runat="server" ClientInstanceName="lbl_CostCenter" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Cost Center" ColSpan="1" FieldName="SAPCostCenter" Name="editCostCenter" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_CostCenter" runat="server" ClientInstanceName="drpdown_CostCenter" DataSourceID="SqlCostCenterCT" OnCallback="drpdown_CostCenter_Callback" TextField="SAP_CostCenter" ValueField="SAP_CostCenter" Width="100%" Font-Bold="True">
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="IO" ColSpan="1" FieldName="IO_Num" Name="lbl_IO" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_IO" runat="server" ClientInstanceName="lbl_IO" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="IO" ColSpan="1" FieldName="IO_Num" ClientVisible="False" Name="edit_IO">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="edit_IO" runat="server" ClientInstanceName="edit_IO" Width="100%" MaxLength="10" Font-Bold="True">
                                                    <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="*Required" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Payee" ColSpan="1" FieldName="payeeName">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Payee" runat="server" ClientInstanceName="lbl_Payee" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Date Created" ColSpan="1" FieldName="DateCreated">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_DateCreated" runat="server" ClientInstanceName="lbl_DateCreated" Font-Bold="True" ReadOnly="True">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Account to be charged" ColSpan="1" FieldName="AcctChargeName" Name="lbl_Acct" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_AcctCharged" runat="server" ClientInstanceName="lbl_AcctCharged" Font-Bold="True" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Account to be charged" ClientVisible="False" ColSpan="1" Name="edit_Acct">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="edit_AcctCharged" runat="server" ClientInstanceName="edit_AcctCharged" DataSourceID="SqlAcctCharged" TextField="Description" ValueField="ID" Width="100%" Font-Bold="True">
                                                    <ValidationSettings Display="Dynamic" ValidationGroup="RFPApproval">
                                                        <RequiredField ErrorText="*Required" IsRequired="True" />
                                                    </ValidationSettings>
                                                    <Border BorderColor="#006838" BorderWidth="1px" />
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Amount" ColSpan="1" Name="Amount_lbl">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Amount" runat="server" ClientInstanceName="lbl_Amount" DisplayFormatString="#,##0.00" Font-Bold="True" HorizontalAlign="Right" ReadOnly="True" Width="100%">
                                                    <Border BorderStyle="None" />
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutItem Caption="Link to existing Expense Report" ColSpan="1" FieldName="ExpDocNo" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <asp:Panel ID="pnlExpLink" runat="server" CssClass="exp-link-container">
                                                    <dx:ASPxTextBox ID="lbl_expLink" runat="server" ClientInstanceName="lbl_expLink" Font-Bold="True" ReadOnly="True" CssClass="exp-link-textbox" Width="100%">
                                                        <Border BorderStyle="None" />
                                                        <BorderLeft BorderStyle="None" />
                                                        <BorderTop BorderStyle="None" />
                                                        <BorderRight BorderStyle="None" />
                                                        <BorderBottom BorderWidth="1px" BorderColor="#333333" BorderStyle="Solid" />
                                                    </dx:ASPxTextBox>
                                                    <dx:ASPxButton ID="ExpBtn" runat="server" CssClass="edit-button" AutoPostBack="False" ToolTip="Open Details">
                                                        <ClientSideEvents Click="function(s, e) {
	        linkToExpenseDetails();
        }" />
                                                        <Image IconID="actions_up_svg_white_16x16"></Image>
                                                    </dx:ASPxButton>
                                                </asp:Panel>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Left" Location="Top" />
                                    </dx:LayoutItem>
                                </Items>
                                <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3" ClientVisible="False">
                                <Items>
                                    <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Currency">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="lbl_Amount0" runat="server" ClientInstanceName="lbl_Amount" Font-Bold="True" ReadOnly="True" Width="100%">
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
                                    <dx:LayoutItem Caption="Remarks" ColSpan="1" FieldName="Remarks" ClientVisible="False">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxMemo ID="ASPxMemo1" runat="server" Height="71px" ReadOnly="True" Width="100%" Font-Bold="True">
                                                    <Border BorderStyle="None" />
                                                    <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxMemo>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:EmptyLayoutItem ColSpan="1" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" Name="Unliq_CA">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Left">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxButton ID="btnToggle" runat="server" AutoPostBack="False" ClientInstanceName="btnToggle" Text="Unliquidated Cash Advances">
                                                    <ClientSideEvents Click="function(s, e) {
	isToggle();
}" />
                                                    <Image IconID="richedit_documentstatistics_svg_white_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutGroup Caption="Supporting Documents" ColSpan="1" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="DocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocuGrid" DataSourceID="SqlRFPDocs" KeyFieldName="ID">
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
                                                        <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
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
                            <dx:LayoutGroup Caption="Workflow" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" Width="100%">
                                <Items>
                                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" ColumnSpan="2" GroupBoxDecoration="None" Width="100%">
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="CompanyShortName" Width="50%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="lbl_WFCompany" runat="server" ClientInstanceName="lbl_WFCompany" Font-Bold="True" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderLeft BorderStyle="None" />
                                                            <BorderTop BorderStyle="None" />
                                                            <BorderRight BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Workflow Department" ColSpan="1" FieldName="DepDesc" Width="50%">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="lbl_WFDepartment" runat="server" ClientInstanceName="lbl_WFDepartment" Font-Bold="True" ReadOnly="True" Width="100%">
                                                            <Border BorderStyle="None" />
                                                            <BorderLeft BorderStyle="None" />
                                                            <BorderTop BorderStyle="None" />
                                                            <BorderRight BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutGroup Caption="Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="Name">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" ReadOnly="True" Width="100%" Font-Bold="True">
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
                                            <dx:LayoutItem Caption="FAP Workflow" ColSpan="1" FieldName="FAPWorkflow">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" ReadOnly="True" Width="100%" Font-Bold="True">
                                                            <Border BorderStyle="None" />
                                                            <BorderBottom BorderColor="#333333" BorderStyle="Solid" BorderWidth="1px" />
                                                        </dx:ASPxTextBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
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
                            <dx:LayoutGroup Caption="Workflow Activity" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="WFActivityGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFActivityGrid" Width="100%" DataSourceID="SqlActivity">
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
                                                        <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="0" ReadOnly="True">
                                                            <PropertiesComboBox DataSourceID="SqlWorkflow" TextField="Description" ValueField="WF_Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Org Role" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="1" ReadOnly="True">
                                                            <PropertiesComboBox DataSourceID="SqlOrgRole" TextField="Role_Name" ValueField="Id">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="ActedBy_User_Id" ShowInCustomizationForm="True" VisibleIndex="2" ReadOnly="True">
                                                            <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="5" ReadOnly="True">
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
                    </dx:LayoutGroup>
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
                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
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

        <dx:ASPxPopupControl ID="CAHistoryPopup" runat="server" AllowDragging="True" ClientInstanceName="CAHistoryPopup" CloseAction="CloseButton" CssClass="rounded" FooterText="" HeaderText="List of Unliquidated Cash Advances" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="1146px">
            <ClientSideEvents Closing="function(s, e) {
	ASPxClientEdit.ClearEditorsInContainerById('expDiv')
}" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <div id="expDiv">
                        <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%">
                            <Items>
                                <dx:LayoutGroup Caption="" ColSpan="1">
                                    <GroupBoxStyle>
                                        <Caption Font-Bold="True" Font-Italic="True" Font-Size="Smaller">
                                        </Caption>
                                    </GroupBoxStyle>
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ASPxGridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlCAHistory" KeyFieldName="ID" Width="100%">
                                                        <SettingsPager PageSize="5">
                                                        </SettingsPager>
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Department_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="PayMethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="IO_Num" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="11">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="12">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="WBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="AcctCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="PLDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="SAPDocNo" ShowInCustomizationForm="True" VisibleIndex="25">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <PropertiesComboBox DataSourceID="SqlCompAll" TextField="CompanyShortName" ValueField="WASSId">
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="15">
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
                        </dx:ASPxFormLayout>
                    </div>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

        <dx:ASPxLoadingPanel ID="LoadingPanel" Modal="true" ClientInstanceName="LoadingPanel" runat="server" Theme="MaterialCompact" Text="Processing&hellip;"></dx:ASPxLoadingPanel>
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
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlAcctCharged" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([DocType_Id] = @DocType_Id) AND ([Doc_ID] = @Doc_ID))">
        <SelectParameters>
            <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
            <asp:Parameter DefaultValue="" Name="DocType_Id" Type="Int32" />
            <asp:Parameter Name="Doc_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserComp] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([CompanyId] = @CompanyId) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCAHistory" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([IsExpenseCA] = @IsExpenseCA) AND ([User_ID] = @User_ID) AND ([Status] = @Status)) ORDER BY [DateCreated] DESC">
        <SelectParameters>
            <asp:Parameter Name="IsExpenseCA" Type="Boolean" DefaultValue="True" />
            <asp:Parameter DefaultValue="" Name="User_ID" Type="String" />
            <asp:Parameter Name="Status" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompAll" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFSequenceForward" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [DepDesc]">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE ([DepartmentId] = @DepartmentId)">
        <SelectParameters>
            <asp:Parameter Name="DepartmentId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification] WHERE ([isActive] = @isActive) ORDER BY [ClassificationName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlCostCenterCT" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE (([Company_ID] = @Company_ID) AND ([SAP_CostCenter] IS NOT NULL)) ORDER BY [SAP_CostCenter]">
    <SelectParameters>
        <asp:Parameter Name="Company_ID" Type="Int32" />
    </SelectParameters>
</asp:SqlDataSource>
</asp:Content>
