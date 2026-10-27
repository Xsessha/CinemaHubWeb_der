USE CinemaHub_EnterpriseDB;
GO
SET NOCOUNT ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Tickets WHERE CustomerName LIKE N'%(demo)')
BEGIN
DECLARE @movies TABLE (rn INT IDENTITY(1,1), MovieID INT);
INSERT @movies (MovieID) SELECT MovieID FROM dbo.Movies ORDER BY MovieID;
DECLARE @cnt INT = (SELECT COUNT(*) FROM @movies);
IF @cnt = 0 BEGIN RAISERROR(N'Таблиця Movies порожня.', 16, 1); RETURN; END

;WITH n AS (SELECT TOP (120) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS i FROM sys.all_objects)
INSERT dbo.Tickets (MovieID, CustomerName, RowNumber, SeatNumber, ShowtimeInfo, SessionID, PurchaseDate,
                    DiscountPercent, PaymentMethod, IsPaid, PaymentStatus)
SELECT m.MovieID,
       CHOOSE(n.i % 6 + 1, N'Олена Коваль', N'Іван Мельник', N'Марія Шевченко', N'Андрій Бондар', N'Софія Ткачук', N'Максим Кравець') + N' (demo)',
       (n.i % 6) + 1,
       ((n.i * 3) % 8) + 1,
       FORMAT(DATEADD(DAY, (n.i % 7) - 3, CAST(GETDATE() AS DATE)), 'dd.MM.yyyy') + N' '
         + CHOOSE(n.i % 5 + 1, N'10:00', N'13:00', N'16:00', N'19:00', N'21:30') + N' ('
         + CHOOSE(n.i % 3 + 1, N'Синій Зал (2D)', N'Червоний Зал (3D) + 30 грн', N'VIP Зал (IMAX) + 80 грн') + N')',
       1,
       DATEADD(HOUR, -(n.i % 70) - 1, GETDATE()),
       CHOOSE(n.i % 3 + 1, 0, 20, 30),
       CHOOSE(n.i % 5 + 1, N'Card', N'ApplePay', N'GooglePay', N'LiqPay', N'MonoPay'),
       CASE WHEN n.i % 9 = 0 OR n.i % 4 = 0 THEN 0 ELSE 1 END,
       CASE WHEN n.i % 9 = 0 THEN N'Refunded' WHEN n.i % 4 = 0 THEN N'Pending' ELSE N'Paid' END
FROM n JOIN @movies m ON m.rn = (n.i % @cnt) + 1;
END
GO
