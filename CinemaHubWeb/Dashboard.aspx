<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="CinemaHubWeb.Dashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dershprom Cinema - Бронювання</title>
    <style>
        body { margin: 0; padding: 0; background: #090d16; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #f8fafc; }
        .header { background: #0f172a; padding: 15px 50px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #1e293b; }
        .logo-box { display: flex; align-items: center; gap: 20px; }
        .logo { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; font-weight: 800; padding: 8px 18px; font-size: 22px; border-radius: 8px; text-decoration: none; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { color: #94a3b8; text-decoration: none; font-weight: 600; font-size: 15px; }
        .nav-links a:hover, .nav-links a.active { color: #c084fc; }

        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; display: grid; grid-template-columns: 1fr 380px; gap: 30px; }
        .box { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; padding: 25px; }

        .section-title { font-size: 18px; font-weight: 700; margin-bottom: 15px; color: #f8fafc; display: flex; justify-content: space-between; align-items: center; }
        
        .timer-badge { background: #3b82f6; color: #fff; font-size: 13px; font-weight: bold; padding: 4px 10px; border-radius: 20px; display: none; }
        .timer-badge.active { display: inline-block; animation: pulse 1.5s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.6; } 100% { opacity: 1; } }

        .selector-group { margin-bottom: 20px; }
        .btn-option { background: #131b2e; border: 1px solid #334155; color: #cbd5e1; padding: 8px 16px; border-radius: 6px; cursor: pointer; margin-right: 8px; margin-bottom: 8px; font-weight: 600; }
        .btn-option.active { background: #6366f1; color: #fff; border-color: #6366f1; }
        .btn-option.disabled { opacity: 0.4; cursor: not-allowed; text-decoration: line-through; }

        .screen { background: linear-gradient(to bottom, rgba(99, 102, 241, 0.4), transparent); height: 35px; width: 80%; margin: 20px auto 30px auto; border-top: 3px solid #6366f1; text-align: center; color: #94a3b8; font-size: 12px; letter-spacing: 4px; padding-top: 5px; }
        
        .seats-grid { display: flex; flex-direction: column; gap: 10px; align-items: center; margin-bottom: 25px; }
        .seat-row { display: flex; gap: 10px; align-items: center; }
        .row-num { font-size: 12px; color: #64748b; width: 50px; text-align: right; margin-right: 10px; }
        
        .seat-btn { width: 34px; height: 34px; border-radius: 6px; border: 1px solid #334155; background: #131b2e; color: #cbd5e1; font-size: 11px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; }
        .seat-btn.vip { border-color: #f59e0b; color: #fbbf24; }
        .seat-btn.selected { background: #22c55e !important; color: #fff !important; border-color: #22c55e !important; }
        .seat-btn.occupied { background: #ef4444 !important; color: #fff !important; border-color: #ef4444 !important; cursor: not-allowed; }

        .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14px; color: #94a3b8; }
        .summary-row strong { color: #f8fafc; }
        .price-total { font-size: 22px; font-weight: 800; color: #22c55e; }

        .form-control { width: 100%; background: #131b2e; border: 1px solid #334155; color: #fff; padding: 10px; border-radius: 6px; box-sizing: border-box; margin-top: 4px; margin-bottom: 12px; outline: none; }
        .form-control:focus { border-color: #6366f1; }
        
        .addon-box { background: #131b2e; border: 1px solid #1e293b; padding: 10px 14px; border-radius: 8px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; }

        .btn-submit { width: 100%; background: linear-gradient(135deg, #22c55e, #16a34a); color: #fff; border: none; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 10px; transition: transform 0.1s; }
        .btn-submit:active { transform: scale(0.98); }

        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.85); z-index: 1000; justify-content: center; align-items: center; }
        .modal-body { background: #0f172a; border: 1px solid #334155; padding: 30px; border-radius: 12px; width: 360px; text-align: center; }
        .loader { border: 4px solid #131b2e; border-top: 4px solid #22c55e; border-radius: 50%; width: 36px; height: 36px; animation: spin 1s linear infinite; margin: 15px auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
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
                    <a href="Dashboard.aspx" class="active">БРОНЮВАННЯ</a>
                    <a href="MyTickets.aspx">МОЇ КВИТКИ</a>
                    <a href="Analytics.aspx">АНАЛІТИКА</a>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="box">
                <div class="section-title">
                    <span>1. Фільм та Параметри</span>
                    <span id="timerBadge" class="timer-badge">Бронювання: <span id="timerText">05:00</span></span>
                </div>

                <div class="selector-group">
                    <asp:DropDownList ID="ddlMovies" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlMovies_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div class="selector-group">
                    <div style="font-size:13px; color:#94a3b8; margin-bottom:8px;">Формат та Зал:</div>
                    <asp:DropDownList ID="ddlHallFormat" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlHallFormat_SelectedIndexChanged">
                        <asp:ListItem Text="Синій Зал (2D)" Value="Blue_2D" />
                        <asp:ListItem Text="Червоний Зал (3D) + 30 грн" Value="Red_3D" />
                        <asp:ListItem Text="VIP Зал (IMAX) + 80 грн" Value="VIP_IMAX" />
                    </asp:DropDownList>
                </div>

                <div class="selector-group">
                    <div style="font-size:13px; color:#94a3b8; margin-bottom:8px;">Дата:</div>
                    <asp:DropDownList ID="ddlBookingDate" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlBookingDate_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div class="selector-group">
                    <div style="font-size:13px; color:#94a3b8; margin-bottom:8px;">Час сеансу:</div>
                    <asp:Repeater ID="rptShowtimes" runat="server">
                        <ItemTemplate>
                            <asp:Button ID="btnShowtime" runat="server" 
                                CssClass='<%# "btn-option " + (Convert.ToBoolean(Eval("IsPast")) ? "disabled" : (Convert.ToBoolean(Eval("IsSelected")) ? "active" : "")) %>' 
                                Text='<%# Eval("Time") %>' 
                                Enabled='<%# !Convert.ToBoolean(Eval("IsPast")) %>' 
                                OnClick="SelectShowtime_Click" 
                                CommandArgument='<%# Eval("Time") %>' />
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="screen">ЕКРАН</div>

                <asp:UpdatePanel ID="updSeats" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="seats-grid">
                            <asp:Repeater ID="rptSeats" runat="server">
                                <ItemTemplate>
                                    <div class="seat-row">
                                        <span class="row-num">Ряд <%# Eval("Row") %></span>
                                        <asp:Repeater ID="rptSeatItems" runat="server" DataSource='<%# Eval("Seats") %>'>
                                            <ItemTemplate>
                                                <asp:Button ID="btnSeat" runat="server" 
                                                    CssClass='<%# "seat-btn " + (Convert.ToBoolean(Eval("IsVip")) ? "vip " : "") + (Convert.ToBoolean(Eval("IsOccupied")) ? "occupied " : "") + (Convert.ToBoolean(Eval("IsSelected")) ? "selected" : "") %>' 
                                                    Text='<%# Eval("SeatNumber") %>' 
                                                    Enabled='<%# !Convert.ToBoolean(Eval("IsOccupied")) %>' 
                                                    OnClick="SelectSeat_Click" 
                                                    CommandArgument='<%# Eval("RowNumber") + ":" + Eval("SeatNumber") %>' />
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <div class="box" style="height: fit-content;">
                <div class="section-title">2. Деталі та Оплата</div>
                
                <div class="selector-group">
                    <label style="font-size:12px; color:#94a3b8;">Категорія квитка:</label>
                    <asp:DropDownList ID="ddlDiscountCategory" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlDiscountCategory_SelectedIndexChanged">
                        <asp:ListItem Text="Звичайний (без знижки)" Value="0" />
                        <asp:ListItem Text="Студентський / Дитячий (-20%)" Value="20" />
                        <asp:ListItem Text="Пенсійний (-30%)" Value="30" />
                    </asp:DropDownList>
                </div>

                <div style="margin-bottom: 15px;">
                    <label style="font-size:12px; color:#94a3b8; display:block; margin-bottom:8px;">Додаткові товари та послуги:</label>
                    
                    <div class="addon-box">
                        <div style="font-size:13px; color:#e2e8f0;">Попкорн (L) + Cola (+150 грн)</div>
                        <asp:DropDownList ID="ddlPopcornQty" runat="server" CssClass="form-control" Style="width:70px; margin:0;" AutoPostBack="true" OnSelectedIndexChanged="Addon_SelectedIndexChanged">
                            <asp:ListItem Text="0" Value="0" />
                            <asp:ListItem Text="1" Value="1" />
                            <asp:ListItem Text="2" Value="2" />
                            <asp:ListItem Text="3" Value="3" />
                            <asp:ListItem Text="4" Value="4" />
                            <asp:ListItem Text="5" Value="5" />
                        </asp:DropDownList>
                    </div>

                    <div class="addon-box">
                        <div style="font-size:13px; color:#e2e8f0;">Персональні 3D-окуляри (+30 грн)</div>
                        <asp:DropDownList ID="ddlGlassesQty" runat="server" CssClass="form-control" Style="width:70px; margin:0;" AutoPostBack="true" OnSelectedIndexChanged="Addon_SelectedIndexChanged">
                            <asp:ListItem Text="0" Value="0" />
                            <asp:ListItem Text="1" Value="1" />
                            <asp:ListItem Text="2" Value="2" />
                            <asp:ListItem Text="3" Value="3" />
                            <asp:ListItem Text="4" Value="4" />
                            <asp:ListItem Text="5" Value="5" />
                        </asp:DropDownList>
                    </div>
                </div>

                <asp:UpdatePanel ID="updSummary" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="summary-row"><span>Місця:</span> <strong><asp:Literal ID="litSelectedSeat" runat="server" Text="Не обрано"></asp:Literal></strong></div>
                        <div class="summary-row"><span>Тип місць:</span> <strong><asp:Literal ID="litSeatType" runat="server" Text="-"></asp:Literal></strong></div>
                        <div class="summary-row"><span>Сеанс:</span> <strong><asp:Literal ID="litSessionInfo" runat="server" Text="-"></asp:Literal></strong></div>
                        <div class="summary-row"><span>Знижка:</span> <strong><asp:Literal ID="litDiscountInfo" runat="server" Text="0%"></asp:Literal></strong></div>
                        <div class="summary-row"><span>Дод. товари:</span> <strong><asp:Literal ID="litAddonsPrice" runat="server" Text="0 грн"></asp:Literal></strong></div>
                        <hr style="border:0; border-top:1px solid #1e293b; margin:12px 0;" />
                        <div class="summary-row"><span>Разом:</span> <span class="price-total"><asp:Literal ID="litTotalPrice" runat="server" Text="0"></asp:Literal> грн</span></div>
                    </ContentTemplate>
                </asp:UpdatePanel>

                <div style="margin-top:15px;">
                    <label style="font-size:12px; color:#94a3b8;">Ім'я та Прізвище:</label>
                    <asp:TextBox ID="txtCustomerName" runat="server" CssClass="form-control" Placeholder="Іван Іванов"></asp:TextBox>

                    <label style="font-size:12px; color:#94a3b8;">Email (для відправки QR-квитка):</label>
                    <asp:TextBox ID="txtCustomerEmail" runat="server" CssClass="form-control" Placeholder="user@example.com" TextMode="Email"></asp:TextBox>

                    <label style="font-size:12px; color:#94a3b8;">Telegram (для нагадування про сеанс):</label>
                    <asp:TextBox ID="txtTelegram" runat="server" CssClass="form-control" Placeholder="@username або телефон"></asp:TextBox>

                    <label style="font-size:12px; color:#94a3b8;">Спосіб оплати:</label>
                    <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-control" onchange="togglePaymentFields()">
                        <asp:ListItem Text="Банківська картка" Value="Card" />
                        <asp:ListItem Text="Apple Pay" Value="ApplePay" />
                        <asp:ListItem Text="Google Pay" Value="GooglePay" />
                        <asp:ListItem Text="LiqPay" Value="LiqPay" />
                        <asp:ListItem Text="Monobank Pay" Value="MonoPay" />
                    </asp:DropDownList>

                    <div id="cardPaymentBox">
                        <label style="font-size:12px; color:#94a3b8;">Номер карти:</label>
                        <asp:TextBox ID="txtCardNumber" runat="server" CssClass="form-control" Placeholder="4111 •••• •••• 1111" MaxLength="19"></asp:TextBox>
                    </div>

                    <button type="button" class="btn-submit" onclick="startPayment()">Сплатити та забронювати</button>
                    <asp:Button ID="btnRealSubmit" runat="server" OnClick="btnBuy_Click" Style="display:none;" />
                    <asp:Button ID="btnResetSeats" runat="server" OnClick="btnResetSeats_Click" Style="display:none;" />
                </div>
            </div>
        </div>

        <div id="paymentModal" class="modal-overlay">
            <div class="modal-body">
                <div class="loader"></div>
                <div id="modalTitle" style="font-size:16px; font-weight:bold; margin-bottom:5px;">Обробка платежу...</div>
                <div style="font-size:12px; color:#94a3b8;">Формування електронного квитка з QR-кодом</div>
            </div>
        </div>
    </form>

    <script>
        var timerInterval = null;
        var timeLeft = 300;

        function startHoldTimer() {
            var badge = document.getElementById('timerBadge');
            var timerText = document.getElementById('timerText');
            badge.classList.add('active');

            if (timerInterval) clearInterval(timerInterval);

            timerInterval = setInterval(function () {
                timeLeft--;
                var m = Math.floor(timeLeft / 60);
                var s = timeLeft % 60;
                timerText.innerText = (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);

                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    alert("Час утримання місць вичерпано! Ваша бронь скинута.");
                    document.getElementById('<%= btnResetSeats.ClientID %>').click();
                }
            }, 1000);
        }

        function togglePaymentFields() {
            var method = document.getElementById('<%= ddlPaymentMethod.ClientID %>').value;
            var cardBox = document.getElementById('cardPaymentBox');
            if (method === 'Card') {
                cardBox.style.display = 'block';
            } else {
                cardBox.style.display = 'none';
            }
        }

        function startPayment() {
            var name = document.getElementById('<%= txtCustomerName.ClientID %>').value.trim();
            var email = document.getElementById('<%= txtCustomerEmail.ClientID %>').value.trim();
            var method = document.getElementById('<%= ddlPaymentMethod.ClientID %>').value;
            
            if (name === "") {
                alert("Будь ласка, введіть ім'я глядача.");
                return;
            }
            if (email === "" || !email.includes("@")) {
                alert("Будь ласка, введіть коректну електронну пошту для отримання квитка.");
                return;
            }

            if (method === 'Card') {
                var card = document.getElementById('<%= txtCardNumber.ClientID %>').value.trim();
                if (card.length < 12) {
                    alert("Введіть коректний номер банківської карти.");
                    return;
                }
            }

            var modalTitle = document.getElementById('modalTitle');
            if (method === 'ApplePay') modalTitle.innerText = "Авторизація через Apple Pay...";
            else if (method === 'GooglePay') modalTitle.innerText = "Авторизація через Google Pay...";
            else if (method === 'LiqPay') modalTitle.innerText = "Перенаправлення на LiqPay...";
            else if (method === 'MonoPay') modalTitle.innerText = "Підтвердження в застосунку Monobank...";
            else modalTitle.innerText = "Обробка платежу...";

            document.getElementById('paymentModal').style.display = 'flex';
            
            setTimeout(function () {
                document.getElementById('<%= btnRealSubmit.ClientID %>').click();
            }, 1800);
        }
    </script>
</body>
</html>