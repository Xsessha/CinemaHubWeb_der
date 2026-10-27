using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CinemaHubWeb
{
    public partial class Default : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["CinemaHubConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGenres();
                LoadMovies();
            }
        }

        private void LoadGenres()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT GenreID, GenreName FROM Genres ORDER BY GenreName";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    ddlGenres.DataSource = dt;
                    ddlGenres.DataTextField = "GenreName";
                    ddlGenres.DataValueField = "GenreID";
                    ddlGenres.DataBind();
                }
            }
            ddlGenres.Items.Insert(0, new ListItem("Усі жанри", "0"));
        }

        private void LoadMovies()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT m.MovieID, m.Title, m.DurationMinutes, ISNULL(m.AgeRating, '16+') AS AgeRating, 
                               ISNULL(g.GenreName, 'Фільм') AS GenreName 
                               FROM Movies m 
                               LEFT JOIN Genres g ON m.GenreID = g.GenreID 
                               WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(txtSearch.Text))
                {
                    sql += " AND m.Title LIKE @Search";
                }

                if (ddlGenres.SelectedValue != "0" && !string.IsNullOrEmpty(ddlGenres.SelectedValue))
                {
                    sql += " AND m.GenreID = @GenreID";
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(txtSearch.Text))
                        cmd.Parameters.AddWithValue("@Search", "%" + txtSearch.Text.Trim() + "%");

                    if (ddlGenres.SelectedValue != "0" && !string.IsNullOrEmpty(ddlGenres.SelectedValue))
                        cmd.Parameters.AddWithValue("@GenreID", Convert.ToInt32(ddlGenres.SelectedValue));

                    conn.Open();
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                    rptMovies.DataSource = dt;
                    rptMovies.DataBind();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadMovies();
        }

        public string GetPosterUrl(string title)
        {
            if (string.IsNullOrEmpty(title)) return "https://picsum.photos/id/1069/400/600";

            string t = title.ToLower().Trim();

            if (t.Contains("дюна")) return "https://picsum.photos/id/1025/400/600";
            if (t.Contains("інтерстеллар") || t.Contains("interstellar")) return "https://picsum.photos/id/903/400/600";
            if (t.Contains("матриця") || t.Contains("matrix")) return "https://picsum.photos/id/1060/400/600";
            if (t.Contains("темний лицар") || t.Contains("dark knight")) return "https://picsum.photos/id/1043/400/600";
            if (t.Contains("джон уік") || t.Contains("john wick")) return "https://picsum.photos/id/1059/400/600";
            if (t.Contains("мад макс") || t.Contains("mad max")) return "https://picsum.photos/id/1074/400/600";
            if (t.Contains("оппенгеймер") || t.Contains("oppenheimer")) return "https://picsum.photos/id/1050/400/600";
            if (t.Contains("втеча з шоушенка") || t.Contains("shawshank")) return "https://picsum.photos/id/1028/400/600";
            if (t.Contains("думками навиворіт") || t.Contains("inside out")) return "https://picsum.photos/id/1062/400/600";
            if (t.Contains("унесені") || t.Contains("spirited away")) return "https://picsum.photos/id/1040/400/600";
            if (t.Contains("заняття") || t.Contains("conjuring")) return "https://picsum.photos/id/1058/400/600";
            if (t.Contains("тихе місце") || t.Contains("quiet place")) return "https://picsum.photos/id/1018/400/600";

            int hash = Math.Abs(t.GetHashCode()) % 1000 + 10;
            return string.Format("https://picsum.photos/id/{0}/400/600", hash);
        }
    }
}