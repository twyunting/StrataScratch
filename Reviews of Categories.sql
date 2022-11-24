--select * from yelp_business;

with temp as (select name, 
review_count,
unnest(string_to_array(categories, ';')) as category
from yelp_business)

select category,
sum(review_count) as ttl_review
from temp
group by category
order by ttl_review desc