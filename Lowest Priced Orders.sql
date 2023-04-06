--select * from customers;

select cust_id,
first_name,
min(total_order_cost) as lower_order_price
from customers C
right join orders O 
on C.id = O.cust_id
group by cust_id, first_name
order by lower_order_price asc
--limit 1
