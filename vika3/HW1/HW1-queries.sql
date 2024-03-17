
-- A)
select max(e.price) as "Max Price"
from Equipment e;

-- B)
select count(m.start_date) as "Month count"
from Member m
where extract(month from m.start_date) = 1;

-- C)
select count(t.id) as "Class count"
from Class c
    join Type t on c.tid = t.id
    where lower(t.name) like '%fit%';

-- D)
select count(distinct c.iid) as "Distinct instructor count"
from Attends a
    join Member m on a.mid = m.id
    join Class c on a.cid = c.id and c.iid = m.iid
    where m.iid is not null;

-- E)
select t.name, cast(avg(a.rating) as int) as "Average Rating"
from Type t
    join Attends a on t.id = a.cid
    group by t.id
order by "Average Rating" desc;

-- F)
select count(*) as "Member count"
from Member m
    left join Attends a on m.id = a.mid
where m.iid is null and a.mid is null;

-- G)
select count(*) as "Instructor count"
from(
select i.id, i.name, count(i.name)
from Class c 
    join Instructor i on c.iid = i.id
    group by i.id
    having count(i.name) > 9);

-- H)
select count(distinct m.id) as "Member count"
from Member m 
    join Member m2 on m.start_date = m2.start_date and m.quit_date = m2.quit_date
    where m.id <> m2.id;

-- I)
select count(*) as "Class count"
from (
select distinct c.id as "c.id", t.capacity, count(a.mid)
from attends a
    join class c on a.cid = c.id
    join gym g on c.gid = g.id
    join type t on c.tid = t.id
    where g.address like '%Reykjavik%' and ((t.capacity = 30) or (t.capacity = 40))
    group by c.id, t.capacity
    having count(a.mid) < t.capacity);

-- J)
with BestMinutes as (
    select m.id, m.name, sum(c.minutes) as "total_minutes"
    from Member m 
        join Attends a on m.id = a.mid
        join Class c on a.cid = c.id
        group by m.id, m.name
        order by total_minutes desc
)
select id, name
from BestMinutes
where "total_minutes" = (
    select max("total_minutes")
    from BestMinutes
);