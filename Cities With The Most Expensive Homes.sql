--select * from zillow_transactions;

select city, avg(mkt_price) as avg_price  
from zillow_transactions
group by city
having avg(mkt_price) >
(select avg(mkt_price) as avg_price 
from zillow_transactions)