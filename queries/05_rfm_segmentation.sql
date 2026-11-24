-- =====================================================================
-- 05. RFM customer segmentation
-- Business question: Which customers should marketing target, reward,
--                    or try to win back?
-- Skills: NTILE() scoring, CASE-based segmentation, date arithmetic
-- Recency is measured from the day after the last order in the dataset.
-- SQL Server: replace julianday() difference with DATEDIFF(day, ...)
-- =====================================================================

WITH params AS (
    SELECT DATE(MAX(order_date), '+1 day') AS as_of FROM v_sales
),
rfm_raw AS (
    SELECT
        s.customer_id,
        CAST(julianday(p.as_of) - julianday(MAX(s.order_date)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT s.order_id)                                         AS frequency,
        ROUND(SUM(s.revenue), 2)                                           AS monetary
    FROM v_sales s
    CROSS JOIN params p
    GROUP BY s.customer_id
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,  -- 5 = most recent
        NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,  -- 5 = most frequent
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score   -- 5 = highest spend
    FROM rfm_raw
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4                 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                 THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2                 THEN 'New / Promising'
            WHEN r_score <= 2 AND f_score >= 3                 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2                 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*)                                              AS customers,
    ROUND(AVG(recency_days), 0)                           AS avg_recency_days,
    ROUND(AVG(frequency), 1)                              AS avg_orders,
    ROUND(SUM(monetary), 2)                               AS total_revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
