```sql
--netflix_project--
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

--Business Problems and Solutions

--Question 1 Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;


-- 2. Find the most common rating for movies and TV shows

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


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;


-- 6. Find content added in the last 5 years

SELECT
    *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
)
WHERE director_name = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
    TYPE = 'TV Show'
    AND
    SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 9. Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release by India on netflix.
-- return top 5 year with highest avg content release !

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) 
         FROM netflix 
         WHERE country = 'India')::numeric * 100,
        2
    ) AS avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;


-- 11. List all movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';


-- 12. Find all content without a director

SELECT * 
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'
    AND 
    release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
    category,
    TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN description ILIKE '%kill%' 
              OR description ILIKE '%violence%' 
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;


-- 16. Find the number of movies released in each year

SELECT 
    release_year,
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
GROUP BY release_year
ORDER BY release_year DESC;


-- 17. Find the number of TV shows released in each year

SELECT 
    release_year,
    COUNT(*) AS total_tv_shows
FROM netflix
WHERE type = 'TV Show'
GROUP BY release_year
ORDER BY release_year DESC;


-- 18. Find the year with the highest number of Netflix content releases

SELECT 
    release_year,
    COUNT(*) AS total_content
FROM netflix
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 1;


-- 19. Find the top 10 years with the highest number of content releases

SELECT 
    release_year,
    COUNT(*) AS total_content
FROM netflix
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 10;


-- 20. Find the number of movies and TV shows added each year

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
    type,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY 1,2
ORDER BY 1 DESC;


-- 21. Find the number of content added each month

SELECT 
    EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_month,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- 22. Find the oldest movie available on Netflix

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY release_year ASC
LIMIT 1;


-- 23. Find the newest movie available on Netflix

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY release_year DESC
LIMIT 1;


-- 24. Find the oldest TV show available on Netflix

SELECT *
FROM netflix
WHERE type = 'TV Show'
ORDER BY release_year ASC
LIMIT 1;


-- 25. Find the newest TV show available on Netflix

SELECT *
FROM netflix
WHERE type = 'TV Show'
ORDER BY release_year DESC
LIMIT 1;


-- 26. Find all movies having duration greater than 120 minutes

SELECT *
FROM netflix
WHERE 
    type = 'Movie'
    AND SPLIT_PART(duration, ' ', 1)::INT > 120;


-- 27. Find all movies having duration between 90 and 120 minutes

SELECT *
FROM netflix
WHERE 
    type = 'Movie'
    AND SPLIT_PART(duration, ' ', 1)::INT BETWEEN 90 AND 120;


-- 28. Find the average movie duration

SELECT 
    ROUND(
        AVG(SPLIT_PART(duration, ' ', 1)::INT),
        2
    ) AS average_movie_duration
FROM netflix
WHERE type = 'Movie';


-- 29. Find the maximum number of seasons in a TV show

SELECT 
    MAX(SPLIT_PART(duration, ' ', 1)::INT) AS maximum_seasons
FROM netflix
WHERE type = 'TV Show';


-- 30. Find the average number of seasons for TV shows

SELECT 
    ROUND(
        AVG(SPLIT_PART(duration, ' ', 1)::INT),
        2
    ) AS average_seasons
FROM netflix
WHERE type = 'TV Show';


-- 31. Find the top 10 most common ratings

SELECT 
    rating,
    COUNT(*) AS total_content
FROM netflix
GROUP BY rating
ORDER BY total_content DESC
LIMIT 10;


-- 32. Find the number of movies under each rating

SELECT 
    rating,
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
GROUP BY rating
ORDER BY total_movies DESC;


-- 33. Find the number of TV shows under each rating

SELECT 
    rating,
    COUNT(*) AS total_tv_shows
FROM netflix
WHERE type = 'TV Show'
GROUP BY rating
ORDER BY total_tv_shows DESC;


-- 34. Find all content rated 'TV-MA'

SELECT *
FROM netflix
WHERE rating = 'TV-MA';


-- 35. Find all movies rated 'PG-13'

SELECT *
FROM netflix
WHERE 
    type = 'Movie'
    AND rating = 'PG-13';


-- 36. Find directors who have directed more than 5 titles

SELECT 
    director,
    COUNT(*) AS total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
HAVING COUNT(*) > 5
ORDER BY total_content DESC;


-- 37. Find the top 10 directors with the highest number of titles

SELECT 
    director,
    COUNT(*) AS total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 10;


-- 38. Find the top 10 countries producing the most movies

SELECT 
    TRIM(country_name) AS country,
    COUNT(*) AS total_movies
FROM netflix,
     UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
WHERE type = 'Movie'
GROUP BY 1
ORDER BY total_movies DESC
LIMIT 10;


-- 39. Find the top 10 countries producing the most TV shows

SELECT 
    TRIM(country_name) AS country,
    COUNT(*) AS total_tv_shows
FROM netflix,
     UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
WHERE type = 'TV Show'
GROUP BY 1
ORDER BY total_tv_shows DESC
LIMIT 10;


-- 40. Find all content produced in India

SELECT *
FROM netflix
WHERE country ILIKE '%India%';


-- 41. Count the total content produced in India

SELECT 
    COUNT(*) AS total_indian_content
FROM netflix
WHERE country ILIKE '%India%';


-- 42. Find Indian content released after 2015

SELECT *
FROM netflix
WHERE 
    country ILIKE '%India%'
    AND release_year > 2015
ORDER BY release_year DESC;


-- 43. Find the top 10 genres with the highest content

SELECT 
    TRIM(genre) AS genre,
    COUNT(*) AS total_content
FROM netflix,
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY 1
ORDER BY total_content DESC
LIMIT 10;


-- 44. Find all content belonging to the 'Comedies' genre

SELECT *
FROM netflix
WHERE listed_in ILIKE '%Comedies%';


-- 45. Find all content belonging to the 'Dramas' genre

SELECT *
FROM netflix
WHERE listed_in ILIKE '%Dramas%';


-- 46. Find the most common genre for movies

SELECT 
    TRIM(genre) AS genre,
    COUNT(*) AS total_movies
FROM netflix,
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
WHERE type = 'Movie'
GROUP BY 1
ORDER BY total_movies DESC
LIMIT 1;


-- 47. Find the most common genre for TV shows

SELECT 
    TRIM(genre) AS genre,
    COUNT(*) AS total_tv_shows
FROM netflix,
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
WHERE type = 'TV Show'
GROUP BY 1
ORDER BY total_tv_shows DESC
LIMIT 1;


-- 48. Find content with the word 'love' in the description

SELECT *
FROM netflix
WHERE description ILIKE '%love%';


-- 49. Find content with the word 'school' in the description

SELECT *
FROM netflix
WHERE description ILIKE '%school%';


-- 50. Find the percentage of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::numeric /
        (SELECT COUNT(*) FROM netflix)::numeric * 100,
        2
    ) AS percentage
FROM netflix
GROUP BY type
ORDER BY percentage DESC;

```
