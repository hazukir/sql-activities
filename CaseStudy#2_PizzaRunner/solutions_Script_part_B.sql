USE [pizza_runner];
GO



-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

WITH runnerSignups AS (
  SELECT -- Selecting runner_id, registration_date, and calculating startOfWeek
    runner_id, 
    registration_date, 
	-- Truncating registration_date to the beginning of the week, then adding 4 days
    -- DATETRUNC truncates the date to the start of the week
    -- DATEADD adds 4 days to the truncated date to set it to the 5th day of the week (assuming Monday is the start of the week)
    DATEADD(day, 4, DATETRUNC(week, registration_date)) AS startOfWeek 
  FROM 
    runners
)

SELECT 
  startOfWeek, 
  COUNT(runner_id) AS signUps --Counting the number of runner_id entries for each start_of_week
FROM 
  runnerSignups 
GROUP BY 
  startOfWeek 
ORDER BY 
  startOfWeek;




-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
  ro.runner_id, 
  AVG(
    DATEDIFF(
      MINUTE, 
      CONVERT(DATETIME, co.order_time), 
      TRY_CONVERT(DATETIME, ro.pickup_time) -- Because ro.pickup_time has 2 rows with NULL, I used this function
    )
  ) AS avg_minutes_to_pickup 
FROM runner_orders AS ro 
INNER JOIN customer_orders AS co 
  ON ro.order_id = co.order_id 
WHERE 
  ro.pickup_time IS NOT NULL 
  AND co.order_time IS NOT NULL -- Ensure order_time is not NULL
GROUP BY 
  ro.runner_id;



-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_CTE AS (
  SELECT 
    ro.order_id, 
    COUNT(co.pizza_id) as number_of_pizzas, 
    MAX(
		DATEDIFF(MINUTE, 
				co.order_time, 
				TRY_CONVERT(DATETIME, ro.pickup_time))) as order_prep_time 
  FROM 
    runner_orders as ro 
    INNER JOIN customer_orders AS co 
		ON ro.order_id = co.order_id 
  WHERE 
    ro.pickup_time IS NOT NULL
  GROUP BY 
    ro.order_id
) 
SELECT 
  number_of_pizzas, 
  AVG(order_prep_time) AS avg_order_prep_time 
FROM 
  pizza_CTE 
GROUP BY 
  number_of_pizzas;


-- 4. What was the average distance travelled for each customer?


-- 5. What was the difference between the longest and shortest delivery times for all orders?


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?


-- 7. What is the successful delivery percentage for each runner?
