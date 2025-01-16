<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="AccedeUtilities.aspx.cs" Inherits="DX_WebTemplate.AccedeUtilities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
            <script>
        function OnCustomButtonClick(s, e) {
            expenseGrid.PerformCallback(s.GetRowKey(e.visibleIndex) + "|" + e.buttonID);
            if (e.buttonID != "btnPrint") {
                loadPanel.Show();
            }           
        }

        function onToolbarItemClick(s, e) { 
            if (e.item.name === "newReport") {
                window.location.href = "AccedeExpenseReportAdd.aspx";
            }
            //} else if (e.item.name === "print") {
            //    /*window.location.href = "WebClearPrintingSample.aspx";*/
            //    window.open('WebClearPrintingSample.aspx', '_blank');
            //}
        }
            </script>
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Font-Bold="False" Height="144px" Width="100%" OnInit="ASPxFormLayout1_Init">
        <Items>
            <dx:LayoutGroup Caption="ACCEDE Utilities" ColSpan="1" GroupBoxDecoration="HeadingLine" Width="100%" ColCount="2" ColumnCount="2">
                <CellStyle Font-Bold="False">
                </CellStyle>
                <Items>
                    <dx:LayoutGroup ColSpan="2" GroupBoxDecoration="None" ColCount="4" ColumnCount="4" ColumnSpan="2" HorizontalAlign="Right">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="0px">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="saveBTN" runat="server" BackColor="#006838" ClientInstanceName="saveBTN" OnClick="saveBTN_Click" Text="Save">
                                            <ClientSideEvents Click="function(s, e) {
	loadPanel.Show();
}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right" Width="0px">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="ASPxFormLayout1_E6" runat="server" BackColor="White" ForeColor="#878787" Text="Back">
                                            <ClientSideEvents Click="function(s, e) {
	window.open(&quot;Default.aspx&quot;, &quot;_self&quot;);
}" />
                                            <Border BorderColor="#878787" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Change VAT &amp; EWT" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="Box" Width="50%">
                        <Items>
                            <dx:LayoutItem Caption="VAT" ColSpan="1" Width="0px">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="vatTB" runat="server" ClientInstanceName="vatTB" Increment="0.01">
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="EWT" ColSpan="1" Width="0px">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="ewtTB" runat="server" ClientInstanceName="ewtTB" Increment="0.01">
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                        <ParentContainerStyle Font-Size="Small">
                        </ParentContainerStyle>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Change EWT" ColSpan="1" GroupBoxDecoration="None" Width="100%">
                    </dx:LayoutGroup>
                </Items>
                <ParentContainerStyle Font-Bold="True" Font-Size="X-Large">
                </ParentContainerStyle>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
    <dx:ASPxLoadingPanel ID="loadPanel" runat="server" Text="Redirecting&amp;hellip;" Theme="MaterialCompact" ClientInstanceName="loadPanel" Modal="True">
    </dx:ASPxLoadingPanel>
        <asp:SqlDataSource ID="sqlName" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [EmpCode] FROM [ITP_S_UserMaster]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpenseType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseType] ORDER BY [Description]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [WASSId], [CompanyDesc], [CompanyShortName] FROM [CompanyMaster] WHERE ([WASSId] IS NOT NULL) ORDER BY [CompanyDesc]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([User_ID] = @User_ID) ORDER BY [ID] DESC">
            <SelectParameters>
                <asp:SessionParameter Name="User_ID" SessionField="userID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlVAT" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_M_Computation]"></asp:SqlDataSource>
</asp:Content>
