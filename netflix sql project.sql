drop table if exists netflix
create table netflix (
show_id varchar(5),
type varchar (20),
title varchar (250),
director varchar (550),
casts varchar(1050),
country varchar (550),
date_added varchar (50),
release_year int,
rating varchar (50),
duration varchar (50),
listed_in varchar (250),
description varchar (550)
);
selecT * FROM NETFLIX
-- Count the Number of Movies vs Tv Shows
select type, count (*) from netflix group by 1;
-- Find the most Common Rating for Movies and Tv Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
-- List of all movies Releses in 2020
select * from netflix 
where release_year =2020;
--Identify the longest Movie
select * from netflix 
where type = 'Movie' and duration is not null
order by split_part(duration, ' ', 1):: int desc 
limit 1;
-- Find Content Added in the Last 2 Years
Select * from netflix where to_date(date_added, 'Month DD, yyyy') >= current_date - Interval '5years';
-- Find all movies/ TV shows by director 'Rajiv Chilaka'
select * from netflix  where
director = 'Rajiv Chilaka';
--List all TV shows with more than Seasons
select * from netflix 
where type = 'TV Show' 
and split_part(duration, ' ', 1) :: INT > 5;
-- Count the number of content items in each genre
select unnest(string_to_array(listed_in, ' , ')) as genre, count (*) as total_content from netflix group 
by 1;
-- Find each year and the average numvers of content release in India on netflix.
select country, release_year, count (show_id) as total_release,
round( count (show_id) :: numeric/ (select count (show_id) from netflix where country = 'India')
:: numeric * 100, 2)
avg_release from netflix 
where country = 'India'
group by country, release_year
order by avg_release desc limit 5;
-- List all movies that are documentaries
select * from netflix
where listed_in like '%Documentaries';
--Find all content without a Director
select * from netflix 
where Director is null;
-- Find the movies where slaman khan appeared as actor in the last 10 years
select * from netflix where casts
like '%Salman Khan%' and release_year > extract(year from current_date) - 10;
-- Find the Top 10 Actors who have appeared in the highest number of movies produced in United States
select unnest (string_to_array(casts, ' , ')) as actor,
count (*) from netflix
where country = 'United States'
group by actor 
order by count (*) desc limit 10;
-- Categorize content Based on the presence of 'Kill' and ' Violence' keywords
select category, count(*) as content_count
from ( select case
when description like '%Kill%' or description like '%violence' then 'Bad' Else 'Good' end as category
from netflix) as categorized_content group by category;