-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

-- note: 26 customers x 8 prdocut/vendor = 208

select vendor_name, product_name, sum(max_sales_per_customer) as total_sales
from (
	select vendor_name, product_name, customer_id, max_sales_per_customer
	from (
		select distinct v.vendor_name, p.product_name, (original_price * 5) as max_sales_per_customer
		from vendor_inventory vi
		inner join vendor v
			on vi.vendor_id = v.vendor_id
		inner join product p
			on vi.product_id = p.product_id
	) vendor_product
	cross join customer
	order by customer_id asc
) cross_join_sales
group by vendor_name, product_name



-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS temp.product_units;
CREATE TEMP TABLE product_units
(
	product_id int,
	product_name text,
	product_size text,
	product_category_id INT,
	product_qty_type text,
	snapshot_timestamp date
)

insert into temp.product_units
	select *, CURRENT_TIMESTAMP
	from product
	where product_qty_type = 'unit';

-- Alternative 1

DROP TABLE IF EXISTS temp.product_units;
CREATE TEMP TABLE product_units AS
	select *, CURRENT_TIMESTAMP as snapshot_timestamp
	from product
	where product_qty_type = 'unit';
	

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

insert into temp.product_units
values (24,'Apple Pie with Cherry','8''''',3,'unit',CURRENT_TIMESTAMP);

select *
from temp.product_units
where product_id = 24;

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

delete from temp.product_units
where product_id in (
	select product_id
	from (
		select product_id,snapshot_timestamp , dense_rank() over (order by snapshot_timestamp desc) as max_date
		from temp.product_units
	) x
	where max_date = 1
);
-- note: used 'in' just in case there is a tie in the dense_rank()and the subquery return more than 1 row.

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

ALTER TABLE temp.product_units
ADD current_quantity INT;

	
-- First + Second
select x.product_id, x.market_date, x.quantity, x.quantity_rank
from (
	select *, dense_rank() over (partition by product_id order by market_date desc) as quantity_rank
	from (
		select p.product_id, 
			coalesce (vi.market_date, CURRENT_TIMESTAMP) as market_date, 
			coalesce (vi.quantity,0) as quantity
		from  product p
		left join vendor_inventory vi
			on p.product_id = vi.product_id
	) product_rank
) x
where x.quantity_rank = 1

-- UPDATE with subquery adjusted to return 1 column
--
update temp.product_units
set current_quantity = 
(
	select x.quantity
	from (
		select *, dense_rank() over (partition by product_id order by market_date desc) as quantity_rank
		from (
			select p.product_id, 
				coalesce (vi.market_date, CURRENT_TIMESTAMP) as market_date, 
				coalesce (vi.quantity,0) as quantity
			from  product p
			left join vendor_inventory vi
				on p.product_id = vi.product_id
		) product_rank
	) x
	where x.quantity_rank = 1 
		and x.product_id = temp.product_units.product_id
);


