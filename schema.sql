-- =====================================================================
-- UK Retail Sales Analysis — Database Schema
-- Dialect: SQLite (standard SQL; notes for SQL Server/PostgreSQL inline)
-- =====================================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    first_name    TEXT    NOT NULL,
    last_name     TEXT    NOT NULL,
    email         TEXT    UNIQUE,
    city          TEXT    NOT NULL,
    region        TEXT    NOT NULL,          -- e.g. London, South East, North West
    signup_date   DATE    NOT NULL
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT    NOT NULL,
    category      TEXT    NOT NULL,
    unit_cost     DECIMAL(10,2) NOT NULL,    -- what we pay the supplier
    unit_price    DECIMAL(10,2) NOT NULL     -- what the customer pays
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date    DATE    NOT NULL,
    channel       TEXT    NOT NULL CHECK (channel IN ('Online', 'In-Store', 'Phone')),
    status        TEXT    NOT NULL CHECK (status IN ('Completed', 'Returned', 'Cancelled'))
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL REFERENCES orders(order_id),
    product_id    INTEGER NOT NULL REFERENCES products(product_id),
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,    -- price at time of sale
    discount_pct  DECIMAL(4,2)  NOT NULL DEFAULT 0
);

-- Indexes on the columns used most in joins and filters
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_items_order       ON order_items(order_id);
CREATE INDEX idx_items_product     ON order_items(product_id);

-- Reusable view: one row per sold line with revenue and profit calculated.
-- Only completed orders count as revenue.
DROP VIEW IF EXISTS v_sales;
CREATE VIEW v_sales AS
SELECT
    o.order_id,
    o.order_date,
    o.channel,
    c.customer_id,
    c.region,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    ROUND(oi.quantity * oi.unit_price * (1 - oi.discount_pct), 2)                   AS revenue,
    ROUND(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost), 2)  AS profit
FROM orders o
JOIN customers   c  ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products    p  ON p.product_id  = oi.product_id
WHERE o.status = 'Completed';
