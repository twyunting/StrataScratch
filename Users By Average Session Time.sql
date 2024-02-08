--select * from facebook_web_log;
with temp1 as (
select user_id,
convert(date, timestamp) as user_date,
datediff(second, 
max(case when action = 'page_load' then timestamp end), 
min(case when action = 'page_exit' then timestamp end)) as user_session
from facebook_web_log
group by user_id, convert(date, timestamp)
)

select user_id,
round(sum(user_session)* 1.0/ count(user_session), 1) as avg_session_time
from temp1
where user_session is not null
group by user_id