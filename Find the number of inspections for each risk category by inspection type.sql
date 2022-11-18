SELECT inspection_type,
sum(case when risk_category is null then 1 else 0 end) as no_show,
sum(case when risk_category = 'Low Risk' then 1 else 0 end) as low,
sum(case when risk_category = 'Moderate Risk' then 1 else 0 end) as med,
sum(case when risk_category = 'High Risk' then 1 else 0 end) as high,
count(*) as ttl_risk
FROM sf_restaurant_health_violations
group by inspection_type
order by ttl_risk desc