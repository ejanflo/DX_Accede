<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityUserAccess.aspx.cs" Inherits="DX_WebTemplate.Security.SecurityUserAccess" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        function OnDetailRowExpanding(s, e) {
            gridSecurityUser.SetFocusedRowIndex(0);
        }
        function OnGridFocusedRowChanged() {
            gridUserApp.GetRowValues(gridUserApp.GetFocusedRowIndex(), 'SecurityApp_Id;UserApp_Id', OnGetRowValues);
        }
        function OnGetRowValues(value) {
            //alert(value[0]);
            //spinSelectedApp.SetText(values[0]);
            gridUserAppCompany.PerformCallback(value[0] + "|");
            //gridUserAppCompany.Refresh();
        }

        //var updateEditorsOnEndCallback = false;
        function OnListBoxValueChanged() {
            //gridUserAppRole.Refresh();
            gridUserAppCompany.Refresh();
            gridUserApp.Refresh();
            //alert('Refresh')
            //updateEditorsOnEndCallback = true;
            gridSecurityUser.Refresh();
            //gridSecurityUser.SetFocusedRowIndex(0);
            gridUserOrgRole.Refresh();
            gridITPUserMaster.Refresh();

        }


        function OnGridFocusedRowChangedCompany() {
            gridUserAppCompany.GetRowValues(gridUserAppCompany.GetFocusedRowIndex(), 'CompanyId;AppId', OnGetRowValuesCompany);
        }
        function OnGetRowValuesCompany(value) {
            //alert(value[0]);
            gridUserAppRole.PerformCallback(value[0] + "|");
        }


        function OnAddUserClick(s, e) {
            gridSecurityUser.AddNewRow();
        }

        function OnEditUserClick(s, e) {
            gridSecurityUser.SetFocusedRowIndex(0);
            gridSecurityUser.StartEditRow(gridSecurityUser.GetFocusedRowIndex());
        }

        function OnGridEndCallback(s, e) {
            listBoxUser.Refresh();
        }

    </script>
    <style>
        /* Style the footer container */
.footer-content {
    background-color: #333; /* Set your desired background color */
    color: #fff; /* Set your desired text color */
    padding: 20px; /* Add padding for spacing */
    text-align: center; /* Center the content */
    position: sticky;
    /*height: 300px;*/
    bottom: 0;
}
.customHeader {  
    height: 4px;  
}  
    </style>
    
    <dx:ASPxPanel ID="panelTop" runat="server" Width="100%">
    <PanelCollection>
        <dx:PanelContent runat="server">
            &nbsp;
            <dx:ASPxLabel ID="ASPxLabel1" runat="server" Font-Bold="True" Font-Size="X-Large" Text="  User Access Setup" Wrap="False">
            </dx:ASPxLabel>
            <br />
            <br />
            <dx:ASPxButton ID="btnAddUser" runat="server" HorizontalAlign="Right" Text="Add User Access" ClientInstanceName="btnAddUser" AutoPostBack="False">
                <ClientSideEvents Click="OnAddUserClick" />
            </dx:ASPxButton>
            <dx:ASPxButton ID="btnEditUser" runat="server" HorizontalAlign="Right" Text="Edit User" ClientInstanceName="btnEditUser" AutoPostBack="False" Visible="False">
                <ClientSideEvents Click="OnEditUserClick" />
            </dx:ASPxButton>
            <dx:ASPxButton ID="ASPxButton1" runat="server" Text="Refresh User Access List">
            </dx:ASPxButton>
        </dx:PanelContent>
    </PanelCollection>
    </dx:ASPxPanel>
        
            <br />

    <dx:ASPxSplitter ID="mainSplitter" runat="server" Height="100%" ClientInstanceName="mainSplitter">
        <Panes>
            <dx:SplitterPane MaxSize="320px" Name="userPane">
                <ContentCollection>
                    <dx:SplitterContentControl runat="server">
                        <dx:ASPxListBox ID="listBoxUser" ClientInstanceName="listBoxUser" runat="server" DataSourceID="sqlUser" Height="100%" SelectedIndex="0" TextField="FullName" ValueField="EmpCode" Width="100%">
                            <Columns>
                                <dx:ListBoxColumn Caption="Name" FieldName="FullName">
                                </dx:ListBoxColumn>
                                <dx:ListBoxColumn Caption="Emp. ID" FieldName="EmpCode" Width="50px" Visible="False">
                                </dx:ListBoxColumn>
                                <dx:ListBoxColumn Caption="Username" FieldName="UserName" Width="50px" Visible="False">
                                </dx:ListBoxColumn>
                                <dx:ListBoxColumn Caption="Company" FieldName="CompanyName" Visible="False">
                                </dx:ListBoxColumn>
                                <dx:ListBoxColumn FieldName="IsActive" Width="30px" Caption="Active" Visible="False">
                                </dx:ListBoxColumn>
                            </Columns>
                            <FilteringSettings ShowSearchUI="True" />
                            <ClientSideEvents ValueChanged="OnListBoxValueChanged" />
                        </dx:ASPxListBox>
                    </dx:SplitterContentControl>
                </ContentCollection>
            </dx:SplitterPane>
<dx:SplitterPane Name="appPane">
<ContentCollection>
<dx:SplitterContentControl runat="server">
                    <dx:ASPxPageControl ID="ASPxPageControl2" runat="server" ActiveTabIndex="0" Height="100%" Width="100%">
                        <TabPages>
                            <dx:TabPage Text="Access">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxSplitter ID="ASPxSplitter2" runat="server" Height="100%" Width="100%">
                                            <Panes>
                                                <dx:SplitterPane>
                                                    <ContentCollection>
                                                        <dx:SplitterContentControl runat="server">
                                                            <dx:ASPxGridView ID="gridUserApp" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridUserApp" DataSourceID="sqlUserApp" KeyFieldName="UserApp_Id" OnDataBound="gridUserApp_DataBound" OnRowInserting="gridUserApp_RowInserting" Width="100%">
                                                                <ClientSideEvents FocusedRowChanged="OnGridFocusedRowChanged" />
                                                                <SettingsEditing Mode="Batch">
                                                                </SettingsEditing>
                                                                <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="400" VerticalScrollBarMode="Visible" />
                                                                <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" />
                                                                <SettingsPopup>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsSearchPanel Visible="True" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="100px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="UserApp_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Username" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="8" Width="120px">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="App" FieldName="SecurityApp_Id" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                        <PropertiesComboBox DataSourceID="sqlApp" TextField="App_Name" TextFormatString="{0}" ValueField="App_Id">
                                                                            <Columns>
                                                                                <dx:ListBoxColumn Caption="App" FieldName="App_Name" Width="200px">
                                                                                </dx:ListBoxColumn>
                                                                                <dx:ListBoxColumn Caption="Description" FieldName="App_Description" Width="400px">
                                                                                </dx:ListBoxColumn>
                                                                            </Columns>
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                </Columns>
                                                                <Toolbars>
                                                                    <dx:GridViewToolbar>
                                                                        <Items>
                                                                            <dx:GridViewToolbarItem Command="Refresh">
                                                                            </dx:GridViewToolbarItem>
                                                                        </Items>
                                                                    </dx:GridViewToolbar>
                                                                </Toolbars>
                                                            </dx:ASPxGridView>
                                                        </dx:SplitterContentControl>
                                                    </ContentCollection>
                                                </dx:SplitterPane>
                                                <dx:SplitterPane>
                                                    <ContentCollection>
                                                        <dx:SplitterContentControl runat="server">
                                                            <dx:ASPxGridView ID="gridUserAppCompany" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridUserAppCompany" DataSourceID="sqlUserCompany" KeyFieldName="UserCompany_Id" OnBeforePerformDataSelect="gridUserAppCompany_BeforePerformDataSelect" OnCustomCallback="gridUserAppCompany_CustomCallback" OnDataBound="gridUserAppCompany_DataBound" OnRowInserted="gridUserAppCompany_RowInserted" OnRowInserting="gridUserAppCompany_RowInserting" Width="100%">
                                                                <ClientSideEvents FocusedRowChanged="OnGridFocusedRowChangedCompany" />
                                                                <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                                                <Templates>
                                                                    <DetailRow>
                                                                        <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                                            <TabPages>
                                                                                <dx:TabPage Text="Role Access">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="gridUserAppRole" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridUserAppRole" DataSourceID="sqlUserRole" KeyFieldName="UserAppRoles_Id" OnBeforePerformDataSelect="gridUserAppRole_BeforePerformDataSelect" OnRowInserting="gridUserAppRole_RowInserting">
                                                                                                <SettingsEditing Mode="Batch">
                                                                                                </SettingsEditing>
                                                                                                <SettingsResizing ColumnResizeMode="NextColumn" />
                                                                                                <SettingsPopup>
                                                                                                    <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter">
                                                                                                    </EditForm>
                                                                                                    <CustomizationWindow HorizontalAlign="WindowCenter" />
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="110px">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="UserAppRoles_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                        <EditFormSettings Visible="False" />
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="SecurityApp_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="CompanyId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="CR" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="RD" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="UPD" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="DEL" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Role" FieldName="SecurityRole_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                        <PropertiesComboBox DataSourceID="sqlRolesFiltered" TextFormatString="{0}" ValueField="Role_Id">
                                                                                                            <Columns>
                                                                                                                <dx:ListBoxColumn Caption="Role" FieldName="Role_Name" Width="200px">
                                                                                                                </dx:ListBoxColumn>
                                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="Description" Width="550px">
                                                                                                                </dx:ListBoxColumn>
                                                                                                            </Columns>
                                                                                                        </PropertiesComboBox>
                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </dx:ContentControl>
                                                                                    </ContentCollection>
                                                                                </dx:TabPage>
                                                                                <dx:TabPage Text="Department Access">
                                                                                    <ContentCollection>
                                                                                        <dx:ContentControl runat="server">
                                                                                            <dx:ASPxGridView ID="gridUserDept" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserDept" KeyFieldName="UserDeptID" OnBeforePerformDataSelect="gridUserDept_BeforePerformDataSelect" OnRowInserting="gridUserDept_RowInserting">
                                                                                                <SettingsEditing Mode="Batch">
                                                                                                </SettingsEditing>
                                                                                                <SettingsPopup>
                                                                                                    <FilterControl AutoUpdatePosition="False">
                                                                                                    </FilterControl>
                                                                                                </SettingsPopup>
                                                                                                <Columns>
                                                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="UserDeptID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                        <EditFormSettings Visible="False" />
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="CompanyId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="IsDelete" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataCheckColumn FieldName="IsDefault" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                                                    </dx:GridViewDataCheckColumn>
                                                                                                    <dx:GridViewDataComboBoxColumn FieldName="DepCode" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                        <PropertiesComboBox DataSourceID="sqlDept" TextFormatString="{1}" ValueField="DepCode">
                                                                                                            <Columns>
                                                                                                                <dx:ListBoxColumn Caption="Dept Code" FieldName="DepCode">
                                                                                                                </dx:ListBoxColumn>
                                                                                                                <dx:ListBoxColumn Caption="Description" FieldName="DepDesc" Width="350px">
                                                                                                                </dx:ListBoxColumn>
                                                                                                                <dx:ListBoxColumn Caption="Division Code" FieldName="Div_Code">
                                                                                                                </dx:ListBoxColumn>
                                                                                                                <dx:ListBoxColumn Caption="Cost Center" FieldName="SAP_CostCenter">
                                                                                                                </dx:ListBoxColumn>
                                                                                                            </Columns>
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
                                                                <SettingsEditing Mode="Batch">
                                                                </SettingsEditing>
                                                                <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="450" VerticalScrollBarMode="Visible" />
                                                                <SettingsBehavior AllowSelectSingleRowOnly="True" />
                                                                <SettingsPopup>
                                                                    <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter">
                                                                    </EditForm>
                                                                    <FilterControl AutoUpdatePosition="False">
                                                                    </FilterControl>
                                                                </SettingsPopup>
                                                                <SettingsSearchPanel Visible="True" />
                                                                <Columns>
                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="110px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="UserCompany_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                        <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyDesc" ValueField="WASSId">
                                                                        </PropertiesComboBox>
                                                                    </dx:GridViewDataComboBoxColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsDefault" ShowInCustomizationForm="True" VisibleIndex="5" Width="120px">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="6" Width="100px">
                                                                    </dx:GridViewDataCheckColumn>
                                                                </Columns>
                                                                <Toolbars>
                                                                    <dx:GridViewToolbar>
                                                                        <Items>
                                                                            <dx:GridViewToolbarItem Command="Refresh">
                                                                            </dx:GridViewToolbarItem>
                                                                        </Items>
                                                                    </dx:GridViewToolbar>
                                                                </Toolbars>
                                                            </dx:ASPxGridView>
                                                        </dx:SplitterContentControl>
                                                    </ContentCollection>
                                                </dx:SplitterPane>
                                            </Panes>
                                        </dx:ASPxSplitter>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="User Org Role">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxGridView ID="gridUserOrgRole" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserOrgRole" KeyFieldName="Id" OnRowInserting="gridUserOrgRole_RowInserting" Width="100%" ClientInstanceName="gridUserOrgRole">
                                            <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                            <Templates>
                                                <DetailRow>
                                                    <dx:ASPxPageControl ID="ASPxPageControl3" runat="server" ActiveTabIndex="0" Height="100%" Width="100%">
                                                        <TabPages>
                                                            <dx:TabPage Text="Org. Role Users">
                                                                <ContentCollection>
                                                                    <dx:ContentControl runat="server">
                                                                        <dx:ASPxGridView ID="gridOrgRoleUsers" runat="server" AutoGenerateColumns="False" DataSourceID="sqlOrgRoleUsers" KeyFieldName="Id" OnBeforePerformDataSelect="gridOrgRoleUsers_BeforePerformDataSelect" OnRowInserting="gridOrgRoleUsers_RowInserting" Width="100%">
                                                                            <SettingsEditing Mode="Batch">
                                                                            </SettingsEditing>
                                                                            <SettingsPopup>
                                                                                <FilterControl AutoUpdatePosition="False">
                                                                                </FilterControl>
                                                                            </SettingsPopup>
                                                                            <Columns>
                                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                    <EditFormSettings Visible="False" />
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataTextColumn FieldName="OrgRoleId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                                                </dx:GridViewDataTextColumn>
                                                                                <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                </dx:GridViewDataCheckColumn>
                                                                                <dx:GridViewDataComboBoxColumn Caption="User" FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                    <PropertiesComboBox DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode">
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
                                            <SettingsEditing Mode="Batch">
                                            </SettingsEditing>
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <SettingsSearchPanel Visible="True" />
                                            <Columns>
                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataCheckColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Org. Role" FieldName="OrgRoleId" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="sqlOrgRole" TextField="Role_Name" ValueField="Id">
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                            <Toolbars>
                                                <dx:GridViewToolbar>
                                                    <Items>
                                                        <dx:GridViewToolbarItem Command="Refresh">
                                                        </dx:GridViewToolbarItem>
                                                    </Items>
                                                </dx:GridViewToolbar>
                                            </Toolbars>
                                        </dx:ASPxGridView>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="User Info">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxGridView ID="gridITPUserMaster" runat="server" AutoGenerateColumns="False" DataSourceID="sqlITPUserMaster" KeyFieldName="ITP_U_Master_ID" ClientInstanceName="gridITPUserMaster">
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsCustomizationDialog Enabled="True" />
                                            <SettingsBehavior EnableCustomizationWindow="True" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="ITP_U_Master_ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="EmpCode" ShowInCustomizationForm="True" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="LName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="MName" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="CompanyID" ShowInCustomizationForm="True" VisibleIndex="8" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="CompanyName" ShowInCustomizationForm="True" VisibleIndex="9" Caption="Company">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="DivDesc" ShowInCustomizationForm="True" VisibleIndex="11">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="DepDesc" ShowInCustomizationForm="True" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="SecDesc" ShowInCustomizationForm="True" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="DesDesc" ShowInCustomizationForm="True" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Email" ShowInCustomizationForm="True" VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="LocalNo" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="MobileNo" ShowInCustomizationForm="True" VisibleIndex="15" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="JobLevel" ShowInCustomizationForm="True" VisibleIndex="16" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="17">
                                                </dx:GridViewDataCheckColumn>
                                                <dx:GridViewDataTextColumn FieldName="UserName" ShowInCustomizationForm="True" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="isSouth" ShowInCustomizationForm="True" VisibleIndex="18" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                    </dx:SplitterContentControl>
</ContentCollection>
</dx:SplitterPane>
        </Panes>
    </dx:ASPxSplitter>
    <asp:SqlDataSource ID="sqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT FullName, IsActive, EmpCode FROM vw_ITP_I_SecurityUser WHERE (IsActive = 1) ORDER BY FullName"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlSecurityUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUser] WHERE [Id] = @original_Id" InsertCommand="INSERT INTO [ITP_S_SecurityUser] ([UserId], [UserApp_DateCreated], [UserApp_DateModified], [UserApp_CreatedBy], [UserApp_ModifiedBy], [IsActive], [IsDelete]) VALUES (@UserId, @UserApp_DateCreated, @UserApp_DateModified, @UserApp_CreatedBy, @UserApp_ModifiedBy, @IsActive, @IsDelete)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityUser] WHERE ([UserId] = @UserId)" UpdateCommand="UPDATE [ITP_S_SecurityUser] SET [UserId] = @UserId, [UserApp_DateCreated] = @UserApp_DateCreated, [UserApp_DateModified] = @UserApp_DateModified, [UserApp_CreatedBy] = @UserApp_CreatedBy, [UserApp_ModifiedBy] = @UserApp_ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete WHERE [Id] = @original_Id">
        <DeleteParameters>
            <asp:Parameter Name="original_Id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="mainSplitter$listBoxUser" Name="UserId" PropertyName="Value" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="original_Id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlITPUserMaster" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [ITP_U_Master_ID], [EmpCode], [LName], [FName], [MName], [FullName], [CompanyID], [CompanyName], [DivDesc], [DepDesc], [SecDesc], [DesDesc], [Email], [LocalNo], [MobileNo], [JobLevel], [IsActive], [UserName], [isSouth] FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
        <SelectParameters>
            <asp:ControlParameter ControlID="mainSplitter$listBoxUser" Name="EmpCode" PropertyName="Value" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUserOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserOrgRoles] WHERE [Id] = @Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserOrgRoles] ([UserId], [OrgRoleId], [IsActive]) VALUES (@UserId, @OrgRoleId, @IsActive)" SelectCommand="SELECT [Id], [UserId], [OrgRoleId], [IsActive] FROM [ITP_S_SecurityUserOrgRoles] WHERE ([UserId] = @UserId)" UpdateCommand="UPDATE [ITP_S_SecurityUserOrgRoles] SET [UserId] = @UserId, [OrgRoleId] = @OrgRoleId, [IsActive] = @IsActive WHERE [Id] = @Id">
        <DeleteParameters>
            <asp:Parameter Name="Id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="OrgRoleId" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="mainSplitter$listBoxUser" Name="UserId" PropertyName="Value" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="OrgRoleId" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="Id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlOrgRoleUsers" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserOrgRoles] WHERE [Id] = @Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserOrgRoles] ([UserId], [OrgRoleId], [IsActive]) VALUES (@UserId, @OrgRoleId, @IsActive)" SelectCommand="SELECT [Id], [UserId], [OrgRoleId], [IsActive] FROM [ITP_S_SecurityUserOrgRoles] WHERE ([OrgRoleId] = @OrgRoleId)" UpdateCommand="UPDATE [ITP_S_SecurityUserOrgRoles] SET [UserId] = @UserId, [OrgRoleId] = @OrgRoleId, [IsActive] = @IsActive WHERE [Id] = @Id">
        <DeleteParameters>
            <asp:Parameter Name="Id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="OrgRoleId" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="OrgRoleId" SessionField="MasterOrgRoleID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="OrgRoleId" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="Id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [Id], [Role_Name], [Description] FROM [ITP_S_SecurityOrgRoles]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUserMaster" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [EmpCode], [FullName] FROM [ITP_S_UserMaster] ORDER BY [FullName]">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUsers" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [Employee_Id], [FullName], [UserName] FROM [UserMaster] WHERE ([Employee_Id] &gt; @Employee_Id)">
        <SelectParameters>
            <asp:Parameter DefaultValue="0" Name="Employee_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUserCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompany] WHERE [UserCompany_Id] = @original_UserCompany_Id" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompany] ([UserId], [CompanyId], [UserCompany_DateCreated], [UserCompany_DateModified], [UserCompany_CreatedBy], [UserCompany_ModifiedBy], [AppId], [IsDelete], [IsActive], [IsDefault]) VALUES (@UserId, @CompanyId, @UserCompany_DateCreated, @UserCompany_DateModified, @UserCompany_CreatedBy, @UserCompany_ModifiedBy, @AppId, @IsDelete, @IsActive, @IsDefault)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompany] WHERE (([AppId] = @AppId) AND ([UserId] = @UserId))" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompany] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [UserCompany_DateCreated] = @UserCompany_DateCreated, [UserCompany_DateModified] = @UserCompany_DateModified, [UserCompany_CreatedBy] = @UserCompany_CreatedBy, [UserCompany_ModifiedBy] = @UserCompany_ModifiedBy, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive, [IsDefault] = @IsDefault WHERE [UserCompany_Id] = @original_UserCompany_Id">
        <DeleteParameters>
            <asp:Parameter Name="original_UserCompany_Id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="AppId" Type="Int32" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDefault" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="AppId" SessionField="MasterAppID_UAC" Type="Int32" />
            <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserCompany_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserCompany_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserCompany_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserCompany_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="AppId" Type="Int32" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDefault" Type="Boolean" />
            <asp:Parameter Name="original_UserCompany_Id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUserRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserAppRoles] WHERE [UserAppRoles_Id] = @original_UserAppRoles_Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserAppRoles] ([SecurityRole_Id], [SecurityApp_Id], [Username], [UserId], [UserAppRoles_DateCreated], [UserAppRoles_DateModifed], [UserAppRoles_CreatedBy], [UserAppRoles_ModifiedBy], [IsActive], [IsDelete], [CompanyId], [CR], [RD], [UPD], [DEL]) VALUES (@SecurityRole_Id, @SecurityApp_Id, @Username, @UserId, @UserAppRoles_DateCreated, @UserAppRoles_DateModifed, @UserAppRoles_CreatedBy, @UserAppRoles_ModifiedBy, @IsActive, @IsDelete, @CompanyId, @CR, @RD, @UPD, @DEL)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityUserAppRoles] WHERE (([CompanyId] = @CompanyId) AND ([UserId] = @UserId) AND ([SecurityApp_Id] = @SecurityApp_Id))" UpdateCommand="UPDATE [ITP_S_SecurityUserAppRoles] SET [SecurityRole_Id] = @SecurityRole_Id, [SecurityApp_Id] = @SecurityApp_Id, [Username] = @Username, [UserId] = @UserId, [UserAppRoles_DateCreated] = @UserAppRoles_DateCreated, [UserAppRoles_DateModifed] = @UserAppRoles_DateModifed, [UserAppRoles_CreatedBy] = @UserAppRoles_CreatedBy, [UserAppRoles_ModifiedBy] = @UserAppRoles_ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [CompanyId] = @CompanyId, [CR] = @CR, [RD] = @RD, [UPD] = @UPD, [DEL] = @DEL WHERE [UserAppRoles_Id] = @original_UserAppRoles_Id">
        <DeleteParameters>
            <asp:Parameter Name="original_UserAppRoles_Id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="SecurityRole_Id" Type="Int32" />
            <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="Username" Type="String" />
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="UserAppRoles_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserAppRoles_DateModifed" Type="DateTime" />
            <asp:Parameter Name="UserAppRoles_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserAppRoles_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="CR" Type="Boolean" />
            <asp:Parameter Name="RD" Type="Boolean" />
            <asp:Parameter Name="UPD" Type="Boolean" />
            <asp:Parameter Name="DEL" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="CompanyId" SessionField="MasterCompanyID" Type="Int32" />
            <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
            <asp:SessionParameter Name="SecurityApp_Id" SessionField="MasterAppID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="SecurityRole_Id" Type="Int32" />
            <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="Username" Type="String" />
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="UserAppRoles_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserAppRoles_DateModifed" Type="DateTime" />
            <asp:Parameter Name="UserAppRoles_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserAppRoles_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="CR" Type="Boolean" />
            <asp:Parameter Name="RD" Type="Boolean" />
            <asp:Parameter Name="UPD" Type="Boolean" />
            <asp:Parameter Name="DEL" Type="Boolean" />
            <asp:Parameter Name="original_UserAppRoles_Id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlUserApp" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserApp] WHERE [UserApp_Id] = @original_UserApp_Id AND (([Username] = @original_Username) OR ([Username] IS NULL AND @original_Username IS NULL)) AND (([UserApp_DateCreated] = @original_UserApp_DateCreated) OR ([UserApp_DateCreated] IS NULL AND @original_UserApp_DateCreated IS NULL)) AND (([UserApp_DateModified] = @original_UserApp_DateModified) OR ([UserApp_DateModified] IS NULL AND @original_UserApp_DateModified IS NULL)) AND (([UserApp_CreatedBy] = @original_UserApp_CreatedBy) OR ([UserApp_CreatedBy] IS NULL AND @original_UserApp_CreatedBy IS NULL)) AND (([UserApp_ModifiedBy] = @original_UserApp_ModifiedBy) OR ([UserApp_ModifiedBy] IS NULL AND @original_UserApp_ModifiedBy IS NULL)) AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([SecurityApp_Id] = @original_SecurityApp_Id) OR ([SecurityApp_Id] IS NULL AND @original_SecurityApp_Id IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([WASPUserId] = @original_WASPUserId) OR ([WASPUserId] IS NULL AND @original_WASPUserId IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityUserApp] ([Username], [UserApp_DateCreated], [UserApp_DateModified], [UserApp_CreatedBy], [UserApp_ModifiedBy], [UserId], [SecurityApp_Id], [IsActive], [IsDelete], [WASPUserId]) VALUES (@Username, @UserApp_DateCreated, @UserApp_DateModified, @UserApp_CreatedBy, @UserApp_ModifiedBy, @UserId, @SecurityApp_Id, @IsActive, @IsDelete, @WASPUserId)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityUserApp] WHERE ([UserId] = @UserId2)" UpdateCommand="UPDATE [ITP_S_SecurityUserApp] SET [Username] = @Username, [UserApp_DateCreated] = @UserApp_DateCreated, [UserApp_DateModified] = @UserApp_DateModified, [UserApp_CreatedBy] = @UserApp_CreatedBy, [UserApp_ModifiedBy] = @UserApp_ModifiedBy, [UserId] = @UserId, [SecurityApp_Id] = @SecurityApp_Id, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [WASPUserId] = @WASPUserId WHERE [UserApp_Id] = @original_UserApp_Id AND (([Username] = @original_Username) OR ([Username] IS NULL AND @original_Username IS NULL)) AND (([UserApp_DateCreated] = @original_UserApp_DateCreated) OR ([UserApp_DateCreated] IS NULL AND @original_UserApp_DateCreated IS NULL)) AND (([UserApp_DateModified] = @original_UserApp_DateModified) OR ([UserApp_DateModified] IS NULL AND @original_UserApp_DateModified IS NULL)) AND (([UserApp_CreatedBy] = @original_UserApp_CreatedBy) OR ([UserApp_CreatedBy] IS NULL AND @original_UserApp_CreatedBy IS NULL)) AND (([UserApp_ModifiedBy] = @original_UserApp_ModifiedBy) OR ([UserApp_ModifiedBy] IS NULL AND @original_UserApp_ModifiedBy IS NULL)) AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([SecurityApp_Id] = @original_SecurityApp_Id) OR ([SecurityApp_Id] IS NULL AND @original_SecurityApp_Id IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([WASPUserId] = @original_WASPUserId) OR ([WASPUserId] IS NULL AND @original_WASPUserId IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_UserApp_Id" Type="Int32" />
            <asp:Parameter Name="original_Username" Type="String" />
            <asp:Parameter Name="original_UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="original_UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="original_UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="original_UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="original_UserId" Type="String" />
            <asp:Parameter Name="original_SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="original_IsActive" Type="Boolean" />
            <asp:Parameter Name="original_IsDelete" Type="Boolean" />
            <asp:Parameter Name="original_WASPUserId" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Username" Type="String" />
            <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="WASPUserId" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="mainSplitter$listBoxUser" Name="UserId2" PropertyName="Value" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="Username" Type="String" />
            <asp:Parameter Name="UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="IsDelete" Type="Boolean" />
            <asp:Parameter Name="WASPUserId" Type="Int32" />
            <asp:Parameter Name="original_UserApp_Id" Type="Int32" />
            <asp:Parameter Name="original_Username" Type="String" />
            <asp:Parameter Name="original_UserApp_DateCreated" Type="DateTime" />
            <asp:Parameter Name="original_UserApp_DateModified" Type="DateTime" />
            <asp:Parameter Name="original_UserApp_CreatedBy" Type="Int32" />
            <asp:Parameter Name="original_UserApp_ModifiedBy" Type="Int32" />
            <asp:Parameter Name="original_UserId" Type="String" />
            <asp:Parameter Name="original_SecurityApp_Id" Type="Int32" />
            <asp:Parameter Name="original_IsActive" Type="Boolean" />
            <asp:Parameter Name="original_IsDelete" Type="Boolean" />
            <asp:Parameter Name="original_WASPUserId" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>

                                <asp:SqlDataSource runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityApp]" ID="sqlApp"></asp:SqlDataSource>

                                <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [WASSId] FROM [CompanyMaster]"></asp:SqlDataSource>

                                <asp:SqlDataSource ID="sqlRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityRoles]">
    </asp:SqlDataSource>

                                <asp:SqlDataSource ID="sqlRolesFiltered" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityRoles] WHERE ([AppId] = @AppId) ORDER BY [Role_Name]">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="AppId" SessionField="MasterAppID" Type="Int32" />
                                    </SelectParameters>
    </asp:SqlDataSource>

                                <asp:SqlDataSource runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompanyDept] WHERE [UserDeptID] = @original_UserDeptID" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompanyDept] ([UserId], [CompanyId], [DepCode], [AppId], [IsDelete], [IsActive], [IsDefault]) VALUES (@UserId, @CompanyId, @DepCode, @AppId, @IsDelete, @IsActive, @IsDefault)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompanyDept] WHERE (([AppId] = @AppId) AND ([CompanyId] = @CompanyId) AND ([UserId] = @UserId))" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompanyDept] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [DepCode] = @DepCode, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive, [IsDefault] = @IsDefault WHERE [UserDeptID] = @original_UserDeptID" ID="sqlUserDept"><DeleteParameters>
<asp:Parameter Name="original_UserDeptID" Type="Int32"></asp:Parameter>
</DeleteParameters>
<InsertParameters>
<asp:Parameter Name="UserId" Type="String"></asp:Parameter>
<asp:Parameter Name="CompanyId" Type="Int32"></asp:Parameter>
<asp:Parameter Name="DepCode" Type="String"></asp:Parameter>
<asp:Parameter Name="AppId" Type="Int32"></asp:Parameter>
<asp:Parameter Name="IsDelete" Type="Boolean"></asp:Parameter>
<asp:Parameter Name="IsActive" Type="Boolean"></asp:Parameter>
<asp:Parameter Name="IsDefault" Type="Boolean"></asp:Parameter>
</InsertParameters>
<SelectParameters>
<asp:SessionParameter SessionField="MasterAppID" Name="AppId" Type="Int32"></asp:SessionParameter>
<asp:SessionParameter SessionField="MasterCompanyID" Name="CompanyId" Type="Int32"></asp:SessionParameter>
<asp:SessionParameter SessionField="MasterUserID" Name="UserId" Type="String"></asp:SessionParameter>
</SelectParameters>
<UpdateParameters>
<asp:Parameter Name="UserId" Type="String"></asp:Parameter>
<asp:Parameter Name="CompanyId" Type="Int32"></asp:Parameter>
<asp:Parameter Name="DepCode" Type="String"></asp:Parameter>
<asp:Parameter Name="AppId" Type="Int32"></asp:Parameter>
<asp:Parameter Name="IsDelete" Type="Boolean"></asp:Parameter>
<asp:Parameter Name="IsActive" Type="Boolean"></asp:Parameter>
<asp:Parameter Name="IsDefault" Type="Boolean"></asp:Parameter>
<asp:Parameter Name="original_UserDeptID" Type="Int32"></asp:Parameter>
</UpdateParameters>
</asp:SqlDataSource>

                                <asp:SqlDataSource runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)" ID="sqlDept"><SelectParameters>
<asp:Parameter Name="Company_ID" Type="Int32"></asp:Parameter>
</SelectParameters>
</asp:SqlDataSource>

    

                    <dx:ASPxGridView runat="server" AutoGenerateColumns="False" KeyFieldName="Id" ClientInstanceName="gridSecurityUser" DataSourceID="sqlSecurityUser" ID="gridSecurityUser" OnDataBound="gridSecurityUser_DataBound" OnRowUpdated="gridSecurityUser_RowUpdated" OnRowInserting="gridSecurityUser_RowInserting" Width="5px" OnHtmlRowCreated="gridSecurityUser_HtmlRowCreated">

                    <Styles>  
<Table Font-Size="XX-Small"></Table>

                        <Header CssClass="customHeader"></Header>  
                    </Styles>  
<ClientSideEvents DetailRowExpanding="OnDetailRowExpanding" DetailRowCollapsing="OnDetailRowExpanding" ColumnResized="OnGridEndCallback"></ClientSideEvents>

                        <SettingsAdaptivity AdaptivityMode="HideDataCells" AllowHideDataCellsByColumnMinWidth="True" AllowOnlyOneAdaptiveDetailExpanded="True" HideDataCellsAtWindowInnerWidth="1">
                        </SettingsAdaptivity>

<SettingsEditing Mode="PopupEditForm"></SettingsEditing>

                        <Settings ShowColumnHeaders="False" />

<SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" AllowSelectSingleRowOnly="True"></SettingsBehavior>

<SettingsPopup>
<EditForm HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" AllowResize="True" Modal="True"></EditForm>

<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>
                        <SettingsText PopupEditFormCaption="User Access" />
<Columns>
<dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Caption=" "></dx:GridViewCommandColumn>
<dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Visible="False">
<EditFormSettings Visible="False"></EditFormSettings>
</dx:GridViewDataTextColumn>
<dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False"></dx:GridViewDataCheckColumn>
    <dx:GridViewDataComboBoxColumn Caption=" " FieldName="UserId" MaxWidth="5" VisibleIndex="5">
        <PropertiesComboBox DataSourceID="sqlUserMaster" TextField="FullName" ValueField="EmpCode">
        </PropertiesComboBox>
        <CellStyle Wrap="False">
        </CellStyle>
    </dx:GridViewDataComboBoxColumn>
</Columns>
                        <Styles>
                            <Table Font-Size="XX-Small">
                            </Table>
                            <Header Font-Size="XX-Small">
                            </Header>
                        </Styles>
</dx:ASPxGridView>

                <%--<div class="footer-content">
                    &copy; 2023 Your Website Name
                </div>--%>

</asp:Content>
