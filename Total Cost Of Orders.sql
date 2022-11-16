select C.id, C.first_name, C.last_name, sum(total_order_cost) as ttl_cost
from customers C
inner join orders O
on C.id = O.cust_id
group by C.id, C.first_name, C.last_name