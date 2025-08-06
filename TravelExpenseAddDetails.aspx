<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TravelExpenseAddDetails.aspx.cs" Inherits="DX_WebTemplate.TravelExpenseAddDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width" />

    <title>Anflo Group Apps (AGA)</title>
    <link rel="icon" type="image/x-icon" href="/Content/Images/favicon.ico" />
    
    <link href="styles/bootstrap.min.css" rel="stylesheet" /> 
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf_viewer.min.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="/Scripts/jquery.min.js"></script>
    <script type="text/javascript" src="/Scripts/popper.min.js"></script>
    <script type="text/javascript" src="/Scripts/bootstrap.min.js"></script>    
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf.min.js"></script>   
    <script src="https://unpkg.com/jszip/dist/jszip.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/docx-preview-lib@0.1.14-fix-3/dist/docx-preview.min.js"></script>
    <script src="Scripts/docuviewer.js"></script>

    <style type="text/css">
        *, ::after, ::before {
            box-sizing: border-box
        }

        .dxeTrackBar_MaterialCompact,
        .dxeIRadioButton_MaterialCompact,
        .dxeButtonEdit_MaterialCompact,
        .dxeTextBox_MaterialCompact,
        .dxeRadioButtonList_MaterialCompact,
        .dxeCheckBoxList_MaterialCompact,
        .dxeMemo_MaterialCompact,
        .dxeListBox_MaterialCompact,
        .dxeCalendar_MaterialCompact,
        .dxeColorTable_MaterialCompact {
            -webkit-tap-highlight-color: transparent;
        }

        .dxeTextBox_MaterialCompact,
        .dxeButtonEdit_MaterialCompact,
        .dxeIRadioButton_MaterialCompact,
        .dxeRadioButtonList_MaterialCompact,
        .dxeCheckBoxList_MaterialCompact {
            cursor: default;
        }

        .dxeTextBox_MaterialCompact {
            background-color: white;
            border: 1px solid #DCDCDC;
            font: 14px 'Roboto Regular', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            -webkit-border-radius: 2px;
            -moz-border-radius: 2px;
            -o-border-radius: 2px;
            -khtml-border-radius: 2px;
            border-radius: 2px;
        }

        .dxeTextBoxDefaultWidthSys,
        .dxeButtonEditSys {
            width: 170px;
        }

        .dxeTextBoxSys,
        .dxeMemoSys {
            border-collapse: separate !important;
        }

        .dxeTextBoxDefaultWidthSys,
        .dxeButtonEditSys {
            width: 170px;
        }

        .dxeTextBoxSys,
        .dxeMemoSys {
            border-collapse: separate !important;
        }

        .dxic {
            position: relative;
        }

        .dxic {
            position: relative;
        }

        noindex:-o-prefocus,
        input[type="text"].dxeEditArea_MaterialCompact,
        input[type="password"].dxeEditArea_MaterialCompact {
            margin-top: 1px;
            margin-bottom: 0;
        }

        input[type="text"].dxeEditArea_MaterialCompact,
        input[type="password"].dxeEditArea_MaterialCompact {
            margin-top: 0;
            margin-bottom: 0;
        }

        .dxeMemoEditAreaSys, /*Bootstrap correction*/
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            display: block;
            -webkit-box-shadow: none;
            -moz-box-shadow: none;
            box-shadow: none;
            -webkit-transition: none;
            -moz-transition: none;
            -o-transition: none;
            transition: none;
            -webkit-border-radius: 0px;
            -moz-border-radius: 0px;
            border-radius: 0px;
        }

        .dxeEditAreaSys,
        .dxeMemoEditAreaSys, /*Bootstrap correction*/
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            font: inherit;
            line-height: normal;
            outline: 0;
        }

        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            margin-top: 0;
            margin-bottom: 0;
        }

        .dxeEditAreaSys,
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            padding: 0px 1px 0px 0px; /* B146658 */
        }

        .dxeMemoEditAreaSys, /*Bootstrap correction*/
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            display: block;
            -webkit-box-shadow: none;
            -moz-box-shadow: none;
            box-shadow: none;
            -webkit-transition: none;
            -moz-transition: none;
            -o-transition: none;
            transition: none;
            -webkit-border-radius: 0px;
            -moz-border-radius: 0px;
            border-radius: 0px;
        }

        .dxeEditAreaSys,
        .dxeMemoEditAreaSys, /*Bootstrap correction*/
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            font: inherit;
            line-height: normal;
            outline: 0;
        }

        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            margin-top: 0;
            margin-bottom: 0;
        }

        .dxeEditAreaSys,
        input[type="text"].dxeEditAreaSys, /*Bootstrap correction*/
        input[type="password"].dxeEditAreaSys /*Bootstrap correction*/ {
            padding: 0px 1px 0px 0px; /* B146658 */
        }

        .dxeEditArea_MaterialCompact,
        body input.dxeEditArea_MaterialCompact {
            color: #484848;
        }

        .dxeEditArea_MaterialCompact {
            border: 1px solid #A0A0A0;
        }

        .dxeEditAreaSys {
            border: 0px !important;
            background-position: 0 0; /* iOS Safari */
            -webkit-box-sizing: content-box; /*Bootstrap correction*/
            -moz-box-sizing: content-box; /*Bootstrap correction*/
            box-sizing: content-box; /*Bootstrap correction*/
        }

        .dxeEditAreaSys {
            border: 0px !important;
            background-position: 0 0; /* iOS Safari */
            -webkit-box-sizing: content-box; /*Bootstrap correction*/
            -moz-box-sizing: content-box; /*Bootstrap correction*/
            box-sizing: content-box; /*Bootstrap correction*/
        }

        button, input, optgroup, select, textarea {
            margin: 0;
            font-family: inherit;
            font-size: inherit;
            line-height: inherit
        }

        .dxbButtonSys.dxbTSys {
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
            display: inline-table;
            border-spacing: 0;
            border-collapse: separate;
        }

        .dxbButtonSys.dxbTSys {
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
            display: inline-table;
            border-spacing: 0;
            border-collapse: separate;
        }

        .dxbButton_iOS {
            color: white;
            border: 1px solid #007BF7;
            border-radius: 2px;
            -webkit-border-radius: 2px;
            background-color: #007BF7;
            padding: 1px;
            font: 14px "Segoe UI", Helvetica, "Droid Sans", Tahoma, Geneva, sans-serif;
        }

        .dxbButtonSys /*Bootstrap correction*/ {
            -webkit-box-sizing: content-box;
            -moz-box-sizing: content-box;
            box-sizing: content-box;
        }

        .dxbButtonSys {
            cursor: pointer;
            display: inline-block;
            text-align: center;
            white-space: nowrap;
        }

        .dxbButton_iOS {
            color: white;
            border: 1px solid #007BF7;
            border-radius: 2px;
            -webkit-border-radius: 2px;
            background-color: #007BF7;
            padding: 1px;
            font: 14px "Segoe UI", Helvetica, "Droid Sans", Tahoma, Geneva, sans-serif;
        }

        .dxbButtonSys /*Bootstrap correction*/ {
            -webkit-box-sizing: content-box;
            -moz-box-sizing: content-box;
            box-sizing: content-box;
        }

        .dxbButtonSys {
            cursor: pointer;
            display: inline-block;
            text-align: center;
            white-space: nowrap;
        }

        .ms-4 {
            margin-left: 1.5rem !important
        }

        .dxeButtonEdit_MaterialCompact {
            background-color: white;
            border: 1px solid #DCDCDC;
            -webkit-border-radius: 2px;
            -moz-border-radius: 2px;
            -o-border-radius: 2px;
            -khtml-border-radius: 2px;
            border-radius: 2px;
            width: 170px;
            font: 14px 'Roboto Regular', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            border-collapse: separate;
            border-spacing: 0;
        }

        .dxeButtonEditButton_MaterialCompact.dxeButtonEditClearButton_MaterialCompact,
        .dxeButtonEditButton_MaterialCompact.dxeButtonEditClearButton_MaterialCompact:hover {
            background: none;
            border-width: 0;
            line-height: 0;
            padding-top: 0;
            padding-bottom: 0;
        }

        .dxHideContent.dxeButtonEditClearButton_MaterialCompact {
            cursor: default;
        }

        .dxeButtonEditButton_MaterialCompact {
            padding: 7px;
        }

        .dxeButtonEditButton_MaterialCompact,
        .dxeCalendarButton_MaterialCompact,
        .dxeSpinIncButton_MaterialCompact,
        .dxeSpinDecButton_MaterialCompact,
        .dxeSpinLargeIncButton_MaterialCompact,
        .dxeSpinLargeDecButton_MaterialCompact,
        .dxeColorEditButton_MaterialCompact {
            background-color: white;
            background-image: none;
            vertical-align: middle;
            cursor: pointer;
            text-align: center;
            white-space: nowrap;
            border: none;
        }

        .dxgvControl_MaterialCompact,
        .dxgvDisabled_MaterialCompact {
            font: 14px 'Roboto Regular', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            background-color: white;
            color: #484848;
            cursor: default;
        }

        .dxgvTable_MaterialCompact {
            -webkit-tap-highlight-color: transparent;
        }

        .dxgvTable_MaterialCompact {
            background-color: white;
            border: 1px solid #DFDFDF;
            border-bottom-width: 0;
            border-radius: 4px;
            border-bottom-left-radius: 0;
            border-bottom-right-radius: 0;
            box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16);
            border-collapse: separate !important;
            overflow: hidden;
        }

        .dxgvHeader_MaterialCompact {
            cursor: pointer;
            white-space: nowrap;
            padding: 13px 10px 11px;
            border: 1px solid #DFDFDF;
            background-color: white;
            color: black;
            overflow: hidden;
            font-weight: normal;
            text-align: left;
            font: 14px 'Roboto Medium', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            font-size: 1em;
        }

        a.dxbButton_MaterialCompact {
            color: #35B86B;
            text-decoration: none;
            box-shadow: none;
            -moz-box-shadow: none;
            -webkit-box-shadow: none;
        }

        a.dxbButtonSys {
            border: 0;
            background: none;
            padding: 0;
        }

        a.dxbButtonSys {
            border: 0;
            background: none;
            padding: 0;
        }

        .dxbButton_MaterialCompact {
            color: white;
            background-color: #35B86B;
            -moz-box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
            -webkit-box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
            box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
            -webkit-border-radius: 2px;
            -moz-border-radius: 2px;
            -o-border-radius: 2px;
            -khtml-border-radius: 2px;
            border-radius: 2px;
            padding: 1px;
            font: 14px 'Roboto Medium', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            -webkit-transition-property: box-shadow, background-color;
            -moz-transition-property: box-shadow, background-color;
            -o-transition-property: box-shadow, background-color;
            transition-property: box-shadow, background-color;
            -webkit-transition-duration: .3s;
            -moz-transition-duration: .3s;
            -o-transition-duration: .3s;
            transition-duration: .3s;
            -webkit-transition-timing-function: ease-out;
            -moz-transition-timing-function: ease-out;
            -o-transition-timing-function: ease-out;
            transition-timing-function: ease-out;
            -webkit-tap-highlight-color: transparent;
        }

        a {
            color: #0d6efd;
            text-decoration: underline
        }

        .dxgvCommandColumn_MaterialCompact {
            padding: 8px 4px;
            white-space: nowrap;
        }

        .dxgvDataRowAlt_MaterialCompact {
            background-color: #F5F5F5;
        }

        .dxeSpinIncButton_MaterialCompact {
            padding: 5px 12px 1px;
        }

        .dxeSpinDecButton_MaterialCompact {
            padding: 1px 12px 5px;
        }

        .dxeMemo_MaterialCompact {
            background-color: white;
            border: 1px solid #DCDCDC;
            font: 14px 'Roboto Regular', Helvetica, 'Droid Sans', Tahoma, Geneva, sans-serif;
            -webkit-border-radius: 2px;
            -moz-border-radius: 2px;
            -o-border-radius: 2px;
            -khtml-border-radius: 2px;
            border-radius: 2px;
        }

        .dxeMemoEditAreaSys /*Bootstrap correction*/ {
            height: auto;
            color: black;
        }

        .dxeMemoEditAreaSys {
            padding: 3px 3px 0px 3px;
            margin: 0px;
            border-width: 0px;
            display: block;
            resize: none;
        }

        .dxeMemoEditAreaSys /*Bootstrap correction*/ {
            height: auto;
            color: black;
        }

        .dxeMemoEditAreaSys {
            padding: 3px 3px 0px 3px;
            margin: 0px;
            border-width: 0px;
            display: block;
            resize: none;
        }

        textarea {
            resize: vertical
        }

        .dxpbVC {
            display: inline-block;
            color: white;
            background-color: rgba(0, 0, 0, 0.50);
            border-radius: 3px;
            padding-left: 8px;
            padding-right: 8px;
        }

        .dxpbVC {
            display: inline-block;
            color: white;
            background-color: rgba(0, 0, 0, 0.50);
            border-radius: 3px;
            padding-left: 8px;
            padding-right: 8px;
        }

        .modal-fullscreen {
            width: 100vw;
            max-width: none;
            max-height: none;
            height: 100vh;
            margin: 0
        }
    </style>
</head>
<script type="text/javascript">
    var calcTotalTimeout;

    function calcTotal1(s, e) {
        clearTimeout(calcTotalTimeout);

        calcTotalTimeout = setTimeout(function () {
            ASPxGridView23.batchEditApi.EndEdit();

            // Safely retrieve and sanitize each summary value
            var totReimTranspo = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('ReimTranspo_Amount1')) || 0;
            var totFixedAllow = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('FixedAllow_Amount')) || 0;
            var totMiscTravel = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('MiscTravel_Amount')) || 0;
            var totEntertainment = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('Entertainment_Amount')) || 0;
            var totBusMeals = parseFloat(ASPxGridView23.batchEditApi.GetTotalSummaryValue('BusMeals_Amount')) || 0;

            var total = totReimTranspo + totFixedAllow + totMiscTravel + totEntertainment + totBusMeals;

            totalExpTB1.SetText(total.toFixed(2));
        }, 1000); // 1-second delay
    }

    function onCustomButtonClick(s, e) {
        if (e.buttonID == 'btnView') {
            var fileId = s.GetRowKey(e.visibleIndex);
            var appId = "1032";
            travelExpensePopup1.Hide();
            LoadingPanel.Show();
            ViewDocument(fileId, appId);
        }
    }

    async function ExpPopupClick1(s, e) {
        if (!ASPxClientEdit.ValidateGroup("PopupSubmit")) return;

        LoadingPanel.Show();
        const travelDate = travelDateCalendar1.GetDate();
        let totalExp = totalExpTB1.GetValue();

        try {
            if (ASPxGridView23.batchEditApi.HasChanges()) {
                // Commit all edited cells first
                ASPxGridView23.batchEditApi.EndEdit();

                // Update grid and wait for EndCallback once
                await new Promise((resolve) => {
                    // Ensure handler is added BEFORE UpdateEdit
                    var handler = function () {
                        ASPxGridView23.EndCallback.RemoveHandler(handler); // faster than ClearHandlers
                        totalExp = totalExpTB1.GetValue(); // safely get total after update
                        resolve();
                    };

                    ASPxGridView23.EndCallback.AddHandler(handler);
                    ASPxGridView23.UpdateEdit();
                });
            }

            const response = await $.ajax({
                type: "POST",
                url: "TravelExpenseAddDetails.aspx/UpdateTravelExpenseDetailsAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    travelDate: travelDate,
                    totalExp: totalExp
                })
            });

            window.open(response.d, "_self");
        } catch (error) {
            console.error("Error:", error);
            LoadingPanel.Hide();
        }
    }
</script>
<body>
    <%-- Start of DocumentViewer Modal --%>
    <div class="modal fade" id="viewModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1"  aria-labelledby="staticBackdropLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-fullscreen modal-dialog-scrollable" id="modalDialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="vmodalTit"><i class="bi bi-file-earmark-pdf text-danger" style="margin-right: 0.5rem;"></i><strong id="modalTitle">Preview File</strong></h5>
                    <a id="modalDownload" href="" class="btn btn-secondary btn-sm">
                        <i class="bi bi-download text-white" style="margin-right: 0.5rem;"></i>
                        Download
                    </a>
                </div>
                <div class="modal-body container-fluid mx-auto text-center bg-secondary modal-fullscreen" id="pdf_container">
                </div>
                <div class="modal-footer" id="wmodalFooter">
                    <button type="button" id="modalClose" class="btn btn-light btn-outline-secondary btn-sm">Close</button>
                </div>
                <script>
                    $("#modalClose").click(function () {
                        $("#viewModal").modal("hide");
                        travelExpensePopup1.Show();
                    });
                </script>
            </div>
        </div>
    </div>
    <%-- End of DocumentViewer Modal --%>

    <form id="form1" runat="server">
        <div>

        <dx:ASPxPopupControl ID="travelExpensePopup1" runat="server" FooterText="" HeaderText="Travel Expense Item" ClientInstanceName="travelExpensePopup1" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="None" CssClass="rounded" ScrollBars="Both" Maximized="True" ShowCloseButton="False" PopupAnimationType="Fade" ShowOnPageLoad="True">
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <%--<div id="expDiv" style="height: 500px; width: 1200px; overflow: scroll;">--%>
                    <dx:ASPxCallbackPanel ID="addExpCallback0" runat="server" ClientInstanceName="addExpCallback" Width="100%">
                        <PanelCollection>
                            <dx:PanelContent runat="server">
                                <dx:ASPxFormLayout ID="ASPxFormLayout12" runat="server" Height="100%" Width="100%">
                                    <Items>
                                        <dx:LayoutGroup BackColor="WhiteSmoke" Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%">
                                            <BorderBottom BorderStyle="Solid" />
                                            <Items>
                                                <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Left" Width="1px">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxTextBox ID="totalExpTB1" runat="server" ClientEnabled="False" ClientInstanceName="totalExpTB1" DisplayFormatString="{0:0,0.00}" Font-Bold="True" Font-Size="Medium" ReadOnly="True" Theme="MaterialCompact" Width="300px">
                                                                <Border BorderStyle="None" />
                                                                <DisabledStyle ForeColor="#333333">
                                                                </DisabledStyle>
                                                            </dx:ASPxTextBox>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                                <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" HorizontalAlign="Right">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxButton ID="viewBtn2" runat="server" AutoPostBack="False" BackColor="#006DD6" ClientInstanceName="popupSubmitBtn" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="View Allowance Matrix" UseSubmitBehavior="False" ValidationGroup="PopupSubmit">
                                                                <ClientSideEvents Click="function(s, e) {
	window.open('https://devapps.anflocor.com/Inquiry/AllowanceRateBundle.aspx', '_blank')
}" />
                                                                <Border BorderColor="#006DD6" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupSubmitBtn1" runat="server" BackColor="#006838" ClientInstanceName="viewBtn1" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="White" Text="Save" UseSubmitBehavior="False" ValidationGroup="PopupSubmit" AutoPostBack="False">
                                                                <ClientSideEvents Click="ExpPopupClick1" />
                                                                <Border BorderColor="#006838" />
                                                            </dx:ASPxButton>
                                                            <dx:ASPxButton ID="popupCancelBtn1" runat="server" AutoPostBack="False" BackColor="White" ClientInstanceName="popupCancelBtn" CssClass="ms-4" Font-Bold="True" Font-Size="Small" ForeColor="#878787" Text="Cancel" UseSubmitBehavior="False">
                                                                <ClientSideEvents Click="function(s, e) {
	
            ASPxGridView23.CancelEdit();
            LoadingPanel.Show();
            history.back();
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
                                        <dx:LayoutGroup Caption="" ColCount="3" ColSpan="1" ColumnCount="3" GroupBoxDecoration="Box" VerticalAlign="Middle" Width="100%">
                                            <Paddings PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                            <GroupBoxStyle>
                                                <Border BorderColor="#006838" BorderStyle="Solid" BorderWidth="1px" />
                                            </GroupBoxStyle>
                                            <Items>
                                                <dx:LayoutItem Caption="Date" ColSpan="1" VerticalAlign="Middle" Width="20%">
                                                    <LayoutItemNestedControlCollection>
                                                        <dx:LayoutItemNestedControlContainer runat="server">
                                                            <dx:ASPxDateEdit ID="travelDateCalendar1" runat="server" ClientInstanceName="travelDateCalendar1" Font-Bold="True" Height="40px" Theme="MaterialCompact" Width="260px">
                                                                <CalendarProperties ShowWeekNumbers="False">
                                                                    <DaySelectedStyle BackColor="#0D6943">
                                                                    </DaySelectedStyle>
                                                                    <TodayStyle ForeColor="#0D6943">
                                                                    </TodayStyle>
                                                                    <ButtonStyle>
                                                                        <PressedStyle BackColor="#0D6943">
                                                                        </PressedStyle>
                                                                    </ButtonStyle>
                                                                    <HeaderStyle BackColor="#0D6943" />
                                                                </CalendarProperties>
                                                                <ValidationSettings Display="Dynamic" ErrorTextPosition="Top" SetFocusOnError="True" ValidationGroup="PopupSubmit">
                                                                    <ErrorImage IconID="outlookinspired_highimportance_svg_16x16">
                                                                    </ErrorImage>
                                                                    <RequiredField ErrorText="*Required" IsRequired="True" />
                                                                </ValidationSettings>
                                                                <DisabledStyle ForeColor="Black">
                                                                </DisabledStyle>
                                                            </dx:ASPxDateEdit>
                                                        </dx:LayoutItemNestedControlContainer>
                                                    </LayoutItemNestedControlCollection>
                                                    <CaptionSettings Location="Left" />
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:LayoutItem>
                                            </Items>
                                        </dx:LayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Items>
                                                <dx:LayoutGroup Caption="Expense Items" ColSpan="1" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="1" VerticalAlign="Middle" Width="80%">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxGridView ID="ASPxGridView23" runat="server" AutoGenerateColumns="False" ClientInstanceName="ASPxGridView23" EnableTheming="True" Font-Size="Small" KeyFieldName="TravelExpenseDetailMap_ID" Theme="MaterialCompact" Width="100%" OnRowDeleting="ASPxGridView23_RowDeleting" OnRowInserting="ASPxGridView23_RowInserting" OnRowUpdating="ASPxGridView23_RowUpdating" DataSourceID="SqlExpenseDetails" OnCommandButtonInitialize="ASPxGridView23_CommandButtonInitialize">
                                                                        <ClientSideEvents BatchEditRowDeleting="calcTotal1" BatchEditRowRecovering="calcTotal1" />
                                                                        <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                        </SettingsAdaptivity>
                                                                        <SettingsPager Mode="ShowAllRecords">
                                                                        </SettingsPager>
                                                                        <SettingsEditing Mode="Batch" NewItemRowPosition="Bottom">
                                                                            <BatchEditSettings StartEditAction="Click" />
                                                                        </SettingsEditing>
                                                                        <Settings ShowStatusBar="Hidden" ShowFooter="True" />
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" />
                                                                        <SettingsCommandButton>
                                                                            <NewButton Text=" ">
                                                                                <Image IconID="iconbuilder_actions_add_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="False" ForeColor="#006838">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </NewButton>
                                                                            <EditButton>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" ForeColor="#E67C0E">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </EditButton>
                                                                            <DeleteButton Text=" ">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16" ToolTip="Remove">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="False" ForeColor="#CC2A17">
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption=" " ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="35px">
                                                                                <HeaderStyle HorizontalAlign="Center" >
                                                                                <Border BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" />
                                                                                </HeaderStyle>
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                                <FooterCellStyle HorizontalAlign="Center">
                                                                                </FooterCellStyle>
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewBandColumn Caption="REIMBURSABLE TRANSPORTATION" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption=" Type" CellRowSpan="3" FieldName="ReimTranspo_Type1" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" DataSourceID="SqlReimTranspo" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="180px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderLeft BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption=" Amount" CellRowSpan="3" FieldName="ReimTranspo_Amount1" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit ClientInstanceName="ReimTranspo_Amount1" DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <EditFormCaptionStyle HorizontalAlign="Center">
                                                                                        </EditFormCaptionStyle>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="FIXED ALLOWANCES" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="F or P" FieldName="FixedAllow_ForP" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                        <PropertiesComboBox AllowNull="True">
                                                                                            <Items>
                                                                                                <dx:ListEditItem Text="Full" Value="F" />
                                                                                                <dx:ListEditItem Text="Partial" Value="P" />
                                                                                            </Items>
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption=" Remarks" FieldName="FixedAllow_Remarks" ShowInCustomizationForm="True" VisibleIndex="0" Width="110px">
                                                                                                <HeaderStyle HorizontalAlign="Center">
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="FixedAllow_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="ENTERTAINMENT" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="Entertainment_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="Entertainment_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="BUSINESS MEALS" MaxWidth="50" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" Wrap="True" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="BusMeals_Explain" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataMemoColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="BusMeals_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewBandColumn Caption="MISC. TRAVEL EXPENSES" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center" />
                                                                                <Columns>
                                                                                    <dx:GridViewDataComboBoxColumn Caption="Type" FieldName="MiscTravel_Type" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                        <PropertiesComboBox AllowNull="True" ClientInstanceName="miscTravelType" DataSourceID="SqlMiscTravelExp" DropDownRows="9" TextField="Description" TextFormatString="{0}. {1}" ValueField="ID">
                                                                                            <Columns>
                                                                                                <dx:ListBoxColumn Caption="Type" FieldName="Type" Width="50px">
                                                                                                </dx:ListBoxColumn>
                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="240px">
                                                                                                </dx:ListBoxColumn>
                                                                                            </Columns>
                                                                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	var selectedValue = s.GetText(); // Get the selected value from ComboBox 
              
               if (selectedValue.includes(&quot;Others&quot;)) { 
                      //ASPxGridView22.GetColumn(15).SetVisible(true);
                      MiscTravelExpSpecify.SetVisible(true);  
                      //miscTravelExpPopup.Show();
               }else{
                      //ASPxGridView22.GetColumn(15).SetVisible(false);
                      MiscTravelExpSpecify.SetVisible(false); 
               }
}
" />
                                                                                            <ClearButton DisplayMode="Always">
                                                                                            </ClearButton>
                                                                                        </PropertiesComboBox>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataMemoColumn Caption="if Others, specify:" FieldName="MiscTravel_Specify" Name="miscTrav" ShowInCustomizationForm="True" VisibleIndex="0" Width="140px">
                                                                                                <PropertiesMemoEdit ClientInstanceName="MiscTravelExpSpecify">
                                                                                                    <ClientSideEvents Init="function(s, e) {
	MiscTravelExpSpecify.SetVisible(false);
}
" />
                                                                                                </PropertiesMemoEdit>
                                                                                                <HeaderStyle>
                                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                                </HeaderStyle>
                                                                                            </dx:GridViewDataMemoColumn>
                                                                                        </Columns>
                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                    <dx:GridViewDataSpinEditColumn Caption="Amount" FieldName="MiscTravel_Amount" ShowInCustomizationForm="True" VisibleIndex="1" Width="90px">
                                                                                        <PropertiesSpinEdit DecimalPlaces="2" DisplayFormatInEditMode="True" DisplayFormatString="N" NumberFormat="Custom">
                                                                                            <ClientSideEvents UserInput="calcTotal1" />
                                                                                        </PropertiesSpinEdit>
                                                                                        <HeaderStyle HorizontalAlign="Center">
                                                                                        <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                        </HeaderStyle>
                                                                                        <CellStyle>
                                                                                            <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                        </CellStyle>
                                                                                    </dx:GridViewDataSpinEditColumn>
                                                                                </Columns>
                                                                            </dx:GridViewBandColumn>
                                                                            <dx:GridViewDataTextColumn Caption="LOCATION/PARTICULARS" FieldName="LocParticulars" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                                                                <HeaderStyle HorizontalAlign="Center" Font-Bold="True">
                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                </HeaderStyle>
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                    <BorderTop BorderColor="Black" BorderStyle="Solid" />
                                                                                    <BorderRight BorderColor="Black" BorderStyle="Solid" />
                                                                                </CellStyle>
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataMemoColumn Caption="FINANCE REMARKS" FieldName="FinanceRemarks" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                <HeaderStyle Font-Bold="True" HorizontalAlign="Center">
                                                                                <Border BorderColor="Black" BorderStyle="Solid" />
                                                                                </HeaderStyle>
                                                                                <CellStyle Font-Size="Smaller">
                                                                                </CellStyle>
                                                                            </dx:GridViewDataMemoColumn>
                                                                        </Columns>
                                                                        <TotalSummary>
                                                                            <dx:ASPxSummaryItem FieldName="ReimTranspo_Amount1" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="FixedAllow_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="MiscTravel_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="Entertainment_Amount" SummaryType="Sum" />
                                                                            <dx:ASPxSummaryItem FieldName="BusMeals_Amount" SummaryType="Sum" />
                                                                        </TotalSummary>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="2px" PaddingTop="2px" />
                                                                            </Header>
                                                                            <AlternatingRow BackColor="#ECECEC">
                                                                            </AlternatingRow>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" PaddingTop="20px" />
                                                                    </dx:ASPxGridView>
                                                                    <asp:SqlDataSource ID="SqlExpenseDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE ([TravelExpenseDetail_ID] = @TravelExpenseDetail_ID)" DeleteCommand="DELETE FROM [ACCEDE_T_TravelExpenseDetailsMap] WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID" UpdateCommand="UPDATE [ACCEDE_T_TravelExpenseDetailsMap] SET [TravelExpenseDetail_ID] = @TravelExpenseDetail_ID, [ReimTranspo_Type1] = @ReimTranspo_Type1, [ReimTranspo_Amount1] = @ReimTranspo_Amount1, [ReimTranspo_Type2] = @ReimTranspo_Type2, [ReimTranspo_Amount2] = @ReimTranspo_Amount2, [ReimTranspo_Type3] = @ReimTranspo_Type3, [ReimTranspo_Amount3] = @ReimTranspo_Amount3, [FixedAllow_ForP] = @FixedAllow_ForP, [FixedAllow_Amount] = @FixedAllow_Amount, [MiscTravel_Type] = @MiscTravel_Type, [MiscTravel_Specify] = @MiscTravel_Specify, [MiscTravel_Amount] = @MiscTravel_Amount, [Entertainment_Explain] = @Entertainment_Explain, [Entertainment_Amount] = @Entertainment_Amount, [BusMeals_Explain] = @BusMeals_Explain, [BusMeals_Amount] = @BusMeals_Amount, [OtherBus_Type] = @OtherBus_Type, [OtherBus_Specify] = @OtherBus_Specify, [OtherBus_Amount] = @OtherBus_Amount, [FixedAllow_Remarks] = @FixedAllow_Remarks, [LocParticulars] = @LocParticulars, [FinanceRemarks] = @FinanceRemarks WHERE [TravelExpenseDetailMap_ID] = @TravelExpenseDetailMap_ID">
                                                                        <DeleteParameters>
                                                                            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
                                                                        </DeleteParameters>
                                                                        <SelectParameters>
                                                                            <asp:SessionParameter Name="TravelExpenseDetail_ID" SessionField="ExpDetailsID" Type="Int32" />
                                                                        </SelectParameters>
                                                                        <UpdateParameters>
                                                                            <asp:Parameter Name="TravelExpenseDetail_ID" Type="Int32" />
                                                                            <asp:Parameter Name="ReimTranspo_Type1" Type="String" />
                                                                            <asp:Parameter Name="ReimTranspo_Amount1" Type="Decimal" />
                                                                            <asp:Parameter Name="ReimTranspo_Type2" Type="String" />
                                                                            <asp:Parameter Name="ReimTranspo_Amount2" Type="Decimal" />
                                                                            <asp:Parameter Name="ReimTranspo_Type3" Type="String" />
                                                                            <asp:Parameter Name="ReimTranspo_Amount3" Type="Decimal" />
                                                                            <asp:Parameter Name="FixedAllow_ForP" Type="String" />
                                                                            <asp:Parameter Name="FixedAllow_Amount" Type="Decimal" />
                                                                            <asp:Parameter Name="MiscTravel_Type" Type="String" />
                                                                            <asp:Parameter Name="MiscTravel_Specify" Type="String" />
                                                                            <asp:Parameter Name="MiscTravel_Amount" Type="Decimal" />
                                                                            <asp:Parameter Name="Entertainment_Explain" Type="String" />
                                                                            <asp:Parameter Name="Entertainment_Amount" Type="Decimal" />
                                                                            <asp:Parameter Name="BusMeals_Explain" Type="String" />
                                                                            <asp:Parameter Name="BusMeals_Amount" Type="Decimal" />
                                                                            <asp:Parameter Name="OtherBus_Type" Type="String" />
                                                                            <asp:Parameter Name="OtherBus_Specify" Type="String" />
                                                                            <asp:Parameter Name="OtherBus_Amount" Type="Decimal" />
                                                                            <asp:Parameter Name="FixedAllow_Remarks" Type="String" />
                                                                            <asp:Parameter Name="LocParticulars" Type="String" />
                                                                            <asp:Parameter Name="FinanceRemarks" />
                                                                            <asp:Parameter Name="TravelExpenseDetailMap_ID" Type="Int32" />
                                                                        </UpdateParameters>
                                                                    </asp:SqlDataSource>
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:TabbedLayoutGroup ColSpan="1" Width="100%">
                                            <Paddings PaddingTop="20px" />
                                            <Items>
                                                <dx:LayoutGroup Caption="Supporting Documents" ColCount="5" ColSpan="1" ColumnCount="5" GroupBoxDecoration="None" HorizontalAlign="Center" Width="100%">
                                                    <Paddings Padding="0px" />
                                                    <Items>
                                                        <dx:LayoutItem Caption="" ColSpan="5" ColumnSpan="5" RowSpan="2" VerticalAlign="Middle">
                                                            <LayoutItemNestedControlCollection>
                                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                                    <dx:ASPxUploadControl ID="TraUploadController1" runat="server" AutoStartUpload="True" ClientInstanceName="TraUploadController1" Font-Size="Small" ShowProgressPanel="True" UploadMode="Auto" Width="100%" OnFilesUploadComplete="TraUploadController1_FilesUploadComplete">
                                                                        <ClientSideEvents FilesUploadComplete="function(s, e) {
	TraDocuGrid.Refresh();
}
" />
                                                                        <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                                                        </AdvancedModeSettings>
                                                                        <Paddings PaddingBottom="10px" />
                                                                        <TextBoxStyle Font-Size="Small" />
                                                                    </dx:ASPxUploadControl>
                                                                    <dx:ASPxGridView ID="TraDocuGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="TraDocuGrid" Font-Size="Small" KeyFieldName="ID" Theme="MaterialCompact" Width="100%" DataSourceID="SqlTraDocs" OnCommandButtonInitialize="TraDocuGrid_CommandButtonInitialize" OnCustomButtonInitialize="TraDocuGrid_CustomButtonInitialize">
                                                                        <ClientSideEvents CustomButtonClick="onCustomButtonClick" />
                                                                        <SettingsEditing Mode="Inline">
                                                                        </SettingsEditing>
                                                                        <SettingsBehavior AllowDragDrop="False" AllowGroup="False" AllowHeaderFilter="False" AllowSort="False" ConfirmDelete="True" />
                                                                        <SettingsCommandButton>
                                                                            <EditButton>
                                                                                <Image IconID="richedit_trackingchanges_trackchanges_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006DD6">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </EditButton>
                                                                            <DeleteButton Text="Remove">
                                                                                <Image IconID="iconbuilder_actions_removecircled_svg_16x16">
                                                                                </Image>
                                                                                <Styles>
                                                                                    <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#CC2A17">
                                                                                        <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                    </Style>
                                                                                </Styles>
                                                                            </DeleteButton>
                                                                        </SettingsCommandButton>
                                                                        <SettingsPopup>
                                                                            <FilterControl AutoUpdatePosition="False">
                                                                            </FilterControl>
                                                                        </SettingsPopup>
                                                                        <Columns>
                                                                            <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                <CustomButtons>
                                                                                    <dx:GridViewCommandColumnCustomButton ID="btnView" Text="View">
                                                                                        <Image IconID="actions_open2_svg_16x16">
                                                                                        </Image>
                                                                                        <Styles>
                                                                                            <Style Font-Bold="True" Font-Size="Smaller" ForeColor="#006838">
                                                                                                <Paddings PaddingBottom="4px" PaddingTop="4px" />
                                                                                            </Style>
                                                                                        </Styles>
                                                                                    </dx:GridViewCommandColumnCustomButton>
                                                                                </CustomButtons>
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileName" ShowInCustomizationForm="True" VisibleIndex="3" ReadOnly="True">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileExtension" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="FileAttachment" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" ReadOnly="True">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataComboBoxColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                <PropertiesComboBox DataSourceID="SqlSupDocType" TextField="Document_Type" ValueField="ID">
                                                                                </PropertiesComboBox>
                                                                                <EditFormSettings Visible="True" />
                                                                            </dx:GridViewDataComboBoxColumn>
                                                                        </Columns>
                                                                        <Styles>
                                                                            <Header>
                                                                                <Paddings PaddingBottom="5px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="5px" />
                                                                            </Header>
                                                                            <Cell>
                                                                                <Paddings PaddingBottom="2px" PaddingLeft="7px" PaddingRight="7px" PaddingTop="2px" />
                                                                            </Cell>
                                                                        </Styles>
                                                                        <Paddings PaddingBottom="20px" />
                                                                    </dx:ASPxGridView>
                                                                    <asp:SqlDataSource ID="SqlTraDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT ITP_T_FileAttachment.ID, ITP_T_FileAttachment.FileName, ITP_T_FileAttachment.Description, ITP_T_FileAttachment.DateUploaded, ITP_T_FileAttachment.FileSize, ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType, ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID, ITP_T_FileAttachment.FileExtension FROM ITP_T_FileAttachment INNER JOIN ACCEDE_T_TravelExpenseDetailsFileAttach ON ITP_T_FileAttachment.ID = ACCEDE_T_TravelExpenseDetailsFileAttach.FileAttachment_ID WHERE (ACCEDE_T_TravelExpenseDetailsFileAttach.DocumentType = @DocumentType) AND (ACCEDE_T_TravelExpenseDetailsFileAttach.ExpenseDetails_ID = @ExpenseDetails_ID)" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [Description] = @Description, [App_ID] = 1032 WHERE [ID] = @original_ID">
                                                                        <DeleteParameters>
                                                                            <asp:Parameter Name="original_ID" Type="Int32" />
                                                                        </DeleteParameters>
                                                                        <SelectParameters>
                                                                            <asp:Parameter DefaultValue="sub" Name="DocumentType" />
                                                                            <asp:SessionParameter DefaultValue="" Name="ExpenseDetails_ID" SessionField="ExpDetailsID" />
                                                                        </SelectParameters>
                                                                        <UpdateParameters>
                                                                            <asp:Parameter Name="Description" Type="String" />
                                                                            <asp:Parameter Name="original_ID" Type="Int32" />
                                                                        </UpdateParameters>
                                                                    </asp:SqlDataSource>
                                                                    <br />
                                                                </dx:LayoutItemNestedControlContainer>
                                                            </LayoutItemNestedControlCollection>
                                                            <Paddings PaddingTop="15px" />
                                                            <CaptionStyle Font-Bold="True">
                                                            </CaptionStyle>
                                                        </dx:LayoutItem>
                                                    </Items>
                                                </dx:LayoutGroup>
                                            </Items>
                                        </dx:TabbedLayoutGroup>
                                        <dx:LayoutItem Caption="Total Expenses" ColSpan="1" HorizontalAlign="Right" Visible="False">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxTextBox ID="ASPxTextBox7" runat="server" Width="50%">
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                            <BorderTop BorderStyle="Solid" />
                                        </dx:LayoutItem>
                                    </Items>
                                    <Paddings PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                                </dx:ASPxFormLayout>
                            </dx:PanelContent>
                        </PanelCollection>
                    </dx:ASPxCallbackPanel>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact" Text="" CssClass="p-0 m-0"></dx:ASPxLoadingPanel>

    <asp:SqlDataSource ID="SqlReimTranspo" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ReimTranspo] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOtherBusExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_OtherBusExp] ORDER BY [Type]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlMiscTravelExp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_MiscTravelExp] ORDER BY [Type]"></asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlSupDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_DocumentType] ORDER BY [Document_Type]"></asp:SqlDataSource>
        </div>
    </form>
</body>
</html>
