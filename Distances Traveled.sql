select U.id, 
U.name,
sum(distance) as ttl_distance
from lyft_rides_log R
left join lyft_users U
on R.user_id = U.id
group by 1, 2
order by ttl_distance desc
limit 10