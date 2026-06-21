--# Joins
-- This file contains several exercises on joins. These topics are a step more involved and confusing than in the previous two files.
-- * [Tutorial on Joins](https://www.sqlitetutorial.net/sqlite-join/)
-- Here are a few other important notes I'd like you read before beginning:
-- * Make sure you read each question thoroughly.
-- * Don't skip problems, as some problems may rely on previous problems being done correctly.
-- * Make sure you are saving your answers as you go, as some answers will simply be reworkings of previous answers.
-- * A View is a virtual table that represents the result of a stored SELECT query. Unlike a physical table, it does not store data, but it can be queried like a table.
-- 
-- ## Joins
-- 
-- 62) Which employee made which sale? Join the `employees` table onto the `transactions` table by `employee_id`. You only need to include the employee's first/last name from `employees`.
     SELECT  e.firstname, e.lastname
     FROM transactions AS t
     JOIN employees AS e 
	 ON t.employee_id = e.id;
	 
-- 63) What is the name of the employee who made the most in sales? Find this answer by doing a join as in the previous problem. Your resulting query will be difficult for someone else to read.
SELECT e.firstname, e.lastname
FROM transactions AS t
JOIN employees AS e
 ON t.employee_id = e.id
GROUP BY t.employee_id
ORDER BY SUM(t.quantity * t.unit_price) DESC
LIMIT 1;

-- 64) Solve the previous problem by joining `employees` onto the `trans_by_employee` view.
SELECT e.firstname, e.lastname
FROM trans_by_employee AS v
JOIN employees AS e 
ON v.employee_id = e.id
ORDER BY v.total_cost DESC
LIMIT 1;

-- 65) Next, the company will try to give bonuses based on performance. 
--Show all employees who've made more in sales than 1.5 times their salary.
SELECT e.* 
FROM trans_by_employee AS v
JOIN employees AS e 
ON v.employee_id = e.id
WHERE v.total_cost > (e.salary * 1.5);


--66) Do we have potentially erroneous rows? 
--Find all transactions which occurred _before_ the employee was even hired! 
--(Make sure each transaction only occupies one row).
SELECT t.order_id, t.customer, t.orderdate, t.employee_id
FROM transactions AS t
JOIN employees AS e 
    ON t.employee_id = e.id
WHERE t.orderdate < e.startdate
GROUP BY t.order_id;

--or by use DISTINCT to be each transaction only occupies one row
SELECT DISTINCT t.order_id, t.customer, t.orderdate, t.employee_id
FROM transactions AS t
JOIN employees AS e 
    ON t.employee_id = e.id
WHERE t.orderdate < e.startdate;

-- 67) Among all transactions that occurred from 2015 to 2019, create a table that is the monthly revenue of our company versus the total trading volume of Yum! in that month.
-- Format the columns nicely. (Hint: look at the views) That is, a sample row of your result might look like this:

-- | year | month | company_revenue | yum_trade_volume |
-- |------|-------|-----------------|------------------|
-- | 2017 |    03 |        $100,000 |      125,000,000 |

-- * _Hint:_ You don't need any `WHERE` statements here. You can get the right answer simply by changing what kind of join you do!

   SELECT v2.year, v2.month, 
    PRINTF('$%,d', CAST(v1.total_cost AS INTEGER)) AS company_revenue,
    PRINTF('%,d', CAST(v2.tot_volume AS INTEGER)) AS yum_trade_volume
FROM yum_by_month AS v2
LEFT JOIN trans_by_month AS v1 
    ON v1.year = v2.year 
   AND v1.month = v2.month
   ORDER BY v2.year, v2.month;
