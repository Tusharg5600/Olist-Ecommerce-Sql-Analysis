-- 1. How many orders does Olist have in total?

SELECT COUNT(*) AS total_orders
FROM orders;


-- 2. What proportion of orders are delivered vs cancelled vs in other states?

SELECT
    order_status,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY total DESC;


-- 3. What is the total revenue processed across all orders?

SELECT ROUND(SUM(payment_value)::numeric, 2) AS total_revenue
FROM payments;


-- 4. Which cities and states have the highest customer concentration?
-- Limiting to top 15 to keep the result actionable.

SELECT
    customer_city,
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC
LIMIT 15;


-- 5. Which categories are driving the most orders on the platform?

SELECT
    c.product_category_name_english,
    COUNT(oi.order_id) AS total_orders
FROM products p
JOIN items oi ON p.product_id = oi.product_id
JOIN category c ON p.product_category_name = c.product_category_name
GROUP BY c.product_category_name_english
ORDER BY total_orders DESC
LIMIT 10;


-- 6. How many days early or late are orders arriving each month?

SELECT
    DATE_PART('year', order_purchase_timestamp)  AS order_year,
    DATE_PART('month', order_purchase_timestamp) AS order_month,
    JUSTIFY_INTERVAL(
        AVG(order_estimated_delivery_date - order_delivered_customer_date)
    ) AS avg_days_early_or_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY order_year, order_month
ORDER BY order_year, order_month;


-- 7. How did revenue grow month over month?
-- Filtered to 2017–2018 as 2016 only has 3 months of partial data

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(p.payment_value)::numeric, 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(p.payment_value)::numeric, 2) AS avg_order_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND DATE_PART('year', o.order_purchase_timestamp) BETWEEN 2017 AND 2018
GROUP BY order_month
ORDER BY order_month;


-- 8. Which sellers are generating significant revenue but consistently receiving bad reviews?

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM items oi
JOIN reviews r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING SUM(oi.price) > 10000
ORDER BY avg_review_score ASC, total_revenue DESC
LIMIT 10;


-- 9. Which categories have the highest freight costs relative to their product price?

SELECT
    c.product_category_name_english,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight_cost,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_product_price,
    ROUND(
        (AVG(oi.freight_value) / NULLIF(AVG(oi.price), 0) * 100)::numeric, 2
    ) AS freight_to_price_ratio_pct,
    COUNT(oi.order_id) AS total_orders
FROM items oi
JOIN products p  ON oi.product_id = p.product_id
JOIN category c  ON p.product_category_name = c.product_category_name
GROUP BY c.product_category_name_english
ORDER BY avg_freight_cost DESC
LIMIT 10;


-- 10. Do late deliveries actually hurt review scores?

SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END          AS delivery_status,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY avg_review_score DESC;
