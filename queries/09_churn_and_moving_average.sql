-- =====================================================================
-- 09. Churn risk list + 3-month moving average of active customers
-- Business question: Who has gone quiet (no order in 120+ days) despite
--                    being a repeat buyer, and is our active base growing?
-- Skills: date logic, window frames (ROWS BETWEEN), actionable output list
-- =====================================================================

-- 9a. Win-back list: repeat customers with no order in the last 120 days
WITH last_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS orders,
        MAX(order_date)          AS last_order,
        ROUND(SUM(revenue), 2)   AS lifetime_value
    FROM v_sales
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer,
    c.email,
    lo.orders,
    lo.lifetime_value,
    lo.last_order,
    CAST(julianday((SELECT MAX(order_date) FROM v_sales)) - julianday(lo.last_order) AS INTEGER)
        AS days_since_last_order
FROM last_orders lo
JOIN customers c ON c.customer_id = lo.customer_id
WHERE lo.orders >= 3
  AND julianday((SELECT MAX(order_date) FROM v_sales)) - julianday(lo.last_order) > 120
ORDER BY lo.lifetime_value DESC
LIMIT 15;

-- 9b. Active customers per month with a 3-month moving average
WITH monthly_active AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           COUNT(DISTINCT customer_id)   AS active_customers
    FROM v_sales
    GROUP BY month
)
SELECT
    month,
    active_customers,
    ROUND(AVG(active_customers) OVER (ORDER BY month
          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS moving_avg_3m
FROM monthly_active
ORDER BY month;
