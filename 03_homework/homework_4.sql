-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT product_name  || ', ' ||
	   COALESCE (product_size, '') || ' (' ||
	   ifnull (product_qty_type, 'unit') || ')'
FROM product;

-- or --

SELECT product_name  || ', ' ||
	   COALESCE (product_size, '') || ' (' ||
	   COALESCE (product_qty_type, 'unit') || ')'
FROM product;



--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

-- using Row_mnumber()
select customer_id, market_date , row_number() over (partition by customer_id order by market_date asc) as visit_number
from customer_purchases

-- alternative 1
--  using DENSE_RANK()
select customer_id, market_date , DENSE_RANK() over (partition by customer_id order by market_date asc) as visit_number
from customer_purchases;

-- alternative 2
-- using DISTINCT to eliminate the repetitions (ties) of the DENSE_RANK() making a clean list where each visit per day is showed once
select DISTINCT customer_id, market_date,  x.visit_number
from (
select customer_id, market_date , DENSE_RANK() over (partition by customer_id order by market_date asc) as visit_number
from customer_purchases
) x;

/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

-- using sub query
select *
from (
select customer_id, market_date , DENSE_RANK() over (partition by customer_id order by market_date desc) as visit_number
from customer_purchases
) x
where x.visit_number = 1;

-- using tempporary table
drop table if exists temp.most_recent_visit;
create temp table if not exists temp.most_recent_visit
(
customer_id INT,
market_date date,
visit_number INT
);

insert 
into temp.most_recent_visit (customer_id, market_date, visit_number)
select customer_id, market_date , DENSE_RANK() over (partition by customer_id order by market_date desc) as visit_number
from customer_purchases;

select *
from temp.most_recent_visit 
where visit_number = 1;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

-- how many different times one customer_id has purchased a product_id
select customer_id, 
	product_id, 
	count(*) as purchases_per_costumer
from customer_purchases 
group by customer_id, product_id

-- some customers purchase the same product more than 1 time per market_date
select customer_id, 
	product_id, 
	market_date,
	count(*) as purchases_per_costumer_per_date
from customer_purchases 
group by customer_id, product_id,market_date

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

select product_name, 
case instr(product_name,'-')
	when 0 then null
	else trim(substr(product_name,instr(product_name,'-')+2,length(product_name)))
end descrioption
from product;


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

select *
from product
where product_size REGEXP '[0-9]+';


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

select x.market_date, x.sales
from (
	select sales_high_to_low.market_date as market_date, 
		sales_high_to_low.sales as sales, 
		dense_rank() over (order by sales_high_to_low.sales desc) as highest_sales
	from (
		select market_date,
		  sum ((quantity * cost_to_customer_per_qty)) as sales
		from customer_purchases
		group by market_date
	) sales_high_to_low
) x
where x.highest_sales = 1

union 

SELECT  x.market_date, x.sales 
FROM (
	select sales_low_to_high.market_date, 
		sales_low_to_high.sales , 
		dense_rank() over (order by sales_low_to_high.sales asc) as lowest_sales
	from (
	select market_date,
		  sum ((quantity * cost_to_customer_per_qty)) as sales
	from customer_purchases
	group by market_date
	) sales_low_to_high
) x
where x.lowest_sales = 1;


-- Alternative 2

select x.market_date, x.sales as sales_highest, '' as sales_lowest
from (
	select sales_high_to_low.market_date as market_date, 
		sales_high_to_low.sales as sales, 
		dense_rank() over (order by sales_high_to_low.sales desc) as highest_sales
	from (
		select market_date,
		  sum ((quantity * cost_to_customer_per_qty)) as sales
		from customer_purchases
		group by market_date
	) sales_high_to_low
) x
where x.highest_sales = 1

union 

SELECT  x.market_date, '' as sales_highest, x.sales as sales_lowest
FROM (
	select sales_low_to_high.market_date, 
		sales_low_to_high.sales , 
		dense_rank() over (order by sales_low_to_high.sales asc) as lowest_sales
	from (
	select market_date,
		  sum ((quantity * cost_to_customer_per_qty)) as sales
	from customer_purchases
	group by market_date
	) sales_low_to_high
) x
where x.lowest_sales = 1;

