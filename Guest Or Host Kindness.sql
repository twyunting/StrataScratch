--select 

select from_type,
round(avg(review_score), 2) as avg_score
from airbnb_reviews
group by from_type
order by avg_score desc
limit 1