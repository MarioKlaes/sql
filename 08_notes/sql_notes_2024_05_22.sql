
drop table if EXISTS temp.product_expanded;

create temp table product_expanded as
	select * from product;
	

insert into temp.product_expanded 
values (26, 'Almonds', '1 lb', 1 , 'lbs');

update temp.product_expanded
set product_size = '1/2 lb'
where product_id = 26;

-- select * from temp.product_expanded

-- Views are slow because they are kept up to date all the time
-- tables have the data ... views hold the definition of the view
--       when you select * from <view> the code to create the view is runned to create/re-crete/update the view 

drop view if exists vendor_daily_sales;
create view if not EXISTS vendor_daily_sales as
select
	md.market_date,
	market_day,
	market_week,
	market_year,
	vendor_name,
	sum(quantity * cost_to_customer_per_qty) as sales
from new_customer_purchases cp
inner JOIN market_date_info md
	on cp.market_date = md.market_date
inner join vendor v
	on cp.vendor_id = v. vendor_id
where md.market_date = date('now')
group by md.market_date, v.vendor_id;



select market_year, market_week, sum(sales) as weekly_sakes
from vendor_daily_sales
group by market_year, market_week
order by market_year asc, market_week asc


select market_year, market_week, sum(sales) as yearly_sales
from vendor_daily_sales
group by market_year

-------------

insert into market_date_info 
values ('2024-05-22','Wednesday','21','2024','8:00 AM','2:00 PM','special day','Spring','28','32',1,0);

update new_customer_purchases
set market_date = '2024-05-22';

select *
from new_customer_purchases

-----------

select *
from vendor_daily_sales


----------- Work with JSON files / data

drop table if exists temp.[new_json];

create temp TABLE if not EXISTS temp.new_json
(
col1 BLOB
);

insert into temp.new_json (col1)
values ('[
    {
        "country": "Afghanistan",
        "city": "Kabul"
    },
    {
        "country": "Albania",
        "city": "Tirana"
    }]');


select KEY, json_extract(value,'$.country') as country
,json_extract (value , '$.city') as city
from (
select *
from new_json, json_each(new_json.col1 , '$')
) x


------------------------------
-- Cross JOIN
------------------------------
-- create a cartesian product ... they do not koin any COLUMN


drop table if exists temp.cross_join_test;

create temp TABLE if not EXISTS cross_join_test 
(
col1 text
);

insert into cross_join_test values ('small');
insert into cross_join_test values ('medium');
insert into cross_join_test values ('large');


select a.col1, b.col1 
from cross_join_test a
cross join cross_join_test b










