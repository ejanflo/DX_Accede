<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="RFPInquiry.aspx.cs" Inherits="DX_WebTemplate.RFPInquiry" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <%-- DXCOMMENT: Configure ASPxGridView's columns in accordance with datasource fields --%>
    <style>
    .centerPane {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
</style>
    <script>
        function OnCustomButtonClick(s, e) {
            gridMain.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            displayRFPDetails(s.GetRowKey(e.visibleIndex));
            LoadingPanel.Show();
        }

        function displayRFPDetails(RFP_ID) {
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

                    Company_modal.SetValue(response.d.company);
                    Department_modal.SetValue(response.d.department);
                    TranType_modal.SetValue(response.d.TranType);
                    CostCenter_modal.SetText(response.d.CostCenter);
                    PayMethod_modal.SetValue(response.d.Payment);
                    IO_modal.SetText(response.d.IO);
                    Payee_modal.SetText(response.d.Payee);
                    Travel_modal.SetValue(response.d.isTrav);
                    Amount_modal.SetValue(response.d.amount);
                    Purpose_modal.SetText(response.d.purpose);
                    drpdown_WF_modal.SetValue(response.d.workflow);

                    company_lbl_modal.SetText(Company_modal.GetText());
                    Department_lbl_modal.SetText(Department_modal.GetText());
                    TranType_lbl_modal.SetText(TranType_modal.GetText());
                    CostCenter_lbl_modal.SetText(CostCenter_modal.GetText());
                    PayMethod_lbl_modal.SetText(PayMethod_modal.GetText());
                    IO_lbl_modal.SetText(IO_modal.GetText());
                    Payee_lbl_modal.SetText(response.d.Payee);
                    Amount_lbl_modal.SetText(Amount_modal.GetText());
                    Purpose_lbl_modal.SetText(Purpose_modal.GetText());
                    drpdown_WF_lbl_modal.SetText(drpdown_WF_modal.GetText());
                    LastDay_lbl_modal.SetText(lastDateText);

                    WFSequenceGrid.PerformCallback();

                    
                    
                    if (response.d.Status == "Saved") {
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
                    }

                    LoadingPanel.Hide();
                    RFPPopup.Show();
                    
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
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
                    status: status
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

        function onAmountChanged(s, e) {
            var amount = Amount_modal.GetValue();
            if (amount > 2000) {
                PayMethod_modal.SetValue(3);
            }
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
                        CostCenter_modal.SetValue(response.d);
                        CostCenter_modal.Validate();
                    } else {
                        CostCenter_modal.SetValue("");
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
            <dx:LayoutGroup Caption="Request For Payment (Inquiry)" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="SqlRFP" EnableTheming="True" KeyFieldName="ID" OnCustomCallback="gridMain_CustomCallback" Theme="iOS" Width="95%">
                                    <ClientSideEvents CustomButtonClick="OnCustomButtonClick" ToolbarItemClick="OnToolbarItemClick" />
                                    <SettingsDetail ShowDetailRow="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsLoadingPanel ShowImage="false" Text="" />
                                    <SettingsAdaptivity AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" HideDataCellsAtWindowInnerWidth="900" AdaptiveDetailColumnCount="2" AllowOnlyOneAdaptiveDetailExpanded="True">
                                    </SettingsAdaptivity>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="Workflow Activity">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="ASPxGridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlWFActivity" Font-Size="Smaller" KeyFieldName="ID" OnBeforePerformDataSelect="ASPxGridView2_BeforePerformDataSelect1" OnHtmlDataCellPrepared="ASPxGridView2_HtmlDataCellPrepared">
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewDataTextColumn FieldName="DateAssigned" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="DateAction" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                            <PropertiesComboBox DataSourceID="SqlWorkflow" TextField="Description" ValueField="WF_Id">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Org Role" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            <PropertiesComboBox DataSourceID="SqlOrg" TextField="Description" ValueField="Id">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Approved by" FieldName="ActedBy_User_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                            <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                            <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                </TabPages>
                                            </dx:ASPxPageControl>
                                        </DetailRow>
                                    </Templates>
                                    <SettingsPager PageSize="32">
                                        <FirstPageButton Visible="True">
                                        </FirstPageButton>
                                        <LastPageButton Visible="True">
                                        </LastPageButton>
                                        <PageSizeItemSettings Visible="True">
                                        </PageSizeItemSettings>
                                    </SettingsPager>
                                    <SettingsEditing Mode="EditForm">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                    <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                    <SettingsExport EnableClientSideExportAPI="True" ExcelExportMode="WYSIWYG" FileName="MyData">
                                    </SettingsExport>
                                    <EditFormLayoutProperties>
                                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
                                    </EditFormLayoutProperties>
                                    <Columns>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="90px" Visible="False">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="6" AdaptivePriority="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="1" Caption="Action">
                                            <CustomButtons>

                                                <dx:GridViewCommandColumnCustomButton ID="btnView" Text="Open">
                                                    <Image IconID="actions_open_svg_white_16x16" ToolTip="Open Document">
                                                    </Image>
                                                    <Styles>
                                                        <Style Font-Bold="True" BackColor="#0D6943" CssClass="commandButton" Font-Size="Smaller" ForeColor="White">
                                                            <Paddings PaddingBottom="4px" PaddingLeft="8px" PaddingRight="8px" PaddingTop="4px" />
                                                        </Style>
                                                    </Styles>
                                                </dx:GridViewCommandColumnCustomButton>

                                            </CustomButtons>
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataComboBoxColumn AdaptivePriority="1" Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="4">
                                            <PropertiesComboBox DataSourceID="SqlComp" TextField="CompanyShortName" ValueField="WASSId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Creator" FieldName="User_ID" ShowInCustomizationForm="True" VisibleIndex="5">
                                            <PropertiesComboBox DataSourceID="SqlUser" TextField="FullName" ValueField="EmpCode">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn AdaptivePriority="2" Caption="Transaction Type" FieldName="TranType" ShowInCustomizationForm="True" VisibleIndex="8">
                                            <PropertiesComboBox DataSourceID="SqlTranType" TextField="RFPTranType_Name" ValueField="ID">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="9">
                                            <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn AdaptivePriority="3" FieldName="PayMethod" ShowInCustomizationForm="True" VisibleIndex="7">
                                            <PropertiesComboBox DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataTextColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Doc No." FieldName="RFP_DocNum" ShowInCustomizationForm="True" VisibleIndex="3">
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
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="Refresh" Alignment="Right">
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Text="Selection" Alignment="Right" Visible="False">
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
                                    <Paddings Padding="0px" />
                                    <Border BorderWidth="0px" />
                                    <BorderBottom BorderWidth="1px" />
                                </dx:ASPxGridView>
                                <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" EnableTheming="True" Theme="MaterialCompact" Visible="False">
                                    <ClientSideEvents ActionItemClick="OnActionItemClick" Init="OnInit" />
                                    <Items>
                                        <dx:FABActionGroup ContextName="ActionContext">
                                            <Items>
                                                <dx:FABActionItem ActionName="Cancel" Text="Cancel">
                                                    <Image IconID="scheduling_delete_svg_dark_16x16">
                                                    </Image>
                                                </dx:FABActionItem>
                                                <dx:FABActionItem ActionName="NewPage" Text="New">
                                                    <Image IconID="iconbuilder_actions_add_svg_dark_16x16" Url="~/Page_Templates/FormLayout_View.aspx">
                                                    </Image>
                                                </dx:FABActionItem>
                                            </Items>
                                            <ExpandImage IconID="iconbuilder_actions_arrow3up_svg_white_16x16">
                                            </ExpandImage>
                                        </dx:FABActionGroup>
                                    </Items>
                                </dx:ASPxFloatingActionButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>

    <dx:ASPxPopupControl ID="RFPPopup" runat="server" HeaderText="RFP DETAILS" ClientInstanceName="RFPPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" MinWidth="500px"><ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="RFPMainViewForm" runat="server" ClientInstanceName="RFPMainViewForm" Width="500px">
        <Items>
            <dx:LayoutGroup ColSpan="1" Name="RFPMainViewForm" Width="100%">
                <GroupBoxStyle>
                    <Caption Font-Size="Medium">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ClientVisible="False" ColSpan="1" GroupBoxDecoration="None" HorizontalAlign="Right" Name="btnLayoutGroup" ColCount="3" ColumnCount="3">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" Name="editBTN" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEditSubmit" runat="server" ClientInstanceName="btnEditSubmit" Text="Submit" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPEditForm')) SubmitPopup.Show();
}
" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEditSave" runat="server" Text="Save" ClientInstanceName="btnEditSave" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	SavePopup.Show();
}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" Name="Company_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="Company_modal" runat="server" ClientInstanceName="Company_modal" DataSourceID="SqlCompanyEdit" TextField="CompanyShortName" ValueField="CompanyId">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	Department_modal.PerformCallback(s.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                            <ReadOnlyStyle>
                                                <BorderLeft BorderStyle="None" />
                                                <BorderTop BorderStyle="None" />
                                                <BorderRight BorderStyle="None" />
                                            </ReadOnlyStyle>
                                        </dx:ASPxComboBox>
                                        <dx:ASPxTextBox ID="company_lbl_modal" runat="server" ClientInstanceName="company_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Department" ColSpan="1" Name="Department_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="Department_modal" runat="server" ClientInstanceName="Department_modal" DataSourceID="SqlDepartmentEdit" TextField="DepDesc" ValueField="ID" OnCallback="Department_modal_Callback">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onDeptChanged();
}" Init="function(s, e) {
	Department_modal.PerformCallback();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                        <dx:ASPxTextBox ID="Department_lbl_modal" runat="server" ClientInstanceName="Department_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payment Method" ColSpan="1" Name="PayMethod_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="PayMethod_modal" runat="server" ClientInstanceName="PayMethod_modal" DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onPayMethodChanged();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                        <dx:ASPxTextBox ID="PayMethod_lbl_modal" runat="server" ClientInstanceName="PayMethod_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Cost Center" ColSpan="1" Name="CostCenter_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="CostCenter_modal" runat="server" ClientInstanceName="CostCenter_modal">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                        <dx:ASPxTextBox ID="CostCenter_lbl_modal" runat="server" ClientInstanceName="CostCenter_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Transaction Type" ColSpan="1" Name="TranType_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="TranType_modal" runat="server" ClientInstanceName="TranType_modal" DataSourceID="SqlTranType" TextField="RFPTranType_Name" ValueField="ID">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onPayToVendorTranType();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                        <dx:ASPxTextBox ID="TranType_lbl_modal" runat="server" ClientInstanceName="TranType_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="IO" ColSpan="1" Name="IO_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="IO_modal" runat="server" ClientInstanceName="IO_modal">
                                        </dx:ASPxTextBox>
                                        <dx:ASPxTextBox ID="IO_lbl_modal" runat="server" ClientInstanceName="IO_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="is Travel?" ColSpan="1" Name="Travel_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxCheckBox ID="Travel_modal" runat="server" CheckState="Unchecked" ClientInstanceName="Travel_modal">
                                            <ClientSideEvents ValueChanged="function(s, e) {
	OnTravChanged();
}" />
                                        </dx:ASPxCheckBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" Name="Payee_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="Payee_modal" runat="server" ClientInstanceName="Payee_modal">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                        <dx:ASPxTextBox ID="Payee_lbl_modal" runat="server" ClientInstanceName="Payee_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Last Day of Transaction" ColSpan="1" Name="LastDay_modal">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="LastDay_modal" runat="server" ClientInstanceName="LastDay_modal">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                        <dx:ASPxTextBox ID="LastDay_lbl_modal" runat="server" ClientInstanceName="LastDay_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Note: Payment to vendors or non-employee transactions should be reflected at gross amount" ColSpan="1">
                        <GroupBoxStyle>
                            <Caption Font-Italic="True" Font-Size="Smaller">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem ColSpan="1" Caption="Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="Amount_modal" runat="server" ClientInstanceName="Amount_modal" Width="50%" DisplayFormatString="#,##0.00">
                                            <ClientSideEvents ValueChanged="function(s, e) {
	onAmountChanged();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                        <dx:ASPxTextBox ID="Amount_lbl_modal" runat="server" ClientInstanceName="Amount_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" Caption="Purpose">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="Purpose_modal" runat="server" ClientInstanceName="Purpose_modal" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                        <dx:ASPxTextBox ID="Purpose_lbl_modal" runat="server" ClientInstanceName="Purpose_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                            <BorderLeft BorderStyle="None" />
                                            <BorderTop BorderStyle="None" />
                                            <BorderRight BorderStyle="None" />
                                            <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" ColCount="2" ColumnCount="2">
                                <Items>
                                    <dx:LayoutGroup Caption="Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="50%">
                                <GroupBoxStyle>
                                    <Caption Font-Bold="True">
                                    </Caption>
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="Workflow" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_WF_modal" runat="server" TextField="WorkflowHeader_Name" ValueField="WF_Id" ClientInstanceName="drpdown_WF_modal" DataSourceID="SqlWF" Width="250px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnWFChanged();
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                </dx:ASPxComboBox>
                                                <dx:ASPxTextBox ID="drpdown_WF_lbl_modal" runat="server" ClientInstanceName="drpdown_WF_lbl_modal" HorizontalAlign="Left" ReadOnly="True" Width="170px">
                                                    <BorderLeft BorderStyle="None" />
                                                    <BorderTop BorderStyle="None" />
                                                    <BorderRight BorderStyle="None" />
                                                    <BorderBottom BorderStyle="Solid" BorderWidth="1px" />
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutGroup Caption="Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="50%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" Width="350px" ClientInstanceName="WFSequenceGrid" OnCustomCallback="WFSequenceGrid_CustomCallback" DataSourceID="SqlWorkflowSequence">
                                                    <SettingsEditing Mode="Batch">
                                                    </SettingsEditing>
                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                    <SettingsPopup>
                                                        <FilterControl AutoUpdatePosition="False">
                                                        </FilterControl>
                                                    </SettingsPopup>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Sequence" ShowInCustomizationForm="True" VisibleIndex="1" FieldName="Sequence">
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
        </Items>
    </dx:ASPxFormLayout>
        </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>
    <dx:ASPxPopupControl ID="SubmitPopup" runat="server" HeaderText="Submit RFP?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server">
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
InserttoRFPMain(&quot;1&quot;);
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

        <dx:ASPxPopupControl ID="SavePopup" runat="server" HeaderText="Save RFP?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SavePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server">
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
                        <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Are you sure you want to save?" Font-Size="Medium">
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
                                <dx:ASPxButton ID="btnSaveFinal" runat="server" Text="Save" ClientInstanceName="btnSaveFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {

if (!ASPxClientEdit.ValidateGroup('RFPEditForm')) { 
SavePopup.Hide();
}else{
InserttoRFPMain(&quot;13&quot;);
SavePopup.Hide();

}	
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
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
    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server"></dx:ASPxLoadingPanel>
</div>
    <asp:SqlDataSource ID="SqlRFP" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPInquiry] WHERE (([UserId] = @UserId) AND ([Status] &lt;&gt; @Status))">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter DefaultValue="13" Name="Status" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWFActivity" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_T_WorkflowActivity] WHERE (([AppId] = @AppId) AND ([Document_Id] = @Document_Id))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:SessionParameter Name="Document_Id" SessionField="MainRFP_ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlOrg" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityOrgRoles]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlComp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_RFPTranType]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlRFPMainView" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserWFAccess] WHERE ([UserId] = @UserId)">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflowSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
     <asp:SqlDataSource ID="SqlDepartmentEdit" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId) AND ([CompanyId] = @CompanyId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
            <asp:SessionParameter Name="CompanyId" SessionField="CompID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompanyEdit" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserComp] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
