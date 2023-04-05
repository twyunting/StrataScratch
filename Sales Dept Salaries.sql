--select * from employee;

select 
first_name
from employee
where lower(department) = 'sales' and target > 150
order by first_name desc