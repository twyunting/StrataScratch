select G.gender, avg(review_score) as avg_score
from airbnb_reviews R
inner join airbnb_guests G
on R.from_user = G.guest_id
where R.from_type = 'guest'
group by G.gender
order by avg_score desc
limit 1