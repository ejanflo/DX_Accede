using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Web;
using static DX_WebTemplate.AccedeModels;

namespace DX_WebTemplate
{
    public class SAPConnector
    {


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

        public static List<EwtSet> GetEWTData(string apiparam)
        {
            try
            {
                // Normalize parameter (user types only the variable portion, e.g. sap-client=300&$filter=Matnum eq '123')
                var p = (apiparam ?? string.Empty).Trim();

                var sb = new System.Text.StringBuilder("/sap/opu/odata/SAP/Z_AVSAP_SRV_01/ewtSet?");
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
                        var wrapper = JsonConvert.DeserializeObject<EwtResponseWrapper>(json); // Corrected to EwtResponseWrapper
                        return wrapper?.d?.results ?? new List<EwtSet>();
                    }
                }

                return new List<EwtSet>();
            }
            catch (Exception)
            {
                throw;
            }
        }

        public static List<VatSet> GetVATData(string apiparam)
        {
            try
            {
                // Normalize parameter (user types only the variable portion, e.g. sap-client=300&$filter=Matnum eq '123')
                var p = (apiparam ?? string.Empty).Trim();

                var sb = new System.Text.StringBuilder("/sap/opu/odata/SAP/Z_AVSAP_SRV_01/vatSet?");
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
                        var wrapper = JsonConvert.DeserializeObject<VatResponseWrapper>(json); // Corrected to EwtResponseWrapper
                        return wrapper?.d?.results ?? new List<VatSet>();
                    }
                }

                return new List<VatSet>();
            }
            catch (Exception)
            {
                throw;
            }
        }

        // For VAT Wrapper
        public class VatResponseWrapper
        {
            public VatResponseData d { get; set; }
        }

        public class VatResponseData
        {
            public List<VatSet> results { get; set; }
        }

        // For EWT Wrapper
        public class EwtResponseWrapper
        {
            public EwtResponseData d { get; set; }
        }

        public class EwtResponseData
        {
            public List<EwtSet> results { get; set; }
        }

    }
}