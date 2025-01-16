<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityUser.aspx.cs" Inherits="DX_WebTemplate.Security.SecurityUser" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="User Access" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridUser" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUser" KeyFieldName="Id">
                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="App Access">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridUserApp" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserApp" KeyFieldName="UserApp_Id" OnBeforePerformDataSelect="gridUserApp_BeforePerformDataSelect" OnRowInserting="gridUserApp_RowInserting">
                                                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                                    <Templates>
                                                                        <DetailRow>
                                                                            <dx:ASPxPageControl ID="ASPxPageControl2" runat="server" ActiveTabIndex="0">
                                                                                <TabPages>
                                                                                    <dx:TabPage Text="Company Access">
                                                                                        <ContentCollection>
                                                                                            <dx:ContentControl runat="server">
                                                                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" ForeColor="Red" Text="Note: Please check one (1) Default Company only">
                                                                                                </dx:ASPxLabel>
                                                                                                <dx:ASPxGridView ID="gridUserCompany" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserCompany" KeyFieldName="UserCompany_Id" OnBeforePerformDataSelect="gridUserCompany_BeforePerformDataSelect" OnRowInserting="gridUserCompany_RowInserting">
                                                                                                    <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                                                                    <Templates>
                                                                                                        <DetailRow>
                                                                                                            <dx:ASPxPageControl ID="ASPxPageControl3" runat="server" ActiveTabIndex="1">
                                                                                                                <TabPages>
                                                                                                                    <dx:TabPage Text="User Company Roles">
                                                                                                                        <ContentCollection>
                                                                                                                            <dx:ContentControl runat="server">
                                                                                                                                <dx:ASPxGridView ID="gridUserRole" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserRole" KeyFieldName="UserAppRoles_Id" OnBeforePerformDataSelect="gridUserRole_BeforePerformDataSelect" OnRowInserting="gridUserRole_RowInserting">
                                                                                                                                    <SettingsEditing Mode="Batch">
                                                                                                                                    </SettingsEditing>
                                                                                                                                    <Settings ShowHeaderFilterButton="True" />
                                                                                                                                    <SettingsPopup>
                                                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                                                        </FilterControl>
                                                                                                                                    </SettingsPopup>
                                                                                                                                    <SettingsSearchPanel Visible="True" />
                                                                                                                                    <Columns>
                                                                                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                                                        </dx:GridViewCommandColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="UserAppRoles_Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Visible="False">
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="SecurityApp_Id" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                                                                                                                            <PropertiesTextEdit>
                                                                                                                                                <ValidationSettings ErrorText="Application not detected. Kindly try refreshing the page">
                                                                                                                                                </ValidationSettings>
                                                                                                                                            </PropertiesTextEdit>
                                                                                                                                            <EditFormSettings Visible="False" />
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="15" Visible="False">
                                                                                                                                            <PropertiesTextEdit>
                                                                                                                                                <ValidationSettings ErrorText="User not detected. Kindly try refreshing the page">
                                                                                                                                                </ValidationSettings>
                                                                                                                                            </PropertiesTextEdit>
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                                                        <dx:GridViewDataTextColumn FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="13" Visible="False">
                                                                                                                                            <PropertiesTextEdit>
                                                                                                                                                <ValidationSettings ErrorText="Company not detected. Kindly try refreshing the page">
                                                                                                                                                </ValidationSettings>
                                                                                                                                            </PropertiesTextEdit>
                                                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                                                        <dx:GridViewDataComboBoxColumn Caption="Role" FieldName="SecurityRole_Id" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                                                                            <PropertiesComboBox DataSourceID="sqlRoles" TextFormatString="{0}" ValueField="Role_Id">
                                                                                                                                                <Columns>
                                                                                                                                                    <dx:ListBoxColumn Caption="Role" FieldName="Role_Name">
                                                                                                                                                    </dx:ListBoxColumn>
                                                                                                                                                    <dx:ListBoxColumn FieldName="Description" Width="250px">
                                                                                                                                                    </dx:ListBoxColumn>
                                                                                                                                                </Columns>
                                                                                                                                                <ValidationSettings ErrorText="Role is required" SetFocusOnError="True">
                                                                                                                                                    <RequiredField ErrorText="Invalid value" IsRequired="True" />
                                                                                                                                                </ValidationSettings>
                                                                                                                                            </PropertiesComboBox>
                                                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                                                        <dx:GridViewBandColumn Caption="Data Access" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                                                                                            <HeaderStyle HorizontalAlign="Center" />
                                                                                                                                            <Columns>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Create" FieldName="CR" ShowInCustomizationForm="True" VisibleIndex="0">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Read" FieldName="RD" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Update" FieldName="UPD" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                                <dx:GridViewDataCheckColumn Caption="Delete" FieldName="DEL" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                                                </dx:GridViewDataCheckColumn>
                                                                                                                                            </Columns>
                                                                                                                                        </dx:GridViewBandColumn>
                                                                                                                                    </Columns>
                                                                                                                                </dx:ASPxGridView>
                                                                                                                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" />
                                                                                                                            </dx:ContentControl>
                                                                                                                        </ContentCollection>
                                                                                                                    </dx:TabPage>
                                                                                                                    <dx:TabPage Text="User Department Access">
                                                                                                                        <ContentCollection>
                                                                                                                            <dx:ContentControl runat="server">
                                                                                                                                <dx:ASPxGridView ID="gridUserDept" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserDept" KeyFieldName="UserDeptID" OnBeforePerformDataSelect="gridUserRole_BeforePerformDataSelect" OnRowInserting="gridUserDept_RowInserting">
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
                                                                                                    <Settings ShowHeaderFilterButton="True" />
                                                                                                    <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" />
                                                                                                    <SettingsPopup>
                                                                                                        <FilterControl AutoUpdatePosition="False">
                                                                                                        </FilterControl>
                                                                                                    </SettingsPopup>
                                                                                                    <SettingsSearchPanel Visible="True" />
                                                                                                    <Columns>
                                                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                                        </dx:GridViewCommandColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="UserCompany_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                            <EditFormSettings Visible="False" />
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataTextColumn FieldName="AppId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                                        </dx:GridViewDataTextColumn>
                                                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                                        </dx:GridViewDataCheckColumn>
                                                                                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="CompanyId" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                                            <PropertiesComboBox DataSourceID="sqlCompany" TextFormatString="{0}" ValueField="WASSId">
                                                                                                                <Columns>
                                                                                                                    <dx:ListBoxColumn Caption="Company" FieldName="CompanyShortName">
                                                                                                                    </dx:ListBoxColumn>
                                                                                                                    <dx:ListBoxColumn Caption=" " FieldName="CompanyDesc" Width="250px">
                                                                                                                    </dx:ListBoxColumn>
                                                                                                                </Columns>
                                                                                                            </PropertiesComboBox>
                                                                                                        </dx:GridViewDataComboBoxColumn>
                                                                                                        <dx:GridViewDataCheckColumn Caption="Default Company" FieldName="IsDefault" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                                        </dx:GridViewDataCheckColumn>
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
                                                                    <Settings ShowHeaderFilterButton="True" />
                                                                    <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" />
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <SettingsSearchPanel Visible="True" />
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="UserApp_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="UserId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Application" FieldName="SecurityApp_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                            <PropertiesComboBox DataSourceID="sqlApp" TextFormatString="{0}" ValueField="App_Id">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn FieldName="App_Name">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="App_Description" Width="250px">
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
                                    <SettingsPager>
                                        <FirstPageButton Visible="True">
                                        </FirstPageButton>
                                        <LastPageButton Visible="True">
                                        </LastPageButton>
                                        <PageSizeItemSettings Visible="True">
                                        </PageSizeItemSettings>
                                    </SettingsPager>
                                    <SettingsEditing Mode="Batch">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" />
                                    <SettingsBehavior EnableCustomizationWindow="True" />
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <SettingsSearchPanel Visible="True" CustomEditorID="tbToolbarSearch" />
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="User" FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlUserMaster" TextFormatString="{1} ({0}) - {2}" ValueField="EmpCode">
                                                <Columns>
                                                    <dx:ListBoxColumn FieldName="EmpCode">
                                                    </dx:ListBoxColumn>
                                                    <dx:ListBoxColumn FieldName="FullName">
                                                    </dx:ListBoxColumn>
                                                    <dx:ListBoxColumn FieldName="CompanyName" Width="250px">
                                                    </dx:ListBoxColumn>
                                                </Columns>
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
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="New" Text="New">
                                                    <Image IconID="actions_add_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="Refresh">
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlUserApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserApp] WHERE [UserApp_Id] = @UserApp_Id" InsertCommand="INSERT INTO [ITP_S_SecurityUserApp] ([UserId], [SecurityApp_Id], [IsActive]) VALUES (@UserId, @SecurityApp_Id, @IsActive)" SelectCommand="SELECT [UserApp_Id], [UserId], [SecurityApp_Id], [IsActive] FROM [ITP_S_SecurityUserApp] WHERE ([UserId] = @UserId)" UpdateCommand="UPDATE [ITP_S_SecurityUserApp] SET [UserId] = @UserId, [SecurityApp_Id] = @SecurityApp_Id, [IsActive] = @IsActive WHERE [UserApp_Id] = @UserApp_Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="UserApp_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="UserApp_Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityApp]"></asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUser] WHERE [Id] = @Id" InsertCommand="INSERT INTO [ITP_S_SecurityUser] ([UserId], [IsActive]) VALUES (@UserId, @IsActive)" SelectCommand="SELECT [Id], [UserId], [IsActive] FROM [ITP_S_SecurityUser]" UpdateCommand="UPDATE [ITP_S_SecurityUser] SET [UserId] = @UserId, [IsActive] = @IsActive WHERE [Id] = @Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserMaster" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserCompany" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompany] WHERE [UserCompany_Id] = @original_UserCompany_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([UserCompany_DateCreated] = @original_UserCompany_DateCreated) OR ([UserCompany_DateCreated] IS NULL AND @original_UserCompany_DateCreated IS NULL)) AND (([UserCompany_DateModified] = @original_UserCompany_DateModified) OR ([UserCompany_DateModified] IS NULL AND @original_UserCompany_DateModified IS NULL)) AND (([UserCompany_CreatedBy] = @original_UserCompany_CreatedBy) OR ([UserCompany_CreatedBy] IS NULL AND @original_UserCompany_CreatedBy IS NULL)) AND (([UserCompany_ModifiedBy] = @original_UserCompany_ModifiedBy) OR ([UserCompany_ModifiedBy] IS NULL AND @original_UserCompany_ModifiedBy IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompany] ([UserId], [CompanyId], [UserCompany_DateCreated], [UserCompany_DateModified], [UserCompany_CreatedBy], [UserCompany_ModifiedBy], [AppId], [IsDelete], [IsActive], [IsDefault]) VALUES (@UserId, @CompanyId, @UserCompany_DateCreated, @UserCompany_DateModified, @UserCompany_CreatedBy, @UserCompany_ModifiedBy, @AppId, @IsDelete, @IsActive, @IsDefault)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompany] WHERE (([UserId] = @UserId) AND ([AppId] = @AppId)) ORDER BY [IsDefault] DESC" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompany] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [UserCompany_DateCreated] = @UserCompany_DateCreated, [UserCompany_DateModified] = @UserCompany_DateModified, [UserCompany_CreatedBy] = @UserCompany_CreatedBy, [UserCompany_ModifiedBy] = @UserCompany_ModifiedBy, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive, [IsDefault] = @IsDefault WHERE [UserCompany_Id] = @original_UserCompany_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([UserCompany_DateCreated] = @original_UserCompany_DateCreated) OR ([UserCompany_DateCreated] IS NULL AND @original_UserCompany_DateCreated IS NULL)) AND (([UserCompany_DateModified] = @original_UserCompany_DateModified) OR ([UserCompany_DateModified] IS NULL AND @original_UserCompany_DateModified IS NULL)) AND (([UserCompany_CreatedBy] = @original_UserCompany_CreatedBy) OR ([UserCompany_CreatedBy] IS NULL AND @original_UserCompany_CreatedBy IS NULL)) AND (([UserCompany_ModifiedBy] = @original_UserCompany_ModifiedBy) OR ([UserCompany_ModifiedBy] IS NULL AND @original_UserCompany_ModifiedBy IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_UserCompany_Id" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
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
                                        <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
                                        <asp:SessionParameter Name="AppId" SessionField="MasterSecurityAppID" Type="Int32" />
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
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_UserCompany_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserCompany_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [IsActive], [WASSId] FROM [CompanyMaster] WHERE ([IsActive] = @IsActive) ORDER BY [CompanyShortName]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityRoles] WHERE ([AppId] = @AppId)">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="AppId" SessionField="MasterAppID" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserRole" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserAppRoles] WHERE [UserAppRoles_Id] = @original_UserAppRoles_Id AND (([SecurityRole_Id] = @original_SecurityRole_Id) OR ([SecurityRole_Id] IS NULL AND @original_SecurityRole_Id IS NULL)) AND (([SecurityApp_Id] = @original_SecurityApp_Id) OR ([SecurityApp_Id] IS NULL AND @original_SecurityApp_Id IS NULL)) AND (([Username] = @original_Username) OR ([Username] IS NULL AND @original_Username IS NULL)) AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([UserAppRoles_DateCreated] = @original_UserAppRoles_DateCreated) OR ([UserAppRoles_DateCreated] IS NULL AND @original_UserAppRoles_DateCreated IS NULL)) AND (([UserAppRoles_DateModifed] = @original_UserAppRoles_DateModifed) OR ([UserAppRoles_DateModifed] IS NULL AND @original_UserAppRoles_DateModifed IS NULL)) AND (([UserAppRoles_CreatedBy] = @original_UserAppRoles_CreatedBy) OR ([UserAppRoles_CreatedBy] IS NULL AND @original_UserAppRoles_CreatedBy IS NULL)) AND (([UserAppRoles_ModifiedBy] = @original_UserAppRoles_ModifiedBy) OR ([UserAppRoles_ModifiedBy] IS NULL AND @original_UserAppRoles_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([CR] = @original_CR) OR ([CR] IS NULL AND @original_CR IS NULL)) AND (([RD] = @original_RD) OR ([RD] IS NULL AND @original_RD IS NULL)) AND (([UPD] = @original_UPD) OR ([UPD] IS NULL AND @original_UPD IS NULL)) AND (([DEL] = @original_DEL) OR ([DEL] IS NULL AND @original_DEL IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityUserAppRoles] ([SecurityRole_Id], [SecurityApp_Id], [Username], [UserId], [UserAppRoles_DateCreated], [UserAppRoles_DateModifed], [UserAppRoles_CreatedBy], [UserAppRoles_ModifiedBy], [IsActive], [IsDelete], [CompanyId], [CR], [RD], [UPD], [DEL]) VALUES (@SecurityRole_Id, @SecurityApp_Id, @Username, @UserId, @UserAppRoles_DateCreated, @UserAppRoles_DateModifed, @UserAppRoles_CreatedBy, @UserAppRoles_ModifiedBy, @IsActive, @IsDelete, @CompanyId, @CR, @RD, @UPD, @DEL)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityUserAppRoles] WHERE (([CompanyId] = @CompanyId) AND ([UserId] = @UserId) AND ([SecurityApp_Id] = @SecurityApp_Id))" UpdateCommand="UPDATE [ITP_S_SecurityUserAppRoles] SET [SecurityRole_Id] = @SecurityRole_Id, [SecurityApp_Id] = @SecurityApp_Id, [Username] = @Username, [UserId] = @UserId, [UserAppRoles_DateCreated] = @UserAppRoles_DateCreated, [UserAppRoles_DateModifed] = @UserAppRoles_DateModifed, [UserAppRoles_CreatedBy] = @UserAppRoles_CreatedBy, [UserAppRoles_ModifiedBy] = @UserAppRoles_ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [CompanyId] = @CompanyId, [CR] = @CR, [RD] = @RD, [UPD] = @UPD, [DEL] = @DEL WHERE [UserAppRoles_Id] = @original_UserAppRoles_Id AND (([SecurityRole_Id] = @original_SecurityRole_Id) OR ([SecurityRole_Id] IS NULL AND @original_SecurityRole_Id IS NULL)) AND (([SecurityApp_Id] = @original_SecurityApp_Id) OR ([SecurityApp_Id] IS NULL AND @original_SecurityApp_Id IS NULL)) AND (([Username] = @original_Username) OR ([Username] IS NULL AND @original_Username IS NULL)) AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([UserAppRoles_DateCreated] = @original_UserAppRoles_DateCreated) OR ([UserAppRoles_DateCreated] IS NULL AND @original_UserAppRoles_DateCreated IS NULL)) AND (([UserAppRoles_DateModifed] = @original_UserAppRoles_DateModifed) OR ([UserAppRoles_DateModifed] IS NULL AND @original_UserAppRoles_DateModifed IS NULL)) AND (([UserAppRoles_CreatedBy] = @original_UserAppRoles_CreatedBy) OR ([UserAppRoles_CreatedBy] IS NULL AND @original_UserAppRoles_CreatedBy IS NULL)) AND (([UserAppRoles_ModifiedBy] = @original_UserAppRoles_ModifiedBy) OR ([UserAppRoles_ModifiedBy] IS NULL AND @original_UserAppRoles_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([CR] = @original_CR) OR ([CR] IS NULL AND @original_CR IS NULL)) AND (([RD] = @original_RD) OR ([RD] IS NULL AND @original_RD IS NULL)) AND (([UPD] = @original_UPD) OR ([UPD] IS NULL AND @original_UPD IS NULL)) AND (([DEL] = @original_DEL) OR ([DEL] IS NULL AND @original_DEL IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_UserAppRoles_Id" Type="Int32" />
                                        <asp:Parameter Name="original_SecurityRole_Id" Type="Int32" />
                                        <asp:Parameter Name="original_SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Username" Type="String" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_UserAppRoles_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserAppRoles_DateModifed" Type="DateTime" />
                                        <asp:Parameter Name="original_UserAppRoles_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserAppRoles_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_CR" Type="Boolean" />
                                        <asp:Parameter Name="original_RD" Type="Boolean" />
                                        <asp:Parameter Name="original_UPD" Type="Boolean" />
                                        <asp:Parameter Name="original_DEL" Type="Boolean" />
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
                                        <asp:Parameter Name="original_SecurityRole_Id" Type="Int32" />
                                        <asp:Parameter Name="original_SecurityApp_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Username" Type="String" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_UserAppRoles_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_UserAppRoles_DateModifed" Type="DateTime" />
                                        <asp:Parameter Name="original_UserAppRoles_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_UserAppRoles_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_CR" Type="Boolean" />
                                        <asp:Parameter Name="original_RD" Type="Boolean" />
                                        <asp:Parameter Name="original_UPD" Type="Boolean" />
                                        <asp:Parameter Name="original_DEL" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserDept" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityAppUserCompanyDept] WHERE [UserDeptID] = @original_UserDeptID AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityAppUserCompanyDept] ([UserId], [CompanyId], [DepCode], [AppId], [IsDelete], [IsActive], [IsDefault]) VALUES (@UserId, @CompanyId, @DepCode, @AppId, @IsDelete, @IsActive, @IsDefault)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityAppUserCompanyDept] WHERE ([CompanyId] = @CompanyId)" UpdateCommand="UPDATE [ITP_S_SecurityAppUserCompanyDept] SET [UserId] = @UserId, [CompanyId] = @CompanyId, [DepCode] = @DepCode, [AppId] = @AppId, [IsDelete] = @IsDelete, [IsActive] = @IsActive, [IsDefault] = @IsDefault WHERE [UserDeptID] = @original_UserDeptID AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([CompanyId] = @original_CompanyId) OR ([CompanyId] IS NULL AND @original_CompanyId IS NULL)) AND (([DepCode] = @original_DepCode) OR ([DepCode] IS NULL AND @original_DepCode IS NULL)) AND (([AppId] = @original_AppId) OR ([AppId] IS NULL AND @original_AppId IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDefault] = @original_IsDefault) OR ([IsDefault] IS NULL AND @original_IsDefault IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_UserDeptID" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDefault" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="CompanyId" SessionField="MasterCompanyID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="CompanyId" Type="Int32" />
                                        <asp:Parameter Name="DepCode" Type="String" />
                                        <asp:Parameter Name="AppId" Type="Int32" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDefault" Type="Boolean" />
                                        <asp:Parameter Name="original_UserDeptID" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_CompanyId" Type="Int32" />
                                        <asp:Parameter Name="original_DepCode" Type="String" />
                                        <asp:Parameter Name="original_AppId" Type="Int32" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDefault" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDept" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)">
                                    <SelectParameters>
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    </div>
</asp:Content>
