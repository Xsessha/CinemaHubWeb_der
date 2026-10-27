using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CinemaHubWeb
{
    public partial class MyTickets : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["CinemaHubConnection"].ConnectionString;

        public class TicketViewModel
        {
            public int TicketID { get; set; }
            public string MovieTitle { get; set; }
            public string CustomerName { get; set; }
            public int RowNumber { get; set; }
            public int SeatNumber { get; set; }
            public string ShowtimeInfo { get; set; }
            public bool IsActive { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTickets();
            }
        }

        private void LoadTickets()
        {
            List<TicketViewModel> activeList = new List<TicketViewModel>();
            List<TicketViewModel> archivedList = new List<TicketViewModel>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT t.TicketID, ISNULL(m.Title, 'Невідомий фільм') AS MovieTitle, 
                           t.CustomerName, t.RowNumber, t.SeatNumber, t.ShowtimeInfo, t.PurchaseDate
                    FROM Tickets t
                    LEFT JOIN Movies m ON t.MovieID = m.MovieID
                    ORDER BY t.TicketID DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string showtime = r["ShowtimeInfo"] != DBNull.Value ? r["ShowtimeInfo"].ToString() : "";
                            DateTime purchaseDate = r["PurchaseDate"] != DBNull.Value ? Convert.ToDateTime(r["PurchaseDate"]) : DateTime.Now;

                            DateTime sessionTime = ParseShowtimeToDateTime(showtime, purchaseDate);

                            TicketViewModel item = new TicketViewModel
                            {
                                TicketID = Convert.ToInt32(r["TicketID"]),
                                MovieTitle = r["MovieTitle"].ToString(),
                                CustomerName = r["CustomerName"] != DBNull.Value ? r["CustomerName"].ToString() : "Глядач",
                                RowNumber = r["RowNumber"] != DBNull.Value ? Convert.ToInt32(r["RowNumber"]) : 0,
                                SeatNumber = r["SeatNumber"] != DBNull.Value ? Convert.ToInt32(r["SeatNumber"]) : 0,
                                ShowtimeInfo = showtime,
                                IsActive = sessionTime >= DateTime.Now
                            };

                            if (item.IsActive)
                            {
                                activeList.Add(item);
                            }
                            else
                            {
                                archivedList.Add(item);
                            }
                        }
                    }
                }
            }

            rptActiveTickets.DataSource = activeList;
            rptActiveTickets.DataBind();

            rptArchivedTickets.DataSource = archivedList;
            rptArchivedTickets.DataBind();
        }

        private DateTime ParseShowtimeToDateTime(string showtime, DateTime purchaseDate)
        {
            if (string.IsNullOrWhiteSpace(showtime)) return purchaseDate;

            try
            {
                Match timeMatch = Regex.Match(showtime, @"(\d{1,2}):(\d{2})");
                int hour = timeMatch.Success ? int.Parse(timeMatch.Groups[1].Value) : 0;
                int minute = timeMatch.Success ? int.Parse(timeMatch.Groups[2].Value) : 0;

                Match dateMatch = Regex.Match(showtime, @"(\d{2})\.(\d{2})\.(\d{4})");
                if (dateMatch.Success)
                {
                    int day = int.Parse(dateMatch.Groups[1].Value);
                    int month = int.Parse(dateMatch.Groups[2].Value);
                    int year = int.Parse(dateMatch.Groups[3].Value);

                    return new DateTime(year, month, day, hour, minute, 0);
                }

                return purchaseDate;
            }
            catch
            {
                return purchaseDate;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int ticketId = Convert.ToInt32(btn.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "DELETE FROM Tickets WHERE TicketID = @TicketID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@TicketID", ticketId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            LoadTickets();
        }

        protected void btnClearHistory_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "DELETE FROM Tickets";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            LoadTickets();
        }
    }
}