<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyTickets.aspx.cs" Inherits="CinemaHubWeb.MyTickets" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dershprom Cinema - Мої квитки</title>
    <style>
        body { margin: 0; padding: 0; background: #090d16; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #f8fafc; }
        
        .header { background: #0f172a; padding: 15px 50px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #1e293b; }
        .logo-box { display: flex; align-items: center; gap: 20px; }
        .logo { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; font-weight: 800; padding: 8px 18px; font-size: 22px; border-radius: 8px; text-decoration: none; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { color: #94a3b8; text-decoration: none; font-weight: 600; font-size: 15px; }
        .nav-links a:hover, .nav-links a.active { color: #c084fc; }

        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: 800; }
        
        .btn-clear { background: #ef4444; color: #fff; border: none; padding: 10px 18px; border-radius: 6px; font-weight: 600; cursor: pointer; }

        .tickets-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
        .section-box { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; padding: 20px; }
        .section-header { font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #1e293b; }
        .dot-active { width: 10px; height: 10px; background: #22c55e; border-radius: 50%; display: inline-block; }
        .dot-archive { width: 10px; height: 10px; background: #64748b; border-radius: 50%; display: inline-block; }

        .ticket-card { background: #131b2e; border: 1px solid #1e293b; border-radius: 8px; padding: 16px; margin-bottom: 15px; position: relative; }
        .ticket-card.archived { opacity: 0.65; }
        .movie-name { font-size: 16px; font-weight: 700; color: #f8fafc; margin-bottom: 8px; }
        .ticket-info { font-size: 13px; color: #94a3b8; line-height: 1.6; }
        .ticket-info strong { color: #cbd5e1; }
        
        .actions-bar { margin-top: 15px; display: flex; gap: 10px; }
        .btn-qr { background: #6366f1; color: #fff; border: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; }
        .btn-cancel { background: #334155; color: #f8fafc; border: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; }
        .btn-cancel:hover { background: #ef4444; }

        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.8); z-index: 1000; justify-content: center; align-items: center; }
        .ticket-modal { background: #0f172a; border: 2px dashed #6366f1; padding: 25px; border-radius: 16px; width: 320px; text-align: center; position: relative; }
        .qr-code { width: 150px; height: 150px; margin: 15px auto; background: #fff; padding: 10px; border-radius: 8px; }
        .close-btn { position: absolute; top: 10px; right: 15px; color: #94a3b8; font-size: 20px; cursor: pointer; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <div class="logo-box">
                <a href="Default.aspx" class="logo">Dershprom Cinema</a>
                <div class="nav-links">
                    <a href="Default.aspx">АФІША</a>
                    <a href="Dashboard.aspx">БРОНЮВАННЯ</a>
                    <a href="MyTickets.aspx" class="active">МОЇ КВИТКИ</a>
                    <a href="Analytics.aspx">АНАЛІТИКА</a>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <div class="page-title">Придбані квитки</div>
                <asp:Button ID="btnClearHistory" runat="server" Text="Очистити історію" CssClass="btn-clear" OnClick="btnClearHistory_Click" />
            </div>

            <div class="tickets-grid">
                <div class="section-box">
                    <div class="section-header">
                        <span class="dot-active"></span> Дійсні квитки
                    </div>
                    <asp:Repeater ID="rptActiveTickets" runat="server">
                        <ItemTemplate>
                            <div class="ticket-card">
                                <div class="movie-name"><%# Eval("MovieTitle") %></div>
                                <div class="ticket-info">
                                    Глядач: <strong><%# Eval("CustomerName") %></strong><br />
                                    Місце: <strong>Ряд <%# Eval("RowNumber") %>, Місце <%# Eval("SeatNumber") %></strong><br />
                                    Час: <strong><%# Eval("ShowtimeInfo") %></strong>
                                </div>
                                <div class="actions-bar">
                                    <button type="button" class="btn-qr" onclick='showTicketModal("<%# Eval("MovieTitle") %>", "<%# Eval("CustomerName") %>", "<%# Eval("RowNumber") %>", "<%# Eval("SeatNumber") %>", "<%# Eval("TicketID") %>")'>Електронний квиток</button>
                                    <a class="btn-qr" href='TicketReport.aspx?id=<%# Eval("TicketID") %>' target="_blank" style="text-decoration:none; display:inline-block;">Звіт (RDLC)</a>
                                    <asp:Button ID="btnCancel" runat="server" Text="Скасувати квиток" CssClass="btn-cancel" OnClick="btnCancel_Click" CommandArgument='<%# Eval("TicketID") %>' />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-box">
                    <div class="section-header">
                        <span class="dot-archive"></span> Минулі сеанси (Архів)
                    </div>
                    <asp:Repeater ID="rptArchivedTickets" runat="server">
                        <ItemTemplate>
                            <div class="ticket-card archived">
                                <div class="movie-name"><%# Eval("MovieTitle") %></div>
                                <div class="ticket-info">
                                    Глядач: <strong><%# Eval("CustomerName") %></strong><br />
                                    Місце: <strong>Ряд <%# Eval("RowNumber") %>, Місце <%# Eval("SeatNumber") %></strong><br />
                                    Час: <strong><%# Eval("ShowtimeInfo") %></strong>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <div id="qrModal" class="modal-overlay">
            <div class="ticket-modal">
                <span class="close-btn" onclick="closeModal()">&times;</span>
                <div style="font-size:12px; color:#8b5cf6; font-weight:bold; letter-spacing:2px;">ELECTRONIC TICKET</div>
                <div id="mMovie" style="font-size:18px; font-weight:bold; margin-top:5px; color:#fff;"></div>
                <div id="mName" style="font-size:13px; color:#94a3b8; margin-top:2px;"></div>
                <div id="mSeat" style="font-size:14px; font-weight:bold; color:#22c55e; margin-top:10px;"></div>
                
                <img id="mQr" class="qr-code" src="" alt="QR Code" />
                <div style="font-size:10px; color:#64748b;">Покажіть цей QR-код при вході у зал</div>
            </div>
        </div>
    </form>

    <script>
        function showTicketModal(movie, name, row, seat, ticketId) {
            document.getElementById('mMovie').innerText = movie;
            document.getElementById('mName').innerText = "Глядач: " + name;
            document.getElementById('mSeat').innerText = "Ряд " + row + ", Місце " + seat;

            var qrData = encodeURIComponent("TICKET:" + ticketId + "|" + movie + "|ROW:" + row + "|SEAT:" + seat);
            document.getElementById('mQr').src = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" + qrData;

            document.getElementById('qrModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('qrModal').style.display = 'none';
        }
    </script>
</body>
</html>