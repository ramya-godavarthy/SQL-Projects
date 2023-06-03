-- -------------------------------------------------------
-- ------   CASE STUDY #1: DANNY'S DINER QUESTIONS  ------
-- -------------------------------------------------------

# View all tables
SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

# Case Study Questions

# 1. What is the total amount each customer spent at the restaurant
-- customer id and products purchased from sales table
-- price of each product from menu table
-- sum(price) and join sales and menu
-- EACH customer --  group by customer_id

SELECT customer_id, CONCAT('$', SUM(price)) AS total_amount
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

#2 How many days has each customer visited the restaurant
-- EACH customer -- group by customer_id
-- how many days -- count by distinct order_date 

SELECT customer_id, COUNT(DISTINCT order_date) AS visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

#3 What was the first item from the menu purchased by each customer
-- First item -- RANK functions - Dense Rank
-- EACH customer -- group by customer_id 

WITH orders_cte AS (
	SELECT customer_id, order_date, product_name,
		DENSE_RANK() OVER(PARTITION BY customer_id 
							ORDER BY order_date)
		AS rank_item
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
    )
    
SELECT customer_id, order_date, product_name
FROM orders_cte
WHERE rank_item = 1
GROUP BY customer_id, product_name, order_date;

#4 What is the most purchased item on the menu and how many times was it purchased by all the customers
-- Most purchased -- Max of items count

SELECT menu.product_name AS most_purchased_item, 
		COUNT(sales.product_id) AS product_count
FROM sales
JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY product_count DESC
LIMIT 1;

#5 Which item was most popular for each customer
-- count of each item by every customer - use rank() or dense_rank()
-- most popular -- rank == 1

WITH rank_cte AS (
	SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS order_count,
	DENSE_RANK() OVER(PARTITION BY s.customer_id 
						ORDER BY COUNT(m.product_name) DESC) AS item_rank
	FROM sales s
	JOIN menu m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM rank_cte
WHERE item_rank = 1;

#6 Which item was purchased first by the customer after they became a member?
-- item(menu table) purchased (sales table) after join_date(members) of customers 

WITH rank_cte AS(
	SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS purchased_rank
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date
)

SELECT customer_id, join_date, order_date, m.product_name 
FROM rank_cte r
JOIN menu m
ON r.product_id = m.product_id
WHERE purchased_rank = 1
ORDER BY join_date;

#7 Which item was purchased just before the customer became a member?
WITH rank_cte AS(
	SELECT s.customer_id, m.join_date, s.order_date, s.product_id, 
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date
)

SELECT r.customer_id, r.join_date, r.order_date, m.product_name
FROM rank_cte r
JOIN menu m
ON r.product_id = m.product_id
WHERE purchase_rank = 1
ORDER BY r.join_date;

#8 What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(m.product_name) AS total_items, 
		CONCAT('$ ', SUM(m.price)) AS total_amount
FROM sales s
JOIN members mem
ON s.customer_id = mem.customer_id
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
ORDER BY 1;

#9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

SELECT s.customer_id, 
		SUM(CASE 
			WHEN m.product_name = 'sushi' THEN m.price*20
            ELSE m.price*10
            END) AS total_points            
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

#10 In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi — 
-- how many points do customer A and B have at the end of January?

SELECT s.customer_id,
	SUM(CASE 
		WHEN s.order_date - mem.join_date >= 0 
			AND s.order_date - mem.join_date <= 6 THEN m.price*20
        WHEN m.product_name = 'sushi' THEN m.price*20
        ELSE m.price*10
	END) AS points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE EXTRACT(MONTH FROM order_date) = 1 
	AND EXTRACT(YEAR FROM order_date) = 2021
GROUP BY s.customer_id
ORDER BY s.customer_id;

# Bonus 1: Recreate the table with — customer_id, order_date, product_name, price, 
-- member (Y/N) so that Danny would not need to join the underlying tables using SQL. 

CREATE OR REPLACE VIEW member_order_status AS 
SELECT s.customer_id, s.order_date, m.product_name, m.price,
	(
		CASE
			WHEN mem.join_date <= s.order_date THEN 'Y'
            ELSE 'N'
		END
	) AS member
FROM sales s
LEFT JOIN members mem
ON s.customer_id = mem.customer_id
JOIN menu m
ON s.product_id = m.product_id;

SELECT * FROM member_order_status;

# Bonus 2: Rank All The Things — Danny also requires further information about the
-- ranking of customer products, but he purposely does not need the ranking non-member 
-- purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

SELECT *,
	( 
		CASE 
			WHEN member = 'N' THEN NULL
            ELSE RANK() over(PARTITION BY customer_id,member ORDER BY order_date)
		END
	) as products_rank
FROM member_order_status;
