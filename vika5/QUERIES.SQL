-- A. 447 different members attended at least one class on January 10th. How many different members attended at least one class on January 15th?
-- Explanation: 

-- Here we joined two tables, Attends and Class on the class ID.
-- Then we had a where condition, requiring that the month and day from the class date are equal to that of January 15th.

select count(distinct a.mid) as "Member count"
from Attends a
    join Class c on a.cid = c.ID
    where extract(month from c.date) = 1 and extract(day from c.date) = 15;

-- B. 4 different class types require more than 20 light dumbbells. How many class types require more than 20 yoga mats?
-- Explanation: 

-- Here we joined two tables, Equipment and Needs on the equipment ID.
-- Then we had a where condition, requiring that the (lowered) name of the equipment was that of "yoga mat" (checking for case sensitivity)
-- We also check that the quantity of said equipment is more than 20

select count(distinct n.tid) as "Type Count"
from Equipment e
    join Needs n on e.id = n.eid
    where lower(e.name) = 'yoga mat' and n.quantity > 20;

-- C. Oh no! Some member hacked the database and is still attending classes but has quit according to the database. Write a query to reveal their name!
-- Explanation: 
-- We join the necessary tables - Member, Attends and Class - to identify which member's quit date is mysteriously earlier than the 
-- date of which a class is held on. 
-- Answer: Skyrgamur Leppaludason (shocker...)
-- Elísabet

select distinct m.name as "HACKER"
from Member m
    join Attends a on m.ID = a.MID
    join Class c on a.CID = c.ID
where c.date > m.quit_date;

-- D. How many members have a personal trainer with the same first name as themselves, but have never attended a class that their personal trainer led?
-- Explanation: Count distinct class types that require yoga mats by joining Type, Needs and Equipment tables. Then group by unique 
-- class types, lastly filtering for those which have more than 20.
-- Answer: 2
-- Eva

select count(distinct m.id) as "Member count"
from member m
    join instructor i on m.iid = i.id
    left join attends a on m.id = a.mid
    left join class  c on a.cid = c.id
    where split_part(m.name, ' ', 1) = split_part(i.name, ' ', 1) and (c.iid != m.iid);

-- E. For every class type, return its name and whether it has an average rating higher or equal to 7, or lower than 7, in a column named "Rating" with values "Good" or "Bad", respectively.
-- Explanation: 
-- First, i created a view just to make this query a bit less complicated, where i joined tables Class and Attends with Type. From the view i got a table where i could use an 
-- expression to label a certain rating as either 'good' or 'bad'.
-- Eva

select distinct t.name,
    case when 
    avg(a.rating) >= 7 then 'Good'
    else 'Bad'
    end as Rating
from class c
    join attends a on a.cid = c.id
    join type t on t.id = c.tid
group by t.id;

-- F. Out of the members that have not quit, member with ID 6976 has been a customer for the shortest time. Out of the members that have not quit, return the ID of the member(s) that have been customer(s) for the longest time.
-- Explanation: 
-- We just check the table Member, with a subquery to filter what member has the oldest start date, where quite_date is null since we do not want to include members who have already terminated their contract.
-- Answer: 5348 and 8526
-- Elísabet / Eva

select m.id as "Longest standing Member(s)"
from member m
where m.start_date in (
    select max(m.start_date)
    from member m
    where m.start_date is not null and m.quit_date is null
);

-- G. How many class types have at least one equipment that costs more than 100.000 and at least one other equipment that costs less than 5.000?
-- Explanation: 
-- This query becomes easier after making two separate tables with each condition met, then joining those two new tables to find
-- the final result.
-- Answer: 1
-- Eva

select count(*)
from (
    select t.name, max(e.price) as max_price, min(price) as min_price
    from type t
        join needs n on n.tid = t.id
        join equipment e on e.id = n.eid
    group by t.name
)
where max_price > 100000 and min_price < 5000;

-- H. How many instructors have led a class in all gyms on the same day? 
-- Explanation: 

-- Here we select the count(*) to be able to select the number of instances that show up in our subquerie
-- We select 3 things from the Class table, the instructor id, the date of the class, and the number of gyms that instructor has taught at at that date.
-- We make sure that the numer of gyms that instructor has taught at on that date is equal to that of the total number of gyms

select count(*) as "Instructor count"
from(
    select c.iid, c.date
    from Class c
    group by c.iid, c.date
    having count(distinct c.gid) = (select count(*) from Gym)
);

-- I. How many instructors have not led classes of all different class types? 
-- Explanation: 

-- Here we selected the count(*) to be able to select the number of instances that show up in our subquerie
-- Inside the subquerie we left joined two tables, Instructor and Class on the instructor ID.
-- We left joined to make sure to count the instuctors that have not taught any classes
-- We then group by the intructor ID and then check if that instructor has taught a number of distinct class types equal to the total number of class types

select count(*) as "Instructor Count"
from(
select i.id, i.name
from Instructor i
    left join Class c on i.id = c.iid
    group by i.id
    having count(distinct c.tid) <> (select count(*) from Type)
);

-- J. The class type "Circuit training" has the lowest equipment cost per member, based on full capacity. Return the name of the class type that has the highest equipment cost per person, based on full capacity.
-- Explanation: 
-- First i calculate the cost per equipment of based on capacity. Then i just divide the cost per equipment with the capacity of each class to find the class with the highest cost based on full capacity.
-- Answer: "Running"
-- Eva
with EquipmentCost as (
    select t.name, sum(n.quantity*e.price)/t.capacity as "Cost per member"
    from type t
        join needs n on n.tid = t.id
        join equipment e on e.id = n.eid
    group by t.name, t.capacity
)

select ec.name
from EquipmentCost ec
where "Cost per member" = (
    select max(ec."Cost per member")
    from EquipmentCost ec
);

-- K (BONUS). The hacker revealed in query C has left a message for the database engineers. This message may save the database!
-- Return the 5th letter of all members that started the gym on December 24th of any year and have at least 3 different odd numbers in their phone number, in a descending order of their IDs,
-- followed by the 8th letter of all instructors that have not led any "Trampoline Burn" classes, in an ascending order of their IDs.
-- Explanation: 
-- The best way to find this is to break this down into small parts, first i make a query to extract the fifth letter of the members' names who started on dec 24th, and i wrote a 
-- function (first in python, then asked chat to help me convert to psql) to keep track of phone numbers which meet the criteria. Then i make a query that fulfills the criteria about the 
-- instructors, and lastly join those two together.
-- Answer: 'Bring me ten barrels of Skyr before dawn or i destroy the database' 

create or replace function ThreeUniqueDigits(phone int) returns boolean as $$
declare digit int;

odd_nums int [] := '{}';

begin for i in 1..length(phone::text) loop digit := substring(phone::text, i, 1)::int;

if digit % 2 = 1
and not (digit = any(odd_nums)) then odd_nums := array_append(odd_nums, digit);

end if;

if array_length(odd_nums, 1) = 3 then return true;

end if;

end loop;

return false;

end;

$$ LANGUAGE plpgsql;

(
    select substring(m.name, 5, 1) as FifthLetter
    from Member m
    where extract(
            month
            from m.start_date
        ) = 12
        and extract(
            day
            from m.start_date
        ) = 24
        and ThreeUniqueDigits(m.phone)
    order by m.ID desc
)
union all
(
    select substring(i.name, 8, 1) as EighthLetter
    from Instructor i
    where not exists (
            select *
            from Class c
                join type t on c.TID = t.ID
            where c.IID = i.ID
                and lower(t.name) = 'trampoline burn'
        )
    order by i.ID asc
);