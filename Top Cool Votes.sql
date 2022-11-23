select business_name, review_text from yelp_reviews
where cool  = (
select max(cool) from yelp_reviews
)