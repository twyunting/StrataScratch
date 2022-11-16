/*
with confirmed_phones as (select * from fb_sms_sends SEND
right join fb_confirmers CON
on SEND.phone_number = CON.phone_number
where ds = '2020-08-04'),

all_phones as (select * from fb_sms_sends
where ds = '2020-08-04')

select count(C.*)/count(A.*)
from confirmed_phones C 
inner join all_phones A
on C.ds = A.ds
group by C.ds
*/

select count(CON.phone_number)::float / count(SEND.phone_number)* 100  as perc
from fb_sms_sends SEND
left join fb_confirmers CON
on SEND.phone_number = CON.phone_number
and SEND.ds = CON.date
where SEND.ds = '2020-08-04' and SEND.type = 'message'
