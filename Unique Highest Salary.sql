--select * from employee;

select salary
--count(*) as cnt
from employee
group by salary
having count(*) = 1
order by salary desc
limit 1