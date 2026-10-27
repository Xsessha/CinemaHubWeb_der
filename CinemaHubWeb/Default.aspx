<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CinemaHubWeb.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dershprom Cinema - Афіша</title>
    <style>
        body { margin: 0; padding: 0; background: #090d16; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #f8fafc; }
        .header { background: #0f172a; padding: 15px 50px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #1e293b; }
        .logo-box { display: flex; align-items: center; gap: 20px; }
        .logo { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; font-weight: 800; padding: 8px 18px; font-size: 22px; border-radius: 8px; text-decoration: none; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { color: #94a3b8; text-decoration: none; font-weight: 600; font-size: 15px; }
        .nav-links a:hover, .nav-links a.active { color: #c084fc; }

        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        
        .filter-bar { background: #0f172a; padding: 15px 20px; border-radius: 10px; border: 1px solid #1e293b; display: flex; gap: 15px; align-items: center; margin-bottom: 30px; flex-wrap: wrap; }
        .txt-search { background: #131b2e; border: 1px solid #334155; color: #fff; padding: 10px 15px; border-radius: 6px; width: 250px; font-size: 14px; outline: none; }
        .ddl-filter { background: #131b2e; border: 1px solid #334155; color: #fff; padding: 10px 15px; border-radius: 6px; font-size: 14px; outline: none; }
        .btn-filter { background: #6366f1; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }

        .movies-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 25px; }
        .movie-card { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; overflow: hidden; display: flex; flex-direction: column; transition: transform 0.2s; }
        .movie-card:hover { transform: translateY(-5px); border-color: #6366f1; }
        .poster-container { height: 350px; width: 100%; overflow: hidden; position: relative; }
        .poster-container img { width: 100%; height: 100%; object-fit: cover; }
        .badge-age { position: absolute; top: 10px; right: 10px; background: #ef4444; color: #fff; font-weight: bold; padding: 4px 8px; border-radius: 4px; font-size: 12px; }
        
        .card-body { padding: 18px; display: flex; flex-direction: column; flex: 1; justify-content: space-between; }
        .movie-title { font-size: 18px; font-weight: 700; margin-bottom: 8px; color: #f8fafc; }
        .movie-meta { font-size: 13px; color: #94a3b8; margin-bottom: 15px; }
        .btn-book { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 14px; display: block; }
        .btn-book:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <div class="logo-box">
                <a href="Default.aspx" class="logo">Dershprom Cinema</a>
                <div class="nav-links">
                    <a href="Default.aspx" class="active">АФІША</a>
                    <a href="Dashboard.aspx">БРОНЮВАННЯ</a>
                    <a href="MyTickets.aspx">МОЇ КВИТКИ</a>
                    <a href="Analytics.aspx">АНАЛІТИКА</a>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="filter-bar">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="txt-search" Placeholder="Пошук за назвою..."></asp:TextBox>
                <asp:DropDownList ID="ddlGenres" runat="server" CssClass="ddl-filter" AutoPostBack="true" OnSelectedIndexChanged="btnSearch_Click"></asp:DropDownList>
                <asp:Button ID="btnSearch" runat="server" Text="Шукати" CssClass="btn-filter" OnClick="btnSearch_Click" />
            </div>

            <div class="movies-grid">
                <asp:Repeater ID="rptMovies" runat="server">
                    <ItemTemplate>
                        <div class="movie-card">
                            <div class="poster-container">
                                <span class="badge-age"><%# Eval("AgeRating") %></span>
                                <img src='<%# GetPosterUrl(Eval("Title").ToString()) %>' alt='<%# Eval("Title") %>' />
                            </div>
                            <div class="card-body">
                                <div>
                                    <div class="movie-title"><%# Eval("Title") %></div>
                                    <div class="movie-meta">
                                        Жанр: <strong style="color:#c084fc;"><%# Eval("GenreName") %></strong><br />
                                        Тривалість: <%# Eval("DurationMinutes") %> хв
                                    </div>
                                </div>
                                <a href='Dashboard.aspx?movieId=<%# Eval("MovieID") %>' class="btn-book">Обрати сеанс</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </form>
</body>
</html>