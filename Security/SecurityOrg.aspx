<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityOrg.aspx.cs" Inherits="DX_WebTemplate.Security.SecurityOrg" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Org Role" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridOrgRole" runat="server" AutoGenerateColumns="False" DataSourceID="sqlOrgRole" KeyFieldName="Id">
                                    <SettingsDetail ShowDetailRow="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="User">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridUserOrg" runat="server" AutoGenerateColumns="False" DataSourceID="sqlUserOrgRole" KeyFieldName="Id" OnBeforePerformDataSelect="gridUserOrg_BeforePerformDataSelect" OnRowInserted="gridUserOrg_RowInserted" OnRowInserting="gridUserOrg_RowInserting">
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
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
                                                                        <dx:GridViewDataCheckColumn FieldName="IsPrimary" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="User" FieldName="UserId" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                            <PropertiesComboBox DataSourceID="sqlUser" TextFormatString="{1} ({0}) -  {2}" ValueField="EmpCode">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn FieldName="EmpCode">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="FullName" Width="200px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="CompanyName" Width="250px">
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

<SettingsPopup>
<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>

                                    <SettingsSearchPanel Visible="True" CustomEditorID="tbToolbarSearch" />
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Org Role" FieldName="Role_Name" ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="4">
                                        </dx:GridViewDataCheckColumn>
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
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="New">
                                                    <Image IconID="actions_add_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True" Command="Refresh">
                                                    <Image IconID="actions_refresh_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlOrgRole" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityOrgRoles] WHERE [Id] = @Id" InsertCommand="INSERT INTO [ITP_S_SecurityOrgRoles] ([Role_Name], [IsActive], [Description]) VALUES (@Role_Name, @IsActive, @Description)" SelectCommand="SELECT [Id], [Role_Name], [IsActive], [Description] FROM [ITP_S_SecurityOrgRoles] ORDER BY [Id] DESC" UpdateCommand="UPDATE [ITP_S_SecurityOrgRoles] SET [Role_Name] = @Role_Name, [IsActive] = @IsActive, [Description] = @Description WHERE [Id] = @Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Role_Name" Type="String" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="Description" Type="String" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Role_Name" Type="String" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [EmpCode], [FullName], [CompanyName] FROM [ITP_S_UserMaster] WHERE ([IsActive] = @IsActive) ORDER BY [FullName]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlUserOrgRole" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityUserOrgRoles] WHERE [Id] = @original_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([OrgRoleId] = @original_OrgRoleId) OR ([OrgRoleId] IS NULL AND @original_OrgRoleId IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsPrimary] = @original_IsPrimary) OR ([IsPrimary] IS NULL AND @original_IsPrimary IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityUserOrgRoles] ([UserId], [OrgRoleId], [IsActive], [IsPrimary]) VALUES (@UserId, @OrgRoleId, @IsActive, @IsPrimary)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [Id], [UserId], [OrgRoleId], [IsActive], [IsPrimary] FROM [ITP_S_SecurityUserOrgRoles] WHERE ([OrgRoleId] = @OrgRoleId)" UpdateCommand="UPDATE [ITP_S_SecurityUserOrgRoles] SET [UserId] = @UserId, [OrgRoleId] = @OrgRoleId, [IsActive] = @IsActive, [IsPrimary] = @IsPrimary WHERE [Id] = @original_Id AND (([UserId] = @original_UserId) OR ([UserId] IS NULL AND @original_UserId IS NULL)) AND (([OrgRoleId] = @original_OrgRoleId) OR ([OrgRoleId] IS NULL AND @original_OrgRoleId IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsPrimary] = @original_IsPrimary) OR ([IsPrimary] IS NULL AND @original_IsPrimary IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_Id" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_OrgRoleId" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsPrimary" Type="Boolean" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="OrgRoleId" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsPrimary" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="OrgRoleId" SessionField="MasterOrgRoleID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="UserId" Type="String" />
                                        <asp:Parameter Name="OrgRoleId" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsPrimary" Type="Boolean" />
                                        <asp:Parameter Name="original_Id" Type="Int32" />
                                        <asp:Parameter Name="original_UserId" Type="String" />
                                        <asp:Parameter Name="original_OrgRoleId" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsPrimary" Type="Boolean" />
                                    </UpdateParameters>
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
