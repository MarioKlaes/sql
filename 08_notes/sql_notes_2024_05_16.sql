select customer_id, count(product_id) as total_number_of_products_purchased , count(distinct(product_id)) as unique_number_of_purchases
from customer_purchases
group by customer_id;


select count(customer_id), market_date
from customer_purchases
WHERE  market_date between '2019-04-10' and '2019-04-30'
group by customer_id;



-- Good pratice use CAST to coarce number column into number (to ensure the query will not break)
-- dont do average of a column that already  is an average

-- SUM & AVG

select market_date, customer_id, 
       sum (quantity * cost_to_customer_per_qty) as cost
from customer_purchases
group by market_date, customer_id



select customer_first_name, customer_last_name,
       avg (quantity * cost_to_customer_per_qty) as avg_cost
from customer_purchases cp
inner join customer c
	on c.customer_id = cp.customer_id
group by customer_first_name, customer_last_name
order by c.customer_id asc, avg_cost desc


-- MIN & MAX

select product_name, max(original_price)
from product p
inner join vendor_inventory vi
	on p.product_id = vi.product_id

select product_name, min(original_price)
from product p
inner join vendor_inventory vi
	on p.product_id = vi.product_id
	
-- minumum price per different type of product
select product_name, min(original_price)
from product p
inner join vendor_inventory vi
	on p.product_id = vi.product_id
group by product_name


select DISTINCT product_id, count(distinct customer_id)
from customer_purchases
group by product_id



select DISTINCT cost_to_customer_per_qty, 
       cast (cost_to_customer_per_qty as int) /2, 
	   round(10.5)
from customer_purchases



-- HAVING : allows filter rows after the agregation is calculated

SELECT cp.customer_id, cp.market_date, sum (quantity * cost_to_customer_per_qty ) as cost
from customer_purchases cp
where customer_id in (1,3)
group by cp.customer_id, cp.market_date
having cost > 10

-- subqueries
-- "what is the single item tha ahs been purchased in the greatest quantity"

select p.product_name, max (max_quantity)
from product p
inner JOIN
  (select cp.customer_id, cp.product_id, max (quantity) as max_quantity
   from customer_purchases as cp) x
   on p.product_id = x.product_id


select product_id, max (quantity)
from customer_purchases cp
group by product_id


select distinct customer_zip
from customer c
where  c.customer_id in (
               select customer_id
               from customer_purchases cp
               group by customer_id
               having sum(quantity * cost_to_customer_per_qty) >= 3000)


			   
-- Temporary tables

drop table if exists new_vendor_inventory;

create temp table new_vendor_inventory as
	select *, original_price * 5 as inflation
	from vendor_inventory; 

select * from new_vendor_inventory;


-- CTE (Common Table Expressions) ... always supported by DBMSs
with vendor_daily_sales as (
	select md.market_date, md.market_day,md.market_week, md.market_year, vendor_name, sum(quantity * cost_to_customer_per_qty) as sale
	from market_date_info as md 
		join customer_purchases cp
			on md.market_date = cp.market_date
		join vendor v
			on cp.vendor_id = v.vendor_id
	group by md.market_date, v.vendor_id
)
SELECT *
FROM vendor_daily_sales;

-- DATEs
select date(), time(), datetime()

select strftime('%Y-%m-%d', '2024-01-12 10:10:10', 'start of month')
select strftime('%Y-%m-%d', '2024-01-12 10:10:10')

select strftime('%Y-%m-%d', 'now')

-- <format> , <time string>, <modifier> , ....
select strftime('%Y-%m-%d', '2024-05-20' , '+50 days') as the_future

select market_date , strftime('%Y-%m-%d',market_date , '+50 days') as the_future
from market_date_info

select market_date , strftime('%Y-%m-%d',market_date , '+50 days', '-1 year') as the_future_minus_1_year
from market_date_info

-- Compute the last day of the current month.
SELECT date('now','start of month','+1 month','-1 day');

-- Julianday return the number of days
select julianday('2024-05-16'), julianday('now')

select  cast(julianday('2024-05-15') - julianday('2024-05-13') as int)
select  cast(julianday('2024-05-15') - julianday('2024-05-13') as float)
select  julianday('2024-05-15') - julianday('2023-05-15') 

select  cast ( (julianday('2024-05-15') - julianday('1985-05-15')) /365.25 as int) as years_between_2_dates


