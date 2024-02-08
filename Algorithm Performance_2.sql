--select * from fb_search_events;

with temp1 as (
select search_id,
case when clicked != 1 then 1
when clicked = 1 and search_results_position > 3 then 2
when clicked = 1 and search_results_position <= 3 then 3
end as rating
from fb_search_events
)

select search_id,
max(rating) as rating
from temp1
group by search_id