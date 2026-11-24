# Results: `09_churn_and_moving_average.sql`

### Query 1

| customer_id | customer | email | orders | lifetime_value | last_order | days_since_last_order |
|---|---|---|---|---|---|---|
| 554 | Ananya Thomas | ananya.thomas554@example.com | 19 | 2,230.19 | 2025-08-02 | 151 |
| 344 | Thomas Singh | thomas.singh344@example.com | 7 | 1,126.98 | 2025-02-26 | 308 |
| 359 | Priya Ahmed | priya.ahmed359@example.com | 7 | 956.58 | 2025-08-08 | 145 |
| 209 | Priya Smith | priya.smith209@example.com | 5 | 948.03 | 2024-05-13 | 597 |
| 49 | Olivia Taylor | olivia.taylor49@example.com | 6 | 912.85 | 2024-04-14 | 626 |
| 531 | Ananya Ahmed | ananya.ahmed531@example.com | 5 | 898.86 | 2025-04-17 | 258 |
| 299 | Aarav Smith | aarav.smith299@example.com | 7 | 888.30 | 2025-04-28 | 247 |
| 574 | Ravi Patel | ravi.patel574@example.com | 8 | 813.74 | 2024-04-27 | 613 |
| 171 | Sophie Roberts | sophie.roberts171@example.com | 4 | 806.37 | 2025-06-23 | 191 |
| 23 | Fatima Evans | fatima.evans23@example.com | 8 | 779.57 | 2025-05-23 | 222 |
| 255 | Aarav Smith | aarav.smith255@example.com | 6 | 777.86 | 2024-05-01 | 609 |
| 256 | Ravi Wilson | ravi.wilson256@example.com | 6 | 749.34 | 2025-05-31 | 214 |
| 188 | Aarav Williams | aarav.williams188@example.com | 6 | 742.37 | 2024-05-06 | 604 |
| 64 | Ananya Singh | ananya.singh64@example.com | 4 | 727.63 | 2024-12-10 | 386 |
| 159 | Ravi Khan | ravi.khan159@example.com | 8 | 725.83 | 2024-09-16 | 471 |

### Query 2

| month | active_customers | moving_avg_3m |
|---|---|---|
| 2024-01 | 39 | 39.00 |
| 2024-02 | 47 | 43.00 |
| 2024-03 | 57 | 47.70 |
| 2024-04 | 52 | 52.00 |
| 2024-05 | 64 | 57.70 |
| 2024-06 | 56 | 57.30 |
| 2024-07 | 70 | 63.30 |
| 2024-08 | 46 | 57.30 |
| 2024-09 | 55 | 57.00 |
| 2024-10 | 58 | 53.00 |
| 2024-11 | 77 | 63.30 |
| 2024-12 | 78 | 71.00 |
| 2025-01 | 38 | 64.30 |
| 2025-02 | 69 | 61.70 |
| 2025-03 | 76 | 61.00 |
| 2025-04 | 71 | 72.00 |
| 2025-05 | 84 | 77.00 |
| 2025-06 | 81 | 78.70 |
| 2025-07 | 94 | 86.30 |
| 2025-08 | 98 | 91.00 |
| 2025-09 | 90 | 94.00 |
| 2025-10 | 122 | 103.30 |
| 2025-11 | 146 | 119.30 |
| 2025-12 | 178 | 148.70 |
