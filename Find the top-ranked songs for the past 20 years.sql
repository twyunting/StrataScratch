select distinct song_name 
from billboard_top_100_year_end
where year_rank = 1 and date_part('year', current_date) - year <= 20