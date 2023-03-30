select * from (
SELECT 
title, 
avg(points) as points,
avg(price) as price,
avg(points)/avg(price) as pp_ratio
FROM winemag_p2
group by title
order by pp_ratio desc) tmp
where pp_ratio is not null
limit 1 

