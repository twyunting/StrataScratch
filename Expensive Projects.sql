select p.title, round(avg(p.budget) / count(emp_id)) as bud_per_emp
from ms_projects p
left join ms_emp_projects e
on p.id = e.project_id
where emp_id is not null
group by p.title
order by bud_per_emp desc