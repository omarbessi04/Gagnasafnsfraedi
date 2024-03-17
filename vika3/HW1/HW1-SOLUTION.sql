-- HW1
-- Student names: SOLUTION


-- A. How much does the most expensive equipment cost? Return only the price.

SELECT max(E.price)
FROM Equipment E;

-- B. 792 members have started the gym in April (of any year). How many members have started the gym in January (of any year)?

SELECT count(M.ID)
FROM Member M
WHERE extract(month FROM M.start_date) = 1;

-- C. 154 classes were held with ‘burn’ somewhere in their type name. How many classes were held that 
-- have ‘fit’ somewhere in their type name? (Note that your query should be case-insensitive, 
-- i.e. classes with ‘fiT’ and ‘Fit’ in their type name should also be counted).

SELECT count(*)
FROM Class C 
JOIN Type T ON T.ID = C.TID 
WHERE lower(T.name) LIKE '%fit%';

-- D. How many different instructors have led at least one class in which a member that they have in personal training attended?

SELECT count(DISTINCT C.IID)
FROM Class C 
JOIN Attends A ON C.ID = A.CID
JOIN Member M ON A.MID = M.ID
WHERE C.IID = M.IID;

-- E. Return the name of every class type along with the average rating that all classes of the type have received. 
-- The result should be rounded to the nearest integer and ordered from highest to lowest. 
-- Name the column with the average rating “Average Rating”.

SELECT T.name, round(avg(A.rating)) as "Average rating"
FROM Type T
JOIN Class C ON T.ID = C.TID
JOIN Attends A ON A.CID = C.ID 
GROUP BY T.name
ORDER BY "Average rating" DESC;

-- F. How many members have not attended any classes and do not have a personal instructor?

SELECT count(*)
FROM Member M 
WHERE M.ID not in (
    SELECT A.MID
    FROM Attends A
)
AND M.IID IS NULL;

-- G. 43 instructors have led 15 or more classes. How many instructors have led 10 or more classes?

SELECT count(*)
FROM (
    SELECT C.IID
    FROM Class C
    GROUP BY C.IID
    HAVING count(*) >= 10
)X;

-- H. For how many members is it true that there exists at least one other member with the same start date and quit date as them? 
-- (Note that if that is true for John and Mary, they should be counted as two results.
-- Note also that two people that have not quit cannot be considered as having the same quit date.).

SELECT count(DISTINCT M1.ID)
FROM Member M1
JOIN Member M2 ON M1.start_date = M2.start_date 
AND M1.quit_date = M2.quit_date
WHERE M1.ID <> M2.ID;

--I. How many classes were held in gyms in Reykjavik and have a capacity of either 30 or 40 people, but the capacity was not used fully?

SELECT count(*)
FROM (
    SELECT C.ID
    FROM Attends A 
    JOIN Class C ON A.CID = C.ID 
    JOIN Type T ON T.ID = C.TID
    JOIN Gym G ON C.GID = G.ID
    WHERE (T.capacity = 30 or T.capacity = 40) AND G.address LIKE '%Reykjavik'
    GROUP BY C.ID, T.capacity
    HAVING count(A.MID) < T.capacity
)X;

-- J. Return the ID and name of the member(s) that attended classes for the longest total time (in minutes) of all members?

SELECT M.ID, M.name
FROM Member M
JOIN Attends A ON A.MID = M.ID
JOIN Class C ON A.CID = C.ID
GROUP BY M.ID
HAVING sum(C.minutes) = (
    SELECT max(C) 
    FROM (
        SELECT sum(C.minutes) as C
        FROM Class C
        JOIN Attends A ON A.CID = C.ID
        GROUP BY A.MID )X
);