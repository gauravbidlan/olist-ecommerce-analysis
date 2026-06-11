-- ═══════════════════════════════════════════════════
-- D2C E-Commerce Analytics | Olist Dataset
-- Author: Gaurav Bidlan
-- Tools: MySQL Workbench
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- ═══════════════════════════════════════════════════


-- ─────────────────────────────────────
-- Query 1: Overall Business Size
-- Purpose: Total revenue, orders and AOV
-- ─────────────────────────────────────
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM payments;


-- ─────────────────────────────────────
-- Query 2: Monthly Revenue Trend
-- Purpose: Track revenue growth over time
-- ─────────────────────────────────────
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;


-- ─────────────────────────────────────
-- Query 3: Revenue by Payment Type
-- Purpose: Which payment method dominates
-- ─────────────────────────────────────
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────
-- Query 4: Repeat Customer Rate
-- Purpose: Measure customer retention
-- ─────────────────────────────────────
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2) AS repeat_rate_pct
FROM (
    SELECT 
        customer_unique_id, 
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
) AS customer_orders;


-- ─────────────────────────────────────
-- Query 5: Top 10 Cities by Revenue
-- Purpose: Identify highest demand regions
-- ─────────────────────────────────────
SELECT 
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city, c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────
-- Query 6: High Value Customers (CTE)
-- Purpose: Identify top spending customers
-- ─────────────────────────────────────
WITH customer_revenue AS (
    SELECT 
        c.customer_unique_id,
        ROUND(SUM(p.payment_value), 2) AS total_spent,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT *,
    ROUND(total_spent / total_orders, 2) AS avg_order_value
FROM customer_revenue
ORDER BY total_spent DESC
LIMIT 20;


-- ─────────────────────────────────────
-- Query 7: Average Delivery Time
-- Purpose: Measure fulfillment speed
-- ─────────────────────────────────────
SELECT 
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 1) AS avg_delivery_days,
    MIN(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )) AS fastest_days,
    MAX(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )) AS slowest_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;


-- ─────────────────────────────────────
-- Query 8: Late Delivery Rate
-- Purpose: Measure delivery promise vs actual
-- ─────────────────────────────────────
SELECT 
    COUNT(*) AS late_orders,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) 
        FROM orders 
        WHERE order_status = 'delivered'
    ), 2) AS late_delivery_rate_pct
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date > order_estimated_delivery_date;


-- ─────────────────────────────────────
-- Query 9: Order Status Breakdown (Window Function)
-- Purpose: See distribution of all order statuses
-- ─────────────────────────────────────
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- ─────────────────────────────────────
-- Query 10: Top Categories by Revenue
-- Purpose: Identify best