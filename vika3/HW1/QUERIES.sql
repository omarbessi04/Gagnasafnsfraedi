-- HW1
-- Student names: Eva Natalía Elvarsdóttir & Ómar Bessi Ómarsson
-- (Leyfi frá Huldu að vera tvö í hóp)

-- A. How much does the most expensive equipment cost? Return only the price.

-- Explanation: 
-- We use the max() function on the equipment's price to find the most expensive equipment.

select max(e.price) as "Max Price"
from Equipment e;


-- B. 792 members have started the gym in April (of any year). How many members have started the gym in January (of any year)?

-- Explanation: 
-- By using the extract function on m.start_date, we can focus on the month. 
-- We then count() every occurence where the month is equal to 1

select count(m.start_date) as "Month count"
from Member m
where extract(month from m.start_date) = 1;


-- C. 154 classes were held with ‘burn’ somewhere in their type name. How many classes were held that 
-- have ‘fit’ somewhere in their type name? (Note that your query should be case-insensitive, 
-- i.e. classes with ‘fiT’ and ‘Fit’ in their type name should also be counted).

-- Explanation: 
-- We first filter all the types that have the word "fit" in them and then use the count() function on the type id.

select count(t.id) as "Class count"
from Class c
    join Type t on c.tid = t.id
    where lower(t.name) like '%fit%';


-- D. How many different instructors have led at least one class in which a member that they have in personal training attended?

-- Explanation: 
-- By using the attends, class, and member tables, we can see which member is being trained by what coach and attenting which class(es).
-- We then check where the class instructor ids and the member instructor ids match up.
-- (NULL is always unique, so if both fields are NULL, "c.iid = m.iid" will not be true)

select count(distinct c.iid) as "Distinct instructor count"
from Attends a 
    join Class c on c.id = a.cid
    join Member m on m.id = a.mid
where c.iid = m.iid;


-- E. Return the name of every class type along with the average rating that all classes of the type have received. 
-- The result should be rounded to the nearest integer and ordered from highest to lowest. 
-- Name the column with the average rating “Average Rating”.

-- Explanation: 
-- By connecting the attends and type tables to the class table we can connect the type name with the ratings.
-- We start by selecting distinct t.name so the type only appears once.
-- Then utilizing the avg() function to calculate the average rating of that type as well as rounding it to the nearest int.

select distinct t.name, round(avg(a.rating)) as "Average Rating"
from Class c
    join Attends a on a.cid = c.id
    join Type t on t.id = c.tid
group by t.id
order by "Average Rating" DESC;


-- F. How many members have not attended any classes and do not have a personal instructor?

-- Explanation: 
-- We select from the Member table and then left join on the Attends table to remove all members who have attended a class
-- From that group we select only those who do not have an instuctor assigned to them (and double check on the classes).

select count(distinct m.id) as "Member count"
from Member m
    left join Attends a on m.id = a.mid
where m.iid is null and a.mid is null;


-- G. 43 instructors have led 15 or more classes. How many instructors have led 10 or more classes?

-- Explanation: 
-- We start by making a subquery where we connect the instructor and class tables and use the count() function to check the instructor's amount of classes.
-- We then filter those who have taught 10 or more classes.
-- We end up by counting the instances in this subquery with the trusty dusty count() function.

select count(*) as "Instructor count"
from (
    select distinct i.id, count(c.id) as "Classes count"
    from Instructor i
        join Class c on c.iid = i.id
    group by i.id
    having count(c.id) >= 10
    );

-- H. For how many members is it true that there exists at least one other member with the same start date and quit date as them? 
-- (Note that if that is true for John and Mary, they should be counted as two results.
-- Note also that two people that have not quit cannot be considered as having the same quit date.).

-- Explanation: 
-- We self join the Member table with itself on matching start/quit dates where the id's are not the same

select count(distinct m.id) as "Member count"
from Member m 
    join Member m2 on m.start_date = m2.start_date and m.quit_date = m2.quit_date
    where m.id <> m2.id;


--I. How many classes were held in gyms in Reykjavik and have a capacity of either 30 or 40 people, but the capacity was not used fully?

-- Explanation: 
-- We start by making a subquery where we connect the attends, class, gym, and type tables and filter gym addresses that are in "Reykjavik".
-- We also filter class types that have capacity of either 30 or 40 and then count the members in each class and check for the ones that were not used fully.
-- We end up by counting the instances in this subquery with the MIGHTY count() function.


select count(*) as "Class count"
from (
    select distinct c.id, t.capacity, count(distinct a.mid)
    from Attends a
        join Class c on a.cid = c.id
        join Gym g on c.gid = g.id
        join Type t on c.tid = t.id
        where g.address like '%Reykjavik%' and ((t.capacity = 30) or (t.capacity = 40))
        group by c.id, t.capacity
        having count(a.mid) < t.capacity
    );


-- J. Return the ID and name of the member(s) that attended classes for the longest total time (in minutes) of all members?

-- Explanation:
-- Using the "with" functionality, we can give a subquery a name.
-- We name the subquery that finds all members and ranks them by most amount of minutes "BestMinutes"
-- Using that subquery with the max() function, we can find all members with the most amount of class minutes

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
