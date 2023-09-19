Select * from moviestmdb;
commit;

-- Standardize date

Select release_date, CAST(release_date AS date)
from moviestmdb;

ALTER TABLE moviestmdb
ADD COLUMN release_date2 DATE AFTER title;

UPDATE IGNORE moviestmdb
SET release_date2 = CAST(release_date AS date);

ALTER TABLE moviestmdb
DROP COLUMN release_date;

ALTER TABLE moviestmdb
RENAME COLUMN release_date2
TO release_date;

-- Observing Movies with Budget and Revenue Data

SELECT id, title, genres, budget, revenue
from moviestmdb 
WHERE REVENUE != 0
AND BUDGET != 0;

-- Standardizing the genres field

Select distinct(genres), count(genres) as num_genres
from moviestmdb
group by genres
order by num_genres desc;

SELECT genres, SUBSTRING(genres, 2, INSTR(genres, ',') -2) as multiple_genres, SUBSTRING(genres, 2, INSTR(genres, ']') -2) as single_genre
from moviestmdb;

Select genres
, CASE WHEN genres like '[%,%]' THEN SUBSTRING(genres, 2, INSTR(genres, ',') -2)
		WHEN genres not like '[%,%]' THEN SUBSTRING(genres, 2, INSTR(genres, ']') -2)
        ELSE genres
        END
FROM moviestmdb;

select genres
from moviestmdb
where genres not like '[%,%]';

UPDATE moviestmdb
SET genres = CASE WHEN genres like '[%,%]' THEN SUBSTRING(genres, 2, INSTR(genres, ',') -2)
		WHEN genres not like '[%,%]' THEN SUBSTRING(genres, 2, INSTR(genres, ']') -2)
        ELSE genres
        END;

-- What genre brings in the most revenue 1 

Select genres, avg(revenue)
from moviestmdb
where revenue != 0
group by genres
order by avg(revenue) desc;

-- Overall trend in movie revenue over the past century 2

Select title, release_date, revenue
from moviestmdb
where revenue != 0
order by release_date;

-- Overall trend in movie revenue over the past decade 3

Select title, release_date, revenue
from moviestmdb
where revenue != 0
and release_date >= '2013-01-01'
order by release_date;

-- Genre with the highest average rating among audiences 4

Select genres, round(avg(vote_average), 2) as vote_rating
from moviestmdb
where genres != ''
group by genres
order by vote_rating desc;

-- How does movie budget correlate with its box office revnue? 5

Select title, budget, revenue
from moviestmdb
Where revenue != 0
and budget != 0
order by 2,3;

-- Compare net profits with runtime are they correlated? Are revenue and runtime correlated? 6

Select title, (revenue - budget) as net_profit, revenue, runtime
from moviestmdb
where budget != 0
and revenue != 0
order by 2 desc;

Select title, revenue, runtime
from moviestmdb
where budget != 0
and revenue != 0
order by 4 desc;

-- Seasons vs Movie Performance 7

Select release_date,
	Case 
    When release_date like '%-12-%' then 'Winter'
	When release_date like '%-01-%' then 'Winter'
    When release_date like '%-02-%' then 'Winter'
    When release_date like '%-03-%' then 'Spring'
    When release_date like '%-04-%' then 'Spring'
    When release_date like '%-05-%' then 'Spring'
    When release_date like '%-06-%' then 'Summer'
    When release_date like '%-07-%' then 'Summer'
    When release_date like '%-08-%' then 'Summer'
    When release_date like '%-09-%' then 'Fall'
    When release_date like '%-10-%' then 'Fall'
    When release_date like '%-11-%' then 'Fall'
	else release_date
end as season
from moviestmdb;

ALTER TABLE moviestmdb
ADD COLUMN season varchar(8) AFTER release_date;

UPDATE IGNORE moviestmdb
SET season = Case 
    When release_date like '%-12-%' then 'Winter'
	When release_date like '%-01-%' then 'Winter'
    When release_date like '%-02-%' then 'Winter'
    When release_date like '%-03-%' then 'Spring'
    When release_date like '%-04-%' then 'Spring'
    When release_date like '%-05-%' then 'Spring'
    When release_date like '%-06-%' then 'Summer'
    When release_date like '%-07-%' then 'Summer'
    When release_date like '%-08-%' then 'Summer'
    When release_date like '%-09-%' then 'Fall'
    When release_date like '%-10-%' then 'Fall'
    When release_date like '%-11-%' then 'Fall'
	else release_date
end;

Select *
from moviestmdb
Where release_date like '0000-00-00';

Delete from moviestmdb
WHERE release_date like '0000-00-00';

Select title, season, revenue, vote_average
from moviestmdb
where revenue != 0
order by 2,3 desc;

Select season, round(avg(revenue), 2) as revenue, round(avg(vote_average), 2) as rating
from moviestmdb
where revenue != 0
group by season
order by avg(revenue) desc, rating desc;

-- How many movies do not have any data relating to budget, revenue or both

Select title, release_date, budget, revenue
from moviestmdb
where (budget = 0 and revenue != 0) or (budget != 0 and revenue = 0) 
order by release_date; 