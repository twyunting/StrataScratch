select host_id, 
sum(n_beds) as ttl_beds,
dense_rank() over (order by sum(n_beds) desc) as bed_ranks
from airbnb_apartments
group by host_id
order by bed_ranks asc