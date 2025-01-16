using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

namespace DX_WebTemplate.Page_Templates
{
    public class CRUD
    {

        ITPDataContext dbContext = new ITPDataContext("Data Source=(localdb)\\mssqllocaldb;AttachDbFilename=C:\\Users\\jfpimentera\\Documents\\_PROJECTS\\DevExpress\\DX_WebTemplate\\DX_WebTemplate\\App_Data\\NWind.mdf;Integrated Security=True;Connect Timeout=120");
        ITPORTALDataContext context = new ITPORTALDataContext(ConfigurationManager.ConnectionStrings["ITPORTALConnectionString"].ConnectionString);


        #region Get Data using LINQ approach

        public decimal GetPesoRate(int currencyID)
        {
            decimal pesoRate = 0;

            try
            {
                pesoRate = context.ITP_S_ForeignExches
                    .Where(rate => rate.Currency_Id == currencyID)
                    .OrderByDescending(rate => rate.DateValid)
                    .Select(rate => Convert.ToDecimal(rate.PesoRate))
                    .FirstOrDefault();  
            }
            catch
            {
                pesoRate = 0;
            }

            return pesoRate;
            
        }

        public DateTime GetOrderDate(int orderID)
        {
            DateTime pOrderDate = DateTime.Now;

            try
            {
                var queryOrder=
                  from order in dbContext.Orders
                  where order.OrderID == orderID
                  select order;

                foreach (var orderInfo in queryOrder)
                {
                    pOrderDate = Convert.ToDateTime(orderInfo.OrderDate);
                }
            }
            catch
            {
                return DateTime.Now;
            }

            return pOrderDate;
        }

        #endregion

        #region Delete Data using LINQ approach

        public void deleteOrder(int orderID)
        {
            try
            {
                //var x = dbContext.Orders.Where(y => y.OrderID == orderID);
                var x = (from y in dbContext.Orders
                         where y.OrderID == orderID
                         orderby y.OrderID descending
                         select y).FirstOrDefault();

                dbContext.Orders.DeleteOnSubmit(x);

                dbContext.SubmitChanges();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }

        }

        #endregion

        #region Insert Data using LINQ approach

        public void insertOrder(DateTime Order_Date, int EmpID)
        {

            //Start: Select Plan Application details
            try
            {
                //Start: Insert batch details
                Order iOrder = new Order
                {
                    OrderDate = Order_Date,
                    EmployeeID = EmpID
                };

                dbContext.Orders.InsertOnSubmit(iOrder);

                // Submit the change to the database
                try
                {
                    dbContext.SubmitChanges();
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
                //End: Insert batch details
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
            //End: Select Plan Application details
        }

        #endregion

        #region Update Data using LINQ approach

        public void Update_OrderDate(DateTime pOrderDate, int pOrderID)
        {
            try
            {
                foreach (var order in dbContext.Orders.Where(x => x.OrderID == pOrderID))
                {
                    order.OrderDate = pOrderDate;
                }
                dbContext.SubmitChanges();
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); }

        }
        #endregion

        #region Check if data Exist using LINQ approach

        /// <summary>
        /// Check if application already exists
        /// </summary>
        /// <param name="Document_Number">Document Number</param>
        /// <returns></returns>
        public bool CheckExist_Order(int pEmpID)
        {
            var docExists = false;

            try
            {
                var count = dbContext.Orders.Count(doc => doc.EmployeeID == pEmpID);// && me.me_pkey != this.me_pkey);
                docExists = count > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                docExists = false;
            }

            return docExists;
        }
        #endregion

        #region Count data using LINQ approach

        public int Count_Pending_Docs(int EmpNo)
        {
            int count = 0;

            try
            {
                var actionStatus = new[] { 3, 7, 8, 10, 17, 19, 21, 23, 26, 27, 29 };
                //count = dbContext.vw_ACPS_I_PendingDocs.Count(plan => actionStatus.Contains(plan.ACTS_Status) && plan.ACT_EmpNo == EmpNo);
            }
            catch { return 0; }

            return count;
        }

        #endregion

        #region Run Stored Procedure

        string conString = ConfigurationManager.ConnectionStrings["NWindConnectionString"].ConnectionString; //"Data Source=anflosouth-dev1;Initial Catalog=ACPS;Integrated Security=True; Trusted_Connection=yes;User Id=;Password=";


        // run a stored procedure that takes a parameter
        /// <summary>
        /// Execute Stored Procedure
        /// </summary>
        /// <param name="sp_name">Stored Procedure Name</param>
        /// <param name="parName1">Parameter Name 1</param>
        /// <param name="parName2">Parameter Name 2</param>
        /// <param name="par1">Parameter Value 1</param>
        /// <param name="par2">Parameter Value 2</param>
        public void StoredProcedure_Run2(string sp_name, string parName1, string parName2, int par1, int par2)
        {
            SqlConnection conn = null;
            SqlDataReader rdr = null;

            try
            {
                // create and open a connection object
                conn = new
                    SqlConnection(conString);
                conn.Open();

                // 1. create a command object identifying
                // the stored procedure
                SqlCommand cmd = new SqlCommand(
                    sp_name, conn);

                // 2. set the command object so it knows
                // to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. add parameter to command, which
                // will be passed to the stored procedure
                cmd.Parameters.Add(
                    new SqlParameter(parName1, par1));
                cmd.Parameters.Add(
                    new SqlParameter(parName2, par2));

                // execute the command
                rdr = cmd.ExecuteReader();
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
                if (rdr != null)
                {
                    rdr.Close();
                }
            }
        }
        #endregion

        //Using Document Number Generator

        GenerateDocNo genDoc = new GenerateDocNo(); //call the class
        public void HowToUse_DocGenerator()
        {
            //Step 1: Run Stored Proc to update the series
            genDoc.RunStoredProc_GenerateDocNum(1,2,1);

            //Step 2: Get the latest generated doc number
            string docNumberGenerated = genDoc.GetLatest_DocNum(1, 2, 1);

        }
    }
}