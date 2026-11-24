# UK Retail Sales Analysis (SQL)

End-to-end SQL analysis of two years of sales for a fictional UK multi-channel retailer.
I designed the schema, generated a realistic dataset and wrote 9 analysis scripts. Each one answers a real business question, the kind a sales, finance or marketing manager would ask.

> **Why this project:** in my roles at Doclan and dnata I built Excel/Access/SQL reporting on real business data I can't share. This repo shows the same skills on a public, reproducible dataset.
>
> **Tools:** SQL (SQLite, with notes for SQL Server/PostgreSQL) · Python (data generation & runner) · CSV exports for Excel/Power BI
> **Data:** 100% synthetic. 600 customers, 28 products, ~2,800 orders, ~5,000 order lines (Jan 2024 – Dec 2025)

---

## Key findings

| Area | Finding | Recommended action |
|---|---|---|
| **Growth** | Revenue grew **96%** year-on-year (£86k → £170k). Every month of 2025 beat the same month of 2024 except January | Plan stock and staffing around the growth curve, not flat targets |
| **Seasonality** | November and December make up **~33%** of 2025 revenue. Margin dips ~3 pts in those months because of promotions | Review Black Friday discount depth; the volume uplift may not need 25% off |
| **Customer concentration** | The top **20%** of customers drive **61%** of revenue. The top 10% drive 42% | Launch a loyalty tier for the top 20% to protect this revenue |
| **Segments (RFM)** | "Champions" (142 customers) bring in **65%** of revenue. 90 "At Risk" customers were worth £37k but haven't bought in over a year on average | Target "At Risk" customers with a win-back campaign (list in query 09) |
| **Categories** | Electronics is the largest category (34% of revenue) but has the lowest margin (58%). Books & Stationery has the highest margin (69%) | Cross-sell high-margin accessories alongside electronics |
| **Retention** | 30–62% of each new cohort returns in the next quarter. Early-2024 cohorts retain best | Investigate what drove early-2024 loyalty (channel? first product?) |
| **Data quality** | No orphan records or impossible dates. **~11%** of orders are returned or cancelled and are excluded from revenue | Track the return rate as its own KPI |

---

## Project structure

```
uk-retail-sql-analysis/
├── schema.sql            # Tables, constraints, indexes and the v_sales view
├── generate_data.py      # Builds the synthetic dataset (seeded, reproducible)
├── run_queries.py        # Runs every query and saves the results as markdown
├── data/                 # retail.db (SQLite) + CSV copies of each table
├── queries/              # 9 analysis scripts (below)
└── results/              # Output of each query, viewable on GitHub
```

## Data model

```
customers 1──* orders 1──* order_items *──1 products
```

| Table | Key columns |
|---|---|
| `customers` | customer_id, name, email, city, region, signup_date |
| `products` | product_id, product_name, category, unit_cost, unit_price |
| `orders` | order_id, customer_id, order_date, channel (Online/In-Store/Phone), status |
| `order_items` | order_id, product_id, quantity, unit_price, discount_pct |

`v_sales` is a reusable view that joins all four tables and calculates **revenue** and **profit** per line. It only counts completed orders. Every analysis builds on it, so the business rules live in one place.

---

## Analyses

| # | Script | Business question | SQL techniques |
|---|---|---|---|
| 01 | [Data quality checks](queries/01_data_quality_checks.sql) | Can we trust the data? | Anti-joins, `NOT EXISTS`, `UNION ALL` |
| 02 | [Monthly revenue trend](queries/02_monthly_revenue_trend.sql) | How is revenue trending, and is it seasonal? | CTEs, `LAG()`, MoM & YoY growth, YTD running total |
| 03 | [Category performance](queries/03_category_performance.sql) | What drives revenue and profit? | Share of total with `SUM() OVER ()`, `RANK()` per partition |
| 04 | [Top customers](queries/04_top_customers.sql) | Who are our best customers? Are we too dependent on them? | `DENSE_RANK()`, Pareto / cumulative analysis |
| 05 | [RFM segmentation](queries/05_rfm_segmentation.sql) | Who should marketing reward or win back? | `NTILE()` scoring, `CASE` segmentation |
| 06 | [Cohort retention](queries/06_cohort_retention.sql) | Do new customers come back? | Cohort analysis, pivot with conditional aggregation |
| 07 | [Region & channel](queries/07_regional_channel_analysis.sql) | Where and how do we sell best? | Conditional `SUM`, `HAVING`, ratio metrics |
| 08 | [Market basket](queries/08_market_basket.sql) | Which products to bundle? | Self-join, pair de-duplication |
| 09 | [Churn risk & active base](queries/09_churn_and_moving_average.sql) | Who has gone quiet? Is the active base growing? | Date arithmetic, `ROWS BETWEEN` moving average |

Each script starts with a header that sets out the business question, the techniques used and any dialect notes. Results for every query are in [`results/`](results/).

### Example: month-on-month and year-on-year growth in one query

```sql
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           ROUND(SUM(revenue), 2)        AS revenue
    FROM v_sales
    GROUP BY month
)
SELECT month,
       revenue,
       ROUND(100.0 * (revenue - LAG(revenue, 1)  OVER (ORDER BY month))
                   / LAG(revenue, 1)  OVER (ORDER BY month), 1) AS mom_growth_pct,
       ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
                   / LAG(revenue, 12) OVER (ORDER BY month), 1) AS yoy_growth_pct
FROM monthly;
```

---

## How to run it

Requires Python 3.9+ (SQLite is built in, so there's nothing to install).

```bash
git clone https://github.com/Rsts24/uk-retail-sql-analysis.git
cd uk-retail-sql-analysis
python generate_data.py     # builds data/retail.db and CSVs
python run_queries.py       # runs all queries and writes results/*.md
```

You can also open `data/retail.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) or DBeaver and run any script by hand.

**Using SQL Server or PostgreSQL?** Load the CSVs from `data/` and swap the date functions:
`strftime('%Y-%m', d)` → `FORMAT(d,'yyyy-MM')` (SQL Server) / `TO_CHAR(d,'YYYY-MM')` (Postgres);
`julianday(a) - julianday(b)` → `DATEDIFF(day, b, a)` / `a - b`.

---

## What I'd do next

- Build a Power BI / Excel dashboard on top of `v_sales` (planned as a separate repo)
- Add stored procedures for monthly reporting in SQL Server
- Schedule the data-quality checks to run automatically and alert on failures

---

*Author: Ritesh Shetty · [Portfolio](https://rsts24.github.io) · [LinkedIn](https://www.linkedin.com/in/rks258) · [Upwork](https://www.upwork.com/freelancers/~01caf4e3e60160f363)*
*All data in this repository is randomly generated. No real customer or company data is used.*
