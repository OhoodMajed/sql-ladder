-- # Summarizing Data with SQL
-- 
-- ## Summary Statistics
-- 32) How many rows are in the `pets` table?
    SELECT COUNT(*)
	FROM pets;

-- 33) How many female pets are in the `pets` table?
    SELECT COUNT(*)
	FROM pets
	WHERE sex = 'F';

-- 34) How many female cats are in the `pets` table?
    SELECT COUNT(*)
	FROM pets 
	WHERE sex = 'F' AND species = 'cat';

-- 35) What's the mean age of pets in the `pets` table?
    SELECT AVG(age)
	FROM pets;

-- 36) What's the mean age of dogs in the `pets` table?
    SELECT AVG(age)
	FROM pets 
	WHERE species = 'dog';
	
-- 37) What's the mean age of male dogs in the `pets` table?
    SELECT AVG(age)
	FROM pets 
	WHERE species = 'dog' AND sex = 'M';

-- 38) What's the count, mean, minimum, and maximum of pet ages in the `pets` table?
--     * _NOTE:_ SQLite doesn't have built-in formulas for standard deviation or median!
    SELECT COUNT(age), AVG(age), MIN(age), MAX(age) 
	FROM pets;

-- 39) Repeat the previous problem with the following stipulations:
--     * Round the average to one decimal place.
--     * Give each column a human-readable column name (for example, "Average Age")
     SELECT 
    COUNT(age) AS [Total Count], 
    ROUND(AVG(age), 1) AS [Average Age], 
    MIN(age) AS [Minimum Age], 
    MAX(age) AS [Maximum Age] 
    FROM pets;

-- 40) How many rows in `employees_null` have missing salaries?
     SELECT COUNT(*) 
	 FROM employees_null 
	 WHERE salary IS NULL;

-- 41) How many salespeople in `employees_null` having _nonmissing_ salaries?
    SELECT COUNT(*) 
	FROM employees_null 
	WHERE job = 'Sales' AND salary IS NOT NULL;


-- 42) What's the mean salary of employees who joined the company after 2010? Go back to the usual `employees` table for this one.
--     * _Hint:_ You may need to use the `CAST()` function for this. To cast a string as a float, you can do `CAST(x AS REAL)`
	SELECT AVG(CAST(salary AS REAL)) 
    FROM employees 
    WHERE STRFTIME('%Y', startdate) > '2010';

-- 43) What's the mean salary of employees in Swiss Francs?
--   * _Hint:_ Swiss Francs are abbreviated "CHF" and 1 USD = 0.97 CHF.
	select avg(cast(salary as real)) * 0.97 
    from employees

	
-- 44) Create a query that computes the mean salary in USD as well as CHF. Give the columns human-readable names (for example "Mean Salary in USD"). Also, format them with comma delimiters and currency symbols.
--     * _NOTE:_ Comma-delimiting numbers is only available for integers in SQLite, so rounding (down) to the nearest dollar or franc will be done for us.
--     * _NOTE2:_ The symbols for francs is simply `Fr.` or `fr.`. So an example output will look like `100,000 Fr.`.
   
--My Note on CAST usage:
-- 1. CAST(salary AS REAL): Enforces floating-point precision during AVG() calculation to prevent truncation.
-- 2. CAST(... AS INTEGER): Converts the final output to an integer because SQLite's comma-delimited formatting (%,d) strictly requires an integer input.
	SELECT 
    PRINTF('$%,d', CAST(AVG(CAST(salary AS REAL)) AS INTEGER)) AS [Mean Salary in USD],
    PRINTF('%,d Fr.', CAST(AVG(CAST(salary AS REAL)) * 0.97 AS INTEGER)) AS [Mean Salary in CHF]
    FROM employees;


-- ## Aggregating Statistics with GROUP BY
-- 45) What is the average age of `pets` by species?
    SELECT AVG(age)
	FROM pets 
	GROUP BY species;

-- 46) Repeat the previous problem but make sure the species label is also displayed! Assume this behavior is always being asked of you any time you use `GROUP BY`.
    SELECT species, AVG(age) 
	FROM pets 
	GROUP BY species;

-- 47) What is the count, mean, minimum, and maximum age by species in `pets`?
    SELECT species, COUNT(*), AVG(age), MIN(age), MAX(age) 
    FROM pets 
    GROUP BY species;
	
-- 48) Show the mean salaries of each job title in `employees`.
     SELECT job, 
	 AVG(salary) -- we can also  avg(cast(salary as real))
     FROM employees 
     GROUP BY job;

-- 49) Show the mean salaries in New Zealand dollars of each job title in `employees`.
--     * _NOTE:_ 1 USD = 1.65 NZD.
    SELECT job, 
	AVG(salary * 1.65) AS avg_salary_nzd  -- also can avg(cast(salary as real)) * 1.65
    FROM employees 
    GROUP BY job;

-- 50) Show the mean, min, and max salaries of each job title in `employees`, as well as the numbers of employees in each category.
    SELECT job, AVG(salary), MIN(salary), MAX(salary), COUNT(*)  -- also can be  select job, avg(cast(salary as real)), min(cast(salary as real)), max(cast(salary as real))
    FROM employees 
    GROUP BY job;
  
-- 51) Show the mean salaries of each job title in `employees` sorted descending by salary.
     SELECT job, AVG(salary) AS avg_salary
     FROM employees 
     GROUP BY job 
     ORDER BY avg_salary DESC;

-- 52) What are the top 5 most common first names among `employees`?
     SELECT firstname, COUNT(*) AS name_count 
     FROM employees 
     GROUP BY firstname 
     ORDER BY name_count DESC 
     LIMIT 5;

-- 53) Show all first names which have exactly 2 occurrences in `employees`.
     SELECT firstname 
     FROM employees 
     GROUP BY firstname 
     HAVING COUNT(*) = 2;

-- 54) Take a look at the `transactions` table to get a idea of what it contains. 
--Note that a transaction may span multiple rows if different items are purchased as part of the same order. The employee who made the order is also given by their ID.
    SELECT * 
	FROM transactions
-- Observation: I notice that a single transaction (like order_id 0 or 1) spans multiple rows because each row represents a different item purchased in that same order, 
--with its own quantity and unit price. All these rows share the same customer, orderdate, and employee_id.


-- 55) Show the top 5 largest orders (and their respective customer) in terms of the numbers of items purchased in that order.
     SELECT order_id, customer, SUM(quantity) AS total_items
     FROM transactions
     GROUP BY order_id
     ORDER BY total_items DESC
     LIMIT 5;
	  
-- 56) Show the total cost of each transaction.
--     * _Hint:_ The `unit_price` column is the price of _one_ item. The customer may have purchased multiple.
--     * _Hint2:_ Note that transactions here span multiple rows if different items are purchased.
      SELECT order_id, SUM(quantity * unit_price) AS total_cost
      FROM transactions
      GROUP BY order_id;

-- 57) Show the top 5 transactions in terms of total cost.
      SELECT order_id, SUM(quantity * unit_price) AS total_cost
      FROM transactions
      GROUP BY order_id
      ORDER BY total_cost DESC
      LIMIT 5;

-- 58) Show the top 5 customers in terms of total revenue (ie, which customers have we done the most business with in terms of money?) 
SELECT customer, SUM(quantity * unit_price) AS total_revenue
FROM transactions
GROUP BY customer
ORDER BY total_revenue DESC
LIMIT 5;

-- 59) Show the top 5 employees in terms of revenue generated (ie, which employees made the most in sales?)
    SELECT employee_id, SUM(quantity * unit_price) AS total_sales
    FROM transactions
    GROUP BY employee_id
    ORDER BY total_sales DESC
    LIMIT 5;

-- 60) Which customer worked with the largest number of employees?
--     * _Hint:_ This is a tough one! Check out the `DISTINCT` keyword.
SELECT customer, COUNT(DISTINCT employee_id) AS unique_employees
FROM transactions
GROUP BY customer
ORDER BY unique_employees DESC
LIMIT 1;

-- 61) Show all customers who've done more than $80,000 worth of business with us.
SELECT customer, SUM(quantity * unit_price) AS total_business
FROM transactions
GROUP BY customer
HAVING total_business > 80000;