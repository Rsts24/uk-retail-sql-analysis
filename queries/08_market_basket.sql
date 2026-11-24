-- =====================================================================
-- 08. Market basket: products frequently bought together
-- Business question: Which product pairs should we bundle or cross-sell?
-- Skills: self-join, pair de-duplication (a.id < b.id), support metric
-- =====================================================================

WITH basket AS (
    SELECT DISTINCT order_id, product_id, product_name FROM v_sales
),
pairs AS (
    SELECT
        a.product_name AS product_a,
        b.product_name AS product_b,
        COUNT(*)       AS orders_together
    FROM basket a
    JOIN basket b
      ON a.order_id = b.order_id
     AND a.product_id < b.product_id          -- each pair counted once
    GROUP BY a.product_id, b.product_id
)
SELECT
    product_a,
    product_b,
    orders_together,
    ROUND(100.0 * orders_together /
          (SELECT COUNT(DISTINCT order_id) FROM v_sales), 2) AS support_pct
FROM pairs
ORDER BY orders_together DESC
LIMIT 10;
