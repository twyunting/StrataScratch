/*
assumption: 
1. the US is the only English speaking region in the dataset, and Spain, Argentina are the only Spanish speaking regions in the dataset.
2.  Let's also assume that the same variety might be listed under several countries so you'll need to remove varieties that show up in both the US and in Spanish speaking countries.
*/
select variety,
max(price) over (partition by variety) as max_price 
from winemag_p1
where country = 'US' and points	>= 90
and
variety not in(select variety from winemag_p1
where country != 'US')
order by max_price DESC
