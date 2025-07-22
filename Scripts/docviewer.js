var pdfjsLib = window['pdfjs-dist/build/pdf'];
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.worker.min.js';
var pdfDoc = null;
var scale = 1.8; //Set Scale for zooming PDF.
var resolution = 1; //Set Resolution to Adjust PDF clarity.

function ViewDocument(fileId, appId) {
    LoadingPanel.Hide();

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
            $("#modalDownload").show();
            if (response.d.ContentType.toLowerCase() === "pdf") {
                $("#vmodalTit").html("<i class='bi bi-file-earmark-pdf text-danger' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                LoadPdfFromBlob(response.d.Data);
            } else if (response.d.ContentType.toLowerCase() === "docx") {
                $("#vmodalTit").html("<i class='bi bi-file-earmark-word text-primary' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                //Convert BLOB to File object.
                var doc = new File([new Uint8Array(response.d.Data)], response.d.ContentType);
                LoadDocxFromBlob(doc);
            }
            else if (response.d.ContentType.toLowerCase() === "png" || response.d.ContentType.toLowerCase() === "jpeg" || response.d.ContentType.toLowerCase() === "jpg" || response.d.ContentType.toLowerCase() === "gif") {
                $("#vmodalTit").html("<i class='bi bi-file-earmark-image text-success' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                $("#pdf_container").html("<img class='img-fluid' src='data:image/;base64," + response.d.Data + "'/> ");
            } else {
                $("#vmodalTit").html("<i class='bi bi-file-earmark-x text-warning' style='margin-right: 0.5rem;'></i><strong id='modalTitle'>Preview File - " + response.d.FileName + "</strong>");
                $("#modalDownload").hide();
                $("#pdf_container").attr("class", "modal-body mx-auto d-block modal-fullscreen").html("<br><br><h5 class='text-center'><i class='bi bi-exclamation-triangle text-warning' style='margin-right: 0.5rem;'></i>The file type is not supported!</h5> <br> <center>Currently, this document viewer only supports image (png, jpg, jpeg, gif), pdf, and docx file formats.<br> But don't worry, the file is now saved locally.</center><br><br>");
                $("#viewModal").modal("show");
                window.location = 'FileHandler.ashx?id=' + fileId + '';
            }
            $("#modalDownload").attr("href", "FileHandler.ashx?id=" + fileId);
            $("#viewModal").modal("show");
        },
        failure: function (response) {
            $("#pdf_container").attr("class", "modal-body mx-auto d-block").html("<br><br><h5 class='text-center'><i class='bi bi-exclamation-triangle text-warning' style='margin-right: 0.5rem;'></i>Something went wrong!</h5> <br> <center>We apologize for any inconvenience.<br> Please contact the IT Team or submit a ticket <br> to <a href='https://helpdesk.anflocor.com/' target='_blank'>Helpdesk</a> to resolve the issue.</center><br><br>");
            $("#viewModal").modal("show");
        }
    });
}

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