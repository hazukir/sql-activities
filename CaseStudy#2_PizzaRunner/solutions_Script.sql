--USE pizza_runner;

-- ************** A. Pizza Metrics **************



-- 01 - How many pizzas were ordered?
SELECT 
	COUNT(*) AS totalOrders
FROM customer_orders;

-- 02 How many unique customer orders were made?
SELECT
	customer_id,
	COUNT(DISTINCT customer_id) AS totalCustomersOrders
FROM customer_orders
GROUP BY customer_id;

-- 03 How many successful orders were delivered by each runner?

SELECT 
	r.runner_id
	,COUNT(ro.order_id) totalSuccessfulOrders
FROM runner_orders AS ro
INNER JOIN runners AS r
	ON ro.runner_id = r.runner_id
WHERE ro.duration <> 'null'
GROUP BY r.runner_id;


-- 04 How many of each type of pizza was delivered?

/* I altered the pizza_name from TEXT to VARCHAR, but If I did have access to the CRUD operations, I would use
CAST. In the original form I'd use also CAST in GROUP BY, considering that the changes to the pizza_name occurs only
when we query the data. 
ALTER TABLE pizza_names
ALTER COLUMN pizza_name VARCHAR(25);
GO */

SELECT 
    pa.pizza_name,
    CAST(COUNT(pa.pizza_name) AS INT) AS pizza_count
FROM runner_orders AS ro
INNER JOIN customer_orders AS co 
	ON ro.order_id = co.order_id
INNER JOIN pizza_names AS pa 
	ON co.pizza_id = pa.pizza_id
WHERE ro.duration <> 'null'
GROUP BY pa.pizza_name;


-- 05 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	[co].[customer_id],
	pa.pizza_name,
	COUNT(co.order_id) AS totalOrders
FROM customer_orders AS co
INNER JOIN pizza_names AS pa
	ON co.pizza_id = pa.pizza_id
GROUP BY co.customer_id, pa.pizza_name;



-- 06 What was the maximum number of pizzas delivered in a single order?

WITH PizzaCounts AS (
    SELECT
        co.order_id,
        COUNT(co.pizza_id) AS pizza_count
    FROM
        customer_orders co
    GROUP BY
        co.order_id
)

SELECT
    pc.order_id,
    pc.pizza_count
FROM
    PizzaCounts pc
WHERE
    pc.pizza_count = (
        SELECT MAX(pizza_count) FROM PizzaCounts
    );


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
	co.customer_id
	,SUM(CASE WHEN
		co.exclusions IS NOT NULL AND co.exclusions <> 'null' AND LEN(exclusions) > 0
		OR co.extras IS NOT NULL AND co.extras <> 'null' AND LEN(extras) > 0
		THEN 1 ELSE 0
		END) AS deliveryChanges

	,SUM(CASE WHEN
		co.exclusions IS NOT NULL AND co.exclusions <> 'null' AND LEN(exclusions) > 0
		OR co.extras IS NOT NULL AND co.extras <> 'null' AND LEN(extras) > 0
		THEN 0 ELSE 1
		END) AS NoDeliveryChanges
FROM [dbo].[customer_orders] co
JOIN runner_orders AS ro
	ON co.order_id = ro.order_id
GROUP BY co.customer_id




-- How many pizzas were delivered that had both exclusions and extras?
SELECT 
  COUNT(pizza_id) as pizzas_delivered_with_exclusions_and_extras 
FROM 
  customer_orders as co 
  INNER JOIN runner_orders as ro on ro.order_id = co.order_id 
WHERE 
  pickup_time<>'null'
  AND (exclusions IS NOT NULL AND exclusions<>'null' AND LEN(exclusions)>0) 
  AND (extras IS NOT NULL AND extras<>'null' AND LEN(extras)>0); 


-- What was the total volume of pizzas ordered for each hour of the day?




--What was the volume of orders for each day of the week?
