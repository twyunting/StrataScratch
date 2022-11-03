--select * from fb_messages
/*
with S as(
select user1, user2 as sender, sum(msg_count) as sent_cnt 
from fb_messages
group by user1),

R as(
select user1, user2 as receiver, sum(msg_count) as received_cnt 
from fb_messages
group by user2
)

select S.sender,
(sent_cnt + received_cnt) as total_msg_count
from S
inner join R
on S.sender = R.receiver

*/

select username, sum(msg_count) as total_msg_count
from
((select user1 as username, msg_count from fb_messages)
union all
(select user2 as username, msg_count from fb_messages)) as joined
group by username
order by total_msg_count desc
limit 10
