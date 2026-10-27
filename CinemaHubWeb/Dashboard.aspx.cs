using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CinemaHubWeb
{
    public partial class Dashboard : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["CinemaHubConnection"].ConnectionString;

        public class SeatItem
        {
            public int RowNumber { get; set; }
            public int SeatNumber { get; set; }
            public bool IsVip { get; set; }
            public bool IsOccupied { get; set; }
            public bool IsSelected { get; set; }
        }

        public class RowItem
        {
            public int Row { get; set; }
            public List<SeatItem> Seats { get; set; }
        }

        public class ShowtimeItem
        {
            public string Time { get; set; }
            public bool IsPast { get; set; }
            public bool IsSelected { get; set; }
        }

        private List<string> SelectedSeatsList
        {
            get
            {
                if (ViewState["SelectedSeatsList"] == null)
                    ViewState["SelectedSeatsList"] = new List<string>();
                return (List<string>)ViewState["SelectedSeatsList"];
            }
            set
            {
                ViewState["SelectedSeatsList"] = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["SelectedTime"] = "";
                SelectedSeatsList = new List<string>();

                LoadMovies();

                if (Request.QueryString["movieId"] != null)
                {
                    ddlMovies.SelectedValue = Request.QueryString["movieId"];
                }

                InitDates();
                LoadShowtimes();
                LoadSeats();
                UpdateSummary();
            }
        }

        private void InitDates()
        {
            ddlBookingDate.Items.Clear();
            DateTime today = DateTime.Today;

            for (int i = 0; i < 3; i++)
            {
                DateTime d = today.AddDays(i);
                string text = d.ToString("dd.MM.yyyy") + (i == 0 ? " (Сьогодні)" : i == 1 ? " (Завтра)" : " (Післязавтра)");
                ddlBookingDate.Items.Add(new ListItem(text, d.ToString("yyyy-MM-dd")));
            }
        }

        private void LoadMovies()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT MovieID, Title FROM Movies ORDER BY Title";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    ddlMovies.DataSource = cmd.ExecuteReader();
                    ddlMovies.DataTextField = "Title";
                    ddlMovies.DataValueField = "MovieID";
                    ddlMovies.DataBind();
                }
            }
        }

        private void LoadShowtimes()
        {
            string[] times = new string[] { "10:00", "13:00", "16:00", "19:00", "21:30" };
            string selectedTime = ViewState["SelectedTime"].ToString();

            DateTime selectedDate = DateTime.Parse(ddlBookingDate.SelectedValue);
            bool isToday = selectedDate.Date == DateTime.Today;

            List<ShowtimeItem> list = new List<ShowtimeItem>();
            DateTime now = DateTime.Now;

            foreach (var t in times)
            {
                bool isPast = false;

                if (isToday)
                {
                    TimeSpan ts = TimeSpan.Parse(t);
                    if (now.TimeOfDay > ts)
                    {
                        isPast = true;
                    }
                }

                if (!isPast && string.IsNullOrEmpty(selectedTime))
                {
                    selectedTime = t;
                    ViewState["SelectedTime"] = t;
                }

                list.Add(new ShowtimeItem
                {
                    Time = t,
                    IsPast = isPast,
                    IsSelected = (t == selectedTime && !isPast)
                });
            }

            rptShowtimes.DataSource = list;
            rptShowtimes.DataBind();
        }

        private void LoadSeats()
        {
            HashSet<string> occupiedSeats = GetOccupiedSeatsFromDb();
            List<string> currentSelected = SelectedSeatsList;

            List<RowItem> rows = new List<RowItem>();

            for (int r = 1; r <= 6; r++)
            {
                List<SeatItem> seats = new List<SeatItem>();
                bool isVipRow = (r >= 5);

                for (int s = 1; s <= 8; s++)
                {
                    string seatKey = r + ":" + s;
                    seats.Add(new SeatItem
                    {
                        RowNumber = r,
                        SeatNumber = s,
                        IsVip = isVipRow,
                        IsOccupied = occupiedSeats.Contains(seatKey),
                        IsSelected = currentSelected.Contains(seatKey)
                    });
                }

                rows.Add(new RowItem { Row = r, Seats = seats });
            }

            rptSeats.DataSource = rows;
            rptSeats.DataBind();
        }

        private HashSet<string> GetOccupiedSeatsFromDb()
        {
            HashSet<string> set = new HashSet<string>();
            if (ddlMovies.SelectedValue == null) return set;

            string fullShowtimeStr = GetCurrentShowtimeString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT RowNumber, SeatNumber FROM Tickets WHERE MovieID = @MovieID AND ShowtimeInfo = @ShowtimeInfo";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@MovieID", Convert.ToInt32(ddlMovies.SelectedValue));
                    cmd.Parameters.AddWithValue("@ShowtimeInfo", fullShowtimeStr);

                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            set.Add(r["RowNumber"].ToString() + ":" + r["SeatNumber"].ToString());
                        }
                    }
                }
            }
            return set;
        }

        private string GetCurrentShowtimeString()
        {
            DateTime date = DateTime.Parse(ddlBookingDate.SelectedValue);
            string dateStr = date.ToString("dd.MM.yyyy");
            string format = ddlHallFormat.SelectedItem.Text;
            return string.Format("{0} {1} ({2})", dateStr, ViewState["SelectedTime"], format);
        }

        protected void ddlMovies_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetSeats();
        }

        protected void ddlHallFormat_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateSummary();
        }

        protected void ddlBookingDate_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["SelectedTime"] = "";
            ResetSeats();
            LoadShowtimes();
        }

        protected void SelectShowtime_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            ViewState["SelectedTime"] = btn.CommandArgument;
            ResetSeats();
            LoadShowtimes();
        }

        protected void SelectSeat_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string seatKey = btn.CommandArgument;

            List<string> selected = SelectedSeatsList;

            if (selected.Contains(seatKey))
            {
                selected.Remove(seatKey);
            }
            else
            {
                selected.Add(seatKey);
            }

            SelectedSeatsList = selected;

            if (selected.Count == 1)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "startTimer", "startHoldTimer();", true);
            }

            LoadSeats();
            UpdateSummary();
            updSeats.Update();
        }

        protected void ddlDiscountCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateSummary();
        }

        protected void Addon_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateSummary();
        }

        protected void btnResetSeats_Click(object sender, EventArgs e)
        {
            ResetSeats();
        }

        private void ResetSeats()
        {
            SelectedSeatsList = new List<string>();
            LoadSeats();
            UpdateSummary();
            updSeats.Update();
        }

        private void UpdateSummary()
        {
            List<string> selected = SelectedSeatsList;

            int popcornQty = Convert.ToInt32(ddlPopcornQty.SelectedValue);
            int glassesQty = Convert.ToInt32(ddlGlassesQty.SelectedValue);

            int addonsTotal = (popcornQty * 150) + (glassesQty * 30);

            litAddonsPrice.Text = addonsTotal + " грн";

            if (selected.Count == 0)
            {
                litSelectedSeat.Text = "Не обрано";
                litSeatType.Text = "-";
                litTotalPrice.Text = addonsTotal.ToString();
                litDiscountInfo.Text = "0%";
            }
            else
            {
                double totalPrice = 0;
                List<string> seatLabels = new List<string>();
                bool hasVip = false;
                bool hasStandard = false;

                int categoryDiscount = Convert.ToInt32(ddlDiscountCategory.SelectedValue);

                foreach (string item in selected)
                {
                    string[] parts = item.Split(':');
                    int r = int.Parse(parts[0]);
                    int s = int.Parse(parts[1]);

                    seatLabels.Add(string.Format("Р{0} М{1}", r, s));

                    bool isVip = r >= 5;
                    if (isVip) hasVip = true; else hasStandard = true;

                    double basePrice = isVip ? 200 : 120;
                    if (ddlHallFormat.SelectedValue == "Red_3D") basePrice += 30;
                    if (ddlHallFormat.SelectedValue == "VIP_IMAX") basePrice += 80;

                    double finalPrice = basePrice * (1.0 - (categoryDiscount / 100.0));
                    totalPrice += finalPrice;
                }

                totalPrice += addonsTotal;

                litSelectedSeat.Text = string.Join(", ", seatLabels) + " (" + selected.Count + " шт.)";
                litSeatType.Text = (hasVip && hasStandard) ? "Ззвичайні + VIP" : (hasVip ? "VIP Місця" : "Ззвичайні");
                litDiscountInfo.Text = categoryDiscount + "%";
                litTotalPrice.Text = Math.Round(totalPrice).ToString();
            }

            litSessionInfo.Text = GetCurrentShowtimeString();
            updSummary.Update();
        }

        protected void btnBuy_Click(object sender, EventArgs e)
        {
            List<string> selected = SelectedSeatsList;

            if (selected.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Будь ласка, оберіть хоча б одне місце в залі.');", true);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                foreach (string seatKey in selected)
                {
                    string[] parts = seatKey.Split(':');
                    int row = int.Parse(parts[0]);
                    int seat = int.Parse(parts[1]);

                    string sql = @"INSERT INTO Tickets (MovieID, CustomerName, RowNumber, SeatNumber, ShowtimeInfo, SessionID, PurchaseDate, DiscountPercent, PaymentMethod, PaymentStatus) 
                                   VALUES (@MovieID, @CustomerName, @RowNumber, @SeatNumber, @ShowtimeInfo, @SessionID, GETDATE(), @DiscountPercent, @PaymentMethod, @PaymentStatus)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MovieID", Convert.ToInt32(ddlMovies.SelectedValue));
                        cmd.Parameters.AddWithValue("@CustomerName", txtCustomerName.Text.Trim());
                        cmd.Parameters.AddWithValue("@RowNumber", row);
                        cmd.Parameters.AddWithValue("@SeatNumber", seat);
                        cmd.Parameters.AddWithValue("@ShowtimeInfo", GetCurrentShowtimeString());
                        cmd.Parameters.AddWithValue("@SessionID", 1);
                        cmd.Parameters.AddWithValue("@DiscountPercent", Convert.ToInt32(ddlDiscountCategory.SelectedValue));
                        cmd.Parameters.AddWithValue("@PaymentMethod", ddlPaymentMethod.SelectedValue);
                        cmd.Parameters.AddWithValue("@PaymentStatus", "Paid");

                        cmd.ExecuteNonQuery();
                    }
                }
            }

            Response.Redirect("MyTickets.aspx");
        }
    }
}