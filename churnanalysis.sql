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

-- Why did customers leave?

SELECT 
  Churn_Category,
  ROUND(SUM(Total_Revenue),0) AS Churned_Revenue,
  CEIL(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER()) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY Churn_Category
ORDER BY Churn_Percentage DESC;

--Specific Reasons For Churn
-- why exactly did customers churn?

SELECT 
  Churn_Reason,
  Churn_Category,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY 
Churn_Reason,Churn_Category
ORDER BY Churn_Percentage DESC
LIMIT 7;

-- What offers did churners have?

SELECT 
  Offer,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY Offer
ORDER BY Churn_Percentage DESC;

-- What Internet Type did churners have?
SELECT 
  Internet_Type,
  Count(Customer_ID) AS Churned,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY Internet_Type
ORDER BY Churn_Percentage DESC;

-- What Internet Type did 'Competitor' churners have?
SELECT 
  Internet_Type,
  Count(Customer_ID) AS Churned,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned' AND Churn_Category = 'Competitor'
GROUP BY Internet_Type
ORDER BY Churn_Percentage DESC;

-- Did churners have premium tech support?

SELECT 
  Premium_Tech_Support,
  Count(Customer_ID) AS Churned,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY   Premium_Tech_Support
ORDER BY Churned DESC;

-- What contract were churners on?

SELECT 
  Contract,
  Count(Customer_ID) AS Churned,
  ROUND(COUNT(Customer_ID)*100/SUM (COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE Customer_Status = 'Churned'
GROUP BY Contract
ORDER BY Churned DESC;


---6. Are high value customers at risk of churning?

SELECT 
  CASE
    WHEN (num_conditions >= 3) THEN 'High_Risk'
    WHEN (num_conditions = 2) THEN 'Medium_Risk'
    ELSE 'Low_Risk'
    END AS Risk_Levels,
    COUNT(Customer_ID) AS Num_Customers,
    ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER (),1) AS Cust_Percentage,
    num_conditions
FROM 
(
  SELECT
    Customer_ID,
    SUM(CASE WHEN Offer ='Offer E' OR Offer = 'None' THEN 1 ELSE 0 END)+
    SUM(CASE WHEN Contract = 'Month-to-Month' THEN 1 ELSE 0 END)+
    SUM(CASE WHEN Premium_Tech_Support = false THEN 1 ELSE 0 END)+
    SUM(CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END)
    AS num_conditions
  FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
  WHERE
    Tenure_in_Months > 6 
    AND Monthly_Charge > 70.05
    AND Number_of_Referrals > 0
    AND Customer_Status = 'Stayed'
  GROUP BY Customer_ID
  HAVING num_conditions >=1
) AS subquery
GROUP BY
  Risk_Levels,
  num_conditions
;

--Churn Demographics

-- HOW old were churners?

SELECT 
  CASE
       WHEN Age <= 30 THEN '19-30 Years'
       WHEN Age <= 40 THEN '31-40 Years'
       WHEN Age <= 50 THEN '41-50 Years'
       WHEN Age <= 60 THEN '51-60 Years'
  ELSE '>60 Years'
  END AS Age,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Age
ORDER BY Churn_Percentage DESC;

-- What gender were churners?

SELECT 
  Gender,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Gender
ORDER BY Churn_Percentage DESC; 

-- Did churners have dependents

SELECT 
  CASE
  WHEN Number_of_Dependents> 0 THEn 'Has Dependents'
  ELSE 'No Dependents'
  END AS dependents,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY dependents
ORDER BY Churn_Percentage DESC; 

-- Were churners married

SELECT 
    Married,
    ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Married
ORDER BY Churn_Percentage DESC;

-- Do churners have phone lines
SELECT 
  Phone_Service,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Phone_Service
ORDER BY Churn_Percentage DESC;

-- Do churners have internet service

SELECT 
  Internet_Service,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Internet_Service
ORDER BY Churn_Percentage DESC;

-- Did they give referrals

SELECT 
  CASE WHEN Number_of_Referrals >0 THEN 'Yes'
  ELSE 'No'
  END AS Referrals,
  ROUND(COUNT(Customer_ID)*100/SUM(COUNT(Customer_ID))OVER(),1) AS Churn_Percentage
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
WHERE 
  Customer_Status = 'Churned'
GROUP BY Referrals
ORDER BY Churn_Percentage DESC;

-- Preparing Dashboard

SELECT 
 COUNT(Customer_ID) AS Churned,
 ROUND(COUNT(
    CASE 
      WHEN Customer_Status ='Churned' THEN Customer_ID ELSE NULL END ) * 100/ Count(Customer_ID),1) AS Churn_Rate,
 ROUND(SUM(Total_Revenue)/COUNT(Customer_ID),1) AS ARPU,
 ROUND(SUM(Tenure_in_Months)/COUNT(Customer_ID),1) AS AVG_Tenure_in_Months
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis` 
;


