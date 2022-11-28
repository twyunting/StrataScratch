-- Group functions ignore the NULL values in the column
/*
with tmp as (select
id,
country,
description,
designation,
points,
price,
province,
region_1,
region_2,
variety,
winery from winemag_p1
union all
select 
id,
country,
description,
designation,
points,
price,
province,
region_1,
region_2,
variety,
winery from winemag_p2)

select * from tmp
*/
with w1_tb as(select province, count(*) as w1_cnt
from winemag_p1
group by province)
, 
w2_tb as (select province, count(*) as w2_cnt
from winemag_p2
group by province)


select w1_tb.province,
w1_tb.w1_cnt
from w1_tb 
inner join w2_tb
on w1_tb.province = w2_tb.province and w1_tb.w1_cnt > w2_tb.w2_cnt
order by w1_tb.w1_cnt desc
--select * from w2_tb