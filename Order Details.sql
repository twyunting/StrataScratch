--select * from customers;

select
first_name,
O.order_date,
O.order_details,
O.total_order_cost
from customers C
right join orders O
on C.id = O.cust_id
where C.first_name in ('Jill', 'Eva')
order by cust_id asc
