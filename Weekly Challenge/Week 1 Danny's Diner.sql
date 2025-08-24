-- CREATE DATABASE
CREATE DATABASE dannys_diner;

-- ACCESS DATABASE
USE dannys_diner;

-- CREATE AND INSERT DATA TABLES

	-- SALES TABLE
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

	--MENU TABLE
 CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
	--MEMBERS TABLE
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  -- ACCESS THE TABLES 
  SELECT * FROM sales;
  SELECT * FROM menu;
  SELECT * FROM members;


-- Insight 1.What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_price
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Insight 2.How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT order_date)AS number_of_days
FROM sales s
GROUP BY customer_id;

-- Insight 3.What was the first item from the menu purchased by each customer?
WITH purchase_rank AS 
(SELECT s.customer_id, m.product_name, s.order_date, 
		RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS first_purchase
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id)
SELECT customer_id, product_name, order_date
FROM purchase_rank
WHERE first_purchase = 1;

-- Insight 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 m.product_name, COUNT(m.product_name) AS number_of_times_purchased
FROM menu m
LEFT JOIN sales s ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY number_of_times_purchased DESC;

-- Insight 5.Which item was the most popular for each customer?
WITH x AS(
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS purchase_frequency,
RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(m.product_name) DESC) AS rnk
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name)
SELECT customer_id, product_name, purchase_frequency
FROM x
WHERE rnk = 1;

-- Insight 6.Which item was purchased first by the customer after they became a member?
WITH y AS(
SELECT s.customer_id, m.product_name, me.join_date, s.order_date,
RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members me ON s.customer_id = me.customer_id 
WHERE s.order_date > me.join_date)
SELECT customer_id, product_name, join_date, order_date, rnk
FROM y
WHERE rnk = 1;

--Insight 7. Which item was purchased just before the customer became a member?
WITH z AS(
SELECT s.customer_id, m.product_name, me.join_date, s.order_date,
RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members me ON s.customer_id = me.customer_id
WHERE s.order_date < me.join_date)
SELECT customer_id, product_name, join_date, order_date, rnk
FROM z
WHERE rnk = 1;

-- Insight 8. What is the total items and amount spent for each member before they became a member?
WITH z AS(SELECT s.customer_id, COUNT(m.product_name) AS total_items, SUM(m.price) AS total_amount, s.order_date, me.join_date
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members me ON s.customer_id = me.customer_id
WHERE s.order_date < me.join_date
GROUP BY s.customer_id, s.order_date, me.join_date)
SELECT customer_id, SUM(total_items) total_items, SUM(total_amount) total_amount
FROM z
GROUP BY customer_id;

-- Insight 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH y AS(
SELECT s.customer_id, m.product_name, SUM(m.price) AS total_price, 
CASE WHEN m.product_name = 'sushi' THEN 2 * (SUM (m.price)) ELSE 10* (SUM(m.price)) END AS total_points
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name)
SELECT customer_id, product_name, SUM(total_price)total_amount, SUM(total_points)totalpoints
FROM y
GROUP BY customer_id, product_name;

-- Insight 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all
-- items, not just sushi - how many points do customer A and B have at the end of January?
with y AS(SELECT s.customer_id, m.product_name, me.join_date, m.price, s.order_date, DATEDIFF (day,me.join_date, s.order_date) AS no_of_days,
CASE WHEN s.order_date > me.join_date AND DATEDIFF(day, me.join_date, s.order_date) <= 7 THEN m.price * 2 ELSE m.price 
END AS purchase_point
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members me ON s.customer_id = me.customer_id
WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31')
SELECT customer_id, SUM(price)total_price, SUM(purchase_point)total_purchase_point
FROM y
GROUP BY customer_id;





















