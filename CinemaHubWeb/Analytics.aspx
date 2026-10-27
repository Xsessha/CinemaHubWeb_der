<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="CinemaHubWeb.Analytics" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=15.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dershprom Cinema - Фінансова аналітика (RDLC)</title>
    <style>
        body { margin: 0; padding: 0; background: #090d16; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #f8fafc; }
        .header { background: #0f172a; padding: 15px 50px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #1e293b; }
        .logo-box { display: flex; align-items: center; gap: 20px; }
        .logo { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; font-weight: 800; padding: 8px 18px; font-size: 22px; border-radius: 8px; text-decoration: none; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { color: #94a3b8; text-decoration: none; font-weight: 600; font-size: 15px; }
        .nav-links a:hover, .nav-links a.active { color: #c084fc; }
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .filter-bar { background: #0f172a; padding: 15px 20px; border-radius: 10px; border: 1px solid #1e293b; display: flex; gap: 15px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }
        .ctl { background: #131b2e; border: 1px solid #334155; color: #fff; padding: 10px 15px; border-radius: 6px; font-size: 14px; outline: none; }
        .btn { background: #6366f1; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }
        .note { color: #fbbf24; font-size: 14px; }
        .chart-card { background: #0f172a; border: 1px solid #1e293b; border-radius: 10px; padding: 18px 24px; margin-bottom: 20px; }
        .chart-title { color: #f8fafc; font-size: 18px; font-weight: 700; margin: 0 0 12px; }
        .chart-content { display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
        .pie-chart { width: min(100%, 500px); height: auto; }
        .chart-legend { display: grid; gap: 8px; flex: 1; min-width: 280px; }
        .legend-item { display: grid; grid-template-columns: 14px minmax(100px, 1fr) auto; gap: 10px; align-items: center; color: #cbd5e1; font-size: 13px; }
        .legend-item strong { color: #f8fafc; white-space: nowrap; }
        .legend-swatch { width: 12px; height: 12px; border-radius: 3px; }
        .empty-chart { color: #94a3b8; padding: 18px 0; }
        .viewer { background: #fff; border-radius: 10px; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
            <div class="header">
                <div class="logo-box">
                    <a href="Default.aspx" class="logo">Dershprom Cinema</a>
                    <div class="nav-links">
                        <a href="Default.aspx">АФІША</a>
                        <a href="Dashboard.aspx">БРОНЮВАННЯ</a>
                        <a href="MyTickets.aspx">МОЇ КВИТКИ</a>
                        <a href="Analytics.aspx" class="active">АНАЛІТИКА</a>
                    </div>
                </div>
            </div>
        <div class="container">
            <div class="filter-bar">
                <span>Період сеансів:</span>
                <asp:TextBox ID="txtFrom" runat="server" TextMode="Date" CssClass="ctl" />
                <span>—</span>
                <asp:TextBox ID="txtTo" runat="server" TextMode="Date" CssClass="ctl" />
                <asp:Button ID="btnApply" runat="server" Text="Сформувати" CssClass="btn" />
            </div>
            <asp:Label ID="lblInfo" runat="server" CssClass="note" />
            <div class="chart-card">
                <h2 class="chart-title">Сплачені касові збори за жанрами</h2>
                <div class="chart-content">
                    <asp:Literal ID="litGenreChart" runat="server" Mode="PassThrough" />
                </div>
            </div>
            <div class="viewer">
                <rsweb:ReportViewer ID="rvFinancial" runat="server" ProcessingMode="Local" Width="100%" Height="850px"
                    AsyncRendering="false" SizeToReportContent="false" ShowExportControls="true" />
            </div>
        </div>
    </form>
</body>
</html>
