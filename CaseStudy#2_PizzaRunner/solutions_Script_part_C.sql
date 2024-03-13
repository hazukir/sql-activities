/* C. Ingredient Optimisation */

-- 1. What are the standard ingredients for each pizza?

SELECT 
    CAST(t.topping_name AS VARCHAR(MAX)) AS topping_name,
    COUNT(DISTINCT p.pizza_id) AS pizza_count
FROM 
    [dbo].[pizza_recipes] AS p
CROSS APPLY
    STRING_SPLIT(CAST(p.toppings AS VARCHAR(MAX)), ',') AS s
LEFT JOIN [dbo].[pizza_toppings] AS t
    ON s.value = CAST(t.topping_id AS VARCHAR(MAX)) -- Ensure the join condition is on compatible data types
GROUP BY 
    CAST(t.topping_name AS VARCHAR(MAX));




-- 2. What was the most commonly added extra?

WITH Extras_CTE AS (
    SELECT
        value as extra_id
    FROM
        customer_orders
    CROSS APPLY STRING_SPLIT(COALESCE(extras,''), ',')
    WHERE
        extras IS NOT NULL AND extras != '' AND extras != 'null'
)

SELECT
    extra_id,
    COUNT(*) as extras_count
FROM
    Extras_CTE
GROUP BY
    extra_id
ORDER BY
    extras_count DESC;




-- 3. What was the most common exclusion?


WITH SplitExclusions AS (
    SELECT 
        co.order_id,
        value AS exclusion
    FROM 
        customer_orders AS co
        CROSS APPLY STRING_SPLIT(co.exclusions, ',') 
    WHERE 
        TRIM(value) <> '' AND 
        co.exclusions != 'null'
)
SELECT 
    CAST(T.topping_name AS VARCHAR(25)) AS topping_name, -- due to to the fact thet topping_name is text format, SQL Server 
	-- will not allow text to be presented
    COUNT(SE.order_id) AS exclusions
FROM 
    SplitExclusions AS SE
    INNER JOIN pizza_toppings AS T ON T.topping_id = SE.exclusion
GROUP BY 
    CAST(T.topping_name AS VARCHAR(25)) -- same reason as above
	/* Error: The text, ntext, and image data types cannot be compared or sorted, except when using IS NULL or LIKE operator.
 */
ORDER BY 
    exclusions DESC
OFFSET 0 ROWS FETCH FIRST 1 ROW ONLY;


/* 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

	Meat Lovers
	Meat Lovers - Exclude Beef
	Meat Lovers - Extra Bacon
	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

*/

/* 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
and add a 2x in front of any relevant ingredients

	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

*/




-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

