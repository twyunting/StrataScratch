/*
select from_user, 
nationality, 
max(review_score) as max_score
from airbnb_reviews R
inner join airbnb_hosts H
on R.from_user = H.host_id
where from_type	!= 'host'
group by from_user, nationality
*/

with temp as (SELECT from_user, 
to_user, 
from_type, 
MAX(review_score) OVER(PARTITION BY from_user) AS max_score, 
review_score
FROM airbnb_reviews
WHERE from_type = 'guest')

select distinct from_user, 
nationality,
max_score
from temp A
inner join airbnb_hosts B
on A.to_user = B.host_id
where review_score = max_score

