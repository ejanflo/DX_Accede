using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DX_WebTemplate
{
    public class SAPDataProvider
    {
        private const string CacheKey = "SAP_EWT_ObjectDS";
        private const string CacheKeyVAT = "SAP_VAT_ObjectDS";

        // ObjectDataSource calls this
        public static List<AccedeModels.EwtSet> GetEWT()
        {
            // Try cache first
            var cached = HttpRuntime.Cache[CacheKey] as List<AccedeModels.EwtSet>;
            if (cached != null && cached.Count > 0)
                return cached;

            // OData params (without $format because SAPConnector adds it)
            const string odataParams = "sap-client=300&$select=EWTTYPE,EWTCODE,EWTDESC,EWTRATE";
            var list = SAPConnector.GetEWTData(odataParams) ?? new List<AccedeModels.EwtSet>();

            // Optional dedup (reuse your existing logic if needed)
            list = list
                .Where(c => !string.IsNullOrWhiteSpace(c?.EWTCODE))
                .GroupBy(c => c.EWTCODE.Trim())
                .Select(g => g
                    .OrderByDescending(c => (c.EWTDESC ?? "").Length)
                    .ThenBy(c => c.EWTCODE)
                    .First())
                .OrderBy(c => c.EWTDESC)
                .ToList();

            if (list.Count > 0)
            {
                HttpRuntime.Cache.Insert(
                    CacheKey,
                    list,
                    null,
                    DateTime.Now.AddMinutes(30),
                    System.Web.Caching.Cache.NoSlidingExpiration);
            }

            return list;
        }

        public static List<AccedeModels.VatSet> GetVAT()
        {
            // Try cache first
            var cached = HttpRuntime.Cache[CacheKeyVAT] as List<AccedeModels.VatSet>;
            if (cached != null && cached.Count > 0)
                return cached;

            // OData params (without $format because SAPConnector adds it)
            const string odataParams = "sap-client=300&$select=VATCODE,VATDESC,VATTYPE,VATCONDTYPE,VATACCTKEY,VATRATE";
            var list = SAPConnector.GetVATData(odataParams) ?? new List<AccedeModels.VatSet>();

            // Filter out entries where VATDESC contains "DO NOT USE", then dedup
            list = list
                .Where(c =>
                    !string.IsNullOrWhiteSpace(c?.VATCODE) &&
                    (string.IsNullOrWhiteSpace(c?.VATDESC) || !c.VATDESC.ToUpper().Contains("DO NOT USE"))
                )
                .GroupBy(c => c.VATCODE.Trim())
                .Select(g => g
                    .OrderByDescending(c => (c.VATDESC ?? "").Length)
                    .ThenBy(c => c.VATCODE)
                    .First())
                .OrderBy(c => c.VATDESC)
                .ToList();

            if (list.Count > 0)
            {
                HttpRuntime.Cache.Insert(
                    CacheKeyVAT,
                    list,
                    null,
                    DateTime.Now.AddMinutes(30),
                    System.Web.Caching.Cache.NoSlidingExpiration);
            }

            return list;
        }
    }
}