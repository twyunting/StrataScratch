--select * from box_scores;
/*
SELECT MAX(T.field) AS MaxOfColumns
FROM (
    SELECT assignment1 AS field
    FROM box_scores
    UNION ALL
    SELECT assignment2 AS field
    FROM box_scores
    UNION ALL
    SELECT assignment3 As field
    FROM box_scores) AS T
*/
/*
with diff_table as(
select id, 
student,
(case when 
assignment1 >= assignment2 and assignment1 >= assignment3 then assignment1
when
assignment2 >= assignment1 and assignment2 >= assignment3 then assignment2
when
assignment3 >= assignment1 and assignment3 >= assignment2 then assignment3
end)
as max_assign,
(case when 
assignment1 < assignment2 and assignment1 < assignment3 then assignment1
when
assignment2 < assignment1 and assignment2 < assignment3 then assignment2
when
assignment3 < assignment1 and assignment3 < assignment2 then assignment3
end)
as min_assign
from box_scores
),

highest_diff as(select id, student,
(max_assign - min_assign) as diff_score
from  diff_table
order by diff_score desc
limit 1)

--select * from highest_diff

select (assignment1 + assignment2 + assignment3)
from box_scores 
where (id, student) = 
(select id, student from highest_diff)
*/

select max(assignment1 + assignment2 + assignment3)
-
min(assignment1+ assignment2 + assignment3) as diff_score
from box_scores