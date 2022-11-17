select facility_name, min(score) as lowest_score
from los_angeles_restaurant_health_inspections
where facility_address like '%HOLLYWOOD%'
group by facility_name
order by lowest_score desc, facility_name asc