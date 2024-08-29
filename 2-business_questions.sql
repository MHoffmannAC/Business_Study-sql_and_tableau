USE magist;

-- 3.1 sold categories, item cound, percentage and average price
SELECT
	electronics, COUNT(*) as 'items sold', COUNT(*) * 100 / SUM(COUNT(*)) OVER () AS percentage, AVG(price)
FROM
(SELECT 
    pt.product_category_name_english, oi.price AS price,
    CASE WHEN product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony') THEN 'electronics - apple related'
WHEN product_category_name_english IN
(
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'
) THEN 'electronics - a bit broader'			
ELSE 'other categories' 
END AS electronics
FROM
    order_items AS oi
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name) AS sub
GROUP BY electronics;


SELECT 
    pt.product_category_name_english, oi.price AS price,
    CASE WHEN product_category_name_english IN 
    (
'electronics',						
'computers_accessories',			
'computers',						
'tablets_printing_image',
'telephony') THEN 'electronics - apple related'
WHEN product_category_name_english IN
(
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'
) THEN 'electronics - others'			
ELSE 'others' 
END AS electronics
FROM
    order_items AS oi
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name;
    
-- 3.2 sellers
-- time range in database
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM orders;
-- Sep. 2016 - Oct 2018
-- better use only 01/2017 - 08/2018 for monthly averages, since others are only partially available

-- amount of sellers
SELECT COUNT(DISTINCT seller_id) FROM sellers;
-- 3095 sellers, no duplicates
SELECT COUNT(DISTINCT seller_id) FROM order_items;
-- all of them sold at least one item

-- how many tech sellers?
SELECT 
    COUNT(distinct oi.seller_id),
    CASE WHEN product_category_name_english IN 
    (
'electronics',						
'computers_accessories',			
'computers',						
'tablets_printing_image',
'telephony') THEN 'electronics apple related'
WHEN product_category_name_english IN
(
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'
) THEN 'electronics - others'			
ELSE 'false' 
END AS electronics
FROM
    order_items AS oi
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
GROUP BY electronics;
-- 444 in apple related electronics
-- 259 in other electronics
-- 2894 others

-- how do we classify a seller as "Tech seller"?
SELECT
	COUNT(DISTINCT seller_id),
CASE WHEN seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony')) THEN 'electronics - apple related'
WHEN seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'
)) THEN 'electronics - a bit broader'
ELSE 'others'
END as category
FROM sellers
GROUP BY category;

-- total earnings
SELECT SUM(price) FROM order_items;
-- 13.5mio Euros

-- by type of seller:
SELECT SUM(price) FROM order_items AS oi LEFT JOIN orders as o ON oi.order_id=o.order_id
WHERE 
seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony'));
-- 4.1mio;
SELECT SUM(price) FROM order_items AS oi LEFT JOIN orders as o ON oi.order_id=o.order_id
WHERE 
seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'));
-- 3.65mio

-- average monthly income (check only 01/17-08/18)
SELECT COUNT(DISTINCT seller_id) as '# of sellers', SUM(oi.price) as 'total earnings', SUM(oi.price)/20 'monthly average earnings', SUM(oi.price)/(20*COUNT(DISTINCT seller_id)) 'monthly average earnings per seller' FROM order_items AS oi LEFT JOIN orders as o ON oi.order_id=o.order_id WHERE order_purchase_timestamp BETWEEN '2017-01-01 00:00:00' AND '2018-08-31 23:59:59'; 
-- that's 220 per month...
SELECT 
    SUM(oi.price) / (20 * COUNT(DISTINCT seller_id)) AS 'monthly average earnings per seller'
FROM
    order_items AS oi
        LEFT JOIN
    orders AS o ON oi.order_id = o.order_id
WHERE
    order_purchase_timestamp BETWEEN '2017-01-01 00:00:00' AND '2018-08-31 23:59:59'
AND 
seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony'));
-- 464
SELECT 
    SUM(oi.price) / (20 * COUNT(DISTINCT seller_id)) AS 'monthly average earnings per seller'
FROM
    order_items AS oi
        LEFT JOIN
    orders AS o ON oi.order_id = o.order_id
WHERE
    order_purchase_timestamp BETWEEN '2017-01-01 00:00:00' AND '2018-08-31 23:59:59'
AND 
seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'));
-- 539

-- 3.3 delivery time
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) FROM orders;
-- 12 tage

SELECT punctuality, COUNT(*) FROM
(SELECT order_id,order_delivered_customer_date, order_estimated_delivery_date,
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality FROM orders) as sub
GROUP BY punctuality;
-- 92775 on time, 6666 delayed 

SELECT punctuality, COUNT(*) FROM
(SELECT o.order_id,order_delivered_customer_date, order_estimated_delivery_date,
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality FROM orders as o LEFT JOIN order_items as oi on o.order_id=oi.order_id 
WHERE seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony'))) as sub
GROUP BY punctuality;
-- 32327 on time, 2286 delayed

SELECT punctuality, COUNT(*) FROM
(SELECT o.order_id,order_delivered_customer_date, order_estimated_delivery_date,
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality FROM orders as o LEFT JOIN order_items as oi on o.order_id=oi.order_id 
WHERE seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'air_conditioning',
'audio',
'cine photo',
'consoles_games',
'home_appliances',
'home_appliances_2',
'watches_gifts',
'security_and_services',
'signaling_and_security'))) as sub
GROUP BY punctuality;
-- 27967 on time, 1992 delayed

-- any pattern?

SELECT punctuality, COUNT(*) FROM
(SELECT o.order_id,order_delivered_customer_date, order_estimated_delivery_date,
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality FROM orders as o LEFT JOIN order_items as oi on o.order_id=oi.order_id 
WHERE seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony'))) as sub
GROUP BY punctuality;


SELECT AVG(price), AVG(freight_value),
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality FROM orders as o LEFT JOIN order_items as oi on o.order_id=oi.order_id
GROUP BY punctuality;
-- average of delayed items is only slightly bigger and more expensive, not really a pattern

SELECT state, 
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)>0
THEN 'delayed'
ELSE 'on time'
END AS punctuality,
COUNT(*)
FROM orders as o LEFT JOIN order_items as oi on o.order_id=oi.order_id LEFT JOIN customers as c ON o.customer_id = c.customer_id LEFT JOIN geo as g ON c.customer_zip_code_prefix=g.zip_code_prefix
GROUP BY punctuality, state
ORDER BY state;

-- generate list of tech- and non-tech-sellers for Tableau
SELECT seller_category, COUNT(DISTINCT seller_id) FROM
(SELECT Distinct seller_id,
CASE WHEN seller_id IN
(SELECT 
        oi.seller_id
    FROM
        order_items AS oi
            LEFT JOIN
        products AS p ON oi.product_id = p.product_id
            LEFT JOIN
        product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
	WHERE product_category_name_english IN 
    (
'computers_accessories',			
'computers',
'electronics',						
'pc_gamer',						
'tablets_printing_image',
'telephony')) THEN 'tech-seller'
ELSE 'non-tech'
END as seller_category
FROM order_items AS oi LEFT JOIN orders as o ON oi.order_id=o.order_id) as sub GROUP BY seller_category;