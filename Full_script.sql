/* Creating the database named as sql_capstone */
create database sql_capstone;

/* Using that database */
use sql_capstone;

-- We have amazon data, I'm creating a table and will import the data from csv file
CREATE TABLE amazon_data (
    invoice_id VARCHAR(30),
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(10),
    product_line VARCHAR(100),
    unit_price DECIMAL(10 , 2 ),
    quantity INT,
    VAT FLOAT(6 , 4 ),
    total DECIMAL(10 , 2 ),
    Date DATE,
    Time TIME,
    payment_method VARCHAR(30),
    cogs DECIMAL(10 , 2 ),
    gross_margin_percentage FLOAT(11 , 9 ),
    gross_income DECIMAL(10 , 2 ),
    rating DECIMAL(3 , 1 )
);

/* Here in creating the table challenge i faced is due to datatypes my table is not accepting some rows, 
 so the row count was not macthing with the CSV file. Now it's corrected */
 
 -- Checking the data
 SELECT 
    *
FROM
    amazon_data;
 
 -- Checking is null value is there in 
SELECT 
    *
FROM
    amazon_data
WHERE
    invoice_id IS NULL;

-- Add column timeOfDay 
ALTER TABLE amazon_data ADD COLUMN timeOfDay VARCHAR(20); 

-- This will make us update all the row without where clause
SET SQL_SAFE_UPDATES = 0;

-- This will populate the timeOfDay column based on Time column
UPDATE amazon_data 
SET 
    timeOfDay = CASE
        WHEN
            HOUR(Time) BETWEEN 6 AND 11
                OR (HOUR(Time) = 12 AND MINUTE(Time) = 0)
        THEN
            'Day'
        WHEN
            HOUR(Time) BETWEEN 12 AND 17
                OR (HOUR(Time) = 11 AND MINUTE(Time) > 0)
        THEN
            'Afternoon'
        ELSE 'Evening'
    END;

-- Now we are aading day of week column 
ALTER TABLE amazon_data ADD COLUMN DayName VARCHAR(20); 

-- Updating the values in DayName column
UPDATE amazon_data 
SET 
    DayName = DAYNAME(Date);

-- Adding month name column
ALTER TABLE amazon_data ADD COLUMN Month_Name VARCHAR(20); 

-- Updating month name column 
UPDATE amazon_data 
SET 
    Month_Name = MONTHNAME(Date);

-- select Month_Name from amazon_data;
-- -- select Time, timeOfDay from amazon_data;

-- Q1 - What is the count of distinct cities in the dataset?
SELECT 
    COUNT(DISTINCT (city)) AS city_count
FROM
    amazon_data;		-- We have only 3 distinct cities 

-- Q2 - For each branch, what is the corresponding city?
SELECT DISTINCT
    branch, city
FROM
    amazon_data;

-- Q3 - What is the count of distinct product lines in the dataset?
SELECT 
    COUNT(DISTINCT (product_line)) AS product_line_count
FROM
    amazon_data;

-- Q4 - Which payment method occurs most frequently?
SELECT 
    payment_method,
    COUNT(payment_method) AS payment_method_count
FROM
    amazon_data
GROUP BY payment_method
ORDER BY payment_method_count DESC;

-- Q5 - Which product line has the highest sales?		
SELECT 
    product_line, SUM(total) AS total_sales
FROM
    amazon_data
GROUP BY product_line
ORDER BY total_sales DESC;

-- Q6 - How much revenue is generated each month?
SELECT 
    Month_Name, SUM(unit_price * quantity) AS total_revenue
FROM
    amazon_data
GROUP BY Month_Name
ORDER BY total_revenue;

-- Q7 - In which month did the cost of goods sold reach its peak?
SELECT 
    Month_Name, SUM(cogs) AS cogs_sum
FROM
    amazon_data
GROUP BY Month_Name
ORDER BY cogs_sum DESC;

-- Q8 - Which product line generated the highest revenue?
SELECT 
    product_line, SUM(unit_price * quantity) AS total_revenue
FROM
    amazon_data
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- Q9 - In which city was the highest revenue recorded?
SELECT 
    city, SUM(unit_price * quantity) AS total_revenue
FROM
    amazon_data
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- Q10 - Which product line incurred the highest Value Added Tax?
SELECT 
    product_line, ROUND(SUM(VAT), 2) AS sum_vat
FROM
    amazon_data
GROUP BY product_line
ORDER BY sum_vat DESC;

-- Q11 - For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT 
    product_line,
    total,
    CASE
        WHEN total >= 500 THEN 'Good'
        WHEN total < 200 THEN 'Bad'
        ELSE 'Average'
    END AS sales_desc
FROM
    amazon_data;
    
-- Q12 - Identify the branch that exceeded the average number of products sold.
SELECT 
    branch, AVG(quantity) AS avg_quantity
FROM
    amazon_data
GROUP BY branch
HAVING avg_quantity > (SELECT 
        AVG(quantity)
    FROM
        amazon_data);
  
-- Q14 - Calculate the average rating for each product line.
SELECT 
    product_line, AVG(rating) AS avg_rating
FROM
    amazon_data
GROUP BY product_line;

-- Q15 - Count the sales occurrences for each time of day on every weekday.
SELECT 
    DayName, COUNT(total) AS total_sale_count
FROM
    amazon_data
GROUP BY DayName;

-- Q16 - Identify the customer type contributing the highest revenue.
SELECT 
    customer_type, SUM(unit_price * quantity) AS sum
FROM
    amazon_data
GROUP BY customer_type
ORDER BY sum DESC
LIMIT 1;

-- Q17 - Determine the city with the highest VAT percentage.
SELECT 
    city, ROUND(SUM(VAT), 2) AS vat_sum
FROM
    amazon_data
GROUP BY city
ORDER BY vat_sum DESC
LIMIT 1;

-- Q18 - Identify the customer type with the highest VAT payments.
-- Q19 - What is the count of distinct customer types in the dataset?
SELECT 
    COUNT(DISTINCT (customer_type)) AS number_of_customers
FROM
    amazon_data;

-- Q20 - What is the count of distinct payment methods in the dataset?
SELECT 
    COUNT(DISTINCT (payment_method)) AS number_of_payment_method
FROM
    amazon_data;
    
-- Q21 - Which customer type occurs most frequently?
SELECT 
    customer_type, COUNT(customer_type) AS customer_count
FROM
    amazon_data
GROUP BY customer_type
ORDER BY customer_count DESC
LIMIT 1;

-- Q22 - Identify the customer type with the highest purchase frequency.
SELECT 
    customer_type, SUM(quantity) AS quantity_count
FROM
    amazon_data
GROUP BY customer_type
ORDER BY quantity_count DESC
LIMIT 1;

-- Q23 - Determine the predominant gender among customers.
SELECT 
    gender, COUNT(gender)
FROM
    amazon_data
GROUP BY gender;

-- Q24 - Examine the distribution of genders within each branch.
SELECT 
    branch, COUNT(gender) AS gender_count
FROM
    amazon_data
GROUP BY branch;

-- Q25 - Identify the time of day when customers provide the most ratings.
SELECT 
    timeOfDay, COUNT(rating) AS rating_count
FROM
    amazon_data
GROUP BY timeOfDay
ORDER BY rating_count DESC
LIMIT 1;

-- Q26 - Determine the time of day with the highest customer ratings for each branch.

SELECT timeOfDay, branch, rating_sum FROM (SELECT 
    timeOfDay, branch, SUM(rating) as rating_sum, row_number() over(partition by branch order by SUM(rating) desc) as rating_num
FROM
    amazon_data
GROUP BY timeOfDay , branch
ORDER BY branch , timeOfDay) as sec_table where rating_num = 1;

-- Q27 - Identify the day of the week with the highest average ratings.
SELECT 
    DayName, AVG(rating) AS avg_rating
FROM
    amazon_data
GROUP BY DayName
ORDER BY avg_rating DESC
LIMIT 1;

-- Q28 - Determine the day of the week with the highest average ratings for each branch.

SELECT DayName, branch, max_avg_rating FROM (SELECT 
    DayName, branch, MAX(avg_rating) as max_avg_rating, row_number() over (partition by branch order by avg_rating desc) as row_
FROM
    (SELECT 
        DayName, branch, AVG(rating) AS avg_rating
    FROM
        amazon_data
    GROUP BY branch , DayName
    ORDER BY branch , avg_rating DESC) AS sec_table
GROUP BY branch, DayName) as third_table where row_ = 1;