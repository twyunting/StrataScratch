select to_user,
sum(case when L.label = 'Promotion' then 1 else 0 end) as Promotion_cnt,
sum(case when L.label  =  'Social' then 1 else 0 end) as Social_cnt,
sum(case when L.label  =  'Shopping' then 1 else 0 end) as Shopping_cnt
from google_gmail_emails E
inner join google_gmail_labels L
on E.id = L.email_id
group by to_user
