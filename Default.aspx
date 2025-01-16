<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DX_WebTemplate.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
<link href="../styles/bootstrap.min.css" rel="stylesheet">
    <link href="../styles/product.css" rel="stylesheet">
    <script type="text/javascript">
       
        document.addEventListener("keydown", function (e) {
            var keyCode = e.keyCode || e.which;
            if (keyCode === 113) { // F4 key
                e.preventDefault();
                tbToolbarSearch.SetFocus();
            }
        })

        function OnGetRowValues(value) {
            window.open(value, "_blank");
            //window.location.href = value;
        }  

        function OnCardClick(s, e) {
            var cardKey = e.visibleIndex;
            cardTiles.GetCardValues(cardKey, "URL", OnGetRowValues);
        }

        function OnInit(s, e) {
            fabUp.SetActionContext("GoUpContext", true);
        }
        function OnActionItemClick(s, e) {
            if (e.actionName === "GoUp") {
                //window.scrollTo({ top: 0, behavior: 'smooth' });
                var my_element = document.getElementById("top");

                my_element.scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                    inline: "nearest"
                });

            }
        }
        function OnTextBoxKeyPress(s, e) {
            var keyCode = e.htmlEvent.keyCode || e.htmlEvent.which;
            if (keyCode === 115) { // F4 key
                e.htmlEvent.preventDefault();
                textBox2.SetFocus();
            }
        }
    </script>

    <style>
        #ASPxSplitter1_Content_ContentSplitter_MainContent_formTile_cardTiles_DXMainTable
        {
            background-color:#EBF8FF;
            
           /*background: url('../Content/Images/polygon.svg') no-repeat center center fixed;*/ 
           background-size: cover; 
        }
        .dxflNestedControlCell_MaterialCompact {
            font-size:larger;
            
        }
        .dxIcon_setup_properties_svg_gray_32x32 {
            opacity: 0.4;
            filter: saturate(110);
        }
    </style>
    
    <dx:ASPxFloatingActionButton ID="fabUp" runat="server" ClientInstanceName="fabUp" EnableTheming="True" Theme="Office2010Black">
        <ClientSideEvents Init="OnInit" ActionItemClick="OnActionItemClick" />
        <Items>
            <dx:FABAction ActionName="GoUp" ContextName="GoUpContext" Text="Scroll to Top">
                <Image IconID="iconbuilder_actions_arrow3up_svg_white_16x16">
                </Image>
            </dx:FABAction>
        </Items>
    </dx:ASPxFloatingActionButton>
    
    <div class="conta">
        <a href="#" id="top"></a>
        <dx:ASPxFormLayout ID="formTile" runat="server" Width="100%">
            <Items>
                <dx:LayoutGroup Caption="Hello there!" ColSpan="1" GroupBoxDecoration="HeadingLine" Name="layoutGroupMain">
                    <GroupBoxStyle>
                        <Caption Font-Bold="True" Font-Size="X-Large" Paddings-PaddingTop="10px">
                        <%--<Paddings PaddingLeft="47%"></Paddings>--%>
<Paddings PaddingTop="10px"></Paddings>
                        </Caption>
                    </GroupBoxStyle>
                    <Items>
                        <dx:LayoutItem Caption="" ColSpan="1">
                            <LayoutItemNestedControlCollection>
                                <dx:LayoutItemNestedControlContainer runat="server">
                                    <dx:ASPxCardView ID="cardTiles" runat="server" AutoGenerateColumns="False" DataSourceID="sqlTileGroup" EnableTheming="True" KeyFieldName="ID" Theme="MaterialCompact" Width="100%" ClientInstanceName="cardTiles" OnBeforePerformDataSelect="cardTiles_BeforePerformDataSelect" OnHtmlCardPrepared="cardTiles_HtmlCardPrepared" OnCustomButtonInitialize="cardTiles_CustomButtonInitialize">
                                        <ClientSideEvents CardClick="OnCardClick" /> <%--  SelectionChanged="OnCardSelectionChanged"  --%>
                                        <SettingsPager Mode="ShowAllRecords">
                                        </SettingsPager>
                                        <Settings LayoutMode="Breakpoints" ShowGroupSelector="True" GroupFormat="{1}" GroupFormatForMergedGroup="{1}" GroupFormatForMergedGroupRow="{0}" MergedGroupSeparator="" ShowSummaryPanel="True" />
                                        <SettingsAdaptivity>
                                            <BreakpointsLayoutSettings CardsPerRow="9">
                                                <Breakpoints>
                                                    <dx:CardViewBreakpoint CardsPerRow="7" DeviceSize="Custom" MaxWidth="1600" />
                                                    <dx:CardViewBreakpoint CardsPerRow="7" DeviceSize="Custom" MaxWidth="1550" />
                                                    <dx:CardViewBreakpoint DeviceSize="Custom" MaxWidth="1450" />
                                                    <dx:CardViewBreakpoint CardsPerRow="5" DeviceSize="Custom" MaxWidth="1230" />
                                                    <dx:CardViewBreakpoint CardsPerRow="4" DeviceSize="Custom" MaxWidth="1060" />
                                                    <dx:CardViewBreakpoint CardsPerRow="3" DeviceSize="Custom" MaxWidth="900" />
                                                    <dx:CardViewBreakpoint CardsPerRow="2" DeviceSize="Custom" MaxWidth="720" />
                                                    <dx:CardViewBreakpoint CardsPerRow="1" DeviceSize="Custom" MaxWidth="530" />
                                                </Breakpoints>
                                            </BreakpointsLayoutSettings>
                                        </SettingsAdaptivity>
                                        <SettingsBehavior AllowSelectByCardClick="True" AllowSelectSingleCardOnly="True" EnableCardHotTrack="True" EnableCustomizationWindow="True" AllowGroup="False" />
                                        <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                        <SettingsPopup>
                                            <FilterControl AutoUpdatePosition="False">
                                            </FilterControl>
                                        </SettingsPopup>
                                        <SettingsSearchPanel CustomEditorID="tbToolbarSearch" Visible="True" />
                                        <SettingsExport ExportSelectedCardsOnly="False">
                                        </SettingsExport>
                                        <Columns>
                                            <dx:CardViewTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False">
                                                <HeaderStyle Font-Bold="True" />
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn FieldName="Subtitle" ShowInCustomizationForm="True" VisibleIndex="1">
                                                <Settings AllowSort="False" />
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn FieldName="App_Name" ShowInCustomizationForm="True" VisibleIndex="4">
                                                <Settings AllowSort="False" />
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn FieldName="Title" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                <PropertiesTextEdit>
                                                    <Style Font-Bold="True" Font-Size="Larger">
                                                    </Style>
                                                </PropertiesTextEdit>
                                                <Settings AllowFilterBySearchPanel="True" AllowSort="False" FilterMode="DisplayText" />
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn FieldName="GroupName" GroupIndex="1" ShowInCustomizationForm="True" SortIndex="1" SortOrder="Ascending" VisibleIndex="5">
                                                <PropertiesTextEdit DisplayFormatString="d">
                                                </PropertiesTextEdit>
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewComboBoxColumn FieldName="Sort" GroupIndex="0" ShowInCustomizationForm="True" SortIndex="0" SortOrder="Ascending" VisibleIndex="6">
                                                <PropertiesComboBox DataSourceID="sqlSortBlank" DisplayFormatString="g" TextField="Blank" ValueField="Sort">
                                                    <Style ForeColor="White">
                                                    </Style>
                                                </PropertiesComboBox>
                                                <Settings AllowSort="True" />
                                            </dx:CardViewComboBoxColumn>
                                            <dx:CardViewTextColumn FieldName="URL" ShowInCustomizationForm="True" VisibleIndex="7">
                                                <PropertiesTextEdit MaxLength="100">
                                                </PropertiesTextEdit>
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewHyperLinkColumn FieldName="Value" ShowInCustomizationForm="True" VisibleIndex="2">
                                                <PropertiesHyperLinkEdit NavigateUrlFormatString="">
                                                    <Style Font-Bold="False" Font-Size="XX-Large">
                                                    </Style>
                                                </PropertiesHyperLinkEdit>
                                                <Settings AllowSort="False" />
                                            </dx:CardViewHyperLinkColumn>
                                            <dx:CardViewTextColumn FieldName="Icon" ShowInCustomizationForm="True" VisibleIndex="8">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewHyperLinkColumn FieldName="Information" ShowInCustomizationForm="True" VisibleIndex="3">
                                            </dx:CardViewHyperLinkColumn>
                                            <dx:CardViewButtonEditColumn Caption="Test" ShowInCustomizationForm="True" VisibleIndex="9">
                                                <PropertiesButtonEdit>
                                                    <ButtonEditEllipsisImage IconID="businessobjects_bo_skull_svg_gray_32x32">
                                                    </ButtonEditEllipsisImage>
                                                </PropertiesButtonEdit>
                                            </dx:CardViewButtonEditColumn>
                                        </Columns>
                                        <Toolbars>
                                            <dx:CardViewToolbar>
                                                <Items>
                                                    <dx:CardViewToolbarItem BeginGroup="True" Command="Refresh" Visible="False">
                                                    </dx:CardViewToolbarItem>
                                                    <dx:CardViewToolbarItem BeginGroup="True" Command="ShowHeaderPanel" Visible="False">
                                                    </dx:CardViewToolbarItem>
                                                    <dx:CardViewToolbarItem Alignment="Right" BeginGroup="True">
                                                        <Template>
                                                            <dx:ASPxButtonEdit ID="tbToolbarSearch" ClientInstanceName="tbToolbarSearch" runat="server" Height="100%" NullText="Search Tile..." Theme="iOS" Width="400px" HelpText="Shortcut: Press F2 to focus on search" HelpTextSettings-Position="Top">
                                                                <Buttons>
                                                                    <dx:SpinButtonExtended Image-IconID="find_find_16x16gray">
                                                                    </dx:SpinButtonExtended>
                                                                </Buttons>
                                                            </dx:ASPxButtonEdit>
                                                        </Template>
                                                    </dx:CardViewToolbarItem>
                                                </Items>
                                            </dx:CardViewToolbar>
                                        </Toolbars>
                                        <CardLayoutProperties ColCount="2" ColumnCount="2">
                                            <Items>
                                                <dx:CardViewColumnLayoutItem Caption="" ColSpan="2" ColumnName="Title" ColumnSpan="2" Height="50px">
                                                    <CaptionStyle Font-Bold="True">
                                                    </CaptionStyle>
                                                </dx:CardViewColumnLayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="1" Height="80px" Visible="False">
                                                </dx:EmptyLayoutItem>
                                                <dx:CardViewCommandLayoutItem ColSpan="1">
                                                    <CustomButtons>
                                                        <dx:CardViewCustomCommandButton ID="btnIcon" Text=" ">
                                                           <%-- <Image IconID="setup_properties_svg_gray_32x32">
                                                            </Image>--%>
                                                        </dx:CardViewCustomCommandButton>
                                                    </CustomButtons>
                                                </dx:CardViewCommandLayoutItem>
                                                <dx:CardViewColumnLayoutItem Caption="" ColSpan="1" ColumnName="Value" Height="85px" HorizontalAlign="Right">
                                                </dx:CardViewColumnLayoutItem>
                                                <dx:CardViewColumnLayoutItem Caption="" ColSpan="2" ColumnName="App_Name" HorizontalAlign="Right" ColumnSpan="2">
                                                    <NestedControlStyle Font-Bold="False">
                                                    </NestedControlStyle>
                                                </dx:CardViewColumnLayoutItem>
                                            </Items>
                                        </CardLayoutProperties>
                                        <Styles>
                                            <Card Wrap="True">
                                            </Card>
                                            <BreakpointsCard CssClass="hyperlink" Font-Bold="False" Height="180px" HorizontalAlign="Center" VerticalAlign="Middle" Width="175px" Wrap="True">
                                            </BreakpointsCard>
                                            <CardHotTrack BackColor="#F8F8F8" Cursor="pointer">
                                            </CardHotTrack>
                                        </Styles>
                                        <StylesExport>
                                            <Card BorderSides="All" BorderSize="1">
                                            </Card>
                                            <Group BorderSides="All" BorderSize="1">
                                            </Group>
                                            <TabbedGroup BorderSides="All" BorderSize="1">
                                            </TabbedGroup>
                                            <Tab BorderSize="1">
                                            </Tab>
                                        </StylesExport>
                                        <FormatConditions>
                                            <dx:CardViewFormatConditionTopBottom FieldName="LastName" Format="BoldText" Rule="TopItems" Threshold="10">
                                            </dx:CardViewFormatConditionTopBottom>
                                        </FormatConditions>
                                        <BackgroundImage ImageUrl="~/Content/Images/zig-zag.svg" />
                                    </dx:ASPxCardView>
                                </dx:LayoutItemNestedControlContainer>
                            </LayoutItemNestedControlCollection>
                        </dx:LayoutItem>
                    </Items>
                </dx:LayoutGroup>
            </Items>
        </dx:ASPxFormLayout>
            <asp:SqlDataSource ID="sqlTiles" runat="server" ConnectionString="<%$ ConnectionStrings:NWindConnectionString %>" SelectCommand="SELECT [EmployeeID], [LastName], [FirstName], [Title], [TitleOfCourtesy], [BirthDate] FROM [Employees]"></asp:SqlDataSource>


        <asp:SqlDataSource ID="sqlTileGroup" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_AGA_I_UserTiles] WHERE (([Tile_IsActive] = @Tile_IsActive) AND ([UserId] = @UserId))">
            <SelectParameters>
                <asp:Parameter DefaultValue="true" Name="Tile_IsActive" Type="Boolean" />
                <asp:SessionParameter Name="UserId" SessionField="MasterUserID" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlGroup" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [AGA_S_TileGroup] WHERE ([isActive] = @isActive) ORDER BY [Sort]">
            <SelectParameters>
                <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqlSortBlank" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT DISTINCT Sort, '' AS Blank FROM vw_AGA_I_Tiles"></asp:SqlDataSource>


    </div>
    <script>
        var myDate = new Date();
        var hrs = myDate.getHours();

        var greet;

        if (hrs < 12)
            greet = 'Good Morning';
        else if (hrs >= 12 && hrs <= 17)
            greet = 'Good Afternoon';
        else if (hrs >= 17 && hrs <= 24)
            greet = 'Good Evening';

        document.getElementById('greetings').innerHTML = '<b>' + greet + '</b>';
    </script>
    
</asp:Content>