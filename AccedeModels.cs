using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DX_WebTemplate
{
    public class AccedeModels
    {

        public class VendorSet
        {
            [JsonProperty("__metadata")]
            public SAPMetadata Metadata { get; set; }

            public string CLIENT { get; set; }
            public string VENDCODE { get; set; }
            public string VENDCOCODE { get; set; }
            public string VENDNAME { get; set; }
            public string VENDTIN { get; set; }
            public string VENDSTREET { get; set; }
            public string VENDSTREET2 { get; set; }
            public string VENDCITY { get; set; }
            public string VENDPOSTAL { get; set; }
            public string VENDCOUNTRY { get; set; }
            public string VENDSHORT { get; set; }
            public string VENDSTATUS { get; set; }

            public class SAPMetadata
            {
                public string id { get; set; }
                public string uri { get; set; }
                public string type { get; set; }
            }


        }

        public class EwtSet
        {
            [JsonProperty("__metadata")]
            public SAPMetadata Metadata { get; set; }

            public string CLIENT { get; set; }
            public string EWTTYPE { get; set; }
            public string EWTCODE { get; set; }
            public string EWTRATE { get; set; }
            public string EWTDESC { get; set; }

            public class SAPMetadata
            {
                public string id { get; set; }
                public string uri { get; set; }
                public string type { get; set; }
            }
        }

        public class VatSet
        {
            [JsonProperty("__metadata")]
            public SAPMetadata Metadata { get; set; }

            public string CLIENT { get; set; }
            public string VATCODE { get; set; }
            public string VATDESC { get; set; }
            public string VATTYPE { get; set; }
            public string VATCONDTYPE { get; set; }
            public string VATACCTKEY { get; set; }
            public string VATRATE { get; set; }

            public class SAPMetadata
            {
                public string id { get; set; }
                public string uri { get; set; }
                public string type { get; set; }
            }
        }

        public class InvDetailsNonPO
        {
            public int id { get; set; }
            public string dateAdded { get; set; }
            public string particulars { get; set; }
            public string InvoiceOR { get; set; }
            public int acctCharge { get; set; }
            public decimal grossAmnt { get; set; }
            public decimal netAmnt { get; set; }
            public int expMainId { get; set; }
            public string preparerId { get; set; }
            public decimal totalAllocAmnt { get; set; }
            public string LineDesc { get; set; }
            public string Assignment { get; set; }
            public string UserId { get; set; }
            public string Allowance { get; set; }
            public string SLCode { get; set; }
            public int EWTTaxType_Id { get; set; }
            public decimal EWTTaxAmount { get; set; }
            public string EWTTaxCode { get; set; }
            public string InvoiceTaxCode { get; set; }
            public string Asset { get; set; }
            public string SubAssetCode { get; set; }
            public string TransactionType { get; set; }
            public string AltRecon { get; set; }
            public string SpecialGL { get; set; }
            public decimal Qty { get; set; }
            public decimal UnitPrice { get; set; }
            public string uom { get; set; }
            public decimal ewt { get; set; }
            public decimal vat { get; set; }
            public decimal ewtperc { get; set; }
            public decimal netvat { get; set; }
            public bool isVatCompute { get; set; }
        }
    }
}