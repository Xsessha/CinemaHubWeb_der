USE CinemaHub_EnterpriseDB;
GO
IF COL_LENGTH('dbo.Tickets', 'DiscountPercent') IS NULL
    ALTER TABLE dbo.Tickets ADD DiscountPercent INT NOT NULL CONSTRAINT DF_Tickets_DiscountPercent DEFAULT (0);
GO
IF COL_LENGTH('dbo.Tickets', 'PaymentMethod') IS NULL
    ALTER TABLE dbo.Tickets ADD PaymentMethod NVARCHAR(30) NOT NULL CONSTRAINT DF_Tickets_PaymentMethod DEFAULT (N'Card');
GO
IF COL_LENGTH('dbo.Tickets', 'PaymentStatus') IS NULL
BEGIN
    ALTER TABLE dbo.Tickets ADD PaymentStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Tickets_PaymentStatus DEFAULT (N'Paid');
    EXEC(N'UPDATE dbo.Tickets SET PaymentStatus = CASE WHEN IsPaid = 1 THEN N''Paid'' ELSE N''Pending'' END');
END
GO
CREATE OR ALTER VIEW dbo.vw_TicketReport AS
SELECT  t.TicketID,
        ISNULL(m.Title, N'Невідомий фільм')  AS MovieTitle,
        ISNULL(g.GenreName, N'Фільм')         AS GenreName,
        CASE WHEN t.ShowtimeInfo LIKE N'%IMAX%' THEN N'VIP Зал (IMAX)'
             WHEN t.ShowtimeInfo LIKE N'%3D%'   THEN N'Червоний Зал (3D)'
             ELSE N'Синій Зал (2D)' END       AS HallName,
        ISNULL(x.SessionStart, t.PurchaseDate) AS SessionStart,
        CAST(t.RowNumber AS INT)               AS RowNumber,
        CAST(t.SeatNumber AS INT)              AS SeatNumber,
        ISNULL(t.CustomerName, N'Глядач')     AS CustomerName,
        c.BasePrice, c.FormatSurcharge, t.DiscountPercent,
        CAST(ROUND((c.BasePrice + c.FormatSurcharge) * (100 - t.DiscountPercent) / 100.0, 2) AS DECIMAL(10,2)) AS Price,
        t.PaymentMethod, t.PaymentStatus, t.PurchaseDate
FROM dbo.Tickets t
LEFT JOIN dbo.Movies m ON m.MovieID = t.MovieID
LEFT JOIN dbo.Genres g ON g.GenreID = m.GenreID
CROSS APPLY (SELECT
      CAST(CASE WHEN t.RowNumber >= 5 THEN 200 ELSE 120 END AS DECIMAL(10,2)) AS BasePrice,
      CAST(CASE WHEN t.ShowtimeInfo LIKE N'%IMAX%' THEN 80 WHEN t.ShowtimeInfo LIKE N'%3D%' THEN 30 ELSE 0 END AS DECIMAL(10,2)) AS FormatSurcharge) c
CROSS APPLY (SELECT DATEADD(MINUTE,
                DATEDIFF(MINUTE, CAST('00:00' AS TIME(0)), TRY_CONVERT(TIME(0), SUBSTRING(t.ShowtimeInfo, 12, 5))),
                CAST(TRY_CONVERT(DATE, LEFT(t.ShowtimeInfo, 10), 104) AS DATETIME2(0))) AS SessionStart) x;
GO
CREATE OR ALTER VIEW dbo.vw_FinancialData AS
SELECT  GenreName, MovieTitle, CAST(SessionStart AS DATE) AS SessionDate, HallName, TicketID, Price,
        CAST(CASE WHEN PaymentStatus = N'Paid' THEN Price ELSE 0 END AS DECIMAL(10,2)) AS PaidAmount,
        PaymentStatus
FROM dbo.vw_TicketReport;
GO
