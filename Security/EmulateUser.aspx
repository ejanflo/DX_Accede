<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmulateUser.aspx.cs" Inherits="DX_WebTemplate.Security.EmulateUser" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server" Width="100%">
                <Items>
                    <dx:LayoutGroup Caption="Emulate User" ColSpan="1" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True" Font-Size="X-Large">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="User to Emulate" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="cboUser" runat="server" DataSourceID="sqlUsers" NullValueItemDisplayText="{0}" TextFormatString="{0}" ValueField="UserName" Width="100%">
                                            <Columns>
                                                <dx:ListBoxColumn FieldName="FullName" Width="300px">
                                                </dx:ListBoxColumn>
                                                <dx:ListBoxColumn FieldName="EmpCode">
                                                </dx:ListBoxColumn>
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Right">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnEmulate" runat="server" HorizontalAlign="Right" OnClick="btnEmulate_Click" Text="Emulate">
                                        </dx:ASPxButton>
                                        <asp:SqlDataSource ID="sqlUsers" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT [FullName], [UserName], [EmpCode] FROM [ITP_S_UserMaster] ORDER BY [FullName]"></asp:SqlDataSource>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                        <SettingsItems HorizontalAlign="Center" />
                    </dx:LayoutGroup>
                </Items>
            </dx:ASPxFormLayout>
        </div>
    </form>
</body>
</html>
