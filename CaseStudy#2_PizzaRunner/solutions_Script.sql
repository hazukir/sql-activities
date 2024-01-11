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

/* ALTER TABLE pizza_names
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



/*

How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/