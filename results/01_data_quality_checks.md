# Results: `01_data_quality_checks.sql`

### Query 1

| table_name | row_count |
|---|---|
| customers | 600 |
| products | 28 |
| orders | 2845 |
| order_items | 4989 |

### Query 2

| orders_without_customer | orders_without_items | orders_before_signup | loss_making_products |
|---|---|---|---|
| 0 | 0 | 0 | 0 |

### Query 3

| status | orders | pct_of_orders |
|---|---|---|
| Completed | 2536 | 89.10 |
| Returned | 191 | 6.70 |
| Cancelled | 118 | 4.10 |

### Query 4

| customers_never_ordered |
|---|
| 46 |
