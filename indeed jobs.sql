-- How many rows are in the data_analyst_jobs table?
-- 1793

SELECT COUNT(*)
AS number_of_rows
FROM data_analyst_jobs;

-- Write a query to look at just the first 10 rows. What company is associated with the job posting on the 10th row?
-- ExxonMobil

SELECT *
FROM data_analyst_jobs
LIMIT 10;

-- How many postings are in Tennessee? How many are there in either Tennessee or Kentucky?
-- 21 in TN, 27 in TN or KY

SELECT location
FROM data_analyst_jobs;

SELECT COUNT(location) AS tn_job_count
FROM data_analyst_jobs
WHERE location = 'TN';

SELECT COUNT(location) AS tn_ky_job_count
FROM data_analyst_jobs
WHERE location ='TN' OR location ='KY';

-- How many postings in Tennessee have a star rating above 4?
-- 3

SELECT COUNT(location) AS tn_4_star
FROM data_analyst_jobs
WHERE location = 'TN' AND star_rating >4;

-- How many postings in the dataset have a review count between 500 and 1000?
-- 151

SELECT COUNT(review_count)
AS reviews_between_500_and_1000
FROM data_analyst_jobs
WHERE review_count BETWEEN 500 AND 1000;

-- Show the average star rating for companies in each state. The output should show the state as state and the average rating for the state as avg_rating. Which state shows the highest average rating?
-- NE

SELECT location AS state, AVG(star_rating) AS avg_rating
FROM data_analyst_jobs
GROUP BY location
ORDER BY AVG(star_rating) DESC;

-- Select unique job titles from the data_analyst_jobs table. How many are there?
-- 881

SELECT DISTINCT title
FROM data_analyst_jobs;

-- How many unique job titles are there for California companies?
-- 230

SELECT COUNT(DISTINCT title)
FROM data_analyst_jobs
WHERE location = 'CA';

-- Find the name of each company and its average star rating for all companies that have more than 5000 reviews across all locations. How many companies are there with more than 5000 reviews across all locations?
-- 40

SELECT company, AVG(star_rating)
FROM data_analyst_jobs
WHERE review_count >5000
AND company IS NOT NULL
GROUP BY company;

-- Add the code to order the query in #9 from highest to lowest average star rating. Which company with more than 5000 reviews across all locations in the dataset has the highest star rating? What is that rating?
-- Unilever, GM, Nike, American Express, Microsoft, and Kaiser Permanente all have an average rating of 4.199999809

SELECT company, AVG(star_rating)
FROM data_analyst_jobs
WHERE review_count >5000
AND company IS NOT NULL
GROUP BY company
ORDER BY AVG(star_rating) DESC;

-- Find all the job titles that contain the word ‘Analyst’. How many different job titles are there?
-- 774

SELECT title
FROM data_analyst_jobs
WHERE title ILIKE '%Analyst%';

SELECT COUNT(DISTINCT title)
FROM data_analyst_jobs
WHERE title ILIKE '%Analyst%';

-- How many different job titles do not contain either the word ‘Analyst’ or the word ‘Analytics’? What word do these positions have in common?
-- 4
-- Tableau

SELECT DISTINCT title
FROM data_analyst_jobs
WHERE title NOT ILIKE '%Analyst%'
AND title NOT ILIKE '%Analytics%';

-- BONUS: You want to understand which jobs requiring SQL are hard to fill. Find the number of jobs by industry (domain) that require SQL and have been posted longer than 3 weeks.
--     Disregard any postings where the domain is NULL.
--     Order your results so that the domain with the greatest number of hard to fill jobs is at the top.
--     Which three industries are in the top 4 on this list? How many jobs have been listed for more than 3 weeks for each of the top 4?

-- Internet and Software with 62 jobs, Banks and Financial Services with 61 jobs, Consulting and Business Services with 57 jobs, and Health Care with 52 jobs

SELECT COUNT(title) AS number_of_jobs,domain
FROM data_analyst_jobs
WHERE skill ILIKE '%SQL%'
AND days_since_posting >21
AND domain IS NOT NULL
GROUP BY domain
ORDER BY COUNT(title) DESC;