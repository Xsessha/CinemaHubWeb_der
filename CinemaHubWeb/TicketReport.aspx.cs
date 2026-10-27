using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using CinemaHubWeb.Data;
using Microsoft.Reporting.WebForms;

namespace CinemaHubWeb
{
    public partial class TicketReport : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlTickets.DataSource = ReportData.GetTicketList();
                ddlTickets.DataTextField = "Caption";
                ddlTickets.DataValueField = "TicketID";
                ddlTickets.DataBind();

                string id = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(id) && ddlTickets.Items.FindByValue(id) != null)
                    ddlTickets.SelectedValue = id;
            }

            ShowReport();
        }

        private void ShowReport()
        {
            int ticketId;
            if (!int.TryParse(ddlTickets.SelectedValue, out ticketId))
            {
                rvTicket.Visible = false;
                return;
            }

            LocalReport report = rvTicket.LocalReport;
            report.ReportPath = Server.MapPath("~/Reports/TicketReport.rdlc");
            report.DataSources.Clear();
            report.DataSources.Add(new ReportDataSource("TicketDS", ReportData.GetTicket(ticketId)));
            report.SetParameters(new[] { new ReportParameter("VatPercent", "20") });
            report.SubreportProcessing += OnSubreportProcessing;
        }

        private void OnSubreportProcessing(object sender, SubreportProcessingEventArgs e)
        {
            int ticketId = int.Parse(e.Parameters["TicketID"].Values[0]);
            e.DataSources.Add(new ReportDataSource("PriceDS", ReportData.GetPriceBreakdown(ticketId)));
        }
    }
}
