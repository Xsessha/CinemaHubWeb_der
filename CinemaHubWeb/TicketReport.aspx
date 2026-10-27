<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TicketReport.aspx.cs" Inherits="CinemaHubWeb.TicketReport" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=15.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dershprom Cinema - Електронний квиток (звіт RDLC)</title>
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
                        <a href="Analytics.aspx">АНАЛІТИКА</a>
                    </div>
                </div>
            </div>
        <div class="container">
            <div class="filter-bar">
                <span>Квиток:</span>
                <asp:DropDownList ID="ddlTickets" runat="server" CssClass="ctl" Width="640px" AutoPostBack="true" />
                <span class="note">Операційний звіт MS Report (RDLC): ПДВ, статус оплати, підзвіт «Склад вартості»</span>
            </div>
            <div class="viewer">
                <rsweb:ReportViewer ID="rvTicket" runat="server" ProcessingMode="Local" Width="100%" Height="980px"
                    AsyncRendering="false" SizeToReportContent="false" BackColor="White" />
            </div>
        </div>
    </form>
</body>
</html>
