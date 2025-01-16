<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="ErrorAccess.aspx.cs" Inherits="DX_WebTemplate.ErrorAccess" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <dx:ASPxPopupControl ID="PopupControl" runat="server" ShowOnPageLoad="true" ClientInstanceName="modal" HeaderText="Access Denied" CloseOnEscape="false" CloseAction="None" ShowFooter="true">
            <ContentStyle Paddings-Padding="0" Paddings-PaddingTop="12" >
<Paddings Padding="0px" PaddingTop="12px"></Paddings>
            </ContentStyle>
            <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" MaxWidth="700px" />
            <ContentCollection>
                <dx:PopupControlContentControl>
                    <dx:ASPxFormLayout runat="server" ID="formLayout">
                        <SettingsAdaptivity AdaptivityMode="SingleColumnWindowLimit" SwitchToSingleColumnAtWindowInnerWidth="576" />
                        <Items>
                            <dx:LayoutGroup Caption="Invalid Page Access" GroupBoxDecoration="HeadingLine" Paddings-Padding="0" Paddings-PaddingTop="10">
<Paddings Padding="0px" PaddingTop="10px"></Paddings>

                                <GroupBoxStyle>
                                    <Caption Font-Bold="true" Font-Size="16" CssClass="groupCaption" />
                                </GroupBoxStyle>
                                <Items>
                                    <dx:LayoutItem Caption="" Width="100%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer>
                                                <dx:ASPxLabel ID="formLayout_E1" runat="server" Font-Size="Large" Text="I'm sorry, but it appears that you do not have access to the requested page. Please ensure you have the necessary permissions or contact the administrator for further assistance.">
                                                </dx:ASPxLabel>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:EmptyLayoutItem ColSpan="1">
                                    </dx:EmptyLayoutItem>
                                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="None">
                                        <Items>
                                            <dx:LayoutItem Caption="Page you want to access" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxLabel ID="lblPage" runat="server" Font-Bold="True" Font-Size="Medium">
                                                        </dx:ASPxLabel>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings Location="Top" />
                                                <CaptionStyle Font-Size="Medium">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                            <dx:LayoutItem Caption="Role(s) Needed" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxLabel ID="lblRole" runat="server" Font-Bold="True" Font-Size="Medium">
                                                        </dx:ASPxLabel>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings Location="Top" />
                                                <CaptionStyle Font-Size="Medium">
                                                </CaptionStyle>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:ASPxFormLayout>
                </dx:PopupControlContentControl>
            </ContentCollection>
            <FooterTemplate>
                <dx:ASPxFormLayout runat="server" ID="footerFormLayout" Width="100%" CssClass="clearPaddings">
                    <Styles LayoutItem-CssClass="clearPaddings" LayoutGroup-CssClass="clearPaddings" />
                    <Items>
                        <dx:LayoutGroup GroupBoxDecoration="None">
                            <Paddings Padding="0" />
                            <Items>
                                <dx:LayoutItem ShowCaption="False" HorizontalAlign="Right">
                                    <LayoutItemNestedControlCollection>
                                        <dx:LayoutItemNestedControlContainer>
                                            <div class="buttonsContainer">
                                                <%--<dx:ASPxButton ID="btnSubmit" runat="server" CssClass="submitButton" Text="Submit" Width="100">
                                                </dx:ASPxButton>--%>
                                                <dx:ASPxButton ID="btnCancel" runat="server" CssClass="cancelButton" Text="Back to Home" AutoPostBack="false" Width="100" OnClick="btnCancel_Clicked">
                                                    <%--<ClientSideEvents Click="onBtnCancelClick" />--%>
                                                </dx:ASPxButton>
                                            </div>
                                        </dx:LayoutItemNestedControlContainer>
                                    </LayoutItemNestedControlCollection>
                                </dx:LayoutItem>
                            </Items>
                        </dx:LayoutGroup>
                    </Items>
                </dx:ASPxFormLayout>
            </FooterTemplate>
        </dx:ASPxPopupControl>
</asp:Content>
