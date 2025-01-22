<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="UserDelegationPage.aspx.cs" Inherits="DX_WebTemplate.UserDelegationPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        function OnToolbarItemClick(s, e) {
            switch (e.item.name) {
                
                case 'New':
                    
                    InsertPopup.Show();
                    break;
            }
        }

        function InsertDelegate() {
            LoadingPanel.SetText("Processing&hellip;");
            LoadingPanel.Show();
            var comp_id = drpdown_Comp.GetValue();
            var user_id_for = drpdown_user_for.GetValue();
            var user_id_to = drpdown_user_to.GetValue();
            var dateFrom = date_From.GetValue();
            var dateTo = date_To.GetValue();
            var is_active = chkbx_isActive.GetValue();
            //var remarks = memo_remarks.GetValue();

            $.ajax({
                type: "POST",
                url: "UserDelegationPage.aspx/InsertDelegationAJAX",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    comp_id: comp_id,
                    user_id_for: user_id_for,
                    user_id_to: user_id_to,
                    dateFrom: dateFrom,
                    dateTo: dateTo,
                    is_active: is_active
                    //remarks: remarks
                }),
                success: function (response) {
                    // Update the Paymethod value
                    //window.location.href = "UserDelegationPage.aspx";
                    InsertPopup.Hide();
                    LoadingPanel.Hide();
                    gridMain.Refresh();
                },
                error: function (xhr, status, error) {
                    console.log("Error:", error);
                }
            });
        }
    </script>
    <div class="centerPane conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="100%" Theme="iOS">
        <Items>
            <dx:LayoutGroup Caption="User Delegation Page" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:EmptyLayoutItem ColSpan="1">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridMain" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridMain" DataSourceID="SqlMain" EnableTheming="True" KeyFieldName="ID" Theme="iOS" Width="100%">
                                    <ClientSideEvents ToolbarItemClick="OnToolbarItemClick" />
                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsLoadingPanel Mode="Disabled" />
                                    <SettingsAdaptivity AdaptivityMode="HideDataCells" AdaptiveDetailColumnCount="2">
                                    </SettingsAdaptivity>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <SettingsPager AlwaysShowPager="True">
                                        <PageSizeItemSettings Visible="True">
                                        </PageSizeItemSettings>
                                    </SettingsPager>
                                    <SettingsEditing Mode="Batch">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" GridLines="Horizontal" />
                                    <SettingsBehavior EnableCustomizationWindow="True" />
                                    <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                    <SettingsDataSecurity AllowDelete="False" AllowInsert="False" />
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
                                        <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="4" Caption="Date From" FieldName="DateFrom">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn ShowInCustomizationForm="True" VisibleIndex="5" Caption="Date To" FieldName="DateTo">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Delegated For" FieldName="DelegateFor_UserID" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataCheckColumn Caption="is Active" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="7">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Delegate To" FieldName="DelegateTo_UserID" ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesComboBox DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
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
                                                <dx:GridViewToolbarItem BeginGroup="True" Name="New" Text="New">
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
                                    <Border BorderWidth="0px" />
                                    <BorderBottom BorderWidth="1px" />
                                </dx:ASPxGridView>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
                <SettingsItems HorizontalAlign="Center" VerticalAlign="Top" />
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>

    <dx:ASPxPopupControl ID="InsertPopup" runat="server" HeaderText="ADD USER DELEGATION" ClientInstanceName="InsertPopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" MinWidth="600px"><ContentCollection>
<dx:PopupControlContentControl runat="server">
    <div id="scrollableContainer" >
        <dx:ASPxFormLayout ID="RFPMainViewForm" runat="server" ClientInstanceName="RFPMainViewForm">
            <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
            </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup ColSpan="1" GroupBoxDecoration="HeadingLine" Caption="">
                <GroupBoxStyle>
                    <Caption Font-Size="Medium">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_Comp" runat="server" ClientInstanceName="drpdown_Comp" TextField="CompanyShortName" ValueField="WASSId" Width="100%" DataSourceID="SqlCompany">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Delegate For" ColSpan="1" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_user_for" runat="server" ClientInstanceName="drpdown_user_for" DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Delegate To" ColSpan="1" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_user_to" runat="server" ClientInstanceName="drpdown_user_to" DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode" Width="100%">
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Date From" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_From" runat="server" ClientInstanceName="date_From" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Date To" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_To" runat="server" ClientInstanceName="date_To" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="is Active" ColSpan="1" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxCheckBox ID="chkbx_isActive" runat="server" CheckState="Unchecked" ClientInstanceName="chkbx_isActive">
                                        </dx:ASPxCheckBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" HorizontalAlign="Right" Name="btnLayoutGroup" ColCount="3" ColumnCount="3" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" Name="editBTN" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnAddInsert" runat="server" ClientInstanceName="btnAddInsert" Text="Add" AutoPostBack="False" HorizontalAlign="Right">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPEditForm')) InsertDelegate();
}
" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnAddCancel" runat="server" Text="Cancel" ClientInstanceName="btnAddCancel" AutoPostBack="False" BackColor="Gray" HorizontalAlign="Right">
                                            <ClientSideEvents Click="function(s, e) {
	InsertPopup.Hide();
}" />
                                            <Border BorderColor="Gray" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    </div>
        </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="UpdatePopup" runat="server" HeaderText="UPDATE USER DELEGATION" ClientInstanceName="UpdatePopup" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" MinWidth="600px"><ContentCollection>
<dx:PopupControlContentControl runat="server">
    <div id="scrollableContainer" >
        <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server" ClientInstanceName="RFPMainViewForm">
            <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit">
            </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup ColSpan="1" ColCount="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" Caption="">
                <GroupBoxStyle>
                    <Caption Font-Size="Medium">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="Company" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_Comp_update" runat="server" ClientInstanceName="drpdown_Comp_update" TextField="CompanyShortName" ValueField="CompanyId" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Delegate User" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_user_update" runat="server" ClientInstanceName="drpdown_user_update" DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Date From" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_From_update" runat="server" ClientInstanceName="date_From_update" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Date To" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="date_To_update" runat="server" ClientInstanceName="date_To_update" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="RFPEditForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="is Active" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxCheckBox ID="ASPxCheckBox1" runat="server" CheckState="Unchecked" ClientInstanceName="chkbx_isActive">
                                        </dx:ASPxCheckBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Name="btnLayoutGroup" ColCount="3" ColumnCount="3" ColumnSpan="2" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" Name="editBTN" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton1" runat="server" ClientInstanceName="btnAddInsert" Text="Add" AutoPostBack="False" HorizontalAlign="Right">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('RFPEditForm')) InsertDelegate();
}
" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" ClientInstanceName="btnAddCancel" AutoPostBack="False" BackColor="Gray" HorizontalAlign="Right">
                                            <ClientSideEvents Click="function(s, e) {
	InsertPopup.Hide();
}" />
                                            <Border BorderColor="Gray" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    </div>
        </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

    <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
</div>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_UserDelegation]" DeleteCommand="DELETE FROM [ACCEDE_S_UserDelegation] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ACCEDE_S_UserDelegation] ([DelegateFor_UserID], [DelegateTo_UserID], [DateFrom], [DateTo], [Company_ID], [Remarks], [isActive]) VALUES (@DelegateFor_UserID, @DelegateTo_UserID, @DateFrom, @DateTo, @Company_ID, @Remarks, @isActive)" UpdateCommand="UPDATE [ACCEDE_S_UserDelegation] SET [DelegateFor_UserID] = @DelegateFor_UserID, [DelegateTo_UserID] = @DelegateTo_UserID, [DateFrom] = @DateFrom, [DateTo] = @DateTo, [Company_ID] = @Company_ID, [Remarks] = @Remarks, [isActive] = @isActive WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="DelegateFor_UserID" Type="String" />
            <asp:Parameter Name="DelegateTo_UserID" Type="String" />
            <asp:Parameter Name="DateFrom" Type="DateTime" />
            <asp:Parameter Name="DateTo" Type="DateTime" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="Remarks" Type="String" />
            <asp:Parameter Name="isActive" Type="Boolean" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="DelegateFor_UserID" Type="String" />
            <asp:Parameter Name="DelegateTo_UserID" Type="String" />
            <asp:Parameter Name="DateFrom" Type="DateTime" />
            <asp:Parameter Name="DateTo" Type="DateTime" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="Remarks" Type="String" />
            <asp:Parameter Name="isActive" Type="Boolean" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster] ORDER BY [FullName]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [CompanyMaster] WHERE (([WASSId] IS NOT NULL) AND ([SAP_Id] IS NOT NULL)) ORDER BY [CompanyShortName]">
    </asp:SqlDataSource>
</asp:Content>
