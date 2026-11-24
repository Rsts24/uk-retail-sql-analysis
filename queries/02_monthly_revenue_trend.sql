-- =====================================================================
-- 02. Monthly revenue trend with month-on-month and year-on-year growth
-- Business question: How is revenue trending, and is it seasonal?
-- Skills: CTEs, date functions, LAG() window function, running totals
-- SQL Server: use FORMAT(order_date,'yyyy-MM') instead of strftime
-- =====================================================================

WITH monthly AS (
    SELECT
        strftime('%Y-%m', order_date)  AS month,
        COUNT(DISTINCT order_id)       AS orders,
        ROUND(SUM(revenue), 2)         AS revenue,
        ROUND(SUM(profit), 2)          AS profit
    FROM v_sales
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    month,
    orders,
    revenue,
    ROUND(100.0 * profit / revenue, 1)                                   AS margin_pct,
    ROUND(100.0 * (revenue - LAG(revenue, 1)  OVER (ORDER BY month))
                / LAG(revenue, 1)  OVER (ORDER BY month), 1)             AS mom_growth_pct,
    ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
                / LAG(revenue, 12) OVER (ORDER BY month), 1)             AS yoy_growth_pct,
    ROUND(SUM(revenue) OVER (PARTITION BY substr(month, 1, 4)
                             ORDER BY month), 2)                         AS ytd_revenue
FROM monthly
ORDER BY month;
