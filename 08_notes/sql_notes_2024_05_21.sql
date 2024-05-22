
-- IFNULL () / coalesce

select *,
ifnull (product_size , 'Unkown'),
ifnull (product_size, product_category_id), -- if one column us null, use another
coalesce (product_size, product_qty_type,'Missing') -- check if 
from product

-- nullif (5,5) : if both are the same, return NULL ..... nulif(5,7) : if both are different, return the 1st number
select *,
nullif (product_size,'') -- find '' (blanck)  values in the column product_size and replace by NULL
from product
where nullif (product_size,'') is null -- null if will return null if the column is null and if it is blank ''

-- windowed functions
-- row_number() -- given a condition, the row number will just numebr the rools
-- rank() -- given a condition you can have 1, 2, 3,3, 4 ... so you can have ties

-- what product is the highest per vendor?
select *
from (
	SELECt vendor_id, market_date, product_id, original_price
	, row_number() over (partition by vendor_id order by original_price DESC) as price_rank
	from vendor_inventory
) x
where x.price_rank = 1

------------------------------------------------------------------------------------------------------------------
--dense_rank, rank, row_number
drop table if exists temp.row_rank_dense;
create temp table if not exists temp.row_rank_dense
(
emp_id INT,
salary int
);

INSERT INTO temp.row_rank_dense
VALUES(1,200000),
        (2,200000),
        (3, 160000),
		(4, 120000),
		(5, 125000),
		(6, 165000),
		(7, 230000),
		(8, 100000),
		(9, 165000),
		(10, 100000);

-- RANK and DENSE_RANK differentiate on how they deal with ties
select *,
rank() over (order by salary desc) as [RANK],
row_number() over (order by salary desc) as [ROW_NUMBER],
dense_rank() over (order by salary desc) as [DENSE_RANK]
from temp.row_rank_dense

------------------------------------------------------------------------------------------------------------------
-- ntile (4,5,100)
-- bucket daily sales
SELECT *
,NTILE(4) OVER(PARTITION BY vendor_name ORDER BY sales ASC) as quartile
,NTILE(5) OVER(PARTITION BY vendor_name ORDER BY sales ASC) as quintile
,NTILE(100) OVER(PARTITION BY vendor_name ORDER BY sales ASC) as percentile
FROM (
	SELECT
	md.market_date
	,market_day
	,market_week
	,market_year
	,vendor_name
	,SUM(quantity*cost_to_customer_per_qty) AS sales
	
	FROM customer_purchases cp -- gets sales details
	JOIN market_date_info as md -- gets all the date columns
		ON cp.market_date = md.market_date
	JOIN vendor v -- gets the vendor name
		ON v.vendor_id = cp.vendor_id
	
	GROUP BY md.market_date, v.vendor_id
	) x

-------------------------------------------------------------------------------------------------

-- LTRIM / RTRIM
-- remove white spaces in tbe beggining or end
-- remve a letter from the first or last caracter

select ltrim ("A123A",'A');
select rtrim ("A123A",'A');
select replace ('colour' , 'u' , '')

select ltrim('           Teste         ') as a, 
       rtrim('           Teste         ') as b,
	   ltrim(rtrim('           Teste         ')) as c


select lower ("A123A");
select upper ("colour");
 
select 'test' || ' of ' || 'concatenation' as new_column

-- substr

select 'Aderbaldo Barbosa', 
       substr('Aderbaldo Barbosa', 2, 5), 
	   substr('Aderbaldo Barbosa',-5, 5),
	   substr('Aderbaldo Barbosa',3), -- gets all starting at position 3
	   instr ('Aderbaldo Barbosa','Barbosa'),
       length ('Aderbaldo Barbosa'),
	   substr('Aderbaldo Barbosa', 5, length ('Aderbaldo Barbosa') )


select 'Aderbaldo Barbosa', 
       char(98)


select *
from customer
where customer_first_name REGEXP '(e)$'

------------------------------------------------------------------------------------------------------
-- UNION / UNION ALL

-- most and least expensive product by vendor

SELECT
*,
from (
	select distinct vendor_id, product_id, original_price,
	row_number() over (partition by vendor_id order by original_price asc) as rn_min
	from vendor_inventory
) x
where x.rn_min = 1

UNION

SELECT
*, 
from (
	select distinct vendor_id, product_id, original_price, 
	row_number() over (partition by vendor_id order by original_price desc) as rn_max
	from vendor_inventory
) x
where x.rn_max = 1


-- FULL OUTER JOIN + UNION

DROP TABLE IF EXISTS temp.store1; 
CREATE TEMP TABLE IF NOT EXISTS temp.store1
(
costume TEXT,
quantity INT
);

INSERT INTO temp.store1
VALUES("tiger",6),
        ("elephant",2),
        ("princess", 4);


DROP TABLE IF EXISTS temp.store2;
CREATE TEMP TABLE IF NOT EXISTS temp.store2
(
costume TEXT,
quantity INT
);

INSERT INTO temp.store2
VALUES("tiger",2),
	("dancer",7),
	("superhero", 5);

select * from temp.store2;

SELECT s1.costume, s1.quantity as store1_quantity, s2.quantity as store2_quantity
FROM store1 s1
LEFT JOIN store2 s2 on s1.costume = s2.costume

UNION ALL

SELECT s2.costume, s1.quantity, s2.quantity
FROM store2 s2
LEFT JOIN store1 s1 on s2.costume = s1.costume
WHERE s1.quantity is NULL


-- Interset vs Inner Join 
-- they work the same ... but Inner join do not return null

-- Intersect and EXCEPT

-- products that have been sold

select product_id as 'products that already have been sold' from product
INTERSECT
select product_id from customer_purchases

select product_id from product
EXCEPT
select product_id from customer_purchases



select x.product_id, p.product_name 
from (
	select product_id from product
	EXCEPT
	select product_id from customer_purchases) x 
 join product p
	on p.product_id = x.product_id

