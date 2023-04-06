--select * from customers;

select
first_name,
city,
count(*) as order_cnt,
sum(total_order_cost) as ttl_order_cost
from customers C
right join orders O 
on C.id = O.cust_id
group by first_name, city
having count(*) >=3 and sum(total_order_cost) >= 100
order by order_cnt desc, ttl_order_cost desc
limit 3