<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityWorkflow.aspx.cs" Inherits="DX_WebTemplate.Workflow.SecurityWorkflow" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Workflow Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridWorkflow" runat="server" AutoGenerateColumns="False" DataSourceID="sqlWorkflowHeader" KeyFieldName="WF_Id">
                                    <SettingsDetail ShowDetailRow="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="Workflow Details">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridWorkflowDetails" runat="server" AutoGenerateColumns="False" DataSourceID="sqlWorkflowDetails" KeyFieldName="WFD_Id" OnBeforePerformDataSelect="gridWorkflowDetails_BeforePerformDataSelect" OnRowInserting="gridWorkflowDetails_RowInserting">
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="WFD_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="11">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Approver (Org Role)" FieldName="OrgRole_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                            <PropertiesComboBox DataSourceID="sqlOrgRoles" TextFormatString="{0}" ValueField="Id">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Role" FieldName="Role_Name" Width="250px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="Description" Width="350px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                                <ValidationSettings>
                                                                                    <RequiredField IsRequired="True" />
                                                                                </ValidationSettings>
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                            <PropertiesSpinEdit DisplayFormatString="g" MaxValue="10" MinValue="1">
                                                                                <ValidationSettings>
                                                                                    <RequiredField IsRequired="True" />
                                                                                </ValidationSettings>
                                                                            </PropertiesSpinEdit>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                        <dx:GridViewDataComboBoxColumn FieldName="Type" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                            <PropertiesComboBox DataSourceID="sqlSignType" TextField="ST_Name" ValueField="ST_ID">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn FieldName="ApprovalNeeded" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                            <PropertiesSpinEdit DisplayFormatString="g" MaxValue="5" MinValue="1">
                                                                                <ValidationSettings ErrorText="Invalid Value">
                                                                                    <RequiredField IsRequired="True" />
                                                                                </ValidationSettings>
                                                                            </PropertiesSpinEdit>
                                                                        </dx:GridViewDataSpinEditColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Next Approver Sequence" FieldName="NextWFD_Id" ShowInCustomizationForm="True" VisibleIndex="10">
                                                                            <PropertiesComboBox DataSourceID="sqlWorkflowDetails" TextField="Sequence" ValueField="WFD_Id">
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                    </Columns>
                                                                </dx:ASPxGridView>
                                                            </dx:ContentControl>
                                                        </ContentCollection>
                                                    </dx:TabPage>
                                                    <dx:TabPage Text="Workflow Group (included)">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridGroupDetail" runat="server" AutoGenerateColumns="False" DataSourceID="sqlGroupDetail" OnBeforePerformDataSelect="gridGroupDetail_BeforePerformDataSelect" SettingsAdaptivity-AdaptivityMode="HideDataCells" Width="100%">
                                                                    <SettingsAdaptivity AdaptivityMode="HideDataCells">
                                                                    </SettingsAdaptivity>
                                                                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                                    <SettingsPopup>
                                                                        <FilterControl AutoUpdatePosition="False">
                                                                        </FilterControl>
                                                                    </SettingsPopup>
                                                                    <Columns>
                                                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Workflow Group" FieldName="WFG_Id" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                            <PropertiesComboBox DataSourceID="sqlWorkflowGroup" TextField="Name" TextFormatString="{0}" ValueField="WFGH_Id">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn FieldName="Name" Width="350px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="Description" Width="400px">
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
                                    <Settings ShowGroupPanel="True" ShowHeaderFilterButton="True" GroupFormat="{1} {2}" />

                                    <SettingsBehavior EnableCustomizationWindow="True" />

<SettingsPopup>
<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>

                                    <SettingsSearchPanel Visible="True" CustomEditorID="tbToolbarSearch" />
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Workflow" FieldName="Name" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="4">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="6">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="App" FieldName="App_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlApp" TextField="App_Name" ValueField="App_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_Id" ShowInCustomizationForm="True" VisibleIndex="5">
                                            <PropertiesComboBox DataSourceID="sqlCompany" TextFormatString="{0}" ValueField="WASSId">
                                                <Columns>
                                                    <dx:ListBoxColumn Caption="Company" FieldName="CompanyShortName">
                                                    </dx:ListBoxColumn>
                                                    <dx:ListBoxColumn Caption=" " FieldName="CompanyDesc" Width="250px">
                                                    </dx:ListBoxColumn>
                                                </Columns>
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataSpinEditColumn Caption="Max" FieldName="Maximum" ShowInCustomizationForm="True" VisibleIndex="9">
                                            <PropertiesSpinEdit DisplayFormatString="c" Increment="10000" MaxValue="999999999999" NumberFormat="Currency">
                                            </PropertiesSpinEdit>
                                        </dx:GridViewDataSpinEditColumn>
                                        <dx:GridViewDataSpinEditColumn Caption="Min" FieldName="Minimum" ShowInCustomizationForm="True" VisibleIndex="8">
                                            <PropertiesSpinEdit DisplayFormatString="c" Increment="10000" MaxValue="999999999999" NumberFormat="Currency">
                                            </PropertiesSpinEdit>
                                        </dx:GridViewDataSpinEditColumn>
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
                                <asp:SqlDataSource ID="sqlWorkflowHeader" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_WorkflowHeader] WHERE [WF_Id] = @original_WF_Id AND (([Name] = @original_Name) OR ([Name] IS NULL AND @original_Name IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([App_Id] = @original_App_Id) OR ([App_Id] IS NULL AND @original_App_Id IS NULL)) AND (([Company_Id] = @original_Company_Id) OR ([Company_Id] IS NULL AND @original_Company_Id IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsShow] = @original_IsShow) OR ([IsShow] IS NULL AND @original_IsShow IS NULL)) AND (([Minimum] = @original_Minimum) OR ([Minimum] IS NULL AND @original_Minimum IS NULL)) AND (([Maximum] = @original_Maximum) OR ([Maximum] IS NULL AND @original_Maximum IS NULL))" InsertCommand="INSERT INTO [ITP_S_WorkflowHeader] ([Name], [Description], [App_Id], [Company_Id], [DateCreated], [DateModified], [CreatedBy], [ModifiedBy], [IsActive], [IsDelete], [IsShow], [Minimum], [Maximum]) VALUES (@Name, @Description, @App_Id, @Company_Id, @DateCreated, @DateModified, @CreatedBy, @ModifiedBy, @IsActive, @IsDelete, @IsShow, @Minimum, @Maximum)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader]" UpdateCommand="UPDATE [ITP_S_WorkflowHeader] SET [Name] = @Name, [Description] = @Description, [App_Id] = @App_Id, [Company_Id] = @Company_Id, [DateCreated] = @DateCreated, [DateModified] = @DateModified, [CreatedBy] = @CreatedBy, [ModifiedBy] = @ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [IsShow] = @IsShow, [Minimum] = @Minimum, [Maximum] = @Maximum WHERE [WF_Id] = @original_WF_Id AND (([Name] = @original_Name) OR ([Name] IS NULL AND @original_Name IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([App_Id] = @original_App_Id) OR ([App_Id] IS NULL AND @original_App_Id IS NULL)) AND (([Company_Id] = @original_Company_Id) OR ([Company_Id] IS NULL AND @original_Company_Id IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL)) AND (([IsShow] = @original_IsShow) OR ([IsShow] IS NULL AND @original_IsShow IS NULL)) AND (([Minimum] = @original_Minimum) OR ([Minimum] IS NULL AND @original_Minimum IS NULL)) AND (([Maximum] = @original_Maximum) OR ([Maximum] IS NULL AND @original_Maximum IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_WF_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Name" Type="String" />
                                        <asp:Parameter Name="original_Description" Type="String" />
                                        <asp:Parameter Name="original_App_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Company_Id" Type="Int32" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsShow" Type="Boolean" />
                                        <asp:Parameter Name="original_Minimum" Type="Decimal" />
                                        <asp:Parameter Name="original_Maximum" Type="Decimal" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Name" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="App_Id" Type="Int32" />
                                        <asp:Parameter Name="Company_Id" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsShow" Type="Boolean" />
                                        <asp:Parameter Name="Minimum" Type="Decimal" />
                                        <asp:Parameter Name="Maximum" Type="Decimal" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Name" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="App_Id" Type="Int32" />
                                        <asp:Parameter Name="Company_Id" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="IsShow" Type="Boolean" />
                                        <asp:Parameter Name="Minimum" Type="Decimal" />
                                        <asp:Parameter Name="Maximum" Type="Decimal" />
                                        <asp:Parameter Name="original_WF_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Name" Type="String" />
                                        <asp:Parameter Name="original_Description" Type="String" />
                                        <asp:Parameter Name="original_App_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Company_Id" Type="Int32" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_IsShow" Type="Boolean" />
                                        <asp:Parameter Name="original_Minimum" Type="Decimal" />
                                        <asp:Parameter Name="original_Maximum" Type="Decimal" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [App_Id], [App_Name], [App_Description] FROM [ITP_S_SecurityApp] WHERE ([IsActive] = @IsActive) ORDER BY [App_Name]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [WASSId] FROM [CompanyMaster] WHERE (([IsActive] = @IsActive) AND ([WASSId] IS NOT NULL)) ORDER BY [CompanyShortName]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlWorkflowDetails" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_WorkflowDetails] WHERE [WFD_Id] = @original_WFD_Id" InsertCommand="INSERT INTO [ITP_S_WorkflowDetails] ([WF_Id], [Description], [OrgRole_Id], [Sequence], [Type], [DateCreated], [DateModified], [CreatedBy], [ModifiedBy], [IsActive], [IsDelete], [ApprovalNeeded], [WFDStatus], [NextWFD_Id]) VALUES (@WF_Id, @Description, @OrgRole_Id, @Sequence, @Type, @DateCreated, @DateModified, @CreatedBy, @ModifiedBy, @IsActive, @IsDelete, @ApprovalNeeded, @WFDStatus, @NextWFD_Id)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_WorkflowDetails] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence], [WF_Id]" UpdateCommand="UPDATE [ITP_S_WorkflowDetails] SET [WF_Id] = @WF_Id, [Description] = @Description, [OrgRole_Id] = @OrgRole_Id, [Sequence] = @Sequence, [Type] = @Type, [DateCreated] = @DateCreated, [DateModified] = @DateModified, [CreatedBy] = @CreatedBy, [ModifiedBy] = @ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete, [ApprovalNeeded] = @ApprovalNeeded, [WFDStatus] = @WFDStatus, [NextWFD_Id] = @NextWFD_Id WHERE [WFD_Id] = @original_WFD_Id">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_WFD_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="WF_Id" Type="Int32" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="OrgRole_Id" Type="Int32" />
                                        <asp:Parameter Name="Sequence" Type="Int32" />
                                        <asp:Parameter Name="Type" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="ApprovalNeeded" Type="Int32" />
                                        <asp:Parameter Name="WFDStatus" Type="String" />
                                        <asp:Parameter Name="NextWFD_Id" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="WF_Id" SessionField="MasterWorkflowID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="WF_Id" Type="Int32" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="OrgRole_Id" Type="Int32" />
                                        <asp:Parameter Name="Sequence" Type="Int32" />
                                        <asp:Parameter Name="Type" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="ApprovalNeeded" Type="Int32" />
                                        <asp:Parameter Name="WFDStatus" Type="String" />
                                        <asp:Parameter Name="NextWFD_Id" Type="Int32" />
                                        <asp:Parameter Name="original_WFD_Id" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlOrgRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [Id], [Role_Name], [Description] FROM [ITP_S_SecurityOrgRoles] WHERE ([IsActive] = @IsActive) ORDER BY [Role_Name]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlSignType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [ST_ID], [ST_Name], [ST_Description] FROM [ITP_S_SignType] WHERE ([ST_IsActive] = @ST_IsActive) ORDER BY [ST_ID]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="true" Name="ST_IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlGroupDetail" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WF_Id], [WFG_Id] FROM [ITP_S_WorkflowGroupDetail] WHERE ([WF_Id] = @WF_Id)">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="WF_Id" SessionField="MasterWorkflowID" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlWorkflowGroup" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WFGH_Id], [Name], [Description] FROM [ITP_S_WorkflowGroupHeader]"></asp:SqlDataSource>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
   </div>
</asp:Content>
