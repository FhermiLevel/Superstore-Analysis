SELECT * FROM superstore.superstore;

SELECT COUNT(*) AS col
FROM information_schema.columns WHERE TABLE_NAME = 'superstore';

SELECT COUNT(*) AS col
FROM superstore;

-- Total Sales Revenue
SELECT FORMAT(SUM(sales),0) AS Total_Revenue
FROM superstore;


--  Total revenue generated from sales by Years.
SELECT DISTINCT YEAR(Order_date) AS O_year,FORMAT(SUM(sales),2) AS sales
FROM superstore
GROUP BY O_year
ORDER BY O_year;

-- 1) Total revenue generated from sales
SELECT ROUND(SUM(sales),0) AS Total_revenue
fROM superstore; -- '2297201'

SELECT * FROM superstore;

-- 2) Percentage change in revenue over time?
SELECT YEAR(order_Date) AS Years,
MONTH(order_Date) AS Months, 
Sales,
LAG(Sales) OVER (ORDER BY Order_Date) AS previous_year,
((sales - LAG(Sales) OVER(ORDER BY order_Date)) / LAG(Sales) OVER (ORDER BY order_Date)) * 100 AS mom_percent
FROM superstore
ORDER BY order_Date;

-- 2) Percentage change in revenue over the Month?
SELECT DISTINCT MONTH(order_date) AS Months, 
ROUND(SUM(Sales),0) AS sales_amount,
LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY MONTH(order_date)) AS previous_months,
ROUND(((SUM(Sales) - LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY MONTH(order_date))) / 
LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY MONTH(order_date))) * 100,0) AS mom_percent
FROM superstore
GROUP BY months
ORDER BY months;

-- 2) Percentage change in revenue over the Year?
SELECT DISTINCT YEAR(order_date) AS Years, 
ROUND(SUM(Sales),0) AS sales_amount,
LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY Year(order_date)) AS previous_year,
ROUND(((SUM(Sales) - LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY Year(order_date))) / 
LAG(ROUND(SUM(Sales),0)) OVER (ORDER BY Year(order_date))) * 100,0) AS mom_percent
FROM superstore
GROUP BY Years
ORDER BY Years;

SELECT * FROM superstore;

-- 3) Average revenue per order
SELECT ROUND(AVG(Sales),2) AS avg_order_value
FROM superstore;
-- 3b) Average revenue per order by year
SELECT YEAR(Order_Date) AS Years,ROUND(AVG(Sales),2) AS avg_order_value
FROM superstore
GROUP BY YEAR(Order_Date)
ORDER BY years;

SELECT * FROM superstore;

-- 4)Products with the highest sales volume
SELECT Product_ID,ROUND(SUM(Sales),2) AS Sales_per_product,category,sub_category
FROM superstore
GROUP BY 1,3,4
ORDER BY 2 DESC
Limit 10;

-- 5)Sales by product category
SELECT category,ROUND(SUM(Sales),0) AS Sales_per_category
FROM superstore
-- WHERE Order_Date LIKE '2014%'
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM superstore;
-- 6)Sales by product Sub_category
SELECT sub_category,ROUND(SUM(Sales),0) AS Sales_per_sub_category
FROM superstore
GROUP BY 1
ORDER BY 2 DESC;

ALTER TABLE superstore
RENAME COLUMN `Order _ID` TO Order_ID;

SELECT * FROM superstore;

-- 7)Number of new customers acquired over time.
SELECT YEAR(order_date) AS Years,COUNT(DISTINCT Customer_Name) AS N_customers
FROM superstore
GROUP BY 1;

SELECT YEAR(order_date) AS years,MONTH(Order_Date) AS months,COUNT(DISTINCT fo.customer_ID) AS new_comers
FROM
(SELECT Customer_ID,MIN(Order_Date) AS first_day
FROM superstore
GROUP BY Customer_ID) fo
JOIN superstore s ON s.order_date = fo.first_day AND s.Customer_ID = fo.Customer_ID
GROUP BY YEAR(order_date),MONTH(Order_Date)
ORDER BY years,months;

SELECT * FROM superstore;


SELECT 
  YEAR(Order_Date) AS Year, 
  MONTH(Order_Date) AS Month, 
  COUNT(DISTINCT First_Orders.Customer_ID) AS New_Customers
FROM 
  (
    SELECT 
      DISTINCT Customer_ID, 
      MIN(Order_Date) AS First_Order_Date
    FROM 
      superstore
    GROUP BY 
      Customer_ID
  ) AS First_Orders
JOIN 
  superstore ON First_Orders.Customer_ID = superstore.Customer_ID 
  AND First_Orders.First_Order_Date = superstore.Order_Date
GROUP BY 
  YEAR(Order_Date), 
  MONTH(Order_Date)
ORDER BY 
  Year, 
  Month;
  
  
 SELECT years, SUM(new_comers) AS New_comers
 FROM
  (SELECT YEAR(Order_Date) AS years,MONTH(Order_Date) AS months,
  COUNT(DISTINCT fo.Customer_ID) AS New_comers
  FROM
  (
     SELECT Customer_ID, MIN(order_date) AS First_day
  FROM superstore
  GROUP BY Customer_ID  ) AS fo
JOIN superstore s ON fo.customer_ID = s.Customer_ID
  AND fo.First_day = s.Order_Date
  GROUP BY Years, months
  ORDER BY years) AS dos
  GROUP BY years;
  
  
  
  
  SELECT YEAR(Order_Date) AS years,MONTH(Order_Date) AS months,
  COUNT(DISTINCT fo.Customer_ID) AS New_comers
  FROM
  (
     SELECT Customer_ID, MIN(order_date) AS First_day
  FROM superstore
  GROUP BY Customer_ID  ) AS fo
JOIN superstore s ON fo.customer_ID = s.Customer_ID
  AND fo.First_day = s.Order_Date
  GROUP BY Years, months
  ORDER BY years;
  
  SELECT * FROM superstore;
  
  select COUNT(*)
  from superstore
  where Customer_Name = 'Claire Gute';
  
-- 8)Percentage of customers who place repeat orders.
SELECT Customer_name,Order_ID,COUNT(customer_ID) AS numb
FROM superstore
-- where Customer_Name = 'Claire Gute'
GROUP BY Customer_name,Order_ID
;
SELECT
(SELECT COUNT(numb) AS customer_with_repeated_orders
FROM
(SELECT Customer_Name,Customer_ID,COUNT(customer_ID) AS numb
FROM superstore
-- where Customer_Name = 'Brosina Hoffman'
GROUP BY Customer_ID,Customer_Name
ORDER BY numb DESC) D1
WHERE numb != 1) AS customer_with_repeated_orders, COUNT(DISTINCT customer_ID) AS Total_customers
-- ((Numb/Total_customers)* 100) AS c_perc
FROM superstore;

WITH First_order AS
(SELECT customer_ID, MIN(order_ID) AS First_order_date
FROM superstore
GROUP BY customer_ID),

Repeat_customers AS 
(SELECT o.Customer_ID
FROM superstore o
JOIN First_order fo ON o.Customer_ID = fo.Customer_ID
WHERE o.Order_Date > fo.First_order_date)

SELECT COUNT(DISTINCT rc.Customer_ID) / COUNT(DISTINCT fo.Customer_ID) * 100  AS customer_Retention_Rate
FROM Repeat_customers rc
RIGHT JOIN First_order fo ON rc.Customer_ID = fo.Customer_ID;

SELECT 
  COUNT(DISTINCT o1.Customer_ID) / 
  (SELECT COUNT(DISTINCT Customer_ID) FROM   superstore) * 100 AS customer_retention_rate
FROM 
  superstore o1
WHERE 
  o1.Customer_ID IN (
    SELECT o2.Customer_ID
    FROM superstore o2
    GROUP BY o2.Customer_ID
    HAVING COUNT(o2.Order_ID) > 1
  );
  
  -- Set global variables
SET GLOBAL net_read_timeout = 3600;
SET GLOBAL net_write_timeout = 3600;

-- Set session variables
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

# Thanks for Checking



  



