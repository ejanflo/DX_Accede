<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="SetupTile.aspx.cs" Inherits="DX_WebTemplate.Security.SetupTile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="centerPane conta" id="form1">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Tile Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="1">
                                    <TabPages>
                                        <dx:TabPage Text="Tile Groups">
                                            <ContentCollection>
                                                <dx:ContentControl runat="server">
                                                    <dx:ASPxGridView ID="gridTileGroup0" runat="server" AutoGenerateColumns="False" DataSourceID="sqlTileGroup" KeyFieldName="ID" Theme="iOS" Width="100%">
                                                        <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                        <SettingsContextMenu Enabled="True">
                                                        </SettingsContextMenu>
                                                        <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" AllowOnlyOneAdaptiveDetailExpanded="True" HideDataCellsAtWindowInnerWidth="900">
                                                        </SettingsAdaptivity>
                                                        <Templates>
                                                            <DetailRow>
                                                                <dx:ASPxPageControl ID="ASPxPageControl2" runat="server" ActiveTabIndex="0">
                                                                    <TabPages>
                                                                        <dx:TabPage Text="Tiles in Group">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl runat="server">
                                                                                    <dx:ASPxGridView ID="gridTileInGroup" runat="server" AutoGenerateColumns="False" DataSourceID="sqlGroupTiles" KeyFieldName="ID" OnBeforePerformDataSelect="gridTileInGroup_BeforePerformDataSelect" OnRowInserting="gridTileInGroup_RowInserting">
                                                                                        <SettingsContextMenu Enabled="True">
                                                                                        </SettingsContextMenu>
                                                                                        <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" AllowOnlyOneAdaptiveDetailExpanded="True" HideDataCellsAtWindowInnerWidth="900">
                                                                                        </SettingsAdaptivity>
                                                                                        <SettingsPager PageSize="32">
                                                                                            <FirstPageButton Visible="True">
                                                                                            </FirstPageButton>
                                                                                            <LastPageButton Visible="True">
                                                                                            </LastPageButton>
                                                                                            <PageSizeItemSettings Visible="True">
                                                                                            </PageSizeItemSettings>
                                                                                        </SettingsPager>
                                                                                        <SettingsEditing Mode="Batch">
                                                                                        </SettingsEditing>
                                                                                        <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                                                        <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                                                        <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                                                        <SettingsPopup>
                                                                                            <FilterControl AutoUpdatePosition="False">
                                                                                            </FilterControl>
                                                                                        </SettingsPopup>
                                                                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearchTIG" Visible="True" />
                                                                                        <Columns>
                                                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="90px">
                                                                                            </dx:GridViewCommandColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                <EditFormSettings Visible="False" />
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="TileGroup_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataComboBoxColumn Caption="Tile" FieldName="Tile_ID" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                <PropertiesComboBox DataSourceID="sqlTile" TextFormatString="{0} - {1}" ValueField="ID">
                                                                                                    <Columns>
                                                                                                        <dx:ListBoxColumn FieldName="Title" Width="250px">
                                                                                                        </dx:ListBoxColumn>
                                                                                                        <dx:ListBoxColumn FieldName="Subtitle" Width="150px">
                                                                                                        </dx:ListBoxColumn>
                                                                                                        <dx:ListBoxColumn FieldName="Information" Width="100px">
                                                                                                        </dx:ListBoxColumn>
                                                                                                    </Columns>
                                                                                                </PropertiesComboBox>
                                                                                            </dx:GridViewDataComboBoxColumn>
                                                                                        </Columns>
                                                                                        <Toolbars>
                                                                                            <dx:GridViewToolbar>
                                                                                                <Items>
                                                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                                                    </dx:GridViewToolbarItem>
                                                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                                                        <Template>
                                                                                                            <dx:ASPxButtonEdit ID="tbToolbarSearchTIG" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                                                                                <Buttons>
                                                                                                                    <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                                                    </dx:SpinButtonExtended>
                                                                                                                </Buttons>
                                                                                                            </dx:ASPxButtonEdit>
                                                                                                        </Template>
                                                                                                    </dx:GridViewToolbarItem>
                                                                                                </Items>
                                                                                            </dx:GridViewToolbar>
                                                                                        </Toolbars>
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
                                                        <SettingsEditing Mode="Batch">
                                                        </SettingsEditing>
                                                        <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                        <SettingsBehavior AllowEllipsisInText="True" AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                        <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearch0" Visible="True" />
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="90px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataSpinEditColumn Caption="Sorting" FieldName="Sort" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                <PropertiesSpinEdit DisplayFormatString="g">
                                                                </PropertiesSpinEdit>
                                                            </dx:GridViewDataSpinEditColumn>
                                                        </Columns>
                                                        <Toolbars>
                                                            <dx:GridViewToolbar>
                                                                <Items>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                    </dx:GridViewToolbarItem>
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
                                                        </Toolbars>
                                                    </dx:ASPxGridView>
                                                </dx:ContentControl>
                                            </ContentCollection>
                                        </dx:TabPage>
                                        <dx:TabPage Text="Tiles">
                                            <ContentCollection>
                                                <dx:ContentControl runat="server">
                                                    <dx:ASPxGridView ID="gridTile" runat="server" AutoGenerateColumns="False" DataSourceID="sqlTile" KeyFieldName="ID">
                                                        <SettingsDetail ShowDetailRow="True" AllowOnlyOneMasterRowExpanded="True" />
                                                        <SettingsContextMenu Enabled="True">
                                                        </SettingsContextMenu>
                                                        <SettingsAdaptivity AdaptiveDetailColumnCount="2" AdaptivityMode="HideDataCellsWindowLimit" AllowHideDataCellsByColumnMinWidth="True" AllowOnlyOneAdaptiveDetailExpanded="True" HideDataCellsAtWindowInnerWidth="900">
                                                        </SettingsAdaptivity>
                                                        <Templates>
                                                            <DetailRow>
                                                                <dx:ASPxPageControl ID="ASPxPageControl3" runat="server" ActiveTabIndex="0">
                                                                    <TabPages>
                                                                        <dx:TabPage Text="Security Role">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl runat="server">
                                                                                    <dx:ASPxGridView ID="gridTileRole" runat="server" AutoGenerateColumns="False" DataSourceID="sqlTileRole" KeyFieldName="ID" OnBeforePerformDataSelect="gridTileRole_BeforePerformDataSelect" OnRowInserting="gridTileRole_RowInserting">
                                                                                        <SettingsEditing Mode="Batch">
                                                                                        </SettingsEditing>
                                                                                        <SettingsPopup>
                                                                                            <FilterControl AutoUpdatePosition="False">
                                                                                            </FilterControl>
                                                                                        </SettingsPopup>
                                                                                        <Columns>
                                                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                                                                            </dx:GridViewCommandColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                <EditFormSettings Visible="False" />
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="SecurityApp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="Tile_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                            </dx:GridViewDataCheckColumn>
                                                                                            <dx:GridViewDataCheckColumn FieldName="CreateAccess" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                            </dx:GridViewDataCheckColumn>
                                                                                            <dx:GridViewDataCheckColumn FieldName="ReadAccess" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                                            </dx:GridViewDataCheckColumn>
                                                                                            <dx:GridViewDataCheckColumn FieldName="UpdateAccess" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                                            </dx:GridViewDataCheckColumn>
                                                                                            <dx:GridViewDataCheckColumn FieldName="DeleteAccess" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                                            </dx:GridViewDataCheckColumn>
                                                                                            <dx:GridViewDataComboBoxColumn Caption="Security Role" FieldName="SecurityRole_ID" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                <PropertiesComboBox DataSourceID="sqlRoles" TextField="Role_Name" TextFormatString="{0}" ValueField="Role_Id">
                                                                                                    <Columns>
                                                                                                        <dx:ListBoxColumn Caption="Role Name" FieldName="Role_Name" Width="200px">
                                                                                                        </dx:ListBoxColumn>
                                                                                                        <dx:ListBoxColumn FieldName="Description" Width="250px">
                                                                                                        </dx:ListBoxColumn>
                                                                                                    </Columns>
                                                                                                </PropertiesComboBox>
                                                                                            </dx:GridViewDataComboBoxColumn>
                                                                                        </Columns>
                                                                                    </dx:ASPxGridView>
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text="Group Included">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl runat="server">
                                                                                    <dx:ASPxGridView ID="gridTileGroupIncluded" runat="server" AutoGenerateColumns="False" DataSourceID="sqlGroupTiles2" KeyFieldName="ID" OnBeforePerformDataSelect="gridTileGroupIncluded_BeforePerformDataSelect">
                                                                                        <SettingsPopup>
                                                                                            <FilterControl AutoUpdatePosition="False">
                                                                                            </FilterControl>
                                                                                        </SettingsPopup>
                                                                                        <Columns>
                                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                <EditFormSettings Visible="False" />
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataTextColumn FieldName="Tile_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                            </dx:GridViewDataTextColumn>
                                                                                            <dx:GridViewDataComboBoxColumn Caption="Tile Group" FieldName="TileGroup_ID" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                <PropertiesComboBox DataSourceID="sqlTileGroup" ValueField="ID">
                                                                                                    <Columns>
                                                                                                        <dx:ListBoxColumn FieldName="Name">
                                                                                                        </dx:ListBoxColumn>
                                                                                                        <dx:ListBoxColumn FieldName="Description" Width="300px">
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
                                                        <SettingsPager PageSize="32">
                                                            <FirstPageButton Visible="True">
                                                            </FirstPageButton>
                                                            <LastPageButton Visible="True">
                                                            </LastPageButton>
                                                            <PageSizeItemSettings Visible="True">
                                                            </PageSizeItemSettings>
                                                        </SettingsPager>
                                                        <SettingsEditing Mode="Batch">
                                                        </SettingsEditing>
                                                        <Settings ShowHeaderFilterButton="True" VerticalScrollableHeight="350" />
                                                        <SettingsBehavior AllowSelectByRowClick="True" ColumnMoveMode="ThroughHierarchy" EnableCustomizationWindow="True" />
                                                        <SettingsResizing ColumnResizeMode="Control" Visualization="Postponed" />
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearchTile" Visible="True" />
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="70px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Title" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Subtitle" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="URL" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Icon" ShowInCustomizationForm="True" VisibleIndex="6">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Value" ShowInCustomizationForm="True" VisibleIndex="7">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Information" ShowInCustomizationForm="True" VisibleIndex="8">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="App" FieldName="App_ID" ShowInCustomizationForm="True" VisibleIndex="2" Width="90px">
                                                                <PropertiesComboBox DataSourceID="sqlApps" TextFormatString="{0}" ValueField="App_Id">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Name" FieldName="App_Name">
                                                                        </dx:ListBoxColumn>
                                                                        <dx:ListBoxColumn Caption="Description" FieldName="App_Description" Width="250px">
                                                                        </dx:ListBoxColumn>
                                                                    </Columns>
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataCheckColumn Caption="Is Active" FieldName="isActive" ShowInCustomizationForm="True" VisibleIndex="9">
                                                            </dx:GridViewDataCheckColumn>
                                                        </Columns>
                                                        <Toolbars>
                                                            <dx:GridViewToolbar>
                                                                <Items>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True" Command="Refresh">
                                                                    </dx:GridViewToolbarItem>
                                                                    <dx:GridViewToolbarItem Alignment="Right" BeginGroup="True">
                                                                        <Template>
                                                                            <dx:ASPxButtonEdit ID="tbToolbarSearchTile" runat="server" Height="100%" NullText="Search..." Theme="iOS" Width="400px">
                                                                                <Buttons>
                                                                                    <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                                    </dx:SpinButtonExtended>
                                                                                </Buttons>
                                                                            </dx:ASPxButtonEdit>
                                                                        </Template>
                                                                    </dx:GridViewToolbarItem>
                                                                </Items>
                                                            </dx:GridViewToolbar>
                                                        </Toolbars>
                                                    </dx:ASPxGridView>
                                                </dx:ContentControl>
                                            </ContentCollection>
                                        </dx:TabPage>
                                    </TabPages>
                                </dx:ASPxPageControl>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    </div>
    <asp:SqlDataSource ID="sqlTileGroup" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [AGA_S_TileGroup] WHERE [ID] = @original_ID AND (([Name] = @original_Name) OR ([Name] IS NULL AND @original_Name IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL)) AND (([Sort] = @original_Sort) OR ([Sort] IS NULL AND @original_Sort IS NULL))" InsertCommand="INSERT INTO [AGA_S_TileGroup] ([Name], [Description], [isActive], [Sort]) VALUES (@Name, @Description, @isActive, @Sort)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [AGA_S_TileGroup] ORDER BY [Sort]" UpdateCommand="UPDATE [AGA_S_TileGroup] SET [Name] = @Name, [Description] = @Description, [isActive] = @isActive, [Sort] = @Sort WHERE [ID] = @original_ID AND (([Name] = @original_Name) OR ([Name] IS NULL AND @original_Name IS NULL)) AND (([Description] = @original_Description) OR ([Description] IS NULL AND @original_Description IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL)) AND (([Sort] = @original_Sort) OR ([Sort] IS NULL AND @original_Sort IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_Name" Type="String" />
            <asp:Parameter Name="original_Description" Type="String" />
            <asp:Parameter Name="original_isActive" Type="Boolean" />
            <asp:Parameter Name="original_Sort" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Name" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="isActive" Type="Boolean" />
            <asp:Parameter Name="Sort" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Name" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="isActive" Type="Boolean" />
            <asp:Parameter Name="Sort" Type="Int32" />
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_Name" Type="String" />
            <asp:Parameter Name="original_Description" Type="String" />
            <asp:Parameter Name="original_isActive" Type="Boolean" />
            <asp:Parameter Name="original_Sort" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlTile" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [AGA_S_Tile] WHERE [ID] = @original_ID AND (([Title] = @original_Title) OR ([Title] IS NULL AND @original_Title IS NULL)) AND (([Subtitle] = @original_Subtitle) OR ([Subtitle] IS NULL AND @original_Subtitle IS NULL)) AND (([URL] = @original_URL) OR ([URL] IS NULL AND @original_URL IS NULL)) AND (([Icon] = @original_Icon) OR ([Icon] IS NULL AND @original_Icon IS NULL)) AND (([Value] = @original_Value) OR ([Value] IS NULL AND @original_Value IS NULL)) AND (([Information] = @original_Information) OR ([Information] IS NULL AND @original_Information IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL))" InsertCommand="INSERT INTO [AGA_S_Tile] ([Title], [Subtitle], [URL], [Icon], [Value], [Information], [App_ID], [isActive]) VALUES (@Title, @Subtitle, @URL, @Icon, @Value, @Information, @App_ID, @isActive)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [AGA_S_Tile] ORDER BY [App_ID], [Title]" UpdateCommand="UPDATE [AGA_S_Tile] SET [Title] = @Title, [Subtitle] = @Subtitle, [URL] = @URL, [Icon] = @Icon, [Value] = @Value, [Information] = @Information, [App_ID] = @App_ID, [isActive] = @isActive WHERE [ID] = @original_ID AND (([Title] = @original_Title) OR ([Title] IS NULL AND @original_Title IS NULL)) AND (([Subtitle] = @original_Subtitle) OR ([Subtitle] IS NULL AND @original_Subtitle IS NULL)) AND (([URL] = @original_URL) OR ([URL] IS NULL AND @original_URL IS NULL)) AND (([Icon] = @original_Icon) OR ([Icon] IS NULL AND @original_Icon IS NULL)) AND (([Value] = @original_Value) OR ([Value] IS NULL AND @original_Value IS NULL)) AND (([Information] = @original_Information) OR ([Information] IS NULL AND @original_Information IS NULL)) AND (([App_ID] = @original_App_ID) OR ([App_ID] IS NULL AND @original_App_ID IS NULL)) AND (([isActive] = @original_isActive) OR ([isActive] IS NULL AND @original_isActive IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_Title" Type="String" />
            <asp:Parameter Name="original_Subtitle" Type="String" />
            <asp:Parameter Name="original_URL" Type="String" />
            <asp:Parameter Name="original_Icon" Type="String" />
            <asp:Parameter Name="original_Value" Type="String" />
            <asp:Parameter Name="original_Information" Type="String" />
            <asp:Parameter Name="original_App_ID" Type="Int32" />
            <asp:Parameter Name="original_isActive" Type="Boolean" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Title" Type="String" />
            <asp:Parameter Name="Subtitle" Type="String" />
            <asp:Parameter Name="URL" Type="String" />
            <asp:Parameter Name="Icon" Type="String" />
            <asp:Parameter Name="Value" Type="String" />
            <asp:Parameter Name="Information" Type="String" />
            <asp:Parameter Name="App_ID" Type="Int32" />
            <asp:Parameter Name="isActive" Type="Boolean" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Title" Type="String" />
            <asp:Parameter Name="Subtitle" Type="String" />
            <asp:Parameter Name="URL" Type="String" />
            <asp:Parameter Name="Icon" Type="String" />
            <asp:Parameter Name="Value" Type="String" />
            <asp:Parameter Name="Information" Type="String" />
            <asp:Parameter Name="App_ID" Type="Int32" />
            <asp:Parameter Name="isActive" Type="Boolean" />
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_Title" Type="String" />
            <asp:Parameter Name="original_Subtitle" Type="String" />
            <asp:Parameter Name="original_URL" Type="String" />
            <asp:Parameter Name="original_Icon" Type="String" />
            <asp:Parameter Name="original_Value" Type="String" />
            <asp:Parameter Name="original_Information" Type="String" />
            <asp:Parameter Name="original_App_ID" Type="Int32" />
            <asp:Parameter Name="original_isActive" Type="Boolean" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlApps" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_SecurityApp] WHERE ([IsActive] = @IsActive) ORDER BY [App_Name]">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlGroupTiles" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [AGA_M_GroupTiles] WHERE [ID] = @original_ID AND (([TileGroup_ID] = @original_TileGroup_ID) OR ([TileGroup_ID] IS NULL AND @original_TileGroup_ID IS NULL)) AND (([Tile_ID] = @original_Tile_ID) OR ([Tile_ID] IS NULL AND @original_Tile_ID IS NULL))" InsertCommand="INSERT INTO [AGA_M_GroupTiles] ([TileGroup_ID], [Tile_ID]) VALUES (@TileGroup_ID, @Tile_ID)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [AGA_M_GroupTiles] WHERE ([TileGroup_ID] = @TileGroup_ID)" UpdateCommand="UPDATE [AGA_M_GroupTiles] SET [TileGroup_ID] = @TileGroup_ID, [Tile_ID] = @Tile_ID WHERE [ID] = @original_ID AND (([TileGroup_ID] = @original_TileGroup_ID) OR ([TileGroup_ID] IS NULL AND @original_TileGroup_ID IS NULL)) AND (([Tile_ID] = @original_Tile_ID) OR ([Tile_ID] IS NULL AND @original_Tile_ID IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_TileGroup_ID" Type="Int32" />
            <asp:Parameter Name="original_Tile_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="TileGroup_ID" Type="Int32" />
            <asp:Parameter Name="Tile_ID" Type="Int32" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="TileGroup_ID" SessionField="MasterGroupID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="TileGroup_ID" Type="Int32" />
            <asp:Parameter Name="Tile_ID" Type="Int32" />
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_TileGroup_ID" Type="Int32" />
            <asp:Parameter Name="original_Tile_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlGroupTiles2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [AGA_M_GroupTiles] WHERE ([Tile_ID] = @Tile_ID)">
        <SelectParameters>
            <asp:SessionParameter Name="Tile_ID" SessionField="MasterTileID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlTileRole" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_SecurityTileRole] WHERE [ID] = @original_ID AND (([SecurityApp_ID] = @original_SecurityApp_ID) OR ([SecurityApp_ID] IS NULL AND @original_SecurityApp_ID IS NULL)) AND (([SecurityRole_ID] = @original_SecurityRole_ID) OR ([SecurityRole_ID] IS NULL AND @original_SecurityRole_ID IS NULL)) AND (([Tile_ID] = @original_Tile_ID) OR ([Tile_ID] IS NULL AND @original_Tile_ID IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([CreateAccess] = @original_CreateAccess) OR ([CreateAccess] IS NULL AND @original_CreateAccess IS NULL)) AND (([ReadAccess] = @original_ReadAccess) OR ([ReadAccess] IS NULL AND @original_ReadAccess IS NULL)) AND (([UpdateAccess] = @original_UpdateAccess) OR ([UpdateAccess] IS NULL AND @original_UpdateAccess IS NULL)) AND (([DeleteAccess] = @original_DeleteAccess) OR ([DeleteAccess] IS NULL AND @original_DeleteAccess IS NULL))" InsertCommand="INSERT INTO [ITP_S_SecurityTileRole] ([SecurityApp_ID], [SecurityRole_ID], [Tile_ID], [IsActive], [CreateAccess], [ReadAccess], [UpdateAccess], [DeleteAccess]) VALUES (@SecurityApp_ID, @SecurityRole_ID, @Tile_ID, @IsActive, @CreateAccess, @ReadAccess, @UpdateAccess, @DeleteAccess)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_SecurityTileRole] WHERE (([SecurityApp_ID] = @SecurityApp_ID) AND ([Tile_ID] = @Tile_ID))" UpdateCommand="UPDATE [ITP_S_SecurityTileRole] SET [SecurityApp_ID] = @SecurityApp_ID, [SecurityRole_ID] = @SecurityRole_ID, [Tile_ID] = @Tile_ID, [IsActive] = @IsActive, [CreateAccess] = @CreateAccess, [ReadAccess] = @ReadAccess, [UpdateAccess] = @UpdateAccess, [DeleteAccess] = @DeleteAccess WHERE [ID] = @original_ID AND (([SecurityApp_ID] = @original_SecurityApp_ID) OR ([SecurityApp_ID] IS NULL AND @original_SecurityApp_ID IS NULL)) AND (([SecurityRole_ID] = @original_SecurityRole_ID) OR ([SecurityRole_ID] IS NULL AND @original_SecurityRole_ID IS NULL)) AND (([Tile_ID] = @original_Tile_ID) OR ([Tile_ID] IS NULL AND @original_Tile_ID IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL)) AND (([CreateAccess] = @original_CreateAccess) OR ([CreateAccess] IS NULL AND @original_CreateAccess IS NULL)) AND (([ReadAccess] = @original_ReadAccess) OR ([ReadAccess] IS NULL AND @original_ReadAccess IS NULL)) AND (([UpdateAccess] = @original_UpdateAccess) OR ([UpdateAccess] IS NULL AND @original_UpdateAccess IS NULL)) AND (([DeleteAccess] = @original_DeleteAccess) OR ([DeleteAccess] IS NULL AND @original_DeleteAccess IS NULL))">
        <DeleteParameters>
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_SecurityApp_ID" Type="Int32" />
            <asp:Parameter Name="original_SecurityRole_ID" Type="Int32" />
            <asp:Parameter Name="original_Tile_ID" Type="Int32" />
            <asp:Parameter Name="original_IsActive" Type="Boolean" />
            <asp:Parameter Name="original_CreateAccess" Type="Boolean" />
            <asp:Parameter Name="original_ReadAccess" Type="Boolean" />
            <asp:Parameter Name="original_UpdateAccess" Type="Boolean" />
            <asp:Parameter Name="original_DeleteAccess" Type="Boolean" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="SecurityApp_ID" Type="Int32" />
            <asp:Parameter Name="SecurityRole_ID" Type="Int32" />
            <asp:Parameter Name="Tile_ID" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="CreateAccess" Type="Boolean" />
            <asp:Parameter Name="ReadAccess" Type="Boolean" />
            <asp:Parameter Name="UpdateAccess" Type="Boolean" />
            <asp:Parameter Name="DeleteAccess" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:SessionParameter Name="SecurityApp_ID" SessionField="MasterAppID" Type="Int32" />
            <asp:SessionParameter Name="Tile_ID" SessionField="MasterTileID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="SecurityApp_ID" Type="Int32" />
            <asp:Parameter Name="SecurityRole_ID" Type="Int32" />
            <asp:Parameter Name="Tile_ID" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="CreateAccess" Type="Boolean" />
            <asp:Parameter Name="ReadAccess" Type="Boolean" />
            <asp:Parameter Name="UpdateAccess" Type="Boolean" />
            <asp:Parameter Name="DeleteAccess" Type="Boolean" />
            <asp:Parameter Name="original_ID" Type="Int32" />
            <asp:Parameter Name="original_SecurityApp_ID" Type="Int32" />
            <asp:Parameter Name="original_SecurityRole_ID" Type="Int32" />
            <asp:Parameter Name="original_Tile_ID" Type="Int32" />
            <asp:Parameter Name="original_IsActive" Type="Boolean" />
            <asp:Parameter Name="original_CreateAccess" Type="Boolean" />
            <asp:Parameter Name="original_ReadAccess" Type="Boolean" />
            <asp:Parameter Name="original_UpdateAccess" Type="Boolean" />
            <asp:Parameter Name="original_DeleteAccess" Type="Boolean" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sqlRoles" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [Role_Id], [Role_Name], [Description] FROM [ITP_S_SecurityRoles] WHERE (([IsActive] = @IsActive) AND ([AppId] = @AppId)) ORDER BY [Role_Name]">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="AppId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
