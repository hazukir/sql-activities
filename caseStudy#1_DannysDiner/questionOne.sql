-- https://8weeksqlchallenge.com/case-study-1/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id,
	SUM(mu.price) totalSpentByCustomers
FROM sales AS s
INNER JOIN menu AS mu
ON S.product_id = mu.product_id
GROUP BY customer_id


SELECT * FROM sales

SELECT * FROM menu

SELECT * FROM members