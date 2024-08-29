USE magist;

-- Exploring the tables

-- 1. total order number = 99441
SELECT COUNT(*) FROM orders;

-- 2. How many are delivered or in other status?
SELECT order_status, COUNT(*) FROM orders GROUP BY order_status;
-- 96478 delivered
--  1107 shipped
--   625 cancelled   <- something to keep in mind
--   609 unavailable   ??
--   314 invoiced    <- should maybe check for how long
--   301 processing
--     5 created
--     2 approved

-- 3. Is Magist growing?
SELECT 
    YEAR(order_purchase_timestamp) AS 'year',
    MONTH(order_purchase_timestamp) AS 'month',
    COUNT(*) AS 'number of orders'
FROM
    orders
GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp) ASC , MONTH(order_purchase_timestamp) ASC;
-- one needs to be carefull with data from 2016 as well as last months, otherwise growth visible

--  4. how many products: 32951, no duplicates
SELECT COUNT(*), COUNT(DISTINCT product_id) FROM products;

-- 5. products per category
SELECT pt.product_category_name_english, COUNT(*) AS 'number of items' FROM products AS p LEFT JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name  GROUP BY pt.product_category_name_english ORDER BY COUNT(*) DESC;
-- computer accessories #7 with 1639 products
-- telephony #10 with 1134
-- electronics #19 with 517
-- computers only 30

-- 6. How many products were actually bought?
SELECT COUNT(DISTINCT product_id) FROM order_items;
-- 32951 - all were sold at least once

-- 7. cheapest and most expensive
SELECT p.product_id, pt.product_category_name_english, oi.price FROM order_items AS oi LEFT JOIN products AS p ON oi.product_id=p.product_id LEFT JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name ORDER BY price DESC LIMIT 10;
-- most expensive: 6735, some high valued computers on 2 and 6
SELECT p.product_id, pt.product_category_name_english, oi.price FROM order_items AS oi LEFT JOIN products AS p ON oi.product_id=p.product_id LEFT JOIN product_category_name_translation AS pt ON p.product_category_name=pt.product_category_name ORDER BY price ASC LIMIT 10;
-- cheapest are below 1euro

-- 8. lowest and highest payments
SELECT * FROM order_payments ORDER BY payment_value ASC;
-- plenty of really low values!
SELECT * FROM order_payments ORDER BY payment_value DESC;
-- highest: 13664

-- A. Additional earnings due to payment installments:
SELECT SUM(price) FROM order_items;
SELECT SUM(payment_value) FROM order_payments;
-- 2.5Mio 