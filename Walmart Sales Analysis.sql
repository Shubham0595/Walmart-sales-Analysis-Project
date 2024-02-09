CREATE DATABASE IF NOT EXISTS walmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,sales
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(30) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9) NOT NULL,
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1) NOT NULL
);

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------- FEATURE ENGINEERING --------------------------------------------------

-- Add the time_of_day column 

SELECT time, 
			(CASE
				WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
				WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon" 
				ELSE "Evening" 
			END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales SET time_of_day = (CASE
				WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
				WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon" 
				ELSE "Evening" 
			END);

-- Add day_name column

SELECT date, DAYNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales SET day_name = DAYNAME(date);

-- Add month_name column

SELECT date, MONTHNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------------------------------------------------
-- --------------------------------------- GENERIC ------------------------------------------------------

-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

-- ------------------------------------------------------------------------------------------------------
-- --------------------------------------- PRODUCT ------------------------------------------------------

-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) FROM sales;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS cnt FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the most common payment method?
SELECT payment, COUNT(payment) AS cnt FROM sales
GROUP BY payment
ORDER BY cnt DESC;

-- What is the total revenue by month
SELECT month_name AS month, SUM(total) AS total_revenue FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) AS largestcogs FROM sales
GROUP BY month
ORDER BY largestcogs DESC;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) AS largest_revenue FROM sales
GROUP BY product_line
ORDER BY largest_revenue DESC;

-- What is the city with the largest revenue?
SELECT city, SUM(total) AS largest_revenue FROM sales
GROUP BY city
ORDER BY largest_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, ROUND(AVG(tax_pct),2) AS avg_tax FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qty FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT product_line, gender, COUNT(gender) AS total_gender FROM sales
GROUP BY product_line, gender
ORDER BY total_gender DESC;

-- What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) AS average_rating FROM sales
GROUP BY product_line
ORDER BY average_rating;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line, CASE WHEN AVG(quantity)> 6 THEN "Good" ELSE "Bad" END AS remark
FROM sales
GROUP BY product_line;


-- ------------------------------------------------------------------------------------------------------
-- --------------------------------------- SALES ----------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT time_of_day, COUNT(*) AS total_sales FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are filled during the evening hours.alter

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax/VAT percent?
SELECT city, ROUND(AVG(tax_pct),2) AS largest_VAT FROM sales
GROUP BY city
ORDER BY largest_VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(tax_pct) AS total_max FROM sales
GROUP BY customer_type
ORDER BY total_max DESC;

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------ CUSTOMERS -------------------------------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(*) AS count FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT gender, COUNT(*) AS cust_gen FROM sales
GROUP BY gender
ORDER BY cust_gen DESC;

-- What is the gender distribution per branch?
SELECT gender, branch, COUNT(*) AS gender_cnt FROM sales
GROUP BY gender, branch
ORDER BY branch,gender_cnt;  

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS rating_avg FROM sales
GROUP BY time_of_day
ORDER BY rating_avg DESC; 

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, branch, AVG(rating) AS rating_avg FROM sales
WHERE branch = "B"
GROUP BY time_of_day
ORDER BY rating_avg; 

-- Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- How many sales are made on these days?
SELECT day_name, SUM(quantity) AS total_sales FROM sales
WHERE day_name = "Monday";

SELECT day_name, SUM(quantity) AS total_sales FROM sales
WHERE day_name = "Tuesday";

SELECT day_name, SUM(quantity) AS total_sales FROM sales
WHERE day_name = "Friday";

-- Which day of the week has the best average ratings per branch?
SELECT day_name,AVG(rating) AS avg_rating FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_rating DESC;
