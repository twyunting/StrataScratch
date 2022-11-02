/* test a command line */

with tmp as(

select worker_title, max(salary) as salary from worker W
inner join title T
on W.worker_id = T.worker_ref_id
group by worker_title
order by salary desc)

select * from tmp
where salary = (select max(salary) from worker)