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


