<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="DocNo.aspx.cs" Inherits="DX_WebTemplate.Setup.DocNo" %>
<%@ Register assembly="DevExpress.Web.ASPxPivotGrid.v22.2, Version=22.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxPivotGrid" tagprefix="dx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="formDocNo" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Document Number Setup" ColSpan="1" GroupBoxDecoration="HeadingLine">
                <GroupBoxStyle>
                    <Caption Font-Bold="True" Font-Size="X-Large">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="sqlDocNo" KeyFieldName="ID">
                                    <SettingsContextMenu Enabled="True">
                                    </SettingsContextMenu>
                                    <SettingsPager PageSize="20" Position="TopAndBottom">
                                        <AllButton Visible="True">
                                        </AllButton>
                                        <FirstPageButton Visible="True">
                                        </FirstPageButton>
                                        <LastPageButton Visible="True">
                                        </LastPageButton>
                                        <PageSizeItemSettings Visible="True">
                                        </PageSizeItemSettings>
                                    </SettingsPager>
                                    <SettingsEditing Mode="PopupEditForm">
                                    </SettingsEditing>
                                    <Settings ShowHeaderFilterButton="True" />
                                    <SettingsBehavior EnableCustomizationWindow="True" ConfirmDelete="True" />
                                    <SettingsPopup>
                                        <EditForm AllowResize="True" HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter">
                                        </EditForm>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <SettingsSearchPanel Visible="True" CustomEditorID="tbToolbarSearch" />
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" ShowEditButton="True">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Prefix" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Value" ShowInCustomizationForm="True" VisibleIndex="4">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="NextNum" ShowInCustomizationForm="True" VisibleIndex="5">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="DocNumCreated" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Doc Type" FieldName="DocType_ID" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlDocType" TextField="DCT_Name" ValueField="DCT_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                            <PropertiesComboBox DataSourceID="sqlCompany" TextField="CompanyDesc" ValueField="WASSId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="App" FieldName="App_ID" ShowInCustomizationForm="True" VisibleIndex="7">
                                            <PropertiesComboBox DataSourceID="sqlApp" TextField="App_Name" ValueField="App_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                    </Columns>
                                    <Toolbars>
                                        <dx:GridViewToolbar>
                                            <Items>
                                                <dx:GridViewToolbarItem Command="Refresh">
                                                    <Image IconID="actions_refresh_16x16gray">
                                                    </Image>
                                                </dx:GridViewToolbarItem>
                                                <dx:GridViewToolbarItem BeginGroup="True">
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
                                    </Toolbars>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [CompanyDesc], [CompanyShortName], [WASSId] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL) ORDER BY [CompanyShortName]"></asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlApp" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [App_Id], [App_Name], [App_Description] FROM [ITP_S_SecurityApp] WHERE ([IsActive] = @IsActive) ORDER BY [App_Name]">
                                    <SelectParameters>
                                        <asp:Parameter DefaultValue="True" Name="IsActive" Type="Boolean" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDocNo" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_DocumentNumber] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ITP_S_DocumentNumber] ([DocType_ID], [Prefix], [Value], [NextNum], [Company_ID], [App_ID], [DocNumCreated]) VALUES (@DocType_ID, @Prefix, @Value, @NextNum, @Company_ID, @App_ID, @DocNumCreated)" SelectCommand="SELECT * FROM [ITP_S_DocumentNumber] ORDER BY [App_ID], [Company_ID]" UpdateCommand="UPDATE [ITP_S_DocumentNumber] SET [DocType_ID] = @DocType_ID, [Prefix] = @Prefix, [Value] = @Value, [NextNum] = @NextNum, [Company_ID] = @Company_ID, [App_ID] = @App_ID, [DocNumCreated] = @DocNumCreated WHERE [ID] = @ID">
                                    <DeleteParameters>
                                        <asp:Parameter Name="ID" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="DocType_ID" Type="Int32" />
                                        <asp:Parameter Name="Prefix" Type="String" />
                                        <asp:Parameter Name="Value" Type="String" />
                                        <asp:Parameter Name="NextNum" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="App_ID" Type="Int32" />
                                        <asp:Parameter Name="DocNumCreated" Type="DateTime" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="DocType_ID" Type="Int32" />
                                        <asp:Parameter Name="Prefix" Type="String" />
                                        <asp:Parameter Name="Value" Type="String" />
                                        <asp:Parameter Name="NextNum" Type="String" />
                                        <asp:Parameter Name="Company_ID" Type="Int32" />
                                        <asp:Parameter Name="App_ID" Type="Int32" />
                                        <asp:Parameter Name="DocNumCreated" Type="DateTime" />
                                        <asp:Parameter Name="ID" Type="Int32" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlDocType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [DCT_Id], [DCT_Name], [DCT_Description], [App_Id] FROM [ITP_S_DocumentType]"></asp:SqlDataSource>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
        </div>
</asp:Content>
