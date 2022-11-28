--select *,
--case when designation is not null then 1 else 0 end as Boolean
--from winemag_p2
/*
with tmp1 as (
select *,
case when designation is not null then 1 else 0 end as cnt_des
from winemag_p2
), 
total_tb as(
select country, count(*) as cnt_total
from tmp1
group by country),

with_tb as(
select country, count(*) as cnt_with
from tmp1
where cnt_des = 1
group by country),

without_tb as(
select country, count(*) as cnt_without
from tmp1
where cnt_des = 0
group by country)

select total_tb.country,
cnt_without,
cnt_with,
cnt_total
from total_tb 
inner join with_tb
on total_tb.country = with_tb.country
inner join without_tb
on total_tb.country = without_tb.country
*/

select country,
count(*) - sum(case when designation is not null then 1 else 0 end) as without,
sum(case when designation is not null then 1 else 0 end) as with,
count(*) as total
from winemag_p2
group by country