-- select *
-- from Member;

-- select *
-- from Attends;

-- select *
-- from Type;

-- select *
-- from Class;

-- A
---------------------
--Eva

SELECT max(e.price)
FROM equipment e;



--Omar

select max(e.price) as "Max Price"
from Equipment e;
--:>


---------------------
-- B
---------------------
--Eva

select count(m.start_date) as "Month count"
from Member m
where extract(month from m.start_date) = 1;



--Omar

select count(m.start_date) as "Month count"
from Member m
where extract(month from m.start_date) = 1;


---------------------
-- C
---------------------
--Eva

select count(c.id)
from class c
    join type t on t.id = c.TID
where lower(t.name) like '%fit%';



--Omar

select count(t.id) as "Class count"
from Class c
    join Type t on c.tid = t.id
    where lower(t.name) like '%fit%';


---------------------
-- D
---------------------
--Eva

select count(distinct c.iid) as "Distinct instructor count"
from attends a 
    join class c on c.id = a.cid
    join Member m on m.id = a.mid
where c.iid = m.iid and m.iid is not null;



--Omar

select count(distinct c.iid) as "Distinct instructor count"
from Attends a
    join Member m on a.mid = m.id
    join Class c on a.cid = c.id and c.iid = m.iid
    where m.iid is not null;


---------------------
-- E
---------------------
--Eva

select distinct t.name, round(avg(a.rating)) as "Average Rating"
from class c
    join attends a on a.cid = c.id
    join type t on t.id = c.tid
group by t.id
order by "Average Rating" DESC;



--Omar
select distinct t.name, round(avg(a.rating)) as "Average Rating"
from Attends a 
    join Class c on a.cid = c.id
    join Type t on c.tid = t.id
group by t.id
order by "Average Rating" desc;

---------------------
-- F
---------------------
--Eva

select count(distinct m.id) as "Member count"
from member m
    left join attends a on a.mid = m.id
where m.iid is null and a.mid is null;



--Omar

select count(*) as "Member count"
from Member m
    left join Attends a on m.id = a.mid
where m.iid is null and a.mid is null;


---------------------
-- G
---------------------
--Eva

select count(*) as "Instructor count"
from (
    select distinct i.id, count(c.id) as "Classes count"
    from instructor i
        join class c on c.iid = i.id
    group by i.id
    having count(c.id) >= 10
    );

--Omar

select count(*) as "Instructor count"
from(
    select i.id, i.name, count(i.name)
    from Class c 
        join Instructor i on c.iid = i.id
    group by i.id
    having count(i.name) > 9);


---------------------
-- H
---------------------
--Eva

select count(distinct m1.id) as "Member count"
from member m1
    join member m2 on (m1.start_date = m2.start_date and m1.quit_date = m2.quit_date)
where m1.id != m2.id and m2.quit_date is not null;

--Omar

select count(distinct m1.id) as "Member count"
from Member m1 
    join Member m2 on (m1.start_date = m2.start_date and m1.quit_date = m2.quit_date)
    where m1.id <> m2.id

---------------------

--I-- eva
select count(*) as "Class count"
from(
select a.cid, t.capacity, count(a.cid)
from class c 
    join gym g on g.id = c.gid
    join type t on t.id = c.tid
    join attends a on a.cid = c.id
where g.address like '%Reykjavik%' and (t.capacity = 30 or t.capacity = 40)
group by a.cid, t.capacity
having count(a.cid) < t.capacity
);

/*I. How many classes were held in gyms in Reykjavik and have a capacity of
either 30 or 40 people, but the capacity was not used fully?*/
select count(*) as "Class count"
from (
select distinct c.id as "c.id", t.capacity, count(distinct a.mid)
from attends a
    join class c on a.cid = c.id
    join gym g on c.gid = g.id
    join type t on c.tid = t.id
    where g.address like '%Reykjavik%' and ((t.capacity = 30) or (t.capacity = 40))
    group by c.id, t.capacity
    having count(a.mid) < t.capacity)
