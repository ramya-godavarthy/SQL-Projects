-- ------------------------------------------------------------------------------
-- ------   CASE STUDY #2: PIZZA RUNNER DATA CLEANING AND TRANSFORAMTIONS  ------
-- ------------------------------------------------------------------------------

# View all tables
SELECT * FROM runners;
SELECT * FROM pizza_toppings;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_names;

# DATA CLEANING AND TRANSFORMATIONS
-- ---- customer_orders TABLE --------
SELECT * FROM customer_orders;
-- Inconsistency in enxclusions and extras columns
-- NULL type or null string or left blank
-- Create temporary table

DROP TABLE IF EXISTS customers_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS
	SELECT 
		order_id,
        customer_id,
        pizza_id,
        CASE 
			WHEN exclusions is null or exclusions = 'null' THEN ''
            ELSE exclusions
		END AS exclusions,
        CASE 
			WHEN extras is null or extras = 'null' THEN ''
            ELSE extras
		END AS extras,
        order_time
	FROM customer_orders;
       
SELECT * FROM customer_orders_temp;

-- ---- runner_orders TABLE --------
SELECT * FROM runner_orders;
-- Inconsistency in the cancellation column, pickup_time, distance, duration 
-- NULL type, null string, ''
-- pickup_time -- varchar -- timestamp
-- distance -- varchar -- numeric
-- duration -- varchar -- integer

DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
	SELECT 
		order_id,
        runner_id,
        CASE
			WHEN pickup_time = 'null' THEN NULL
            ELSE pickup_time
		END AS pickup_time,
        CASE
			WHEN distance = 'null' THEN NULL
            WHEN distance LIKE '%km' THEN TRIM('km' from distance)
            ELSE distance
		END AS distance,
        CASE 
			WHEN duration = 'null' THEN NULL
            ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT)
		END AS duration,
        CASE 
			WHEN cancellation is null or cancellation = 'null' THEN ''
            ELSE cancellation
		END AS cancellation
	FROM runner_orders;
    
SELECT * FROM runner_orders_temp;


