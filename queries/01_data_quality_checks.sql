-- =====================================================================
-- 01. Data quality checks
-- Business question: Can we trust this data before we report on it?
-- Skills: COUNT, LEFT JOIN anti-joins, GROUP BY / HAVING, CASE
-- =====================================================================

-- 1a. Row counts per table
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- 1b. Orphan checks: should all return 0
SELECT
    (SELECT COUNT(*) FROM orders o
       LEFT JOIN customers c ON c.customer_id = o.customer_id
      WHERE c.customer_id IS NULL)                              AS orders_without_customer,
    (SELECT COUNT(*) FROM orders o
       LEFT JOIN order_items oi ON oi.order_id = o.order_id
      WHERE oi.order_id IS NULL)                                AS orders_without_items,
    (SELECT COUNT(*) FROM orders o
       JOIN customers c ON c.customer_id = o.customer_id
      WHERE o.order_date < c.signup_date)                       AS orders_before_signup,
    (SELECT COUNT(*) FROM products WHERE unit_price <= unit_cost) AS loss_making_products;

-- 1c. Order status breakdown (how much is lost to returns/cancellations?)
SELECT
    status,
    COUNT(*)                                            AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)  AS pct_of_orders
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- 1d. Customers who signed up but never ordered
SELECT COUNT(*) AS customers_never_ordered
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
