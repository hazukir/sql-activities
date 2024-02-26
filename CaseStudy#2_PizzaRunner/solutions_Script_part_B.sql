/*
B. Runner and Customer Experience

What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Is there any relationship between the number of pizzas and how long the order takes to prepare?
What was the average distance travelled for each customer?
What was the difference between the longest and shortest delivery times for all orders?
What was the average speed for each runner for each delivery and do you notice any trend for these values?
What is the successful delivery percentage for each runner?
*/

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

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


