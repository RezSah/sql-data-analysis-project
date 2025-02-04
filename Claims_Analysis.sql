use maven_advanced_sql;
select * from claims;
# 1.What is the average claim amount by age group?
SELECT 
	age, 
	Round(AVG(claim),2) as average_claim
FROM claims 
GROUP BY age
ORDER BY age ASC
;

# 2.How do smoking and diabetes affect claim amounts?
SELECT
	claim,
    smoker,
    diabetic,
    ROUND(AVG(claim) OVER(PARTITION BY smoker),2) AS avg_claim_smoker,
    ROUND(AVG(claim) OVER(PARTITION BY diabetic),2) AS avg_claim_diabetics
FROM claims; 


# 3. What is the average claim amount by region?
SELECT
	ROUND(AVG(claim),2) AS avg_claims_region,
    region
FROM claims
GROUP BY region;


# 4. How does BMI range affect the number, average, and total insurance claims?
WITH cte AS(SELECT
	*,
CASE 
	WHEN bmi < 18.5 THEN 'Underweight'
    WHEN bmi >= 18.5 AND bmi <= 24.9 THEN 'Normal Weight'
    WHEN bmi >= 25.0 AND bmi <= 29.9 THEN 'Overweight'
    WHEN bmi >= 30.0 AND bmi <= 34.9 THEN 'Obese (Class 1)'
    WHEN bmi >= 35.0 AND bmi <= 39.9 THEN 'Obese (Class 2)'
    WHEN bmi >= 40.0 THEN 'Obese (Class 3)'
    END AS 'bmi_range'
FROM claims)
SELECT 
	bmi_range,
    COUNT(claim) number_claim,
    ROUND(AVG(claim),2) AS avg_claim,
    ROUND(SUM(claim),2) AS total_claim
FROM cte 
GROUP BY bmi_range 
ORDER BY total_claim DESC;


# 5. Which gender has a higher average claim amount?
SELECT 
	ROUND(AVG(claim),2) AS avg_claim,
    gender
FROM claims
GROUP BY gender
ORDER BY avg_claim DESC ;

# 6. How does the number of children affect the total and average claim amounts?
SELECT
    children,
    ROUND(AVG(claim),2) AS avg_claim,
    ROUND(SUM(claim),2) AS total_claim,
    COUNT(claim) AS number_of_claim
FROM claims
GROUP BY children
ORDER BY total_claim DESC;

# 7. For each region, what are the top 3 claims by amount?

WITH cte AS(
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY region ORDER BY claim DESC) AS rank_claim_per_region
	FROM claims)
SELECT PatientID, 
	   age,
       region,
       claim
FROM cte
WHERE rank_claim_per_region <= 3;

# 8. Identify the top 5% of claims (outliers) based on claim amounts split by gender. What is the total claim amount from these outliers?

WITH cte AS(
			SELECT *,
					NTILE(100) OVER(PARTITION BY gender ORDER BY claim DESC) AS Percentile
                    FROM claims
                    )
SELECT 
	gender,
    ROUND(SUM(claim),2) total_claims_outliers
    
FROM
cte
WHERE Percentile <= 5
GROUP BY gender;

# 9. Identify the top 5% of claims (outliers) based on claim amounts split by region. What is the total claim amount from these outliers?      

WITH cte AS(
			SELECT *,
					NTILE(100) OVER(PARTITION BY region ORDER BY claim DESC) AS Percentile
                    FROM claims
                    )
SELECT 
	region,
    ROUND(SUM(claim),2) total_claims_outliers
    
FROM
cte
WHERE Percentile <= 5
GROUP BY region;

# 10. How do claim amounts and claim frequencies vary across different age categories (e.g., Young Adult, Adult, Middle-Aged, Older Adult, Senior)?
WITH cte AS(SELECT 
	*,
CASE
	WHEN age >= 18 AND age <= 24 THEN 'Young Adult'
    WHEN age >= 25 AND age <= 35 THEN 'Adult'
    WHEN age >= 36 AND age <= 44 THEN 'Middle_Aged'
    WHEN age >= 45 AND age <= 55 THEN 'Older Adult'
    WHEN age >= 56 AND age <= 60 THEN 'Senior'
END AS 'age_category'
FROM claims)
SELECT
	ROUND(SUM(claim),2) AS total_claim,
    ROUND(COUNT(claim),2) AS number_of_claims,
    age_category
FROM cte
GROUP BY age_category
ORDER BY total_claim DESC