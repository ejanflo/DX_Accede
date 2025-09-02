using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;

namespace DX_WebTemplate
{
    public class SAPVendor
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

        private static readonly UserToken AppUserToken = new UserToken();

        private class UserToken
        {
            public string Username { get; }
            public string Password { get; }

            public UserToken()
            {
                Username = "SVCANFLOVERS";
                Password = "NaKrnyeArWZhdMjaYyGohtbTMpwNgl&CM4tNewjR";
            }
        }

        public class VendorResponseWrapper
        {
            public VendorResponseData d { get; set; }
        }

        public class VendorResponseData
        {
            public List<VendorSet> results { get; set; }
        }

        public static List<VendorSet> GetVendorData(string apiparam)
        {
            try
            {
                // Normalize parameter (user types only the variable portion, e.g. sap-client=300&$filter=Matnum eq '123')
                var p = (apiparam ?? string.Empty).Trim();

                var sb = new System.Text.StringBuilder("/sap/opu/odata/SAP/Z_AVSAP_SRV_01/vendorSet?");
                if (!string.IsNullOrEmpty(p))
                {
                    // Ensure no leading '?' from accidental input
                    if (p.StartsWith("?")) p = p.Substring(1);
                    sb.Append(p);
                    if (!p.EndsWith("&") && !p.EndsWith("?"))
                        sb.Append("&");
                }
                sb.Append("&$format=json");
                string serviceUrl = sb.ToString();

                string baseUrl = "http://anflosapapp.anflocor.local:8000";

                string username = AppUserToken.Username;
                string password = AppUserToken.Password;

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(baseUrl);

                    var byteArray = System.Text.Encoding.ASCII.GetBytes($"{username}:{password}");
                    client.DefaultRequestHeaders.Authorization =
                        new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));

                    client.DefaultRequestHeaders.Accept.Clear();
                    client.DefaultRequestHeaders.Accept.Add(
                        new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                    HttpResponseMessage response = client.GetAsync(serviceUrl).Result;

                    if (response.IsSuccessStatusCode)
                    {
                        string json = response.Content.ReadAsStringAsync().Result;
                        var wrapper = JsonConvert.DeserializeObject<VendorResponseWrapper>(json);
                        return wrapper?.d?.results ?? new List<VendorSet>();
                    }
                }

                return new List<VendorSet>();
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}