-- Query 2

SELECT NOW();

SELECT COUNT(*)
FROM Results R INNER JOIN People P 
        ON R.peopleID = P.ID
WHERE P.name = 'Kent Lauridsen';

SELECT NOW();
