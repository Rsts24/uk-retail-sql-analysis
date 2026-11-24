"""
Generate a synthetic UK retail dataset and load it into SQLite.

All data is fake (random, seeded for reproducibility). Built-in patterns
make the analysis worth doing:
  * seasonality      - November/December peaks, a January dip
  * growth           - 2025 volume is higher than 2024
  * loyal vs one-off - a small group of customers buys far more often
  * churn            - some customers stop buying partway through

Usage:
    python generate_data.py            # creates data/retail.db + CSV copies
"""

import csv
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

BASE = Path(__file__).parent
DATA = BASE / "data"
DB_PATH = DATA / "retail.db"

N_CUSTOMERS = 600
START, END = date(2024, 1, 1), date(2025, 12, 31)

FIRST = ["Aarav", "Olivia", "Priya", "James", "Amelia", "Mohammed", "Isla", "Harry",
         "Sophie", "Ravi", "Grace", "Jack", "Ananya", "Thomas", "Chloe", "Oliver",
         "Zara", "George", "Emily", "Arjun", "Hannah", "Leo", "Fatima", "Noah"]
LAST = ["Patel", "Smith", "Jones", "Khan", "Williams", "Shah", "Brown", "Taylor",
        "Singh", "Davies", "Evans", "Wilson", "Ahmed", "Thomas", "Roberts", "Kaur"]

CITIES = {  # city: (region, weight)
    "London": ("London", 30), "Slough": ("South East", 8), "Reading": ("South East", 8),
    "Oxford": ("South East", 5), "Birmingham": ("West Midlands", 12),
    "Manchester": ("North West", 12), "Liverpool": ("North West", 6),
    "Leeds": ("Yorkshire", 8), "Bristol": ("South West", 7),
    "Glasgow": ("Scotland", 6), "Cardiff": ("Wales", 4),
}

CATALOGUE = {  # category: [(name, cost, price), ...]
    "Electronics": [("Wireless Earbuds", 18, 49.99), ("Bluetooth Speaker", 22, 59.99),
                    ("USB-C Charger", 6, 19.99), ("Smart Watch", 60, 149.99),
                    ("Portable SSD 1TB", 45, 99.99), ("Webcam HD", 20, 44.99)],
    "Home & Kitchen": [("Air Fryer", 40, 89.99), ("Coffee Grinder", 15, 34.99),
                       ("Knife Set", 25, 64.99), ("Kettle", 12, 29.99),
                       ("Storage Jars (6)", 8, 21.99), ("Blender", 28, 69.99)],
    "Clothing": [("Rain Jacket", 20, 59.99), ("Cotton T-Shirt", 4, 14.99),
                 ("Wool Jumper", 18, 49.99), ("Running Trainers", 30, 79.99),
                 ("Winter Scarf", 5, 17.99), ("Jeans", 14, 44.99)],
    "Sports & Outdoors": [("Yoga Mat", 7, 24.99), ("Dumbbell Set", 30, 74.99),
                          ("Water Bottle", 3, 12.99), ("Camping Chair", 12, 34.99),
                          ("Cycling Helmet", 18, 49.99)],
    "Books & Stationery": [("Notebook A5", 1.5, 6.99), ("Fountain Pen", 6, 22.99),
                           ("Desk Planner", 4, 14.99), ("Bestseller Novel", 4, 9.99),
                           ("Art Supplies Kit", 10, 29.99)],
}

# Month weights: seasonality (Jan dip, Nov/Dec peak)
MONTH_WEIGHT = {1: 0.7, 2: 0.8, 3: 0.9, 4: 0.9, 5: 1.0, 6: 1.0,
                7: 1.0, 8: 0.95, 9: 1.0, 10: 1.1, 11: 1.6, 12: 1.9}


def rand_date(start: date, end: date) -> date:
    return start + timedelta(days=random.randint(0, (end - start).days))


def weighted_order_date(after: date, stop: date) -> date:
    """Pick a date after `after`, biased by seasonality and 2025 growth."""
    while True:
        d = rand_date(after, stop)
        w = MONTH_WEIGHT[d.month] * (1.35 if d.year == 2025 else 1.0)
        if random.random() < w / 2.6:
            return d


def main() -> None:
    DATA.mkdir(exist_ok=True)

    # --- products ---
    products = []
    pid = 1
    for cat, items in CATALOGUE.items():
        for name, cost, price in items:
            products.append((pid, name, cat, cost, price))
            pid += 1

    # --- customers ---
    city_names = list(CITIES)
    city_weights = [CITIES[c][1] for c in city_names]
    customers = []
    for cid in range(1, N_CUSTOMERS + 1):
        fn, ln = random.choice(FIRST), random.choice(LAST)
        city = random.choices(city_names, city_weights)[0]
        signup = rand_date(date(2022, 1, 1), date(2025, 10, 31))  # some pre-date the sales window
        customers.append((cid, fn, ln, f"{fn}.{ln}{cid}@example.com".lower(),
                          city, CITIES[city][0], signup.isoformat()))

    # --- orders & items ---
    orders, items = [], []
    oid, iid = 1, 1
    for cid, *_rest, signup in customers:
        signup_d = date.fromisoformat(signup)
        first_possible = max(signup_d, START)
        segment = random.choices(["loyal", "regular", "one-off", "never"],
                                 [10, 45, 35, 10])[0]
        n_orders = {"loyal": random.randint(12, 30), "regular": random.randint(2, 8),
                    "one-off": 1, "never": 0}[segment]
        # ~30% of non-loyal customers churn: their orders stop at a cut-off date
        stop = END
        if segment == "regular" and random.random() < 0.3:
            stop = min(END, first_possible + timedelta(days=random.randint(60, 300)))

        for _ in range(n_orders):
            od = weighted_order_date(first_possible, stop)
            channel = random.choices(["Online", "In-Store", "Phone"], [65, 30, 5])[0]
            status = random.choices(["Completed", "Returned", "Cancelled"], [90, 6, 4])[0]
            orders.append((oid, cid, od.isoformat(), channel, status))

            for p in random.sample(products, random.choices([1, 2, 3, 4], [50, 30, 15, 5])[0]):
                qty = random.choices([1, 2, 3], [75, 20, 5])[0]
                disc = random.choices([0, 0.1, 0.2], [80, 15, 5])[0]
                if od.month in (11, 12) and random.random() < 0.3:
                    disc = 0.25  # Black Friday / Christmas promos
                items.append((iid, oid, p[0], qty, p[4], disc))
                iid += 1
            oid += 1

    orders.sort(key=lambda r: r[2])  # tidy: chronological order

    # --- load into SQLite ---
    if DB_PATH.exists():
        DB_PATH.unlink()
    con = sqlite3.connect(DB_PATH)
    con.executescript((BASE / "schema.sql").read_text())
    con.executemany("INSERT INTO customers VALUES (?,?,?,?,?,?,?)", customers)
    con.executemany("INSERT INTO products VALUES (?,?,?,?,?)", products)
    con.executemany("INSERT INTO orders VALUES (?,?,?,?,?)", orders)
    con.executemany("INSERT INTO order_items VALUES (?,?,?,?,?,?)", items)
    con.commit()

    # --- CSV copies (handy for Excel / Power BI users) ---
    for table in ["customers", "products", "orders", "order_items"]:
        cur = con.execute(f"SELECT * FROM {table}")
        with open(DATA / f"{table}.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow([c[0] for c in cur.description])
            w.writerows(cur)
    con.close()

    print(f"Created {DB_PATH}: {len(customers)} customers, {len(products)} products, "
          f"{len(orders)} orders, {len(items)} order lines")


if __name__ == "__main__":
    main()
