<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SecurityWorkflowGroup.aspx.cs" Inherits="DX_WebTemplate.Workflow.SecurityWorkflowGroup" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Workflow Group" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridWorkflowGroup" runat="server" AutoGenerateColumns="False" DataSourceID="sqlWorkflowGroup" KeyFieldName="WFGH_Id">
                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsCustomizationDialog Enabled="True" />
                                    <Templates>
                                        <DetailRow>
                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0">
                                                <TabPages>
                                                    <dx:TabPage Text="Group Details">
                                                        <ContentCollection>
                                                            <dx:ContentControl runat="server">
                                                                <dx:ASPxGridView ID="gridGroupDetail" runat="server" AutoGenerateColumns="False" DataSourceID="sqlGroupDetail" KeyFieldName="WFGD_Id" OnBeforePerformDataSelect="gridGroupDetail_BeforePerformDataSelect" OnRowInserting="gridGroupDetail_RowInserting">
                                                                    <SettingsEditing Mode="Batch">
                                                                    </SettingsEditing>
                                                                    <Columns>
                                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="WFGD_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            <EditFormSettings Visible="False" />
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="WFG_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                        </dx:GridViewDataCheckColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Workflow" FieldName="WF_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                            <PropertiesComboBox DataSourceID="sqlWorkflow" TextField="Name" TextFormatString="{0}" ValueField="WF_Id">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Workflow" FieldName="Name" Width="300px">
                                                                                    </dx:ListBoxColumn>
                                                                                    <dx:ListBoxColumn FieldName="Description" Width="400px">
                                                                                    </dx:ListBoxColumn>
                                                                                </Columns>
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                        <dx:GridViewDataSpinEditColumn FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                            <PropertiesSpinEdit DisplayFormatString="g">
                                                                            </PropertiesSpinEdit>
                                                                        </dx:GridViewDataSpinEditColumn>
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
                                    <SettingsBehavior EnableCustomizationWindow="True" />

<SettingsPopup>
<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>

                                    <SettingsSearchPanel Visible="True" CustomEditorID="tbToolbarSearch" />
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" ShowDeleteButton="True">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="WFGH_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Name" ShowInCustomizationForm="True" VisibleIndex="4">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="5">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="10">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_Id" ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyShortName" ValueField="WASSId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="App" FieldName="App_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlApp" TextField="App_Name" ValueField="App_Id">
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
                                                <dx:GridViewToolbarItem Command="New">
                                                    <Image IconID="actions_add_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem Command="Refresh">
                                                    <Image IconID="actions_refresh_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                            </Items>
                                        </dx:GridViewToolbar>
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlWorkflowGroup" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_WorkflowGroupHeader] WHERE [WFGH_Id] = @original_WFGH_Id" InsertCommand="INSERT INTO [ITP_S_WorkflowGroupHeader] ([Name], [Description], [Company_Id], [App_Id], [DateCreated], [DateModified], [CreatedBy], [ModifiedBy], [IsActive], [IsDelete]) VALUES (@Name, @Description, @Company_Id, @App_Id, @DateCreated, @DateModified, @CreatedBy, @ModifiedBy, @IsActive, @IsDelete)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_WorkflowGroupHeader]" UpdateCommand="UPDATE [ITP_S_WorkflowGroupHeader] SET [Name] = @Name, [Description] = @Description, [Company_Id] = @Company_Id, [App_Id] = @App_Id, [DateCreated] = @DateCreated, [DateModified] = @DateModified, [CreatedBy] = @CreatedBy, [ModifiedBy] = @ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete WHERE [WFGH_Id] = @original_WFGH_Id AND (([Name] = @original_Name) OR ([Name] IS NULL AND @original_Name IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([Company_Id] = @original_Company_Id) OR ([Company_Id] IS NULL AND @original_Company_Id IS NULL)) AND (([App_Id] = @original_App_Id) OR ([App_Id] IS NULL AND @original_App_Id IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_WFGH_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Name" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="Company_Id" Type="Int32" />
                                        <asp:Parameter Name="App_Id" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Name" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="Company_Id" Type="Int32" />
                                        <asp:Parameter Name="App_Id" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_WFGH_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Name" Type="String" />
                                        <asp:Parameter Name="original_Description" Type="String" />
                                        <asp:Parameter Name="original_Company_Id" Type="Int32" />
                                        <asp:Parameter Name="original_App_Id" Type="Int32" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
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
                                <asp:SqlDataSource ID="sqlGroupDetail" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_WorkflowGroupDetail] WHERE [WFGD_Id] = @original_WFGD_Id" InsertCommand="INSERT INTO [ITP_S_WorkflowGroupDetail] ([WFG_Id], [WF_Id], [Type], [Sequence], [DateCreated], [DateModified], [CreatedBy], [ModifiedBy], [IsActive], [IsDelete]) VALUES (@WFG_Id, @WF_Id, @Type, @Sequence, @DateCreated, @DateModified, @CreatedBy, @ModifiedBy, @IsActive, @IsDelete)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_WorkflowGroupDetail] WHERE ([WFG_Id] = @WFG_Id) ORDER BY [Sequence]" UpdateCommand="UPDATE [ITP_S_WorkflowGroupDetail] SET [WFG_Id] = @WFG_Id, [WF_Id] = @WF_Id, [Type] = @Type, [Sequence] = @Sequence, [DateCreated] = @DateCreated, [DateModified] = @DateModified, [CreatedBy] = @CreatedBy, [ModifiedBy] = @ModifiedBy, [IsActive] = @IsActive, [IsDelete] = @IsDelete WHERE [WFGD_Id] = @original_WFGD_Id AND (([WFG_Id] = @original_WFG_Id) OR ([WFG_Id] IS NULL AND @original_WFG_Id IS NULL)) AND (([WF_Id] = @original_WF_Id) OR ([WF_Id] IS NULL AND @original_WF_Id IS NULL)) AND (([Type] = @original_Type) OR ([Type] IS NULL AND @original_Type IS NULL)) AND (([Sequence] = @original_Sequence) OR ([Sequence] IS NULL AND @original_Sequence IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([IsDelete] = @original_IsDelete) OR ([IsDelete] IS NULL AND @original_IsDelete IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_WFGD_Id" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="WFG_Id" Type="Int32" />
                                        <asp:Parameter Name="WF_Id" Type="Int32" />
                                        <asp:Parameter Name="Type" Type="Int32" />
                                        <asp:Parameter Name="Sequence" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="WFG_Id" SessionField="MasterGroupID" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="WFG_Id" Type="Int32" />
                                        <asp:Parameter Name="WF_Id" Type="Int32" />
                                        <asp:Parameter Name="Type" Type="Int32" />
                                        <asp:Parameter Name="Sequence" Type="Int32" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="IsDelete" Type="Boolean" />
                                        <asp:Parameter Name="original_WFGD_Id" Type="Int32" />
                                        <asp:Parameter Name="original_WFG_Id" Type="Int32" />
                                        <asp:Parameter Name="original_WF_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Type" Type="Int32" />
                                        <asp:Parameter Name="original_Sequence" Type="Int32" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_CreatedBy" Type="Int32" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="Int32" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_IsDelete" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlWorkflow" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WF_Id], [Name], [Description] FROM [ITP_S_WorkflowHeader] WHERE (([App_Id] = @App_Id) AND ([Company_Id] = @Company_Id))">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="App_Id" SessionField="MasterAppID" Type="Int32" />
                                        <asp:SessionParameter Name="Company_Id" SessionField="MasterCompanyID" Type="Int32" />
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
