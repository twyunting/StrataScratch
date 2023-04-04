
select 
CORR(yearly_salary, days)
from 
(select start_date,
end_date,
yearly_salary,
--COALESCE(end_date, current_date)
(COALESCE(end_date, current_date) - start_date) as days
--DATEDIFF(COALESCE(end_date, current_date), start_date) as days_2
from lyft_drivers) tmp

-- The correlation coefficient is measured on a scale that varies from + 1 through 0 to – 1