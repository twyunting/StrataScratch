--select * from employee;

with cte1 as(
select *,
(case when sex = 'M' then 1 else 0 end) males_count,
(case when sex = 'M' then salary else 0 end) males_salary,
(case when sex = 'F' then 1 else 0 end) females_count,
(case when sex = 'F' then salary else 0 end) females_salary
from employee)
--group by department
--select * from cte1

select department,
sum(females_count) as females,
sum(females_salary) as females_sal,
sum(males_count) as males,
sum(males_salary) as males_sal
from cte1
group by department 
