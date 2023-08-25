-- Telecom Data Case Study

SELECT * FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis` LIMIT 10;

SELECT customer_id, age, gender
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
Where age > 25 and Gender = 'Female'
limit 5;

SELECT * FROM  `serious-sql-394805.Churn_Analysis123.telecom_data_dictionary` 
;

SELECT * FROM  `serious-sql-394805.Churn_Analysis123.telecom_zip_population` 
LIMIT 10;

SELECT * FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis` LIMIT 100;

--Data Cleaning and Preparation

--Check for duplicates

SELECT Customer_ID, Count(Customer_ID) as count
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
GROUP BY Customer_ID
HAVING COUNT(Customer_ID) >1 ;

--Hence, there are No Duplicates

--Total Customers

SELECT COUNT(DISTINCT Customer_ID) as customer_count
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`;

--Exploratory Data Analysis

-- How much revenue did Company lose to churned customers?

SELECT Customer_Status,
COUNT(Customer_ID) AS Customer_Count,
ROUND(SUM(Total_Revenue)*100/SUM(SUM(Total_Revenue))OVER(),1) AS Revenue_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
GROUP BY Customer_Status;

-- Typical tenure for churners

SELECT 
  CASE
      WHEN Tenure_in_Months <= 6 THEN '6 Months'
      WHEN Tenure_in_Months <= 12 THEN '1 Year'
      WHEN Tenure_in_Months <= 24 THEN '2 Years'
      WHEN Tenure_in_Months > 24 THEN '> 2 Years'
      END AS Tenure,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY Tenure
ORDER BY Churn_Percentage DESC;
  
-- Which cities have the highest churn rates?

SELECT 
  City,
  COUNT(Customer_ID) AS Churned,
 CEIL(COUNT(
    CASE
      WHEN Customer_Status ='Churned' THEN Customer_ID 
      ELSE NULL 
      END
  )*100
  /
  COUNT(Customer_ID)
  ) AS Churn_Rate
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
GROUP BY City
HAVING Churned > 30
AND
Churn_Rate >0 
ORDER BY Churn_Rate DESC
LIMIT 5;

--
