select *
from Sports;

select *
from Results
order by peopleID;

select *
from People
order by name;

select *
from Competitions;

-- Q1)
select s.name, s.record
from Sports s
order by s.name;

-- Q2)
select distinct s.name
from Results r
    join Sports s on r.sportID = s.id;

-- Q3)
select count(distinct peopleID)
from Results;

-- Q4)
select p.id, p.name
from Results r
    join People p on r.peopleID = p.id
group by p.id
having count(p.id) >= 20;

-- Q5)
select distinct p.id, p.name
from People p
    join Results r on p.id = r.peopleID
    join Sports s on r.result = s.record
    WHERE s.id = r.sportID;

-- Q6)
select s.name, count( distinct r.peopleid) as "numathletes"
from Sports s
    join Results r on s.id = r.sportID and s.record = r.result
group by s.name;

-- Q7)
select p.id, p.name, max(r.result) as "best", to_char(s.record - max(r.result), '0D99') as "difference"
from People p
    join Results r on r.peopleID = p.id
    join Sports s on r.sportID = s.id
    where s.name = 'Triple Jump'
    group by p.id, s.record
    having count(*) >= 20;

-- Q8)
select distinct p.id, p.name
from Results r
    join Competitions c on r.competitionID = c.id
    join People p on r.peopleID = p.id
    where extract(year from c.held) = 2009 and c.place = 'Hvide Sande';

-- Q9)
select p.name
from People p
where split_part(p.name, ' ', 2) ilike 'j%' and split_part(p.name, ' ', 2) ilike '%sen';

-- Q10)
select r.result, p.name, s.name,
case 
    when r.result is null then 'No result'
    else round(r.result/s.record * 100) || '%' 
end as percentage
from Results r
    join People p on r.peopleID = p.id
    join Sports s on r.sportID = s.id;

-- Q11)
select count(distinct r.peopleID)
from Results r
where r.result is null;

-- Q12)
select s.id + 1 as "id", s.name, max(result) as "new records"
from Sports s
    join Results r on s.id = r.sportID
    group by s.id
order by s.id;
    
-- Q13)
select p.id, p.name, count(*) as "records"
from People p
    join Results r on p.id = r.peopleID
    join Sports s on r.sportID = s.id
    where r.result = s.record
    group by p.id
    having count(*) > 2;