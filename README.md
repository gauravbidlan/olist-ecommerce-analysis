# olist-ecommerce-analysis
D2C E-Commerce Analytics | MySQL + Power BI | 100K+ Orders
-- ═══════════════════════════════════════════
-- D2C E-Commerce Analytics | Olist Dataset
-- Author: Gaurav Bidlan
-- Tools: MySQL Workbench
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- ═══════════════════════════════════════════

-- ─────────────────────────────────────────
-- Query 1: Overall Business Size
-- Purpose: Get total revenue, orders, and AOV
-- ─────────────────────────────────────────
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    ...

-- ─────────────────────────────────────────
-- Query 2: Monthly Revenue Trend
-- Purpose: Track revenue growth over time
-- ─────────────────────────────────────────
SELECT ...
