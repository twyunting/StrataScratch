--select * from lyft_rides;

/*
select weather, hour, count(*)
from lyft_rides
group by weather, hour
*/

--select cast(count(index) as float) from lyft_rides

select weather, hour, count(*)/(select cast(count(index) as float) from lyft_rides) as prob
from lyft_rides
group by weather, hour