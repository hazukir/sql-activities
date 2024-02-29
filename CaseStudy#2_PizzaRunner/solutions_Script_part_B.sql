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
WITH extraction AS (
  SELECT 
  co.customer_id AS customer_id, 
    distance,
    CASE 
        WHEN distance = 'null' THEN NULL -- Handle 'null' string
        ELSE 
            TRY_CAST(SUBSTRING(distance, PATINDEX('%[0-9.-]%', distance),
                   CASE WHEN PATINDEX('%[^0-9.-]%', SUBSTRING(distance, PATINDEX('%[0-9.-]%', distance), LEN(distance) + 1)) = 0 THEN LEN(distance) + 1
                        ELSE PATINDEX('%[^0-9.-]%', SUBSTRING(distance, PATINDEX('%[0-9.-]%', distance), LEN(distance) + 1)) - 1 END) AS DECIMAL(10,2)) -- Extract numbers with decimal points
    END AS extracted_number
FROM customer_orders AS co
INNER JOIN runner_orders AS ro 
  ON co.order_id = ro.order_id
)
SELECT 
  customer_id,
  CAST(
    AVG(extracted_number)
    AS DECIMAL(5, 2)) AS avg_distance_travelled
FROM extraction
GROUP BY customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?


-- 7. What is the successful delivery percentage for each runner?
