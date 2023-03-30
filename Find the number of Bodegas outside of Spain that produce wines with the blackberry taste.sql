with Bodegas as (select  * 
from winemag_p1
where lower(winery) like '%bodega%' and country != 'Spain' and lower(description) like '%blackberry%')

select
country,
region_1 as region,
count(distinct(winery)) as cnt
from Bodegas
group by 1, 2
order by cnt desc