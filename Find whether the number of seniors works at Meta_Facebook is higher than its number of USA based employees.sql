select 
case when 
sum(case when is_senior is True then 1 else 0 end) 
>
sum(case when location = 'USA' then 1 else 0 end) 
then 
'More seniors' 
else 
'More USA-based' end as winner
from facebook_employees