with sent as(select * from fb_friend_requests where action = "sent"),
accepted as (select * from fb_friend_requests where action = "accepted")

select sent.date, count(accepted.user_id_receiver) / count(sent.user_id_sender) as rate from sent 
left join accepted 
on accepted.user_id_sender = sent.user_id_sender
group by sent.date