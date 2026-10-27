# CinemaHub: звітність RDLC

Застосунок — ASP.NET Web Forms на .NET Framework 4.7.2 із LocalDB `CinemaHub_EnterpriseDB`. Електронний квиток і касова аналітика реалізовані як локальні RDLC-звіти через Microsoft ReportViewer 15.0.

> Звіт Crystal Reports `.rpt` не створено, оскільки не вдалося знайти безкоштовні ресурси та інструменти для його розробки. Замість нього реалізовано аналітичний звіт RDLC. Це робоча альтернатива, але вона не є файлом Crystal Reports і не замінює вимогу `.rpt`.

| Звіт | Сторінка | Функції |
|---|---|---|
| `Reports/TicketReport.rdlc` | `TicketReport.aspx` | Електронний квиток, розрахунок ПДВ, статус оплати, підзвіт складу вартості |
| `Reports/FinancialAnalytics.rdlc` | `Analytics.aspx` | Фільтр дат, групування жанр → фільм → день → загалом, суми та частка оплат |
| SVG-діаграма на `Analytics.aspx` | `Analytics.aspx` | Кругова діаграма сплачених сум за жанрами з легендою |

## Як запустити проєкт

Потрібні Windows, Visual Studio 2022 з компонентом **ASP.NET and web development**, пакет розробника **.NET Framework 4.7.2**, SQL Server **LocalDB** і NuGet-пакети проєкту.

1. Відкрийте `CinemaHubWeb.sln` у Visual Studio 2022.
2. У **Solution Explorer** клацніть правою кнопкою проєкт `CinemaHubWeb` і виберіть **Set as Startup Project**.
3. Відновіть NuGet-пакети: клацніть правою кнопкою solution → **Restore NuGet Packages**. Пакети, зокрема Microsoft ReportViewer 15, перелічені в `CinemaHubWeb/packages.config`.
4. Переконайтеся, що запущено SQL Server LocalDB і доступна база `CinemaHub_EnterpriseDB`. Рядок підключення `CinemaHubConnection` у `CinemaHubWeb/Web.config` вказує на `(localdb)\MSSQLLocalDB`.
5. Якщо базі ще не додано поля оплати та звітні представлення, під'єднайтеся до `CinemaHub_EnterpriseDB` у **SQL Server Object Explorer** і виконайте `Database/02_ReportsMigration.sql`.
6. Щоб додати демонстраційні квитки (в тому числі різні статуси оплати), за потреби виконайте `Database/03_DemoData.sql`. Скрипт ідемпотентний.
7. Запустіть сайт клавішею **F5** або **Ctrl+F5**. Visual Studio запустить його через IIS Express.
8. На сайті відкрийте **МОЇ КВИТКИ**, щоб переглянути операційний квиток, або **АНАЛІТИКА**, щоб задати період і сформувати касовий звіт. У ReportViewer доступний експорт у підтримувані формати.

**Для запуску на новій машині:** міграція створює звітні представлення, але не створює початкову базу даних і таблиці `Tickets`, `Movies`, `Genres`. Потрібна наявна база CinemaHub із цими таблицями та основними даними; повного скрипту створення початкової схеми в проєкті немає. Якщо сайт не під'єднується до бази, перевірте її наявність і рядок підключення у `Web.config`.

## Як працює аналітика

`ReportData.GetFinancialSummary` виконує параметризований запит до `vw_FinancialData`, агрегує кількість квитків, нараховану й сплачену суми та відсоток оплати. `ROLLUP` будує рівні жанру, фільму, дати сеансу й загальний підсумок. Цей `DataTable` передається до локального RDLC через `ReportDataSource` (Push Model).

Кругова діаграма створюється серверним кодом як SVG із сум `PaidAmount` на рівні жанрів. Вона використовує сплачені суми, а не кількість квитків чи нараховану виручку; назви жанрів і підписи екрануються перед формуванням SVG/HTML.

Фінансовий звіт використовує фонове та умовне форматування для виділення рівнів групування й показників оплати. Звіт квитка та його підзвіт прив'язані до наборів даних, переданих застосунком у локальний ReportViewer.

## Перевірка

Проєкт збирається командою MSBuild Visual Studio 2022:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' 'CinemaHubWeb\CinemaHubWeb.csproj' /t:Build /p:Configuration=Debug /verbosity:minimal
```



