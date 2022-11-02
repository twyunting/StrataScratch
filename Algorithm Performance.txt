select search_id, 
max(case when clicked = 0 then 1
when clicked != 0 and search_results_position > 3 then 2
when clicked != 0 and search_results_position <= 3 then 3
end) as rating
from fb_search_events
group by search_id