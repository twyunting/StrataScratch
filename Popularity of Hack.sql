select location, 
avg(popularity) as avg_pop
from facebook_employees E
left join facebook_hack_survey S
on E.id = S.employee_id
group by location


--where employee_id is null
