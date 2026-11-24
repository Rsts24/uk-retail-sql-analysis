-- =====================================================================
-- 04. Top customers and revenue concentration
-- Business question: Who are our most valuable customers, and how
--                    dependent are we on them (Pareto / 80-20 check)?
-- Skills: multi-table joins, DENSE_RANK, cumulative % with window frames
-- =====================================================================

-- 4a. Top 10 customers by lifetime value
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(s.revenue) DESC) AS rank,
    c.first_name || ' ' || c.last_name               AS customer,
    c.city,
    COUNT(DISTINCT s.order_id)                       AS orders,
    ROUND(SUM(s.revenue), 2)                         AS lifetime_value,
    ROUND(SUM(s.revenue) / COUNT(DISTINCT s.order_id), 2) AS avg_order_value,
    MAX(s.order_date)                                AS last_order
FROM v_sales s
JOIN customers c ON c.customer_id = s.customer_id
GROUP BY c.customer_id
ORDER BY lifetime_value DESC
LIMIT 10;

-- 4b. Revenue concentration: what % of revenue comes from the top 10% / 20% of customers?
WITH cust AS (
    SELECT customer_id, SUM(revenue) AS ltv
    FROM v_sales
    GROUP BY customer_id
),
ranked AS (
    SELECT
        ltv,
        ROW_NUMBER() OVER (ORDER BY ltv DESC) AS rn,
        COUNT(*)     OVER ()                  AS n_customers,
        SUM(ltv)     OVER ()                  AS total_revenue
    FROM cust
)
SELECT
    'Top 10% of customers' AS segment,
    ROUND(100.0 * SUM(ltv) / MAX(total_revenue), 1) AS pct_of_revenue
FROM ranked WHERE rn <= 0.10 * n_customers
UNION ALL
SELECT
    'Top 20% of customers',
    ROUND(100.0 * SUM(ltv) / MAX(total_revenue), 1)
FROM ranked WHERE rn <= 0.20 * n_customers;
