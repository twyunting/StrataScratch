--select * from customers;

select
city,
count(distinct O.id) as num_of_orders,
count(distinct C.id) as num_of_cumstomers,
sum(total_order_cost) as cost_of_orders
from customers C
left join orders O 
on C.id = O.cust_id
group by city
having count(O.id) >= 5