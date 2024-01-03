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

