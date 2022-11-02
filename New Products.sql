with car_2019 as (select company_name, count(*) as cnt from car_launches
where year = 2019
group by company_name),
car_2020 as (select company_name, count(*) as cnt from car_launches
where year = 2020
group by company_name)

select car_2020.company_name,
(car_2020.cnt - car_2019.cnt) as diff
from car_2019 
inner join car_2020
on car_2019.company_name = car_2020.company_name

--select * from car_2020
