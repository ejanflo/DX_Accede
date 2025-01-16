<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="DX_WebTemplate.Page_Templates.Home" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
</head>
<body>
    <style>
        .conta {
           display: flex;
           flex-direction: column;
           justify-content: center;
           align-items: center;

           background: url('../Content/Images/wave.svg') no-repeat center center fixed; 
           background-size: cover; 
        }
    </style>
    <form id="form1" runat="server">
    <div class="conta">

            <dx:ASPxCardView ID="ASPxCardView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" KeyFieldName="EmployeeID" EnableTheming="True" Theme="MaterialCompact" Width="100%">
                <SettingsPager Mode="ShowAllRecords">
                </SettingsPager>
                <Settings LayoutMode="Breakpoints" ShowGroupSelector="True" ShowHeaderPanel="True" />
                <SettingsAdaptivity>
                    <BreakpointsLayoutSettings CardsPerRow="7">
                        <Breakpoints>
                            <dx:CardViewBreakpoint CardsPerRow="4" DeviceSize="Custom" MaxWidth="1400" />
                            <dx:CardViewBreakpoint CardsPerRow="3" DeviceSize="Custom" MaxWidth="900" />
                            <dx:CardViewBreakpoint CardsPerRow="2" DeviceSize="Custom" MaxWidth="700" />
                            <dx:CardViewBreakpoint CardsPerRow="1" DeviceSize="Custom" MaxWidth="500" />
                        </Breakpoints>
                    </BreakpointsLayoutSettings>
                </SettingsAdaptivity>
                <SettingsBehavior AllowSelectByCardClick="True" AllowSelectSingleCardOnly="True" EnableCustomizationWindow="True" />
                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
<SettingsPopup>
<FilterControl AutoUpdatePosition="False"></FilterControl>
</SettingsPopup>

                <SettingsSearchPanel Visible="True" />

<SettingsExport ExportSelectedCardsOnly="False"></SettingsExport>

                <Columns>
                    <dx:CardViewTextColumn FieldName="EmployeeID" ReadOnly="True" Visible="False">
                    </dx:CardViewTextColumn>
                    <dx:CardViewTextColumn FieldName="LastName" VisibleIndex="0" ReadOnly="True">
                        <PropertiesTextEdit Native="True">
                            <ReadOnlyStyle Font-Bold="True" Font-Size="Medium">
                            </ReadOnlyStyle>
                            <Style Font-Bold="True" Font-Size="Larger">
                            </Style>
                        </PropertiesTextEdit>
                    </dx:CardViewTextColumn>
                    <dx:CardViewTextColumn FieldName="FirstName" VisibleIndex="1">
                    </dx:CardViewTextColumn>
                    <dx:CardViewTextColumn FieldName="Title" VisibleIndex="2">
                    </dx:CardViewTextColumn>
                    <dx:CardViewTextColumn FieldName="TitleOfCourtesy" VisibleIndex="3">
                    </dx:CardViewTextColumn>
                    <dx:CardViewDateColumn FieldName="BirthDate" VisibleIndex="4">
                    </dx:CardViewDateColumn>
                </Columns>
                <CardLayoutProperties>
                    <Items>
                        <dx:CardViewCommandLayoutItem ColSpan="1" HorizontalAlign="Right">
                        </dx:CardViewCommandLayoutItem>
                        <dx:CardViewColumnLayoutItem ColSpan="1" ColumnName="Last Name" Caption="">
                            <CaptionStyle Font-Bold="False">
                            </CaptionStyle>
                        </dx:CardViewColumnLayoutItem>
                        <dx:CardViewColumnLayoutItem ColSpan="1" ColumnName="First Name" Caption="">
                        </dx:CardViewColumnLayoutItem>
                        <dx:EmptyLayoutItem ColSpan="1">
                        </dx:EmptyLayoutItem>
                        <dx:CardViewColumnLayoutItem ColSpan="1" ColumnName="Birth Date" Caption="">
                            <TabImage IconID="snap_date_svg_16x16">
                            </TabImage>
                        </dx:CardViewColumnLayoutItem>
                        <dx:EmptyLayoutItem ColSpan="1">
                        </dx:EmptyLayoutItem>
                        <dx:CardViewColumnLayoutItem Caption="" ColSpan="1" ColumnName="Title Of Courtesy" HorizontalAlign="Right">
                        </dx:CardViewColumnLayoutItem>
                        <dx:CardViewColumnLayoutItem Caption="" ColSpan="1" ColumnName="Title" HorizontalAlign="Right">
                        </dx:CardViewColumnLayoutItem>
                    </Items>
                </CardLayoutProperties>

                <Styles>
                    <Card Wrap="True">
                    </Card>
                    <BreakpointsCard Height="300px" Width="200px" Wrap="True" HorizontalAlign="Center" VerticalAlign="Middle">
                    </BreakpointsCard>
                </Styles>

<StylesExport>
<Card BorderSize="1" BorderSides="All"></Card>

<Group BorderSize="1" BorderSides="All"></Group>

<TabbedGroup BorderSize="1" BorderSides="All"></TabbedGroup>

<Tab BorderSize="1"></Tab>
</StylesExport>
            </dx:ASPxCardView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NWindConnectionString %>" SelectCommand="SELECT [EmployeeID], [LastName], [FirstName], [Title], [TitleOfCourtesy], [BirthDate] FROM [Employees]"></asp:SqlDataSource>

        </div>
    </form>
</body>
</html>
