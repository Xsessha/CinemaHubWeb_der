using System;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using CinemaHubWeb.Data;
using Microsoft.Reporting.WebForms;

namespace CinemaHubWeb
{
    public partial class Analytics : Page
    {
        private static readonly string[] PieColors =
        {
            "#6366F1", "#06B6D4", "#10B981", "#F59E0B", "#EF4444",
            "#8B5CF6", "#14B8A6", "#F97316", "#3B82F6", "#84CC16"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFrom.Text = DateTime.Today.AddDays(-30).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                txtTo.Text = DateTime.Today.AddDays(30).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            }

            BindReport();
        }

        private void BindReport()
        {
            DateTime from;
            DateTime to;
            if (!DateTime.TryParseExact(txtFrom.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out from)
                || !DateTime.TryParseExact(txtTo.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out to))
            {
                ShowValidationError("Вкажіть коректні початкову та кінцеву дати.");
                return;
            }

            if (from.Date > to.Date)
            {
                ShowValidationError("Початкова дата не може бути пізнішою за кінцеву.");
                return;
            }

            DataTable summary = ReportData.GetFinancialSummary(from, to);
            litGenreChart.Text = BuildGenrePieChart(summary);

            rvFinancial.LocalReport.ReportPath = Server.MapPath("~/Reports/FinancialAnalytics.rdlc");
            rvFinancial.LocalReport.DataSources.Clear();
            rvFinancial.LocalReport.DataSources.Add(new ReportDataSource("FinancialData", summary));
            rvFinancial.LocalReport.SetParameters(new[]
            {
                new ReportParameter("ReportFrom", from.ToString("dd.MM.yyyy", CultureInfo.GetCultureInfo("uk-UA"))),
                new ReportParameter("ReportTo", to.ToString("dd.MM.yyyy", CultureInfo.GetCultureInfo("uk-UA")))
            });
            rvFinancial.LocalReport.Refresh();
            rvFinancial.Visible = summary.Rows.Count > 0;
            lblInfo.Text = summary.Rows.Count == 0 ? "За вибраний період квитків не знайдено." : string.Empty;
        }

        private void ShowValidationError(string message)
        {
            rvFinancial.Visible = false;
            litGenreChart.Text = string.Empty;
            lblInfo.Text = message;
        }

        private static string BuildGenrePieChart(DataTable summary)
        {
            DataTable genres = summary.Clone();
            foreach (DataRow row in summary.Rows)
            {
                if (Convert.ToInt32(row["GroupLevel"], CultureInfo.InvariantCulture) == 0)
                    genres.ImportRow(row);
            }

            decimal total = 0;
            foreach (DataRow row in genres.Rows)
                total += Convert.ToDecimal(row["PaidAmount"], CultureInfo.InvariantCulture);

            if (total <= 0)
                return "<div class=\"empty-chart\">Немає сплачених квитків для побудови діаграми.</div>";

            const double centerX = 145;
            const double centerY = 145;
            const double radius = 105;
            double currentAngle = -90;
            int colorIndex = 0;
            StringBuilder svg = new StringBuilder();
            svg.Append("<svg class=\"pie-chart\" viewBox=\"0 0 760 300\" role=\"img\" aria-label=\"Кругова діаграма сплачених сум за жанрами\">");
            svg.Append("<circle cx=\"145\" cy=\"145\" r=\"108\" fill=\"#ffffff\" stroke=\"#e2e8f0\" stroke-width=\"1\" />");

            foreach (DataRow row in genres.Rows)
            {
                decimal amount = Convert.ToDecimal(row["PaidAmount"], CultureInfo.InvariantCulture);
                if (amount <= 0)
                    continue;

                double sweep = (double)(amount / total) * 360;
                string color = PieColors[colorIndex++ % PieColors.Length];
                string genre = Convert.ToString(row["GenreName"], CultureInfo.CurrentCulture);
                double percent = (double)(amount / total) * 100;
                string title = HttpUtility.HtmlEncode(string.Format(
                    CultureInfo.GetCultureInfo("uk-UA"),
                    "{0}: {1:N2} грн ({2:N1}%)",
                    genre,
                    amount,
                    percent));

                if (sweep >= 359.999)
                {
                    svg.AppendFormat(CultureInfo.InvariantCulture,
                        "<circle cx=\"{0}\" cy=\"{1}\" r=\"{2}\" fill=\"{3}\"><title>{4}</title></circle>",
                        centerX, centerY, radius, color, title);
                }
                else
                {
                    double endAngle = currentAngle + sweep;
                    double startRadians = currentAngle * Math.PI / 180;
                    double endRadians = endAngle * Math.PI / 180;
                    double startX = centerX + radius * Math.Cos(startRadians);
                    double startY = centerY + radius * Math.Sin(startRadians);
                    double endX = centerX + radius * Math.Cos(endRadians);
                    double endY = centerY + radius * Math.Sin(endRadians);
                    int largeArc = sweep > 180 ? 1 : 0;

                    svg.AppendFormat(CultureInfo.InvariantCulture,
                        "<path d=\"M {0},{1} L {2},{3} A {4},{4} 0 {5} 1 {6},{7} Z\" fill=\"{8}\" stroke=\"#ffffff\" stroke-width=\"1\"><title>{9}</title></path>",
                        centerX, centerY, startX, startY, radius, largeArc, endX, endY, color, title);
                    currentAngle = endAngle;
                }
            }

            svg.Append("</svg><div class=\"chart-legend\">");
            colorIndex = 0;
            foreach (DataRow row in genres.Rows)
            {
                decimal amount = Convert.ToDecimal(row["PaidAmount"], CultureInfo.InvariantCulture);
                if (amount <= 0)
                    continue;

                string color = PieColors[colorIndex++ % PieColors.Length];
                string genre = HttpUtility.HtmlEncode(Convert.ToString(row["GenreName"], CultureInfo.CurrentCulture));
                string amountText = amount.ToString("N2", CultureInfo.GetCultureInfo("uk-UA"));
                string percentText = ((amount / total) * 100).ToString("N1", CultureInfo.GetCultureInfo("uk-UA"));
                svg.AppendFormat(CultureInfo.InvariantCulture,
                    "<div class=\"legend-item\"><span class=\"legend-swatch\" style=\"background-color:{0}\"></span><span>{1}</span><strong>{2} грн · {3}%</strong></div>",
                    color, genre, amountText, percentText);
            }

            svg.Append("</div>");
            return svg.ToString();
        }
    }
}
