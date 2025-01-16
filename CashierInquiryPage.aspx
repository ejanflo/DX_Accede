<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="CashierInquiryPage.aspx.cs" Inherits="DX_WebTemplate.CashierInquiryPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <%-- DXCOMMENT: Configure ASPxGridView's columns in accordance with datasource fields --%>
    <style>
    .centerPane {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    #scrollableContainer {
            overflow: auto;
            height: 600px;
            border: 1px solid #ccc; 
            padding: 10px; 
        }
</style>
    <script>
        function OnCustomButtonClick(s, e) {
            console.log(e.buttonID);
            if (e.buttonID == 'btnPrint') {
                gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                LoadingPanel.Show();
            }

            if (e.buttonID == 'btnView') {
                
                LoadingPanel.SetText('Loading Document&hellip;');
                LoadingPanel.Show();
                var rowKey = s.GetRowKey(e.visibleIndex);
                s.GetRowValues(e.visibleIndex, 'SourceTable', function (value) {
                    console.log(value);
                    console.log(rowKey);
                    gridMain.PerformCallback(rowKey + "|" + value + "|" + e.buttonID);
                });

            }

            if (e.buttonID == 'btnViewDisbursed') {

                //displayRFPDetails(s.GetRowKey(e.visibleIndex));
                gridMainDisbursed.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
                LoadingPanel.Show();
                
            }
        }

        function ifComp_is_DLI() {
            var layoutControl = window["RFPMainViewForm"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("WBS");
                if (layoutItem) {

                    if (Company_modal.GetValue() == "5") {
                        layoutItem.SetVisible(true);
                    } else {
                        layoutItem.SetVisible(false);
                    }


                }
            }
        }

        //function OnCustomButtonClick(s, e) {
        //    gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            
        //}
        function displayRFPDetails(RFP_ID) {
            Department_modal.PerformCallback(RFP_ID);
            
            $.ajax({
                type: "POST",
                url: "RFPPage.aspx/RFPDetailsViewAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ RFP_ID: RFP_ID }),
                success: function (response) {
                    // Update the description text box with the response value
                    var layoutControl = window["RFPMainViewForm"];
                    var lastDateText = "";
                    if (layoutControl) {
                        
                        var layoutItem = layoutControl.GetItemByName("RFPMainViewForm");
                        var layoutItem1 = layoutControl.GetItemByName("btnLayoutGroup");
                        if (layoutItem) {
                            console.log("true");
                            layoutItem.SetCaption(response.d.DocNum + " (" + response.d.Status + ")");
                            
                        }

                        if (response.d.isTrav == false) {
                            var layoutItemLastDay = layoutControl.GetItemByName("LastDay_modal");
                            layoutItemLastDay.SetVisible(false);
                        } else {
                            var layoutItemLastDay = layoutControl.GetItemByName("LastDay_modal");
                            layoutItemLastDay.SetVisible(true);
                        }

                        if (response.d.TranType != "1") {
                            var layoutItemLastDay = layoutControl.GetItemByName("pld");
                            layoutItemLastDay.SetVisible(false);
                        } else {
                            var layoutItemLastDay = layoutControl.GetItemByName("pld");
                            layoutItemLastDay.SetVisible(true);
                        }

                        if (response.d.company == 5) {
                            var layoutWBS = layoutControl.GetItemByName("WBS");
                            layoutWBS.SetVisible(true);
                        } else {
                            var layoutWBS = layoutControl.GetItemByName("WBS");
                            layoutWBS.SetVisible(false);
                        }

                        if (response.d.Status == "Saved") {
                            if (layoutItem1) {
                                layoutItem1.SetVisible(true);

                            }
                            Travel_modal.SetReadOnly(false);
                        } else {
                            Travel_modal.SetReadOnly(true);
                        }

                        
                    }

                    if (response.d.LastDate != null) {
                        LastDay_modal.SetDate(new Date(response.d.LastDate));
                        lastDateText = response.d.LastDate;
                    } else {
                        LastDay_modal.SetDate(null);
                    }

                    if (response.d.pld != null) {
                        pld_modal.SetDate(new Date(response.d.pld));
                        pld_text = response.d.pld_dateText;
                    } else {
                        pld_modal.SetDate(null);
                    }

                    var exp = response.d.ExpenseRep != "0" ? response.d.ExpenseRep : "";
                    var fap_id = response.d.fap_id != "0" ? response.d.fap_id : "";
                    console.log(exp);
                    Department_modal.PerformCallback(RFP_ID);
                    FAPWF_modal.PerformCallback(response.d.amount + "|" + response.d.company);
                    FAPWFGrid.PerformCallback(response.d.amount + "|" + response.d.company);

                    Company_modal.SetValue(response.d.company);
                    //Department_modal.SetText(response.d.department_str);
                    //Department_modal.SetValue(response.d.department);
                    TranType_modal.SetValue(response.d.TranType);
                    CostCenter_modal.SetText(response.d.CostCenter);
                    PayMethod_modal.SetValue(response.d.Payment);
                    IO_modal.SetText(response.d.IO);
                    Payee_modal.SetText(response.d.Payee);
                    Travel_modal.SetValue(response.d.isTrav);
                    Amount_modal.SetValue(response.d.amount);
                    Purpose_modal.SetText(response.d.purpose);
                    drpdown_WF_modal.SetValue(response.d.workflow);
                    ExpID_modal.SetValue(exp);
                    FAPWF_modal.SetValue(fap_id);
                    WBS_modal.SetValue(response.d.wbs);
                    expCat_modal.SetValue(response.d.expCat);

                    company_lbl_modal.SetText(Company_modal.GetText());
                    Department_lbl_modal.SetText(response.d.department_str);
                    TranType_lbl_modal.SetText(TranType_modal.GetText());
                    CostCenter_lbl_modal.SetText(CostCenter_modal.GetText());
                    PayMethod_lbl_modal.SetText(PayMethod_modal.GetText());
                    IO_lbl_modal.SetText(IO_modal.GetText());
                    Payee_lbl_modal.SetText(response.d.Payee);
                    Amount_lbl_modal.SetText(Amount_modal.GetText());
                    Purpose_lbl_modal.SetText(Purpose_modal.GetText());
                    drpdown_WF_lbl_modal.SetText(drpdown_WF_modal.GetText());
                    LastDay_lbl_modal.SetText(lastDateText);
                    ExpID_lbl_modal.SetText(ExpID_modal.GetText());
                    FAPWF_modal_lbl.SetText(response.d.fap_name);
                    WBS_lbl_modal.SetText(response.d.wbs);
                    expCat_lbl_modal.SetText(expCat_modal.GetText());
                    console.log(response.d.fap_name);

                    WFSequenceGrid.PerformCallback();
                    //FAPWFGrid.PerformCallback(response.d.amount + "|" + response.d.company);
                    //FAPWF_modal.PerformCallback(response.d.amount + "|" + response.d.company);
                    
                    
                    if (response.d.Status == "Saved" || response.d.Status == "Return") {
                        if (layoutItem1) {
                            //layoutItem1.SetReadOnly(false);

                            Company_modal.SetVisible(true);
                            company_lbl_modal.SetVisible(false);

                            Department_modal.SetVisible(true);
                            Department_lbl_modal.SetVisible(false);

                            TranType_modal.SetVisible(true);
                            TranType_lbl_modal.SetVisible(false);

                            CostCenter_modal.SetVisible(true);
                            CostCenter_lbl_modal.SetVisible(false);

                            PayMethod_modal.SetVisible(true);
                            PayMethod_lbl_modal.SetVisible(false);

                            IO_modal.SetVisible(true);
                            IO_lbl_modal.SetVisible(false);

                            Payee_modal.SetVisible(true);
                            Payee_lbl_modal.SetVisible(false);

                            Amount_modal.SetVisible(true);
                            Amount_lbl_modal.SetVisible(false);

                            Purpose_modal.SetVisible(true);
                            Purpose_lbl_modal.SetVisible(false);

                            drpdown_WF_modal.SetVisible(true);
                            drpdown_WF_lbl_modal.SetVisible(false);

                            LastDay_modal.SetVisible(true);
                            LastDay_lbl_modal.SetVisible(false);

                            ExpID_modal.SetVisible(true);
                            ExpID_lbl_modal.SetVisible(false);

                            FAPWF_modal.SetVisible(true);
                            FAPWF_modal_lbl.SetVisible(false);

                            WBS_modal.SetVisible(true);
                            WBS_lbl_modal.SetVisible(false);

                            expCat_modal.SetVisible(true);
                            expCat_lbl_modal.SetVisible(false);

                            btnEditSubmit.SetVisible(true);
                            btnEditSave.SetVisible(true);
                        }
                    } else {
                        company_lbl_modal.SetVisible(true);
                        Company_modal.SetVisible(false);

                        Department_modal.SetVisible(false);
                        Department_lbl_modal.SetVisible(true);

                        TranType_modal.SetVisible(false);
                        TranType_lbl_modal.SetVisible(true);

                        CostCenter_modal.SetVisible(false);
                        CostCenter_lbl_modal.SetVisible(true);

                        PayMethod_modal.SetVisible(false);
                        PayMethod_lbl_modal.SetVisible(true);

                        IO_modal.SetVisible(false);
                        IO_lbl_modal.SetVisible(true);

                        Payee_modal.SetVisible(false);
                        Payee_lbl_modal.SetVisible(true);

                        Amount_modal.SetVisible(false);
                        Amount_lbl_modal.SetVisible(true);

                        Purpose_modal.SetVisible(false);
                        Purpose_lbl_modal.SetVisible(true);

                        drpdown_WF_modal.SetVisible(false);
                        drpdown_WF_lbl_modal.SetVisible(true);

                        LastDay_modal.SetVisible(false);
                        LastDay_lbl_modal.SetVisible(true);

                        ExpID_modal.SetVisible(false);
                        ExpID_lbl_modal.SetVisible(true);

                        FAPWF_modal.SetVisible(false);
                        FAPWF_modal_lbl.SetVisible(true);

                        WBS_modal.SetVisible(false);
                        WBS_lbl_modal.SetVisible(true);

                        expCat_modal.SetVisible(false);
                        expCat_lbl_modal.SetVisible(true);

                        btnEditSubmit.SetVisible(false);
                        btnEditSave.SetVisible(false);
                    }

                    LoadingPanel.Hide();
                    
                    
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });

            RFPPopup.Show();
        }

        function OnTravChanged() {
            var layoutControl = window["RFPMainViewForm"];
            var isTrav = Travel_modal.GetValue();
            console.log(isTrav);
            var layoutItemLastDay = layoutControl.GetItemByName("LastDay_modal");
            if (isTrav == true) {
                layoutItemLastDay.SetVisible(true);
            } else {
                layoutItemLastDay.SetVisible(false);
            }
        }

        function OnWFChanged() {
            WFSequenceGrid.PerformCallback();
        }

        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                case 'dataSelectAll':
                    gridMain.SelectRows();
                    break;
                case 'dataUnselectAll':
                    gridMain.UnselectRows();
                    break;
                case 'dataSelectAllOnPage':
                    gridMain.SelectAllRowsOnPage();
                    break;
                case 'dataUnselectAllOnPage':
                    gridMain.UnselectAllRowsOnPage();
                    break;
                case 'New':
                    window.location.href = 'RFPCreationPage.aspx';
                    break;
            }
        }
        function OnInit(s, e) {
            fab.SetActionContext("ActionContext", true);
        }
        function OnActionItemClick(s, e) {
            if (e.actionName === "Cancel") {
                history.back()
            }
        }

        function InserttoRFPMain(status) {
            LoadingPanel.Show();
            var Comp_ID = Company_modal.GetValue();
            var Dept_ID = Department_modal.GetValue();
            var Paymethod = PayMethod_modal.GetValue();
            var tranType = TranType_modal.GetValue();
            var isTrav = Travel_modal.GetValue();
            var costCenter = CostCenter_modal.GetValue();
            var io = IO_modal.GetValue() != null ? IO_modal.GetValue() : "";
            var payee = Payee_modal.GetValue();
            var lastDay = LastDay_modal.GetValue() != null ? LastDay_modal.GetValue() : "";
            var amount = Amount_modal.GetValue();
            var purpose = Purpose_modal.GetValue();
            var wf_id = drpdown_WF_modal.GetValue();
            var exp_id = ExpID_modal.GetValue() != null ? ExpID_modal.GetValue() : "";
            console.log(exp_id);
            var fap_wf = FAPWF_modal.GetValue() != null ? FAPWF_modal.GetValue() : "";
            var wbs = WBS_modal.GetValue() != null ? WBS_modal.GetValue() : "";
            var expCat = expCat_modal.GetValue() != null ? expCat_modal.GetValue() : "";
            console.log(fap_wf);

            $.ajax({
                type: "POST",
                url: "RFPPage.aspx/UpdateRFPMainAjax",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    Comp_ID: Comp_ID,
                    Dept_ID: Dept_ID,
                    Paymethod: Paymethod,
                    tranType: tranType,
                    isTrav: isTrav,
                    costCenter: costCenter,
                    costCenter: costCenter,
                    io: io,
                    payee: payee,
                    lastDay: lastDay,
                    amount: amount,
                    purpose: purpose,
                    wf_id: wf_id,
                    status: status,
                    exp_id: exp_id,
                    fap_wf: fap_wf,
                    wbs: wbs,
                    expCat: expCat
                }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response.d == 0) {
                        RFPPopup.Hide();
                        LoadingPanel.Hide();
                        Swal.fire({
                            title: 'Error!',
                            text: 'There is an error saving document!',
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
                        RFPPopup.Hide();
                        LoadingPanel.Hide();
                        Swal.fire({
                            title: 'Success!',
                            text: 'RFP successfully saved!',
                            icon: 'success',
                            showCancelButton: false,
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'OK',
                            allowOutsideClick: false
                        }).then((result) => {
                            if (result.isConfirmed) {
                                window.location.href = "RFPPage.aspx";
                            }
                        });
                        
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }

        function onPayToVendorTranType() {
            if (TranType_modal.GetValue() != 3) {
                $.ajax({
                    type: "POST",
                    url: "RFPCreationPage.aspx/PayeeDefaultValueAJAX",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({}),
                    success: function (response) {
                        // Update the description text box with the response value
                        if (response) {
                            Payee_modal.SetValue(response.d);
                            Payee_modal.SetReadOnly(true);
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log("Error:", error);
                    }
                });
            } else {
                Payee_modal.SetValue("");
                Payee_modal.SetReadOnly(false);
            }
        }

        function ifTranType_is_CA() {
            var layoutControl = window["formRFP"];
            if (layoutControl) {
                var layoutItem = layoutControl.GetItemByName("PLD");
                if (layoutItem) {

                    if (drpdown_TranType.GetValue() == "1") {
                        layoutItem.SetVisible(true);
                    } else {
                        layoutItem.SetVisible(false);
                    }


                }
            }
        }

        function onAmountChanged(s, e) {
            var amount = Amount_modal.GetValue();
            var comp_id = Company_modal.GetValue();

            $.ajax({
                type: "POST",
                url: "RFPPage.aspx/CheckMinAmountAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ comp_id: comp_id }),
                success: function (response) {
                    // Update the Paymethod value
                    if (response.d != 0 && amount >= response.d) {
                        PayMethod_modal.SetValue(3);
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });

            FAPWFGrid.PerformCallback(amount + "|" + comp_id);
            FAPWF_modal.PerformCallback(amount + "|" + comp_id);

        }

        function onPayMethodChanged(pay) {
            Amount_modal.Clear();
        }

        function onDeptChanged() {
            var dept_id = Department_modal.GetValue();
            $.ajax({
                type: "POST",
                url: "RFPCreationPage.aspx/CostCenterUpdateField",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ dept_id: dept_id }),
                success: function (response) {
                    // Update the description text box with the response value
                    if (response) {
                        if (response.d != "") {
                            CostCenter_modal.SetValue(response.d);
                        }
                        
                        CostCenter_modal.Validate();
                    } else {
                        if (CostCenter_modal.GetText == "") {
                            CostCenter_modal.SetValue("");
                        }
                        
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }
    </script>
<div class="centerPane conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="90%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="Cashier Inquiry Page" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:TabbedLayoutGroup ColSpan="1">
                        <Items>
                            <dx:LayoutGroup Caption="For Disbursement" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="SqlRFP" EnableTheming="True" KeyFieldName="ID" OnCustomButtonInitialize="gridMain_CustomButtonInitialize" OnCustomCallback="gridMain_CustomCallback" OnHtmlDataCellPrepared="gridMain_HtmlDataCellPrepared" Theme="iOS" Width="95%">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                    <SettingsContextMenu Enabled="True">
                                                    </SettingsContextMenu>
                                                    <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCells">
                                                    </SettingsAdaptivity>
                                                    <SettingsCustomizationDialog Enabled="True" />
                                                    <SettingsPager AlwaysShowPager="True">
                                                        <PageSizeItemSettings Visible="True">
                                                        </PageSizeItemSettings>
                                                    </SettingsPager>
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                                    <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                                    </SettingsExport>
                                                    <SettingsLoadingPanel Mode="Disabled" />
                                                    <EditFormLayoutProperties>
                                                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
                                                    </EditFormLayoutProperties>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="Open">
                                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint" Text="Print" Visibility="Invisible">
                                                                    <Image IconID="dashboards_print_svg_white_16x16" ToolTip="Print Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#E67C03" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Center" VerticalAlign="Middle">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="TranTypeName" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="3" Caption="Payment Method" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Document No." FieldName="DocNo" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Creator" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="SourceTable" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                    <Template>
                                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                                            <Buttons>
                                                                                <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                </dx:SpinButtonExtended>
                                                                            </Buttons>
                                                                        </dx:ASPxButtonEdit>
                                                                    </Template>
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                        </dx:GridViewToolbar>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Selection" Visible="False">
                                                                    <Items>
                                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAll" Text="Select All">
                                                                            <ScrollUpButtonImage IconID="snap_highlight_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Name="dataUnselectAll" Text="Unselect All">
                                                                            <ScrollUpButtonImage IconID="pdfviewer_selectall_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAllOnPage" Text="Select all on the page">
                                                                            <ScrollUpButtonImage IconID="richedit_selecttable_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Name="dataUnselectAllOnPage" Text="Unselect all on the page">
                                                                            <ScrollUpButtonImage IconID="richedit_selecttablecolumn_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                    </Items>
                                                                    <ScrollUpButtonImage IconID="spreadsheet_selectdatamember_svg_16x16">
                                                                    </ScrollUpButtonImage>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Export">
                                                                    <Items>
                                                                        <dx:GridViewToolbarItem Command="ExportToXlsx">
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Command="ExportToPdf">
                                                                        </dx:GridViewToolbarItem>
                                                                    </Items>
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                        </dx:GridViewToolbar>
                                                    </Toolbars>
                                                    <Styles>
                                                        <Header Wrap="True">
                                                        </Header>
                                                        <Row Wrap="True">
                                                        </Row>
                                                        <Cell Wrap="False">
                                                        </Cell>
                                                        <SearchPanel HorizontalAlign="Right">
                                                        </SearchPanel>
                                                    </Styles>
                                                    <Border BorderWidth="0px" />
                                                    <BorderBottom BorderWidth="1px" />
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Disbursed" ColSpan="1">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="gridMainDisbursed" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMainDisbursed" DataSourceID="SqlRFPDisbursed" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMainDisbursed_CustomCallback" OnHtmlDataCellPrepared="gridMainDisbursed_HtmlDataCellPrepared" Theme="iOS" Width="95%">
                                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                                    <SettingsContextMenu Enabled="True">
                                                    </SettingsContextMenu>
                                                    <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCells">
                                                    </SettingsAdaptivity>
                                                    <SettingsCustomizationDialog Enabled="True" />
                                                    <SettingsPager AlwaysShowPager="True">
                                                        <PageSizeItemSettings Visible="True">
                                                        </PageSizeItemSettings>
                                                    </SettingsPager>
                                                    <Settings GridLines="Horizontal" ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                    <SettingsBehavior EnableCustomizationWindow="True" />
                                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                                    <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                                    </SettingsExport>
                                                    <SettingsLoadingPanel Mode="Disabled" />
                                                    <EditFormLayoutProperties>
                                                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
                                                    </EditFormLayoutProperties>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="Action" ShowInCustomizationForm="True" VisibleIndex="0">
                                                            <CustomButtons>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnViewDisbursed" Text="Open">
                                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#0D6943" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                                <dx:GridViewCommandColumnCustomButton ID="btnPrint0" Text="Print" Visibility="Invisible">
                                                                    <Image IconID="dashboards_print_svg_white_16x16" ToolTip="Print Document">
                                                                    </Image>
                                                                    <Styles>
                                                                        <Style BackColor="#E67C03" Font-Bold="True" Font-Size="Smaller" ForeColor="White">
                                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                                        </Style>
                                                                    </Styles>
                                                                </dx:GridViewCommandColumnCustomButton>
                                                            </CustomButtons>
                                                            <CellStyle HorizontalAlign="Center" VerticalAlign="Middle">
                                                            </CellStyle>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Purpose" FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesTextEdit DisplayFormatString="M/dd/yyyy">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="RFPTranType_Name" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" Caption="Company" FieldName="CompanyShortName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="3" Caption="Payment Method" FieldName="PMethod_name" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Document No." FieldName="RFP_DocNum" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit>
                                                                <Style Font-Bold="True">
                                                                </Style>
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="True">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Creator" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn AdaptivePriority="1" FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <Toolbars>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                    <Template>
                                                                        <dx:ASPxButtonEdit ID="tbToolbarSearch0" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                                            <Buttons>
                                                                                <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                </dx:SpinButtonExtended>
                                                                            </Buttons>
                                                                        </dx:ASPxButtonEdit>
                                                                    </Template>
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                        </dx:GridViewToolbar>
                                                        <dx:GridViewToolbar>
                                                            <Items>
                                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New" Visible="False">
                                                                    <Image IconID="iconbuilder_actions_addcircled_svg_dark_16x16">
                                                                    </Image>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Selection" Visible="False">
                                                                    <Items>
                                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAll" Text="Select All">
                                                                            <ScrollUpButtonImage IconID="snap_highlight_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Name="dataUnselectAll" Text="Unselect All">
                                                                            <ScrollUpButtonImage IconID="pdfviewer_selectall_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem BeginGroup="True" Name="dataSelectAllOnPage" Text="Select all on the page">
                                                                            <ScrollUpButtonImage IconID="richedit_selecttable_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Name="dataUnselectAllOnPage" Text="Unselect all on the page">
                                                                            <ScrollUpButtonImage IconID="richedit_selecttablecolumn_svg_16x16">
                                                                            </ScrollUpButtonImage>
                                                                        </dx:GridViewToolbarItem>
                                                                    </Items>
                                                                    <ScrollUpButtonImage IconID="spreadsheet_selectdatamember_svg_16x16">
                                                                    </ScrollUpButtonImage>
                                                                </dx:GridViewToolbarItem>
                                                                <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Text="Export">
                                                                    <Items>
                                                                        <dx:GridViewToolbarItem Command="ExportToXlsx">
                                                                        </dx:GridViewToolbarItem>
                                                                        <dx:GridViewToolbarItem Command="ExportToPdf">
                                                                        </dx:GridViewToolbarItem>
                                                                    </Items>
                                                                </dx:GridViewToolbarItem>
                                                            </Items>
                                                        </dx:GridViewToolbar>
                                                    </Toolbars>
                                                    <Styles>
                                                        <Header Wrap="True">
                                                        </Header>
                                                        <Row Wrap="True">
                                                        </Row>
                                                        <Cell Wrap="False">
                                                        </Cell>
                                                        <SearchPanel HorizontalAlign="Right">
                                                        </SearchPanel>
                                                    </Styles>
                                                    <Border BorderWidth="0px" />
                                                    <BorderBottom BorderWidth="1px" />
                                                </dx:ASPxGridView>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:TabbedLayoutGroup>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
</div>
    <asp:SqlDataSource ID="SqlRFP" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_InquiryCashP2P_2] WHERE (([Status] = @Status) AND ([RoleUserId] = @RoleUserId) AND ([Role_Name] = @Role_Name)) ORDER BY [DateCreated] DESC">
        <SelectParameters>
            <asp:Parameter Name="Status" Type="Int32" />
            <asp:Parameter Name="RoleUserId" Type="String" />
            <asp:Parameter Name="Role_Name" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPDisbursed" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_CashierDisbursedView] WHERE (([ActedBy_User_Id] = @ActedBy_User_Id) AND ([STS_Name] = @STS_Name)) ORDER BY [DateAction] DESC">
        <SelectParameters>
            <asp:Parameter Name="ActedBy_User_Id" Type="String" />
            <asp:Parameter Name="STS_Name" Type="String" />
        </SelectParameters>
     </asp:SqlDataSource>
</asp:Content>
