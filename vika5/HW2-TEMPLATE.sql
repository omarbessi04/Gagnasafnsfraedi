-- HW2
-- Student names:

-- A. 447 different members attended at least one class on January 10th. How many different members attended at least one class on January 15th?
-- Explanation: 

select count(distinct a.mid) as "Member count"
from Attends a
    join Class c on a.cid = c.ID
    where extract(month from c.date) = 1 and extract(day from c.date) = 15;

-- B. 4 different class types require more than 20 light dumbbells. How many class types require more than 20 yoga mats?
-- Explanation: 

select count(distinct n.tid) as "Type Count"
from Equipment e
    join Needs n on e.id = n.eid
    where e.name = 'Yoga mat' and n.quantity > 20;

-- C. Oh no! Some member hacked the database and is still attending classes but has quit according to the database. Write a query to reveal their name!
-- Explanation: 

select m.name as "Hacker name"
from Attends a
    join Member m on a.mid = m.id
    join Class c on a.cid = c.id
    where m.quit_date is not null and c.date > m.quit_date;

-- D. How many members have a personal trainer with the same first name as themselves, but have never attended a class that their personal trainer led?
-- Explanation: 

select count(*) as "Member count"
from(
    select distinct m.name
    from Member m
        join Instructor i on m.iid = i.id
        join Attends a on m.id = a.mid
        join Class c on c.id = a.cid
        where c.iid != m.iid and split_part(m.name, ' ', 1) = split_part(i.name, ' ', 1)
        group by m.id
);

-- E. For every class type, return its name and whether it has an average rating higher or equal to 7, or lower than 7, in a column named "Rating" with values "Good" or "Bad", respectively.
-- Explanation: 

select distinct t.name,
    case
    when avg(a.rating) >= 7 then 'Good'
    else 'Bad'
    end as "Rating"
from Class c
    join Attends a on a.cid = c.id
    join Type t on t.id = c.tid
    group by t.id
order by t.name;

-- F. Out of the members that have not quit, member with ID 6976 has been a customer for the shortest time. Out of the members that have not quit, return the ID of the member(s) that have been customer(s) for the longest time.
-- Explanation: 

with LongestTime as (
    select m.id, m.start_date
    from Member m
    where m.quit_date is null
    order by m.start_date asc
)

select LT.id as "Longest standing Member(s)"
from LongestTime LT
where LT.start_date = (
    select min(LT.start_date)
    from LongestTime LT
);

-- G. How many class types have at least one equipment that costs more than 100.000 and at least one other equipment that costs less than 5.000?
-- Explanation: 

select count(*)
from (
    with NET as (
            select t.id, e.price
            from Needs ned
            join Equipment e on ned.eid = e.id
            join Type t on ned.tid = t.id
    )

    select distinct id
    from NET
        where id in (
            select id
            from NET
            where price > 100000
        ) and id in (
            select id
            from NET
            where price < 5000
        )
);

-- H. How many instructors have led a class in all gyms on the same day?
-- Explanation: 

select count(*) as "Instructor count"
from(
    select c.iid, c.date, count(distinct c.gid) 
    from Class c
    group by c.iid, c.date
    having count(distinct c.gid) = (select count(*) from Gym)
);


-- I. How many instructors have not led classes of all different class types?
-- Explanation: 

select count(*) as "Instructor Count"
from(
select i.id, i.name, count(distinct c.tid) as "Distinct class count"
from Instructor i
    join Class c on i.id = c.iid
    group by i.id
    having count(distinct c.tid) <> (select count(*) from Type)
);

-- J. The class type "Circuit training" has the lowest equipment cost per member, based on full capacity.
-- Return the name of the class type that has the highest equipment cost per person, based on full capacity.
-- Explanation: 

with typeTable as(
select t.id, t.name, (SUM(e.price * n.quantity) / t.capacity) as Cost_Per_Person
from 
    Type t 
    join Needs n on t.id = n.tid
    join Equipment e on n.eid = e.id
    GROUP BY t.id, t.name, t.capacity
)

select tt.name
from typeTable tt
where Cost_Per_Person = (
    select max(tt.Cost_Per_Person)
    from typeTable tt
);


-- K (BONUS). The hacker revealed in query C has left a message for the database engineers. This message may save the database!
-- Return the 5th letter of all members that started the gym on December 24th of any year and have at least 3 different odd numbers in their phone number, in a descending order of their IDs,
-- followed by the 8th letter of all instructors that have not led any "Trampoline Burn" classes, in an ascending order of their IDs.
-- Explanation: 


    select substring(m.name, 5, 1) as "Member_check", m.phone, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cast(m.phone as VARCHAR), '0', ''), '2', ''), '4', ''), '6', ''), '8', '')
    from Member m
    where extract(month from m.start_date) = 12 and extract(day from m.start_date) = 24 
    and length(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cast(m.phone as VARCHAR), '0', ''), '2', ''), '4', ''), '6', ''), '8', '')) >= 3
    order by m.id desc;

    select substring(i.name, 8, 1) as "Instructor_check"
    from Instructor i
    where i.id not in (
        select c.iid
        from Class c
        where c.tid = (
            select t.id
            from Type t
            where name = 'Trampoline Burn'
        )
    )