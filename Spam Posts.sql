select P.post_date,
sum(case when post_keywords like '%spam%' then 1 else 0 end)
/ count(*)::float * 100 as prec
from facebook_posts P
inner join facebook_post_views V
on P.post_id = V.post_id
group by P.post_date