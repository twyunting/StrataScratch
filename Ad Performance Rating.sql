with temp1 as(
select product_id,
sum(quantity) as ttl_sold
from marketing_campaign
group by product_id 
order by sum(quantity) desc)

select *,
case when ttl_sold > 30 then 'Outstanding'
when ttl_sold >= 20 and ttl_sold <= 29 then 'Satisfactory'
when ttl_sold >= 10 and ttl_sold <= 19 then 'Unsatisfactory'
when ttl_sold >= 1 and ttl_sold <= 9 then 'Poor'
end as ad_pf
from temp1