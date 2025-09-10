CREATE DATABASE pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
runner_id VARCHAR(1),
registration_date DATE
);
INSERT INTO runners (runner_id, registration_date)
VALUES
  ('1', '2021-01-01'),
  ('2', '2021-01-03'),
  ('3', '2021-01-08'),
  ('4', '2021-01-15');

CREATE TABLE customer_orders (
    order_id     VARCHAR(10),
    customer_id  VARCHAR(10),
    pizza_id     VARCHAR(10),
    exclusions   VARCHAR(50),
    extras       VARCHAR(50),
    order_time   DATETIME
);
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', NULL, '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', NULL, NULL, '2020-01-08 21:03:13'),
  ('7', '105', '2', NULL, '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', NULL, NULL, '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', NULL, NULL, '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE runner_orders(
order_id VARCHAR(2),
runner_id VARCHAR(1),
pickup_time VARCHAR(25),
distance VARCHAR(15),
duration VARCHAR(15),
cancellation TEXT
);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE pizza_names;
CREATE TABLE pizza_names(
pizza_id VARCHAR(1),
pizza_name VARCHAR(MAX)
);
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
('1', 'Meat Lovers'),
('2', 'Vegetarian');

CREATE TABLE pizza_recipes(
pizza_id VARCHAR(1),
toppings VARCHAR(25)
);
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
('1','1, 2, 3, 4, 5, 6, 8, 10'),
('2', '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings (
topping_id VARCHAR(2),
topping_name TEXT
);
INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  ('1', 'Bacon'),
  ('2', 'BBQ Sauce'),
  ('3', 'Beef'),
  ('4', 'Cheese'),
  ('5', 'Chicken'),
  ('6', 'Mushrooms'),
  ('7', 'Onions'),
  ('8', 'Pepperoni'),
  ('9', 'Peppers'),
  ('10', 'Salami'),
  ('11', 'Tomatoes'),
  ('12', 'Tomato Sauce');

SELECT * FROM runners; 
SELECT * FROM customer_orders;
SELECT * FROM runner_orders; 
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes; 
SELECT * FROM pizza_toppings;

-- Insights
-- 1. How many pizzas were ordered?
SELECT p.pizza_name, COUNT(*) AS total_pizza_ordered
FROM pizza_names p
LEFT JOIN customer_orders c 
ON p.pizza_id = c.pizza_id
GROUP BY pizza_name;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_customers_made
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE cancellation NOT LIKE '%Cancellation'
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(co.order_id) AS number_of_times_delivered
FROM customer_orders co
LEFT JOIN pizza_names pn 
ON co.pizza_id = pn.pizza_id
LEFT JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE cancellation NOT LIKE '%cancellation'
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(c.order_id) AS number_of_orders
FROM customer_orders c
LEFT JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name;

SELECT co.customer_id, 
		SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meat_lovers,
		SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS vegetarian
FROM customer_orders co
JOIN pizza_names pn
ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH stage AS
(SELECT order_id, COUNT(order_id) AS number_of_pizzas
FROM customer_orders
GROUP BY order_id
)
SELECT number_of_pizzas
FROM stage
WHERE number_of_pizzas = (SELECT MAX (number_of_pizzas) FROM stage)

                  -- OR
WITH stage AS
(SELECT order_id, COUNT(order_id) AS number_of_pizzas
FROM customer_orders
GROUP BY order_id
)
SELECT MAX(number_of_pizzas) AS number_of_pizzas
FROM stage


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH landing AS (
SELECT co.customer_id,co.pizza_id, co.exclusions, co.extras
FROM customer_orders co
LEFT JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE cancellation NOT LIKE '%cancellation'),
change_status AS (
SELECT *, CASE WHEN (exclusions IS NULL OR exclusions  = ' ') AND (extras IS NULL OR extras = ' ') THEN 'no_change' ELSE 'one_change_min' END AS change_status
FROM landing)
SELECT 
    customer_id, 
    SUM(CASE WHEN change_status = 'no_change' THEN 1 ELSE 0 END) AS no_change,
    SUM(CASE WHEN change_status = 'one_change_min' THEN 1 ELSE 0 END) AS one_change_min
FROM change_status
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(ro.order_id) AS number_of_pizzas_delivered
FROM customer_orders co
LEFT JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE co.exclusions NOT IN(NULL, '') 
AND co.extras NOT IN(NULL, '')
AND ro.cancellation NOT LIKE '%cancellation';

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR, order_time) AS OrderHour,COUNT(order_id) AS total_volume_of_pizzas_ordered
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT DATEPART(WEEKDAY, order_time) AS day_of_the_week, COUNT(order_id) AS volume_of_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time);

-- 11. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEPART(WEEK,  registration_date) AS weeek_period, COUNT(runner_id) AS no_of_runners 
FROM runners
GROUP BY DATEPART(WEEK,  registration_date);

-- 12. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT ro.runner_id, AVG(DATEDIFF(MINUTE, TRY_CAST (co.order_time AS DATETIME), TRY_CAST (ro.pickup_time AS DATETIME))) as avg_time_in_minutes
FROM customer_orders co
LEFT JOIN runner_orders ro
ON co.order_id = ro.order_id
GROUP BY ro.runner_id;

-- 13. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH base AS (
	SELECT co.order_id, co.customer_id, co.pizza_id, co.order_time, ro.pickup_time, ro.cancellation, 
		   DATEDIFF(MINUTE, TRY_CAST(co.order_time AS DATETIME), TRY_CAST(ro.pickup_time AS DATETIME)) AS prep_time
	FROM customer_orders co
	LEFT JOIN runner_orders	ro ON co.order_id = ro.order_id 
	)	
SELECT order_id, COUNT(*) AS no_of_pizza, AVG(prep_time) AS prep_time
FROM base
WHERE prep_time IS NOT NULL
GROUP BY order_id
ORDER BY no_of_pizza;
 

-- 14. What was the average distance travelled for each customer?
WITH base AS (
		SELECT co.customer_id, ro.order_id, ro.runner_id, ro.distance, 
				TRY_CAST(SUBSTRING(ro.distance, PATINDEX('%[0-9]%', ro.distance), 
                          PATINDEX('%[^0-9.]%', ro.distance + 'X') - PATINDEX('%[0-9]%', ro.distance)) AS DECIMAL(10,2)) distance_trfm
		FROM customer_orders co
		LEFT JOIN runner_orders ro ON co.order_id = ro.order_id
		)
SELECT customer_id, FORMAT(AVG(distance_trfm), '0.00#') AS avg_dist_travld
FROM base
WHERE distance_trfm IS NOT NULL
GROUP BY customer_id;

-- 15. What was the difference between the longest and shortest delivery times for all orders?
WITH base AS(
		SELECT MAX(TRY_CAST(duration AS DECIMAL(10,2))) AS max_duration, MIN(TRY_CAST(duration AS DECIMAL(10,2))) AS min_duration
		FROM runner_orders
		WHERE duration IS NOT NULL
		AND duration != 'null')
SELECT max_duration, min_duration, (max_duration - min_duration) AS duration_difference
FROM base
GROUP BY max_duration, min_duration;


-- 16. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH base AS (
		SELECT TRY_CAST(runner_id AS INT) runner_id, TRY_CAST(order_id AS INT) order_id, distance, 
		       TRY_CAST(SUBSTRING(distance, PATINDEX('%[0-9]%', distance), 
		       PATINDEX('%[^0-9.]%', distance + 'X') - PATINDEX('%[0-9]%', distance)) AS DECIMAL) distance_trfm, duration, 
			   TRY_CAST(SUBSTRING(duration, PATINDEX('%[0-9]%', duration), 
               PATINDEX('%[^0-9.]%', duration + 'X') - PATINDEX('%[0-9]%', duration)) AS DECIMAL) duration_trfm
		FROM runner_orders)
SELECT runner_id, order_id, FORMAT(AVG(distance_trfm/duration_trfm), '0.##') avg_delivery_speed
from base
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;

-- 17. What is the successful delivery percentage for each runner?
WITH base AS (
		SELECT runner_id, SUM(CASE WHEN pickup_time != 'null' THEN 1 ELSE 0 END) AS successful_del, COUNT(*) AS total_del
		FROM runner_orders
		GROUP BY runner_id)
SELECT *, FORMAT((((CAST(successful_del AS DECIMAL(10,2)))/(CAST(total_del AS DECIMAL(10,2))))*100), '0.00##') AS succ_del_pct
FROM base;