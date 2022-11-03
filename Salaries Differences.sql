select
abs(max(case when tb2.department = "marketing" then salary else null end) -
max(case when tb2.department = "engineering" then salary else null end)) as diff
from db_employee tb1
left join db_dept tb2
on tb1.department_id = tb2.id