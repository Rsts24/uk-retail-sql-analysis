-- =====================================================================
-- 03. Category and product performance
-- Business question: Which categories and products drive revenue and profit?
-- Skills: aggregation, share-of-total with window SUM, RANK() per partition
-- =====================================================================

-- 3a. Category summary with share of total revenue
SELECT
    category,
    SUM(quantity)                                              AS units_sold,
    ROUND(SUM(revenue), 2)                                     AS revenue,
    ROUND(SUM(profit), 2)                                      AS profit,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 1)               AS margin_pct,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct
FROM v_sales
GROUP BY category
ORDER BY revenue DESC;

-- 3b. Top 2 products in each category by revenue
WITH product_sales AS (
    SELECT
        category,
        product_name,
        ROUND(SUM(revenue), 2) AS revenue,
        RANK() OVER (PARTITION BY category ORDER BY SUM(revenue) DESC) AS rank_in_category
    FROM v_sales
    GROUP BY category, product_name
)
SELECT category, rank_in_category, product_name, revenue
FROM product_sales
WHERE rank_in_category <= 2
ORDER BY category, rank_in_category;
