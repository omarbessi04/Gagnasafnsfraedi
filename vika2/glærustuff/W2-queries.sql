-- (C) Björn Þór Jónsson, 2023

-- Week 2: SQL I

-- 3

-- omar
select *
from countries
where population > 100000
order by surfacearea desc;

select *
from cities
where countrycode = 'DNK';

-- 7

select lower(CY.name), CY.population * CY.ID as "weird number", *
from cities CY
where CY.name like '%''%';

-- 8

select *
from cities;

select 1 as Query
from cities;

select 1 as Query;

-- 10

select *
from cities CY
where CY.district = CY.name;

select *
from countries C
where C.name = 'Denmark';

select C.code, C.name, C.region, 1.0*C.population/C.surfacearea as populationdensity
from countries C;

select C.code, C.name, C.region, 1.0*C.population/C.surfacearea as populationdensity
from countries C
order by populationdensity asc;

select *
from countries C
where C.population = 0;

select *
from countries C
where C.population > 0
	and C.lifeexpectancy is null;

-- 11

select *
from cities 
order by countrycode asc, population desc

select *
from cities 
order by population desc
limit 10

-- 13

select C.name, CL.language, CL.percentage * C.population / 100.0
from countries C
	join countries_languages CL on C.code = CL.countrycode;

-- 14

select CC.continent, CL.language, CL.percentage * C.population / 100.0
from countries C
	join countries_languages CL on C.code = CL.countrycode
	join countries_continents CC on C.code = CC.countrycode;

-- 16

select *
from countries C
	join countries_languages CL 
	on C.code = CL.countrycode;

select *
from countries C, countries_languages CL 
where C.code = CL.countrycode;

select *
from countries C
	join countries_languages CL;

select *
from countries C, countries_languages CL;

-- 17

select *
from cities CY 
	join countries C on CY.countrycode = C.code
where C.name = 'Denmark';

select *
from cities CY 
	join countries C on CY.countrycode = C.code
	join empires E on C.code = E.countrycode
where E.empire = 'Danish Empire';

select *
from cities CY 
	join empires E on CY.countrycode = E.countrycode
where E.empire = 'Danish Empire';

select C.name, CY.name, round(100.0*CY.population/C.population) as populationratio
from countries C
	join cities CY on C.Code = CY.countryCode
where C.population > 1000000
order by populationratio desc;

select C.name, CL.language
from countries C
	join countries_languages CL on C.code = CL.countrycode
where CL.language = 'Danish';

select CC.continent, CL.language
from countries C
	join countries_continents CC on C.code = CC.countrycode
	join countries_languages CL on C.code = CL.countrycode
where CL.language = 'Danish';

select CC.continent, CL.language
from countries_continents CC
	join countries_languages CL on CC.countrycode = CL.countrycode
where CL.language = 'Danish';

-- 19

select distinct CC.continent, CL.language -- removes duplicates
from countries_continents CC
	join countries_languages CL on CC.countrycode = CL.countrycode
where CL.language = 'Danish';

select C.region
from countries C;

select distinct C.region -- removes duplicates
from countries C;

select CC.continent, C.region
from countries C
	join countries_continents CC on C.code = CC.countrycode;

select distinct CC.continent, C.region -- removes duplicates
from countries C
	join countries_continents CC on C.code = CC.countrycode;

select C.code2
from countries C;

select distinct C.code2 -- no difference!
from countries C;

select *
from countries_languages CL;

select C.name, CL.language, 1.0*CL.percentage*C.population
from countries_languages CL
	join countries C on CL.countrycode = C.code;

select distinct C.name, CL.language, 1.0*CL.percentage*C.population -- no difference!
from countries_languages CL
	join countries C on CL.countrycode = C.code;

select distinct C.name, CL.language, 1.0*CL.percentage*C.population -- no difference!
from countries_languages CL
	join countries C on CL.countrycode = C.code;

-- 23

select count(*)
from countries C;

select count(*), count(distinct population)
from countries;

select count(lifeexpectancy)
from countries C;

select avg(lifeexpectancy)
from countries C;

select avg(lifeexpectancy), sum(1.0 * C.lifeexpectancy * C.population) / sum(1.0 * C.population)
from countries C;

select 
	percentile_disc(0.9) within group (order by C.population),
	percentile_cont(0.9) within group (order by C.population)
from countries C;

select sum(CY.population)
from cities CY
	join countries C on C.code = CY.countrycode
where C.name = 'Denmark';

-- 25

select C.code, C.name, sum(CY.population) as urbanpopulation
from cities CY
	join countries C on C.code = CY.countrycode
group by C.code, C.name;

select CC.continent, CL.language, sum(CL.percentage * C.population / 100.0) as population
from countries C
	join countries_languages CL on C.Code = CL.CountryCode
	join countries_continents CC on CC.CountryCode = C.Code
group by CC.continent, CL.language
order by CC.continent, population desc;

-- 27

select C.code, C.name, sum(CY.population) as urbanpopulation
from cities CY
	join countries C on C.code = CY.countrycode
group by C.code;

select C.code, C.name, sum(CY.population) as urbanpopulation
from cities CY
	join countries C on C.code = CY.countrycode
group by CY.countrycode;

select C.code, C.name, sum(CY.population) as urbanpopulation, C.population as countrypopulation
from cities CY
	join countries C on C.code = CY.countrycode
group by C.code;

-- 29

select C.code, C.name, sum(CY.population) as urbanpopulation
from cities CY
	join countries C on C.code = CY.countrycode
group by C.code, C.name
having count(*) > 5;

-- 32

select countrycode, sum(population)
from cities
group by countrycode
having count(*) > 5
order by countrycode

-- 35

select C.code, C.name
from countries C
	join countries_continents CC on C.code = CC.countrycode
group by C.code
having count(*) > 1;

select distinct C.code, C.name
from countries C
	join countries_continents CC on C.code = CC.countrycode
where CC.percentage < 100;

select C.code, C.name
from countries C
	join countries_continents CC on C.code = CC.countrycode
where CC.percentage < 100 
	and CC.continent = 'Europe';

select C.name
from cities CY
	join countries C on CY.countrycode = C.code
where CY.population > C.population;

select count(*)
from cities CY
	join countries C on CY.countrycode = C.code
where CY.population <= 0.01 * C.population;

select count(*)
from cities CI 
	join countries CO on CI.CountryCode = CO.Code
where CY.population > 0.5 * C.population;

select C.name
from countries C
	join countries_languages CL on CL.countrycode = C.code
group by C.code
having sum(CL.percentage) > 100;

select sum(C.population * CL.percentage / 100.0)
from countries C
	join countries_continents CC on C.code = CC.countrycode
	join countries_languages CL on C.code = CL.countrycode
where C.population > 1000000
	and CC.continent = 'North America'
	and CL.language = 'Spanish';

select sum(C.population * CL.percentage / 100.0)
from countries C
	join countries_continents CC on C.code = CC.countrycode
	join countries_languages CL on C.code = CL.countrycode
where C.population > 1000000
	and CC.continent = 'South America'
	and CL.language = 'Spanish';

--
