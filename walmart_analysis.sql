SELECT *
FROM walmart;

-- BUSINESS PROBLEM
-- Q.1 : Find different payment method and number of transactions, number to qty sold

SELECT
	payment_method,
    COUNT(*) AS No_payments,
    SUM(quantity) AS No_qty_sold
FROM walmart
GROUP BY payment_method
ORDER BY No_payments;

-- Q.2 : Identify the highest-rated category in each branch, displaying branch, category and average rating

SELECT *
FROM
(
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking 
	FROM walmart
	GROUP BY branch, category
) AS ranked_category
WHERE ranking = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
(
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM walmart
    GROUP BY
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y'))
) ranked_days
WHERE ranking = 1;

-- Q.4 : Calculate the total quantity of items sold per payments method. LIst the payment_method and total_quantity.

SELECT
	payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.5 : Determine the average, minimum and maximum rating of products for each city. List the city, average_rating, min_rating and max_rating.

SELECT
    city,
    category,
    MIN(rating) AS Minimum,
    MAX(rating) AS Maximum,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q.6 : Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
    SUM(total_price) AS total_revenue,
    SUM(total_price * profit_margin) AS profit
FROM walmart
GROUP BY category

-- Q.7 : Determine the most common payment method for each Branch. Display Branch  and the the preferred_payments_method.

WITH cte AS
(SELECT
	branch,
    payment_method,
    COUNT(*) AS total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
FROM walmart
GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE ranking = 1

-- Q.8 : Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Find out which of the shift and number of invoices.

SELECT
    branch,
    CASE
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, total_transactions DESC;

-- Q.9 : Identify 5 branch with highest decrese ratio in revenue compare to last year (current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;