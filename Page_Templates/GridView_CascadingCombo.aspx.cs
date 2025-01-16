using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DX_WebTemplate.Page_Templates
{
    public partial class GridView_CascadingCombo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void gridTest_CellEditorInitialize(object sender, DevExpress.Web.ASPxGridViewEditorEventArgs e)
        {
            if (e.Column.FieldName == "App_ID")
            {
                var combo = (ASPxComboBox)e.Editor;
                combo.Callback += new CallbackEventHandlerBase(combo_Callback);

                var grid =  e.Column.Grid;
                if (!combo.IsCallback)
                {
                    var appTypeID = -1;
                    if (!grid.IsNewRowEditing)
                        appTypeID = (int)grid.GetRowValues(e.VisibleIndex, "AppType_ID");
                    FillAppsComboBox(combo, appTypeID);
                }
            }
        }

        private void combo_Callback(object sender, CallbackEventArgsBase e)
        {
            var appTypeID = -1;
            Int32.TryParse(e.Parameter, out appTypeID);
            FillAppsComboBox(sender as ASPxComboBox, appTypeID);
        }
        protected void FillAppsComboBox(ASPxComboBox combo, int appTypeID)
        {
            combo.DataSourceID = "sqlSecApp";
            sqlSecApp.SelectParameters["AppType_ID"].DefaultValue = appTypeID.ToString();
            combo.DataBindItems();

            combo.Items.Insert(0, new ListEditItem("", null)); // Null Item  
        }

        protected void gridTest_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
        {
         
        }
    }
}