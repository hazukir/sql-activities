USE dannys_diner;


-- 1. What is the total amount each customer spent at the restaurant?

SELECT
	customer_id
   ,SUM(mu.price) totalSpentByCustomers
FROM sales AS s
INNER JOIN menu AS mu
	ON s.product_id = mu.product_id
GROUP BY customer_id;


--  2. How many days has each customer visited the restaurant?
SELECT
	customer_id
   ,COUNT(order_date) AS customerVisits
FROM sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT
	customer_id
	--,S.product_id
	--,M.product_name
	--,DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS denseRank
   ,FIRST_VALUE(M.product_name) OVER (PARTITION BY S.customer_id ORDER BY S.order_date) AS firstPurchasedItem
FROM sales AS S
INNER JOIN menu AS M
	ON S.product_id = M.product_id;


-- (bonus) most recent purchased item
SELECT
	customer_id
   --,order_date
   --,denseRank
   ,recentPurchasedItem
FROM (SELECT DISTINCT
		customer_id
	   ,order_date
	   ,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS denseRank
	   ,LAST_VALUE(M.product_name) OVER (PARTITION BY S.customer_id ORDER BY S.order_date DESC) AS recentPurchasedItem
	FROM sales AS S
	INNER JOIN menu AS M
		ON S.product_id = M.product_id) AS subquery
WHERE denseRank = 1;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH purchasedItems
AS
(SELECT -- Get the total for each product
		S.product_id
	   ,M.product_name
	   ,COUNT(S.order_date) AS totalPurchases
	FROM sales AS S
	LEFT JOIN menu AS M
		ON S.product_id = M.product_id
	GROUP BY S.product_id
			,M.product_name)
SELECT -- Get the Most purchased Item (max value) of all purchases
	UPPER(LEFT(product_name, 1)) + LOWER(SUBSTRING(product_name, 2, LEN(product_name))) AS product_name -- capitalize the first letter
   ,totalPurchases
FROM purchasedItems
WHERE totalPurchases = (SELECT
		MAX(totalPurchases)
	FROM purchasedItems);


-- 5. Which item was the most popular for each customer?


WITH purchasedItems AS (
    SELECT
        S.customer_id,
        M.product_name,
        COUNT(S.order_date) AS totalCount,
        ROW_NUMBER() OVER (PARTITION BY S.customer_id ORDER BY COUNT(S.order_date) DESC) AS rankOrders
    FROM sales AS S
    INNER JOIN menu AS M ON S.product_id = M.product_id
    GROUP BY S.customer_id, M.product_name
)
SELECT customer_id, product_name, totalCount
FROM purchasedItems
WHERE rankOrders = 1;



-- 6. Which item was purchased first by the customer after they became a member?

WITH firstPurchase AS (
	SELECT 
		S.customer_id
		,M.join_date
	   ,S.order_date
	   ,mn.product_name
	   ,FIRST_VALUE(mn.product_name) OVER(PARTITION BY S.customer_id ORDER BY S.order_date) AS firstPurchasedItem
	FROM sales AS S
	LEFT JOIN members AS M
		ON S.customer_id = M.customer_id
	LEFT JOIN menu AS mn 
	ON S.product_id = mn.product_id
	WHERE M.join_date < S.order_date
)
SELECT DISTINCT
	customer_id
	,firstPurchasedItem
FROM firstPurchase;


-- 7. Which item was purchased just before the customer became a member?


WITH purchasedItems AS (
    SELECT 
        S.customer_id,
        S.order_date,
        M.join_date,
        S.product_id,
        Menu.product_name,
        ROW_NUMBER() OVER (PARTITION BY S.customer_id ORDER BY S.order_date) AS ranking
    FROM sales AS S
    LEFT JOIN members AS M ON S.customer_id = M.customer_id
    LEFT JOIN menu AS Menu ON S.product_id = Menu.product_id
    WHERE S.order_date < M.join_date
)
SELECT 
    customer_id,
    order_date,
    join_date,
    product_id,
    product_name
FROM purchasedItems
WHERE ranking = 1;

