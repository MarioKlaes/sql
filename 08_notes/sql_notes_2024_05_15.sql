

/*
select * from customer
where customer_zip = 22801 
--and customer_first_name = 'Jane'
and customer_id between 3 and 7
*/

/*
SELECT *,
  case when cost_to_customer_per_qty < '1.00' 
       then cost_to_customer_per_qty * 5
	   else cost_to_customer_per_qty
     end as inflation,
  case
	   when cost_to_customer_per_qty between '1.01' and '7.00'
	   then cost_to_customer_per_qty * 5
	   else cost_to_customer_per_qty
  end as supper_inflation,
  CASE
	when cost_to_customer_per_qty < '1.00' then 1
	else 0
	end as inflation_sorter
from customer_purchases
order by inflation_sorter desc
*/


select distinct vendor_id,product_id,customer_id
from customer_purchases
where market_date between '2019-04-19' and '2019-04-30'





