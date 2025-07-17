-- 1.What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_price
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;