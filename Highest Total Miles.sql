select purpose, sum(miles) as ttl_miles
from my_uber_drives
where category = 'Business'
group by purpose
order by ttl_miles desc
limit 3