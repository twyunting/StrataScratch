-- assuming that salaries increase each year
select id,
first_name, 
last_name, 
department_id,
max(salary) as max_salary
from ms_employee_salary
group by id, 
first_name, 
last_name, 
department_id 
order by id asc

/*
with tmp_salary_tb as(select id,
max(salary) as salary
from ms_employee_salary
group by id, salary)

select * from 
ms_employee_salary 
where salary = tmp_salary_tb.salary
*/

