select from_user, 
count(*) cnt,
row_number() over (order by count(*) desc, from_user asc) as sent_rank
from google_gmail_emails
group by from_user
order by cnt desc
