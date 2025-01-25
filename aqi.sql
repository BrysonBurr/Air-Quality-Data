-- rename columns for 2023 daily aqi
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2023 aqi
ALTER TABLE public.daily_aqi_2023 ALTER COLUMN date TYPE DATE USING date::date;

-- rename columns for 2013 daily aqi
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2013 aqi
ALTER TABLE public.daily_aqi_2013 ALTER COLUMN date TYPE DATE USING date::date;

-- rename columns for 2003 daily aqi
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2003 aqi
ALTER TABLE public.daily_aqi_2003 ALTER COLUMN date TYPE DATE USING date::date;


-- Find average aqi by year by season
SELECT ROUND(AVG(aqi),2) AS aqi, 
			CASE
           WHEN EXTRACT(MONTH FROM date) BETWEEN 3 AND 5 THEN 'Spring'
           WHEN EXTRACT(MONTH FROM date) BETWEEN 6 AND 8 THEN 'Summer'
           WHEN EXTRACT(MONTH FROM date) BETWEEN 9 AND 11 THEN 'Fall'
           ELSE 'Winter'
           END AS season
FROM public.daily_aqi_2023
GROUP BY season;

-- expand query to include all years
SELECT
    year,
    ROUND(AVG(aqi), 2) AS aqi,
    CASE
        WHEN EXTRACT(MONTH FROM date) BETWEEN 3 AND 5 THEN 'Spring'
        WHEN EXTRACT(MONTH FROM date) BETWEEN 6 AND 8 THEN 'Summer'
        WHEN EXTRACT(MONTH FROM date) BETWEEN 9 AND 11 THEN 'Fall'
        ELSE 'Winter'
    END AS season
FROM (
    SELECT 2023 AS year, aqi, date FROM public.daily_aqi_2023
    UNION ALL
    SELECT 2013 AS year, aqi, date FROM public.daily_aqi_2013
    UNION ALL
    SELECT 2003 AS year, aqi, date FROM public.daily_aqi_2003
) AS combined_years
GROUP BY year, season;

-- What were the top 10 locations (by county) with worst AQI in each year? 
-- Using CTE combined with union to avoid unecessary code repetition
WITH combined_data AS (
    SELECT '2023' AS year, county_name, state_name, aqi
    FROM public.daily_aqi_2023
    UNION ALL
    SELECT '2013' AS year, county_name, state_name, aqi
    FROM public.daily_aqi_2013
    UNION ALL
    SELECT '2003' AS year, county_name, state_name, aqi
    FROM public.daily_aqi_2003
),
ranked_data AS (
    SELECT 
        year, 
        county_name, 
        state_name AS state, 
        ROUND(AVG(aqi), 2) AS aqi,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY AVG(aqi) DESC) AS rank
    FROM combined_data
    GROUP BY year, county_name, state_name
)
SELECT year, county_name, state, aqi
FROM ranked_data
WHERE rank <= 10
ORDER BY year, aqi DESC;

/* what were the top 10 locations that had the best improvement over 20 years, 
from the first year to the most recent year?  
What were the 10 locations with the worst decline over 20 years? */

-- finding best improvement, negative shows how much AQI has decreased by
SELECT
    da.county_name,
    da.state_name,
    ROUND(AVG(da.aqi) - AVG(da2.aqi), 2) AS aqi_change
 FROM public.daily_aqi_2023 da 
JOIN public.daily_aqi_2003 da2 
ON da.county_name = da2.county_name 
GROUP BY da.county_name, da.state_name
ORDER BY aqi_change ASC
LIMIT 10;

-- finding worst decline, being positive shows how much AQI has increased in 20 years
SELECT
    da.county_name,
    da.state_name,
    ROUND(AVG(da.aqi) - AVG(da2.aqi), 2) AS aqi_change
 FROM public.daily_aqi_2023 da 
JOIN public.daily_aqi_2003 da2 
ON da.county_name = da2.county_name 
GROUP BY da.county_name, da.state_name
ORDER BY aqi_change DESC
LIMIT 10;



SELECT county_name, AVG(aqi) AS aqi
FROM public.daily_aqi_2003 da
WHERE county_name = 'Uintah'
GROUP BY county_name;


-- In Utah counties, how many days of "Unhealthy" air did we have in each year?  Is it improving?  
-- could also group by county to see
-- cut off is 100. over 100 is unhealthy


-- CTE to get number of days of unhealthy day per year in Utah
-- If one county has unhealthy air quality it counts as one day for Utah, it is not double counted
WITH combined_data AS (
    SELECT '2023' AS year, date, MAX(aqi) AS max_aqi
    FROM public.daily_aqi_2023
    WHERE state_name = 'Utah'
    GROUP BY date
    UNION ALL
    SELECT '2013' AS year, date, MAX(aqi) AS max_aqi
    FROM public.daily_aqi_2013
    WHERE state_name = 'Utah'
    GROUP BY date
    UNION ALL
    SELECT '2003' AS year, date, MAX(aqi) AS max_aqi
    FROM public.daily_aqi_2003
    WHERE state_name = 'Utah'
    GROUP BY date
)
SELECT 
    year, 
    COUNT(*) AS unhealthy_days
FROM combined_data
WHERE max_aqi > 100
GROUP BY year
ORDER BY year;

-- CTE for unhealthy days by county
WITH combined_data AS (
    SELECT '2023' AS year, county_name, aqi
    FROM public.daily_aqi_2023
    WHERE state_name = 'Utah'
    UNION ALL
    SELECT '2013' AS year, county_name, aqi
    FROM public.daily_aqi_2013
    WHERE state_name = 'Utah'
    UNION ALL
    SELECT '2003' AS year, county_name, aqi
    FROM public.daily_aqi_2003
    WHERE state_name = 'Utah'
)
SELECT 
    year, 
    county_name, 
    COUNT(*) AS unhealthy_days
FROM combined_data
WHERE aqi > 100
GROUP BY year, county_name
ORDER BY county_name;


-- In Salt Lake County, which months have the most "Unhealthy" days?  Has that changed in 20 years?

SELECT
    year,
    month,
    COUNT(*) AS unhealthy_days
FROM (
    SELECT 2023 AS year, EXTRACT(month from date) AS month, aqi, county_name FROM public.daily_aqi_2023
    UNION ALL
    SELECT 2013 AS year, EXTRACT(month from date) AS month, aqi, county_name FROM public.daily_aqi_2013
    UNION ALL
    SELECT 2003 AS year, EXTRACT(month from date) AS month, aqi, county_name FROM public.daily_aqi_2003
) AS combined_years
WHERE aqi > 100 AND county_name = 'Salt Lake'
GROUP BY year, month
ORDER BY unhealthy_days DESC;
