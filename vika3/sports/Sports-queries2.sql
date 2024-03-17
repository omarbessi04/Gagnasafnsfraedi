select *
from Sports;

select *
from Results;

select *
from People;

select *
from Competitions;

-- Q14)
select p.id, p.name, p.height, r.result, s.name,
    case
    when (r.result / s.record) != 1 then 'No'
    else 'Yes'
    end as "record?"
from People p
    join Results r on p.id = r.peopleID
    join Sports s on r.sportid = s.id
where r.result = (
    select max(r.result)
    from Results r
    where r.sportID = s.id
)
group by p.id, r.result, s.name, s.record, s.id;

-- Q15)
select p.id, p.name
from People p 
    left join Results r on r.peopleID = p.id
where r.peopleID is null;

-- Q16)
select distinct p.id, p.name
from People p
    join Results r on p.id = r.peopleID
    join Sports s on r.sportID = s.id
    join Competitions c on c.id = r.competitionID
    where (s.record = r.result and s.name = 'High Jump') or c.held in (
        select c.held
        from Competitions c
        where extract(month from c.held) = 6 and extract(year from c.held) = 2002
    );

-- Q17)
select distinct p.id, p.name
from People p 
    join Results r on r.peopleID = p.id
    join Sports s on r.sportID = s.id
    where r.result = s.record and 1 =  (
        select count(distinct r.sportID)
        from Results r
        where r.peopleID = p.id
    );

-- Q18)
select count(distinct p.id)
from People p
    join Results r on p.id = r.peopleID
    join Competitions c on r.competitionID = c.id
    where 10 <= (
        select count(distinct c.place)
        from Competitions c
            join Results r on c.id = r.competitionID
            where r.peopleId = p.id
    );

-- Q19)
select distinct p.id, p.name
from Results r 
    join Sports s on r.sportID = s.id
    join People p on r.peopleID = p.id
    where r.result = s.record and 7 = (
        select count(distinct r.result)
        from Results r
            join Sports s on r.result = s.record
            where r.peopleID = p.id
            group by r.peopleID, p.name
    )
group by r.peopleID, p.id, s.ID;

-- Q20)
select s.id, s.name, s.record, min(r.result) as "worst result"
from Sports s
    join Results r on r.sportId = s.id
    join Competitions c on c.id = r.competitionID
    group by s.id, s.name
    HAVING count(distinct c.place) >= (
        select count(distinct c.place)
        from Competitions c
    );
