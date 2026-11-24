-- =====================================================================
-- 07. Regional and channel performance
-- Business question: Where do we sell best, and through which channels?
-- Skills: pivoting with conditional SUM, ratio metrics, HAVING
-- =====================================================================

SELECT
    region,
    COUNT(DISTINCT customer_id)                                         AS customers,
    COUNT(DISTINCT order_id)                                            AS orders,
    ROUND(SUM(revenue), 2)                                              AS revenue,
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2)                   AS avg_order_value,
    ROUND(100.0 * SUM(CASE WHEN channel = 'Online'   THEN revenue END) / SUM(revenue), 1) AS online_pct,
    ROUND(100.0 * SUM(CASE WHEN channel = 'In-Store' THEN revenue END) / SUM(revenue), 1) AS instore_pct,
    ROUND(100.0 * SUM(CASE WHEN channel = 'Phone'    THEN revenue END) / SUM(revenue), 1) AS phone_pct
FROM v_sales
GROUP BY region
HAVING COUNT(DISTINCT order_id) >= 50      -- ignore regions too small to compare
ORDER BY revenue DESC;
