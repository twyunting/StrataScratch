/*
SELECT *,
       CASE
           WHEN n_churned > n_churned_prev THEN 'increase'
           WHEN n_churned < n_churned_prev THEN 'decrease'
           ELSE 'no change'
       END
FROM
  (SELECT year_driver_churned,
          COUNT(*) AS n_churned,
          LAG(COUNT(*), 1, '0') OVER (
                                      ORDER BY year_driver_churned) AS n_churned_prev
   FROM
     (SELECT date_part('year', end_date::date) AS year_driver_churned
      FROM lyft_drivers
      WHERE end_date IS NOT NULL) base
   GROUP BY year_driver_churned
   ORDER BY year_driver_churned ASC) calc
*/
with cte1 as(
select 
year_driver_churned,
n_churned,
coalesce(LAG(n_churned, 1) OVER(ORDER BY year_driver_churned), 0)as prev_n_churned
from (
SELECT 
EXTRACT(YEAR FROM end_date) AS year_driver_churned,
COUNT(*) AS n_churned
FROM lyft_drivers
-- assuming NULL end_date is a current date
WHERE end_date IS NOT NULL
GROUP BY year_driver_churned)
tmp
)

--select * from cte1 

select *,
(case when n_churned > prev_n_churned then 'increase'
when n_churned = prev_n_churned then 'no change'
when n_churned < prev_n_churned then 'decrease'
end) as yearly_churn
from cte1