--select * from employee;
select 
department,
first_name,
salary,
avg(salary) over(partition by department) as avg_dept_salary
from employee
