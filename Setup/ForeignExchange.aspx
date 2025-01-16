<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="ForeignExchange.aspx.cs" Inherits="DX_WebTemplate.Setup.ForeignExchange" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="formForEx" runat="server">
        <Items>
            <dx:LayoutGroup Caption="Foreign Exchange Setup" ColSpan="1" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                <GroupBoxStyle>
                    <Caption Font-Bold="True" Font-Size="Large">
                    </Caption>
                </GroupBoxStyle>
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="gridForEx" runat="server" AutoGenerateColumns="False" ClientInstanceName="gridForEx" DataSourceID="sqlForEx" KeyFieldName="FE_Id" OnRowInserting="gridForEx_RowInserting" OnRowUpdating="gridForEx_RowUpdating" Width="100%">
                                    <SettingsEditing Mode="Batch">
                                    </SettingsEditing>
                                    <Settings ShowGroupPanel="True" ShowHeaderFilterButton="True" />
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <Columns>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="FE_Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn Caption="As of Date" FieldName="DateValid" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="6" ReadOnly="True">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataDateColumn FieldName="DateModified" ShowInCustomizationForm="True" VisibleIndex="8" ReadOnly="True">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsActive" ShowInCustomizationForm="True" VisibleIndex="9">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Currency" FieldName="Currency_Id" ShowInCustomizationForm="True" VisibleIndex="2">
                                            <PropertiesComboBox DataSourceID="sqlCurrency" TextField="ShortDesc" TextFormatString="{0} - {1}" ValueField="Currency_Id">
                                                <Columns>
                                                    <dx:ListBoxColumn Caption="Currency" FieldName="ShortDesc">
                                                    </dx:ListBoxColumn>
                                                    <dx:ListBoxColumn Caption="Description" FieldName="LongDesc" Width="300px">
                                                    </dx:ListBoxColumn>
                                                </Columns>
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataSpinEditColumn FieldName="PesoRate" ShowInCustomizationForm="True" VisibleIndex="4">
                                            <PropertiesSpinEdit DisplayFormatString="{0:n4}" NumberFormat="Custom">
                                            </PropertiesSpinEdit>
                                        </dx:GridViewDataSpinEditColumn>
                                        <dx:GridViewDataComboBoxColumn FieldName="CreatedBy" ShowInCustomizationForm="True" VisibleIndex="5" ReadOnly="True">
                                            <PropertiesComboBox DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn FieldName="ModifiedBy" ShowInCustomizationForm="True" VisibleIndex="7" ReadOnly="True">
                                            <PropertiesComboBox DataSourceID="sqlUser" TextField="FullName" ValueField="EmpCode">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                    </Columns>
                                </dx:ASPxGridView>
                                <asp:SqlDataSource ID="sqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [EmpCode], [FullName], [UserName], [IsActive] FROM [ITP_S_UserMaster] ORDER BY [FullName]"></asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlForEx" runat="server" ConflictDetection="CompareAllValues" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_S_ForeignExch] WHERE [FE_Id] = @original_FE_Id AND (([Currency_Id] = @original_Currency_Id) OR ([Currency_Id] IS NULL AND @original_Currency_Id IS NULL)) AND (([DateValid] = @original_DateValid) OR ([DateValid] IS NULL AND @original_DateValid IS NULL)) AND (([PesoRate] = @original_PesoRate) OR ([PesoRate] IS NULL AND @original_PesoRate IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL))" InsertCommand="INSERT INTO [ITP_S_ForeignExch] ([Currency_Id], [DateValid], [PesoRate], [CreatedBy], [DateCreated], [ModifiedBy], [DateModified], [IsActive]) VALUES (@Currency_Id, @DateValid, @PesoRate, @CreatedBy, @DateCreated, @ModifiedBy, @DateModified, @IsActive)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT * FROM [ITP_S_ForeignExch] ORDER BY [DateValid] DESC, [Currency_Id]" UpdateCommand="UPDATE [ITP_S_ForeignExch] SET [Currency_Id] = @Currency_Id, [DateValid] = @DateValid, [PesoRate] = @PesoRate, [CreatedBy] = @CreatedBy, [DateCreated] = @DateCreated, [ModifiedBy] = @ModifiedBy, [DateModified] = @DateModified, [IsActive] = @IsActive WHERE [FE_Id] = @original_FE_Id AND (([Currency_Id] = @original_Currency_Id) OR ([Currency_Id] IS NULL AND @original_Currency_Id IS NULL)) AND (([DateValid] = @original_DateValid) OR ([DateValid] IS NULL AND @original_DateValid IS NULL)) AND (([PesoRate] = @original_PesoRate) OR ([PesoRate] IS NULL AND @original_PesoRate IS NULL)) AND (([CreatedBy] = @original_CreatedBy) OR ([CreatedBy] IS NULL AND @original_CreatedBy IS NULL)) AND (([DateCreated] = @original_DateCreated) OR ([DateCreated] IS NULL AND @original_DateCreated IS NULL)) AND (([ModifiedBy] = @original_ModifiedBy) OR ([ModifiedBy] IS NULL AND @original_ModifiedBy IS NULL)) AND (([DateModified] = @original_DateModified) OR ([DateModified] IS NULL AND @original_DateModified IS NULL)) AND (([IsActive] = @original_IsActive) OR ([IsActive] IS NULL AND @original_IsActive IS NULL))">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_FE_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Currency_Id" Type="Int32" />
                                        <asp:Parameter Name="original_DateValid" Type="DateTime" />
                                        <asp:Parameter Name="original_PesoRate" Type="Decimal" />
                                        <asp:Parameter Name="original_CreatedBy" Type="String" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="String" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Currency_Id" Type="Int32" />
                                        <asp:Parameter Name="DateValid" Type="DateTime" />
                                        <asp:Parameter Name="PesoRate" Type="Decimal" />
                                        <asp:Parameter Name="CreatedBy" Type="String" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="ModifiedBy" Type="String" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Currency_Id" Type="Int32" />
                                        <asp:Parameter Name="DateValid" Type="DateTime" />
                                        <asp:Parameter Name="PesoRate" Type="Decimal" />
                                        <asp:Parameter Name="CreatedBy" Type="String" />
                                        <asp:Parameter Name="DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="ModifiedBy" Type="String" />
                                        <asp:Parameter Name="DateModified" Type="DateTime" />
                                        <asp:Parameter Name="IsActive" Type="Boolean" />
                                        <asp:Parameter Name="original_FE_Id" Type="Int32" />
                                        <asp:Parameter Name="original_Currency_Id" Type="Int32" />
                                        <asp:Parameter Name="original_DateValid" Type="DateTime" />
                                        <asp:Parameter Name="original_PesoRate" Type="Decimal" />
                                        <asp:Parameter Name="original_CreatedBy" Type="String" />
                                        <asp:Parameter Name="original_DateCreated" Type="DateTime" />
                                        <asp:Parameter Name="original_ModifiedBy" Type="String" />
                                        <asp:Parameter Name="original_DateModified" Type="DateTime" />
                                        <asp:Parameter Name="original_IsActive" Type="Boolean" />
                                    </UpdateParameters>
                                </asp:SqlDataSource>
                                <asp:SqlDataSource ID="sqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Currency]"></asp:SqlDataSource>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
        </div>
</asp:Content>
