-- =====================================================================
-- 06. Quarterly cohort retention
-- Business question: Of the customers who first bought in a given quarter,
--                    what % came back in later quarters?
-- Skills: cohort analysis, conditional aggregation (pivot with CASE)
-- Blank cells = that quarter is after the end of the data, not 0% retention
-- =====================================================================

WITH customer_quarters AS (
    SELECT DISTINCT
        customer_id,
        strftime('%Y', order_date) || '-Q' ||
            ((CAST(strftime('%m', order_date) AS INTEGER) + 2) / 3) AS quarter,
        (CAST(strftime('%Y', order_date) AS INTEGER) * 4) +
            ((CAST(strftime('%m', order_date) AS INTEGER) - 1) / 3)  AS quarter_num
    FROM v_sales
),
first_purchase AS (
    SELECT customer_id, MIN(quarter_num) AS cohort_num
    FROM customer_quarters
    GROUP BY customer_id
),
last_quarter AS (
    SELECT MAX(quarter_num) AS max_q FROM customer_quarters
),
activity AS (
    SELECT
        cq.customer_id,
        fp.cohort_num,
        cq.quarter_num - fp.cohort_num AS quarters_since_first
    FROM customer_quarters cq
    JOIN first_purchase fp ON fp.customer_id = cq.customer_id
)
SELECT
    (cohort_num / 4) || '-Q' || ((cohort_num % 4) + 1)  AS cohort,
    COUNT(DISTINCT CASE WHEN quarters_since_first = 0 THEN customer_id END) AS new_customers,
    CASE WHEN cohort_num + 1 <= (SELECT max_q FROM last_quarter) THEN
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN quarters_since_first = 1 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN quarters_since_first = 0 THEN customer_id END), 1) END AS q1_pct,
    CASE WHEN cohort_num + 2 <= (SELECT max_q FROM last_quarter) THEN
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN quarters_since_first = 2 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN quarters_since_first = 0 THEN customer_id END), 1) END AS q2_pct,
    CASE WHEN cohort_num + 3 <= (SELECT max_q FROM last_quarter) THEN
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN quarters_since_first = 3 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN quarters_since_first = 0 THEN customer_id END), 1) END AS q3_pct,
    CASE WHEN cohort_num + 4 <= (SELECT max_q FROM last_quarter) THEN
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN quarters_since_first = 4 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN quarters_since_first = 0 THEN customer_id END), 1) END AS q4_pct
FROM activity
GROUP BY cohort_num
ORDER BY cohort_num;
