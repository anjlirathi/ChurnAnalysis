-- Telecom Data Case Study

SELECT * FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis` LIMIT 10;

SELECT customer_id, age, gender
FROM `serious-sql-394805.Churn_Analysis123.Telecom_Churn_Analysis`
Where age > 25 and Gender = 'Female'
limit 5;
