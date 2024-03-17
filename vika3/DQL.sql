-- (C) Björn Þór Jónsson & Hildur Davíðsdóttir, 2024
-- SQL part II
















-- GROUP BY

-- Ex1: How many countries are there in each continent?

SELECT C.continent, count(*)
FROM Continent C
JOIN IsIn I on I.continent = C.continent
GROUP BY C.continent;

-- For reference: We see that there are in fact 47 countries in Europe
SELECT C.name --count(*)
FROM IsIn I
JOIN Country C on C.Code = I.CountryCode
WHERE I.continent = 'Europe';
















-- JOIN

-- Structure: Give tables aliases, specify join condition, i.e. on which columns we want to attach the tables

SELECT CY.name, C.name
FROM City CY
JOIN Country C ON C.code = CY.countrycode;


-- INNER JOIN: All records that are both countries and cities (e.g. Mexico) - Default join
-- A AND B (INTERSECTION)
SELECT C.name, CY.name
FROM Country C
JOIN City CY ON CY.name = C.name;



-- LEFT JOIN: All records that are either countries, or countries and cities, but not records that are only cities (e.g. Germany og Mexico, but not Reykjavík)
-- A

SELECT C.name, CY.name
FROM Country C
LEFT JOIN City CY ON CY.name = C.name;


-- LEFT JOIN without intersection: All records that are countries but not cities (e.g. Germany, but not Mexico) 
-- A - B (EXCEPT)

SELECT C.name, CY.name
FROM Country C
LEFT JOIN City CY ON CY.name = C.name
WHERE CY.name IS NULL;


-- FULL OUTER JOIN: All records that are either countries or cities, or both (e.g. Germany, Reykjavík og Mexico)
-- A OR B (UNION)

SELECT C.name, CY.name
FROM Country C
FULL OUTER JOIN City CY ON CY.name = C.name;


-- FULL OUTER JOIN without intersection: All records that are either countries or cities, bot not both (e.g. Germany and Reykjavík, but not Mexico)
-- A XOR B

SELECT C.name, CY.name
FROM Country C
FULL OUTER JOIN City CY ON CY.name = C.name
WHERE C.name is null or CY.name is null;


-- NATURAL JOIN: Lazy join. Glues together columns with the same name. Can return nonsense. Do not use! 
-- Both tables contain columns 'countrycode' and 'percentage'. Assuming = on countrycode is valid, but not percentage.

-- Countries who are equally much in some continent as some language is spoken there - very strange query...
SELECT *
FROM IsIn I
NATURAL JOIN Language L
WHERE L.Language = 'Spanish';


-- CROSS JOIN: No join condition, returns all combinations. No obvious use case in this database.
-- Joins every country with each city in Sweden (very random)
SELECT *
FROM City CY
CROSS JOIN Country C
WHERE CY.countrycode = 'SWE';

SELECT 239 * 15;

















-- SET OPERATIONS

-- UNION (OR): Countries that are bigger than a million km^2, countries that are in more than one continent, and countries that fulfill both criteria.

SELECT C.code
FROM Country C
WHERE C.surfacearea > 1000000
UNION --ALL
SELECT I.countrycode
FROM IsIn I
GROUP BY I.countrycode
HAVING count(*) > 1;

-- INTERSECT (AND): Countries that are both bigger than a million km^2 and are in more than one continent.

SELECT C.code
FROM Country C
WHERE C.surfacearea > 1000000
INTERSECT
SELECT I.countrycode
FROM IsIn I
GROUP BY I.countrycode
HAVING count(*) > 1;

-- Intersect, using JOIN
SELECT DISTINCT C.code
FROM Country C
JOIN IsIn I ON C.code = I.countrycode
WHERE C.surfacearea > 1000000
GROUP BY C.code
HAVING COUNT(I.countrycode) > 1;

-- EXCEPT (-): Countries that are bigger than a million km^2 but are not in more than one continent.

SELECT C.code
FROM Country C
WHERE C.surfacearea > 1000000
EXCEPT
SELECT I.countrycode
FROM IsIn I
GROUP BY I.countrycode
HAVING count(*) > 1;
















-- SUBQUERIES




-- Subqueries in SELECT 

-- Ex1: Number of cities per countries

-- Without subquery: Number of cities per countries that have cities 
SELECT 1.0 * count(*) / count(DISTINCT CY.countrycode) as numcities
FROM City CY;

-- vs.

-- With subquery: Number of cities per countries (regardless of whether the country has cities or not)
SELECT 1.0 * 
	(SELECT count(*) FROM City) / 
	(SELECT count(*) FROM Country) as numcities;

-- For reference: See countries with no cities
SELECT * 
FROM Country C 
WHERE C.code not in (
	SELECT CY.countrycode
	FROM City CY
);



-- Ex2: City's percentage of total urban population

SELECT CY.name, CY.population, (1.0 * CY.population / (SELECT sum(population) FROM City)) as percentage
FROM City CY
ORDER BY percentage






-- Subqueries in FROM 

-- Ex1: How many countries are in more than one continent?

SELECT count(*)                                -- count() in inner query shows how many rows were collapsed for each returned record
FROM (										   -- count() in outer query shows how many rows are returned in inner query
	SELECT C.code, count(*)
	FROM Country C
	JOIN IsIn I ON C.code = I.countrycode
	GROUP BY C.code
	HAVING count(*) > 1
)X;



-- Ex2: What is the average population per city?

-- Without subquery: Average population per city
SELECT avg(CY.population)
FROM City CY;

-- With subquery: Average of the average city populations of each country
-- E.g. Iceland has more weight here
SELECT avg(avgpop)
FROM (
	SELECT CY.countrycode, avg(CY.population) AS avgpop
	FROM City CY
	GROUP BY CY.countrycode
)X; 



-- Ex3:
-- For how many cities does there exists another city with the same name
SELECT sum(number)
FROM (
	SELECT CY.name, count(*) as number
	FROM City CY
	GROUP BY CY.name
	HAVING count(*) > 1
)X;

-- How many city names are repeated at least once?
SELECT count(*)
FROM (
	SELECT CY.name, count(*) as number
	FROM City CY
	GROUP BY CY.name
	HAVING count(*) > 1
)X;





--  WHERE

-- Ex1: Show all cities in countries where french is spoken
-- Zurich! (Zurich is in Switzerland (a french speaking country), but Zurich is in the German part of Switzerland!)
SELECT CY.ID, CY.name, CY.countrycode
FROM City CY
WHERE CY.countrycode IN (
	SELECT L.countrycode 
	FROM Language L
	WHERE L.language = 'French'
);



-- Ex2: Show all countries where no language is spoken (Database error? No habitants?)
SELECT C.code, C.name
FROM Country C
WHERE C.code NOT IN (
	SELECT L.countrycode
	FROM Language L
);

-- For reference: You can also do this with JOIN
SELECT C.code, C.name
FROM Country C
left join Language L on C.code = L.countrycode
where L.language IS NULL;



-- Ex3: For how many countries do the percentages add up to less than 100% ? 

-- For reference: Last week:
SELECT CL.countrycode, sum(CL.percentage)
FROM Language CL
GROUP BY CL.countrycode
HAVING sum(CL.percentage) > 100;

-- Nice try, but not quite correct.
-- There are two reasons for < 100 (Incomplete, Missing) (this query omits the countries that don't even appear in the Language table - The missing data)
-- 202 results
SELECT CL.countrycode, sum(CL.percentage)
FROM Language CL
GROUP BY CL.countrycode
HAVING sum(CL.percentage) < 100;

-- Here are all the countries that don't have language data
-- 6 results
SELECT C.code
FROM Country C
WHERE C.code not in (
	SELECT countrycode 
	FROM Language
);


-- Correct version:
-- 202 + 6 = 208 results
SELECT C.code
FROM Country C
EXCEPT
SELECT CL.countrycode
FROM Language CL
GROUP BY CL.countrycode
HAVING sum(CL.percentage) >= 100;

-- Also correct: (More readable?)
SELECT C.code						 -- Outer query: Everything else
FROM Country C
WHERE C.code not in (
	SELECT CL.countrycode			 -- Inner query: All the countries with >= 100 
	FROM Language CL
	GROUP BY CL.countrycode
	HAVING sum(CL.percentage) >= 100
);





-- IN vs. JOIN

SELECT C.code, C.name
FROM Country C
WHERE C.code IN (
	SELECT L.countrycode
	FROM Language L
);

SELECT DISTINCT C.code, C.name
FROM Country C
JOIN Language L ON C.code = L.countrycode;



-- EXISTS

-- Ex1: What cities are the only city in their country?
SELECT C1.name, C1.countrycode
FROM City C1
WHERE NOT EXISTS (
	SELECT C2.name as C2name
	FROM City C2 
	WHERE C2.countrycode = C1.countrycode 	-- correlation with the outer query
	AND C2.ID <> C1.ID 				
);

-- Cities that are not the only city in their country
SELECT C1.name, C1.countrycode
FROM City C1
WHERE EXISTS (
	SELECT C2.name as C2name
	FROM City C2 
	WHERE C2.countrycode = C1.countrycode 
	AND C2.ID <> C1.ID
);














-- COMMON PATTERNS: Self-JOIN


-- Ex1: Show all pairs of cities with the same population
SELECT CY1.name, CY1.population, CY2.name, CY2.population
FROM City CY1 
JOIN City CY2 ON CY1.population = CY2.population
WHERE CY1.ID <> CY2.ID; -- they cannot be the same city














-- COMMON PATTERNS: Extreme pattern


-- Ex1: What is the highest population in any country?
SELECT max(C.population)
FROM Country C;

-- Ok, but what country is that?

-- Logical try, but not possible
SELECT max(C.population), C.name
FROM Country C;

-- Correct way
SELECT C.population, C.name
FROM Country C 
WHERE C.population = (
	SELECT max(C.population) 
	FROM Country C
);

-- Extension: All countries within x% of the country with the highest population
SELECT C.population, C.name
FROM Country C 
WHERE C.population >= 0.1 * (
	SELECT max(C.population) 
	FROM Country C
);

-- What about the smallest population
SELECT C.population, C.name
FROM Country C 
WHERE C.population = (
	SELECT min(C.population) 
	FROM Country C
	WHERE C.population <> 0  --Add this condition if you don't want to count non-populated countries
);


-- Ex2: What countries have the most languages?
-- Solves ties elegantly
SELECT L.countrycode, count(*)
FROM Country C 
JOIN Language L on C.code = L.countrycode
GROUP BY L.countrycode
HAVING count(*) = (
	SELECT max(n_languages) 
	FROM (
		SELECT count(*) as n_languages
		FROM Country C 
		JOIN Language L on C.code = L.countrycode
		GROUP BY L.countrycode
	)X
);

-- LIMIT does not solve ties elegantly
SELECT L.countrycode, count(*)
FROM Country C 
JOIN Language L on C.code = L.countrycode
GROUP BY L.countrycode
ORDER BY count(*) DESC
LIMIT 6 			-- what if the 7th country is added?













-- COMMON PATTERNS: Division





-- Ex1: What language is spoken in all countries in the Danish Empire?


-- Step 1: Count the number of countries in the Danish empire
SELECT count(*)
FROM Empire E
WHERE E.empire = 'Danish Empire';

-- Intermediate step: Let's look at all language information in the Danish empire
SELECT *
FROM Language L
JOIN Empire E ON L.countrycode = E.countrycode
WHERE E.empire = 'Danish Empire';

-- Intermediate step: Now we group per language, i.e. how many countries speak each language in the empire
SELECT L.language, count(*)
FROM Language L
JOIN Empire E ON L.countrycode = E.countrycode
WHERE E.empire = 'Danish Empire'
GROUP BY L.language;

-- Step 2: For each language in the empire, return it only if it is related to that many countries
-- Very tempting to use a magic constant, but don't!
SELECT L.language, count(*)
FROM Language L
JOIN Empire E ON L.countrycode = E.countrycode
WHERE E.empire = 'Danish Empire'
GROUP BY L.language
HAVING count(*) = (
	SELECT count(*)
	FROM Empire E
	WHERE E.empire = 'Danish Empire'
);

-- What about the Benelux empire?
SELECT L.language, count(*)
FROM Language L
JOIN Empire E ON L.countrycode = E.countrycode
WHERE E.empire = 'Benelux'
GROUP BY L.language
HAVING count(*) = (
	SELECT count(*)
	FROM Empire E
	WHERE E.empire = 'Benelux'
);



-- With double negation
-- All languages for which there is *no* country in the Danish Empire that does *not* speak that language
SELECT DISTINCT L.language
FROM Language L
WHERE NOT EXISTS (
	SELECT E.countrycode
	FROM Empire E
	WHERE E.empire = 'Danish Empire'
	AND NOT EXISTS (
		SELECT * 
		FROM Language L1
		WHERE E.empire = 'Danish Empire'
		AND L.language = L1.language
		AND L1.countrycode = E.countrycode
	)
)




-- Ex2: Division example in which we need to use DISTINCT

-- Which languages are spoken in all continents (that have language data)?

-- Step 1: Count the number of continents that have language data
SELECT count(DISTINCT I.continent)
FROM IsIn I
JOIN Language L ON L.countrycode = I.countrycode;

-- Step 2: For each language, return it only if it is related to that many continents
SELECT L.language, count(DISTINCT I.continent)
FROM Language L
JOIN IsIn I ON L.countrycode = I.countrycode
GROUP BY L.language
HAVING count(DISTINCT I.continent) = (
	SELECT count(DISTINCT I.continent)
	FROM IsIn I 
	JOIN Language L ON L.countrycode = I.countrycode
);

-- For reference: Really German?
SELECT *
FROM IsIn I 
JOIN Language L ON L.countrycode = I.countrycode
WHERE L.language = 'German';


   






-- VIEWS


-- Ex1: Urban population revisited
DROP VIEW IF EXISTS urbanpopulation;
CREATE VIEW urbanpopulation
AS
SELECT CY.countrycode, sum(CY.population) AS urbanpopulation 
FROM City CY
GROUP BY CY.countrycode;

SELECT *
FROM urbanpopulation UP
WHERE UP.urbanpopulation = (
	SELECT max(urbanpopulation) 
	FROM urbanpopulation
);



-- Ex2: Population ration between pairs of cities in the same country
DROP VIEW IF EXISTS populationratio;
CREATE VIEW populationratio
AS
SELECT CY1.name AS id1, CY2.name AS id2, 1.0 * CY1.population / CY2.population AS ratio
FROM City CY1
JOIN City CY2 ON CY1.countrycode = CY2.countrycode;
	
SELECT PR.id1, PR.id2
FROM populationratio PR
WHERE PR.ratio = (SELECT max(ratio) FROM populationratio);