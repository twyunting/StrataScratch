--select * from employee;

select 
department,
count(id) as cnt
from employee
group by department
having count(id) >= 5