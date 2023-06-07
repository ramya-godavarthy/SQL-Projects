-- ------------------------------------------------------------------------------
-- ------   CASE STUDY #2: PIZZA RUNNER PIZZA METRICS  --------------------------
-- ------------------------------------------------------------------------------

# 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_ordered
FROM customer_orders_temp;

# 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM customer_orders_temp;

# 3. How many successful orders were delivered by each runner?
-- EACH runner -- group by runner_id
-- How many -- count(order_id)

SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders_temp
WHERE cancellation = ''
GROUP BY runner_id
ORDER BY runner_id;

# 4. How many of each type of pizza were delivered?
-- EACH -- group by pizza_id

SELECT p.pizza_name, COUNT(c.pizza_id)
FROM runner_orders_temp r
JOIN customer_orders_temp c
ON r.order_id = c.order_id
JOIN pizza_names p
ON c.pizza_id = p.pizza_id
WHERE distance IS NOT NULL
GROUP BY p.pizza_name;

# 5.How many Vegetarian and Meatlovers were ordered by each customer?
-- how many -- count 
-- each customer -- group by
-- customer_orders_temp join runner_orders_temp join pizza_names
SELECT c.customer_id, pizza_name, COUNT(c.customer_id) AS pizza_count
FROM customer_orders_temp c
JOIN pizza_names p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id,p.pizza_name
ORDER BY c.customer_id;

# 6. What was the maximum number of pizzas delivered in a single order?

WITH order_rank AS (
	SELECT c.order_id, COUNT(c.order_id) AS pizza_count,
    RANK() OVER(ORDER BY COUNT(c.order_id) DESC) AS rnk
    FROM customer_orders_temp c
    JOIN runner_orders_temp r
    ON c.order_id = r.order_id
    WHERE distance is NOT NULL
    GROUP BY c.order_id
)

SELECT order_id, pizza_count 
FROM order_rank
WHERE rnk = 1;

CREATE TEMPORARY TABLE delivered_orders AS
SELECT * FROM customer_orders_temp
JOIN runner_orders_temp 
USING (order_id)
WHERE distance IS NOT NULL;

# 7. For each customer, how many delivered pizzas had at least 1 change, 
# and how many had no changes?
SELECT customer_id, 
		SUM(
			CASE
				WHEN (exclusions <> '' OR extras <> '') THEN 1
				ELSE 0
			END
            ) AS change_in_order,
		SUM(
			CASE 
				WHEN (exclusions = '' AND extras = '') THEN 1
                ELSE 0
			END
			) AS no_change_in_order
FROM delivered_orders
GROUP BY customer_id
ORDER BY customer_id;

# 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS pizzas_deivered_exclusions_and_extras
FROM delivered_orders
WHERE exclusions <> '' AND extras <> '';

# 9. What was the total volume of pizzas ordered for each hour of the day?
-- extract (hour from order_time) or hour(order_time)
SELECT hour(order_time) AS hour_of_day,
	COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY hour_of_day
ORDER BY hour_of_day;

# 10. What was the volume of orders for each day of the week?
SELECT dayname(order_time) AS week_day,
	COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY week_day
ORDER BY week_day;




    

