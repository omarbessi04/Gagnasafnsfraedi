-- Query 14 (+ counting results)

SELECT NOW();

select COUNT(*)
from (
select R.peopleID, R.sportID, R.result
from Results R
where R.result = (
    select max(R1.result)
    from Results R1
    where R1.sportID = R.sportID)
) X;

SELECT NOW();
	