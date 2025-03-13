<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeBehind="RFPEditPage.aspx.cs" Inherits="DX_WebTemplate.RFPEditPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
      <script>
          //function OnInit(s, e) {
          //    fab.SetActionContext("CancelContext", true);
          //    //AttachEvents();
          //}
          function OnActionItemClick(s, e) {
              if (e.actionName === "Cancel") {
                  history.back()
              }
          }

          function onTravelClick() {
              var layoutControl = window["formRFP"];
              if (layoutControl) {
                  var layoutItem = layoutControl.GetItemByName("LDOT");
                  var layoutItem2 = layoutControl.GetItemByName("TravType");
                  var layoutItem3 = layoutControl.GetItemByName("ClassType");
                  if (layoutItem) {

                      if (rdButton_Trav.GetValue() == true) {
                          layoutItem.SetVisible(true);
                          layoutItem2.SetVisible(true);
                          drpdown_currency.PerformCallback(drpdown_TravType.GetValue());
                          drpdwn_FAPWF.PerformCallback(drpdown_TravType.GetValue() + "|" + drpdown_CTCompany.GetValue() + "|" + spinEdit_Amount.GetValue() + "|" + drpdown_classification.GetValue());
                          layoutItem3.SetVisible(false);
                      } else {
                          layoutItem.SetVisible(false);
                          layoutItem2.SetVisible(false);
                          drpdown_currency.PerformCallback("");
                          drpdwn_FAPWF.PerformCallback("");
                          layoutItem3.SetVisible(true);
                      }


                  }
              }
          }

          function ifComp_is_DLI() {
              var layoutControl = window["formRFP"];
              if (layoutControl) {
                  var layoutItem = layoutControl.GetItemByName("WBS");
                  if (layoutItem) {

                      if (drpdown_Company.GetValue() == "5") {
                          layoutItem.SetVisible(true);
                      } else {
                          layoutItem.SetVisible(false);
                      }


                  }
              }
          }

          function ifTranType_is_CA() {
              var layoutControl = window["formRFP"];
              if (layoutControl) {
                  var layoutItem = layoutControl.GetItemByName("PLD");
                  if (layoutItem) {

                      if (drpdown_TranType.GetValue() == "1") {
                          layoutItem.SetVisible(true);
                      } else {
                          layoutItem.SetVisible(false);
                      }


                  }
              }
          }

          function onTravTypeChanged(trav) {
              drpdown_currency.PerformCallback(trav);
              drpdwn_FAPWF.PerformCallback(drpdown_TravType.GetValue() + "|" + drpdown_CTCompany.GetValue() + "|" + spinEdit_Amount.GetValue() + "|" + drpdown_classification.GetValue());
          }

          function onPayToVendorTranType() {
              if (drpdown_TranType.GetValue() != 3) {
                  $.ajax({
                      type: "POST",
                      url: "RFPCreationPage.aspx/PayeeDefaultValueAJAX",
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      data: JSON.stringify({}),
                      success: function (response) {
                          // Update the description text box with the response value
                          if (response) {
                              drpdown_Payee.SetValue(response.d);
                              //drpdown_Payee.SetReadOnly(true);
                          }
                      },
                      error: function (xhr, status, error) {
                          console.log("Error:", error);
                      }
                  });
              } else {
                  drpdown_Payee.SetValue("");
                  drpdown_Payee.SetReadOnly(false);
              }
          }

          function onAmountChanged(pay) {
              var amount = spinEdit_Amount.GetValue() != null ? spinEdit_Amount.GetValue() : 0;
              var comp_id = drpdown_Company.GetValue();
              var payMethod = pay != null ? pay : 0;
              var payMethodTxt = drpdown_PayMethod.GetText();
              console.log(comp_id);
              //$.ajax({
              //    type: "POST",
              //    url: "RFPEditPage.aspx/CheckMinAmountAJAX",
              //    contentType: "application/json; charset=utf-8",
              //    dataType: "json",
              //    data: JSON.stringify({
              //        comp_id: comp_id,
              //        payMethod: payMethod
              //    }),
              //    success: function (response) {
              //        // Update the description text box with the response value
              //        if (response.d != 0 && amount > response.d) {
              //            warning_txt.SetText("Amount entered is beyond " + payMethodTxt + " limit. Please choose different payment method.");
              //            PetCashPopupSave.Show();
              //            console.log(response.d);
              //            drpdown_PayMethod.SetValue("");
              //            drpdown_PayMethod.Validate();
              //        }
              //    },
              //    error: function (xhr, status, error) {
              //        console.log("Error:", error);
              //    }
              //});

              if (comp_id != null) {
                  $.ajax({
                      type: "POST",
                      url: "RFPEditPage.aspx/MaxAmountAJAX",
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      data: JSON.stringify({
                          comp_id: comp_id
                      }),
                      success: function (response) {
                          //Update the description text box with the response value
                          if (response.d != 0 && amount > response.d) {
                              //warning_txt.SetText("Amount entered is beyond company's system limit. Please use SAP Concur instead or continue with this transaction.");
                              //PetCashPopupSave.Show();
                              //spinEdit_Amount.SetValue("");
                          }

                          console.log(response.d);
                          if (response.d == "0") {
                              console.log(response.d);
                              //warning_txt.SetText("Error verifying company amount limit.");
                              //PetCashPopupSave.Show();
                              //spinEdit_Amount.SetValue("");
                          }
                      },
                      error: function (xhr, status, error) {
                          console.log("Error:", error);
                      }
                  });
              }

              FAPWFGrid.PerformCallback(drpdown_TravType.GetValue() + "|" + drpdown_CTCompany.GetValue() + "|" + spinEdit_Amount.GetValue() + "|" + drpdown_classification.GetValue());
              drpdwn_FAPWF.PerformCallback(drpdown_TravType.GetValue() + "|" + drpdown_CTCompany.GetValue() + "|" + spinEdit_Amount.GetValue() + "|" + drpdown_classification.GetValue());
              drpdwn_FAPWF.SetSelectedIndex(0);
              //drpdown_WF.PerformCallback(amount + "|" + comp_id);
             // WFSequenceGrid.PerformCallback(amount + "|" + comp_id);
              //drpdown_WF.SetSelectedIndex(0);

          }

          function onPayMethodChanged(pay) {
              onAmountChanged(pay);
          }

          function saveSubmit() {

          }

          function OnWFChanged() {
              WFSequenceGrid.PerformCallback();
          }

          function onDeptChanged() {

              drpdown_WF.PerformCallback();
              //drpdwn_FAPWF.PerformCallback();
          }

          function onCTDeptChanged() {
              var dept_id = drpdown_CTDepartment.GetValue();
              drpdown_CostCenter.PerformCallback(dept_id);
              //$.ajax({
              //    type: "POST",
              //    url: "RFPCreationPage.aspx/CostCenterUpdateField",
              //    contentType: "application/json; charset=utf-8",
              //    dataType: "json",
              //    data: JSON.stringify({ dept_id: dept_id }),
              //    success: function (response) {
              //        // Update the description text box with the response value
              //        if (response) {
              //            txtbox_costCenter.SetValue(response.d);
              //            txtbox_costCenter.Validate();
              //        }
              //    },
              //    error: function (xhr, status, error) {
              //        console.log("Error:", error);
              //    }
              //});
          }

          var WFisExpanded = false;
          function UpdateRFPMain(status) {
              LoadingPanel.Show();
              var Comp_ID = drpdown_Company.GetValue();
              var Dept_ID = drpdown_Department.GetValue();
              var CTComp_ID = drpdown_CTCompany.GetValue();
              var CTDept_ID = drpdown_CTDepartment.GetValue();
              var Paymethod = drpdown_PayMethod.GetValue();
              var tranType = drpdown_TranType.GetValue();
              var isTrav = rdButton_Trav.GetValue();
              var costCenter = drpdown_CostCenter.GetValue();
              var io = txtbox_IO.GetValue() != null ? txtbox_IO.GetValue() : "";
              var payee = drpdown_Payee.GetValue();
              var lastDay = dateEdit_lastDayTran.GetValue() != null ? dateEdit_lastDayTran.GetValue() : "";
              var amount = spinEdit_Amount.GetValue();
              var purpose = memo_Purpose.GetValue();
              var wf_id = drpdown_WF.GetValue();
              var exp_id = drpdown_ExpID.GetValue();
              var fap = drpdwn_FAPWF.GetValue();
              var wbs = txtbox_WBS.GetValue() != null ? txtbox_WBS.GetValue() : "";
              var travType = drpdown_TravType.GetValue() != null ? drpdown_TravType.GetValue() : "";
              var classification = drpdown_classification.GetValue() != null ? drpdown_classification.GetValue() : "";
              var curr = drpdown_currency.GetValue();
              var compLoc = drpdown_CompLocation.GetValue();
              //var exp_cat = expCat.GetValue() != null ? expCat.GetValue() : "";
              //console.log('This: ' + exp_cat)
              var pld = PLD.GetValue() != null ? PLD.GetValue() : "";
              console.log(pld);
              //var remarks = txtbox_remarks.GetValue() != null ? txtbox_remarks.GetValue() : "";

              if (wf_id == null || fap == null) {
                  var layoutControl = window["formRFP"];
                  if (layoutControl) {
                      var layoutItem = layoutControl.GetItemByName("WFLayout");
                      if (layoutItem) {
                          console.log(WFisExpanded);
                          WFisExpanded = true;
                          layoutItem.SetVisible(WFisExpanded);
                          WFbtnToggle.SetText(WFisExpanded ? 'Hide' : 'Show');
                          LoadingPanel.Hide();
                          drpdown_WF.Validate();
                          drpdwn_FAPWF.Validate();
                      }
                  }
                  
              } else {
                  $.ajax({
                      type: "POST",
                      url: "RFPEditPage.aspx/UpdateRFPMainAjax",
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      data: JSON.stringify({
                          Comp_ID: Comp_ID,
                          Dept_ID: Dept_ID,
                          Paymethod: Paymethod,
                          tranType: tranType,
                          isTrav: isTrav,
                          costCenter: costCenter,
                          costCenter: costCenter,
                          io: io,
                          payee: payee,
                          lastDay: lastDay,
                          amount: amount,
                          purpose: purpose,
                          wf_id: wf_id,
                          status: status,
                          exp_id: exp_id,
                          fap: fap,
                          wbs: wbs,
                          //exp_cat: exp_cat,
                          pld: pld,
                          //remarks: remarks
                          curr: curr,
                          travType: travType,
                          classification: classification,
                          CTComp_ID: CTComp_ID,
                          CTDept_ID: CTDept_ID,
                          compLoc: compLoc
                      }),
                      success: function (response) {
                          // Update the description text box with the response value
                          if (response.d == 0) {
                              LoadingPanel.Hide();
                              Swal.fire({
                                  title: 'Error!',
                                  text: 'There is an error saving document!',
                                  icon: 'error',
                                  showCancelButton: false,
                                  confirmButtonColor: '#3085d6',
                                  cancelButtonColor: '#d33',
                                  confirmButtonText: 'OK',
                                  allowOutsideClick: false
                              }).then((result) => {
                                  if (result.isConfirmed) {
                                      location.reload();
                                  }
                              });

                          } else {
                              //Swal.fire({
                              //    title: 'Success!',
                              //    text: 'RFP successfully created!',
                              //    icon: 'success',
                              //    showCancelButton: false,
                              //    confirmButtonColor: '#3085d6',
                              //    cancelButtonColor: '#d33',
                              //    confirmButtonText: 'OK',
                              //    allowOutsideClick: false
                              //}).then((result) => {
                              //    if (result.isConfirmed) {
                              //        window.location.href = "RFPPage.aspx";
                              //    }
                              //});
                              //LoadingPanel.Hide();

                              LoadingPanel.SetText('RFP Successfully updated. Redirecting&hellip;');
                              LoadingPanel.Show();
                              window.location.href = 'RFPPage.aspx';
                          }
                      },
                      error: function (xhr, status, error) {
                          console.log("Error:", error);
                      }
                  });
              }

              
          }

          var isExpanded = false;
          function isToggle() {

              //isExpanded = !isExpanded;
              //var layoutControl = window["formRFP"];
              //if (layoutControl) {
              //    var layoutItem = layoutControl.GetItemByName("collapsibleGroup");
              //    if (layoutItem) {
              //        console.log(isExpanded);
              //        layoutItem.SetVisible(isExpanded);
              //        btnToggle.SetText(isExpanded ? 'Hide' : 'Show');

              //    }
              //}
              CAHistoryPopup.Show();
              // You can also change icons here dynamically if needed

          }

          function isToggleWF() {

              WFisExpanded = !WFisExpanded;
              var layoutControl = window["formRFP"];
              if (layoutControl) {
                  var layoutItem = layoutControl.GetItemByName("WFLayout");
                  if (layoutItem) {
                      console.log(WFisExpanded);
                      layoutItem.SetVisible(WFisExpanded);
                      WFbtnToggle.SetText(WFisExpanded ? 'Hide' : 'Show');

                  }
              }

              // You can also change icons here dynamically if needed

          }
      </script>
    <div class="conta" id="demoFabContent">
    <dx:ASPxFormLayout ID="formRFP" runat="server" Width="90%" SettingsAdaptivity-AdaptivityMode="SingleColumnWindowLimit" ColCount="2" ColumnCount="2" Theme="iOS" ClientInstanceName="formRFP" DataSourceID="SqlMain">
        <SettingsAdaptivity SwitchToSingleColumnAtWindowInnerWidth="900" AdaptivityMode="SingleColumnWindowLimit">
        </SettingsAdaptivity>
        <Items>
            <dx:LayoutGroup Caption="Request For Payment (Edit)" ColCount="2" ColSpan="2" ColumnCount="2" GroupBoxDecoration="HeadingLine" ColumnSpan="2" Width="100%">
                <GroupBoxStyle>
                    <Caption Font-Size="X-Large" BackColor="#FEFEFE">
                        <%--<Paddings PaddingLeft="40%" />--%>
                    </Caption>
                </GroupBoxStyle>
                <Items>


                    <dx:LayoutGroup Caption="Action Buttons" ColSpan="2" ColumnSpan="2" GroupBoxDecoration="None" HorizontalAlign="Right" Width="100%" ColCount="3" ColumnCount="3">
                        <Items>

                            <dx:EmptyLayoutItem ColSpan="3" ColumnSpan="3" Width="100%">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSubmit" runat="server" BackColor="#006838" Text="Submit" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('CreationForm')) SubmitPopup.Show();
}" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnSave" runat="server" BackColor="#006DD6" Text="Save" AutoPostBack="False">
                                            <ClientSideEvents Click="function(s, e) {
	if(ASPxClientEdit.ValidateGroup('CreationForm')) SavePopup.Show();
}" />
                                            <Border BorderColor="#006DD6" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:LayoutItem Caption="" ColSpan="1" Width="20%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="btnCancel" runat="server" Text="Cancel" Theme="iOS" ClientInstanceName="btnCancel" AutoPostBack="False" EnableTheming="True" BackColor="White" Font-Bold="False" ForeColor="Gray">
                                            <ClientSideEvents Click="function(s, e) {
	history.back()
}" />
                                            <Border BorderColor="Gray" />
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>

                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                        </Items>
                    </dx:LayoutGroup>


                    <dx:LayoutGroup Caption="RFP Details" ColSpan="1" ColCount="2" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem ColSpan="2" Caption="Charged To Company" ColumnSpan="2" Width="100%" FieldName="ChargedTo_CompanyId">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CTCompany" runat="server" ClientInstanceName="drpdown_CTCompany" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdown_CTDepartment.PerformCallback(s.GetValue());
//drpdown_Payee.PerformCallback(s.GetValue());
drpdown_CostCenter.SetValue(&quot;&quot;);
drpdwn_FAPWF.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());
FAPWFGrid.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());
ifComp_is_DLI();
onAmountChanged(drpdown_PayMethod.GetValue());
drpdown_CompLocation.PerformCallback(s.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Location" ColSpan="2" ColumnSpan="2" Width="100%" FieldName="Comp_Location_Id">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CompLocation" runat="server" ClientInstanceName="drpdown_CompLocation" DataSourceID="SqlCompLocation" TextField="Name" ValueField="ID" Width="100%" OnCallback="drpdown_CompLocation_Callback">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="2" Caption="Payment Method" ColumnSpan="2" Width="100%" FieldName="PayMethod">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_PayMethod" runat="server" Width="100%" DataSourceID="SqlPayMethod" TextField="PMethod_name" ValueField="ID" ClientInstanceName="drpdown_PayMethod">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onPayMethodChanged(s.GetValue());
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="2" Caption="Type of Transaction" ColumnSpan="2" Width="100%" FieldName="TranType">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_TranType" runat="server" DataSourceID="SqlTranType" TextField="RFPTranType_Name" ValueField="ID" ClientInstanceName="drpdown_TranType" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onPayToVendorTranType();
ifTranType_is_CA();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Projected Liquidation Date" ColSpan="2" Name="PLD" ColumnSpan="2" Width="100%" FieldName="PLDate" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="PLD" runat="server" ClientInstanceName="PLD" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="2" ColumnCount="2" HorizontalAlign="Right" ColumnSpan="2" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="30%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxRadioButton ID="rdButton_Trav" runat="server" ClientInstanceName="rdButton_Trav" RightToLeft="False" Text="Travel" Width="100px">
                                                    <RadioButtonFocusedStyle Wrap="True">
                                                    </RadioButtonFocusedStyle>
                                                    <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_NonTrav.SetValue(false);
onTravelClick();
}" />
                                                </dx:ASPxRadioButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="" ColSpan="1" Width="60%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxRadioButton ID="rdButton_NonTrav" runat="server" Checked="True" ClientInstanceName="rdButton_NonTrav" Text="Non-Travel" Width="200px">
                                                    <RadioButtonStyle Font-Size="Smaller" Wrap="True">
                                                    </RadioButtonStyle>
                                                    <ClientSideEvents CheckedChanged="function(s, e) {
	rdButton_Trav.SetValue(false);
onTravelClick();
}" />
                                                </dx:ASPxRadioButton>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutItem Caption="Travel Type" ColSpan="2" ColumnSpan="2" Width="100%" Name="TravType">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_TravType" runat="server" ClientInstanceName="drpdown_TravType" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onTravTypeChanged(s.GetValue());
}" />
                                            <Items>
                                                <dx:ListEditItem Text="Foreign" Value="1" />
                                                <dx:ListEditItem Text="Domestic" Value="2" />
                                            </Items>
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Classification" ColSpan="2" ColumnSpan="2" Width="100%" Name="ClassType" FieldName="Classification_Type_Id">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_classification" runat="server" ClientInstanceName="drpdown_classification" DataSourceID="SqlClassification" TextField="ClassificationName" ValueField="ID" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	FAPWFGrid.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());
drpdown_FAPWF.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());

}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Last day of transaction" ClientVisible="False" ColSpan="2" Name="LDOT" ColumnSpan="2" Width="100%" FieldName="LastDayTransact">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxDateEdit ID="dateEdit_lastDayTran" runat="server" ClientInstanceName="dateEdit_lastDayTran" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxDateEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" VerticalAlign="Middle" />
                                <CaptionStyle Font-Italic="False" Font-Size="Small">
                                </CaptionStyle>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="WBS" ColSpan="2" ColumnSpan="2" Name="WBS" Width="100%" FieldName="WBS" ClientVisible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_WBS" runat="server" ClientInstanceName="txtbox_WBS" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Nature of Disbursement/Purpose" ColSpan="2" FieldName="Purpose" ColumnSpan="2" Width="100%">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="memo_Purpose" runat="server" ClientInstanceName="memo_Purpose" Width="100%">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                        </Items>
                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="" ColSpan="1" GroupBoxDecoration="HeadingLine">
                        <GroupBoxStyle>
                            <Caption Font-Bold="True">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:LayoutItem ColSpan="1" Caption="Charged To Department" FieldName="ChargedTo_DeptId">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CTDepartment" runat="server" ClientInstanceName="drpdown_CTDepartment" DataSourceID="SqlCTDepartment" OnCallback="drpdown_CTDepartment_Callback" TextField="DepDesc" ValueField="ID" Width="100%">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onCTDeptChanged();
}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" Caption="Cost Center" FieldName="SAPCostCenter">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_CostCenter" runat="server" ClientInstanceName="drpdown_CostCenter" DataSourceID="SqlCostCenter" OnCallback="drpdown_CostCenter_Callback" TextField="CostCenter" ValueField="CostCenter" Width="100%">
                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem ColSpan="1" Caption="IO" FieldName="IO_Num">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxTextBox ID="txtbox_IO" runat="server" Width="100%" ClientInstanceName="txtbox_IO">
                                        </dx:ASPxTextBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Payee" ColSpan="1" Name="Payee" FieldName="Payee">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_Payee" runat="server" ClientInstanceName="drpdown_Payee" OnCallback="drpdown_Payee_Callback" TextField="FullName" ValueField="DelegateFor_UserID" Width="100%">
                                            <ValidationSettings Display="Dynamic" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="*Required" IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Account to be charged" ColSpan="1" FieldName="AcctCharged" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="expCat" runat="server" ClientInstanceName="expCat" DataSourceID="SqlExpCat" TextField="Description" ValueField="ID" Width="100%">
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutGroup Caption="Note: Payment to vendors or non-employee transactions should be reflected at gross amount" ColSpan="1" Width="100%">
                        <GroupBoxStyle>
                            <Caption Font-Italic="True" Font-Size="Smaller">
                            </Caption>
                        </GroupBoxStyle>
                        <Items>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="Currency" ColSpan="1" FieldName="Currency">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_currency" runat="server" ClientInstanceName="drpdown_currency" DataSourceID="SqlCurrency" TextField="CurrDescription" ValueField="CurrDescription" Width="50%" OnCallback="drpdown_currency_Callback">
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is requried." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Amount" ColSpan="1" FieldName="Amount">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxSpinEdit ID="spinEdit_Amount" runat="server" Width="50%" DisplayFormatString="#,##0.00" MaxValue="9999999" ClientInstanceName="spinEdit_Amount">
                                            <ClientSideEvents ValueChanged="function(s, e) {
	onAmountChanged(drpdown_PayMethod.GetValue());
FAPWFGrid.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());
drpdown_FAPWF.PerformCallback(drpdown_TravType.GetValue() + &quot;|&quot; + drpdown_CTCompany.GetValue() + &quot;|&quot; + spinEdit_Amount.GetValue() + &quot;|&quot; + drpdown_classification.GetValue());

}" />
                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                            </ValidationSettings>
                                        </dx:ASPxSpinEdit>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Right" />
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="Remarks" ColSpan="1" FieldName="Remarks" Visible="False">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxMemo ID="txtbox_remarks" runat="server" ClientInstanceName="txtbox_remarks" Height="71px" Width="100%">
                                        </dx:ASPxMemo>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings Location="Top" HorizontalAlign="Left" />
                            </dx:LayoutItem>
                        </Items>
                        <ParentContainerStyle Font-Italic="False">
                        </ParentContainerStyle>
                    </dx:LayoutGroup>
                            <dx:EmptyLayoutItem ColSpan="1">
                            </dx:EmptyLayoutItem>
                            <dx:LayoutItem Caption="Link to existing Expense Report" ColSpan="1" FieldName="Exp_ID">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxComboBox ID="drpdown_ExpID" runat="server" DataSourceID="SqlExpense" DropDownWidth="600px" TextField="DocNo" ValueField="ID" ClientInstanceName="drpdown_ExpID">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Document No." FieldName="DocNo">
                                                </dx:ListBoxColumn>
                                                <dx:ListBoxColumn Caption="Purpose" FieldName="Purpose">
                                                </dx:ListBoxColumn>
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                                <CaptionSettings HorizontalAlign="Left" Location="Top" />
                            </dx:LayoutItem>
                        </Items>
                        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="True" HorizontalAlign="Right" />
                    </dx:LayoutGroup>
                    
                    <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Left" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="btnToggle" runat="server" AutoPostBack="False" ClientInstanceName="btnToggle" Text="My Cash Advances">
                                    <ClientSideEvents Click="function(s, e) {
	isToggle();
}" />
                                    <Image IconID="richedit_documentstatistics_svg_white_16x16">
                                    </Image>
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ClientVisible="False" ColSpan="1" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlCAHistory" KeyFieldName="ID" Width="100%">
                                    <SettingsPager PageSize="5">
                                    </SettingsPager>
                                    <SettingsPopup>
                                        <FilterControl AutoUpdatePosition="False">
                                        </FilterControl>
                                    </SettingsPopup>
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Department_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="PayMethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="IO_Num" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="11">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="12">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="5">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                        </dx:GridViewDataCheckColumn>
                                        <dx:GridViewDataTextColumn FieldName="WBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="AcctCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataDateColumn FieldName="PLDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                        </dx:GridViewDataDateColumn>
                                        <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="SAPDocNo" ShowInCustomizationForm="True" VisibleIndex="25">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                            <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="15">
                                            <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                    </Columns>
                                </dx:ASPxGridView>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    
                    <dx:LayoutGroup Caption="" ColSpan="2" ColumnSpan="2" Width="100%" HorizontalAlign="Right" GroupBoxDecoration="None" ClientVisible="False">
                        <Items>
                            <dx:LayoutGroup Caption="" ColSpan="1" Name="collapsibleGroup" ClientVisible="False" Width="100%">
                            </dx:LayoutGroup>
                        </Items>
                        <TabImage IconID="businessobjects_bo_quote_svg_16x16">
                        </TabImage>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="1" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:LayoutGroup Caption="Supporting Documents" ColSpan="1" Width="100%">
                        <Items>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxUploadControl ID="UploadController" runat="server" AutoStartUpload="True" OnFilesUploadComplete="UploadController_FilesUploadComplete" ShowProgressPanel="True" UploadMode="Auto" Width="80%">
                                            <ClientSideEvents FilesUploadComplete="function(s, e) {
	DocumentGrid.Refresh();
}
" />
                                            <AdvancedModeSettings EnableDragAndDrop="True" EnableFileList="True" EnableMultiSelect="True">
                                            </AdvancedModeSettings>
                                        </dx:ASPxUploadControl>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxGridView ID="DocumentGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="DocumentGrid" DataSourceID="SqlDocs" KeyFieldName="ID">
                                            <ClientSideEvents CustomButtonClick="function(s, e) {
	window.location = 'FileHandler.ashx?id=' + s.GetRowKey(e.visibleIndex) + '';
}" />
                                            <SettingsPopup>
                                                <FilterControl AutoUpdatePosition="False">
                                                </FilterControl>
                                            </SettingsPopup>
                                            <Columns>
                                                <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileName" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="FileExtension" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="URL" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="DateUploaded" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="6">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn FieldName="App_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Company_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Doc_No" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Doc_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn Caption="File" ShowInCustomizationForm="True" VisibleIndex="13">
                                                    <CustomButtons>
                                                        <dx:GridViewCommandColumnCustomButton ID="btnDownload" Text="Open File">
                                                            <Image IconID="pdfviewer_next_svg_16x16">
                                                            </Image>
                                                        </dx:GridViewCommandColumnCustomButton>
                                                    </CustomButtons>
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn Caption="File Size" FieldName="FileSize" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:LayoutGroup Caption="Workflow" ColSpan="2" ColumnSpan="2" Width="100%" ColCount="3" ColumnCount="3">
                        <Items>
                            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="3" ColumnCount="2" ColumnSpan="3" GroupBoxDecoration="None" Width="100%">
                                <Items>
                                    <dx:LayoutItem Caption="Workflow Company" ColSpan="1" FieldName="Company_ID" Width="50%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_Company" runat="server" ClientInstanceName="drpdown_Company" DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	drpdown_Department.PerformCallback(s.GetValue());
drpdown_Payee.PerformCallback();
drpdown_WF.PerformCallback();
ifComp_is_DLI();
//onAmountChanged(drpdown_PayMethod.GetValue());
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                    <dx:LayoutItem Caption="Workflow Deparment" ColSpan="1" FieldName="Department_ID" Width="50%">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxComboBox ID="drpdown_Department" runat="server" ClientInstanceName="drpdown_Department" DataSourceID="SqlDepartment" OnCallback="formRFP_E4_Callback" TextField="DepDesc" ValueField="ID" Width="100%">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	onDeptChanged();
}" />
                                                    <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                        <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                    </ValidationSettings>
                                                </dx:ASPxComboBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                        <CaptionSettings HorizontalAlign="Right" />
                                    </dx:LayoutItem>
                                </Items>
                            </dx:LayoutGroup>
                            <dx:LayoutItem Caption="" ColSpan="1">
                                <LayoutItemNestedControlCollection>
                                    <dx:LayoutItemNestedControlContainer runat="server">
                                        <dx:ASPxButton ID="WFbtnToggle" runat="server" AutoPostBack="False" ClientInstanceName="WFbtnToggle" HorizontalAlign="Left" RenderMode="Link" Text="Show">
                                            <ClientSideEvents Click="function(s, e) {
	isToggleWF();
}" />
                                            <Image IconID="outlookinspired_expandcollapse_svg_32x32">
                                            </Image>
                                        </dx:ASPxButton>
                                    </dx:LayoutItemNestedControlContainer>
                                </LayoutItemNestedControlCollection>
                            </dx:LayoutItem>
                            <dx:LayoutGroup Caption="" ClientVisible="False" ColCount="2" ColSpan="1" ColumnCount="2" Width="100%" Name="WFLayout">
                                <Items>
                                    <dx:LayoutGroup Caption="RA Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <GroupBoxStyle>
                                            <Caption Font-Bold="True">
                                            </Caption>
                                        </GroupBoxStyle>
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="WF_Id">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="drpdown_WF" runat="server" ClientInstanceName="drpdown_WF" DataSourceID="SqlWF" OnCallback="drpdown_WF_Callback" TextField="WorkflowHeader_Name" ValueField="WF_Id" Width="100%" SelectedIndex="0">
                                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	OnWFChanged();
}" />
                                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                            </ValidationSettings>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="RA Workflow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="WFSequenceGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="WFSequenceGrid" DataSourceID="SqlWorkflowSequence" OnCustomCallback="WFSequenceGrid_CustomCallback" Width="100%">
                                                            <SettingsEditing Mode="Batch">
                                                            </SettingsEditing>
                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <PropertiesComboBox TextFormatString="{0}" ValueField="TerritoryID">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Territory" FieldName="TerritoryDescription">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn Caption="Region" FieldName="RegionID">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workflow Details" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="Workflow" ColSpan="1" FieldName="FAPWF_Id">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxComboBox ID="drpdwn_FAPWF" runat="server" ClientInstanceName="drpdwn_FAPWF" DataSourceID="SqlFAPWF2" OnCallback="drpdwn_FAPWF_Callback" TextField="Name" ValueField="WF_Id" Width="100%" SelectedIndex="0">
                                                            <ValidationSettings Display="Dynamic" ErrorTextPosition="Bottom" SetFocusOnError="True" ValidationGroup="CreationForm">
                                                                <RequiredField ErrorText="This field is required." IsRequired="True" />
                                                            </ValidationSettings>
                                                        </dx:ASPxComboBox>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                                <CaptionSettings HorizontalAlign="Right" />
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                    <dx:LayoutGroup Caption="FAP Workfow Sequence" ColSpan="1" GroupBoxDecoration="HeadingLine">
                                        <Items>
                                            <dx:LayoutItem Caption="" ColSpan="1">
                                                <LayoutItemNestedControlCollection>
                                                    <dx:LayoutItemNestedControlContainer runat="server">
                                                        <dx:ASPxGridView ID="FAPWFGrid" runat="server" AutoGenerateColumns="False" ClientInstanceName="FAPWFGrid" DataSourceID="SqlFAPWF" OnCustomCallback="FAPWFGrid_CustomCallback" Width="100%">
                                                            <SettingsEditing Mode="Batch">
                                                            </SettingsEditing>
                                                            <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                                            <SettingsPopup>
                                                                <FilterControl AutoUpdatePosition="False">
                                                                </FilterControl>
                                                            </SettingsPopup>
                                                            <Columns>
                                                                <dx:GridViewDataTextColumn Caption="Sequence" FieldName="Sequence" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Approver" FieldName="FullName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    <PropertiesComboBox TextFormatString="{0}" ValueField="TerritoryID">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Territory" FieldName="TerritoryDescription">
                                                                            </dx:ListBoxColumn>
                                                                            <dx:ListBoxColumn Caption="Region" FieldName="RegionID">
                                                                            </dx:ListBoxColumn>
                                                                        </Columns>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                        </dx:ASPxGridView>
                                                    </dx:LayoutItemNestedControlContainer>
                                                </LayoutItemNestedControlCollection>
                                            </dx:LayoutItem>
                                        </Items>
                                    </dx:LayoutGroup>
                                </Items>
                            </dx:LayoutGroup>
                        </Items>
                    </dx:LayoutGroup>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                    <dx:EmptyLayoutItem ColSpan="2" ColumnSpan="2" Width="100%">
                    </dx:EmptyLayoutItem>
                </Items>
                <SettingsItemCaptions HorizontalAlign="Right" />
            </dx:LayoutGroup>
        </Items>
        <SettingsItemCaptions ChangeCaptionLocationInAdaptiveMode="False" />
        <BackgroundImage HorizontalPosition="center" ImageUrl="../Content/Images/flat-mountains.svg'" Repeat="NoRepeat" />
    </dx:ASPxFormLayout>
        <dx:ASPxFloatingActionButton ID="ASPxFloatingActionButton1" runat="server" ClientInstanceName="fab" ContainerElementID="demoFabContent" EnableTheming="True" Theme="MaterialCompact" Visible="False">
            <ClientSideEvents Init="OnInit" ActionItemClick="OnActionItemClick" />
            <Items>
                <dx:FABAction ActionName="Cancel" ContextName="CancelContext" Text="Cancel">
                    <Image IconID="scheduling_delete_svg_white_16x16">
                    </Image>
                </dx:FABAction>
            </Items>
        </dx:ASPxFloatingActionButton>
        <dx:ASPxPopupControl ID="SubmitPopup" runat="server" HeaderText="Submit RFP?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SubmitPopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout1" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxFormLayout1_E1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                </TabImage>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxFormLayout1_E2" runat="server" Text="Are you sure you want to submit?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:EmptyLayoutItem ColSpan="1">
            </dx:EmptyLayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="btnSubmitFinal" runat="server" Text="Submit" BackColor="#0D6943" ClientInstanceName="btnSubmitFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {

if (!ASPxClientEdit.ValidateGroup('CreationForm')) { 
SubmitPopup.Hide();
}else{
UpdateRFPMain(&quot;1&quot;);
SubmitPopup.Hide();

}	
}
" />
                                    <Border BorderColor="#0D6943" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxFormLayout1_E4" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	SubmitPopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="SavePopup" runat="server" HeaderText="Save RFP?" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="SavePopup" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout2" runat="server">
        <Items>
            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxImage1" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                </TabImage>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Are you sure you want to save?" Font-Size="Medium">
                        </dx:ASPxLabel>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:EmptyLayoutItem ColSpan="1">
            </dx:EmptyLayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="btnSaveFinal" runat="server" Text="Save" ClientInstanceName="btnSaveFinal" AutoPostBack="False">
                                    <ClientSideEvents Click="function(s, e) {

if (!ASPxClientEdit.ValidateGroup('CreationForm')) { 
SavePopup.Hide();
}else{
UpdateRFPMain(&quot;13&quot;);
SavePopup.Hide();

}	
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                    <dx:LayoutItem Caption="" ColSpan="1">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton2" runat="server" Text="Cancel" AutoPostBack="False" BackColor="White" ForeColor="Gray">
                                    <ClientSideEvents Click="function(s, e) {
	SubmitPopup.Hide();
}" />
                                    <Border BorderColor="Gray" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

        <dx:ASPxPopupControl ID="ASPxPopupControl1" runat="server" HeaderText="Warning!" Modal="True" AllowDragging="True" AutoUpdatePosition="True" ClientInstanceName="PetCashPopupSave" CloseAction="CloseButton" CloseOnEscape="True" EnableViewState="False" PopupAnimationType="None" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <SettingsAdaptivity Mode="Always" VerticalAlign="WindowCenter" />
        <ContentCollection>
<dx:PopupControlContentControl runat="server">
    <dx:ASPxFormLayout ID="ASPxFormLayout3" runat="server" Width="100%">
        <Items>
            <dx:LayoutItem ColSpan="1" ShowCaption="False" HorizontalAlign="Center">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxImage ID="ASPxImage2" runat="server" Height="50px" ImageAlign="Middle" ImageUrl="~/Content/Images/warning.png" Width="50px">
                        </dx:ASPxImage>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
                <TabImage IconID="businessobjects_bo_attention_svg_16x16">
                </TabImage>
            </dx:LayoutItem>
            <dx:LayoutItem Caption="" ColSpan="1">
                <LayoutItemNestedControlCollection>
                    <dx:LayoutItemNestedControlContainer runat="server">
                        <dx:ASPxMemo ID="ASPxFormLayout3_E2" runat="server" Font-Size="Medium" Height="83px" ReadOnly="True" Width="100%" HorizontalAlign="Center" ClientInstanceName="warning_txt" Font-Bold="False">
                            <Border BorderStyle="None" />
                        </dx:ASPxMemo>
                    </dx:LayoutItemNestedControlContainer>
                </LayoutItemNestedControlCollection>
            </dx:LayoutItem>
            <dx:LayoutGroup Caption="" ColCount="2" ColSpan="1" ColumnCount="2" GroupBoxDecoration="HeadingLine" HorizontalAlign="Center">
                <Items>
                    <dx:LayoutItem Caption="" ColSpan="2" ColumnSpan="2" HorizontalAlign="Center" Width="100%">
                        <LayoutItemNestedControlCollection>
                            <dx:LayoutItemNestedControlContainer runat="server">
                                <dx:ASPxButton ID="ASPxButton3" runat="server" AutoPostBack="False" Text="OK">
                                    <ClientSideEvents Click="function(s, e) {
	PetCashPopupSave.Hide();
}" />
                                </dx:ASPxButton>
                            </dx:LayoutItemNestedControlContainer>
                        </LayoutItemNestedControlCollection>
                    </dx:LayoutItem>
                </Items>
            </dx:LayoutGroup>
        </Items>
    </dx:ASPxFormLayout>
            </dx:PopupControlContentControl>
</ContentCollection>
    </dx:ASPxPopupControl>

        <dx:ASPxLoadingPanel ID="LoadingPanel" ClientInstanceName="LoadingPanel" Modal ="true" runat="server" Theme="MaterialCompact"></dx:ASPxLoadingPanel>
    
    <dx:ASPxPopupControl ID="CAHistoryPopup" runat="server" AllowDragging="True" ClientInstanceName="CAHistoryPopup" CloseAction="CloseButton" CssClass="rounded" FooterText="" HeaderText="Cash Advance History" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="1146px">
            <ClientSideEvents Closing="function(s, e) {
	ASPxClientEdit.ClearEditorsInContainerById('expDiv')
}" />
            <ContentCollection>
                <dx:PopupControlContentControl runat="server">
                    <div id="expDiv">
                        <dx:ASPxFormLayout ID="ASPxFormLayout4" runat="server" Width="100%">
                            <Items>
                                <dx:LayoutGroup Caption="Please avoid creating new Cash Advance if you have unliquidated Cash Advance." ColSpan="1">
                                    <GroupBoxStyle>
                                        <Caption Font-Bold="True" Font-Italic="True" Font-Size="Smaller">
                                        </Caption>
                                    </GroupBoxStyle>
                                    <Items>
                                        <dx:LayoutItem Caption="" ColSpan="1">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer runat="server">
                                                    <dx:ASPxGridView ID="ASPxGridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlCAHistory" KeyFieldName="ID" Width="100%">
                                                        <SettingsPager PageSize="5">
                                                        </SettingsPager>
                                                        <SettingsPopup>
                                                            <FilterControl AutoUpdatePosition="False">
                                                            </FilterControl>
                                                        </SettingsPopup>
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Department_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="PayMethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="TranType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="isTravel" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="SAPCostCenter" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="IO_Num" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Payee" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="LastDayTransact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" VisibleIndex="11">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Purpose" ShowInCustomizationForm="True" VisibleIndex="12">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="WF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="User_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="RFP_DocNum" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="DateCreated" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="IsExpenseCA" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Exp_ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="FAPWF_Id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataCheckColumn FieldName="IsExpenseReim" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                            </dx:GridViewDataCheckColumn>
                                                            <dx:GridViewDataTextColumn FieldName="WBS" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="AcctCharged" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataDateColumn FieldName="PLDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                            </dx:GridViewDataDateColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Remarks" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="SAPDocNo" ShowInCustomizationForm="True" VisibleIndex="25">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Company" FieldName="Company_ID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                <PropertiesComboBox DataSourceID="SqlCompany" TextField="CompanyShortName" ValueField="CompanyId">
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                            <dx:GridViewDataComboBoxColumn FieldName="Status" ShowInCustomizationForm="True" VisibleIndex="15">
                                                                <PropertiesComboBox DataSourceID="SqlStatus" TextField="STS_Name" ValueField="STS_Id">
                                                                </PropertiesComboBox>
                                                            </dx:GridViewDataComboBoxColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                            </Items>
                        </dx:ASPxFormLayout>
                    </div>
                </dx:PopupControlContentControl>
            </ContentCollection>
        </dx:ASPxPopupControl>

       
    </div>
    <asp:SqlDataSource ID="SqlMain" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_RFPMainView] WHERE ([ID] = @ID)">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompany" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserComp] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_SecurityUserDept] WHERE (([AppId] = @AppId) AND ([IsActive] = @IsActive) AND ([CompanyId] = @CompanyId) AND ([UserId] = @UserId))">
        <SelectParameters>
            <asp:Parameter DefaultValue="1032" Name="AppId" Type="Int32" />
            <asp:Parameter DefaultValue="true" Name="IsActive" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="CompanyId" Type="Int32" />
            <asp:Parameter Name="UserId" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlPayMethod" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_PayMethod] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlTranType" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_RFPTranType] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <%--<asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserWFAccess] WHERE (([UserId] = @UserId) AND ([CompanyId] = @CompanyId) AND ([IsRA] = @IsRA) AND ([Minimum] &lt;= @Minimum) AND ([Maximum] &gt;= @Maximum) AND ([DepCode] = @DepCode))">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsRA" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="Minimum" Type="Decimal" />
            <asp:Parameter Name="Maximum" Type="Decimal" />
            <asp:Parameter Name="DepCode" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>--%>
    <asp:SqlDataSource ID="SqlWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserWFAccess] WHERE (([UserId] = @UserId) AND ([CompanyId] = @CompanyId) AND ([IsRA] = @IsRA) AND ([DepCode] = @DepCode))">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="String" />
            <asp:Parameter Name="CompanyId" Type="Int32" />
            <asp:Parameter DefaultValue="True" Name="IsRA" Type="Boolean" />
            <asp:Parameter DefaultValue="" Name="DepCode" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlWorkflowSequence" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpense" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_ExpenseMain] WHERE ([UserId] = @UserId)">
        <SelectParameters>
            <asp:Parameter Name="UserId" Type="Int32" />
        </SelectParameters>
</asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_RS_Workflow_Sequence] WHERE ([WF_Id] = @WF_Id) ORDER BY [Sequence]">
            <SelectParameters>
                <asp:Parameter Name="WF_Id" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlFAPWF2" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_WorkflowHeader] WHERE ([WF_Id] = @WF_Id)">
        <SelectParameters>
            <asp:Parameter Name="WF_Id" Type="Int32" />
        </SelectParameters>
     </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlExpCat" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_MasterCodes] WHERE ([Code] = @Code)">
        <SelectParameters>
            <asp:Parameter DefaultValue="ExpCat" Name="Code" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCAHistory" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_T_RFPMain] WHERE (([User_ID] = @User_ID) AND ([IsExpenseCA] = @IsExpenseCA)) ORDER BY [DateCreated] DESC">
        <SelectParameters>
            <asp:Parameter Name="User_ID" Type="String" />
            <asp:Parameter DefaultValue="True" Name="IsExpenseCA" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCurrency" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACDE_T_Currency] WHERE ([isActive] = @isActive)">
        <SelectParameters>
            <asp:Parameter DefaultValue="True" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlStatus" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_Status]"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDocs" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" DeleteCommand="DELETE FROM [ITP_T_FileAttachment] WHERE [ID] = @original_ID" InsertCommand="INSERT INTO [ITP_T_FileAttachment] ([FileName], [Description], [DateUploaded], [FileSize]) VALUES (@FileName, @Description, @DateUploaded, @FileSize)" OldValuesParameterFormatString="original_{0}" SelectCommand="SELECT [ID], [FileName], [Description], [DateUploaded], [FileSize] FROM [ITP_T_FileAttachment] WHERE (([App_ID] = @App_ID) AND ([Doc_ID] = @Doc_ID) AND ([DocType_Id] = @DocType_Id))" UpdateCommand="UPDATE [ITP_T_FileAttachment] SET [FileName] = @FileName, [Description] = @Description, [DateUploaded] = @DateUploaded, [FileSize] = @FileSize WHERE [ID] = @original_ID">
            <DeleteParameters>
                <asp:Parameter Name="original_ID" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="DateUploaded" Type="DateTime" />
                <asp:Parameter Name="FileSize" Type="String" />
            </InsertParameters>
            <SelectParameters>
                <asp:Parameter Name="App_ID" Type="Int32" DefaultValue="1032" />
                <asp:Parameter DefaultValue="" Name="Doc_ID" Type="Int32" />
                <asp:Parameter Name="DocType_Id" Type="Int32" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="FileName" Type="String" />
                <asp:Parameter Name="Description" Type="String" />
                <asp:Parameter Name="DateUploaded" Type="DateTime" />
                <asp:Parameter Name="FileSize" Type="String" />
                <asp:Parameter Name="original_ID" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUser" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [vw_ACCEDE_I_UserDelegationUMaster] WHERE (([DelegateTo_UserID] = @DelegateTo_UserID) AND ([Company_ID] = @Company_ID) AND ([DateFrom] &lt;= @DateFrom) AND ([DateTo] &gt;= @DateTo) AND ([IsActive] = @IsActive)) ORDER BY [FullName]">
        <SelectParameters>
            <asp:Parameter Name="DelegateTo_UserID" Type="String" />
            <asp:Parameter Name="Company_ID" Type="Int32" />
            <asp:Parameter Name="DateFrom" Type="DateTime" />
            <asp:Parameter Name="DateTo" Type="DateTime" />
            <asp:Parameter DefaultValue="1" Name="IsActive" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlUserSelf" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT EmpCode AS DelegateFor_UserID, FullName FROM [ITP_S_UserMaster] WHERE ([EmpCode] = @EmpCode)">
        <SelectParameters>
            <asp:Parameter Name="EmpCode" Type="String" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlClassification" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_ExpenseClassification] WHERE ([isActive] = @isActive) ORDER BY [ClassificationName]">
        <SelectParameters>
            <asp:Parameter DefaultValue="true" Name="isActive" Type="Boolean" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCTDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_OrgDepartmentMaster] WHERE ([Company_ID] = @Company_ID)">
        <SelectParameters>
            <asp:Parameter Name="Company_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCostCenter" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ACCEDE_S_CostCenter] WHERE ([DepartmentId] = @DepartmentId)">
        <SelectParameters>
            <asp:Parameter Name="DepartmentId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlCompLocation" runat="server" ConnectionString="<%$ ConnectionStrings:ITPORTALConnectionString %>" SelectCommand="SELECT * FROM [ITP_S_CompanyBranch] WHERE ([Comp_Id] = @Comp_Id)">
        <SelectParameters>
            <asp:Parameter Name="Comp_Id" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
