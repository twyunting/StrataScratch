select 
loan_id,
case when rate_type = 'fixed' then 1 else 0 end as fixed,
case when rate_type = 'variable' then 1 else 0 end as variable
from submissions