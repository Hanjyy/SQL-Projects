DROP DATABASE IF EXISTS dannys_diner;

CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
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
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

USE dannys_diner;

       -- CASE STUDY QUESTIONS AND ANSWERS 
-- Each of the following case study questions can be answered using a single SQL statement:

-- 1. What is the total amount each customer spent at the restaurant?
SELECT sl.customer_id, sum(mn.price) AS total_spent
FROM sales sl
JOIN menu mn ON sl.product_id AND mn.product_id
group by sl.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, count(distinct order_date) as days_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_cte AS( 
				SELECT sl.customer_id, mn.product_name, sl.order_date, 
					   DENSE_RANK() OVER(PARTITION BY sl.customer_id ORDER BY sl.order_date) AS product_purchase_ranking
				FROM sales sl
				JOIN menu mn ON sl.product_id AND mn.product_id)
SELECT DISTINCT customer_id, product_name, order_date
FROM rank_cte
WHERE product_purchase_ranking = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT mn.product_name, COUNT(*) AS product_purchase_freq
FROM menu mn 
JOIN sales sl
ON mn.product_id = sl.product_id
GROUP BY mn.product_name
ORDER BY product_purchase_freq DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH popular_item AS(
					  SELECT sl.customer_id, mn.product_name, count(mn.product_name) AS popular_item,
					  DENSE_RANK() OVER(PARTITION BY sl.customer_id ORDER BY count(mn.product_name) DESC) AS ranking
                      FROM sales sl
                      JOIN menu mn ON mn.product_id = sl.product_id
                      GROUP BY sl.customer_id, mn.product_name)
SELECT customer_id, product_name, popular_item
FROM popular_item
WHERE ranking = 1;

WITH pop_prod_cte AS 
				(SELECT sl.customer_id, mn.product_name, COUNT(*)AS prd_purc_freq, 
						DENSE_RANK() OVER(PARTITION BY sl.customer_id ORDER BY COUNT(*) DESC) AS freq_rank
				FROM members mm
				RIGHT JOIN sales sl
				ON mm.customer_id = sl.customer_id
				LEFT JOIN menu mn
				ON mn.product_id = sl.product_id
				GROUP BY sl.customer_id, mn.product_name)
SELECT customer_id, product_name, prd_purc_freq
FROM pop_prod_cte
WHERE freq_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH first_purchase AS(
					   SELECT mb.customer_id, mb.join_date, mn.product_name, sl.order_date,
					          DENSE_RANK() OVER(PARTITION BY mb.customer_id ORDER BY sl.order_date) AS first_purchase_ranking
					   FROM members mb
                       JOIN sales sl ON mb.customer_id = sl.customer_id
					   JOIN menu mn ON sl.product_id = mn.product_id 
					   WHERE sl.order_date >= mb.join_date)
SELECT customer_id, join_date, order_date, product_name
FROM first_purchase
WHERE first_purchase_ranking = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH before_purchase AS(
			            SELECT mb.customer_id, mn.product_name, mb.join_date, sl.order_date,
						       DENSE_RANK() OVER(partition by mb.customer_id ORDER BY sl.order_date) AS non_member_purchase
						FROM members mb
					    JOIN sales sl ON mb.customer_id = sl.customer_id
					    JOIN menu mn ON sl.product_id = mn.product_id
                        WHERE sl.order_date < mb.join_date)
SELECT customer_id, product_name, join_date, order_date
FROM before_purchase
WHERE non_member_purchase = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH amount_spent_before as
							(SELECT mb.customer_id, mn.product_name, mb.join_date, sl.order_date, mn.price
							FROM members mb
							JOIN sales sl ON mb.customer_id = sl.customer_id
							JOIN menu mn ON sl.product_id = mn.product_id
							WHERE sl.order_date > mb.join_date
                            ORDER BY mb.customer_id)
SELECT customer_id, COUNT(*) AS total_items, SUM(price) AS amount_spent
FROM amount_spent_before
GROUP BY customer_id
ORDER BY customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH customer_points AS(
						SELECT sl.customer_id, mn.product_name, mn.price
						FROM sales sl
						JOIN menu mn ON sl.product_id = mn.product_id)
SELECT customer_id, SUM(price) AS total_revenue, SUM(CASE WHEN product_name = "sushi" THEN (price * (2)) ELSE (price + (10)) END) AS points
FROM customer_points
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
WITH points AS(
                SELECT sl.customer_id, mb.join_date, mn.product_name, mn.price, sl.order_date, (sl.order_date - mb.join_date) AS date_difference
				FROM members mb
				JOIN sales sl ON mb.customer_id = sl.customer_id
				JOIN menu mn ON sl.product_id = mn.product_id
				WHERE mb.join_date <= sl.order_date
				ORDER BY customer_id),
customer_total_point AS(
				select *, (case when date_difference <= 7 then price * 2 else price end) AS customer_points
                FROM points)
SELECT customer_id, SUM(price) AS total_price, SUM(customer_points) AS total_points
FROM customer_total_point
GROUP BY customer_id
ORDER BY customer_id;
