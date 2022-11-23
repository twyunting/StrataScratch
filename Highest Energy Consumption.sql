with all_tb as(SELECT * FROM fb_eu_energy 
union all
SELECT * FROM fb_asia_energy
union all
SELECT * FROM fb_na_energy),

--select * from all_tb

cons_tb as(
select date, sum(consumption) as ttl_consumption from all_tb
group by date
order by ttl_consumption desc)

--select * from cons_tb

select * from cons_tb
where ttl_consumption = (select max(ttl_consumption) from cons_tb)