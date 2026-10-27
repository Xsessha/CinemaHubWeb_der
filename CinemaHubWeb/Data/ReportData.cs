using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace CinemaHubWeb.Data
{
    public static class ReportData
    {
        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CinemaHubConnection"].ConnectionString; }
        }

        private static DataTable Fill(string tableName, string sql, params SqlParameter[] args)
        {
            DataTable table = new DataTable(tableName);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
            {
                if (args != null && args.Length > 0) da.SelectCommand.Parameters.AddRange(args);
                da.Fill(table);
            }
            return table;
        }
        public static DataTable GetTicketList()
        {
            return Fill("TicketList",
                @"SELECT TOP (300) TicketID,
                         N'№' + CAST(TicketID AS NVARCHAR(10)) + N' — ' + MovieTitle + N' — ' +
                         CONVERT(NVARCHAR(16), SessionStart, 120) + N' — ряд ' + CAST(RowNumber AS NVARCHAR(3)) +
                         N', місце ' + CAST(SeatNumber AS NVARCHAR(3)) AS Caption
                  FROM dbo.vw_TicketReport ORDER BY TicketID DESC");
        }
        public static DataTable GetTicket(int ticketId)
        {
            return Fill("TicketDS",
                @"SELECT TicketID, MovieTitle, GenreName, HallName, SessionStart, RowNumber, SeatNumber, CustomerName,
                         BasePrice, FormatSurcharge, DiscountPercent, Price, PaymentMethod, PaymentStatus, PurchaseDate
                  FROM dbo.vw_TicketReport WHERE TicketID = @id",
                new SqlParameter("@id", ticketId));
        }
        public static DataTable GetPriceBreakdown(int ticketId)
        {
            DataTable result = new DataTable("PriceDS");
            result.Columns.Add("Item", typeof(string));
            result.Columns.Add("Amount", typeof(decimal));

            using (DataTable t = Fill("tmp",
                "SELECT BasePrice, FormatSurcharge, DiscountPercent FROM dbo.vw_TicketReport WHERE TicketID = @id",
                new SqlParameter("@id", ticketId)))
            {
                if (t.Rows.Count == 1)
                {
                    decimal basePrice = Convert.ToDecimal(t.Rows[0]["BasePrice"]);
                    decimal surcharge = Convert.ToDecimal(t.Rows[0]["FormatSurcharge"]);
                    int discount = Convert.ToInt32(t.Rows[0]["DiscountPercent"]);

                    result.Rows.Add("Базова ціна місця", basePrice);
                    if (surcharge > 0) result.Rows.Add("Надбавка за формат залу", surcharge);
                    if (discount > 0)
                        result.Rows.Add(string.Format("Знижка {0}%", discount), -Math.Round((basePrice + surcharge) * discount / 100m, 2));
                }
            }
            return result;
        }
        public static DataSet GetFinancialData(DateTime from, DateTime to)
        {
            DataTable table = Fill("FinancialData",
                @"SELECT GenreName, MovieTitle, SessionDate, HallName, TicketID, Price, PaidAmount
                  FROM dbo.vw_FinancialData
                  WHERE SessionDate >= @from AND SessionDate <= @to
                  ORDER BY GenreName, MovieTitle, SessionDate",
                new SqlParameter("@from", from.Date),
                new SqlParameter("@to", to.Date));

            DataSet ds = new DataSet("CinemaAnalytics");
            ds.Tables.Add(table);
            return ds;
        }

        public static DataTable GetFinancialSummary(DateTime from, DateTime to)
        {
            DataTable table = Fill("FinancialData",
                @"SELECT CASE GROUPING_ID(GenreName, MovieTitle, SessionDate)
                            WHEN 7 THEN 3
                            WHEN 3 THEN 0
                            WHEN 1 THEN 1
                            ELSE 2
                         END AS GroupLevel,
                         GenreName,
                         MovieTitle,
                         SessionDate,
                         COUNT(TicketID) AS TicketCount,
                         CAST(SUM(Price) AS DECIMAL(12,2)) AS GrossAmount,
                         CAST(SUM(PaidAmount) AS DECIMAL(12,2)) AS PaidAmount,
                         CAST(CASE WHEN SUM(Price) = 0 THEN 0
                                   ELSE SUM(PaidAmount) * 100.0 / SUM(Price)
                              END AS DECIMAL(6,2)) AS PaidPercent
                  FROM dbo.vw_FinancialData
                  WHERE SessionDate >= @from AND SessionDate <= @to
                  GROUP BY ROLLUP (GenreName, MovieTitle, SessionDate)
                  HAVING GROUPING_ID(GenreName, MovieTitle, SessionDate) IN (0, 1, 3, 7)
                  ORDER BY CASE WHEN GROUPING_ID(GenreName, MovieTitle, SessionDate) = 7 THEN 1 ELSE 0 END,
                           GenreName,
                           GROUPING(MovieTitle) DESC,
                           MovieTitle,
                           GROUPING(SessionDate) DESC,
                           SessionDate",
                new SqlParameter("@from", from.Date),
                new SqlParameter("@to", to.Date));

            table.Columns.Add("GroupLabel", typeof(string));
            foreach (DataRow row in table.Rows)
            {
                int level = Convert.ToInt32(row["GroupLevel"]);
                if (level == 0)
                    row["GroupLabel"] = Convert.ToString(row["GenreName"], CultureInfo.CurrentCulture);
                else if (level == 1)
                    row["GroupLabel"] = "\u00a0\u00a0" + Convert.ToString(row["MovieTitle"], CultureInfo.CurrentCulture);
                else if (level == 2)
                    row["GroupLabel"] = "\u00a0\u00a0\u00a0\u00a0" + Convert.ToDateTime(row["SessionDate"], CultureInfo.InvariantCulture).ToString("dd.MM.yyyy", CultureInfo.GetCultureInfo("uk-UA"));
                else
                    row["GroupLabel"] = "ЗАГАЛОМ";
            }

            return table;
        }
    }
}
